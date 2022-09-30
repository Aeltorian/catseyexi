require("scripts/globals/msg")

xi = xi or {}

local maxAreas =
{
    -- Temenos
    { Max = 8, Zones = { 37 } },

    -- Apollyon
    { Max = 6, Zones = { 38 } },

    -- Dynamis
    { Max = 1, Zones = { 39, 40, 41, 42, 134, 135, 185, 186, 187, 188, 29, 140 } }, -- riverneb, ghelsba
}

function onBattlefieldHandlerInitialise(zone)
    local id      = zone:getID()
    local default = 3

    for _, battlefield in pairs(maxAreas) do
        for _, zoneid in pairs(battlefield.Zones) do
            if id == zoneid then
                return battlefield.Max
             end
        end
    end

    return default
end

xi.battlefield = {}
xi.battlefield.contents = {}
xi.battlefield.contentsByZone = {}

xi.battlefield.status =
{
    OPEN     = 0,
    LOCKED   = 1,
    WON      = 2,
    LOST     = 3,
}

xi.battlefield.returnCode =
{
    WAIT              = 1,
    CUTSCENE          = 2,
    INCREMENT_REQUEST = 3,
    LOCKED            = 4,
    REQS_NOT_MET      = 5,
    BATTLEFIELD_FULL  = 6
}

xi.battlefield.leaveCode =
{
    EXIT   = 1,
    WON    = 2,
    WARPDC = 3,
    LOST   = 4
}

xi.battlefield.dropChance =
{
    EXTREMELY_LOW  = 2,
    VERY_LOW       = 10,
    LOW            = 30,
    NORMAL         = 50,
    HIGH           = 70,
    VERY_HIGH      = 100,
    EXTREMELY_HIGH = 140,
}

xi.battlefield.id =
{
    SHADOW_LORD_BATTLE = 160,
    WHERE_TWO_PATHS_CONVERGE = 161,
    SE_APOLLYON = 1293,
}

Battlefield = setmetatable({}, { __index = Container })
Battlefield.__index = Battlefield
Battlefield.__eq = function(m1, m2)
    return m1.id == m2.id
end

-- Creates a new Battlefield interaction
-- Data takes the following keys:
--  - zoneId: Which zone this battlefield exists within (required)
--  - battlefieldId: Battlefield ID used in the database (required)
--  - menuBit: The bit used to communicate with the client on which menu item this battlefield is (required)
--  - area: Some battlefields has multiple areas (Burning Circles) while others have fixed areas (Apollyon). Set to have a fixed area. (optional)
--  - entryNPC: The name of the NPC used for entering
--  - exitNPC: The name of the NPC used for exiting
--  - requiredItems: Items required to be traded to enter the battlefield (optional)
--  - createWornItem: Should a worn item is created with the required item (optional)
--  - requiredKeyItems: Key items required to be able to enter the battlefield - these are removed upon entry (optional)
--  - title: Title given to players upon victory (optional)
--  - grantXP: Amount of XP to grant upon victory (optional)
function Battlefield:new(data)
    local obj = Container:new(Battlefield.getVarPrefix(data.battlefieldId))
    setmetatable(obj, self)
    -- Which zone this battlefield exists within
    obj.zoneId = data.zoneId
    -- Battlefield ID used in the database
    obj.battlefieldId = data.battlefieldId
    -- The bit used to communicate with the client on which menu item this battlefield is
    obj.menuBit = data.menuBit
    -- Some battlefields has multiple areas (Burning Circles) while others have fixed areas (Apollyon). Set to have a fixed area.
    obj.area = data.area
    -- Monster battlefield groups added with battlefield:addGroups()
    obj.groups = {}
    -- Pathing for monsters and npcs within the battlefield
    obj.paths = {}
    -- Loot spawned in the Armoury Crate(s)
    obj.loot = {}
    -- Items required to be traded to enter the battlefield
    obj.requiredItems = data.requiredItems or {}
    -- Should a worn item is created with the required item
    obj.createWornItem = data.createWornItem or true
    -- Key items required to be able to enter the battlefield - these are removed upon entry
    obj.requiredKeyItems = data.requiredKeyItems or {}
    -- The name of the NPC used for entering
    obj.entryNpc = data.entryNpc
    -- The name of the NPC used for exiting
    obj.exitNpc = data.exitNpc
    -- Title given to players upon victory
    obj.title = data.title
    -- Amount of XP to grant upon victory
    obj.grantXP = data.grantXP
    obj.sections = { { [obj.zoneId] = {} } }
    return obj
