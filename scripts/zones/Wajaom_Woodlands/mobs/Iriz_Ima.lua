-----------------------------------
-- Area: Wajaom Woodlands
--  ZNM: Iriz Ima
-----------------------------------
mixins = { require("scripts/mixins/rage") }
-----------------------------------
local entity = {}
-- TODO INITIAL COMMIT Just put here so players cannot run through the NM's 
entity.onMobInitialize = function(mob)
    mob:addMod(xi.mod.ATT, 25)
    mob:setMobMod(xi.mobMod.IDLE_DESPAWN, 300)
    mob:addMod(xi.mod.MDEF, 50)
    mob:addMod(xi.mod.DEF, 25)
    mob:addMod(xi.mod.MAIN_DMG_RATING, 10)
    mob:setMod(xi.mod.EARTH_MEVA, 25)
    mob:setMod(xi.mod.DARK_MEVA, 25)
    mob:setMod(xi.mod.LIGHT_MEVA, 25)
    mob:setMod(xi.mod.FIRE_MEVA, 25)
    mob:setMod(xi.mod.WATER_MEVA, 25)
    mob:setMod(xi.mod.THUNDER_MEVA, 25)
    mob:setMod(xi.mod.ICE_MEVA, 25)
    mob:setMod(xi.mod.WIND_MEVA, 25)
    mob:setMod(xi.mod.EARTH_SDT, 25)
    mob:setMod(xi.mod.DARK_SDT, 25)
    mob:setMod(xi.mod.LIGHT_SDT, 25)
    mob:setMod(xi.mod.FIRE_SDT, 25)
    mob:setMod(xi.mod.WATER_SDT, 25)
    mob:setMod(xi.mod.THUNDER_SDT, 25)
    mob:setMod(xi.mod.ICE_SDT, 25)
    mob:setMod(xi.mod.WIND_SDT, 25)
    mob:setMod(xi.mod.DOUBLE_ATTACK, 5)
    mob:addMod(xi.mod.GRAVITYRES, 10000)
    mob:addMod(xi.mod.SLEEPRES, 10000)
    mob:addMod(xi.mod.LULLABYRES, 10000)
    mob:addMod(xi.mod.SILENCERES, 10000)
    mob:addMod(xi.mod.BINDRES, 10000)
    mob:addStatusEffect(xi.effect.REGAIN, 2, 3, 0)
    mob:addStatusEffect(xi.effect.REGEN, 5, 3, 0)
    mob:addMod(xi.mod.MOVE, 12)
    mob:setMobMod(xi.mobMod.IDLE_DESPAWN, 300)
end

entity.onMobSpawn = function(mob)
    mob:setLocalVar("[rage]timer", 3600) -- 60 minutes
    mob:setLocalVar("BreakChance", 5)
end

entity.onCriticalHit = function(mob, attacker)
    if math.random(100) <= mob:getLocalVar("BreakChance") then
        local animationSub = mob:getAnimationSub()
        if animationSub == 4 then
            mob:setAnimationSub(1) -- 1 horn broken
        elseif animationSub == 1 then
            mob:setAnimationSub(2) -- both horns broken
        end
    end
end

entity.onMobDeath = function(mob, player, optParams)
end

return entity
