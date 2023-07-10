-----------------------------------
-- Enfeebling Spell Utilities
-- Used for spells that deal negative status effects upon targets.
-----------------------------------
require("scripts/globals/combat/element_tables")
require("scripts/globals/combat/magic_hit_rate")
require("scripts/globals/jobpoints")
require("scripts/globals/magicburst")
require("scripts/globals/msg")
require("scripts/globals/spell_data")
require("scripts/globals/utils")
-----------------------------------
xi = xi or {}
xi.spells = xi.spells or {}
xi.spells.enfeebling = xi.spells.enfeebling or {}
-----------------------------------
local pTable =
{   --                                 1                             2           3                   4                    5      6    7         8       9    10        11         12
    --                 [Spell ID ] = { Effect,                       Stat-Used,  Resist-Mod,         MEVA-Mod,            pBase, DoT, Duration, Resist, msg, immunity, pSaboteur, mAcc },
    -- Black Magic
    [xi.magic.spell.BIND         ] = { xi.effect.BIND,               xi.mod.INT, xi.mod.BINDRES,     xi.mod.BIND_MEVA,        0,   0,       60,      2,   0,        4, false,       0 },
    [xi.magic.spell.BINDGA       ] = { xi.effect.BIND,               xi.mod.INT, xi.mod.BINDRES,     xi.mod.BIND_MEVA,        0,   0,       60,      2,   0,        4, false,       0 },
    [xi.magic.spell.BLIND        ] = { xi.effect.BLINDNESS,          xi.mod.INT, xi.mod.BLINDRES,    xi.mod.BLIND_MEVA,       0,   0,      180,      2,   0,       64, true,        0 },
    [xi.magic.spell.BLIND_II     ] = { xi.effect.BLINDNESS,          xi.mod.INT, xi.mod.BLINDRES,    xi.mod.BLIND_MEVA,       0,   0,      180,      2,   0,       64, true,        0 },
    [xi.magic.spell.BLINDGA      ] = { xi.effect.BLINDNESS,          xi.mod.INT, xi.mod.BLINDRES,    xi.mod.BLIND_MEVA,       0,   0,      180,      2,   0,       64, true,        0 },
    [xi.magic.spell.BREAK        ] = { xi.effect.PETRIFICATION,      xi.mod.INT, xi.mod.PETRIFYRES,  xi.mod.PETRIFY_MEVA,     1,   0,       30,      2,   0,        0, false,       0 },
    [xi.magic.spell.BREAKGA      ] = { xi.effect.PETRIFICATION,      xi.mod.INT, xi.mod.PETRIFYRES,  xi.mod.PETRIFY_MEVA,     1,   0,       30,      2,   0,        0, false,       0 },
    [xi.magic.spell.BURN         ] = { xi.effect.BURN,               xi.mod.INT, 0,                  0,                       0,   3,       90,      3,   1,        0, true,        0 },
    [xi.magic.spell.CHOKE        ] = { xi.effect.CHOKE,              xi.mod.INT, 0,                  0,                       0,   3,       90,      3,   1,        0, true,        0 },
    [xi.magic.spell.CURSE        ] = { xi.effect.CURSE_I,            xi.mod.INT, xi.mod.CURSERES,    xi.mod.CURSE_MEVA,      50,   0,      300,      2,   0,        0, false,       0 },
    [xi.magic.spell.DISPEL       ] = { xi.effect.NONE,               xi.mod.INT, 0,                  0,                       0,   0,        0,      4,   0,        0, false,     175 },
    [xi.magic.spell.DISPELGA     ] = { xi.effect.NONE,               xi.mod.INT, 0,                  0,                       0,   0,        0,      4,   0,        0, false,       0 },
    [xi.magic.spell.DISTRACT     ] = { xi.effect.EVASION_DOWN,       xi.mod.MND, 0,                  0,                       0,   0,      120,      2,   0,        0, true,      150 },
    [xi.magic.spell.DISTRACT_II  ] = { xi.effect.EVASION_DOWN,       xi.mod.MND, 0,                  0,                       0,   0,      120,      2,   0,        0, true,      150 },
    [xi.magic.spell.DISTRACT_III ] = { xi.effect.EVASION_DOWN,       xi.mod.MND, 0,                  0,                       0,   0,      120,      2,   0,        0, true,      150 },
    [xi.magic.spell.DROWN        ] = { xi.effect.DROWN,              xi.mod.INT, 0,                  0,                       0,   3,       90,      3,   1,        0, true,        0 },
    [xi.magic.spell.FRAZZLE      ] = { xi.effect.MAGIC_EVASION_DOWN, xi.mod.MND, 0,                  0,                       0,   0,      120,      2,   0,        0, true,      150 },
    [xi.magic.spell.FRAZZLE_II   ] = { xi.effect.MAGIC_EVASION_DOWN, xi.mod.MND, 0,                  0,                       0,   0,      120,      2,   0,        0, true,      150 },
    [xi.magic.spell.FRAZZLE_III  ] = { xi.effect.MAGIC_EVASION_DOWN, xi.mod.MND, 0,                  0,                       0,   0,      120,      2,   0,        0, true,      150 },
    [xi.magic.spell.FROST        ] = { xi.effect.FROST,              xi.mod.INT, 0,                  0,                       0,   3,       90,      3,   1,        0, true,        0 },
    [xi.magic.spell.GRAVITY      ] = { xi.effect.WEIGHT,             xi.mod.INT, xi.mod.GRAVITYRES,  xi.mod.GRAVITY_MEVA,    26,   0,      120,      2,   0,        2, true,        0 },
    [xi.magic.spell.GRAVITY_II   ] = { xi.effect.WEIGHT,             xi.mod.INT, xi.mod.GRAVITYRES,  xi.mod.GRAVITY_MEVA,    32,   0,      180,      2,   0,        2, true,        0 },
    [xi.magic.spell.GRAVIGA      ] = { xi.effect.WEIGHT,             xi.mod.INT, xi.mod.GRAVITYRES,  xi.mod.GRAVITY_MEVA,    50,   0,      120,      2,   0,        2, true,        0 },
    [xi.magic.spell.POISON       ] = { xi.effect.POISON,             xi.mod.INT, xi.mod.POISONRES,   xi.mod.POISON_MEVA,      0,   3,       90,      2,   0,      256, true,        0 },
    [xi.magic.spell.POISON_II    ] = { xi.effect.POISON,             xi.mod.INT, xi.mod.POISONRES,   xi.mod.POISON_MEVA,      0,   3,      120,      2,   0,      256, true,       30 },
    [xi.magic.spell.POISON_III   ] = { xi.effect.POISON,             xi.mod.INT, xi.mod.POISONRES,   xi.mod.POISON_MEVA,      0,   3,      150,      2,   0,      256, true,        0 },
    [xi.magic.spell.POISONGA     ] = { xi.effect.POISON,             xi.mod.INT, xi.mod.POISONRES,   xi.mod.POISON_MEVA,      0,   3,       90,      2,   0,      256, true,        0 },
    [xi.magic.spell.POISONGA_II  ] = { xi.effect.POISON,             xi.mod.INT, xi.mod.POISONRES,   xi.mod.POISON_MEVA,      0,   3,      120,      2,   0,      256, true,        0 },
    [xi.magic.spell.POISONGA_III ] = { xi.effect.POISON,             xi.mod.INT, xi.mod.POISONRES,   xi.mod.POISON_MEVA,      0,   3,      150,      2,   0,      256, true,        0 },
    [xi.magic.spell.RASP         ] = { xi.effect.RASP,               xi.mod.INT, 0,                  0,                       0,   3,       90,      3,   1,        0, true,        0 },
    [xi.magic.spell.SHOCK        ] = { xi.effect.SHOCK,              xi.mod.INT, 0,                  0,                       0,   3,       90,      3,   1,        0, true,        0 },
    [xi.magic.spell.SLEEP        ] = { xi.effect.SLEEP_I,            xi.mod.INT, xi.mod.SLEEPRES,    xi.mod.SLEEP_MEVA,       1,   0,       60,      2,   0,        1, false,       0 },
    [xi.magic.spell.SLEEP_II     ] = { xi.effect.SLEEP_I,            xi.mod.INT, xi.mod.SLEEPRES,    xi.mod.SLEEP_MEVA,       2,   0,       90,      2,   0,        1, false,       0 },
    [xi.magic.spell.SLEEPGA      ] = { xi.effect.SLEEP_I,            xi.mod.INT, xi.mod.SLEEPRES,    xi.mod.SLEEP_MEVA,       1,   0,       60,      2,   0,        1, false,       0 },
    [xi.magic.spell.SLEEPGA_II   ] = { xi.effect.SLEEP_I,            xi.mod.INT, xi.mod.SLEEPRES,    xi.mod.SLEEP_MEVA,       2,   0,       90,      2,   0,        1, false,       0 },
    [xi.magic.spell.STUN         ] = { xi.effect.STUN,               xi.mod.INT, xi.mod.STUNRES,     xi.mod.STUN_MEVA,        1,   0,        5,      4,   0,        8, false,     200 },
    [xi.magic.spell.VIRUS        ] = { xi.effect.PLAGUE,             xi.mod.INT, xi.mod.VIRUSRES,    xi.mod.VIRUS_MEVA,       5,   3,       60,      2,   0,        0, false,       0 },

    -- White Magic
    [xi.magic.spell.FLASH        ] = { xi.effect.FLASH,              xi.mod.MND, xi.mod.BLINDRES,    xi.mod.BLIND_MEVA,     300,   0,       12,      4,   0,        0, true,      200 },
    [xi.magic.spell.INUNDATION   ] = { xi.effect.INUNDATION,         xi.mod.MND, 0,                  0,                       1,   0,      300,      5,   0,        0, false,       0 },
    [xi.magic.spell.PARALYZE     ] = { xi.effect.PARALYSIS,          xi.mod.MND, xi.mod.PARALYZERES, xi.mod.PARALYZE_MEVA,    0,   0,      120,      2,   0,       32, true,      -10 },
    [xi.magic.spell.PARALYZE_II  ] = { xi.effect.PARALYSIS,          xi.mod.MND, xi.mod.PARALYZERES, xi.mod.PARALYZE_MEVA,    0,   0,      120,      2,   0,       32, true,        0 },
    [xi.magic.spell.PARALYGA     ] = { xi.effect.PARALYSIS,          xi.mod.MND, xi.mod.PARALYZERES, xi.mod.PARALYZE_MEVA,    0,   0,      120,      2,   0,       32, true,        0 },
    [xi.magic.spell.REPOSE       ] = { xi.effect.SLEEP_II,           xi.mod.MND, xi.mod.SLEEPRES,    xi.mod.SLEEP_MEVA,       2,   0,       90,      2,   1,        1, false,       0 },
    [xi.magic.spell.SILENCE      ] = { xi.effect.SILENCE,            xi.mod.MND, xi.mod.SILENCERES,  xi.mod.SILENCE_MEVA,     1,   0,      120,      2,   0,       16, false,       0 },
    [xi.magic.spell.SILENCEGA    ] = { xi.effect.SILENCE,            xi.mod.MND, xi.mod.SILENCERES,  xi.mod.SILENCE_MEVA,     1,   0,      120,      2,   0,       16, false,       0 },
    [xi.magic.spell.SLOW         ] = { xi.effect.SLOW,               xi.mod.MND, xi.mod.SLOWRES,     xi.mod.SLOW_MEVA,        0,   0,      180,      2,   0,      128, true,       10 },
    [xi.magic.spell.SLOW_II      ] = { xi.effect.SLOW,               xi.mod.MND, xi.mod.SLOWRES,     xi.mod.SLOW_MEVA,        0,   0,      180,      2,   0,      128, true,       10 },
    [xi.magic.spell.SLOWGA       ] = { xi.effect.SLOW,               xi.mod.MND, xi.mod.SLOWRES,     xi.mod.SLOW_MEVA,        0,   0,      180,      2,   0,      128, true,        0 },

    -- Ninjutsu
    [xi.magic.spell.AISHA_ICHI   ] = { xi.effect.ATTACK_DOWN,        xi.mod.INT, 0,                  0,                      15,   0,      120,      4,   1,        0, false,       0 },
    [xi.magic.spell.DOKUMORI_ICHI] = { xi.effect.POISON,             xi.mod.INT, xi.mod.POISONRES,   xi.mod.POISON_MEVA,      3,   3,       60,      2,   0,      256, false,       0 },
    [xi.magic.spell.DOKUMORI_NI  ] = { xi.effect.POISON,             xi.mod.INT, xi.mod.POISONRES,   xi.mod.POISON_MEVA,     10,   3,      120,      2,   0,      256, false,       0 },
    [xi.magic.spell.DOKUMORI_SAN ] = { xi.effect.POISON,             xi.mod.INT, xi.mod.POISONRES,   xi.mod.POISON_MEVA,     20,   3,      360,      2,   0,      256, false,       0 },
    [xi.magic.spell.HOJO_ICHI    ] = { xi.effect.SLOW,               xi.mod.INT, xi.mod.SLOWRES,     xi.mod.SLOW_MEVA,     1465,   0,      180,      2,   0,      128, false,       0 },
    [xi.magic.spell.HOJO_NI      ] = { xi.effect.SLOW,               xi.mod.INT, xi.mod.SLOWRES,     xi.mod.SLOW_MEVA,     1953,   0,      300,      2,   0,      128, false,       0 },
    [xi.magic.spell.HOJO_SAN     ] = { xi.effect.SLOW,               xi.mod.INT, xi.mod.SLOWRES,     xi.mod.SLOW_MEVA,     2930,   0,      420,      2,   0,      128, false,       0 },
    [xi.magic.spell.JUBAKU_ICHI  ] = { xi.effect.PARALYSIS,          xi.mod.INT, xi.mod.PARALYZERES, xi.mod.PARALYZE_MEVA,   20,   0,      180,      2,   1,       32, false,       0 },
    [xi.magic.spell.JUBAKU_NI    ] = { xi.effect.PARALYSIS,          xi.mod.INT, xi.mod.PARALYZERES, xi.mod.PARALYZE_MEVA,   30,   0,      300,      2,   1,       32, false,       0 },
    [xi.magic.spell.JUBAKU_SAN   ] = { xi.effect.PARALYSIS,          xi.mod.INT, xi.mod.PARALYZERES, xi.mod.PARALYZE_MEVA,   35,   0,      420,      2,   1,       32, false,       0 },
    [xi.magic.spell.KURAYAMI_ICHI] = { xi.effect.BLINDNESS,          xi.mod.INT, xi.mod.BLINDRES,    xi.mod.BLIND_MEVA,      20,   0,      180,      2,   0,       64, false,       0 },
    [xi.magic.spell.KURAYAMI_NI  ] = { xi.effect.BLINDNESS,          xi.mod.INT, xi.mod.BLINDRES,    xi.mod.BLIND_MEVA,      30,   0,      300,      2,   0,       64, false,       0 },
    [xi.magic.spell.KURAYAMI_SAN ] = { xi.effect.BLINDNESS,          xi.mod.INT, xi.mod.BLINDRES,    xi.mod.BLIND_MEVA,      40,   0,      420,      2,   0,       64, false,       0 },
    [xi.magic.spell.YURIN_ICHI   ] = { xi.effect.INHIBIT_TP,         xi.mod.INT, 0,                  0,                      10,   0,      180,      3,   1,        0, false,       0 },
}

