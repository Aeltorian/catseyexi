-----------------------------------
-- Area: Castle Oztroja
--  NPC: _47i (Handle)
-- Note: Opens door _471
-- !pos -182 -15 -19 151
-----------------------------------
local oztrojaGlobal = require("scripts/zones/Castle_Oztroja/globals")
-----------------------------------
local entity = {}

entity.onTrigger = function(player, npc)
    oztrojaGlobal.handleOnTrigger(npc)
end

entity.onEventUpdate = function(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
