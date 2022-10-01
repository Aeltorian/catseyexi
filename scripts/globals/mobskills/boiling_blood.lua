-----------------------------------
-- Boiling Blood
-- Description: Boiling Blood
-- Foe gains Haste +25% and Berserk +50%
-- TODO: Verify ability duration
-- https://www.bg-wiki.com/ffxi/Locus_Wivre
-----------------------------------
require("scripts/globals/mobskills")
require("scripts/globals/settings")
require("scripts/globals/status")
-----------------------------------
local mobskill_object = {}

mobskill_object.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskill_object.onMobWeaponSkill = function(target, mob, skill)
    xi.mobskills.mobBuffMove(mob, xi.effect.HASTE, 2500, 0, 60)
    xi.mobskills.mobBuffMove(mob, xi.effect.BERSERK, 5000, 0, 60)
    skill:setMsg(xi.msg.basic.NONE)
    return 0
end

return mobskill_object
