-----------------------------------
-- Area: Port Bastok
--  NPC: Kachada
-----------------------------------
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    player:startEvent(96)--, 0, 0, 0, 0, 0, -1, 2)
end

entity.onEventUpdate = function(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
