-----------------------------------
-- Area: Norg
--  NPC: Shivivi
-- Starts Quest: Secret of the Damp Scroll
-- !pos 68.729 -6.281 -6.432 252
-----------------------------------
local entity = {}

local pathNodes =
{
    { x = 59.698738, y = -6.282220, z = -0.842413 },
    { x = 60.732185, z = -1.238357 },
    { x = 61.612240, z = -1.784821 },
    { x = 62.487907, z = -2.353283 },
    { x = 72.850945, z = -9.126195 },
    { x = 73.853767, z = -9.553433 },
    { x = 74.856308, z = -9.683896 },
    { x = 73.738983, z = -9.515277 },
    { x = 72.831741, z = -9.069685 },
    { x = 71.878197, z = -8.482308 },
    { x = 70.934311, z = -7.872030 },
    { x = 59.120659, z = -0.152556 },
    { x = 58.260170, z = 0.364192 },
    { x = 57.274529, z = 0.870113 },
    { x = 56.267262, z = 1.278537 },
    { x = 55.206066, z = 1.567320 },
    { x = 54.107983, z = 1.825333 },
    { x = 52.989727, z = 2.044612 },
    { x = 51.915558, z = 2.155138 },
    { x = 50.790054, z = 2.229803 },
    { x = 48.477810, z = 2.361498 },
    { x = 52.035912, z = 2.157254 },
    { x = 53.062607, z = 2.020960 },
    { x = 54.161610, z = 1.805452 },
    { x = 55.267555, z = 1.563984 },
    { x = 56.350552, z = 1.252867 },
    { x = 57.370754, z = 0.821186 },
    { x = 58.355640, z = 0.306034 },
    { x = 59.294991, z = -0.273827 },
    { x = 60.222008, z = -0.873351 },
    { x = 72.913628, z = -9.164549 },
    { x = 73.919716, z = -9.571738 },
    { x = 75.007599, z = -9.696978 },
    { x = 73.930611, z = -9.597872 },
    { x = 72.944572, z = -9.142765 },
    { x = 72.017265, z = -8.573789 },
    { x = 71.103760, z = -7.982807 },
    { x = 59.055004, z = -0.111382 },
    { x = 58.112335, z = 0.439206 },
}

entity.onSpawn = function(npc)
    npc:initNpcAi()
    npc:setPos(xi.path.first(pathNodes))
    npc:pathThrough(pathNodes, xi.path.flag.PATROL)
end

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    local dampScroll = player:getQuestStatus(xi.quest.log_id.OUTLANDS, xi.quest.id.outlands.SECRET_OF_THE_DAMP_SCROLL)
    local mLvl = player:getMainLvl()

    if
        dampScroll == QUEST_AVAILABLE and
        player:getFameLevel(xi.quest.fame_area.NORG) >= 3 and
        mLvl >= 10 and
        player:hasItem(xi.items.DAMP_SCROLL)
    then
        player:startEvent(31, xi.items.DAMP_SCROLL) -- Start the quest
    elseif dampScroll == QUEST_ACCEPTED then
        player:startEvent(32) -- Reminder Dialogue
    else
        player:startEvent(85)
    end
end

entity.onEventUpdate = function(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 31 then
        player:addQuest(xi.quest.log_id.OUTLANDS, xi.quest.id.outlands.SECRET_OF_THE_DAMP_SCROLL)
    end
end

return entity
