-----------------------------------
-- Area: Leafallia (281)
--  NPC: Heroic Footprints
-- !pos -44.972,-0.974,23.990
-----------------------------------
require("scripts/settings/main")
require("scripts/globals/titles")
require("scripts/globals/keyitems")
require("scripts/globals/shop")
require("scripts/globals/quests")
require("scripts/globals/status")
require("scripts/globals/ability")
require("scripts/globals/msg")
local ID = require("scripts/zones/Leafallia/IDs")
-----------------------------------
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    player:setPos(-31.850, -0.000, -32.803, 150, 245)
end

entity.onEventUpdate = function(player, csid, option)
end

entity.onEventFinish = function(player, csid, option)
end

return entity