local immunobreakTable =
{
    [xi.effect.SLEEP_I      ] = { xi.mod.SLEEP_IMMUNOBREAK    },
    [xi.effect.POISON       ] = { xi.mod.POISON_IMMUNOBREAK   },
    [xi.effect.PARALYSIS    ] = { xi.mod.PARALYZE_IMMUNOBREAK },
    [xi.effect.BLINDNESS    ] = { xi.mod.BLIND_IMMUNOBREAK    },
    [xi.effect.SILENCE      ] = { xi.mod.SILENCE_IMMUNOBREAK  },
    [xi.effect.PETRIFICATION] = { xi.mod.PETRIFY_IMMUNOBREAK  },
    [xi.effect.BIND         ] = { xi.mod.BIND_IMMUNOBREAK     },
    [xi.effect.WEIGHT       ] = { xi.mod.GRAVITY_IMMUNOBREAK  },
    [xi.effect.SLOW         ] = { xi.mod.SLOW_IMMUNOBREAK     },
    [xi.effect.ADDLE        ] = { xi.mod.ADDLE_IMMUNOBREAK    },
}

local function getElementalDebuffPotency(caster, statUsed)
    local potency    = 1
    local casterStat = caster:getStat(statUsed)

    if casterStat > 150 then
        potency = potency + 4
    elseif casterStat > 100 then
        potency = potency + 3
    elseif casterStat > 70 then
        potency = potency + 2
    elseif casterStat > 40 then
        potency = potency + 1
    end

    potency = potency + caster:getMerit(xi.merit.ELEMENTAL_DEBUFF_EFFECT) -- TODO: Add BLM Toban gear effect (potency) here.

    return potency
