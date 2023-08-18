-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Famad
-- Type: Assault Mission Giver
-- !pos 134.098 0.161 -43.759 50
-----------------------------------
require("scripts/globals/assault")
require("scripts/globals/besieged")
require("scripts/globals/npc_util")
require("scripts/globals/extravaganza")
-----------------------------------
local entity = {}

local items =
{
    [1]  = { itemid = xi.items.INSOMNIA_EARRING,             price =  3000 },
    [2]  = { itemid = xi.items.HALE_RING,                    price =  5000 },
    [3]  = { itemid = xi.items.CHIVALROUS_CHAIN,             price =  8000 },
    [4]  = { itemid = xi.items.PRECISE_BELT,                 price = 10000 },
    [5]  = { itemid = xi.items.INTENSIFYING_CAPE,            price = 10000 },
    [6]  = { itemid = xi.items.IMPERIAL_POLE,                price = 15000 },
    [7]  = { itemid = xi.items.DOOMBRINGER,                  price = 15000 },
    [8]  = { itemid = xi.items.SAYOSAMONJI,                  price = 15000 },
    [9]  = { itemid = xi.items.PAHLUWAN_DASTANAS,            price = 20000 },
    [10] = { itemid = xi.items.YIGIT_CRACKOWS,               price = 20000 },
    [11] = { itemid = xi.items.AMIR_KORAZIN,                 price = 20000 },
    [12] = { itemid = xi.items.CIPHER_OF_OVJANGS_ALTER_EGO,  price =  3000 },
    [13] = { itemid = xi.items.CIPHER_OF_MNEJINGS_ALTER_EGO, price =  3000 },
}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    local rank = xi.besieged.getMercenaryRank(player)
    local haveimperialIDtag = player:hasKeyItem(xi.ki.IMPERIAL_ARMY_ID_TAG) and 1 or 0
    local assaultPoints = player:getAssaultPoint(xi.assault.assaultArea.LEBROS_CAVERN)
    local cipher = 0
    local active = xi.extravaganza.campaignActive()

    if
        active == xi.extravaganza.campaign.SPRING_FALL or
        active == xi.extravaganza.campaign.BOTH
    then
        cipher = 1
    end

    if rank > 0 then
        player:startEvent(275, rank, haveimperialIDtag, assaultPoints, player:getCurrentAssault(), cipher)
    else
        player:startEvent(281)
    end
end

entity.onEventUpdate = function(player, csid, option, npc)
    local selectiontype = bit.band(option, 0xF)
    if csid == 275 and selectiontype == 2 then
        local item = bit.rshift(option, 14)
        local choice = items[item]
        local assaultPoints = player:getAssaultPoint(xi.assault.assaultArea.LEBROS_CAVERN)
        local canEquip = player:canEquipItem(choice.itemid) and 2 or 0

        player:updateEvent(0, 0, assaultPoints, 0, canEquip)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 275 then
        local selectiontype = bit.band(option, 0xF)
        if
            selectiontype == 1 and
            npcUtil.giveKeyItem(player, xi.ki.LEBROS_ASSAULT_ORDERS)
        then
            -- taken assault mission
            player:addAssault(bit.rshift(option, 4))
            player:delKeyItem(xi.ki.IMPERIAL_ARMY_ID_TAG)
            player:addKeyItem(xi.ki.MAP_OF_LEBROS_CAVERN)
        elseif selectiontype == 2 then
            -- purchased an item
            local item = bit.rshift(option, 14)
            local choice = items[item]
            if choice and npcUtil.giveItem(player, choice.itemid) then
                player:delAssaultPoint(xi.assault.assaultArea.LEBROS_CAVERN, choice.price)
            end
        end
    end
end

return entity
