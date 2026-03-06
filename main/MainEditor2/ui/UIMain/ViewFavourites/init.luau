--!strict
local components = require("../components")
local singletons = require("../../singletons")
local pinboard_picker = require("../components/PinboardPicker")
local show_pinboard_contents = require("@self/show_pinboard_contents")
local lune = components.lune_ui
local tabs = lune.tab
local empty_frame = lune.empty_frame
local styling = lune.styling
local event_bus = singletons.event_bus

return function(parent: Instance?)
	local pinboards_container = empty_frame()
	pinboards_container.Name = "Home"
	local board_container = empty_frame()
	board_container.Name = "Board"
	styling.padding(pinboards_container).PaddingTop = UDim.new(0, 50)

	local tab_container, _, view_func = tabs({ pinboards_container, board_container }, "Home", parent)
	view_func.hide_tab(true)
	local current_view_pinboards: Frame? = nil
	local current_view_boards: Frame? = nil
	local is_enabled = false
	local updated_queued = false

	local function update()
		if current_view_pinboards then
			current_view_pinboards:Destroy()
		end

		current_view_pinboards = pinboard_picker({
			parent = pinboards_container,
			on_picked_pinboard = function(picked)
				if current_view_boards then
					current_view_boards:Destroy()
				end
				current_view_boards = show_pinboard_contents(board_container, picked.name)
				view_func.toggle("Board", true)
				event_bus.topbar_visibility_custom_button.emit({
					button_id = "pin_back",
					show = true,
				})
				return
			end,
		})
		return
	end
	view_func.on_view_change = function(view)
		if view == "Home" and updated_queued then
			update()
			updated_queued = false
		end
		return
	end
	event_bus.save_pinboard_success.connect(function(parm: {}): nil
		if view_func.get_current_view() == "Home" then
			update()
		else
			updated_queued = true
		end
		return
	end)

	event_bus.catalog_show_overlay.connect(function(parm): nil
		is_enabled = parm.overlay == "Favourites"
		tab_container.Visible = is_enabled
		if is_enabled then
			update()
		end
		return
	end)

	event_bus.topbar_register_custom_button.emit({
		allowed_overlay = "Favourites",
		image = 84503957682657,
		button_id = "pin_back",
		on_click = function()
			if current_view_boards then
				current_view_boards:Destroy()
			end
			event_bus.topbar_visibility_custom_button.emit({
				button_id = "pin_back",
				show = false,
			})
			view_func.toggle("Home", true)
			pinboards_container.Visible = true
			return
		end,
	})

	tab_container.Visible = false
	return tab_container
end
