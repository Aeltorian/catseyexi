-----------------------------------
--  Javelin Throw
--
--  Description: Ranged attack with the equipped weapon, which is lost.
--  Type: Ranged
--  Utsusemi/Blink absorb: 1 shadow
--  Range: 7.0
--  Notes: Only used by armed DRG Mamool Ja
-----------------------------------
require("scripts/settings/main")
require("scripts/globals/monstertpmoves")
require("scripts/globals/status")
-----------------------------------
local mobskill_object = {}

mobskill_object.onMobSkillCheck = function(target, mob, skill)
    if mob:getAnimationSub() == 0 and mob:getMainJob() == xi.job.DRG then
        return 0
    end
    return 1
end

mobskill_object.onMobWeaponSkill = function(target, mob, skill)
    mob:AnimationSub(1)
    local numhits = 1
    local accmod = 1
    local dmgmod = 3
    local info = MobRangedMove(mob, target, skill, numhits, accmod, dmgmod, TP_NO_EFFECT)
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, xi.attackType.RANGED, xi.damageType.PIERCING, info.hitslanded)
    target:takeDamage(dmg, mob, xi.attackType.RANGED, xi.damageType.PIERCING)
    return dmg
end

return mobskill_object
