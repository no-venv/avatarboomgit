type arg = {
	parent: Instance?,
	id: number | string,
	theme_enabled: boolean?,
	on_click: () -> nil,
}
local textbutton = require("./textbutton")
local theme_manager = require("./theme_manager")
local aspect_ratio = Instance.new("UIAspectRatioConstraint")
aspect_ratio.AspectRatio = 1
aspect_ratio.AspectType = Enum.AspectType.ScaleWithParentSize
aspect_ratio.DominantAxis = Enum.DominantAxis.Height
return function(arg: arg)
	local parent = arg.parent
	local id = arg.id
	local theme_enabled = arg.theme_enabled
	local func = arg.on_click
	local image = Instance.new("ImageLabel")
	image.Transparency = 1
	image.AnchorPoint = Vector2.new(0.5, 0.5)
	image.Position = UDim2.new(0.5, 0, 0.5, 0)
	image.Size = UDim2.new(1, 0, 1, 0)
	image.ImageContent = type(id) == "string" and Content.fromUri(id) or Content.fromAssetId(id)
	local clone = textbutton("", parent, func)
	clone.AutomaticSize = Enum.AutomaticSize.None
	image.Parent = clone
	if theme_enabled then
		theme_manager:add_custom_gui_instance(image, "Foreground")
	end
	aspect_ratio:Clone().Parent = clone
	return clone
end
