local function normalize(mouse_vector : Vector2, gui_abs_position : Vector2, gui_abs_size : Vector2)
	-- normalize mouse coords to 0-1 based on the gui
	local min_x = gui_abs_position.X
	local max_x = min_x + gui_abs_size.X

	local min_y = gui_abs_position.Y
	local max_y = min_y + gui_abs_size.Y

	return Vector2.new(
		math.clamp((mouse_vector.X - min_x)/(max_x - min_x),0,1),
		math.clamp((mouse_vector.Y - min_y)/(max_y - min_y),0,1)
	)
end

return normalize