local mod_skyblock = minetest.get_modpath("skyblock")

-- InvRef :room_for_item() does not check for multiple stacks need. That's the purpose of this function
function room_left_for_item(list, item)
	local item_name = item:get_name()
	local room_left = 0
	for k,v in pairs(list) do
		minetest.chat_send_all("")
		if(v:get_name() == item_name) then room_left = room_left + v:get_free_space()
		elseif v:is_empty() then room_left = room_left + item:get_stack_max() end
	end
	return room_left
end



-- Add items to the inventory, splitting in stacks if necessary
-- Have to separate item_name & nb_items instead of using an Itemstack in the case you want to add many not stackable ItemStack (keys, filled buckets...)
function place_item_in_stacks(player, inv_name, item_name, nb_items)
	local player_inv = player:get_inventory()
	assert(player_inv)
	local stack_max = ItemStack(item_name):get_stack_max()

	-- Put a single stack for creative players and split the result for non creatives
	if minetest.get_player_privs(player:get_player_name()).creative and not stack_max == 1 then
		player_inv:add_item(inv_name, ItemStack(item_name.." "..nb_items))
	else
		local nb_stacks = math.floor(nb_items / stack_max)
		local remaining = nb_items % stack_max
		for i=1,nb_stacks do
			player_inv:add_item(inv_name, item_name.." "..stack_max)
		end
		if remaining ~= 0 then player_inv:add_item(inv_name, item_name.." "..remaining) end
	end
	
	-- support skyblock quests
	if mod_skyblock then
		-- track crafting, mimic minetest.register_on_craft as it's bypassed using this function ;)
		for i=1,nb_items do
			skyblock.feats.on_craft(ItemStack(item_name), player)
		end
	end
	
	-- log event!
	minetest.log("action", player:get_player_name().." crafts "..item_name.." "..nb_items)
end
