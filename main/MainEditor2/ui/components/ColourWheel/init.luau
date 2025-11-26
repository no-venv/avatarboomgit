type void = nil;
local CENTRE = Vector2.new(0.5, 0.5)
local function normalize(mouse_vector: Vector2, gui_abs_position: Vector2, gui_abs_size: Vector2)
	-- normalize mouse coords to 0-1 based on the gui
	local min_x = gui_abs_position.X
	local max_x = min_x + gui_abs_size.X

	local min_y = gui_abs_position.Y
	local max_y = min_y + gui_abs_size.Y

	return Vector2.new(
		math.clamp((mouse_vector.X - min_x) / (max_x - min_x), 0, 1),
		math.clamp((mouse_vector.Y - min_y) / (max_y - min_y), 0, 1)
	)
end
local function percentage(x, a, b)
	return math.abs(x - a) / (b - a)
end
local function create_selected_cursor(parent: Instance?): Frame
	local frame = Instance.new("Frame")
	frame.Visible = true
	frame.Transparency = 1
	frame.Size = UDim2.new(0, 16, 0, 16)
	frame.Parent = parent

	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio = 1
	aspect.Parent = frame

	local ui_corner = Instance.new("UICorner")
	ui_corner.CornerRadius = UDim.new(0, 48)
	ui_corner.Parent = frame

	local ui_border = Instance.new("UIStroke")
	ui_border.Parent = frame
	ui_border.Thickness = 2

	local ui_border_white = Instance.new("UIStroke")
	ui_border_white.Parent = frame
	ui_border_white.Color = Color3.new(1, 1, 1)
	ui_border_white.Thickness = 2
	ui_border_white.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	return frame
end
local function base_mouse_drag(gui: GuiObject, pos_changed: (Vector2) -> void)
	local should_update
	gui.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			should_update = true
			local release_event
			release_event = input.Changed:Connect(function(property: string)
				if input.UserInputState == Enum.UserInputState.End then
					should_update = false
					release_event:Disconnect()
				end
			end)
		end
	end)

	local mutex = false
	gui.InputChanged:Connect(function(input: InputObject)
		if not should_update or mutex then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			mutex = true
			local release_event
			release_event = input.Changed:Connect(function(property: string)
				if not should_update then
					release_event:Disconnect()
					mutex = false
				end

				if should_update then
					pos_changed(Vector2.new(input.Position.X, input.Position.Y))
				end
			end)
		end
	end)
end
return function(parent: Instance)
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 1, 0)
	do
		local v_layout = Instance.new("UIListLayout")
		v_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		v_layout.VerticalFlex = Enum.UIFlexAlignment.Fill
		v_layout.Padding = UDim.new(0, 16)
		v_layout.SortOrder = Enum.SortOrder.LayoutOrder
		v_layout.Parent = container
	end

	local hs_button = Instance.new("ImageButton")
	do
		local ratio_const = Instance.new("UIAspectRatioConstraint")
		ratio_const.AspectRatio = 1
		ratio_const.Parent = hs_button
		hs_button.BackgroundTransparency = 1
		hs_button.Size = UDim2.new(1, 0, 1, 0)
		hs_button.ImageContent = Content.fromAssetId(135185910974207)
		hs_button.Parent = container
	end
	local v_button = Instance.new("TextButton")
	do
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = v_button
		local gradient = Instance.new("UIGradient")
		gradient.Color = ColorSequence.new(Color3.new(), Color3.new(1, 1, 1))
		gradient.Parent = v_button
		local padding = Instance.new("UIPadding")
		padding.PaddingLeft = UDim.new(0, 16)
		padding.PaddingRight = UDim.new(0, 16)
		padding.Parent = v_button
		local size_const = Instance.new("UISizeConstraint")
		size_const.MaxSize = Vector2.new(math.huge, 32)
		size_const.MinSize = Vector2.new(0, 32)
		size_const.Parent = v_button
		v_button.AutoButtonColor = false
		v_button.TextTransparency = 1
		v_button.Size = UDim2.new(1, 0, 0, 32)
		v_button.Parent = container
	end
	container.Parent = parent
	local H = 0
	local S = 0
	local V = 1
	local hs_cursor = create_selected_cursor(hs_button)
	local v_cursor = create_selected_cursor(v_button)
	v_cursor.AnchorPoint = Vector2.new(0.5, 0.5)
	local self
	self = {
		instance = container,
		on_colour = function(updated_colour: Color3)
			return
		end,
		set_colour = function(colour: Color3)
			local h, s, v = colour:ToHSV()
			H = h
			S = s
			V = v
			h *= 360
			h = math.rad(h)
			local x = math.cos(h)
			local y = math.sin(h)
			x = percentage(x, -1, 1)
			y = percentage(y, -1, 1)
			x = math.lerp(0.5, x, s)
			y = math.lerp(0.5, y, s)
			hs_cursor.Position = UDim2.new(x, 0, y, 0)
			v_cursor.Position = UDim2.new(v, 0, 0.5, 0)

			self.on_colour(colour)
		end,
	}

	local gx, gy = 0, 0
	local function hs_mouse_event(x: number, y: number)
		gx = x
		gy = y
		local norm = normalize(Vector2.new(x, y), hs_button.AbsolutePosition, hs_button.AbsoluteSize)
		hs_cursor.Position = UDim2.new(norm.X, 0, norm.Y, 0)
		hs_cursor.Visible = true
		local diff = norm - CENTRE
		H = (180 - math.deg(math.atan2(diff.Y, -diff.X))) / 360
		S = diff.Magnitude * 2
		H = math.clamp(H, 0, 1)
		S = math.clamp(S, 0, 1)
		self.on_colour(Color3.fromHSV(H, S, V))
	end

	local function v_mouse_event(x: number, y: number)
		gx = x
		gy = y
		local norm = normalize(Vector2.new(x, y), v_button.AbsolutePosition, v_button.AbsoluteSize)
		v_cursor.Visible = true
		v_cursor.Position = UDim2.new(norm.X, 0, 0.5, 0)
		V = norm.X
		self.on_colour(Color3.fromHSV(H, S, V))
	end

	base_mouse_drag(hs_button, function(a0: Vector2)
		hs_mouse_event(a0.X, a0.Y)
	end)
	base_mouse_drag(v_button, function(a0: Vector2)
		v_mouse_event(a0.X, a0.Y)
	end)

	self.set_colour(Color3.new(1, 1, 1))
	return self
end
