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

return function(parent: Instance?, scrolling_type: ("List" | "Grid" | "None")?, override: {}?, on_reached_end: ((root : ScrollingFrame) -> boolean)?)
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
		for prop, value in override :: any do
			selected_layout[prop] = value
		end
	end
	if parent then
		clone.Parent = parent
	end
	utils.prop_scope.auto_set_property(clone)
	if on_reached_end then
		local mutex = false
		local function update_canvas()
			if mutex then
				return
			end
			local Y = (clone.CanvasPosition.Y + clone.AbsoluteWindowSize.Y) / clone.AbsoluteCanvasSize.Y
			if Y >= 0.90 and not mutex then
				local TargetSize = clone.AbsoluteWindowSize.Y + clone.AbsoluteCanvasSize.Y
				mutex = true
				while true do
					local should_continue = on_reached_end(clone)
					if (clone.AbsoluteCanvasSize.Y >= TargetSize) or not should_continue then
						break
					end
				end
				mutex = false
			end
		end
		update_canvas()
		local canvas_size_change = clone:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(update_canvas)
		local canvas_position_change = clone:GetPropertyChangedSignal("CanvasPosition")
		canvas_position_change:Connect(update_canvas)
	end
	return clone
end
