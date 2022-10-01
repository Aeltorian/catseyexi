-----------------------------------
-- Area: Meriphataud Mountains
--  Mob: Boggart
-----------------------------------
require("scripts/globals/regimes")
-----------------------------------
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.regime.checkRegime(player, mob, 63, 2, xi.regime.type.FIELDS)
end

return entity
