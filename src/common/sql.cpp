﻿/*
===========================================================================

  Copyright (c) 2010-2015 Darkstar Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "logging.h"
#include "settings.h"
#include "timer.h"
#include "tracy.h"
#include "xirand.h"

#include "sql.h"

#include <any>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <thread>

SqlConnection::SqlConnection()
: SqlConnection(settings::get<std::string>("network.SQL_LOGIN").c_str(),
                settings::get<std::string>("network.SQL_PASSWORD").c_str(),
                settings::get<std::string>("network.SQL_HOST").c_str(),
                settings::get<uint16>("network.SQL_PORT"),
                settings::get<std::string>("network.SQL_DATABASE").c_str())
{
    // Just forwarding the default credentials to the next contrictor
}

SqlConnection::SqlConnection(const char* user, const char* passwd, const char* host, uint16 port, const char* db)
: m_LatencyWarning(false)
{
    TracyZoneScoped;

    self = new Sql_t();

    // Allocates or initializes a MYSQL object suitable for mysql_real_connect().
    // If mysql is a NULL pointer, the function allocates, initializes, and returns a new object.
    // Otherwise, the object is initialized and the address of the object is returned.
    // If mysql_init() allocates a new object, it is freed when mysql_close() is called to close the connection.
    if (mysql_init(&self->handle) == nullptr)
    {
        ShowCritical("mysql_init failed!");
    }

    self->lengths = nullptr;
    self->result  = nullptr;

    bool reconnect = true;
    mysql_options(&self->handle, MYSQL_OPT_RECONNECT, &reconnect);

    self->buf.clear();
    if (!mysql_real_connect(&self->handle, host, user, passwd, db, (uint32)port, nullptr /*unix_socket*/, 0 /*clientflag*/))
    {
        ShowCritical("%s", mysql_error(&self->handle));
    }

    m_User   = user;
    m_Passwd = passwd;
    m_Host   = host;
    m_Port   = port;
    m_Db     = db;

    InitPreparedStatements();

    SetupKeepalive();
}

SqlConnection::~SqlConnection()
{
    TracyZoneScoped;
    if (self)
    {
        mysql_close(&self->handle);
        FreeResult();
        delete self;
    }
}

std::string SqlConnection::GetClientVersion()
{
    return fmt::format("database client version: {}", MARIADB_PACKAGE_VERSION);
}

std::string SqlConnection::GetServerVersion()
{
    std::string serverVer = "";
    auto        ret       = Query("SELECT VERSION()");
    if (ret != SQL_ERROR && NumRows() != 0 && NextRow() == SQL_SUCCESS)
    {
        serverVer = GetStringData(0);
    }

    return fmt::format("database server version: {}", serverVer);
}

