--move.luau
local move = Instance.new("Handles")
move.Style = Enum.HandlesStyle.Movement
move.Visible = false
local vector_3_zero = Vector3.new()
return function(
	parent: Instance?,
	primary_part: BasePart,
	mode: "Position" | "Scale",
	on_transform: (value: Vector3, scale: Vector3) -> nil
)
	local new_move_handle = move:Clone()
    if mode == "Scale" then
        new_move_handle.Style = Enum.HandlesStyle.Resize
    end
    new_move_handle.Adornee = primary_part
	local last_distance = nil
	new_move_handle.MouseDrag:Connect(function(face: Enum.NormalId, distance: number)
		if not last_distance then
			last_distance = distance
			return
		end
		local d = distance - last_distance
		local vec3 = Vector3.new(d, d, d)
		local vector_directions = {
			[Enum.NormalId.Left] = -primary_part.CFrame.RightVector,
			[Enum.NormalId.Right] = primary_part.CFrame.RightVector,
			[Enum.NormalId.Front] = primary_part.CFrame.LookVector,
			[Enum.NormalId.Back] = -primary_part.CFrame.LookVector,
			[Enum.NormalId.Top] = primary_part.CFrame.UpVector,
			[Enum.NormalId.Bottom] = -primary_part.CFrame.UpVector,
		}
		if mode == "Scale" then
			local s = vec3 * vector_directions[face]:Abs()
			on_transform((vec3 / 2) * vector_directions[face], s)
		else
			on_transform(vec3 * vector_directions[face], vector_3_zero)
		end
		last_distance = distance
	end)
	new_move_handle.MouseButton1Up:Connect(function(face: Enum.NormalId)
		last_distance = nil
	end)
    new_move_handle.Parent = parent
	return new_move_handle
end
