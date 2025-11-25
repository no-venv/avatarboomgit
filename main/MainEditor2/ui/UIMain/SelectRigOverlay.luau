local Editor = script:FindFirstAncestor("MainEditor2")
local components = require(Editor.ui.components)
local singletons = require(Editor.singletons)
local event_bus = singletons.event_bus
local ui_lib = components.lune_ui
local humanoid_editor = singletons.humanoid_description
local import_rig_component =require(Editor.ui.UIDrawer.ViewImportRig)

return function(parent : Instance?)
	local container = ui_lib.empty_frame(parent)
	local _8_padding = UDim.new(0,8)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = _8_padding
	padding.PaddingLeft = _8_padding
	padding.PaddingRight = _8_padding
	padding.PaddingBottom = _8_padding
	padding.Parent = container
	local vert_layout = Instance.new("UIListLayout")
	vert_layout.Padding = UDim.new(0,8)
	vert_layout.SortOrder = Enum.SortOrder.LayoutOrder
	vert_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	vert_layout.VerticalAlignment = Enum.VerticalAlignment.Center
	vert_layout.Parent = container
	local avatar_boom_logo = Instance.new("ImageLabel")
	avatar_boom_logo.ImageContent = Content.fromAssetId(109639726516588)
	avatar_boom_logo.Size = UDim2.new(1,0,1,0)
	avatar_boom_logo.Parent = container
	avatar_boom_logo.Transparency = 1
	avatar_boom_logo.BorderSizePixel = 1
	ui_lib.theme_manager:add_custom_gui_instance(avatar_boom_logo,"Foreground")
	local ratio_const = Instance.new("UIAspectRatioConstraint")
	ratio_const.AspectRatio = 8.32971800434
	ratio_const.Parent = avatar_boom_logo
	local text = ui_lib.textlabel("<b>Select a Rig or import one to use avatarBOOM!</b>",container)
	local import_rig = import_rig_component(container)
	import_rig.AutomaticSize = Enum.AutomaticSize.Y
	import_rig.Size = UDim2.new(1,0,0,0)
	import_rig.Visible = true
	container.Transparency = 120
	container.ZIndex = 10
	container.Visible = false
	humanoid_editor.humanoid_changed.Event:Connect(function(...: any) 
		local init_status = not humanoid_editor:is_init()
		container.Visible = init_status
		singletons.event_bus.select_rig_overlay.emit({bool = init_status})
	end)

	container.Visible = not humanoid_editor:is_init()
	singletons.event_bus.select_rig_overlay.emit({bool = true})
	return container
end

