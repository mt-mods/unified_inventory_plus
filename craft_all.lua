local S = unified_inventory.gettext
local F = unified_inventory.fgettext

-- Backup to inject code
unified_inventory_plus.craft_all = unified_inventory.pages["craft"].get_formspec

local function onload()
	unified_inventory.pages["craft"] = {
	get_formspec = function(player, perplayer_formspec)
		local formspecy = perplayer_formspec.formspec_y
		local formspec = unified_inventory_plus.craft_all(player, perplayer_formspec).formspec
		formspec = formspec.."button[5.15,  "..(formspecy + 1.18)..";0.8,0.6;craft_craftall;All]"
		return {formspec=formspec}
	end,
}
end

onload()


-- Determine the minimal size occupied by the ingredients in the craft inventory
--local function get_recipe_width(list)
--	local mini = 3
--	local maxi = 0
--	for j = 0, 2 do
--		for i = 1, 3 do
--			if not list[3*j+i]:is_empty() then
--				if mini > i then mini = i end
--				if maxi < i then maxi = i end
--			end
--		end
--	end
--	if mini > maxi then return 0 end
--	return maxi - mini + 1
--end

-- The previous function works as expected but that s not what expects get_craft_result.
-- I don t get what is this width (for instance 3 to craft a sandstone and not 2), so I determine it by comparing the result
local function infer_width(list, expected)
	if not expected or expected:is_empty() then return nil end
	local width = nil
	for i = 1,3 do
		local result, remaining_stack = minetest.get_craft_result({ method = "normal", width = i, items = list})
		if result.item:to_string() == expected:to_string() then width = i break end
	end
	if width == nil then print("Can't infer recipe width for "..expected:to_string()) end
	return width
end

-- Craft max possible items and put the result in the main inventory
local function craft_craftall(player, formname, fields)		
	local player_inv = player:get_inventory()
	assert(player_inv)
	local craft_list = player_inv:get_list("craft")
	local craft_width = infer_width(craft_list, player_inv:get_stack("craftpreview", 1))
	if craft_width == nil then return end

	-- While there are ingredients & room in the inventory, craft !
	local tmp_result, tmp_inv = minetest.get_craft_result({ method = "normal", width = craft_width, items = craft_list})
	local nb_res, result, decremented_input = 0, tmp_result, craft_list
	if not player_inv:room_for_item("main", tmp_result.item) then return end
	while not tmp_result.item:is_empty() and player_inv:room_for_item("main", tmp_result.item:get_name().." "..nb_res + tmp_result.item:get_count()) and nb_res + tmp_result.item:get_count() <= tmp_result.item:get_stack_max() do
		nb_res = nb_res + tmp_result.item:get_count()
		decremented_input = tmp_inv
		tmp_result, tmp_inv = minetest.get_craft_result({ method = "normal", width = craft_width, items = decremented_input.items})
	end
	player_inv:add_item("main", result.item:get_name().." "..nb_res)
	player_inv:set_list("craft", decremented_input.items)
end




minetest.register_on_player_receive_fields(function(player, formname, fields)
	for k, v in pairs(fields) do
		if k:match("craft_craftall") then
			craft_craftall(player, formname, fields)
			return
		end
	end
end)
