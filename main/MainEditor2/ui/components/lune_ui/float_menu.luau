local empty_frame = require("./empty_frame")
local styling = require("./styling_components")
local theme_manager = require("./theme_manager")
local lune_overlay = require("./lune_overlay")
return function(view: Frame, width: number?, x: number, y: number)
	local container = empty_frame()
	container.Position = UDim2.new(0, x, 0, y)
	container.Size = UDim2.new(0, width or 120, 0, 0)
	container.AutomaticSize = Enum.AutomaticSize.Y
	-- styling.vbox(container).HorizontalFlex = Enum.UIFlexAlignment.Fill
	-- styling.corner(container)
	-- styling.stroke(container)
	-- styling.padding(container)
	theme_manager:add_custom_gui_instance(container, "Foreground")
	view.Parent = container
	container.Parent = lune_overlay
	return container
end
