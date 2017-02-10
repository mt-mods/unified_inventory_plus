-- Rotate items in the craft inventory


-- Backup to inject code
unified_inventory_plus.craft_rotate = unified_inventory.pages["craft"].get_formspec

local function onload()
	unified_inventory.pages["craft"] = {
	get_formspec = function(player, perplayer_formspec)
		local formspecy = perplayer_formspec.formspec_y
		local formspec = unified_inventory_plus.craft_rotate(player, perplayer_formspec).formspec
		formspec = formspec.."image_button[1.25,"..(formspecy)..";0.75,0.75;pattern_rotate.png;craft_rotate;]"
		return {formspec=formspec}
	end,
}
end

onload()


-- Rotate items in the craft inventory
local function craft_rotate_cw(player, formname, fields)	
	local player_inv = player:get_inventory()
	local craft_list = player_inv:get_list("craft")

	-- Rotate corners
	local stack = craft_list[1]
	craft_list[1] = craft_list[7]
	craft_list[7] = craft_list[9]
	craft_list[9] = craft_list[3]
	craft_list[3] = stack

	-- Rotate middle ones
	stack = craft_list[2]
	craft_list[2] = craft_list[4]
	craft_list[4] = craft_list[8]
	craft_list[8] = craft_list[6]
	craft_list[6] = stack
	
	player_inv:set_list("craft", craft_list)
end




minetest.register_on_player_receive_fields(function(player, formname, fields)
	--if not formname:match("craft") then return end
	for k, v in pairs(fields) do
		if k:match("craft_rotate") then
			craft_rotate_cw(player, formname, fields)
		end
	end
end)
