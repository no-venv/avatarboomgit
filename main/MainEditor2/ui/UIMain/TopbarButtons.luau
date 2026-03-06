local singletons = require("../../singletons")
local components = require("../components")
local lune = components.lune_ui
local empty_frame = lune.empty_frame
local styling = lune.styling
local theme_manager = lune.theme_manager
local iconbutton = lune.iconbutton
local textbutton = lune.textbutton
local textbox = lune.textbox
local function state()
	local first = false
	local consumed: string = nil
	local output = {
		output = "None",
	}
	local set_state = function(state: string)
		if consumed ~= state then
			consumed = state
			first = false
		end
		if not consumed then
			output.output = "None"
			return "None"
		end
		first = not first
		output.output = first and consumed or "None"
		return output.output
	end
	return set_state, output
end
--
local container = empty_frame()
container.Size = UDim2.new(1, 0, 0, 48)
container.BackgroundTransparency = 0
container.ZIndex = 10
do
	local gradient_background = Instance.new("UIGradient")
	gradient_background.Rotation = 90
	gradient_background.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.8, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
	gradient_background.Parent = container
	theme_manager:add_custom_gui_instance(gradient_background, "Foreground")
	styling.corner(container)
	styling.padding(container)
	local flex = Instance.new("UIListLayout")
	flex.HorizontalFlex = Enum.UIFlexAlignment.Fill
	flex.SortOrder = Enum.SortOrder.LayoutOrder
	flex.FillDirection = Enum.FillDirection.Horizontal
	flex.Parent = container
end

