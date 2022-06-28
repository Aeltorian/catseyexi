-----------------------------------
-- LOGGING SETTINGS
-----------------------------------
-- All settings are attached to the `xi.settings` object. This is published globally, and be accessed from C++ and any script.
--
-- This file is concerned mainly with configuring the logging across all server executables.
-----------------------------------

xi = xi or {}
xi.settings = xi.settings or {}

xi.settings.logging =
{
    TRACE_NAVMESH = false,
    TRACE_PACKETS = false,
}
