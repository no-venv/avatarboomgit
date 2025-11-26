type OnTransformFunc = (type : "Move" | "Rotation" | "Scale" | "Reset", value : Vector3) -> nil
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local gizmo = require(script.Gizmo)
local ui_lib = require(script.Parent.lune_ui)
local shared = require(Editor.shared)
local plugin = shared.plugin.plugin
return function(primary_part : BasePart,on_transform : OnTransformFunc)
	local instanced_gizmo = gizmo()
	local current_gizmo : HandlesBase? = nil
	local current_camera = workspace.CurrentCamera :: Camera
	local billboard_gui = Instance.new("BillboardGui")
	local user_gizmo_active = false
	billboard_gui.Active = true
	billboard_gui.AlwaysOnTop = true
	billboard_gui.StudsOffsetWorldSpace = primary_part.Position + Vector3.new(2,0,0)
	billboard_gui.Size = UDim2.new(0,96,0,256)
	billboard_gui.Parent = (game::any).CoreGui
	local container = ui_lib.empty_frame(billboard_gui)
	local vert_layout = Instance.new("UIListLayout")
	vert_layout.Padding = UDim.new(0,8)
	vert_layout.HorizontalFlex = Enum.UIFlexAlignment.Fill
	vert_layout.SortOrder = Enum.SortOrder.LayoutOrder
	vert_layout.Parent = container
	local self 
	self = {
		current_mode = "";
		instance = instanced_gizmo.container;
		scale_sens = 1;
		update_position = function()
			billboard_gui.StudsOffsetWorldSpace = primary_part.Position + Vector3.new(2,0,0)
		end,
		toggle = function(gizmo_type : "Move" | "Rotation" | "Scale" | "UniformScale")
			if current_gizmo then
				current_gizmo.Visible = false
			end
			local is_scale = gizmo_type == "Scale"
			local is_move = gizmo_type == "Move"
			if is_scale or is_move then
				instanced_gizmo.Move.Style = 
					(is_scale and Enum.HandlesStyle.Resize) or Enum.HandlesStyle.Movement
				instanced_gizmo.Move.Visible = true		
				current_gizmo = instanced_gizmo.Move
			else
				instanced_gizmo[gizmo_type].Visible = true
				current_gizmo = instanced_gizmo[gizmo_type]
			end
			self.current_mode = gizmo_type
		end,
		hide = function()
			instanced_gizmo.Move.Visible = false
			instanced_gizmo.Rotation.Visible = false
			instanced_gizmo.UniformScale.Visible = false
		end,
		update_unform_scale_size = function()
			local part_scale = primary_part.Size.Magnitude
			local uniform_scale = instanced_gizmo.UniformScale
			uniform_scale.Height = 0.125
			uniform_scale.Radius = part_scale * 0.5
			uniform_scale.InnerRadius = uniform_scale.Radius * 0.8
		end,
	}
	local move_button = ui_lib.textbutton("Move",container,function(): nil 
		self.toggle("Move")	
		return
	end)
	local rot_button = ui_lib.textbutton("Rotation",container,function(): nil 
		self.toggle("Rotation")	
		return
	end)
	local scale_button = ui_lib.textbutton("Scale",container,function(): nil 
		self.toggle("Scale")
		return
	end)
	local uniform_scale_button = ui_lib.textbutton("Uniform Scale",container,function(): nil 
		self.toggle("UniformScale")
		return
	end)
	local reset_button = ui_lib.textbutton("Reset",container,function(): nil 
		on_transform("Reset",Vector3.zero)	
		self.update_unform_scale_size()
		return
	end)
	local hide_gizmos_button = ui_lib.textbutton("Hide Gizmos",container,function(): nil 
		self.hide()
		return
	end)
	local last_distance = nil
	instanced_gizmo.Move.MouseDrag:Connect(function(face: Enum.NormalId, distance: number) 
		user_gizmo_active = true
		if not last_distance then
			last_distance = distance
			return
		end
		local d = distance - last_distance
		local vec3 = Vector3.new(d,d,d)
		local vector_directions = {
			[Enum.NormalId.Left] 	=  -primary_part.CFrame.RightVector;
			[Enum.NormalId.Right] 	=  primary_part.CFrame.RightVector;
			[Enum.NormalId.Front] 	=  primary_part.CFrame.LookVector;
			[Enum.NormalId.Back]	=  -primary_part.CFrame.LookVector;
			[Enum.NormalId.Top] 	=   primary_part.CFrame.UpVector;
			[Enum.NormalId.Bottom]	=  -primary_part.CFrame.UpVector;
		}
		if self.current_mode == "Scale" then
			local s = vec3 * vector_directions[face]:Abs()
			on_transform("Scale",s)
			on_transform("Move",(vec3/2) * vector_directions[face])
		else
			on_transform("Move",vec3 * vector_directions[face])
		end
		last_distance = distance
	end)
	instanced_gizmo.Move.MouseButton1Up:Connect(function(face: Enum.NormalId) 
		user_gizmo_active = false
		last_distance = nil	
	end)

	local last_angle = nil
	local last_axis : Enum.Axis? = nil
	instanced_gizmo.Rotation.MouseDrag:Connect(function(axis: Enum.Axis, relativeAngle: number)
		user_gizmo_active = true
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
		on_transform("Rotation", filtered)
	end)

	instanced_gizmo.Rotation.MouseButton1Up:Connect(function(axis: Enum.Axis) 
		user_gizmo_active = false
		last_angle = nil	
		last_axis = nil
	end)
	--
	--
	local input_changed : RBXScriptConnection? = nil
	local input_ended  : RBXScriptConnection? = nil
	local mouse_pos_listener : RBXScriptConnection? = nil
	instanced_gizmo.UniformScale.MouseButton1Down:Connect(function() 
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
				mutex= false
				user_gizmo_active = false
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
			user_gizmo_active = true
			local last_scale : number? = nil
			local primary_part_origin = current_camera:WorldToViewportPoint(primary_part.Position)
			primary_part_origin = Vector2.new(primary_part_origin.X,primary_part_origin.Y)
			mouse_pos_listener = input.Changed:Connect(function(property: string) 
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					local mouse_pos = Vector2.new(input.Position.X,input.Position.Y)
					if not last_scale then
						last_scale = ((mouse_pos - primary_part_origin).Magnitude / 60)
						return
					end
					local mag = ((mouse_pos - primary_part_origin).Magnitude / 60)
					local delta = mag - last_scale
					on_transform("Scale",Vector3.new(delta,delta,delta) * self.scale_sens)
					self.update_unform_scale_size()
					last_scale = mag
				end
			end)
		end)

	end)

	local mutex_hotkey = false
	local percise_movement_hotkey_ended : RBXScriptConnection? = nil
	local percise_movement_hotkey = UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
		if mutex_hotkey  then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		local shift_pressed = (input.KeyCode == Enum.KeyCode.LeftShift) or (input.KeyCode == Enum.KeyCode.RightShift)
		if not shift_pressed then
			return
		end	
		mutex_hotkey = true
		self.scale_sens = 0.10
		local percise_movement_hotkey_ended 
		percise_movement_hotkey_ended = input.Changed:Connect(function(property: string) 
			if input.UserInputState == Enum.UserInputState.End then
				mutex_hotkey = false
				percise_movement_hotkey_ended:Disconnect()
				self.scale_sens = 1
			end	
		end)
	end)
	local render_stepped = RunService.RenderStepped:Connect(function(deltaTime: number) 
		local localLook = primary_part.CFrame:VectorToObjectSpace(current_camera.CFrame.LookVector)
		local newCF = CFrame.lookAt(Vector3.zero,localLook)
		instanced_gizmo.UniformScale.CFrame = newCF
		self.update_position()
		billboard_gui.Enabled = not user_gizmo_active
	end)

	for _,gizmo : HandlesBase in instanced_gizmo do
		if gizmo:IsA("Model") then
			continue
		end
		gizmo.Adornee = primary_part
	end
	
	local buttons = {
		rot_button;
		move_button;
		reset_button;
		scale_button;
		hide_gizmos_button;
		uniform_scale_button;
	}
	for _,button in buttons do
		button.MouseEnter:Connect(function(x: number, y: number) 
			button.Transparency = 0	
		end)
		button.MouseLeave:Connect(function(x: number, y: number) 
			button.Transparency = 0.5	
		end)
		button.Transparency = 0.5
	end
	if plugin then
		plugin:Activate(true)
	end
	local part_scale = primary_part.Size.Magnitude
	self.update_unform_scale_size()
	instanced_gizmo.container.Parent = game.CoreGui
	instanced_gizmo.container.Destroying:Connect(function() 
		if plugin then
			plugin:Activate(false)
		end
		billboard_gui:Destroy()
		render_stepped:Disconnect()
		if input_ended then
			input_ended:Disconnect()
		end
		if input_changed then
			input_changed:Disconnect()
		end
		if mouse_pos_listener then
			mouse_pos_listener:Disconnect()
		end
		if percise_movement_hotkey_ended then
			percise_movement_hotkey_ended:Disconnect()
		end
	end)
	return instanced_gizmo.container
end
