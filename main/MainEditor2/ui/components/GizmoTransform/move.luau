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

		local world_direction = primary_part.CFrame:VectorToWorldSpace(Vector3.FromNormalId(face))
		local world_delta = world_direction * d

		local attachment = primary_part:FindFirstChildOfClass("Attachment")
		local character = primary_part.Parent and primary_part.Parent.Parent
		local body_part = nil

		if character and attachment then
			local body_attachment = character:FindFirstChild(attachment.Name, true)
			if body_attachment and body_attachment:IsA("Attachment") then
				body_part = body_attachment.Parent
			end
		end

		local final_delta
		if body_part and body_part:IsA("BasePart") then
			-- world movement to body part local space
			final_delta = body_part.CFrame:VectorToObjectSpace(world_delta)
		else
			-- fallback (works ok too but ideally the above code works like 100% of the time)
			final_delta = primary_part.CFrame:VectorToObjectSpace(world_delta)
		end

		if mode == "Scale" then
			local s = Vector3.FromNormalId(face):Abs() * d
			on_transform(final_delta / 2, s)
		else
			on_transform(final_delta, vector_3_zero)
		end

		last_distance = distance
	end)
	new_move_handle.MouseButton1Up:Connect(function(face: Enum.NormalId)
		last_distance = nil
	end)
	new_move_handle.Parent = parent
	return new_move_handle
end
