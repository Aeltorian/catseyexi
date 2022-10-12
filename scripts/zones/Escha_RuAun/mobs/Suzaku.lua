-----------------------------------
-- Area: Escha - Ru'Aun
-- NM: Suzaku
-- TODO: Make flamingos immune to sleep/bind/gravity
-----------------------------------
local ID = require("scripts/zones/Escha_RuAun/IDs")
mixins = {require("scripts/mixins/job_special")}
require("scripts/globals/mobs")
require("scripts/globals/status")
-----------------------------------
local entity = {}
local addIds = {}
local despawnMobTable =
{
    17961281,
    17961282,
    17961283,
    17961284,
    17961285,
    17961286,
    17961287,
    17961288
}

numAdds = 0

entity.onMobSpawn = function(mob, target)
    mob:setMod(xi.mod.MAIN_DMG_RATING, 50)
    mob:setMod(xi.mod.UFASTCAST, 50)
    mob:setMod(xi.mod.SILENCERES, 9999)
    mob:setMod(xi.mod.STUNRES, 9999)
    mob:setMod(xi.mod.BINDRES, 9999)
    mob:setMod(xi.mod.GRAVITYRES, 9999)
    mob:setMod(xi.mod.SLEEPRES, 9999)
    mob:setMod(xi.mod.POISONRES, 9999)
    mob:setMod(xi.mod.PARALYZERES, 9999)
    mob:setMod(xi.mod.LULLABYRES, 9999)
    mob:setDropID(3992)

	for _, despawnMob in ipairs(despawnMobTable) do
	    DespawnMob(despawnMob)
    end
end

entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 1)
end

entity.onMobFight = function(mob, target, spellId) -- This function is fired every 400 ms.
    local currentTime = os.time()

    -- Pet logic here
    local spawnTime = 30 -- Spawn dynamic entity every interval of seconds
    local nextPet   = mob:getLocalVar("nextPetPop")

    if nextPet == 0 then
        nextPet = currentTime + spawnTime
        mob:setLocalVar("nextPetPop", nextPet)
    end

    -- 2-Hour Logic
    local twoHourTime  = mob:getLocalVar("twoHourTime")
    local fifteenBlock = mob:getBattleTime() / 15

    -- Randomize opportunity to use blood weapon (2-hour skill)
    if twoHourTime == 0 then
        twoHourTime = math.random(4, 6)
        mob:setLocalVar("twoHourTime", twoHourTime)
    end

    -- DEBUG
    -- print(string.format("spawnTime: %s fifteenBlock: %s", spawnTime, fifteenBlock))
    
    -- check to see if we can use blood weapon
    if fifteenBlock > twoHourTime then
        mob:useMobAbility(695) -- blood weapon
        mob:setLocalVar("twoHourTime", fifteenBlock + math.random(4, 6))
    end
    
    if currentTime > nextPet then
        -- Variable Work for next pet cooldown.
        nextPet = currentTime + spawnTime
        mob:setLocalVar("nextPetPop", nextPet)

        for _, partyMember in pairs(target:getAlliance()) do
            partyMember:PrintToPlayer("Suzaku begins absorbs his minions' strength...")
        end
        -- Get random player from the enmity list to attach an add to
        local enmityList   = mob:getEnmityList()
        local numEntries   = #enmityList
        local randomPlayer = utils.randomEntry(enmityList)["entity"]
        local zone         = randomPlayer:getZone()

        -- Dynamic Entity Definition (Minion)
        local minion = zone:insertDynamicEntity({
            objtype  = xi.objType.MOB,
            name     = "Suzaku's Minion",
            x        = randomPlayer:getXPos(),
            y        = randomPlayer:getYPos(),
            z        = randomPlayer:getZPos(),
            rotation = randomPlayer:getRotPos(),

            -- Flamingo
            groupId     = 2,
            groupZoneId = 130,

            onMobDeath = function(mob, playerArg, isKiller)
            end,

            onMobSpawn = function(mob)
			    mob:setMod(xi.mod.SLEEPRES, 9999)
                mob:setMod(xi.mod.LULLABYRES, 9999)
                numAdds = numAdds + 1
                mob:timer(25000, function(mobArg)
                    mob:useMobAbility(511) -- self-destruct
                end)
            end,
            
            onMobFight = function(mob, target)
                local suzaku = GetMobByID(17961568)

                if not suzaku:isAlive() then
                    DespawnMob(mob:getID())
                end
            end,

            releaseIdOnDeath = true,
        
            -- You can apply mixins like you would with regular mobs. mixinOptions aren't supported yet.
            mixins =
            {
                require("scripts/mixins/rage"),
                require("scripts/mixins/job_special"),
            },
        
            -- The "whooshy" special animation that plays when Trusts or Dynamis mobs spawn
            specialSpawnAnimation = true,
        })
        
        -- Use the minion object as you normally would
        minion:setSpawn(randomPlayer:getXPos(), randomPlayer:getYPos(), randomPlayer:getZPos(), randomPlayer:getRotPos())
        minion:setDropID(0) -- No loot!
        minion:spawn()
        minion:updateClaim(randomPlayer)
    end

    mob:setMod(xi.mod.MAIN_DMG_RATING, 75 * numAdds)
    -- print(string.format("numadds %s", numAdds))
end

entity.onAdditionalEffect = function(mob, target, damage)
    return xi.mob.onAddEffect(mob, target, damage, xi.mob.ae.ENFIRE)
end

entity.onMobDeath = function(mob, player, isKiller)
    for _, add in ipairs(addIds) do
        DespawnMob(add)
    end
end

entity.onMobDespawn = function(mob)
	for _, despawnMob in ipairs(despawnMobTable) do
	    SpawnMob(despawnMob)
    end
end

return entity