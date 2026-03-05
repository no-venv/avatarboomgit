local styling = require("./styling_components")
local utils = require("./utils")
local scrolling_frame = Instance.new("ScrollingFrame")
scrolling_frame.Size = UDim2.new(1, 0, 1, 0)
scrolling_frame.BackgroundTransparency = 1
scrolling_frame.BorderSizePixel = 1
scrolling_frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrolling_frame.CanvasSize = UDim2.new()
scrolling_frame.ScrollBarThickness = 1
scrolling_frame.ScrollingDirection = Enum.ScrollingDirection.Y

return function(parent: Instance?, scrolling_type: ("List" | "Grid")?, override: (UIGridStyleLayout)?)
	scrolling_type = scrolling_type or "List"
	local clone = scrolling_frame:Clone()
	local selected_layout: UIGridStyleLayout
	if scrolling_type == "Grid" then
		selected_layout = styling.grid(clone)
	end
	if scrolling_type == "List" then
		selected_layout = styling.vbox(clone)
	end
	if override and selected_layout then
		for prop, value in override do
			selected_layout[prop] = value
		end
	end
	if parent then
		clone.Parent = parent
	end
	utils.prop_scope.auto_set_property(clone)
	return clone
end
