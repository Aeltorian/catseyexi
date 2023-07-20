-----------------------------------
-- Area: Misareaux_Coast
--  NPC: ??? (Spawn Gration)
-- !pos 113.563 -16.302 38.912 25
-----------------------------------
local ID = require("scripts/zones/Misareaux_Coast/IDs")
require("scripts/globals/npc_util")
-----------------------------------
local entity = {}

entity.onTrade = function(player, npc, trade)
    if
        (npcUtil.tradeHas(trade, xi.items.PICAROONS_SHIELD) or npcUtil.tradeHas(trade, xi.items.HICKORY_SHIELD)) and
        npcUtil.popFromQM(player, npc, ID.mob.GRATION)
    then
        player:confirmTrade()
    end
end

entity.onTrigger = function(player, npc)
    player:messageSpecial(ID.text.NOTHING_OUT_OF_ORDINARY)
end

entity.onEventUpdate = function(player, csid, option)
end

entity.onEventFinish = function(player, csid, option)
end

return entity
