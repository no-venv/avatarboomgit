local theme_manager = require("./theme_manager")
local styling = require("./styling_components")
local utils = require("./utils")
local textlabel = Instance.new("TextLabel")
textlabel.AutomaticSize = Enum.AutomaticSize.XY
textlabel.BackgroundTransparency = 1
textlabel.BorderSizePixel = 0
textlabel.RichText = true
textlabel.TextSize = 16
textlabel.TextWrapped = true
--textlabel.TextScaled = false
textlabel.TextColor3 = Color3.new()
textlabel.Size = UDim2.new(0,0,0,32)
styling.font(textlabel)
return function(text :string, parent : Instance?)
	local label_clone = textlabel:Clone()
	theme_manager:add_custom_gui_instance(label_clone,"Background")
	utils.prop_scope.auto_set_property(label_clone)
	label_clone.Text = text
	if parent then
		label_clone.Parent = parent
	end
	return label_clone
end
