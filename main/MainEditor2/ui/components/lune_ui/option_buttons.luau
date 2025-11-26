local empty_frame = require("./empty_frame")
local textbutton = require("./textbutton")
local theme_manager = require("./theme_manager")
local utils = require("./utils")
return function(parent : Instance?,options : {string},value_chosen : (value : string) -> nil)
	local container = empty_frame()
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.Size = UDim2.new(1,0,0,0)
	local horiz_list_layout = Instance.new("UIListLayout")
	horiz_list_layout.FillDirection = Enum.FillDirection.Horizontal
	horiz_list_layout.Padding = UDim.new(0,8)
	horiz_list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	horiz_list_layout.Wraps = true
	horiz_list_layout.Parent = container
	local buttons = {}
	local selected_button : TextButton? = nil
	local selected_option : string? = nil
	
	local self = {
		get = function()
			return selected_option
		end,
		set = function(selection : string)
			if selected_button then
				theme_manager:force_highlight(selected_button,false)
			end
			local button = buttons[selection]
			if not button then
				return
			end
			selected_button = button
			theme_manager:force_highlight(selected_button,true)
		end,
	}
	for _,option in options do
		local button : TextButton
		button = textbutton(option,container,function(): nil
			self.set(option)
			value_chosen(option)	
			return
		end)
		buttons[option] = button
	end
	
	utils.prop_scope.auto_set_property(container)
	if parent then
		container.Parent = parent
	end
	return container,self
end
