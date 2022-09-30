-----------------------------------
-- Area: Dynamis-Tavnazia
--  Mob: Diabolos Club
-- Note: Mega Boss
-----------------------------------
require("scripts/globals/dynamis")
-----------------------------------
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.dynamis.megaBossOnDeath(mob, player, isKiller)
    player:addTitle(xi.title.NIGHTMARE_AWAKENER)
end

return entity
