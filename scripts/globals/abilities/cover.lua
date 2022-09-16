-----------------------------------
-- Ability: Cover
-- Allows you to protect party members by placing yourself between them and the enemy.
-- Obtained: Paladin Level 35
-- Recast Time: 0:03:00
-- Duration: 0:00:15 - 0:00:35
-- Info from https://www.bg-wiki.com/bg/Cover
-----------------------------------
require("scripts/globals/job_utils/paladin")
-----------------------------------
local ability_object = {}

ability_object.onAbilityCheck = function(player, target, ability)
    return xi.job_utils.paladin.checkCover(player, target, ability)
end

ability_object.onUseAbility = function(player, target, ability)
    xi.job_utils.paladin.useCover(player, target, ability)
end

return ability_object
