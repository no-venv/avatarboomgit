--!strict
local lune = require("../../components/lune_ui")
local tab = require("../../components/lune_ui/tab")
local on_modification = require("./on_modification")
local humanoid_editor = require("../../../singletons/SimpleHumanoidDescription")
local image_from_disk = require("../../../utils/image_from_disk")
return function(tab: tab.TabImpl)
	local current_id = 0
	local container = lune.empty_frame()
	container.Name = "Texture"
	local texture_preview = Instance.new("ImageLabel")
	texture_preview.Size = UDim2.new(0, 150, 0, 150)
	lune.styling.corner(texture_preview)
	do
		local vbox = lune.styling.vbox(container)
		vbox.VerticalAlignment = Enum.VerticalAlignment.Center
		vbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
	end
	do
		local aspect = Instance.new("UIAspectRatioConstraint")
		aspect.AspectRatio = 1
		aspect.Parent = texture_preview
	end
	texture_preview.Parent = container
	local texture_textbox = lune.textbox("Insert Material ID", container)
	local texture_buttons_container = lune.empty_frame(container)
	texture_buttons_container.AutomaticSize = Enum.AutomaticSize.Y
	texture_buttons_container.Size = UDim2.new(1, 0, 0, 0)
	lune.styling.hbox(texture_buttons_container).HorizontalAlignment = Enum.HorizontalAlignment.Center
	local warning_local_texture =
		lune.textlabel("⚠️ The local texture will not work after closing Studio.", container)
	warning_local_texture.Visible = false
	local function update_texture()
		local material_id = humanoid_editor:get_id_texture(current_id)
		if not material_id then
			return false
		end
		warning_local_texture.Visible = material_id:match("rbxtemp") and true or false
		texture_preview.ImageContent = Content.fromUri(material_id)
		texture_textbox.Text = material_id
		return true
	end
	lune.textbutton("Apply", texture_buttons_container, function(...)
		local asset_id = current_id
		local material_id = texture_textbox.Text:match("(%d+)")
		if not material_id then
			return
		end
		humanoid_editor:set_id_texture(asset_id, tonumber(material_id))
		update_texture()
	end)
	lune.textbutton("Reset", texture_buttons_container, function(...)
		local asset_id = current_id
		humanoid_editor:reset_id_texture(asset_id)
		update_texture()
	end)
	lune.textbutton("Upload File", texture_buttons_container, function(...)
		local generated_asset_id = image_from_disk()
		if not generated_asset_id then
			return
		end
		humanoid_editor:set_id_texture(current_id, generated_asset_id)
		update_texture()
	end)

	on_modification.connect(function(parm)
		if parm.event_type == "disable" then
			tab.hide_tab_bar_button("Texture", true)
			return
		end
		if parm.event_type == "selected_id" then
			current_id = parm.id
		end
		-- hide tab button, we are not ready yet
		tab.hide_tab_bar_button("Texture", true)
		if not humanoid_editor:id_equipped(parm.id) then
			return
		end
		if not update_texture() then
			return
		end
		tab.hide_tab_bar_button("Texture", false)
	end)
	return container
end
