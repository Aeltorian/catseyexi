-----------------------------------
-- Area: Bastok_Mines
--  NPC: Faustin
-- Ronfaure Regional Merchant
-----------------------------------
local ID = zones[xi.zone.BASTOK_MINES]
require("scripts/globals/events/harvest_festivals")
-----------------------------------
local entity = {}

entity.onTrade = function(player, npc, trade)
    onHalloweenTrade(player, trade, npc)
end

entity.onTrigger = function(player, npc)
    if GetRegionOwner(xi.region.RONFAURE) ~= xi.nation.BASTOK then
        player:showText(npc, ID.text.FAUSTIN_CLOSED_DIALOG)
    else
        local stock =
        {
            xi.items.SAN_DORIAN_CARROT,           33,
            xi.items.BUNCH_OF_SAN_DORIAN_GRAPES,  79,
            xi.items.RONFAURE_CHESTNUT,          124,
            xi.items.BAG_OF_SAN_DORIAN_FLOUR,     62,
        }

        player:showText(npc, ID.text.FAUSTIN_OPEN_DIALOG)
        xi.shop.general(player, stock, xi.quest.fame_area.BASTOK)
    end
end

entity.onEventUpdate = function(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
