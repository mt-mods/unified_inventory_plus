-- Clear items in the craft inventory


-- Backup to inject code
unified_inventory_plus.craft_clear = unified_inventory.pages["craft"].get_formspec

local function onload()
	unified_inventory.pages["craft"] = {
	get_formspec = function(player, perplayer_formspec)
		local formspecy = perplayer_formspec.formspec_y + 1
		local formspec = unified_inventory_plus.craft_clear(player, perplayer_formspec).formspec
		formspec = formspec.."image_button[1.25,"..(formspecy)..";0.75,0.75;pattern_clear.png;craft_clear;]"
		return {formspec=formspec}
	end,
}
end

onload()


-- Return items from the craft inventory to the player's inventory
local function craft_clear(player, formname, fields)	
	local player_inv = player:get_inventory()
	local craft_list = player_inv:get_list("craft")
	local remaining_craft_list = craft_list

	for k,v in pairs(craft_list) do
		local type_name = v:get_name()
		local itemdef = minetest.registered_items[type_name]
		-- non-stackable items often have wear / metadata attached that gets lost in the code below
		if itemdef and itemdef.stack_max == 1 then
			if player_inv:room_for_item("main", v) then
				player_inv:add_item("main", v)
				remaining_craft_list[k]:clear()
			end
		elseif(v:get_count() > 0) then
			local nb_left = room_left_for_item(player_inv:get_list("main"), v)
			if(nb_left >= v:get_count()) then
				place_item_in_stacks(player, "main", v:get_name(), v:get_count())
				remaining_craft_list[k]:clear()
			else
				place_item_in_stacks(player, "main", v:get_name(), nb_left)
				remaining_craft_list[k]:set_count(v:get_count() - nb_left)
			end
		end
	end
	
	player_inv:set_list("craft", remaining_craft_list)
end




minetest.register_on_player_receive_fields(function(player, formname, fields)
	--if not formname:match("craft") then return end
	for k, v in pairs(fields) do
		if k:match("craft_clear") then
			craft_clear(player, formname, fields)
		end
	end
end)
