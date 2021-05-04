-----------------------------------
-- Area: Mhaura
--  NPC: Rycharde
--    Standard Info NPC
--  WAY_OF_THE_COOK, UNENDING_CHASE
--     his name is Valgeir (not completed correctly, ferry not implemented)
--     the clue (100%)
--     the basics (not completed correctly, ferry not implemented)
-----------------------------------
local ID = require("scripts/zones/Mhaura/IDs")

require("scripts/globals/titles")
require("scripts/globals/quests")
require("scripts/globals/settings")
require("scripts/globals/keyitems")
-----------------------------------
local entity = {}

--   player:startEvent(74) -- first quest completed ok
--   player:startEvent(75) -- nothing to do
--   player:startEvent(76) -- second quest start  --WAY_OF_THE_COOK
--   player:startEvent(78) -- you have x hours left
--   player:startEvent(79) -- not yet done
--   player:startEvent(80) -- second quest completed
--   player:startEvent(81) -- too late second quest
--   player:startEvent(82)-- third quest
--   player:startEvent(83)-- third quest completed
--   player:startEvent(84)-- third quest  said no, ask again
--   player:startEvent(85)-- third quest  comment no hurry
--   player:startEvent(86)-- forth quest   His Name is Valgeir
--   player:startEvent(87)-- forth quest   not done yet
--   player:startEvent(88)-- forth quest   done!
--   player:startEvent(89)-- nothing to do
--   player:startEvent(90)-- fifth quest The Clue
--   player:startEvent(91)-- fifth quest The Clue asked again
--   player:startEvent(92)-- fifth quest completed
--   player:startEvent(93)-- fifth quest not enogh
--   player:startEvent(94)-- sixth quest The Basics
--   player:startEvent(95)-- sixth quest not done yet
--   player:startEvent(96)-- sixth quest completed
--   player:startEvent(97)-- sixth quest completed commentary
--   player:startEvent(98)-- sixth quest completed commentary 2

entity.onTrade = function(player, npc, trade)
--[[
    if (player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.UNENDING_CHASE) == QUEST_ACCEPTED) then
        local puffball  = trade:hasItemQty(4448, 1) --4448 - puffball

        if (puffball  == true) then
            player:startEvent(83) -- completed quest 3 UNENDING_CHASE
        end

    elseif (player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.THE_CLUE) == QUEST_ACCEPTED) then
        local count = trade:getItemCount()
        local DhalmelMeat  = trade:hasItemQty(4357, trade:getItemCount()) --4357 - crawler egg

        if (DhalmelMeat  == true and count > 3) then
            player:startEvent(92)
        elseif (DhalmelMeat  == true) then
            player:startEvent(93) -- that's not enogh!
        end

    elseif (player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.THE_BASICS) == QUEST_ACCEPTED) then
        local BackedPototo  = trade:hasItemQty(4436, 1) --4436 - baked_popoto
        if (BackedPototo  == true) then
            player:startEvent(96)
        end
    end
]]
end

entity.onTrigger = function(player, npc)
--[[
---------------------------QUEST UNENDING_CHASE--------------------------------------------------
    if player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.UNENDING_CHASE) == QUEST_AVAILABLE and
        player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.WAY_OF_THE_COOK) == QUEST_COMPLETED and
        player:getFameLevel(WINDURST) > 2
    then
        if (player:getCharVar("QuestWayofTCCompDay_var")+7 < VanadielDayOfTheYear() or player:getCharVar("QuestWayofTCCompYear_var") < VanadielYear()) then  -- days between quest
            if (player:getCharVar("QuestUnendingCAskedAlready_var")==2) then
                player:startEvent(84, 4448)-- third quest  said no, ask again
            else
                player:startEvent(82, 4448)-- third quest UNENDING_CHASE    4448 - puffball
            end
        else
            player:startEvent(75) -- nothing to do
        end

    elseif player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.UNENDING_CHASE) == QUEST_ACCEPTED then
        player:startEvent(85)-- third quest  comment no hurry
