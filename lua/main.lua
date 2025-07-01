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
	if not cfg.image then
		wml.error "[multihex_image] missing required image= attribute."
	end
	cfg.image = cfg.image.."~NO_TOD_SHIFT()"
	for i, loc in ipairs(locs) do
		add_overlay(loc[1], loc[2], cfg)

		local width, height = filesystem.image_size(cfg.image)
		if width<=72 and height <=72 then else
			local n_hex, ne_hex, se_hex, s_hex, sw_hex, nw_hex = wesnoth.map.get_adjacent_hexes(loc)
			local ref_image = cfg.image
			cfg.image = "misc/blank-hex.png~BLIT("..ref_image.."~CROP("..tostring(width/2-36)..",0,72,"..tostring(height/2-36).."),0,"..tostring(72-(height/2-36))
			add_overlay(n_hex[1], n_hex[2], cfg)
			cfg.image = "misc/blank-hex.png~BLIT("..ref_image.."~CROP("..tostring(width/2+18)..","..tostring(math.max(0,height/2-72))..","..tostring(width/2-18)..","..tostring(height/2).."),0,"..tostring(math.max(0,72-height/2))
			add_overlay(ne_hex[1], ne_hex[2], cfg)
			cfg.image = "misc/blank-hex.png~BLIT("..ref_image.."~CROP("..tostring(width/2+18)..","..tostring(height/2)..","..tostring(width/2-18)..","..tostring(math.min(height/2,72)).."),0,0)"
			add_overlay(se_hex[1], se_hex[2], cfg)
			cfg.image = "misc/blank-hex.png~BLIT("..ref_image.."~CROP("..tostring(width/2-36)..","..tostring(height/2+36)..",72,"..tostring(height/2-36).."),0,0)"
			add_overlay(s_hex[1], s_hex[2], cfg)
			cfg.image = "misc/blank-hex.png~BLIT("..ref_image.."~CROP(0,"..tostring(height/2)..","..tostring(width/2-18)..","..tostring(math.min(height/2,72)).."),"..tostring(72-(width/2-18))..",0)"
			add_overlay(sw_hex[1], sw_hex[2], cfg)
			cfg.image = "misc/blank-hex.png~BLIT("..ref_image.."~CROP(0,"..tostring(math.max(0,height/2-72))..","..tostring(width/2-18)..","..tostring(math.min(height/2,72)).."),"..tostring(72-(width/2-18))..","..tostring(math.max(0,72-height/2))
			add_overlay(nw_hex[1], nw_hex[2], cfg)
		end 
	end

	local redraw = cfg.redraw
	if redraw == nil then redraw = true end
	if redraw then wml_actions.redraw {} end
	if cfg.write_name then wml.variables[cfg.write_name] = cfg.name end
	return cfg.name
end