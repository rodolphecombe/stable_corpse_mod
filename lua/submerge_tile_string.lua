function submerge_tile_string(x,y,do_partial_submerge, y_offset) --TODO remove
	local y_offset=y_offset or 0
	local terrain = wesnoth.current.map[{x,y}]
	local red,green,blue,fade_speed,fade_offset,total_submerge_opacity = 0,0,0,0,0,0
	local water_height

	local terrain_properties = {
		["Chw"] = {water_height = "0.2", red = -60, green = -60, blue = -50, fade_speed = 2.0, fade_offset = 0.3, total_submerge_opacity = 50},
		["Cm"] = {water_height = "0.2", red = -60, green = -60, blue = -50, fade_speed = 2.0, fade_offset = 0.3, total_submerge_opacity = 50},
		["Km"] = {water_height = "0.2", red = -60, green = -60, blue = -50, fade_speed = 2.0, fade_offset = 0.3, total_submerge_opacity = 50},
		["Cme"] = {water_height = "0.2", red = -60, green = -60, blue = -50, fade_speed = 2.0, fade_offset = 0.3, total_submerge_opacity = 50},
		["Kme"] = {water_height = "0.2", red = -60, green = -60, blue = -50, fade_speed = 2.0, fade_offset = 0.3, total_submerge_opacity = 50},
		["Chs"] = {water_height = "0.3", red = -60, green = 0, blue = -20, fade_speed = 5.0, fade_offset = 0.2, total_submerge_opacity = 25},
		["Wo"] = {water_height = "0.8", red = -60, green = -60, blue = -50, fade_speed = 2.0, fade_offset = 0.3, total_submerge_opacity = 50},
		["Ww"] = {water_height = "0.4", red = -60, green = -60, blue = -50, fade_speed = 2.0, fade_offset = 0.3, total_submerge_opacity = 50},
		["Wwf"] = {water_height = "0.2", red = -60, green = -60, blue = -50, fade_speed = 2.0, fade_offset = 0.3, total_submerge_opacity = 50},
		["Ss"] = {water_height = "0.3", red = -60, green = 0, blue = -20, fade_speed = 5.0, fade_offset = 0.2, total_submerge_opacity = 25},
		["Sm"] = {water_height = "0.2", red = 20, green = -5, blue = -30, fade_speed = 4.0, fade_offset = 0.6, total_submerge_opacity = 25},
		["Ai"] = {water_height = "0.3", red = 40, green = 40, blue = 60, fade_speed = 4.0, fade_offset = 0.6, total_submerge_opacity = 25}
	}

	if terrain_properties[terrain] then
		local props = terrain_properties[terrain]
		water_height = props.water_height
		red, green, blue = props.red, props.green, props.blue
		fade_speed = props.fade_speed
		fade_offset = props.fade_offset
		total_submerge_opacity = props.total_submerge_opacity
	else
		return ""
	end

	red,green,blue = red/255.0,green/255.0,blue/255.0

	-- wesnoth.wml_actions.inspect({})
	if not do_partial_submerge then
		return "~O("..total_submerge_opacity.."%)~CS("..red..","..green..","..blue..")"
	else
		local water_line_string= "y<"..y_offset.."+height*("..0.7-water_height..")"

		local function get_sign(value)
			return value < 0 and "(-1)*" or ""
		end

		local red_positive = get_sign(red)
		local green_positive = get_sign(green)
		local blue_positive = get_sign(blue)

		return
		"~CHAN(" ..
		"red *("..water_line_string.." and 1 or "..red.."+max(min((("..1.0 - fade_offset.."-"..red_positive.."(("..y_offset.."+height*("..0.7 - water_height.."))/height)*"..fade_speed..")+(y*"..fade_speed..")/height*"..red.."),"..1 + math.max(red, 0).."),"..1 + math.min(red, 0)..")),"..
		"green *("..water_line_string.." and 1 or "..green.."+max(min((("..1.0 - fade_offset.."-"..green_positive.."(("..y_offset.."+height*("..0.7 - water_height.."))/height)*"..fade_speed..")+(y*"..fade_speed..")/height*".. green.."),"..1 + math.max(green, 0).."),"..1 + math.min(green, 0).."))," ..
		"blue *("..water_line_string.." and 1 or "..blue.."+max(min((("..1.0 - fade_offset.."-"..blue_positive.."(("..y_offset.."+height*("..0.7 - water_height.."))/height)*"..fade_speed..")+(y*"..fade_speed..")/height*".. blue.."),"..1 + math.max(blue, 0).."),"..1 + math.min(blue, 0).."))," ..
		"alpha *("..water_line_string.." and 1 or max((("..1.0 - fade_offset.."+(("..y_offset.."+height*("..0.7 - water_height.."))/height)*"..fade_speed..")-(y*"..fade_speed..")/height),0))" ..
		")"
	end
end