end

-- Calculate potency before resist.
xi.spells.enfeebling.calculatePotency = function(caster, target, spellId, spellEffect, skillType, statUsed)
    local potency    = pTable[spellId][5]
    local statDiff   = caster:getStat(statUsed) - target:getStat(statUsed)
    local skillLevel = caster:getSkillLevel(skillType)

    -- Calculate base potency for spells.
    switch (spellEffect) : caseof
    {
        [xi.effect.BLINDNESS] = function()
            statDiff = caster:getStat(statUsed) - target:getStat(xi.mod.MND)

            if spellId == xi.magic.spell.BLIND_II then
                potency = utils.clamp(statDiff * 0.375 + 49, 15, 90) -- Values from JP wiki: http://wiki.ffo.jp/html/3449.html
            else
                potency = utils.clamp(statDiff * 0.225 + 23, 5, 50)  -- Values from JP wiki: http://wiki.ffo.jp/html/834.html
            end
        end,

        [xi.effect.EVASION_DOWN] = function()
            if spellId == xi.magic.spell.DISTRACT then
                potency = utils.clamp(skillLevel / 5, 0, 25) + utils.clamp(statDiff / 5, 0, 10)
            elseif spellId == xi.magic.spell.DISTRACT_II then
                potency = utils.clamp(skillLevel * 4 / 35, 0, 40) + utils.clamp(statDiff / 5, 0, 10)
            else
                potency = utils.clamp(skillLevel / 5, 0, 120) + utils.clamp(statDiff / 5, 0, 10)
            end
        end,

        [xi.effect.MAGIC_EVASION_DOWN] = function()
            if spellId == xi.magic.spell.FRAZZLE then
                potency = utils.clamp(skillLevel / 5, 0, 25) + utils.clamp(statDiff / 5, 0, 10)
            elseif spellId == xi.magic.spell.FRAZZLE_II then
                potency = utils.clamp(skillLevel * 4 / 35, 0, 40) + utils.clamp(statDiff / 5, 0, 10)
            else
                potency = utils.clamp(skillLevel / 5, 0, 120) + utils.clamp(statDiff / 5, 0, 10)
            end
        end,

        [xi.effect.PARALYSIS] = function()
            if spellId == xi.magic.spell.PARALYZE_II then
                potency = utils.clamp(statDiff / 4 + 20, 10, 30)
            else
                potency = utils.clamp(statDiff / 4 + 15, 5, 25)
            end
        end,

        [xi.effect.POISON] = function()
            if
                spellId == xi.magic.spell.POISON or
                spellId == xi.magic.spell.POISONGA
            then
                potency = math.max(skillLevel / 25, 1)
                if skillLevel > 400 then
                    potency = math.min((skillLevel - 225) / 5, 55) -- Cap is 55 hp/tick.
                end
            elseif
                spellId == xi.magic.spell.POISON_II or
                spellId == xi.magic.spell.POISONGA_II
            then
                potency = math.max(skillLevel / 20, 4)
                if skillLevel > 400 then
                    potency = skillLevel * 49 / 183 - 55 -- No cap can be reached yet
                end
            else
                potency = skillLevel / 10 + 1
            end
        end,

        [xi.effect.SLOW] = function()
            if spellId == xi.magic.spell.SLOW_II then
                potency = utils.clamp(statDiff * 226 / 15 + 2380, 1250, 3510)
            else
                potency = utils.clamp(statDiff * 73 / 5 + 1825, 730, 2920)
            end
        end,

        [xi.effect.BURN] = function()
            potency = getElementalDebuffPotency(caster, statUsed)
        end,

        [xi.effect.CHOKE] = function()
            potency = getElementalDebuffPotency(caster, statUsed)
        end,

        [xi.effect.DROWN] = function()
            potency = getElementalDebuffPotency(caster, statUsed)
        end,

        [xi.effect.FROST] = function()
            potency = getElementalDebuffPotency(caster, statUsed)
        end,

        [xi.effect.RASP] = function()
            potency = getElementalDebuffPotency(caster, statUsed)
        end,

        [xi.effect.SHOCK] = function()
            potency = getElementalDebuffPotency(caster, statUsed)
        end,
    }

    potency = math.floor(potency)

    -- Apply Saboteur Effect when aplicable.
    local applySaboteur = pTable[spellId][11]

    if
        applySaboteur and
        caster:hasStatusEffect(xi.effect.SABOTEUR) and
        skillType == xi.skill.ENFEEBLING_MAGIC
    then
        if target:isNM() then
            potency = potency * (1.3 + caster:getMod(xi.mod.ENHANCES_SABOTEUR))
        else
            potency = potency * (2 + caster:getMod(xi.mod.ENHANCES_SABOTEUR))
        end
    end

    return math.floor(potency)
