local styling = require("./styling_components")
local theme_manager = require("./theme_manager")
local utils = require("./utils")
local button = Instance.new("TextButton")
button.AutomaticSize = Enum.AutomaticSize.X
button.AutoButtonColor = false
button.Size = UDim2.new(0, 0, 0, 32)
button.TextScaled = true
button.TextSize = 1
button.TextWrapped = true
styling.corner(button)
styling.stroke(button)
styling.font(button)
styling.padding(button)
return function(text: string, parent: Instance?, connect_func)
	local clone = button:Clone()
	if connect_func then
		clone.MouseButton1Click:Connect(connect_func)
	end
	theme_manager:add_custom_gui_instance(clone, "Foreground")
	theme_manager:add_highlight(clone)
	utils.prop_scope.auto_set_property(clone)
	clone.Text = text
	if parent then
		clone.Parent = parent
	end
	return clone
end
