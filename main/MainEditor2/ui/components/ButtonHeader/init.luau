local lune = require("@self/../lune_ui")
export type Button = {
	id: number,
	id_states: { number }?,
	on_click: () -> number | nil,
}
type Arguments = {
	parent: GuiBase,
	left_topbar: { Button },
	right_topbar: { Button },
}

local image_button = Instance.new("ImageButton")
image_button.BackgroundTransparency = 1
image_button.Size = UDim2.new(1, 0, 1, 0)
do
	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio = 1
	aspect.Parent = image_button
end

local button_container_temp = lune.empty_frame()
button_container_temp.Size = UDim2.new(1, 0, 0, 24)

local function ibutton(parent, image, func, state)
	local button = image_button:Clone()
	button.Parent = parent
	button.ImageContent = Content.fromAssetId(image)
	button.MouseButton1Click:Connect(function(...)
		local icon_img = func()
		if icon_img then
			button.ImageContent = Content.fromAssetId(state[icon_img])
		else
			button.ImageContent = Content.fromAssetId(image)
		end
	end)
	lune.theme_manager:add_custom_gui_instance(button, "Foreground")
	lune.theme_manager:add_highlight(button)
	return button
end
return function(args: Arguments)
	local container = lune.empty_frame()
	container.Size = UDim2.new(1, 0, 0, 24)
	lune.styling.hbox(container).HorizontalFlex = Enum.UIFlexAlignment.Fill
	local left_topbar = lune.empty_frame(container)
	local right_topbar = lune.empty_frame(container)
	lune.styling.hbox(left_topbar)
	lune.styling.hbox(right_topbar).HorizontalAlignment = Enum.HorizontalAlignment.Right
	local buttons = {}
	local button_image_to_index_lookup = {}
	for index, topbar_button in args.left_topbar do
		table.insert(buttons, {
			button = ibutton(left_topbar, topbar_button.id, topbar_button.on_click, topbar_button.id_states),
			state = topbar_button.id_states,
		})
		button_image_to_index_lookup[topbar_button.id] = #buttons
	end
	for index, topbar_button in args.right_topbar do
		table.insert(buttons, {
			button = ibutton(right_topbar, topbar_button.id, topbar_button.on_click, topbar_button.id_states),
			state = topbar_button.id_states,
		})
		button_image_to_index_lookup[topbar_button.id] = #buttons
	end
	container.Parent = args.parent
	lune.theme_manager:on_highlight(args.parent, function(enabled: boolean)
		for _, button in buttons do
			lune.theme_manager:force_highlight(button.button, enabled)
		end
	end)
	local self = {
		set_button_image_state = function(image: number, id: number | nil)
			local button = buttons[button_image_to_index_lookup[image]]
			if id then
				button.button.ImageContent = Content.fromAssetId(button.state[id])
			else
				button.button.ImageContent = Content.fromAssetId(image)
			end
		end,
	}
	return container, self
end
