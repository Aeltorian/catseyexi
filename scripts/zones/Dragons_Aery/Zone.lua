-----------------------------------
-- Zone: Dragons_Aery (154)
-----------------------------------
local ID = require('scripts/zones/Dragons_Aery/IDs')
require('scripts/globals/conquest')
require('scripts/globals/zone')
-----------------------------------
local zone_object = {}

zone_object.onInitialize = function(zone)
    zone:registerRegion(1, -61.164, -1.725, -33.673, -55.521, -1.332, -18.122)
end

zone_object.onConquestUpdate = function(zone, updatetype)
    xi.conq.onConquestUpdate(zone, updatetype)
end

zone_object.onZoneIn = function(player, prevZone)
    local cs = -1

    if player:getXPos() == 0 and player:getYPos() == 0 and player:getZPos() == 0 then
        player:setPos(-60.006, -2.915, -39.501, 202)
    end

    player:PrintToPlayer("NOTICE: A rubber band effect is active to prevent abuse of the survival guide while HNM's are engaged.")
	player:PrintToPlayer("Attempts to circumvent this mechanic are logged and are actionable.")

    return cs
end

zone_object.onRegionEnter = function(player, region)
    if GetMobByID(ID.mob.FAFNIR):isEngaged() or GetMobByID(ID.mob.NIDHOGG):isEngaged() then
        player:setPos(-60.183, -1.121, -37.731)
		print("%s has triggered the rubber band in Dragon's Aery", GetPlayerByName(player))
    end
end

zone_object.onEventUpdate = function(player, csid, option)
end

zone_object.onEventFinish = function(player, csid, option)
end

return zone_object
