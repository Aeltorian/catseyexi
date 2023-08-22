-----------------------------------
-- Magnetite Cloud
-- Deals earth damage to enemies within a fan-shaped area originating from the caster. Additional effect: Weight.
-----------------------------------
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local typeEffect = xi.effect.WEIGHT
    xi.mobskills.mobStatusEffectMove(mob, target, typeEffect, 50, 0, 120)

    local dmgmod = xi.mobskills.mobBreathMove(mob, target, 0.167, 1.875, xi.element.EARTH, 509)

    local dmg = xi.mobskills.mobFinalAdjustments(dmgmod, mob, skill, target, xi.attackType.BREATH, xi.damageType.EARTH, xi.mobskills.shadowBehavior.WIPE_SHADOWS)
    target:takeDamage(dmg, mob, xi.attackType.BREATH, xi.damageType.EARTH)
    return dmg
end

return mobskillObject