int32 SqlConnection::GetTimeout(uint32* out_timeout)
{
    if (out_timeout && SQL_SUCCESS == Query("SHOW VARIABLES LIKE 'wait_timeout'"))
    {
        char*  data;
        size_t len;
        if (SQL_SUCCESS == NextRow() && SQL_SUCCESS == GetData(1, &data, &len))
        {
            *out_timeout = (uint32)strtoul(data, nullptr, 10);
            FreeResult();
            return SQL_SUCCESS;
        }
        FreeResult();
    }
    ShowCritical("Query: %s", self->buf);
    ShowCritical("GetTimeout: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
    return SQL_ERROR;
}

int32 SqlConnection::GetColumnNames(const char* table, char* out_buf, size_t buf_len, char sep)
{
    char*  data;
    size_t len;
    size_t off = 0;

    if (self == nullptr || SQL_ERROR == Query("EXPLAIN `%s`", table))
    {
        return SQL_ERROR;
    }

    out_buf[off] = '\0';
    while (SQL_SUCCESS == NextRow() && SQL_SUCCESS == GetData(0, &data, &len))
    {
        len = strnlen(data, len);
        if (off + len + 2 > buf_len)
        {
            ShowDebug("GetColumns: output buffer is too small");
            *out_buf = '\0';
            return SQL_ERROR;
        }
        memcpy(out_buf + off, data, len);
        off += len;
        out_buf[off++] = sep;
    }
    out_buf[off] = '\0';
    FreeResult();
    return SQL_SUCCESS;
}

int32 SqlConnection::SetEncoding(const char* encoding)
{
    if (mysql_set_character_set(&self->handle, encoding) == 0)
    {
        return SQL_SUCCESS;
    }
    return SQL_ERROR;
}

void SqlConnection::SetupKeepalive()
{
    TracyZoneScoped;
    auto now        = std::chrono::system_clock::now().time_since_epoch();
    auto nowSeconds = std::chrono::duration_cast<std::chrono::seconds>(now).count();
    m_LastPing      = nowSeconds;

    // set a default value first
    uint32 timeout = 7200; // 2 hours

    // request the timeout value from the mysql server
    GetTimeout(&timeout);

    if (timeout < 60)
    {
        timeout = 60;
    }

    // 30-second reserve
    uint8 reserve  = 30;
    m_PingInterval = timeout + reserve;
}

void SqlConnection::CheckCollation()
{
    // Check collation is what we require
    auto ret = QueryStr("SHOW VARIABLES LIKE 'collation%';");
    if (ret != SQL_ERROR && NumRows())
    {
        bool foundError = false;
        while (NextRow() == SQL_SUCCESS)
        {
            auto collationType     = GetStringData(0);
            auto collectionSetting = GetStringData(1);
            if (!starts_with(collectionSetting, "utf8"))
            {
                foundError = true;
                // clang-format off
                ShowWarning(fmt::format("Unexpected collation setting in database: {}: {}. Expected utf8*.",
                    collationType, collectionSetting).c_str());
                // clang-format on
            }
        }

        if (foundError)
        {
            ShowWarning("This can result in data reads and writes being corrupted!");
        }
    }
}

int32 SqlConnection::TryPing()
{
    TracyZoneScoped;
    auto now        = std::chrono::system_clock::now().time_since_epoch();
    auto nowSeconds = std::chrono::duration_cast<std::chrono::seconds>(now).count();

    if (m_LastPing + m_PingInterval <= nowSeconds)
    {
        ShowInfo("Pinging SQL server to keep connection alive");

        m_LastPing = nowSeconds;

        auto startId = mysql_thread_id(&self->handle);
        try
        {
            if (mysql_ping(&self->handle) == 0)
            {
                auto endId = mysql_thread_id(&self->handle);
                if (startId != endId)
                {
                    ShowWarning("DB thread ID has changed. You have been reconnected.");
                    // TODO: Maybe we need to refresh the prepared statements now?
                }
                return SQL_SUCCESS;
            }
        }
        catch (const std::exception& e)
        {
            ShowCritical(fmt::format("mysql_ping failed: {}", e.what()));
        }
        catch (...)
        {
            ShowCritical("mysql_ping failed with unhandled exception");
        }
    }

    return SQL_ERROR;
}

size_t SqlConnection::EscapeStringLen(char* out_to, const char* from, size_t from_len)
{
    if (self)
    {
        return mysql_real_escape_string(&self->handle, out_to, from, (uint32)from_len);
    }
    return mysql_escape_string(out_to, from, (uint32)from_len);
}

size_t SqlConnection::EscapeString(char* out_to, const char* from)
{
    return EscapeStringLen(out_to, from, strlen(from));
}

int32 SqlConnection::QueryStr(const char* query)
{
    TracyZoneScoped;
    TracyZoneCString(query);

    DebugSQL(query);

    if (self == nullptr)
    {
        return SQL_ERROR;
    }

    FreeResult();
    self->buf.clear();

    auto startTime = hires_clock::now();

    {
        self->buf += query;
        if (mysql_real_query(&self->handle, self->buf.c_str(), (unsigned int)self->buf.length()))
        {
            ShowError("Query: %s", self->buf);
            ShowError("mysql_real_query: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
            return SQL_ERROR;
        }
    }

    {
        self->result = mysql_store_result(&self->handle);
        if (mysql_errno(&self->handle) != 0)
        {
            ShowError("Query: %s", self->buf);
            ShowError("mysql_store_result: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
            return SQL_ERROR;
        }
    }

    auto endTime = hires_clock::now();
    auto dTime   = std::chrono::duration_cast<std::chrono::milliseconds>(endTime - startTime);
    if (m_LatencyWarning)
    {
        if (dTime > 250ms)
        {
            ShowError(fmt::format("Query took {}ms: {}", dTime.count(), self->buf));
        }
        else if (dTime > 100ms)
        {
            ShowWarning(fmt::format("Query took {}ms: {}", dTime.count(), self->buf));
        }
    }

    return SQL_SUCCESS;
}

uint64 SqlConnection::AffectedRows()
{
    if (self)
    {
        return (uint64)mysql_affected_rows(&self->handle);
    }
    return 0;
}

uint64 SqlConnection::LastInsertId()
{
    if (self)
    {
        return (uint64)mysql_insert_id(&self->handle);
    }
    return 0;
}

uint32 SqlConnection::NumColumns()
{
    if (self && self->result)
    {
        return mysql_num_fields(self->result);
    }
    return 0;
}

uint64 SqlConnection::NumRows()
{
    if (self && self->result)
    {
        return mysql_num_rows(self->result);
    }
    return 0;
}

int32 SqlConnection::NextRow()
{
    if (self && self->result)
    {
        self->row = mysql_fetch_row(self->result);
        if (self->row)
        {
            self->lengths = mysql_fetch_lengths(self->result);
            return SQL_SUCCESS;
        }
        self->lengths = nullptr;
        if (mysql_errno(&self->handle) == 0)
        {
            return SQL_NO_DATA;
        }
    }
    ShowCritical("Query: %s", self->buf);
    ShowCritical("NextRow: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
    return SQL_ERROR;
}

int32 SqlConnection::GetData(size_t col, char** out_buf, size_t* out_len)
{
    if (self && self->row)
    {
        if (col < NumColumns())
        {
            if (out_buf)
            {
                *out_buf = self->row[col];
            }
            if (out_len)
            {
                *out_len = self->lengths[col];
            }
        }
        else // out of range - ignore
        {
            if (out_buf)
            {
                *out_buf = nullptr;
            }
            if (out_len)
            {
                *out_len = 0;
            }
        }
        return SQL_SUCCESS;
    }
    ShowCritical("Query: %s", self->buf);
    ShowCritical("GetData: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
    return SQL_ERROR;
}

int8* SqlConnection::GetData(size_t col)
{
    if (self && self->row)
    {
        if (col < NumColumns())
        {
            return (int8*)self->row[col];
        }
    }
    ShowCritical("Query: %s", self->buf);
    ShowCritical("GetData: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
    return nullptr;
}

int32 SqlConnection::GetIntData(size_t col)
{
    if (self && self->row)
    {
        if (col < NumColumns())
        {
            return (self->row[col] ? atoi(self->row[col]) : 0);
        }
    }
    ShowCritical("Query: %s", self->buf);
    ShowCritical("GetIntData: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
    return 0;
}

uint32 SqlConnection::GetUIntData(size_t col)
{
    if (self && self->row)
    {
        if (col < NumColumns())
        {
            return (self->row[col] ? (uint32)strtoul(self->row[col], nullptr, 10) : 0);
        }
    }
    ShowCritical("Query: %s", self->buf);
    ShowCritical("GetUIntData: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
    return 0;
}

uint64 SqlConnection::GetUInt64Data(size_t col)
{
    if (self && self->row)
    {
        if (col < NumColumns())
        {
            return (self->row[col] ? (uint64)strtoull(self->row[col], NULL, 10) : 0);
        }
    }
    ShowCritical("Query: %s", self->buf);
    ShowCritical("GetUInt64Data: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
    return 0;
}

float SqlConnection::GetFloatData(size_t col)
{
    if (self && self->row)
    {
        if (col < NumColumns())
        {
            return (self->row[col] ? (float)atof(self->row[col]) : 0.f);
        }
    }
    ShowCritical("Query: %s", self->buf);
    ShowCritical("GetFloatData: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
    return 0;
}

std::string SqlConnection::GetStringData(size_t col)
{
    if (self && self->row)
    {
        if (col < NumColumns())
        {
            return std::string(self->row[col] ? (const char*)self->row[col] : "");
        }
    }
    ShowCritical("Query: %s", self->buf);
    ShowCritical("GetStringData: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
    return "";
}

void SqlConnection::FreeResult()
{
    if (self && self->result)
    {
        mysql_free_result(self->result);
        self->result  = nullptr;
        self->row     = nullptr;
        self->lengths = nullptr;
    }
}

bool SqlConnection::SetAutoCommit(bool value)
{
    TracyZoneScoped;
    uint8 val = (value) ? 1 : 0;

    // if( self && mysql_autocommit(&self->handle, val) == 0)
    if (self && Query("SET @@autocommit = %u", val) != SQL_ERROR)
    {
        return true;
    }

    ShowCritical("Query: %s", self->buf);
    ShowCritical("SetAutoCommit: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
    return false;
}

bool SqlConnection::GetAutoCommit()
{
    TracyZoneScoped;
    if (self)
    {
        int32 ret = Query("SELECT @@autocommit;");

        if (ret != SQL_ERROR && NumRows() > 0 && NextRow() == SQL_SUCCESS)
        {
            return (GetUIntData(0) == 1);
        }
    }

    ShowCritical("Query: %s", self->buf);
    ShowCritical("GetAutoCommit: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
    return false;
}

bool SqlConnection::TransactionStart()
{
    TracyZoneScoped;
    if (self && Query("START TRANSACTION;") != SQL_ERROR)
    {
        return true;
    }

    ShowCritical("Query: %s", self->buf);
    ShowCritical("TransactionStart: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
    return false;
}

bool SqlConnection::TransactionCommit()
{
    TracyZoneScoped;
    if (self && mysql_commit(&self->handle) == 0)
    {
        return true;
    }

    ShowCritical("Query: %s", self->buf);
    ShowCritical("TransactionCommit: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
    return false;
}

bool SqlConnection::TransactionRollback()
{
    TracyZoneScoped;
    if (self && Query("ROLLBACK;") != SQL_ERROR)
    {
        return true;
    }

    ShowCritical("Query: %s", self->buf);
    ShowCritical("TransactionRollback: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
    return false;
}

// Prepares to profile a single query.
// If you try to query multiple queries inside a start/end block,
// only the most recent will print results.
void SqlConnection::StartProfiling()
{
    TracyZoneScoped;
    if (self && QueryStr("SET profiling = 1;") != SQL_ERROR)
    {
        return;
    }

    ShowCritical("Query: %s", self->buf);
    ShowCritical("StartProfiling: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
}

// Finished profiling a single query.
// Will print out a table corresponding to the results shown by `SHOW PROFILE;`
// If you try to query multiple queries inside a start/end block,
// only the most recent will print results.
void SqlConnection::FinishProfiling()
{
    TracyZoneScoped;
    if (!self)
    {
        return;
    }

    auto lastQuery = self->buf;
    if (QueryStr("SHOW PROFILE;") != SQL_ERROR && NumRows() > 0)
    {
        std::string outStr = "SQL SHOW PROFILE:\n";
        outStr += fmt::format("Query: {}\n", lastQuery);
        outStr += fmt::format("| {:<31}| {:<8} |\n", "Status", "Duration");
        outStr += fmt::format("|{:=<32}|{:=<10}|\n", "", "");

        while (NextRow() == SQL_SUCCESS)
        {
            auto category    = GetStringData(0);
            auto measurement = GetStringData(1);
            outStr += fmt::format("| {:<31}| {:<8} |\n", category, measurement);
        }
        QueryStr("SET profiling = 0;");
        ShowInfo(outStr);
        return;
    }

    ShowCritical("Query: %s", self->buf);
    ShowCritical("FinishProfiling: SQL_ERROR: %s (%u)", mysql_error(&self->handle), mysql_errno(&self->handle));
}

void SqlConnection::InitPreparedStatements()
{
    TracyZoneScoped;
    auto add = [&](std::string const& name, std::string const& query)
    {
        auto st                    = std::make_shared<SqlPreparedStatement>(&self->handle, query);
        m_PreparedStatements[name] = st;
    };

    add("GET_CHAR_VAR", "SELECT value FROM char_vars WHERE charid = (?) AND varname = (?) LIMIT 1;");
}

std::shared_ptr<SqlPreparedStatement> SqlConnection::GetPreparedStatement(std::string const& name)
{
    TracyZoneScoped;
    return m_PreparedStatements[name];
}
