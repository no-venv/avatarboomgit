--!strict
local core_gui = (game :: any).CoreGui
local humanoid_description = require("../../singletons/SimpleHumanoidDescription")
local screen_gui = Instance.new("ScreenGui")
local lune = require("../components/lune_ui")
local items_container = require("@self/items_container")
local shared = require("../../shared")
screen_gui.Parent = core_gui
return function(parent: Instance)
	local tooltip_container = lune.empty_frame(screen_gui)
	---
	local container = lune.empty_frame(screen_gui)
	lune.styling.padding(container)
	do
		local hbox = lune.styling.hbox(container)
		hbox.HorizontalAlignment = Enum.HorizontalAlignment.Right
	end
	---
	local layered_items_container = lune.empty_frame(container)
	layered_items_container.Size = UDim2.new(0, 72, 1, 0)
	layered_items_container.AutomaticSize = Enum.AutomaticSize.X
	layered_items_container.Name = "apples"
	local _, _, adjust_tabs_func = lune.tab({}, "", layered_items_container)
	adjust_tabs_func.hide_tab_bar(true)

	---
	local button_container = lune.empty_frame(container)
	button_container.Size = UDim2.new(0, 32, 1, 0)
	lune.styling.vbox(button_container)

	local hide_adjust_button = lune.iconbutton({
		id = shared.icons.hide,
		on_click = function()
			layered_items_container.Visible = false
		end,
		parent = button_container,
		theme_enabled = true
	})
	lune.tooltips(hide_adjust_button, "Hide Adjust", tooltip_container)

	local adjust_buttons_container = lune.empty_frame(button_container)
	lune.styling.vbox(adjust_buttons_container)
	local adjust_makeup_button = lune.iconbutton({
		id = shared.icons.makeup,
		on_click = function()
			adjust_tabs_func.toggle("Makeup", true)
			layered_items_container.Visible = true
		end,
		parent = adjust_buttons_container,
		theme_enabled = true
	})
	lune.tooltips(adjust_makeup_button, "Adjust Makeup", tooltip_container)

	local adjust_layered_clothing_button = lune.iconbutton({
		id = shared.icons.clothes,
		on_click = function()
			adjust_tabs_func.toggle("Clothing", true)
			layered_items_container.Visible = true
		end,
		parent = adjust_buttons_container,
		theme_enabled = true
	})
	lune.tooltips(adjust_layered_clothing_button, "Adjust Layered clothing", tooltip_container)
	---
	local function update()
		if not humanoid_description:is_init() then
			container.Visible = false
			return
		end
		container.Visible = true
		adjust_tabs_func.add_views({
			items_container({
				name = "Makeup",
				items = humanoid_description:get_makeup_order(),
				on_position_change = function(id, order)
					humanoid_description:set_makeup_order(id, order)
				end,
			}),
			items_container({
				name = "Clothing",
				items = humanoid_description:get_layered_clothing_order(),
				on_position_change = function(id, order)
					humanoid_description:set_layered_clothing_order(id, order)
				end,
			}),
		})
	end
	humanoid_description.humanoid_changed.Event:Connect(update)
	humanoid_description.id_added.Event:Connect(update)
	humanoid_description.id_removed.Event:Connect(update)
	update()
	parent.Destroying:Connect(function(...)
		screen_gui:Destroy()
	end)
	-- adjust_makeup_button.Visible = false
	return screen_gui
end
