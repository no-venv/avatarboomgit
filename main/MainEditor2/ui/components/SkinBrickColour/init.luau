local skin_colour_json = require("@self/skin_colour_json")()
return function(parent : Instance)
	local scrolling_frame = Instance.new("ScrollingFrame")
	scrolling_frame.Size = UDim2.new(1,0,1,0)
	scrolling_frame.Transparency = 1
	scrolling_frame.BorderSizePixel = 0
	scrolling_frame.ScrollBarThickness = 1
	scrolling_frame.CanvasSize = UDim2.new()
	scrolling_frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrolling_frame.Parent = parent
	local self = {
		instance = scrolling_frame;
		on_brick_colour_click = function(colour3 : Color3)

		end,
	}
	
	local grid_layout = Instance.new("UIGridLayout")
	grid_layout.CellSize = UDim2.new(0,48,0,48)
	grid_layout.Parent = scrolling_frame
	grid_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local ui_corner = Instance.new("UICorner")
	ui_corner.CornerRadius = UDim.new(0,8)
	
	for _,colour in skin_colour_json do
		local button = Instance.new("TextButton")
		button.BackgroundColor3 = colour
		button.Text = ""
		button.MouseButton1Click:Connect(function() 
			self.on_brick_colour_click(colour)	
		end)
		ui_corner:Clone().Parent = button
		button.Parent = scrolling_frame
	end
	
	return self
end