local button_container_layout = Instance.new("UIListLayout")
button_container_layout.Padding = UDim.new(0, 8)
button_container_layout.FillDirection = Enum.FillDirection.Horizontal
button_container_layout.SortOrder = Enum.SortOrder.LayoutOrder
local button_container = empty_frame()
button_container.Size = UDim2.new(0.5, 0, 1, 0)
--
return function(parent: Instance?)
	local state, state_status = state()
	local dropdown_state = false
	local topbar_container = container:Clone()
	local left_button_container = button_container:Clone()
	left_button_container.Parent = topbar_container
	local custom_button_container = empty_frame(left_button_container)
	custom_button_container.AutomaticSize = Enum.AutomaticSize.X
	custom_button_container.Size = UDim2.new(0, 0, 1, 0)
	do
		local layout = button_container_layout:Clone()
		layout.Parent = custom_button_container
		layout.HorizontalFlex = Enum.UIFlexAlignment.Fill
	end
	local search_container = empty_frame(topbar_container)
	search_container.Size = UDim2.new(1, 0, 1, 0)
	local search = textbox("search or paste ID here", search_container)
	search.Size = UDim2.new(1, 0, 1, 0)
	search.ClearTextOnFocus = false
	search.FocusLost:Connect(function(enterPressed: boolean, inputThatCausedFocusLoss: InputObject)
		if not enterPressed then
			return
		end
		local query = search.Text

		singletons.event_bus.catalog_search.emit({
			query = query,
		})
	end)

	local right_button_container = button_container:Clone()
	right_button_container.Parent = topbar_container

	do
		local left_layout = button_container_layout:Clone()
		left_layout.Parent = left_button_container
		local right_layout = button_container_layout:Clone()
		right_layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		right_layout.Parent = right_button_container
	end
	local dropdown_button = iconbutton({
		id = 134883261664446,
		parent = custom_button_container,
		theme_enabled = true,
		on_click = function()
			dropdown_state = not dropdown_state
			singletons.event_bus.drawer_open.emit({
				bool = dropdown_state,
			})
		end,
	})

	local catalog_button = iconbutton({
		id = 122758973653468,
		parent = right_button_container,
		theme_enabled = true,
		on_click = function()
			singletons.event_bus.catalog_show_overlay.emit({ overlay = "None" })
		end,
	})
	local favourites_button = iconbutton({
		id = 106335234167054,
		parent = right_button_container,
		theme_enabled = true,
		on_click = function()
			singletons.event_bus.catalog_show_overlay.emit({
				overlay = state("Favourites"),
			})
		end,
	})
	local wearing_button = iconbutton({
		id = 112085719237258,
		parent = right_button_container,
		theme_enabled = true,
		on_click = function()
			singletons.event_bus.catalog_show_overlay.emit({
				overlay = state("Wearing"),
			})
		end,
	})

	local custom_buttons = {}
	singletons.event_bus.topbar_register_custom_button.connect(function(parm)
		local button = iconbutton({
			id = parm.image,
			parent = custom_button_container,
			theme_enabled = true,
			on_click = function()
				local button = custom_buttons[parm.button_id]
				if parm.has_state then
					custom_buttons[parm.button_id].state = not button.state
					theme_manager:force_highlight(button.button, button.state)
				end
				parm.on_click(button.state)
			end,
		})

		button.Visible = state_status.output == parm.allowed_overlay
		custom_buttons[parm.button_id] = {
			button = button,
			allowed_overlay = parm.allowed_overlay,
			stored_visible_state = false,
			state = false,
			on_click = parm.on_click,
		}
	end)
	singletons.event_bus.topbar_unregister_custom_button.connect(function(parm)
		local button_ids = {}
		if type(parm.button_id) == "string" then
			button_ids = { parm.button_id }
		else
			button_ids = parm.button_id
		end
		for _, button_id in button_ids do
			local button = custom_buttons[button_id]
			button.button:Destroy()
			custom_buttons[button_id] = nil
		end
	end)
	singletons.event_bus.topbar_visibility_custom_button.connect(function(parm)
		local button_ids = {}
		if type(parm.button_id) == "string" then
			button_ids = { parm.button_id }
		else
			button_ids = parm.button_id
		end
		for _, button_id in button_ids do
			local button = custom_buttons[button_id]
			if state_status.output == button.allowed_overlay then
				button.button.Visible = parm.show
			end
			button.stored_visible_state = parm.show
		end
	end)
	singletons.event_bus.topbar_set_state.connect(function(parm)
		local button = custom_buttons[parm.button_id]
		button.state = parm.state
		theme_manager:force_highlight(button.button, parm.state)
		button.on_click(parm.state)
	end)

	-- overflow check
	local function overflow_check()
		local left_container_right_pos = custom_button_container.AbsoluteSize.X
			+ custom_button_container.AbsolutePosition.X
		local search_bar_left_pos = search_container.AbsolutePosition.X
		if left_container_right_pos > search_bar_left_pos then
			search.Visible = false
		else
			search.Visible = true
		end
	end
	custom_button_container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function(...)
		overflow_check()
	end)
	topbar_container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function(...)
		overflow_check()
	end)
	singletons.event_bus.drawer_open.connect(function(parm): nil
		if not parm.bool then
			dropdown_state = false
		end

		theme_manager:force_highlight(dropdown_button, parm.bool)
		--ui_lib.theme_manager:force_highlight(topbar.LeftButtons.Dropdown,parm.bool)
		return
	end)
	singletons.event_bus.avatar_item_selected.connect(function(parm): nil
		theme_manager:force_highlight(dropdown_button, false)
		--ui_lib.theme_manager:force_highlight(topbar.LeftButtons.Dropdown,false)
		dropdown_state = false
		return
	end)
	-- singletons.event_bus.catalog_set_search_filter.connect(function(parm)
	-- 	creator_filter_button.Text = parm.CreatorName
	-- 	creator_filter_button.Visible = not (parm.CreatorName == "")
	-- end)
	singletons.event_bus.catalog_show_overlay.connect(function(parm): nil
		theme_manager:force_highlight(catalog_button, parm.overlay == "None")
		theme_manager:force_highlight(favourites_button, parm.overlay == "Favourites")
		theme_manager:force_highlight(wearing_button, parm.overlay == "Wearing")
		--ui_lib.theme_manager:force_highlight(topbar.RightButtons.Favourites,parm.overlay=="Favourites")
		--ui_lib.theme_manager:force_highlight(topbar.RightButtons.ViewWearing,parm.overlay=="Wearing")
		if parm.overlay == "None" then
			state("None")
		end
		for _, button in custom_buttons do
			if button.allowed_overlay == parm.overlay then
				button.button.Visible = button.stored_visible_state
			else
				button.button.Visible = false
			end
		end
		return
	end)

	topbar_container.Parent = parent
	return container
end
