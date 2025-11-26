-- TODO:
-- improve this gizmo
local rotation = Instance.new("ArcHandles")
local deg = math.deg
rotation.Visible = false

function AngleFromAxis(axis, r)
	local relativeAngle = math.rad(round(math.deg(r)))

	return axis == Enum.Axis.X and { relativeAngle, 0, 0 }
		or axis == Enum.Axis.Y and { 0, relativeAngle, 0 }
		or axis == Enum.Axis.Z and { 0, 0, relativeAngle }
end
function round(number)
	return math.floor((number / 5) + 0.5) * 5
end

return function(parent: Instance?, primary_part: BasePart, on_transform: (value: Vector3) -> nil)
	local new_rotation_handle = rotation:Clone()
	new_rotation_handle.Adornee = primary_part
	local last_angle = nil
	local last_axis: Enum.Axis? = nil
	local last_cframe: CFrame? = nil
	local last_rotation: Vector3? = nil
	
	new_rotation_handle.MouseDrag:Connect(function(axis: Enum.Axis, relativeAngle: number)
		local angle = math.deg(relativeAngle)
		if not last_angle or axis ~= last_axis then
			last_angle = angle
			last_axis = axis
			return
		end
		local delta = angle - last_angle
		last_angle = angle
		last_axis = axis
		local world_axis = primary_part.CFrame:VectorToWorldSpace(Vector3.FromAxis(axis)).Unit
		local rot_delta = CFrame.fromAxisAngle(world_axis, math.rad(delta))
		local x, y, z = rot_delta:ToEulerAnglesXYZ()
		local euler = Vector3.new(math.deg(x), math.deg(y), math.deg(z))
		local abs = world_axis:Abs()
		local dominant
		if abs.X > abs.Y and abs.X > abs.Z then
			dominant = "X"
		elseif abs.Y > abs.X and abs.Y > abs.Z then
			dominant = "Y"
		else
			dominant = "Z"
		end
		local filtered = Vector3.new(
			dominant == "X" and euler.X or 0,
			dominant == "Y" and euler.Y or 0,
			dominant == "Z" and euler.Z or 0
		)
		on_transform(filtered)
	end)

	new_rotation_handle.MouseButton1Up:Connect(function(axis: Enum.Axis)
		last_angle = nil
		last_axis = nil
		last_cframe = nil
	end)
	new_rotation_handle.Parent = parent
	return new_rotation_handle
end
