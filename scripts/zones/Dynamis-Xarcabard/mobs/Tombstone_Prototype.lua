-----------------------------------
-- Area: Dynamis - Xarcabard
--  Mob: Tombstone Prototype
-----------------------------------
require("scripts/globals/dynamis")
-----------------------------------
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.dynamis.timeExtensionOnDeath(mob, player, isKiller)
end

return entity
