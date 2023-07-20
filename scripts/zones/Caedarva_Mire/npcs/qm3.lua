-----------------------------------
-- Area: Caedarva Mire
--  NPC: ??? (Spawn Mahjlaef the Paintorn(ZNM T3))
-- !pos 695 -7 527 79
-----------------------------------
local ID = require("scripts/zones/Caedarva_Mire/IDs")
require("scripts/globals/npc_util")
-----------------------------------
local entity = {}

entity.onTrade = function(player, npc, trade)
    if
        npcUtil.tradeHas(trade, xi.items.BOUND_EXORCISM_TREATISE) and
        npcUtil.popFromQM(player, npc, ID.mob.MAHJLAEF_THE_PAINTORN)
    then
        player:confirmTrade()
        player:messageSpecial(ID.text.DRAWS_NEAR)
    end
end

entity.onTrigger = function(player, npc)
    player:messageSpecial(ID.text.SHREDDED_SCRAPS)
end

entity.onEventUpdate = function(player, csid, option)
end

entity.onEventFinish = function(player, csid, option)
end

return entity
