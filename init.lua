-- Unified Inventory Plus for Minetest 0.4.8+

local modpath = minetest.get_modpath(minetest.get_current_modname())
local worldpath = minetest.get_worldpath()

unified_inventory_plus = {

	-- Patterns: (Comment unwanted ones & reorder as you wish: buttons are then placed left to right, then up, 6 on a row)
	-- pattern field contains indexes to fill in the craft inventory according to the scheme: (then others for non creatives)
	--
	-- 1 2 3
	-- 4 5 6
	-- 7 8 9
	--
	craft_patterns = {
	{ico="pattern_1.png" , pattern={1}},
	{ico="pattern_4.png" , pattern={1,2,4,5}},
	{ico="pattern_9.png" , pattern={1,2,3,4,5,6,7,8,9}},
	{ico="pattern_3.png" , pattern={1,2,3}},
	{ico="pattern_3b.png", pattern={1,4,7}},
	{ico="pattern_5.png" , pattern={1,3,5,7,9}},
	{ico="pattern_6.png" , pattern={1,4,5,7,8,9}},
	{ico="pattern_6b.png", pattern={1,2,3,4,5,6}},
	{ico="pattern_6c.png", pattern={1,3,4,6,7,9}},
	{ico="pattern_7.png" , pattern={1,2,3,4,5,6,8}},
	{ico="pattern_8.png" , pattern={1,2,3,4,6,7,8,9}},
	},
	
	
}






dofile(modpath.."/functions.lua")

-- Functionalities are independants.
if minetest.settings:get_bool("unified_inventory_plus.enable_craft_all", true) then
	dofile(modpath.."/craft_all.lua")
end

if minetest.settings:get_bool("unified_inventory_plus.enable_craft_organize", true) then
	dofile(modpath.."/craft_organize.lua")
end

if minetest.settings:get_bool("unified_inventory_plus.enable_craft_rotate", true) then
	dofile(modpath.."/craft_rotate.lua")
end
