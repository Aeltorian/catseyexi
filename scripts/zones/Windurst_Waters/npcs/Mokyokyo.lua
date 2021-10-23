-----------------------------------
-- Area: Windurst Waters
--  NPC: Mokyoko
-- Starts Windurst Missions
-- !pos -55 -8 227 238
-----------------------------------
local ID = require("scripts/zones/Windurst_Waters/IDs")
require("scripts/settings/main")
require("scripts/globals/titles")
require("scripts/globals/keyitems")
require("scripts/globals/missions")
-----------------------------------
local entity = {}

entity.onTrigger = function(player, npc)
    if player:getNation() ~= xi.nation.WINDURST then
        player:startEvent(103) -- for other nation
    else
        local currentMission = player:getCurrentMission(WINDURST)

        if currentMission ~= xi.mission.id.windurst.NONE then
            player:startEvent(109)
        elseif player:hasKeyItem(xi.ki.MESSAGE_TO_JEUNO_WINDURST) then
            player:startEvent(232)
        elseif (player:hasCompletedMission(xi.mission.log_id.WINDURST, xi.mission.id.windurst.MOON_READING) == true) then
            player:startEvent(837)
        else
            -- NPC dialog changes when starting 3-2 according to whether it's the first time or being repeated
            local param3 = player:hasCompletedMission(xi.mission.log_id.WINDURST, xi.mission.id.windurst.WRITTEN_IN_THE_STARS) and 1 or 0
            local flagMission, repeatMission = getMissionMask(player)

            player:startEvent(111, flagMission, 0, param3, 0, xi.ki.STAR_CRESTED_SUMMONS_1, repeatMission)
        end
    end
end

entity.onEventUpdate = function(player, csid, option)
end

entity.onEventFinish = function(player, csid, option)
    if csid ~= 118 or csid ~= 130 or csid ~= 135 then
        finishMissionTimeline(player, 2, csid, option)
    end
    if csid == 111 and (option == 12 or option == 15) then
        player:addKeyItem(xi.ki.STAR_CRESTED_SUMMONS_1)
        player:messageSpecial(ID.text.KEYITEM_OBTAINED, xi.ki.STAR_CRESTED_SUMMONS_1)
    end
    if csid == 837 then
        player:setCharVar("WWatersRTenText", 1)
    end
end

return entity