-------------------------QUEST HIS_NAME_IS_VALGEIR--------------------------------------------------
    elseif player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.HIS_NAME_IS_VALGEIR) == QUEST_AVAILABLE and
        player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.UNENDING_CHASE) == QUEST_COMPLETED and
        player:getFameLevel(WINDURST) > 2
    then
        if player:getCharVar("QuestUnendingCCompDay_var")+2< VanadielDayOfTheYear() or player:getCharVar("QuestUnendingCCompYear_var") < VanadielYear() then
            player:startEvent(86)-- forth quest   His Name is Valgeir
        else
            player:startEvent(75) -- nothing to do
        end

    elseif player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.HIS_NAME_IS_VALGEIR) == QUEST_ACCEPTED then
        if (player:hasKeyItem(xi.ki.ARAGONEU_PIZZA)) then
            player:startEvent(87)-- forth quest   not done yet
        else
            player:startEvent(88)-- forth quest   done!
        end
---------------------------QUEST THE CLUE--------------------------------------------------------
    elseif player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.THE_CLUE) == QUEST_AVAILABLE and
        player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.HIS_NAME_IS_VALGEIR) == QUEST_COMPLETED and
        player:getFameLevel(WINDURST) > 4
    then
        if player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.EXPERTISE) == QUEST_COMPLETED then
            if player:getCharVar("QuestExpertiseCompDay_var") + 7 < VanadielDayOfTheYear() or player:getCharVar("QuestExpertiseCompYear_var") < VanadielYear() then
                if player:getCharVar("QuestTheClueStatus_var") == 1 then
                    player:startEvent(91, 4357)-- fifth quest The Clue asked again 4357 - crawler_egg
                else
                    player:startEvent(90, 4357)-- fifth quest The Clue 4357 - crawler_egg
                end
            else
                player:startEvent(75) -- nothing to do
            end
        else
            player:startEvent(75) -- nothing to do
        end

    elseif player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.THE_CLUE) == QUEST_ACCEPTED then
        player:startEvent(85)-- third quest  comment no hurry
---------------------------QUEST THE Basics--------------------------------------------------------
    elseif player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.THE_BASICS) == QUEST_AVAILABLE and
        player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.THE_CLUE) == QUEST_COMPLETED and
        player:getFameLevel(WINDURST) > 4
    then
        if player:getCharVar("QuestTheClueCompDay_var")+7 < VanadielDayOfTheYear() or player:getCharVar("QuestTheClueCompYear_var") < VanadielYear() then
            player:startEvent(94)-- sixth quest The Basics
        else
            player:startEvent(75) -- nothing to do standar dialog
        end

    elseif player:getQuestStatus(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.THE_BASICS) == QUEST_ACCEPTED then
        player:startEvent(95)-- sixth quest not done yet

    else
        if player:getCharVar("QuestTheBasicsComentary_var") == 1 then
            player:startEvent(97)-- sixth quest completed commentary
        else
            player:startEvent(98)-- sixth quest completed commentary 2
        end
    end
]]
end

entity.onEventUpdate = function(player, csid, option)
end

