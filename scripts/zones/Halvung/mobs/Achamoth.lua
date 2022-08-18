-----------------------------------
-- Area: Halvung
--  ZNM: Achamoth
--  Mobid: 17031600
-----------------------------------
mixins ={require("scripts/mixins/job_special"),
         require("scripts/mixins/rage")}
         require("scripts/globals/status")
-----------------------------------
local entity = {}
entity.onMobInitialize = function(mob)
    mob:addMod(xi.mod.ATT, 200)
    mob:addMod(xi.mod.MDEF, 200)
    mob:addMod(xi.mod.DEF, 175)
    mob:addMod(xi.mod.MAIN_DMG_RATING, 50)
    mob:addMod(xi.mod.STR, 50)
    mob:addMod(xi.mod.VIT, 30)
    mob:addMod(xi.mod.INT, 60)
    mob:addMod(xi.mod.MND, 30)
    mob:addMod(xi.mod.CHR, 20)
    mob:addMod(xi.mod.AGI, 30)
    mob:addMod(xi.mod.DEX, 40)
    mob:addMod(xi.mod.DEFP, 475)
    mob:setMod(xi.mod.DOUBLE_ATTACK, 10)
    mob:setMod(xi.mod.EARTH_MEVA, 200)
    mob:setMod(xi.mod.DARK_MEVA, 200)
    mob:setMod(xi.mod.LIGHT_MEVA, 200)
    mob:setMod(xi.mod.FIRE_MEVA, 300)
    mob:setMod(xi.mod.WATER_MEVA, 200)
    mob:setMod(xi.mod.THUNDER_MEVA, 170)
    mob:setMod(xi.mod.ICE_MEVA, 170)
    mob:setMod(xi.mod.WIND_MEVA, 200)
    mob:setMod(xi.mod.EARTH_SDT, 200)
    mob:setMod(xi.mod.DARK_SDT, 200)
    mob:setMod(xi.mod.LIGHT_SDT, 200)
    mob:setMod(xi.mod.FIRE_SDT, 300)
    mob:setMod(xi.mod.WATER_SDT, 200)
    mob:setMod(xi.mod.THUNDER_SDT, 170)
    mob:setMod(xi.mod.ICE_SDT, 170)
    mob:setMod(xi.mod.WIND_SDT, 200)
    mob:setMod(xi.mod.SILENCERES, 10000)
    mob:setMod(xi.mod.FIRE_ABSORB, 100)
    mob:setMod(xi.mod.STUNRES, 50)
    mob:setMod(xi.mod.BINDRES, 10000)
    mob:setMod(xi.mod.GRAVITYRES, 10000)
    mob:setMod(xi.mod.SLEEPRES, 10000)
    mob:setMod(xi.mod.PARALYZERES, 100)
    mob:setMod(xi.mod.LULLABYRES, 10000)
    mob:addMod(xi.mod.MATT, 250)
    mob:addMod(xi.mod.MACC, 250)
    mob:addMod(xi.mod.MOVE, 12)
    mob:addMod(xi.mod.CURE_POTENCY, 250)
    mob:addStatusEffect(xi.effect.REGAIN, 10, 3, 0)
    mob:addStatusEffect(xi.effect.REGEN, 30, 3, 0)
    mob:addStatusEffect(xi.effect.REFRESH, 50, 3, 0)
    mob:addStatusEffect(xi.effect.BLAZE_SPIKES, 100, 0, 9000000)
    mob:setMobMod(xi.mobMod.IDLE_DESPAWN, 300)
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 1)
    mob:setAnimationSub(0)
end

entity.onAdditionalEffect = function(mob, target, damage)
 return xi.mob.onAddEffect(mob, target, damage, xi.mob.ae.MP_DRAIN, {chance = 100, power = math.random(5, 20)})
end

entity.onMobSpawn = function(mob)
    xi.mix.jobSpecial.config(mob, {
        specials =
        {
            {id = xi.jsa.BENEDICTION, hpp = 25},
        },
    })
    mob:setLocalVar("[rage]timer", 1800)
end

entity.onMobDeath = function(mob, player, isKiller)
end

return entity
