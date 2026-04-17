--!strict
type void = nil
local components = require("./components")
local singletons = require("../singletons")
local shared = require("../shared")
local ui_lib = components.lune_ui
local styling = ui_lib.styling
local iconbutton = ui_lib.iconbutton
local UDIM_UI_CLOSED = UDim2.new(1, 0, 0, 0)
local UDIM_UI_OPENED = UDim2.new(1, 0, 0.8, 0)
local input_catcher = Instance.new("TextButton")
input_catcher.Size = UDim2.new(1, 0, 1, 0)
input_catcher.Transparency = 1
input_catcher.TextTransparency = 1
input_catcher.AutoButtonColor = false
input_catcher.ZIndex = 0
return function(parent: Instance)
	--
	local set_filter = require("@self/ViewSetFilter")()
	local import_rig = require("@self/ViewImportRig")()
	local edit_rig = require("@self/EditRig/Init")()
	local view_asset = require("@self/ViewAssetInfo")()
	local accessory_mod = require("@self/ViewAccessoryModification")()
	local set_themes = require("@self/ViewThemes")()
	local save_to_pinboard = require("@self/SavePinboard")()
	local settings_view = require("@self/Settings")()
	local tab_views = {
		set_filter,
		import_rig,
		edit_rig,
		set_themes,
		settings_view,
		view_asset,
		accessory_mod,
		save_to_pinboard,
	}
	--
	local outer_container = ui_lib.empty_frame()
	outer_container.Size = UDIM_UI_CLOSED
	outer_container.Visible = false
	outer_container.AnchorPoint = Vector2.new(0, 1)
	outer_container.Position = UDim2.new(0, 0, 1, 0)
	outer_container.ZIndex = 1899
	input_catcher:Clone().Parent = outer_container
	local drawer_container = ui_lib.empty_frame(outer_container)
	drawer_container.BackgroundTransparency = 0
	drawer_container.BackgroundColor3 = Color3.new(1, 1, 1)
	--drawer_container.AnchorPoint = Vector2.new(0,1)
	drawer_container.ZIndex = 3
	--drawer_container.Position = UDim2.new(0,0,1,0)
	drawer_container.ClipsDescendants = true
	drawer_container.Size = UDim2.new(1, 0, 1, 0)
	ui_lib.theme_manager:add_custom_gui_instance(drawer_container, "Background")
	styling.padding(drawer_container)
	styling.corner(drawer_container)
	styling.stroke(drawer_container)
	do
		local drawer_container_flex = Instance.new("UIListLayout")
		drawer_container_flex.Padding = UDim.new(0, 8)
		drawer_container_flex.VerticalFlex = Enum.UIFlexAlignment.Fill
		drawer_container_flex.Parent = drawer_container
	end
	--
	local drawer_topbar = ui_lib.empty_frame()
	drawer_topbar.Size = UDim2.new(1, 0, 0, 32)
	do
		local topbar_flex = Instance.new("UIListLayout")
		topbar_flex.Padding = UDim.new(0, 8)
		topbar_flex.FillDirection = Enum.FillDirection.Horizontal
		topbar_flex.SortOrder = Enum.SortOrder.LayoutOrder
		topbar_flex.HorizontalFlex = Enum.UIFlexAlignment.Fill
		topbar_flex.Parent = drawer_topbar
	end

	drawer_topbar.Parent = drawer_container
	-- logic for the drawer
	local drawer_view_container = ui_lib.empty_frame(drawer_container)
	local visible_state = false

	local tab, topbar, tab_func = ui_lib.tab(tab_views, "", drawer_view_container, drawer_topbar);
	(topbar:FindFirstChildWhichIsA("UIListLayout") :: UIListLayout).HorizontalAlignment = Enum.HorizontalAlignment.Left
	local popout_toggle = false
	-- pop out
	iconbutton({
		id = shared.icons.pip,
		theme_enabled = true,
		on_click = function()
			if not shared.plugin.plugin then
				return
			end
			popout_toggle = not popout_toggle
			singletons.event_bus.pop_out_drawer.emit({
				bool = popout_toggle,
			})
		end,
		parent = drawer_topbar,
	})
	-- close drawer
	iconbutton({
		id = shared.icons.close,
		theme_enabled = true,
		on_click = function()
			singletons.event_bus.drawer_open.emit({
				bool = false,
			})
		end,
		parent = drawer_topbar,
	})

	local function show_drawer(bool: boolean?)
		if bool == nil then
			visible_state = not visible_state
		else
			visible_state = bool
		end
		if popout_toggle then
			return
		end
		outer_container.Visible = visible_state
		outer_container.Size = visible_state and UDIM_UI_OPENED or UDIM_UI_CLOSED
	end
	-- buttons that are enabled under these views
	local conditional_buttons = {
		[view_asset.Name] = {
			[accessory_mod.Name] = true,
		},
		[save_to_pinboard.Name] = {},
		-- [edit_rig.Name] = {},
	}
	local function change_tab_button_visiblity(tab_name: string)
		local is_conditional = conditional_buttons[tab_name]
		for _, views in tab_views do
			if views.Name == tab_name then
				tab_func.hide_tab_bar_button(tab_name, false)
				continue
			end
			if is_conditional then
				tab_func.hide_tab_bar_button(views.Name, not is_conditional[views.Name])
			else
				tab_func.hide_tab_bar_button(views.Name, not not conditional_buttons[views.Name])
			end
		end
	end

	singletons.event_bus.avatar_item_selected.connect(function(): nil
		tab_func.toggle(view_asset.Name, true)
		change_tab_button_visiblity(view_asset.Name)
		show_drawer(true)
		return
	end)

	singletons.event_bus.save_pinboard.connect(function()
		tab_func.toggle(save_to_pinboard.Name, true)
		change_tab_button_visiblity(save_to_pinboard.Name)
		show_drawer(true)
	end)

	singletons.event_bus.drawer_open.connect(function(parm): nil
		local current_view = tab_func.get_current_view()
		local view_asset_view = current_view == view_asset.Name
		local edit_view = current_view == accessory_mod.Name
		local save_pin_view = current_view == save_to_pinboard.Name
		if view_asset_view or edit_view or save_pin_view then
			tab_func.toggle(set_filter.Name, true)
		end
		change_tab_button_visiblity("Set Filter")
		tab_func.hide_tab_bar_button(accessory_mod.Name, true)
		show_drawer(parm.bool)
		return
	end)

	singletons.event_bus.pop_out_drawer.connect(function(parm): nil
		popout_toggle = parm.bool
		outer_container.Size = popout_toggle and UDim2.new(1, 0, 1, 0) or UDIM_UI_OPENED
		outer_container.Visible = popout_toggle
		return
	end)

	tab_func.toggle("Set Filter", true)
	outer_container.Parent = parent
	print("UI Drawer loaded")
	return outer_container
end
