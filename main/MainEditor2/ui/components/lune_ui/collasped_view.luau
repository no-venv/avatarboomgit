local textbutton = require("./textbutton")
local empty_frame = require("./empty_frame")
local theme_manager = require("./theme_manager")
return function(name: string, view: Frame, parent: Instance?)
	local container = empty_frame()
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.Size = UDim2.new(1, 0, 0, 0)
	container.Parent = parent
	local vbox_layout = Instance.new("UIListLayout")
	vbox_layout.HorizontalFlex = Enum.UIFlexAlignment.Fill
	vbox_layout.SortOrder = Enum.SortOrder.LayoutOrder
	vbox_layout.Padding = UDim.new(0, 8)
	vbox_layout.Parent = container
	local button = textbutton(name, container, function()
		view.Visible = not view.Visible
	end)
	view.Parent = container
	view.Visible = false
	view:GetPropertyChangedSignal("Visible"):Connect(function(...: any)
		theme_manager:force_highlight(button, view.Visible)
	end)
	return container
end
