type arg = {
	parent: Instance?,
	id: number | string | { number | string },
	theme_enabled: boolean?,
	on_click: () -> (),
}
local textbutton = require("./textbutton")
local theme_manager = require("./theme_manager")
local aspect_ratio = Instance.new("UIAspectRatioConstraint")
aspect_ratio.AspectRatio = 1
aspect_ratio.AspectType = Enum.AspectType.ScaleWithParentSize
aspect_ratio.DominantAxis = Enum.DominantAxis.Height
local function new_image(id: number | string): ImageLabel
	local image = Instance.new("ImageLabel")
	image.Transparency = 1
	image.AnchorPoint = Vector2.new(0.5, 0.5)
	image.Position = UDim2.new(0.5, 0, 0.5, 0)
	image.Size = UDim2.new(1, 0, 1, 0)
	image.ImageContent = type(id) == "string" and Content.fromUri(id) or Content.fromAssetId(id :: number)
	return image
end
local image_positioning = {
	{
		UDim2.new(0.2, 0, 0.5, 0),
		UDim2.new(0.45, 0, 0.45, 0),
		-35,
		-1,
	},

	{
		UDim2.new(0.5, 0, 0.5, 0),
		UDim2.new(0.6, 0, 0.6, 0),
		0,
		1,
	},
	{
		UDim2.new(0.8, 0, 0.5, 0),
		UDim2.new(0.45, 0, 0.45, 0),
		35,
		-1,
	},
}
return function(arg: arg)
	local parent = arg.parent
	local id = arg.id
	local theme_enabled = arg.theme_enabled
	local func = arg.on_click
	local clone = textbutton("", parent, func)
	clone.AutomaticSize = Enum.AutomaticSize.None
	local created_images = {}
	if type(id) == "table" then
		if #id == 1 then
			local image = new_image(id[1])
			image.Parent = clone
			table.insert(created_images, image)
		else
			for index, value in id do
				local pos = image_positioning[index]
				local image = new_image(value)
				image.Position = pos[1]
				image.Size = pos[2]
				image.Rotation = pos[3]
				image.ZIndex = pos[4]
				image.Parent = clone
				table.insert(created_images, image)
			end
		end
	else
		local image = new_image(id)
		image.Parent = clone
		table.insert(created_images, image)
	end

	if theme_enabled then
		for _, image in created_images do
			theme_manager:add_custom_gui_instance(image, "Foreground")
			theme_manager:add_highlight(image)
		end
		theme_manager:on_highlight(clone, function(enabled: boolean)
			for _, image in created_images do
				theme_manager:force_highlight(image, enabled)
			end
		end)
	end

	aspect_ratio:Clone().Parent = clone
	clone:GetAttributeChangedSignal("image"):Connect(function()
		created_images[1].Image = clone:GetAttribute("image")
	end)
	return clone
end
