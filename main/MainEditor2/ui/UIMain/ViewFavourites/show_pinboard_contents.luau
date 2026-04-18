local pinboard_shared = require("../../../shared/pinboard")
local singletons = require("../../../singletons")
local event_bus = singletons.event_bus
local buy_asset_button = require("../../components/BuyAssetButton")
local robux_counter = require("../../components/RobuxCount")
local asset_button = require("../../components/AssetButton")
local asset_button_header = require("../../components/AssetButtonHeader")
local show_similar_items = require("./show_similar_items")
local lune = require("../../components/lune_ui")

local empty_frame = lune.empty_frame
local scrolling_frame = lune.scrolling_frame
local tabs = lune.tab
local label = lune.textlabel
local styling = lune.styling
return function(parent: Frame, name: string)
	local outer_container = empty_frame()
	outer_container.Name = "Pins"
	local similar_items_container = show_similar_items(nil, name, pinboard_shared.pinboard_exists(name))
	similar_items_container.Name = "Find Similar Items"
	local current_view: Frame?
	local select_mode = false
	local stored_buttons = {}
	local selected_buttons = {}
	local robux_counter = robux_counter(nil, 0)

	local tab_container = tabs({ outer_container, similar_items_container }, "Pins", parent)
	styling.padding(tab_container).PaddingTop = UDim.new(0, 50)

	local function generate(contents: pinboard_shared.Board)
		if current_view then
			current_view:Destroy()
		end
		stored_buttons = {}
		selected_buttons = {}
		-- select_mode = false
		local scrolling_container = empty_frame(outer_container)
		local vbox = styling.vbox(scrolling_container)
		vbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
		vbox.VerticalFlex = Enum.UIFlexAlignment.Fill
		do
			label(`<b>{name}</b>\n{#contents} Pins`, scrolling_container).Size = UDim2.new(1, 0, 0, 32)
		end

		local container = scrolling_frame(scrolling_container, "Grid")
		-- container.AutomaticSize = Enum.AutomaticSize.Y
		buy_asset_button(container, contents)
		local tally = 0
		for index, value in contents do
			if value.Price then
				tally += value.Price
			end
			local button: TextButton
			button = asset_button({
				-- asset_id = value.Id,
				-- asset_type = value.ItemType,
				-- price = 0,
				asset = value,
				parent = container,
				on_click = function()
					if not select_mode then
						singletons.event_bus.avatar_item_selected.emit({
							asset_info = value,
						})
					else
						local selected = selected_buttons[index] ~= nil
						if selected then
							selected = false
							selected_buttons[index] = nil
						else
							selected = true
							selected_buttons[index] = true
						end
						lune.theme_manager:force_highlight(button, selected)
						local more_than_one_selection = false
						for selected in selected_buttons do
							more_than_one_selection = true
							break
						end
						event_bus.topbar_visibility_custom_button.emit({
							button_id = { "pin_move", "pin_remove" },
							show = more_than_one_selection,
						})
					end
				end,
			})

			local header = asset_button_header(value, { ["Favourite"] = false, ["Remove"] = true }, button)
			stored_buttons[index] = {
				button = button,
				header = header,
			}
			if select_mode then
				header.Visible = false
			end
		end
		robux_counter.Text = tally
		current_view = scrolling_container
	end
	local contents = pinboard_shared.pinboard_data.data[name]
	event_bus.topbar_register_custom_button.emit({
		allowed_overlay = "Favourites",
		image = 107708197594475,
		button_id = "pin_select",
		tooltip = "Select Pins",
		has_state = true,
		on_click = function(state)
			for _, button in stored_buttons do
				button.header.Visible = not state
				if not state then
					lune.theme_manager:force_highlight(button.button, false)
				end
			end
			select_mode = state
			if not state then
				selected_buttons = {}
				event_bus.topbar_visibility_custom_button.emit({
					button_id = { "pin_move", "pin_remove" },
					show = false,
				})
			end
			return
		end,
	})
	event_bus.topbar_visibility_custom_button.emit({ button_id = "pin_select", show = true })

	event_bus.topbar_register_custom_button.emit({
		allowed_overlay = "Favourites",
		image = 72997579114213,
		button_id = "pin_move",
		tooltip = "Move selected Pins",
		on_click = function(state)
			local to_save = {}
			for selected in selected_buttons do
				table.insert(to_save, contents[selected])
			end
			singletons.event_bus.topbar_set_state.emit({ button_id = "pin_select", state = false })
			singletons.event_bus.save_pinboard.emit({ asset_info = to_save, operation = "Move", move_src = name })
			return
		end,
	})
	event_bus.topbar_register_custom_button.emit({
		allowed_overlay = "Favourites",
		image = 96060799177234,
		button_id = "pin_remove",
		tooltip = "Remove selected Pins",
		on_click = function(state)
			local to_remove = {}
			for selected in selected_buttons do
				table.insert(to_remove, contents[selected].Id)
			end
			lune.window.option({
				title = "Delete Pin Confirmation",
				prompt_text = `Are you sure you want to delete {#to_remove} pins?`,
				options = { "Yes", "No" },
				on_prompt_result = function(result)
					if result == "Yes" then
						pinboard_shared.remove_pin(name, to_remove)
						singletons.event_bus.topbar_set_state.emit({ button_id = "pin_select", state = false })
					end
				end,
				important = true,
				custom_embed = outer_container,
			})

			return
		end,
	})
	event_bus.topbar_register_custom_element.emit({
		allowed_overlay = "Favourites",
		button_id = "favourites_robux",
		element = robux_counter,
		location = "right",
	})
	event_bus.topbar_visibility_custom_button.emit({
		button_id = "favourites_robux",
		show = true,
	})
	local on_pinboard_save = event_bus.save_pinboard_success.connect(function(parm: {})
		contents = pinboard_shared.pinboard_exists(name)
		generate(contents)
	end)
	event_bus.topbar_visibility_custom_button.emit({
		button_id = { "pin_move", "pin_remove" },
		show = false,
	})
	outer_container.Destroying:Connect(function(...)
		event_bus.topbar_unregister_custom_button.emit({
			button_id = { "pin_select", "pin_move", "pin_remove", "favourites_robux" },
		})
		on_pinboard_save:Disconnect()
	end)
	generate(contents)
	return tab_container
end
