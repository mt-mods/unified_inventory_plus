-- Unified Inventory Plus for Minetest 0.4.8+

local modpath = minetest.get_modpath(minetest.get_current_modname())
local worldpath = minetest.get_worldpath()

unified_inventory_plus = {

	-- Patterns: (Comment unwanted ones & reorder on your wish: buttons are placed left to right, then up each 6)
	-- pattern field contains indexes to fill in the craft inventory according to the scheme: (then others for non creatives)
	--
	-- 1 2 3
	-- 4 5 6
	-- 7 8 9
	--
	craft_patterns = {
	{ico="pattern_1.png" , pattern={1}},
	{ico="pattern_9.png" , pattern={1,2,3,4,5,6,7,8,9}},
	{ico="pattern_4.png" , pattern={1,2,4,5}},
	{ico="pattern_8.png" , pattern={1,2,3,4,6,7,8,9}},
	{ico="pattern_5.png" , pattern={1,3,5,7,9}},
	{ico="pattern_7.png" , pattern={1,2,3,4,5,6,8}},
	{ico="pattern_3.png" , pattern={1,2,3}},
	{ico="pattern_3b.png", pattern={1,4,7}},
	{ico="pattern_6.png" , pattern={1,4,5,7,8,9}},
	{ico="pattern_6b.png", pattern={1,2,3,4,5,6}},
	},
	
	
}






dofile(modpath.."/functions.lua")

-- Functionalities are independants.
-- Comment the following lines to disable those you don't want
dofile(modpath.."/craft_all.lua")
dofile(modpath.."/craft_organize.lua")
