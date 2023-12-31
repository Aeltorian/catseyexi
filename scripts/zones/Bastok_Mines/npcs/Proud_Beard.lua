-----------------------------------
-- Area: Bastok Mines
--  NPC: Proud Beard
-- Standard Merchant NPC
-----------------------------------
local ID = require("scripts/zones/Bastok_Mines/IDs")
require("scripts/globals/events/harvest_festivals")
require("scripts/globals/shop")
-----------------------------------
local entity = {}

entity.onTrade = function(player, npc, trade)
    onHalloweenTrade(player, trade, npc)
end

entity.onTrigger = function(player, npc)
    local stock =
    {
        12631, 276,    --Hume Tunic
        12632, 276,    --Hume Vest
        12754, 165,    --Hume M Gloves
        12760, 165,    --Hume F Gloves
        12883, 239,    --Hume Slacks
        12884, 239,    --Hume Pants
        13005, 165,    --Hume M Boots
        13010, 165,    --Hume F Boots
        12637, 276,    --Galkan Surcoat
        12758, 165,    --Galkan Bracers
        12888, 239,    --Galkan Braguette
        13009, 165     --Galkan Sandals
    }

    player:showText(npc, ID.text.PROUDBEARD_SHOP_DIALOG)
    xi.shop.general(player, stock)
end

entity.onEventUpdate = function(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
