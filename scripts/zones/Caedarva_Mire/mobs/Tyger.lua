-----------------------------------
-- Area: Caedarva Mire
--  ZNM: Tyger
-- !pos -766 -12 632 79
-- Spawn with Singed Buffalo: !additem 2593
-----------------------------------
mixins = {require("scripts/mixins/rage")}
require("scripts/globals/status")
-----------------------------------
local entity = {}

entity.onMobSpawn = function(mob)
    mob:setMod(xi.mod.SLOWRES, 10000)
    mob:addMod(xi.mod.ATT, 200)
    mob:setMobMod(xi.mobMod.IDLE_DESPAWN, 300)
    mob:addMod(xi.mod.MDEF, 150)
    mob:addMod(xi.mod.DEF, 100)
    mob:addMod(xi.mod.MAIN_DMG_RATING, 50)
    mob:addMod(xi.mod.STR, 50)
    mob:addMod(xi.mod.VIT, 20)
    mob:addMod(xi.mod.INT, 50)
    mob:addMod(xi.mod.MND, 20)
    mob:addMod(xi.mod.CHR, 20)
    mob:addMod(xi.mod.AGI, 20)
    mob:addMod(xi.mod.DEX, 40)
    mob:setMod(xi.mod.DEFP, 50)
    mob:addMod(xi.mod.DEFP, 475)
    mob:setMod(xi.mod.DOUBLE_ATTACK, 10)
    mob:setMod(xi.mod.EARTH_MEVA, 128)
    mob:setMod(xi.mod.DARK_MEVA, 250)
    mob:setMod(xi.mod.LIGHT_MEVA, 128)
    mob:setMod(xi.mod.FIRE_MEVA, 170)
    mob:setMod(xi.mod.WATER_MEVA, 170)
    mob:setMod(xi.mod.THUNDER_MEVA, 250)
    mob:setMod(xi.mod.ICE_MEVA, 128)
    mob:setMod(xi.mod.WIND_MEVA, 170)
    mob:setMod(xi.mod.EARTH_SDT, 128)
    mob:setMod(xi.mod.DARK_SDT, 250)
    mob:setMod(xi.mod.LIGHT_SDT, 128)
    mob:setMod(xi.mod.FIRE_SDT, 170)
    mob:setMod(xi.mod.WATER_SDT, 170)
    mob:setMod(xi.mod.THUNDER_SDT, 250)
    mob:setMod(xi.mod.ICE_SDT, 128)
    mob:setMod(xi.mod.WIND_SDT, 170)
    mob:setMod(xi.mod.SILENCERES, 10000)
    mob:setMod(xi.mod.LTNG_ABSORB, 100)
    mob:setMod(xi.mod.STUNRES, 50)
    mob:setMod(xi.mod.BINDRES, 10000)
    mob:setMod(xi.mod.GRAVITYRES, 10000)
    mob:setMod(xi.mod.SLEEPRES, 10000)
    mob:setMod(xi.mod.PARALYZERES, 100)
    mob:setMod(xi.mod.LULLABYRES, 10000)
    mob:setMod(xi.mod.FASTCAST, 10)
    mob:addStatusEffect(xi.effect.REGAIN, 10, 3, 0)
    mob:addStatusEffect(xi.effect.REGEN, 30, 3, 0)
    mob:addStatusEffect(xi.effect.REFRESH, 50, 3, 0)
    mob:addMod(xi.mod.MOVE, 12)
    mob:setAnimationSub(0)
    mob:setLocalVar("[rage]timer", 3600) -- 60 minutes
end

entity.onMobDeath = function(mob, player, isKiller)
end

return entity
