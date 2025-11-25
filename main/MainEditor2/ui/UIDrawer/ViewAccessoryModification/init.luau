--!strict
local Editor = script:FindFirstAncestor("MainEditor2")
local singletons = require(Editor.singletons)
local components = require(Editor.ui.components)
local event_bus = singletons.event_bus
local ui_lib = components.lune_ui
local asset_button = components.asset_button
local gizmo_transform = components.gizmo_transform
local humanoid_editor = singletons.humanoid_description

return function(parent : Instance?) : Frame
	local is_accessory = false
	local is_clothing = false
	local clothing_type = ""
	local current_id = 0
	local current_asset_info_id
	local container = ui_lib.empty_frame()	
	container.Parent = parent
	container.Name = "Edit"
	container.Visible = false
	local vert_layout = Instance.new("UIListLayout")
	vert_layout.Padding = UDim.new(0,8)
	vert_layout.SortOrder = Enum.SortOrder.LayoutOrder
	vert_layout.VerticalAlignment = Enum.VerticalAlignment.Center
	vert_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local colour_edit = ui_lib.empty_frame()
	colour_edit.Name = "Colour"
	local material_texture = ui_lib.empty_frame()
	material_texture.Name = "Texture"
	do
		local colour_edit_layout = vert_layout:Clone()
		colour_edit_layout.VerticalFlex = Enum.UIFlexAlignment.Fill
		colour_edit_layout.Parent = colour_edit
	end
	vert_layout:Clone().Parent = material_texture

	local tab,topbar,tab_func = ui_lib.tab({
		colour_edit;
		material_texture;
	},"Colour",container)

	-- colour wheel view
	local colour_wheel = components.colour_wheel(colour_edit)
	local min_size = Instance.new("UISizeConstraint")
	min_size.MinSize = Vector2.new(0,32)
	local hex_colour = ui_lib.textbox("Hex Colour",colour_edit)
	local reset_colour = ui_lib.textbutton("Reset",colour_edit,function(): nil 
		colour_wheel.set_colour(Color3.new(1,1,1))
		return
	end)
	hex_colour.FocusLost:Connect(function(enterPressed: boolean, inputThatCausedFocusLoss: InputObject) 
		if not enterPressed then
			return
		end	
		colour_wheel.set_colour(Color3.fromHex(hex_colour.Text))
	end)
	colour_wheel.on_colour = function(colour)
		if is_clothing then
			humanoid_editor:set_clothing_colour(clothing_type,colour)
		else
			humanoid_editor:set_id_colour(current_id,colour)
		end
		hex_colour.Text = colour:ToHex()		
	end

	min_size:Clone().Parent = reset_colour
	min_size:Clone().Parent = hex_colour
	-- Material Options view
	local texture_preview = Instance.new("ImageLabel")
	texture_preview.Size = UDim2.new(0,150,0,150)
	ui_lib.styling.corner(texture_preview)
	do
		local aspect = Instance.new("UIAspectRatioConstraint")
		aspect.AspectRatio = 1
		aspect.Parent = texture_preview
	end
	texture_preview.Parent = material_texture
	local texture_textbox = ui_lib.textbox("Insert Material ID",material_texture)
	local texture_buttons_container = ui_lib.empty_frame(material_texture)
	texture_buttons_container.AutomaticSize = Enum.AutomaticSize.Y
	texture_buttons_container.Size = UDim2.new(1,0,0,0)
	ui_lib.styling.hbox(texture_buttons_container)
		.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local texture_apply = ui_lib.textbutton("Apply",texture_buttons_container)
	local texture_reset = ui_lib.textbutton("Reset",texture_buttons_container)

	local function update_material_options()
		if not current_asset_info_id then
			return
		end
		local asset_id = current_asset_info_id.asset_info.Id
		local material_id = humanoid_editor:get_id_texture(asset_id)
		tab_func.hide_button(material_texture.Name,not material_id)
		if not material_id then
			-- not ready, i guess
			return
		end
		texture_preview.ImageContent = Content.fromUri(material_id)
		texture_textbox.Text = material_id
	end
	texture_apply.MouseButton1Click:Connect(function() 
		if not current_asset_info_id then
			return
		end	
		local asset_id = current_asset_info_id.asset_info.Id
		local material_id = texture_textbox.Text:match("(%d+)")
		if not material_id then
			return
		end
		humanoid_editor:set_id_texture(asset_id,tonumber(material_id))
		update_material_options()
	end)
	texture_reset.MouseButton1Click:Connect(function() 
		if not current_asset_info_id then
			return
		end
		local asset_id = current_asset_info_id.asset_info.Id
		humanoid_editor:reset_id_texture(asset_id)
		update_material_options()
	end)
	-- Gizmos
	local current_gizmo_transform 
	local function update_modification()
		if current_gizmo_transform then
			current_gizmo_transform:Destroy()
		end
		event_bus.accessory_modification_ready.emit({bool = false})
		if not current_asset_info_id then
			return
		end
		local asset_id = current_asset_info_id.asset_info.Id
		local item_type = current_asset_info_id.asset_info.ItemType
		local asset_type = current_asset_info_id.asset_info.AssetType
		if not humanoid_editor:id_equipped(asset_id) then
			return
		end
		is_accessory = item_type == "Asset"
		is_clothing = asset_type == "Shirt" or asset_type == "Pants"
		clothing_type = asset_type
		current_id = asset_id
		local saved_colour = is_clothing and humanoid_editor:get_clothing_colour(asset_type) or humanoid_editor:get_id_colour(asset_id)
		if saved_colour then
			colour_wheel.set_colour(saved_colour)
		end
		if is_accessory and not is_clothing then
			local accessory = humanoid_editor:get_id_accessory(current_id)
			if not accessory then
				return
			end
			local handle_part = accessory:FindFirstChild("Handle")
			if not handle_part then
				return
			end
			current_gizmo_transform = gizmo_transform(handle_part,function(type, value: Vector3): nil 
				if type == "Move" then
					local cur_id_transform = humanoid_editor:get_id_transformation(current_id,"Pos")
					if not cur_id_transform then
						return
					end
					humanoid_editor:set_id_transformation(current_id,"Pos",cur_id_transform + value)
					return	
				end
				if type == "Rotation" then
					local cur_id_rot = humanoid_editor:get_id_transformation(current_id,"Rot")
					if not cur_id_rot then
						return
					end
					humanoid_editor:set_id_transformation(current_id,"Rot",cur_id_rot + value)
					return	
				end
				if type == "Scale" then
					local cur_id_scale = humanoid_editor:get_id_transformation(current_id,"Scale")
					if not cur_id_scale then
						return
					end
					humanoid_editor:set_id_transformation(current_id,"Scale",cur_id_scale + value )
					return	
				end
				if type == "Reset" then
					humanoid_editor:set_id_transformation(current_id,"Pos",Vector3.zero)
					humanoid_editor:set_id_transformation(current_id,"Rot",Vector3.zero)
					humanoid_editor:set_id_transformation(current_id,"Scale",Vector3.new(1,1,1))
					return	
				end
				return
			end)
		end
		event_bus.accessory_modification_ready.emit({bool = true})
		return	
	end

	local function update_all()
		update_modification()
		update_material_options()
	end
	event_bus.drawer_open.connect(function(parm): nil 
		current_asset_info_id = nil
		if current_gizmo_transform then
			current_gizmo_transform:Destroy()
		end
		return
	end)

	humanoid_editor.humanoid_changed.Event:Connect(update_all)
	humanoid_editor.id_added.Event:Connect(update_all)
	humanoid_editor.id_removed.Event:Connect(update_all)
	event_bus.avatar_item_selected.connect(function(parm): nil 
		current_asset_info_id = parm
		update_all()
		return
	end)
	container.Destroying:Connect(function() 
		if current_gizmo_transform then
			current_gizmo_transform:Destroy()
		end	
	end)
	return container
end