end

function Battlefield.getVarPrefix(battlefieldID)
    return string.format("Battlefield[%d]", battlefieldID)
end

function Battlefield:register()
    -- Only hookup the entry and exit callbacks if this is the first in the zone
    -- If we do all of them then each trigger/trade/event occurs twice
    local existing = xi.battlefield.contents[self.battlefieldId]
    if (existing and existing.hasCallbacks) or not utils.hasKey(self.zoneId, xi.battlefield.contentsByZone) then
        if self.entryNpc then
            self:setEntryNpc(self.entryNpc)
        end

        if self.exitNpc then
            self:setExitNpc(self.exitNpc)
        end
        self.hasCallbacks = true
    end

    xi.battlefield.contents[self.battlefieldId] = self
    if utils.hasKey(self.zoneId, xi.battlefield.contentsByZone) then
        table.insert(xi.battlefield.contentsByZone[self.zoneId], self)
    else
        xi.battlefield.contentsByZone[self.zoneId] = { self }
    end
    return self
end

function Battlefield:checkRequirements(player, npc, registrant, trade)
    for _, keyItem in ipairs(self.requiredKeyItems) do
        if not player:hasKeyItem(keyItem) then
            return false
        end
    end

    if trade and #self.requiredItems > 0 then
        if not npcUtil.tradeHasExactly(trade, self.requiredItems) then
            return false
        end
    end

    return true
end

function Battlefield:checkSkipCutscene(player)
    return false
end

function Battlefield:setEntryNpc(entryNpc)
    local entry =
    {
        [entryNpc] =
        {
            onTrade = utils.bind(self.onEntryTrade, self),
            onTrigger = utils.bind(self.onEntryTrigger, self),
        },
        onEventUpdate =
        {
            [32000] = utils.bind(self.onEntryEventUpdate, self),
            [32003] = utils.bind(self.onExitEventUpdate, self),
        },
        onEventFinish =
        {
            [32000] = utils.bind(self.onEventFinishEnter, self),
            [32001] = utils.bind(self.onEventFinishWin, self),
            [32002] = utils.bind(self.onEventFinishEnter, self),
            [32003] = utils.bind(self.onFinishEnterExit, self),
        }
    }

    utils.append(self.sections[1][self.zoneId], entry)
    self.entryNpc = entryNpc
end

function Battlefield:setExitNpc(exitNpc)
    local exit =
    {
        [exitNpc] =
        {
            onTrigger = utils.bind(self.onExitTrigger, self),
        },
    }

    utils.append(self.sections[1][self.zoneId], exit);
    self.exitNpc = exitNpc
end

function Battlefield:onEntryTrade(player, npc, trade, onUpdate)
    -- Check if player's party has level sync
    if xi.battlefield.rejectLevelSyncedParty(player, npc) then
        return false
    end

    -- Validate trade
    if not trade then
        return false
    end

    if #self.requiredItems > 0 and not npcUtil.tradeHasExactly(trade, self.requiredItems) then
        return false
    end

    -- Check if the player is trading exactly one item but it is worn
    if #self.requiredItems == 1 and self.createWornItem and player:hasWornItem(self.requiredItems[1]) then
        player:messageBasic(xi.msg.basic.ITEM_UNABLE_TO_USE_2, 0, 0)
        return false
    end

    -- Validate battlefield status
    if player:hasStatusEffect(xi.effect.BATTLEFIELD) and not onUpdate then
        player:messageBasic(xi.msg.basic.WAIT_LONGER, 0, 0)
        return false
    end

    -- Check if another party member has battlefield status effect. If so, don't allow trade.
    local alliance = player:getAlliance()
    for _, member in pairs(alliance) do
        if member:hasStatusEffect(xi.effect.BATTLEFIELD) then
            player:messageBasic(xi.msg.basic.WAIT_LONGER, 0, 0)

            return false
        end
    end

    -- Open menu of valid battlefields
    local options = xi.battlefield.getBattlefieldOptions(player, npc, trade)
    if options ~= 0 then
        if not onUpdate then
            player:startEvent(32000, 0, 0, 0, options, 0, 0, 0, 0)
        end

        return true
    end

    return false
