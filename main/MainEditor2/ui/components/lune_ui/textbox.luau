local styling = require("./styling_components")
local theme_manager = require("./theme_manager")
local utils = require("./utils")
local textbox = Instance.new("TextBox")
textbox.Size = UDim2.new(0, 240, 0, 32)
textbox.BorderColor3 = Color3.new()
textbox.TextSize = 16
textbox.PlaceholderColor3 = Color3.new(0, 0, 0)
textbox.TextWrapped = true
textbox.RichText = true
textbox.Text = ""
textbox.TextScaled = false
styling.corner(textbox)
styling.font(textbox)
return function(background_text: string, parent: Instance?, on_text: ((text: string, enter_pressed: boolean) -> any)?)
	local clone = textbox:Clone()
	clone.PlaceholderText = background_text
	styling.stroke(clone)
	theme_manager:add_custom_gui_instance(clone, "Foreground")
	utils.prop_scope.auto_set_property(clone)
	if parent then
		clone.Parent = parent
	end
	if on_text then
		clone.FocusLost:Connect(function(enter: boolean)
			if enter then
				on_text(clone.Text, true)
			end
		end)
		clone:GetPropertyChangedSignal("Text"):Connect(function(...)
			on_text(clone.Text, false)
		end)
	end
	return clone
end
