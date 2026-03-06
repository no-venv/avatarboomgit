type arg = {
	price: number,
	asset_id: number,
	asset_type: "Asset" | "Bundle",
	parent: Instance?,
	on_click: (() -> nil)?,
}
local lune = require("@self/../lune_ui")
local iconbutton = lune.iconbutton
local empty_frame = lune.empty_frame
local styling = lune.styling
local shadow = Instance.new("ImageLabel")
local zero_udim = UDim.new(0, 0)
local container_udim = UDim2.new(0, 135, 0, 135)
shadow.Size = UDim2.new(1, 0, 1, 18)
shadow.ImageContent = Content.fromAssetId(186491278)
shadow.ImageTransparency = 0.36
shadow.BackgroundTransparency = 1
shadow.BorderSizePixel = 0
shadow.ZIndex = -2
return function(arg: arg): TextButton
	local price = arg.price
	local asset_id = arg.asset_id
	local asset_type = arg.asset_type
	local parent = arg.parent
	local on_click = arg.on_click
	local container = empty_frame()
	container.Size = container_udim
	local padding = styling.padding(container)
	padding.PaddingTop = zero_udim
	padding.PaddingBottom = zero_udim
	padding.PaddingLeft = zero_udim
	padding.PaddingRight = zero_udim
	if asset_type == "Bundle" then
		asset_type = "BundleThumbnail"
	end
	local asset_button = iconbutton({
		parent = parent,
		id = `rbxthumb://type={asset_type}&id={asset_id}&w=420&h=420`,
		theme_enabled = false,
		on_click = function()
			if on_click then
				on_click()
			end
		end,
	})
	asset_button.Size = container_udim
	return asset_button
end