end

function Battlefield:onEntryTrigger(player, npc)
    -- Cannot enter if anyone in party is level/master sync'd
    if xi.battlefield.rejectLevelSyncedParty(player, npc) then
        return false
    end

    -- Player has battlefield status effect. That means a battlefield is open OR the player is inside a battlefield.
    if player:hasStatusEffect(xi.effect.BATTLEFIELD) then
        -- Player is outside battlefield. Attempting to enter.
        -- TODO(jmcmorris): Is this going to be triggered for each battlefield in the zone?
        local status = player:getStatusEffect(xi.effect.BATTLEFIELD)
        local bfid = status:getPower()
        if self.battlefieldId ~= bfid then
            return false
        end

        if not self.checkRequirements(player, npc, bfid, false) then
            return false
        end

        player:startEvent(32000, 0, 0, 0, self.menuBit, 0, 0, 0, 0)
        return true
    end

    -- Player doesn't have battlefield status effect. That means player wants to register a new battlefield OR is attempting to enter a closed one.
    -- Check if another party member has battlefield status effect. If so, that means the player is trying to enter a closed battlefield.
    local alliance = player:getAlliance()
    for _, member in pairs(alliance) do
        if member:hasStatusEffect(xi.effect.BATTLEFIELD) then
            -- player:messageSpecial() -- You are eligible but cannot enter.
            return false
        end
    end

    -- No one in party/alliance has battlefield status effect. We want to register a new battlefield.
    local options = xi.battlefield.getBattlefieldOptions(player, npc)

    -- GMs get access to all BCNMs (FLAG_GM = 0x04000000)
    if player:getGMLevel() > 0 and player:checkNameFlags(0x04000000) then
        options = 268435455
    end

    -- options = 268435455 -- uncomment to open menu with all possible battlefields
    if options == 0 then
        return false
    end

    player:startEvent(32000, 0, 0, 0, options, 0, 0, 0, 0)
    return true
end

function Battlefield:onEntryEventUpdate(player, csid, option, extras)
    if option == 0 or option == 255 then
        -- todo: check if battlefields full, check party member requiremenst
        return false
    end

    if bit.rshift(option, 4) ~= self.menuBit then
        return false
    end

    local clearTime = 1
    local name      = "Meme"
    local partySize = 1

    local area = self.area or (player:getLocalVar("[battlefield]area") + 1)
    if self.area ~= 0 then
        area = self.area
    end

    local result = player:registerBattlefield(self.battlefieldId, area)
    local status = xi.battlefield.status.OPEN

    if result ~= xi.battlefield.returnCode.CUTSCENE then
        if result == xi.battlefield.returnCode.INCREMENT_REQUEST then
            if area < 3 then
                player:setLocalVar("[battlefield]area", area)
            else
                result = xi.battlefield.returnCode.WAIT
                player:updateEvent(result)
            end
        end

        return false
    end

    -- Only allow entrance if battlefield is open and player has battlefield effect, witch can be lost mid battlefield selection.
    if
        not player:getBattlefield() and
        player:hasStatusEffect(xi.effect.BATTLEFIELD)
        -- and id:getStatus() == xi.battlefield.status.OPEN -- TODO: Uncomment only once that can-of-worms is dealt with.
    then
        player:enterBattlefield()
    end

    -- Handle record
    local initiatorId = 0
    local battlefield = player:getBattlefield()

    if battlefield then
        name, clearTime, partySize = battlefield:getRecord()
        initiatorId, _ = battlefield:getInitiator()
    end

    -- Register party members
    if initiatorId == player:getID() then
        local effect = player:getStatusEffect(xi.effect.BATTLEFIELD)
        local zone   = player:getZoneID()

        -- Handle traded items
        if #self.requiredItems > 0 then
            if self.createWornItem and player:hasItem(self.requiredItems[1]) then
                player:createWornItem(self.requiredItems[1])
            else
                player:tradeComplete()
            end
        end

        -- Handle party/alliance members
        local alliance = player:getAlliance()
        for _, member in pairs(alliance) do
            if
                member:getZoneID() == zone and
                not member:hasStatusEffect(xi.effect.BATTLEFIELD) and
                not member:getBattlefield()
            then
                member:addStatusEffect(effect)
                member:registerBattlefield(self.battlefieldId, area, player:getID())
            end
        end
    end

    player:updateEvent(result, self.menuBit, 0, clearTime, partySize, self:checkSkipCutscene(player))
    player:updateEventString(name)
    return status < xi.battlefield.status.LOCKED and result < xi.battlefield.returnCode.LOCKED
