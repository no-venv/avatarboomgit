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
local function highlight_body_part(rig: Model, target: string)
	if target == "All" then
		return
	end
	for _, part in rig:GetChildren() do
		if part.Name == "HumanoidRootPart" then
			continue
		end
		if part:IsA("BasePart") then
			if part.Name == target then
				continue
			end
			local color = Vector3.new(part.Color.R, part.Color.G, part.Color.B) * 0.5
			part.Color = Color3.new(color.X, color.Y, color.Z)
		end
	end
	return
end

local function reset_body_part_colours(rig: Model)
	local body_colours: BodyColors = rig:FindFirstChild("Body Colors") :: BodyColors
	for _, part in rig:GetChildren() do
		if part.Name == "HumanoidRootPart" then
			continue
		end
		if part:IsA("BasePart") then
			local colour = body_colours[part_to_body_colour[part.Name]]
			part.Color = colour
		end
	end
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

	self = {
		instance = viewport_clone,
		reset = function()
			selected_rig_body_part = "All"
			reset_body_part_colours(rig)
			self.on_body_part_click(selected_rig_body_part)
		end,
		set_selected_body_part_colour = function(colour: Color3)
			set_rig_colour(rig, colour, selected_rig_body_part)
			highlight_body_part(rig, selected_rig_body_part)
		end,
		set_body_part_colour = function(target: string, colour: Color3)
			set_rig_colour(rig, colour, target)
			highlight_body_part(rig, selected_rig_body_part)
		end,
		on_body_part_click = function(body_part: string) end,
	}

	viewport_clone.MouseMoved:Connect(function(x: number, y: number)
		local raycast: RaycastResult = RaycastInViewportFrame(viewport_clone, x, y, 100)
		if not raycast then
			raycast_hit = nil
			reset_body_part_colours(rig)
			if selected_rig_body_part ~= "All" then
				highlight_body_part(rig, selected_rig_body_part)
			end
			return
		end
		reset_body_part_colours(rig)
		highlight_body_part(rig, raycast.Instance.Name)
		raycast_hit = raycast.Instance
	end)

	viewport_clone.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			selected_rig_body_part = raycast_hit and raycast_hit.Name or "All"
			self.on_body_part_click(selected_rig_body_part)
			--if not raycast_hit then
			--	reset_body_part_colours(rig)
			--end
		end
	end)

	return self
end
