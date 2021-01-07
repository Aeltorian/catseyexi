----------------------------------------
-- tpz.effect.MANAWELL
----------------------------------------
require("scripts/globals/status")
-----------------------------------
local effect_object = {}

function onEffectGain(target, effect)
    target:addMod(tpz.mod.NO_SPELL_MP_DEPLETION, 100)
end

function onEffectTick(target, effect)
end

function onEffectLose(target, effect)
    target:delMod(tpz.mod.NO_SPELL_MP_DEPLETION, 100)
end

return effect_object
