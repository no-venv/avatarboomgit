local InputService = game:GetService("UserInputService")
local lune = require("@self/../lune_ui")
local viewport_frame = require("@self/ViewportFrame")
local part_to_body_colour = {
	Head = "HeadColor3",
	["Left Arm"] = "LeftArmColor3",
	["Left Leg"] = "LeftLegColor3",
	["Right Arm"] = "RightArmColor3",
	["Right Leg"] = "RightLegColor3",
	HumanoidRootPart = "TorsoColor3",
	Torso = "TorsoColor3",
}

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

local function create_selected_cursor(parent: Instance?): Frame
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.zero
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

local function RaycastInViewportFrame(viewportFrame, x, y, raycastDistance, raycastParams)
	local camera = viewportFrame.CurrentCamera
	local worldModel = viewportFrame:FindFirstChildWhichIsA("WorldModel")
	local mousePosition = Vector2.new(x, y) - viewportFrame.AbsolutePosition -- account for viewportframe offset
	local relativePosition = ((mousePosition - (viewportFrame.AbsoluteSize / 2)) * Vector2.new(1, -1))
		/ (viewportFrame.AbsoluteSize / 2) -- get the relative position of the click with center of viewportFrame as origin: -1 is left/bottom and 1 is right/top for X and Y respectively
	local projectedY = math.tan(math.rad(camera.FieldOfView) / 2) * raycastDistance -- the projected height of a 2D frame raycastDistance studs from the camera with same aspect ratio
	local projectedX = projectedY * (viewportFrame.AbsoluteSize.X / viewportFrame.AbsoluteSize.Y) -- projected width from aspect ratio
	local projectedPosition = Vector2.new(projectedX, projectedY) * relativePosition -- the projected position of the input on the similar frame
	local worldPosition = (camera.CFrame * CFrame.new(projectedPosition.X, projectedPosition.Y, -raycastDistance)).Position -- the 3d position of said projected position
	return worldModel:Raycast(
		camera.CFrame.Position,
		(worldPosition - camera.CFrame.Position).Unit * raycastDistance,
		raycastParams
	)
end

local function set_rig_colour(rig: Model, colour: Color3, target: string | "All")
	local body_colours: BodyColors = rig:FindFirstChild("Body Colors") :: BodyColors
	if target == "All" then
		for _, part in rig:GetChildren() do
			if part:IsA("BasePart") then
				body_colours[part_to_body_colour[part.Name]] = colour
			end
		end
	else
		body_colours[part_to_body_colour[target]] = colour
	end
end

return function(parent: Instance)
	local viewport_clone = viewport_frame:Clone()
	local world_model = viewport_clone.WorldModel
	local camera = Instance.new("Camera")
	camera.FieldOfView = 20
	camera.CFrame = CFrame.new(0, 2.25, 20)
	camera.Parent = viewport_clone
	viewport_clone.Parent = parent
	viewport_clone.CurrentCamera = camera
	local rig = world_model.Rig
	local raycast_hit: Instance? = nil
	local selected_rig_body_part: string = "All"
	local self
	local selected_cursor = create_selected_cursor(viewport_clone)
	selected_cursor.Visible = false
	local label = lune.textbutton("<Selected>", selected_cursor)
	label.Position = UDim2.new(0, 0, 0, -42)
	label.Size = UDim2.new(0, 182, 0, 32)
	lune.theme_manager:force_highlight(label, true)
	self = {
		instance = viewport_clone,
		reset = function(_internal_call)
			selected_rig_body_part = "All"
			selected_cursor.AnchorPoint = Vector2.new(0.5, 0.5)
			selected_cursor.Size = UDim2.new(0.8, 0, 0.8, 0)
			selected_cursor.Position = UDim2.new(0.5, 0, 0.46, 0)
			label.Visible = false
			if not _internal_call then
				self.on_body_part_click(selected_rig_body_part)
			end
		end,
		set_selected_body_part_colour = function(colour: Color3)
			set_rig_colour(rig, colour, selected_rig_body_part)
			-- highlight_body_part(rig, selected_rig_body_part)
		end,
		set_body_part_colour = function(target: string, colour: Color3)
			set_rig_colour(rig, colour, target)
			-- highlight_body_part(rig, selected_rig_body_part)
		end,
		on_body_part_click = function(body_part: string) end,
	}
	local stored_click_pos = {}
	viewport_clone.MouseMoved:Connect(function(x: number, y: number)
		selected_cursor.Visible = true
		local raycast: RaycastResult = RaycastInViewportFrame(viewport_clone, x, y, 100)
		if not raycast then
			raycast_hit = nil
			if selected_rig_body_part == "All" then
				self.reset(true)
			else
				selected_cursor.Position = stored_click_pos[selected_rig_body_part]
				label.Text = `Colouring {selected_rig_body_part}`
			end
			return
		end
		local norm = normalize(Vector2.new(x, y), viewport_clone.AbsolutePosition, viewport_clone.AbsoluteSize)
		selected_cursor.Position = UDim2.fromScale(norm.X, norm.Y)
		selected_cursor.AnchorPoint = Vector2.zero
		selected_cursor.Size = UDim2.fromOffset(16, 16)
		raycast_hit = raycast.Instance
		local is_selected = selected_rig_body_part == raycast_hit.Name
		local select_text = `Colour {raycast.Instance.Name}`
		local selected_text = `Colouring {raycast.Instance.Name}`
		label.Text = is_selected and selected_text or select_text
		label.Visible = true
	end)
	viewport_clone.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			selected_rig_body_part = raycast_hit and raycast_hit.Name or "All"
			stored_click_pos[selected_rig_body_part] = selected_cursor.Position
			label.Text = `Colouring {selected_rig_body_part}`
			self.on_body_part_click(selected_rig_body_part)
		end
	end)

	return self
end