end

function Battlefield:onEventFinishEnter(player, csid, option)
    player:setLocalVar("[battlefield]area", 0)
end

function Battlefield:onEventFinishWin(player, csid, option)
    if self.title then
        player:addTitle(self.title)
    end
    if self.grantXP then
        player:addExp(self.grantXP)
    end
end

function Battlefield:onExitTrigger(player, npc)
    if player:getBattlefield() then
        player:startOptionalCutscene(32003)
    end
end

function Battlefield:onExitEventUpdate(player, csid, option, npc)
    if option == 2 then
        player:updateEvent(3)
    elseif option == 3 then
        player:updateEvent(0)
    end
end

function Battlefield:onFinishEnterExit(player, csid, option)
    if option == 4 and player:getBattlefield() then
        player:leaveBattlefield(1)
    end
end

function Battlefield:onBattlefieldInitialise(battlefield)
    if #self.loot > 0 then
        battlefield:setLocalVar("loot", 1)
    end

    battlefield:addGroups(self.groups)

    for mobId, path in pairs(self.paths) do
        GetMobByID(mobId):pathThrough(path, xi.path.flag.PATROL)
    end
end

function Battlefield:onBattlefieldTick(battlefield, tick)
    local leavecode     = -1
    local canLeave      = false

    local status        = battlefield:getStatus()
    local players       = battlefield:getPlayers()
    local cutsceneTimer = battlefield:getLocalVar("cutsceneTimer")
    local phaseChange   = battlefield:getLocalVar("phaseChange")

    if status == xi.battlefield.status.LOST then
        leavecode = xi.battlefield.leaveCode.LOST
    elseif status == xi.battlefield.status.WON then
        leavecode = xi.battlefield.leaveCode.WON
    end

    if leavecode ~= -1 then
        -- Artificially inflate the time we remain inside the battlefield.
        battlefield:setLocalVar("cutsceneTimer", cutsceneTimer + 1)

        canLeave = battlefield:getLocalVar("loot") == 0

        if status == xi.battlefield.status.WON and not canLeave then
            if battlefield:getLocalVar("lootSpawned") == 0 and battlefield:spawnLoot() then
                canLeave = false
            elseif battlefield:getLocalVar("lootSeen") == 1 then
                canLeave = true
            end
        end
    end

    -- Check that players haven't all died or that their dead time is over.
    xi.battlefield.HandleWipe(battlefield, players)

    -- Cleanup battlefield.
    if
        not xi.battlefield.SendTimePrompts(battlefield, players) or -- If we cant send anymore time prompts, they are out of time.
        (canLeave and cutsceneTimer >= 15)                          -- Players won and artificial time inflation is over.
    then
        battlefield:cleanup(true)
    elseif status == xi.battlefield.status.LOST then -- Players lost.
        for _, player in pairs(players) do
            player:messageSpecial(zones[player:getZoneID()].text.PARTY_MEMBERS_HAVE_FALLEN)
        end

        battlefield:cleanup(true)
    end

    -- Check if theres at least 1 mob alive.
    local killedallmobs = true
    local mobs = battlefield:getMobs(true, false)
    for _, mob in pairs(mobs) do
        if mob:isAlive() then
            killedallmobs = false
            break
        end
    end

    -- Set win status.
    if killedallmobs and phaseChange == 0 then
        battlefield:setStatus(xi.battlefield.status.WON)
    end
end

function Battlefield:onBattlefieldRegister(player, battlefield)
end

function Battlefield:onBattlefieldStatusChange(battlefield, players, status)
    -- Remove battlefield effect for players in alliance not inside battlefield once the battlefield gets locked. Do this only once.
    if status == xi.battlefield.status.LOCKED and battlefield:getLocalVar("statusRemoval") == 0 then
        battlefield:setLocalVar("statusRemoval", 1)

        for _, player in pairs(players) do
            local alliance = player:getAlliance()
            for _, member in pairs(alliance) do
                if member:hasStatusEffect(xi.effect.BATTLEFIELD) and not member:getBattlefield() then
                    member:delStatusEffect(xi.effect.BATTLEFIELD)
                end
            end
        end
    end
