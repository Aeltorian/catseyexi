----------------------------------------------------------------
-- Claim Shield Mixin
-- Used to add Claim Shield to a mob without overwriting
-- the onSpawn() function.
----------------------------------------------------------------
require("scripts/globals/mixins")
require("scripts/globals/utils")
----------------------------------------------------------------
g_mixins = g_mixins or {}

local claimshieldTime = 4000 -- In miliseconds.

-- Checks the list to see if the entry exists already
local function listContains(list, element)
    for _, v in pairs(list) do
        if v == element then
            return true
        end
    end

    return false
end

-- Find the index for the given entry name
local function findIndexForName(list, name)
    for index, entryName in ipairs(list) do
        if entryName == name then
            return index
        end
    end

    return nil
end

local function logListToFile(fileName, textToAdd)
    local filePath = io.popen("cd"):read'*all'
    local logFile  = filePath:sub(1, -2) .. "\\log\\claim_shield_logs\\" .. fileName .. ".html"
    local textHTML = ""
    local logRead  = io.open(logFile, "r")

    -- Handle the text for the HTML
    if logRead ~= nil then
        local oldFile = logRead:read("*all")
        textHTML = oldFile:sub(1, -15) .. textToAdd .. "</body></html>"
        logRead:close()
    else
        textHTML = "<html><title>Claim Shield Log [" .. os.date("%x", os.time()) .. "]</title><body style=\"background-color:DarkSlateGray; color:LimeGreen; font-family:Helvetica, Sans-Serif;\"><h2>Claim Shield Log [" .. os.date("%x", os.time()) .. "]</h2>" .. textToAdd .. "</body></html>"
    end

    -- Write the HTML file out
    local logWrite = io.open(logFile, "w")
    logWrite:write(textHTML)
    logWrite:close()
end

g_mixins.claim_shield = function(claimshieldMob)
    claimshieldMob:addListener("SPAWN", "CS_SPAWN", function(mob)
        mob:setClaimable(false)
        mob:setUnkillable(true)
        mob:setCallForHelpBlocked(true)
        mob:setAutoAttackEnabled(false)
        mob:setMobAbilityEnabled(false)
        mob:addStatusEffect(xi.effect.PHYSICAL_SHIELD, 999, 3, 9999)
        mob:addStatusEffect(xi.effect.MAGIC_SHIELD, 999, 3, 9999)
        mob:addStatusEffect(xi.effect.ARROW_SHIELD, 999, 3, 9999)

        mob:timer(claimshieldTime, function(mobArg)
            local enmityList = mobArg:getEnmityList()

            -- Filter so that pets will only count as a single entry along with their masters
            local entries = {}

            for _, v in pairs(enmityList) do
                local entity = v["entity"]
                local master = entity:getMaster()

                if entity:getObjType() ~= xi.objType.TRUST then
                    local name = entity:getName()

                    if
                        not entity:isPC() and
                        master and
                        master:isPC()
                    then
                        name = master:getName()
                    end

                    if not listContains(entries, name) then
                        table.insert(entries, name)
                    end
                end
            end

            local numEntries = #entries

            -- Select a winner
            local winningNum  = math.random(1, #entries)
            local winningName = "NOONE"

            for index, entryName in ipairs(entries) do
                if index == winningNum then
                    winningName = entryName
                end
            end

            local claimWinner = GetPlayerByName(winningName)

            if claimWinner then
                -- Setup Log File
                local fileName  = os.date("%x", os.time()):gsub("/", "-")
                local textToAdd = "<h3>[" .. os.date("%X", os.time()) .. "] - { " .. mobArg:getName() .. " }</h3><br><b>&emsp;Winners:</b><br>&emsp;<ul>"
            
                if claimWinner:isPC() then
                    claimWinner:incrementCharVar("[LB]CLAIMS", 1)
                end
            
                -- Message winner and their party/alliance that they've won
                local alliance = claimWinner:getAlliance()

                for _, member in pairs(alliance) do
                    local str = string.format("Your group has won the lottery for %s! (out of %i players)", mobArg:getName(), numEntries)
 
                    if #alliance == 1 then
                        str = string.format("You have won the lottery for %s! (out of %i players)", mobArg:getName(), numEntries)
                    end

                    member:PrintToPlayer(str, xi.msg.channel.SYSTEM_3, "")

                    -- Add name to Log
                    textToAdd = textToAdd .. "<li>" .. member:getName() .. "</li><br>"

                    -- Remove from entries table
                    local pos = findIndexForName(entries, member:getName())
 
                    if pos then
                        table.remove(entries, pos)
                    end
                end

                -- Finalize winners log
                textToAdd = textToAdd .. "</ul><br><b>&emsp;Losers:</b><br>&emsp;<ul>"

                -- Everyone left in the entries table isn't part of the winning group, message them and
                -- clear them from the enmity list
                for _, member in pairs(entries) do
                    local memberEntity = GetPlayerByName(member)
                    local memberParty  = memberEntity:getPartyWithTrusts()

                    for _, partyMember in pairs(memberParty) do
                        if partyMember:getObjType() == xi.objType.TRUST then
                            if partyMember:isEngaged() then
                                partyMember:disengage()
                            end

                            mobArg:clearEnmityForEntity(partyMember)
                        end
                    end

                    local header    = string.format("==================================================================")
                    local stringOne = string.format("You were not successful in the lottery for %s. (out of %i players)", mobArg:getName(), numEntries)
                    local stringTwo = string.format("Disengage from the mob immediately if it hasn't happened automatically")

                    memberEntity:PrintToPlayer(header, xi.msg.channel.SYSTEM_3, "")
                    memberEntity:PrintToPlayer(stringOne, xi.msg.channel.SYSTEM_3, "")
                    memberEntity:PrintToPlayer(stringTwo, xi.msg.channel.SYSTEM_3, "")
                    memberEntity:PrintToPlayer(header, xi.msg.channel.SYSTEM_3, "")

                    if memberEntity:getPet() ~= nil then
                        if memberEntity:getPet():isEngaged() then
                            memberEntity:getPet():disengage()
                        end

                        mobArg:clearEnmityForEntity(memberEntity:getPet())
                    end

                    -- Add name to Log
                    textToAdd = textToAdd .. "<li>" .. member .. "</li><br>"

                    if memberEntity:isEngaged() then
                        memberEntity:disengage()
                    end

                    mobArg:clearEnmityForEntity(memberEntity)
                end

                -- Finalize log and store
                textToAdd = textToAdd .. "</ul><br><br>"
                logListToFile(fileName, textToAdd)

                -- Update Claim to winner
                mobArg:updateClaim(claimWinner)
                mobArg:addEnmity(claimWinner, 1, 1000)
            end

            mobArg:setClaimable(true)
            mobArg:setUnkillable(false)
            mobArg:setCallForHelpBlocked(false)
            mobArg:setAutoAttackEnabled(true)
            mobArg:setMobAbilityEnabled(true)
            mobArg:delStatusEffectSilent(xi.effect.PHYSICAL_SHIELD)
            mobArg:delStatusEffectSilent(xi.effect.MAGIC_SHIELD)
            mobArg:delStatusEffectSilent(xi.effect.ARROW_SHIELD)
            mobArg:delStatusEffectsByFlag(0xFFFF)
            mobArg:setHP(mobArg:getMaxHP())
        end)
    end)
end

return g_mixins.claim_shield