entity.onEventFinish = function(player, csid, option)
--[[
    if (csid == 82) then  -- accept quest 3 UNENDING_CHASE
        player:setCharVar("QuestUnendingCAskedAlready_var", 2)
        if (option == 77 ) then -- answer yes!
            player:addQuest(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.UNENDING_CHASE)
        end
    elseif (csid == 84) then  -- accept quest 3 UNENDING_CHASE
        if (option == 78 ) then -- answer yes!
            player:addQuest(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.UNENDING_CHASE)
        end
    elseif (csid == 83) then  -- end quest 3 UNENDING_CHASE
        player:tradeComplete()
        player:addFame(WINDURST, 120)
        player:addTitle(xi.title.TWOSTAR_PURVEYOR)
        player:addGil(GIL_RATE*2100)
        player:messageSpecial(ID.text.GIL_OBTAINED, GIL_RATE*2100)
        player:setCharVar("QuestUnendingCAskedAlready_var", 0)
        player:setCharVar("QuestWayofTCCompDay_var", 0) -- completition day of WAY_OF_THE_COOK delete variable
        player:setCharVar("QuestWayofTCCompYear_var", 0)
        player:setCharVar("QuestUnendingCCompDay_var", VanadielDayOfTheYear()) -- completition day of unending chase
        player:setCharVar("QuestUnendingCCompYear_var", VanadielYear())
        player:completeQuest(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.UNENDING_CHASE)
    elseif (csid == 86) then  -- accept quest 4 HIS_NAME_IS_VALGEIR
        if (option == 80 ) then -- answer yes!

            player:addKeyItem(xi.ki.ARAGONEU_PIZZA) --give pizza to player
            player:messageSpecial(ID.text.KEYITEM_OBTAINED, xi.ki.ARAGONEU_PIZZA)
            player:addQuest(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.HIS_NAME_IS_VALGEIR)
        end
    elseif (csid == 88) then  -- end quest 4 his name is Valgeir
        player:addFame(WINDURST, 120)
        player:addKeyItem(xi.ki.MAP_OF_THE_TORAIMARAI_CANAL) --reward Map of the Toraimarai Canal
        player:messageSpecial(ID.text.KEYITEM_OBTAINED, xi.ki.MAP_OF_THE_TORAIMARAI_CANAL)
        player:setCharVar("QuestUnendingCCompDay_var", 0) -- completition day of unending chase delete
        player:setCharVar("QuestUnendingCCompYear_var", 0)
        player:setCharVar("QuestHNIVCCompDay_var", VanadielDayOfTheYear()) -- completition day of unending chase
        player:setCharVar("QuestHNIVCCompYear_var", VanadielYear())
        player:completeQuest(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.HIS_NAME_IS_VALGEIR)
    elseif (csid == 90 or csid == 91) then  --accept quest the clue
        player:setCharVar("QuestTheClueStatus_var", 1)
        if (option == 83 ) then
            player:addQuest(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.THE_CLUE)
        end
    elseif (csid == 92) then   -- end quest THE CLUE
        player:tradeComplete()
        player:addFame(WINDURST, 120)
        player:addTitle(xi.title.FOURSTAR_PURVEYOR)
        player:addGil(GIL_RATE*3000)
        player:messageSpecial(ID.text.GIL_OBTAINED, GIL_RATE*3000)
        player:setCharVar("QuestTheClueStatus_var", 0)
        player:setCharVar("QuestExpertiseCompDay_var", 0) -- completition day of expertice quest
        player:setCharVar("QuestExpertiseCompYear_var", 0)
        player:setCharVar("QuestTheClueCompDay_var", VanadielDayOfTheYear()) -- completition day of THE CLUE
        player:setCharVar("QuestTheClueCompYear_var", VanadielYear())
        player:completeQuest(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.THE_CLUE)
    elseif (csid == 94) then  --accept quest the basics
        if (option == 85 ) then
            --TODO pay for ferry
            player:addKeyItem(xi.ki.MHAURAN_COUSCOUS) -- xi.ki.MHAURAN_COUSCOUS                = 92
            player:messageSpecial(ID.text.KEYITEM_OBTAINED, xi.ki.MHAURAN_COUSCOUS)
            player:addQuest(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.THE_BASICS)
        end
    elseif (csid == 96) then   -- end quest the basics
        player:tradeComplete()
        player:addFame(WINDURST, 120)
        player:addTitle(xi.title.FIVESTAR_PURVEYOR)
        if (player:getFreeSlotsCount() <= 1) then
            player:messageSpecial(ID.text.ITEM_CANNOT_BE_OBTAINED, 133)
        else
            player:addItem(133)
            player.messageSpecial(ID.text.ITEM_OBTAINED, 133)
            player:setCharVar("QuestTheClueCompDay_var", 0) -- completition day of THE CLUE
            player:setCharVar("QuestTheClueCompYear_var", 0)
            player:setCharVar("QuestTheBasicsComentary_var", 1)
            player:completeQuest(xi.quest.log_id.OTHER_AREAS, xi.quest.id.otherAreas.THE_BASICS)
        end
    elseif (csid == 97) then  --end commentary quest the basics
        player:setCharVar("QuestTheBasicsComentary_var", 0)
    end
]]
end

return entity
