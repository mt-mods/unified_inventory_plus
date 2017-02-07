-- Organize items in the craft inventory following a pattern:
-- 1 Compact stacks
-- 3 Fill the first line
-- 4 Fill a square
-- 6 Fill a 'stair pattern'
-- 8 Fill a circle
-- 9 Equal repartition in the grid


local S = unified_inventory.gettext
local F = unified_inventory.fgettext

-- Backup to inject code
unified_inventory_plus.craft_organize = unified_inventory.pages["craft"].get_formspec

local function onload()
	unified_inventory.pages["craft"] = {
	get_formspec = function(player, perplayer_formspec)
		local formspecy = perplayer_formspec.formspec_y
		local formspec = unified_inventory_plus.craft_organize(player, perplayer_formspec).formspec
		--formspec = formspec.."label[3.0,"..(formspecy - 2.0)..";Organize:]"
		formspec = formspec.."image_button[2.0,"..(formspecy - 1.0)..";1.0,1.0;1.png;craft_organize_1;]"
		formspec = formspec.."image_button[3.0,"..(formspecy - 1.0)..";1.0,1.0;3.png;craft_organize_3;]"
		formspec = formspec.."image_button[4.0,"..(formspecy - 1.0)..";1.0,1.0;4.png;craft_organize_4;]"
		formspec = formspec.."image_button[5.0,"..(formspecy - 1.0)..";1.0,1.0;6.png;craft_organize_6;]"
		formspec = formspec.."image_button[6.0,"..(formspecy - 1.0)..";1.0,1.0;8.png;craft_organize_8;]"
		formspec = formspec.."image_button[7.0,"..(formspecy - 1.0)..";1.0,1.0;9.png;craft_organize_9;]"
		return {formspec=formspec}
	end,
}
end

onload()


-- inventory indexes to fill (then others for non creatives)
local craft_patterns = {
["1"]={1},
["3"]={1,2,3},
["4"]={1,2,4,5},
["6"]={1,4,5,7,8,9},
["8"]={1,2,3,4,6,7,8,9},
["9"]={1,2,3,4,5,6,7,8,9}
}


-- Return if there is only one type and the item type name in the StackItems list.
local function get_type_infos(craft_list)
	local item = nil
	for j=0,2 do
		for i=1,3 do
			if not craft_list[3*j+i]:is_empty() then
				if item == nil then item = craft_list[3*j+i]
				elseif item:get_name() ~= craft_list[3*j+i]:get_name() then return false, item:get_name()
				end
			end
		end
	end
	return true, (item ~= nil) and item:get_name() or nil
end

local function get_total_amount(craft_list)
	local nb = 0
	for j=0,2 do
		for i=1,3 do
			nb = nb + craft_list[3*j+i]:get_count()
		end
	end
	return nb
end


-- Organize items in the craft inventory following a pattern
local function craft_organize(player, formname, fields)	
	local pattern_id
	for k, v in pairs(fields) do
		pattern_id = k:match("craft_organize_(.*)")
		if pattern_id then break end
	end
	if not pattern_id then return end

	local player_inv = player:get_inventory()
	assert(player_inv)
	local player_name = player:get_player_name()
	local craft_list = player_inv:get_list("craft")
	local is_creative = minetest.get_player_privs(player_name).creative
	
	-- Organize only on 1 type of item
	local only_one_type, type_name = get_type_infos(craft_list)
	if not type_name then return end -- craft is empty
	if not only_one_type then minetest.chat_send_player(player_name, "You can only organize one type of item.") return end

	-- Don't exceed 9*99 for non creative players (it shouldn't but who knows ...)
	local total_amount = get_total_amount(craft_list)
	if not is_creative and total_amount > 891 then minetest.chat_send_player(player_name, "There are too many items to organize ! Have less than 9 x 99 items.") return end

	local res = {ItemStack(type_name),ItemStack(type_name),ItemStack(type_name),ItemStack(type_name),ItemStack(type_name),ItemStack(type_name),ItemStack(type_name),ItemStack(type_name),ItemStack(type_name)}
	for i=1,9 do res[i]:set_count(0) end -- doing this cause empty ItemStack constructor in list crashes the game :S
	
	local nb_stacks = tonumber(pattern_id)
	local stack_size = math.floor(total_amount / nb_stacks)
	if not is_creative then stack_size = math.min(stack_size, ItemStack(type_name):get_stack_max()) end -- limit stacks to get_stack_max() for non creatives
	local remaining = total_amount - nb_stacks * stack_size -- no % nb_stacks if limit
	
	for i=1,nb_stacks do
		res[craft_patterns[pattern_id][i]]:add_item(type_name.." "..stack_size)
	end
	
	player_inv:set_list("craft", res)
	player_inv:add_item("craft", type_name.." "..remaining)
end




minetest.register_on_player_receive_fields(function(player, formname, fields)
	for k, v in pairs(fields) do
		if k:match("craft_organize_") then
			craft_organize(player, formname, fields)
			return
		end
	end
end)
