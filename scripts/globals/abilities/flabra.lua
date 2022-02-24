-----------------------------------
-- Ability: Flabra
-- Increases resistance against earth and deals wind damage.
-- Obtained: Rune Fencer Level 5
-- Recast Time: 0:10
-- Duration: 5:00
-----------------------------------
require("scripts/settings/main")
require("scripts/globals/status")
require("scripts/globals/abilities/rune_enchantment")
-----------------------------------
local ability_object = {}

ability_object.onAbilityCheck = function(player, target, ability)
	return 0, 0
end

ability_object.onUseAbility = function(caster, target, ability, action)
    local effect = xi.effect.FLABRA
    enforceRuneCounts(target)
    applyRuneEnhancement(effect, target)
end

return ability_object
