local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local uniform_scale_handles = Instance.new("CylinderHandleAdornment")
uniform_scale_handles.Color3 = Color3.new(1, 1, 1)
uniform_scale_handles.AlwaysOnTop = true
uniform_scale_handles.Angle = 360
uniform_scale_handles.Height = 0.03
uniform_scale_handles.InnerRadius = 2.2
uniform_scale_handles.ZIndex = 2
uniform_scale_handles.Visible = false
return function(parent : Instance?,primary_part: BasePart, on_transform: (scale: Vector3) -> nil)
	local new_uniform_scale_handles = uniform_scale_handles:Clone()
    new_uniform_scale_handles.Adornee = primary_part
	local scale_sens = 1
	local current_camera = workspace.CurrentCamera :: Camera
	local input_changed: RBXScriptConnection? = nil
	local input_ended: RBXScriptConnection? = nil
	local mouse_pos_listener: RBXScriptConnection? = nil
	new_uniform_scale_handles.MouseButton1Down:Connect(function()
		local mutex = false
		input_ended = UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
			local is_left_button = input.UserInputType == Enum.UserInputType.MouseButton1
			local is_end = input.UserInputState == Enum.UserInputState.End
			if is_left_button and is_end then
				if input_ended then
					input_ended:Disconnect()
					input_ended = nil
				end
				if input_changed then
					input_changed:Disconnect()
					input_changed = nil
				end
				if mouse_pos_listener then
					mouse_pos_listener:Disconnect()
					mouse_pos_listener = nil
				end
				mutex = false
			end
		end)
		input_changed = UserInputService.InputChanged:Connect(function(input: InputObject, gameProcessedEvent: boolean)
			if mutex then
				return
			end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement then
				return
			end
			mutex = true
			local last_scale: number? = nil
			local primary_part_origin = current_camera:WorldToViewportPoint(primary_part.Position)
			primary_part_origin = Vector2.new(primary_part_origin.X, primary_part_origin.Y)
			mouse_pos_listener = input.Changed:Connect(function(property: string)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					local mouse_pos = Vector2.new(input.Position.X, input.Position.Y)
					if not last_scale then
						last_scale = ((mouse_pos - primary_part_origin).Magnitude / 60)
						return
					end
					local mag = ((mouse_pos - primary_part_origin).Magnitude / 60)
					local delta = mag - last_scale
					on_transform(Vector3.new(delta, delta, delta) * scale_sens)
					-- Update Size of Gizmo
					local part_scale = primary_part.Size.Magnitude
					local uniform_scale = new_uniform_scale_handles
					uniform_scale.Height = 0.125
					uniform_scale.Radius = part_scale * 0.5
					uniform_scale.InnerRadius = uniform_scale.Radius * 0.8
                    --
					last_scale = mag
				end
			end)
		end)
	end)

	local render_stepped = RunService.RenderStepped:Connect(function(deltaTime: number)
		local localLook = primary_part.CFrame:VectorToObjectSpace(current_camera.CFrame.LookVector)
		local newCF = CFrame.lookAt(Vector3.zero, localLook)
		new_uniform_scale_handles.CFrame = newCF
	end)
	new_uniform_scale_handles.Destroying:Connect(function(...)
		render_stepped:Disconnect()
	end)
    new_uniform_scale_handles.Parent = parent
	return new_uniform_scale_handles
end

-- local mutex_hotkey = false
-- local percise_movement_hotkey_ended: RBXScriptConnection? = nil
-- local percise_movement_hotkey = UserInputService.InputBegan:Connect(
-- 	function(input: InputObject, gameProcessedEvent: boolean)
-- 		if mutex_hotkey then
-- 			return
-- 		end
-- 		if input.UserInputType ~= Enum.UserInputType.Keyboard then
-- 			return
-- 		end
-- 		local shift_pressed = (input.KeyCode == Enum.KeyCode.LeftShift)
-- 			or (input.KeyCode == Enum.KeyCode.RightShift)
-- 		if not shift_pressed then
-- 			return
-- 		end
-- 		mutex_hotkey = true
-- 		self.scale_sens = 0.10
-- 		local percise_movement_hotkey_ended
-- 		percise_movement_hotkey_ended = input.Changed:Connect(function(property: string)
-- 			if input.UserInputState == Enum.UserInputState.End then
-- 				mutex_hotkey = false
-- 				percise_movement_hotkey_ended:Disconnect()
-- 				self.scale_sens = 1
-- 			end
-- 		end)
-- 	end
-- )
