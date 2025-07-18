function wesnoth.wml_actions.multihex_image(cfg)
	local locs = wesnoth.map.find(cfg)
	cfg = wml.parsed(cfg)

	if not cfg.image then
		wml.error "[multihex_image] missing required image= attribute."
	end

	local submerge, redraw = cfg.submerge, cfg.redraw
	cfg.submerge = 0
	cfg.redraw = false

	local width, height = filesystem.image_size(cfg.image)
	local ref_image = cfg.image

	local function set_hex_image(hex, crop_x, crop_y, crop_w, crop_h, offset_x, offset_y)
		cfg.x, cfg.y = hex[1], hex[2]
		if submerge then
			cfg.image = "misc/blank-hex.png~BLIT("..ref_image..submerge_tile_string(cfg.x,cfg.y,true,height/3.).."~CROP("..crop_x..","..crop_y..","..crop_w..","..crop_h.."),"..(offset_x or 0)..","..(offset_y or 0)..")"
		else
			cfg.image = "misc/blank-hex.png~BLIT("..ref_image.."~CROP("..crop_x..","..crop_y..","..crop_w..","..crop_h.."),"..(offset_x or 0)..","..(offset_y or 0)..")"
		end
		wesnoth.wml_actions.item(cfg)
	end

	for _, loc in ipairs(locs) do
		local c_hex = wesnoth.map.get(loc)  
		local n_hex, ne_hex, se_hex, s_hex, sw_hex, nw_hex = wesnoth.map.get_adjacent_hexes(loc)

		set_hex_image(c_hex,width/2-36,height/2-36,72,72)
		set_hex_image(ne_hex, width/2 + 18, math.max(0, height/2 - 72), width/2 - 18, height/2, 0, math.max(0, 72 - height/2))
		set_hex_image(nw_hex, 0, math.max(0, height/2 - 72), width/2 - 18, math.min(height/2, 72), 72 - (width/2 - 18), math.max(0, 72 - height/2))
		set_hex_image(se_hex, width/2 + 18, height/2, width/2 - 18, math.min(height/2, 72))
		set_hex_image(sw_hex, 0, height/2, width/2 - 18, math.min(height/2, 72), 72 - (width/2 - 18))
		if height>72 then
			set_hex_image(n_hex,width/2-36,0,72,height/2-36,0,108-height/2)
			set_hex_image(s_hex, width/2-36, height/2+36, 72, height/2-36)
		end
	end

	if redraw then 
		wesnoth.wml_actions.redraw{}
	end
end