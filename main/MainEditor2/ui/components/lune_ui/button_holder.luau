type arg = {
	parent: Instance?,
	left: { Instance }?,
	centre: { Instance }?,
	right: { Instance }?,
}
local empty_frame = require("./empty_frame")
local styling = require("./styling_components")

return function(arg: arg)
	local button_container = empty_frame(arg.parent)
	button_container.Size = UDim2.new(1, 0, 0, 48)
	do
		local hbox = styling.hbox(button_container)
		hbox.HorizontalFlex = Enum.UIFlexAlignment.Fill
	end
	local button_container_left = empty_frame(button_container)
	styling.hbox(button_container_left)
	local button_container_centre = empty_frame(button_container)
	do
		local hbox = styling.hbox(button_container_centre)
		hbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
	end
	local button_container_right = empty_frame(button_container)
	do
		local hbox = styling.hbox(button_container_right)
		hbox.HorizontalAlignment = Enum.HorizontalAlignment.Right
	end

	if arg.left then
		for _, elm in arg.left do
			elm.Parent = button_container_left
		end
	end

	if arg.centre then
		for _, elm in arg.centre do
			elm.Parent = button_container_centre
		end
	end

	if arg.right then
		for _, elm in arg.right do
			elm.Parent = button_container_right
		end
	end

	return button_container, button_container_left, button_container_centre, button_container_right
end