end

function Battlefield:onBattlefieldEnter(player, battlefield)
    for _, keyItem in ipairs(self.requiredKeyItems) do
        player:delKeyItem(keyItem)
    end
end

function Battlefield:onBattlefieldDestroy(battlefield)
end

function Battlefield:onBattlefieldLeave(player, battlefield, leavecode)
    if leavecode == xi.battlefield.leaveCode.WON then
        self:onBattlefieldWin(player, battlefield)
    elseif leavecode == xi.battlefield.leaveCode.LOST then
        self:onBattlefieldLoss(player, battlefield)
    end
end

function Battlefield:onBattlefieldWin(player, battlefield)
    local _, clearTime, partySize = battlefield:getRecord()
    player:startEvent(32001, battlefield:getArea(), clearTime, partySize, battlefield:getTimeInside(), 1, self.menuBit, 0)
end

function Battlefield:onBattlefieldLoss(player, battlefield)
    player:startEvent(32002)
end

function xi.battlefield.getBattlefieldOptions(player, npc, trade)
    local result = 0
    local contents = xi.battlefield.contentsByZone[player:getZoneID()]

    if contents == nil then
        return result
    end

    for _, content in ipairs(contents) do
        if content:checkRequirements(player, npc, true, trade) and not player:battlefieldAtCapacity(content.battlefieldId) then
            result = utils.mask.setBit(result, content.menuBit, true)
        end
    end

    return result
end

function xi.battlefield.rejectLevelSyncedParty(player, npc)
    for _, member in pairs(player:getAlliance()) do
        if member:isLevelSync() then
            local zoneId = player:getZoneID()
            local ID = zones[zoneId]
            -- Your party is unable to participate because certain members' levels are restricted
            player:messageText(npc, ID.text.MEMBERS_LEVELS_ARE_RESTRICTED, false)
            return true
        end
    end
    return false
end

BattlefieldMission = setmetatable({ }, { __index = Battlefield })
BattlefieldMission.__index = BattlefieldMission
BattlefieldMission.__eq = function(m1, m2)
    return m1.name == m2.name
end

-- Creates a new Limbus Battlefield interaction
-- Data takes the additional following keys:
--  - missionArea: The mission area this battlefield is associated with (optional)
--  - mission: The mission this battlefield is associated with (optional)
--  - missionStatusArea: The mission area to retrieve the mission status from. Will default to using the player's nation (optional)
--  - missionStatus: The optional extra status information xi.mission.status (optional)
--  - requiredMissionStatus: The required mission status to enter
--  - skipMissionStatus: The required mission status to skip the cutscene. Defaults to the required mission status.
function BattlefieldMission:new(data)
    local obj = Battlefield:new(data)
    setmetatable(obj, self)
    -- The mission area ID this battlefield is associated with
    obj.missionArea = data.missionArea
    -- The mission this battlefield is associated with
    obj.mission = data.mission
    -- The mission area to retrieve the mission status from. Will default to using the player's nation (optional)
    obj.missionStatusArea = data.missionStatusArea
    -- The optional extra status information xi.mission.status (optional)
    obj.missionStatus = data.missionStatus
    -- The required mission status to enter
    obj.requiredMissionStatus = data.requiredMissionStatus
    -- The required mission status to skip the cutscene
    obj.skipMissionStatus = data.skipMissionStatus or data.requiredMissionStatus
    return obj
end

function BattlefieldMission:checkRequirements(player, npc, registrant, trade)
    Battlefield.checkRequirements(self, player, npc, registrant, trade)
    local missionArea = self.missionArea or player:getNation()
    local current = player:getCurrentMission(missionArea)
    local missionStatusArea = self.missionStatusArea or player:getNation()
    local status = player:getMissionStatus(missionStatusArea)
    return current == self.mission and status == self.requiredMissionStatus
end