end

-- Calculate duration before resist
xi.spells.enfeebling.calculateDuration = function(caster, target, spellId, spellEffect, skillType)
    local duration = pTable[spellId][7] -- Get base duration.

    -- Additions to base duration.
    if
        spellEffect == xi.effect.BURN or
        spellEffect == xi.effect.CHOKE or
        spellEffect == xi.effect.DROWN or
        spellEffect == xi.effect.FROST or
        spellEffect == xi.effect.RASP or
        spellEffect == xi.effect.SHOCK
    then
        duration = duration + caster:getMerit(xi.merit.ELEMENTAL_DEBUFF_DURATION) -- TODO: Add BLM Toban gear effect (duration) here.
    end

    if caster:hasStatusEffect(xi.effect.SABOTEUR) then
        if target:isNM() then
            duration = duration * 1.25
        else
            duration = duration * 2
        end
    end

    -- After Saboteur according to bg-wiki
    if
        caster:getMainJob() == xi.job.RDM and
        skillType == xi.skill.ENFEEBLING_MAGIC
    then
        -- RDM Merit: Enfeebling Magic Duration
        duration = duration + caster:getMerit(xi.merit.ENFEEBLING_MAGIC_DURATION)

        -- RDM Job Point: Enfeebling Magic Duration
        duration = duration + caster:getJobPointLevel(xi.jp.ENFEEBLE_DURATION)

        -- RDM Job Point: Stymie effect
        if caster:hasStatusEffect(xi.effect.STYMIE) then
            duration = duration + caster:getJobPointLevel(xi.jp.STYMIE_EFFECT)
        end
    end

    return math.floor(duration)
