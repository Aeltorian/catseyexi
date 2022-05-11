-----------------------------------
-- Area: Western Altepa Desert
--  NPC: <this space intentionally left blank>
-- !pos -152 -16 20 125
-----------------------------------
local ID = require("scripts/zones/Western_Altepa_Desert/IDs")
require("scripts/globals/items")
require("scripts/globals/npc_util")
-----------------------------------
local entity = {}

entity.onTrade = function(player, npc, trade)
    if player:getCharVar("RELIC_IN_PROGRESS") == xi.items.OGRE_KILLER and npcUtil.tradeHas(trade, {xi.items.RIMILALA_STRIPESHELL, xi.items.RUNAEIC_FRAGMENT, xi.items.SHARD_OF_NECROPSYCHE, xi.items.OGRE_KILLER}) then -- currency, shard, necropsyche, stage 4
        player:startEvent(205, xi.items.GUTTLER)
    end
	
	--  vars for part 1 of the relic exchange program
    local Gil = trade:getGil()
	local ExchangeToken = player:getCharVar("[CXI]RelicExchangeToken")
    local TradeSpharai = npcUtil.tradeHas(trade, xi.items.SPHARAI)
    local TradeMandau = npcUtil.tradeHas(trade, xi.items.MANDAU)
    local TradeExcalibur = npcUtil.tradeHas(trade, xi.items.EXCALIBUR)
    local TradeRagnarok = npcUtil.tradeHas(trade, xi.items.RAGNAROK)
    local TradeGuttler = npcUtil.tradeHas(trade, xi.items.GUTTLER)
    local TradeBravura = npcUtil.tradeHas(trade, xi.items.BRAVURA)
    local TradeApocalypse = npcUtil.tradeHas(trade, xi.items.APOCALYPSE)
    local TradeGungnir = npcUtil.tradeHas(trade, xi.items.GUNGNIR)
    local TradeKikoku = npcUtil.tradeHas(trade, xi.items.KIKOKU)
    local TradeAmano = npcUtil.tradeHas(trade, xi.items.AMANOMURAKUMO)
    local TradeMjollnir = npcUtil.tradeHas(trade, xi.items.MJOLLNIR)
    local TradeClaustrum = npcUtil.tradeHas(trade, xi.items.CLAUSTRUM)
    local TradeYoichi = npcUtil.tradeHas(trade, xi.items.YOICHINOYUMI)
    local TradeAnnihilator = npcUtil.tradeHas(trade, xi.items.ANNIHILATOR)
    local TradeGjallhorn = npcUtil.tradeHas(trade, xi.items.GJALLARHORN)
    local TradeAegis = npcUtil.tradeHas(trade, xi.items.AEGIS)
	
-- vars for part 2	
	local GuttlerExchange = (ExchangeToken == 1 and npcUtil.tradeHas(trade, 18284)) -- relic_axe

-- give player their exchange token
    if Gil == 10000000 and
       (TradeSpharai or TradeMandau or TradeExcalibur or TradeRagnarok or TradeGuttler or TradeBravura or TradeApocalypse or
        TradeGungnir or TradeKikoku or TradeAmano or TradeMjollnir or TradeClaustrum or TradeYoichi or TradeAnnihilator or
        TradeGjallhorn or TradeAegis) then
            player:tradeComplete()
            player:PrintToPlayer("???: You have decided... Now offer me the corresponding vessel and we'll complete the covenant.", 0xD)
            player:setCharVar("[CXI]RelicExchangeToken", 1)
	elseif GuttlerExchange then 
	    player:tradeComplete()
		player:setCharVar("[CXI]RelicExchangeToken", 0)
	    player:addItem(xi.items.GUTTLER) 
		player:messageSpecial(ID.text.ITEM_OBTAINED, xi.items.GUTTLER)
   	else
        player:PrintToPlayer("???: The covenant states 10,000,000 gil and your existing relic. Don't keep me waiting.", 0xD)
    end
end

entity.onTrigger = function(player, npc)
--    player:messageSpecial(ID.text.NOTHING_OUT_OF_ORDINARY)
    player:PrintToPlayer("???: Hail to you hardened traveler,", 0xD)
    player:PrintToPlayer("???: Do you desire to switch your ally? Trade your relic back to me together with 10,000,000 gil", 0xD)
	player:PrintToPlayer("???: and I'll exchange it for my soul. Let me return to the battlefield!", 0xD)
end

entity.onEventUpdate = function(player, csid, option)
end

entity.onEventFinish = function(player, csid, option)
    if csid == 205 and npcUtil.giveItem(player, {xi.items.GUTTLER, {xi.items.LUNGO_NANGO_JADESHELL, 30}}) then
        player:confirmTrade()
        player:setCharVar("RELIC_IN_PROGRESS", 0)
    end
end

return entity
