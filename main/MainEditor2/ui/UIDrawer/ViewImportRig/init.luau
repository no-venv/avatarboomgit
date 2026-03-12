local StudioService = game:GetService("StudioService")
local components = require("../components")
local import_friends = require("@self/import_friends")
local import_rig = require("@self/import_rig")
local ui_lib = components.lune_ui

return function(parent: Instance?)
	local import_rig_view = ui_lib.tab({ import_rig(), import_friends(nil, StudioService:GetUserId()) }, "Create Rig",parent)
	import_rig_view.Visible = false
	import_rig_view.Name = "Import Rig"
	return import_rig_view
end