end

xi.spells.enfeebling.handleEffectNullification = function(caster, target, spell, spellId, spellEffect)
    -- Determine if target mob is completely immune to a status effect.
    if target:isMob() then
        local value = pTable[spellId][10]

        -- Mob is completely immune. Set "Completely resists" message and nullify effect.
        if
            value > 0 and
            target:hasImmunity(value)
        then
            spell:setMsg(xi.msg.basic.MAGIC_RESIST_2) -- TODO: Confirm correct message.

            return true
        end
    end

    -- Check trait nullification trigger.
    local traitPower = target:getMod(pTable[spellId][3]) + target:getMod(xi.mod.STATUSRES)

    if traitPower > 0 then
        local roll = math.random(1, 100)
        traitPower = traitPower + 5

        if caster:isNM() then
            traitPower = traitPower / 2
        end

        -- Trait trigers. Set "Resist!" message and nullify effect.
        if roll <= traitPower then
            spell:setModifier(xi.msg.actionModifier.RESIST)
            spell:setMsg(xi.msg.basic.MAGIC_RESIST)

            return true
        end
    end

    -- Table for elemental debuff effects and which effect nullifies it.
    local elementalDebuffTable =
    {
        -- effect = Nullified by
        [xi.effect.BURN ] = { xi.effect.DROWN },
        [xi.effect.CHOKE] = { xi.effect.FROST },
        [xi.effect.DROWN] = { xi.effect.SHOCK },
        [xi.effect.FROST] = { xi.effect.BURN  },
        [xi.effect.RASP ] = { xi.effect.CHOKE },
        [xi.effect.SHOCK] = { xi.effect.RASP  },
    }

    -- Elemental DoTs effects.
    if
        spellEffect == xi.effect.BURN or
        spellEffect == xi.effect.CHOKE or
        spellEffect == xi.effect.DROWN or
        spellEffect == xi.effect.FROST or
        spellEffect == xi.effect.RASP or
        spellEffect == xi.effect.SHOCK
    then
        -- Target already has an status effect that nullifies current.
        if target:hasStatusEffect(elementalDebuffTable[spellEffect][1]) then
            spell:setMsg(xi.msg.basic.MAGIC_NO_EFFECT)

            return true
        end
    end

    return false
