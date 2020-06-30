-- Organize items in the craft inventory following a pattern:


-- Backup to inject code
unified_inventory_plus.craft_organize = unified_inventory.pages["craft"].get_formspec

local function onload()
	unified_inventory.pages["craft"] = {
	get_formspec = function(player, perplayer_formspec)
		local formspecy = perplayer_formspec.formspec_y
		local formspec = unified_inventory_plus.craft_organize(player, perplayer_formspec).formspec
		for i,v in ipairs(unified_inventory_plus.craft_patterns) do
			formspec = formspec.."image_button["..(2.0 + 0.5 * ((i-1)%6))..","..(formspecy - 0.5 * math.ceil(i/6))..";0.5,0.5;"..v.ico..";craft_organize_"..i..";]"
		end
		return {formspec=formspec}
	end,
}
end

onload()



-- Return if there is only one type and the item type name in the StackItems list (nil if none)
local function get_type_infos(craft_list)
	local item = nil
	for j=0,2 do
		for i=1,3 do
			if not craft_list[3*j+i]:is_empty() then
				if item == nil then item = craft_list[3*j+i]
				elseif item:get_name() ~= craft_list[3*j+i]:get_name() then return false, ""
				end
			end
		end
	end
	return true, (item ~= nil) and item:get_name() or nil
end

-- Sum the craft_list items
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

	local itemdef = minetest.registered_items[type_name]
	if itemdef and itemdef.stack_max == 1 then
		-- disallow non-stackable items
		-- most of them have assiciated metadata which gets cleared in the reordering
		minetest.chat_send_player(player_name, "You can only organize stackable items.")
		return
	end


	-- Don't exceed 9*99 for non creative players. It shouldn't happen but avoids potential losses then
	local total_amount = get_total_amount(craft_list)
	if not is_creative and total_amount > 891 then minetest.chat_send_player(player_name, "There are too many items to organize ! Have less than 9 x 99 items.") return end

	local res = {ItemStack(type_name),ItemStack(type_name),ItemStack(type_name),ItemStack(type_name),ItemStack(type_name),ItemStack(type_name),ItemStack(type_name),ItemStack(type_name),ItemStack(type_name)}
	for i=1,9 do res[i]:set_count(0) end -- Doing this because using empty ItemStack in list constructor crashes the game :S

	local pattern = unified_inventory_plus.craft_patterns[tonumber(pattern_id)].pattern
	local nb_stacks = 0
	for i in pairs(pattern) do nb_stacks = nb_stacks + 1 end
	local stack_size = math.floor(total_amount / nb_stacks)
	if not is_creative then stack_size = math.min(stack_size, ItemStack(type_name):get_stack_max()) end -- limit stacks to get_stack_max() for non creatives
	local remaining = total_amount - nb_stacks * stack_size -- no % nb_stacks if limit: remaining could be greater than a stack

	for i=1,nb_stacks do
		res[pattern[i]]:add_item(type_name.." "..stack_size)
	end

	player_inv:set_list("craft", res)
	place_item_in_stacks(player, "craft", type_name, remaining)
end




minetest.register_on_player_receive_fields(function(player, formname, fields)
	--if not formname:match("craft") then return end
	for k, v in pairs(fields) do
		if k:match("craft_organize_") then
			craft_organize(player, formname, fields)
			return
		end
	end
end)
