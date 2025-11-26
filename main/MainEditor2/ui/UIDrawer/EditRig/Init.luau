--!strict
local colour_view = require("./colours")
local R15Scale_view = require("./scale")
local components = require("../../components")
local ui_lib = components.lune_ui
return function(parent: Instance?)
	local edit_rig_view = ui_lib.empty_frame()
	edit_rig_view.Name = "Edit Rig"
	edit_rig_view.Visible = false
	edit_rig_view.Parent = parent
	ui_lib.tab({
		colour_view(),
		R15Scale_view(),
	}, "Body Colour", edit_rig_view)
	--tab.Size = UDim2.new(1,0,1,0)
	return edit_rig_view
end
