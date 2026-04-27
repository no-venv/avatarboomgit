local singletons = require("../singletons")
local components = require("./components")
local shared = require("../shared")
local lune = components.lune_ui
local styling = lune.styling
local theme_manager = lune.theme_manager
local container = lune.empty_frame()
styling.padding(container)
local main_view = lune.empty_frame(container)
styling.corner(main_view)
theme_manager:add_custom_gui_instance(main_view, "Background")
main_view.BackgroundTransparency = 0
-- main_view.ZIndex = -1999

return function(parent: Instance)
	local mainframe = container:Clone()
	local inner_container = lune.empty_frame(mainframe)
	inner_container.Size = UDim2.new(1, 0, 1, -48)
	singletons.event_bus.select_rig_overlay.connect(function(parm: { bool: boolean }): nil
		inner_container.Visible = not parm.bool
		return
	end)

	require("@self/TopbarButtons")(inner_container)
	require("@self/CatalogResult")(inner_container)
	require("@self/ViewWearing")(inner_container)
	require("@self/ViewFavourites")(inner_container)
	require("@self/LayeredItemsViewportOverlay")(inner_container)
	require("@self/UpdateChecker")()
	require("@self/SelectRigOverlay")(mainframe)
	require("@self/NavigationBar")(mainframe, {
		{
			tooltip = "Catalog",
			icon = shared.icons.home,
			overlay = "None",
		},
		{
			tooltip = "Saved Boards",
			icon = shared.icons.heart,
			overlay = "Favourites",
		},
		{
			tooltip = "View Wearing",
			icon = shared.icons.clothes,
			overlay = "Wearing",
		},
	})
	mainframe.Parent = parent
	print("UI Main Loaded")
	singletons.event_bus.catalog_show_overlay.emit({ overlay = "None" })
	local robux_amount = components.robux_count()

	singletons.event_bus.topbar_register_custom_element.emit({
		allowed_overlay = { "Wearing", "None" },
		button_id = "wearing_robux",
		location = "right",
		element = robux_amount,
	})
	singletons.event_bus.topbar_visibility_custom_button.emit({
		button_id = "wearing_robux",
		show = true,
	})
	return mainframe, inner_container
end
