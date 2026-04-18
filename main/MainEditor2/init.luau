--[[

	avatarBOOM 1
	formally known as "rig editor one", but it was incomplete and the codebase was bad
	i did modernize the codebase a bit but it still stinks at some parts
	
]]
print("avatarBOOM!")
-- Create MainUI and mounnt Drawer UI to it
local drawer_widget_info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 400, 255, 400, 255)
return function(parent: Instance, plugin_global: Plugin?, widget_global: DockWidgetPluginGui?)
	local plugin_container = require("./MainEditor2/shared/Plugin")
	plugin_container.plugin = plugin_global
	plugin_container.widget = widget_global
	local utils = require("./MainEditor2/utils")
	local shared = require("./MainEditor2/shared")
	local daemons = require("./MainEditor2/daemons")
	local singletons = require("./MainEditor2/singletons")
	local lune = require("./MainEditor2/ui/components/lune_ui")
	local ui_main, ui_main_inner = require("./MainEditor2/ui/UIMain")(parent)
	local ui_drawer = require("./MainEditor2/ui/UIDrawer")(ui_main)
	lune.lune_overlay.Parent = ui_main
	if plugin_global then
		local widget = plugin_global:CreateDockWidgetPluginGuiAsync("avatarBOOM drawer", drawer_widget_info)
		widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		widget.Enabled = false
		local function popout_drawer_state(state: boolean)
			ui_drawer.Parent = state and widget or ui_main
			widget.Enabled = state
		end
		widget:BindToClose(function()
			singletons.event_bus.pop_out_drawer.emit({
				bool = false,
			})
		end)

		singletons.event_bus.pop_out_drawer.connect(function(parm: { bool: boolean }): nil
			popout_drawer_state(parm.bool)
			return
		end)
	end
	singletons.event_bus.avatar_boom_post_init:emit()
	return ui_main
end
