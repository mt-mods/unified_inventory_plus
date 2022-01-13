local S = minetest.get_translator("unified_inventory")
local F = minetest.formspec_escape
local has_stamina = minetest.global_exists("stamina")
local ui = unified_inventory
local uip = unified_inventory_plus

-- Backup to inject code
uip.craft_all = ui.pages["craft"].get_formspec

ui.pages["craft"] = {
	get_formspec = function(player, perplayer_formspec)
		local formspec = uip.craft_all(player, perplayer_formspec).formspec
		formspec = formspec ..
				string.format("image[%f,%f;%f,%f;ui_crafting_long_arrow.png]",
						perplayer_formspec.craft_arrow_x,
						perplayer_formspec.craft_y,
						ui.imgscale,
						ui.imgscale * 3) ..
				string.format("button[%f,%f;%f,%f;craft_craftall;%s]",
						perplayer_formspec.craft_arrow_x + 0.23,
						perplayer_formspec.craft_y + 1.50,
						perplayer_formspec.btn_size,
						perplayer_formspec.btn_size,
						F(S("All")))
		return { formspec = formspec }
	end,
}

-- I don't get what is this width (for instance 3 to craft a sandstone and not 2),
-- so I determine it by comparing the result
local function infer_width(list, expected)
	if not expected or expected:is_empty() then
		return nil
	end
	local width = nil
	for i = 1, 3 do
		local result, remaining_stack = minetest.get_craft_result({ method = "normal", width = i, items = list })
		if result.item:to_string() == expected:to_string() then
			width = i
			break
		end
	end
	if width == nil then
		minetest.log("warning", "[unified_inventory_plus] Can't infer recipe width for " .. expected:to_string())
	end
	return width
end

-- Craft max possible items and put the result in the main inventory
local function craft_craftall(player, formname, fields)
	local player_inv = player:get_inventory()
	local player_name = player:get_player_name()
	local craft_list = player_inv:get_list("craft")
	local expected_result = player_inv:get_stack("craftpreview", 1)
	local craft_width = infer_width(craft_list, expected_result)
	if not craft_width then
		return
	end

	local num_crafted = 0
	-- don't modify player's inventory until end, in case something goes wrong (e.g. crash)
	local tmp_inv_name = ("uip_tmp_%s"):format(player_name)
	local tmp_inv = minetest.create_detached_inventory(tmp_inv_name, {}, player_name)
	tmp_inv:set_size("main", player_inv:get_size("main"))
	tmp_inv:set_list("main", player_inv:get_list("main"))
	while true do
		local output, decremented_input = minetest.get_craft_result({
			method = "normal",
			width = craft_width,
			items = craft_list,
		})

		if output.item:get_name() ~= expected_result:get_name() then
			break
		end

		local added = {}
		if tmp_inv:room_for_item("main", output.item) then
			tmp_inv:add_item("main", output.item)  -- should be no remainder, ignore it
			table.insert(added, output.item)
		else
			break
		end
		local all_added = true
		for _, replacement_stk in ipairs(output.replacements) do
			if tmp_inv:room_for_item("main", replacement_stk) then
				tmp_inv:add_item("main", replacement_stk)  -- should be no remainder, ignore it
				table.insert(added, replacement_stk)
			else
				all_added = false
				break
			end
		end

		if not all_added then
			for _, stk in ipairs(added) do
				tmp_inv:remove_item("main", stk)  -- should be no remainder, ignore it
			end
			break
		end

		if has_stamina and stamina.exhaust_player then
			stamina.exhaust_player(player, stamina.settings.exhaust_craft, stamina.exhaustion_reasons.craft)
		end

		craft_list = decremented_input.items

		num_crafted = num_crafted + 1
	end

	player_inv:set_list("craft", craft_list)
	player_inv:set_list("main", tmp_inv:get_list("main"))

	minetest.remove_detached_inventory(tmp_inv_name)

	minetest.log("action", player:get_player_name() .. " crafts " .. expected_result:get_name() .. " " .. num_crafted)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	--if not formname:match("craft") then return end
	for k, v in pairs(fields) do
		if k:match("craft_craftall") then
			craft_craftall(player, formname, fields)
			return
		end
	end
end)
