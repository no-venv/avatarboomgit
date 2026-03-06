local lune = require("@self/../lune_ui")
type Arguments = {
	parent: Frame?,
	left_topbar: {
		{
			id: number,
			on_click: () -> any,
		}
	},
	right_topbar: { { id: number, on_click: () -> any } },
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

local function ibutton(parent, image, func)
	local button = image_button:Clone()
	button.Parent = parent
	button.ImageContent = Content.fromAssetId(image)
	button.MouseButton1Click:Connect(func)
	lune.theme_manager:add_custom_gui_instance(button, "Foreground")
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

	for _, topbar_button in args.left_topbar do
		ibutton(left_topbar, topbar_button.id, topbar_button.on_click)
	end
	for _, topbar_button in args.right_topbar do
		ibutton(right_topbar, topbar_button.id, topbar_button.on_click)
	end
	container.Parent = args.parent
	return container
end
