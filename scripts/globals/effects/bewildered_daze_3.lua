----------------------------------------
-- tpz.effect.BEWILDERED_DAZE_3
----------------------------------------
require("scripts/globals/status")
-----------------------------------
local effect_object = {}

function onEffectGain(target, effect)
    target:addMod(tpz.mod.CEVA, -9)
end

function onEffectTick(target, effect)
end

function onEffectLose(target, effect)
    target:delMod(tpz.mod.CEVA, -9)
end

return effect_object
