-----------------------------------
-- Area: Buburimu Peninsula
--  NPC: Craigine, R.K.
-- Border Conquest Guards
-- !pos -599.903 -41.441 165.776 118
-----------------------------------
require("scripts/globals/conquest")
-----------------------------------
local entity = {}

local guardNation = xi.nation.SANDORIA
local guardType   = xi.conq.guard.BORDER
local guardRegion = xi.region.KOLSHUSHU
local guardEvent  = 32762

entity.onTrade = function(player, npc, trade)
    xi.conq.overseerOnTrade(player, npc, trade, guardNation, guardType)
end

entity.onTrigger = function(player, npc)
    xi.conq.overseerOnTrigger(player, npc, guardNation, guardType, guardEvent, guardRegion)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.conq.overseerOnEventUpdate(player, csid, option, guardNation)
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.conq.overseerOnEventFinish(player, csid, option, guardNation, guardType, guardRegion)
end

return entity
