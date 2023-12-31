-----------------------------------
-- ID: 10851
-- Slime Belt
-- Enchantment: 60Min, Costume - Slime
-----------------------------------
local itemObject = {}

itemObject.onItemCheck = function(target)
    if not target:canUseMisc(xi.zoneMisc.COSTUME) then
        return xi.msg.basic.CANT_BE_USED_IN_AREA
    end

    return 0
end

itemObject.onItemUse = function(target)
    target:addStatusEffect(xi.effect.COSTUME, 292, 0, 3600)
end

return itemObject
