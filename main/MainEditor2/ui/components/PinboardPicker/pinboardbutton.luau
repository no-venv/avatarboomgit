type arg = {
	assets: {
		{
			asset_id: number,
			asset_type: "Asset" | "Bundle",
		}
	},
	name: string,
	parent: Instance?,
	on_click: (() -> nil)?,
	on_rename: (() -> nil)?,
	on_share: (() -> nil)?,
	on_remove: (() -> nil)?,
}
local TweenService = game:GetService("TweenService")
local lune = require("../lune_ui")
local iconbutton = lune.iconbutton
local empty_frame = lune.empty_frame
local textlabel = lune.textlabel
local styling = lune.styling
local shadow = Instance.new("ImageLabel")
local zero_udim = UDim.new(0, 0)
local container_udim = UDim2.new(0, 135, 0, 135)
local tween_data = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, true)
shadow.Size = UDim2.new(1, 0, 1, 18)
shadow.ImageContent = Content.fromAssetId(186491278)
shadow.ImageTransparency = 0.36
shadow.BackgroundTransparency = 1
shadow.BorderSizePixel = 0
shadow.ZIndex = -2

local image_button = Instance.new("ImageButton")
image_button.BackgroundTransparency = 1
image_button.Size = UDim2.new(1, 0, 1, 0)
do
	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio = 1
	aspect.Parent = image_button
end

local button_container_temp = empty_frame()
button_container_temp.Size = UDim2.new(1, 0, 0, 24)
do
	local h_list = Instance.new("UIListLayout")
	h_list.Padding = UDim.new(0, 6)
	h_list.HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween
	h_list.FillDirection = Enum.FillDirection.Horizontal
	h_list.SortOrder = Enum.SortOrder.LayoutOrder
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 3)
	padding.PaddingRight = UDim.new(0, 3)
	padding.PaddingTop = UDim.new(0, 3)
	h_list:Clone().Parent = button_container_temp
	padding:Clone().Parent = button_container_temp
end

local function ibutton(parent, image, func)
	local button = image_button:Clone()
	button.Parent = parent
	button.ImageContent = Content.fromAssetId(image)
	button.MouseButton1Click:Connect(func)
	lune.theme_manager:add_custom_gui_instance(button, "Foreground")
	return button
end

return function(arg: arg): TextButton
	local name = arg.name
	local parent = arg.parent
	local on_click = arg.on_click
	local on_rename = arg.on_rename
	local on_share = arg.on_share
	local on_remove = arg.on_remove
	local asset_urls = {}
	for _, asset in arg.assets do
		table.insert(asset_urls, `rbxthumb://type={asset.asset_type}&id={asset.asset_id}&w=420&h=420`)
	end
	local asset_button = iconbutton({
		parent = parent,
		id = asset_urls,
		theme_enabled = false,
		on_click = function()
			if on_click then
				on_click()
			end
		end,
	})

	asset_button.Size = container_udim

	local label = textlabel(name, asset_button)
	label.AnchorPoint = Vector2.new(0, 1)
	label.Position = UDim2.new(0, 8, 1, 0)
	label.TextYAlignment = Enum.TextYAlignment.Bottom

	local top_buttons_container = button_container_temp:Clone()
	top_buttons_container.ZIndex = 10
	top_buttons_container.Parent = asset_button
	do
		local left_container = empty_frame(top_buttons_container)
		left_container.AutomaticSize = Enum.AutomaticSize.X
		styling.hbox(left_container)
		if on_rename then
			ibutton(left_container, 111453011062900, on_rename)
		end
		-- share
		-- if on_share then
		-- 	ibutton(left_container, 103742597823204, on_share)
		-- end
	end

	do
		if on_remove then
			ibutton(top_buttons_container, 96060799177234, on_remove)
		end
	end
	return asset_button
end
