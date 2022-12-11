-----------------------------------
-- xi.effect.CAPRICCIO
-----------------------------------
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    target:addMod(xi.mod.PETRIFY_MEVA, effect:getPower())
    target:addMod(xi.mod.AGI, effect:getSubPower()) -- Apply Stat Buff from AUGMENT_SONG_STAT
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    target:delMod(xi.mod.PETRIFY_MEVA, effect:getPower())
    target:delMod(xi.mod.AGI, effect:getSubPower()) -- Remove Stat Buff from AUGMENT_SONG_STAT
end

return effectObject