end

-- Main function, called by spell scripts
xi.spells.enfeebling.useEnfeeblingSpell = function(caster, target, spell)
    local spellId     = spell:getID()
    local spellEffect = pTable[spellId][1]

    ------------------------------
    -- STEP 1: Check spell nullification.
    ------------------------------
    if xi.spells.enfeebling.handleEffectNullification(caster, target, spell, spellId, spellEffect) then
        return spellEffect
    end

    ------------------------------
    -- STEP 2: Calculate resist tiers.
    ------------------------------
    local skillType    = spell:getSkillType()
    local spellElement = spell:getElement()
    local spellGroup   = spell:getSpellGroup()
    local statUsed     = pTable[spellId][2]
    local mEvaMod      = pTable[spellId][4]
    local resistStages = pTable[spellId][8]
    local message      = pTable[spellId][9]
    local bonusMacc    = pTable[spellId][12]
    local resistRank   = target:getMod(xi.combat.element.resistRankMod[spellElement]) or 0
    local rankModifier = target:getMod(immunobreakTable[spellEffect][1]) or 0

    -- Magic Hit Rate calculations.
    local magicAcc     = xi.combat.magicHitRate.calculateActorMagicAccuracy(caster, target, spellGroup, skillType, spellElement, statUsed, bonusMacc)
    local magicEva     = xi.combat.magicHitRate.calculateTargetMagicEvasion(caster, target, spellElement, true, mEvaMod, rankModifier)
    local magicHitRate = xi.combat.magicHitRate.calculateMagicHitRate(magicAcc, magicEva)
    local resistRate   = xi.combat.magicHitRate.calculateResistRate(caster, target, skillType, spellElement, magicHitRate, rankModifier)

    ------------------------------
    -- STEP 3: Check if spell resists and Immunobreak.
    ------------------------------
    if spellEffect ~= xi.effect.NONE then
        -- Stymie
        if
            skillType == xi.skill.ENFEEBLING_MAGIC and
            caster:hasStatusEffect(xi.effect.STYMIE)
        then
            resistRate = 1

        -- Fealty
        elseif target:hasStatusEffect(xi.effect.FEALTY) then
            resistRate = 0
        end
    end

    -- The effect will get resisted.
    if resistRate <= 1 / (2 ^ resistStages) then
        -- Attempt immunobreak.
        if
            caster:isPC() and
            target:isMob() and
            immunobreakTable[spellEffect] and          -- Only certain effects can be immunobroken.
            skillType == xi.skill.ENFEEBLING_MAGIC and -- Only Enfeebling magic can immunobreak.
            resistRank > 4                             -- Only mobs with a resistace rank of 5+ (50% EEM) can be immunobroken.
        then
            local immunobreakRandom = math.random(1, 100)
            local immunobreakChance = magicHitRate / (1 + rankModifier) + caster:getMerit(xi.merit.IMMUNOBREAK_CHANCE)

            -- We successfuly trigger Immunobreak. Change tagret modifier and set correct message.
            if immunobreakRandom <= immunobreakChance then
                target:setMod(immunobreakTable[spellEffect][1], rankModifier + 1) -- TODO: Add equipment modifier (x2) here.

                spell:setModifier(xi.msg.actionModifier.IMMUNOBREAK)
            end
        end

        -- We still resited.
        spell:setMsg(xi.msg.basic.MAGIC_RESIST)

        return spellEffect
    end

    ------------------------------
    -- STEP 4: Calculate Duration, Potency and Tick.
    ------------------------------
    local potency  = xi.spells.enfeebling.calculatePotency(caster, target, spellId, spellEffect, skillType, statUsed)
    local duration = math.floor(xi.spells.enfeebling.calculateDuration(caster, target, spellId, spellEffect, skillType) * resistRate)
    local tick     = pTable[spellId][6]

    ------------------------------
    -- STEP 5: Exceptions.
    ------------------------------
    -- Bind
    if spellEffect == xi.effect.BIND then
        potency = target:getSpeed()

    -- Dispel
    elseif spellEffect == xi.effect.NONE then
        spellEffect = target:dispelStatusEffect()

        if spellEffect == xi.effect.NONE then
            spell:setMsg(xi.msg.basic.MAGIC_NO_EFFECT)
        else
            spell:setMsg(xi.msg.basic.MAGIC_ERASE)
        end

        return spellEffect
    end

    ------------------------------
    -- STEP 6: Final Operations.
    ------------------------------
    if target:addStatusEffect(spellEffect, potency, tick, duration) then
        -- Delete Stymie effect
        if
            skillType == xi.skill.ENFEEBLING_MAGIC and
            caster:hasStatusEffect(xi.effect.STYMIE)
        then
            caster:delStatusEffect(xi.effect.STYMIE)
        end

        -- Add "Magic Burst!" message
        local _, skillchainCount = FormMagicBurst(spellElement, target) -- External function. Not present in magic.lua.

        if skillchainCount > 0 then
            spell:setMsg(xi.msg.basic.MAGIC_BURST_ENFEEB_IS - message * 3)
            caster:triggerRoeEvent(xi.roe.triggers.magicBurst)
        else
            spell:setMsg(xi.msg.basic.MAGIC_ENFEEB_IS + message)
        end
    else
        spell:setMsg(xi.msg.basic.MAGIC_NO_EFFECT)
    end

    return spellEffect
end
