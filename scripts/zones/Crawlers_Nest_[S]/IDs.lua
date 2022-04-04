-----------------------------------
-- Area: Crawlers_Nest_[S]
-----------------------------------
require("scripts/globals/zone")
-----------------------------------

zones = zones or {}

zones[xi.zone.CRAWLERS_NEST_S] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED = 6906, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED           = 6912, -- Obtained: <item>.
        GIL_OBTAINED            = 6913, -- Obtained <number> gil.
        KEYITEM_OBTAINED        = 6915, -- Obtained key item: <keyitem>.
        CARRIED_OVER_POINTS     = 7523, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY = 7524, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!<space>
        LOGIN_NUMBER            = 7525, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        ITEM_DELIVERY_DIALOG    = 7685, -- Hello! Any packages to sendy-wend?
        COMMON_SENSE_SURVIVAL   = 8650, -- It appears that you have arrived at a new survival guide provided by the Servicemen's Mutual Aid Network. Common sense dictates that you should now be able to teleport here from similar tomes throughout the world.
    },
    mob =
    {
        MORILLE_MORTELLE_PH =
        {
            [17477636] = 17477640, -- 61 0 -4
        },
    },
    npc =
    {
    },
}

return zones[xi.zone.CRAWLERS_NEST_S]
