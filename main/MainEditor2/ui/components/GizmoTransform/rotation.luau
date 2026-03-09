-- TODO:
-- improve this gizmo
type RotationGizmoImpl = {
	update_cframe: () -> any,
}
local run_service = game:GetService("RunService")
local rotation = Instance.new("ArcHandles")
rotation.Visible = false
local function AngleFromAxis(axis, r)
	local relativeAngle = math.rad((math.deg(r)))

	return axis == Enum.Axis.X and { relativeAngle, 0, 0 }
		or axis == Enum.Axis.Y and { 0, relativeAngle, 0 }
		or axis == Enum.Axis.Z and { 0, 0, relativeAngle }
end

return function(parent: Instance?, primary_part: BasePart, on_transform: (value: Vector3) -> nil): ArcHandles
	local handle_part = Instance.new("Part")
	handle_part.Transparency = 1
	handle_part.Parent = parent
	handle_part.CFrame = primary_part.CFrame

	local new_rotation_handle = rotation:Clone()
	new_rotation_handle.Adornee = handle_part
	local last_cframe: CFrame? = nil
	local last_rotation: Vector3? = nil

	new_rotation_handle.MouseDrag:Connect(function(axis: Enum.Axis, relativeAngle: number)
		handle_part.CFrame = (last_cframe :: CFrame) * CFrame.Angles(unpack(AngleFromAxis(axis, relativeAngle)))
		local x, y, z = handle_part.CFrame:ToOrientation()
		local vec3_orint = Vector3.new(math.deg(x), math.deg(y), math.deg(z))
		local detla = vec3_orint - last_rotation
		last_rotation = vec3_orint
		on_transform(detla)
	end)

	new_rotation_handle.MouseButton1Up:Connect(function(axis: Enum.Axis)
		last_cframe = nil
	end)
	new_rotation_handle.MouseButton1Down:Connect(function(a0: Enum.Axis)
		last_cframe = handle_part.CFrame
		local x, y, z = handle_part.CFrame:ToOrientation()
		last_rotation = Vector3.new(math.deg(x), math.deg(y), math.deg(z))
	end)
	new_rotation_handle.Destroying:Connect(function()
		handle_part:Destroy()
	end)
	local update = run_service.Heartbeat:Connect(function(a0: number)
		handle_part.Position = primary_part.Position
	end)
	new_rotation_handle.Destroying:Connect(function(...)
		update:Disconnect()
	end)
	new_rotation_handle.Parent = parent
	new_rotation_handle:SetAttribute("force_update_frame", false)
	local debounce = false
	new_rotation_handle:GetAttributeChangedSignal("force_update_frame"):Connect(function(...)
		if debounce then
			debounce = false
			return
		end
		debounce = true
		local updated_value = new_rotation_handle:GetAttribute("force_update_frame")
		if updated_value then
			handle_part.CFrame = primary_part.CFrame
		end
		new_rotation_handle:SetAttribute("force_update_frame", false)
	end)
	return new_rotation_handle
end
