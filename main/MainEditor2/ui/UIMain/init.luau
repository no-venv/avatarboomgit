local singletons = require("../singletons")
local components = require("@self/../components")
local lune = components.lune_ui
local styling = lune.styling
local theme_manager = lune.theme_manager
local container = lune.empty_frame()
styling.padding(container)
local main_view = lune.empty_frame(container)
styling.corner(main_view)
theme_manager:add_custom_gui_instance(main_view, "Background")
main_view.BackgroundTransparency = 0

return function(parent: Instance)
	--local mainframe = script.gui.Main:Clone()
	local mainframe = container:Clone()
	local inner_container = lune.empty_frame(mainframe)
	singletons.event_bus.select_rig_overlay.connect(function(parm: { bool: boolean }): nil
		inner_container.Visible = not parm.bool
		return
	end)
	require("@self/TopbarButtons")(inner_container)
	require("@self/CatalogResult")(inner_container)
	require("@self/ViewWearing")(inner_container)
	require("@self/ViewFavourites")(inner_container)
	require("@self/UpdateChecker")()
	require("@self/SelectRigOverlay")(mainframe)
	lune.lune_overlay.Parent = inner_container
	mainframe.Parent = parent
	print("UI Main Loaded")
	singletons.event_bus.catalog_show_overlay.emit({ overlay = "None" })
	return mainframe, inner_container
end
