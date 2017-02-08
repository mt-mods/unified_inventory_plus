-- Unified Inventory Plus for Minetest 0.4.8+

local modpath = minetest.get_modpath(minetest.get_current_modname())
local worldpath = minetest.get_worldpath()

unified_inventory_plus = {}


dofile(modpath.."/functions.lua")

-- Functionalities are independants.
-- Comment the following lines to disable those you don't want
dofile(modpath.."/craft_all.lua")
dofile(modpath.."/craft_organize.lua")
