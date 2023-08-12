-----------------------------------
-- Area: Silver_Sea_route_to_Nashmau
--  NPC: Qudamahf
-- Notes: Tells ship ETA time
-- !pos 0.340 -12.232 -4.120 58
-----------------------------------
local ID = require("scripts/zones/Silver_Sea_route_to_Nashmau/IDs")
require("scripts/globals/transport")
-----------------------------------
local entity = {}

local messages =
{
    [xi.transport.message.NEARING] = ID.text.NEARING_NASHMAU,
    [xi.transport.message.DOCKING] = ID.text.DOCKING_IN_NASHMAU
}

entity.onSpawn = function(npc)
    npc:addPeriodicTrigger(xi.transport.message.NEARING, xi.transport.messageTime.SILVER_SEA, xi.transport.epochOffset.NEARING)
    npc:addPeriodicTrigger(xi.transport.message.DOCKING, xi.transport.messageTime.SILVER_SEA, xi.transport.epochOffset.DOCKING)
end

entity.onTimeTrigger = function(npc, triggerID)
    xi.transport.captainMessage(npc, triggerID, messages)
end

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    player:messageSpecial(ID.text.ON_WAY_TO_NASHMAU, 0, 0) -- Earth Time, Vana Hours. Needs a get-time function for boat?
end

entity.onEventUpdate = function(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