function BattlefieldMission:checkSkipCutscene(player)
    local missionArea = self.missionArea or player:getNation()
    local current = player:getCurrentMission(missionArea)
    local missionStatusArea = self.missionStatusArea or player:getNation()
    local status = player:getMissionStatus(missionStatusArea, self.missionStatus)
    return player:hasCompletedMission(missionArea, self.mission) or
        (current == self.mission and status > self.skipMissionStatus)
end

function BattlefieldMission:onBattlefieldWin(player, battlefield)
    Battlefield.onBattlefieldWin(self, player, battlefield)

    local current = player:getCurrentMission(self.missionArea)
    if current == self.mission then
        player:setLocalVar("battlefieldWin", battlefield:getID())
    end

    local _, clearTime, partySize = battlefield:getRecord()
    local canSkipCS = (current ~= self.mission) and 1 or 0
    player:startEvent(32001, battlefield:getArea(), clearTime, partySize, battlefield:getTimeInside(), 1, self.menuBit, canSkipCS)
end

function BattlefieldMission:onEventFinishWin(player, csid, option)
    if self.title then
        player:addTitle(self.title)
    end

    -- Only grant mission XP once per JP midnight
    local varKey = "MN_XP_" .. self.id
    if self.grantXP and player:getCharVar(varKey) <= os.time() then
        player:setCharVar(varKey, getMidnight())
        player:addExp(self.grantXP)
    end
end

function xi.battlefield.onBattlefieldTick(battlefield, timeinside)
    local killedallmobs = true
    local leavecode     = -1
    local canLeave      = false

    local mobs          = battlefield:getMobs(true, false)
    local status        = battlefield:getStatus()
    local players       = battlefield:getPlayers()
    local cutsceneTimer = battlefield:getLocalVar("cutsceneTimer")
    local phaseChange   = battlefield:getLocalVar("phaseChange")

    if status == xi.battlefield.status.LOST then
        leavecode = 4
    elseif status == xi.battlefield.status.WON then
        leavecode = 2
    end

    if leavecode ~= -1 then
        -- Artificially inflate the time we remain inside the battlefield.
        battlefield:setLocalVar("cutsceneTimer", cutsceneTimer + 1)

        canLeave = battlefield:getLocalVar("loot") == 0

        if status == xi.battlefield.status.WON and not canLeave then
            if battlefield:getLocalVar("lootSpawned") == 0 and battlefield:spawnLoot() then
                canLeave = false
            elseif battlefield:getLocalVar("lootSeen") == 1 then
                canLeave = true
            end
        end
    end

    -- Remove battlefield effect for players in alliance not inside battlefield once the battlefield gets locked. Do this only once.
    if status == xi.battlefield.status.LOCKED and battlefield:getLocalVar("statusRemoval") == 0 then
        battlefield:setLocalVar("statusRemoval", 1)

        for _, player in pairs(players) do
            local alliance = player:getAlliance()
            for _, member in pairs(alliance) do
                if member:hasStatusEffect(xi.effect.BATTLEFIELD) and not member:getBattlefield() then
                    member:delStatusEffect(xi.effect.BATTLEFIELD)
                end
            end
        end
    end

    -- Check that players haven't all died or that their dead time is over.
    xi.battlefield.HandleWipe(battlefield, players)

    -- Cleanup battlefield.
    if
        not xi.battlefield.SendTimePrompts(battlefield, players) or -- If we cant send anymore time prompts, they are out of time.
        (canLeave and cutsceneTimer >= 15)                          -- Players won and artificial time inflation is over.
    then
        battlefield:cleanup(true)
    elseif status == xi.battlefield.status.LOST then -- Players lost.
        for _, player in pairs(players) do
            player:messageSpecial(zones[player:getZoneID()].text.PARTY_MEMBERS_HAVE_FALLEN)
        end

        battlefield:cleanup(true)
    end

    -- Check if theres at least 1 mob alive.
    for _, mob in pairs(mobs) do
        if mob:isAlive() then
            killedallmobs = false
            break
        end
    end

    -- Set win status.
    if killedallmobs and phaseChange == 0 then
        battlefield:setStatus(xi.battlefield.status.WON)
    end
end

