--local utils = wesnoth.require "wml-utils"
local wml_actions = wesnoth.wml_actions

local scenario_items = (wesnoth.require "location_set").create()
local next_item_name = 0

local function add_overlay(x, y, cfg)

	if not cfg.name then
		cfg.name = "item_" .. tostring(next_item_name)
		next_item_name = next_item_name + 1
	end

	wesnoth.interface.add_hex_overlay(x, y, cfg)
	local items = scenario_items:get(x, y)
	if not items then
		items = {}
		scenario_items:insert(x, y, items)
	end
	table.insert(items,
		{
			x = x, y = y,
			image = cfg.image,
			halo = cfg.halo,
			team_name = cfg.team_name,
			filter_team = cfg.filter_team,
			visible_in_fog = cfg.visible_in_fog,
			submerge = cfg.submerge,
			redraw = cfg.redraw,
			name = cfg.name,
			z_order = cfg.z_order,
			wml.tag.variables(wml.get_child(cfg, "variables") or {}),
		})
end

function wml_actions.multihex_image(cfg)
	local locs = wesnoth.map.find(cfg)
	cfg = wml.parsed(cfg)
	if not cfg.image and not cfg.halo then
		wml.error "[multihex_image] missing required image= attribute."
	end
	for i, loc in ipairs(locs) do
		add_overlay(loc[1], loc[2], cfg)

		local width, height = filesystem.image_size(cfg.image)
		if width<=72 and height <=72 then else
			local nw_hex, sw_hex, s_hex, se_hex, ne_hex, n_hex
			wml.tag.store_locations { wml.tag.filter_adjacent_location {x = loc[1], y = loc[2], adjacent = "se"}, variable = nw_hex}
			if nw_hex == nil then wesnoth.interface.add_chat_message("nw_hex is nil") end
			wesnoth.interface.add_chat_message(wesnoth.as_text(nw_hex))
		end 
	end

	local redraw = cfg.redraw
	if redraw == nil then redraw = true end
	if redraw then wml_actions.redraw {} end
	if cfg.write_name then wml.variables[cfg.write_name] = cfg.name end
	return cfg.name
end