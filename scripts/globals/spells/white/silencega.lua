-----------------------------------
-- Spell: Silencega
-----------------------------------
require("scripts/globals/spells/enfeebling_spell")
-----------------------------------
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.spells.enfeebling.useEnfeeblingSpell(caster, target, spell)
end

return spellObject