-- returns false if out of time
function xi.battlefield.SendTimePrompts(battlefield, players)
    -- local tick = battlefield:getTimeInside()
    -- local status = battlefield:getStatus()
    local remainingTime  = battlefield:getRemainingTime()
    local message        = 0
    local lastTimeUpdate = battlefield:getLastTimeUpdate()

    players = players or battlefield:getPlayers()

    if lastTimeUpdate == 0 and remainingTime < 600 then
        message = 600
    elseif lastTimeUpdate == 600 and remainingTime < 300 then
        message = 300
    elseif lastTimeUpdate == 300 and remainingTime < 60 then
        message = 60
    elseif lastTimeUpdate == 60 and remainingTime < 30 then
        message = 30
    elseif lastTimeUpdate == 30 and remainingTime < 10 then
        message = 10
    end

    if message ~= 0 then
        for i, player in pairs(players) do
            player:messageBasic(xi.msg.basic.TIME_LEFT, remainingTime)
        end

        battlefield:setLastTimeUpdate(message)
    end

    return remainingTime >= 0
end

function xi.battlefield.HandleWipe(battlefield, players)
    local rekt     = true
    local wipeTime = battlefield:getWipeTime()
    local elapsed  = battlefield:getTimeInside()

    players = players or battlefield:getPlayers()

    -- If party has not yet wiped.
    if wipeTime <= 0 then
        -- Check if party has wiped.
        for _, player in pairs(players) do
            if player:getHP() ~= 0 then
                rekt = false
                break
            end
        end

        -- Party has wiped. Save and send time remaining before being booted.
        -- TODO: Add LUA Binding to check for BCNM flag - RULES_REMOVE_3MIN = 0x04,
        if rekt then
            if battlefield:getLocalVar("instantKick") == 0 then
                for _, player in pairs(players) do
                    player:messageSpecial(zones[player:getZoneID()].text.THE_PARTY_WILL_BE_REMOVED, 0, 0, 0, 3)
                end

                battlefield:setWipeTime(elapsed)
            else
                battlefield:setStatus(xi.battlefield.status.LOST)
            end
        end

    -- Party has already wiped.
    else
        -- Time is over.
        if (elapsed - wipeTime) > 180 then -- It will take aproximately 20 extra seconds to actually get kicked, but we have already lost.
            battlefield:setStatus(xi.battlefield.status.LOST)

        -- Check for comeback.
        else
            for _, player in pairs(players) do
                if player:getHP() ~= 0 then
                    battlefield:setWipeTime(0)
                    rekt = false
                    break
                end
            end
        end
    end
end

function xi.battlefield.HandleLootRolls(battlefield, lootTable, players, npc)
    players = players or battlefield:getPlayers()
    if battlefield:getStatus() == xi.battlefield.status.WON and battlefield:getLocalVar("lootSeen") == 0 then
        if npc then
            npc:setAnimation(90)
        end

        for i = 1, #lootTable, 1 do
            local lootGroup = lootTable[i]

            if lootGroup then
                local max = 0

                for _, entry in pairs(lootGroup) do
                    max = max + entry.droprate
                end

                local roll = math.random(max)

                for _, entry in pairs(lootGroup) do
                    max = max - entry.droprate

                    if roll > max then
                        if entry.itemid ~= 0 then
                            if entry.itemid == 65535 then
                                local gil = entry.amount/#players

                                for j = 1, #players, 1 do
                                    players[j]:addGil(gil)
                                    players[j]:messageSpecial(zones[players[1]:getZoneID()].text.GIL_OBTAINED, gil)
                                end

                                break
                            end

                            players[1]:addTreasure(entry.itemid, npc)
                        end

                        break
                    end
                end
            end
        end

        battlefield:setLocalVar("cutsceneTimer", 10)
        battlefield:setLocalVar("lootSeen", 1)
    end
end

-- TODO(jmcmorris): This is no longer needed once Limbus uses the new Battlefield system
function xi.battlefield.HealPlayers(battlefield, players)
    players = players or battlefield:getPlayers()
    for _, player in pairs(players) do
        local recoverHP = player:getMaxHP() - player:getHP()
        local recoverMP = player:getMaxMP() - player:getMP()
        player:addHP(recoverHP)
        player:addMP(recoverMP)
        player:resetRecasts()
        player:messageBasic(xi.msg.basic.RECOVERS_HP_AND_MP, recoverHP, recoverMP)
        player:messageBasic(xi.msg.basic.ALL_ABILITIES_RECHARGED)
    end
end
