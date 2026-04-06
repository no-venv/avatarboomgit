local textlabel = require("./textbutton")
local theme = require("./theme_manager")
local overlay = require("./lune_overlay")
local utils = require("./utils")
return function(parent: GuiObject, text: string)
	local tooltip_text = textlabel(text, overlay)
	tooltip_text.AnchorPoint = Vector2.new(0.5, 0)
	tooltip_text.Visible = false

	parent.MouseEnter:Connect(function(a0: number, a1: number)
		tooltip_text.Visible = true
	end)
	parent.MouseLeave:Connect(function(a0: number, a1: number)
		tooltip_text.Visible = false
	end)
	parent.MouseMoved:Connect(function(x: number, y: number)
		local left_out_of_bounds = (x - (tooltip_text.AbsoluteSize.X / 2)) < 0
		local right_out_of_bounds = x + (tooltip_text.AbsoluteSize.X / 2) > overlay.AbsoluteSize.X
		tooltip_text.AnchorPoint = left_out_of_bounds and Vector2.zero
			or right_out_of_bounds and Vector2.new(1, 0)
			or Vector2.new(0.5, 0)

		local pos = utils.normalize_mouse(Vector2.new(x, y), overlay.AbsolutePosition, overlay.AbsoluteSize)
		tooltip_text.Position = UDim2.new(pos.X, 0, pos.Y, 16)
	end)
	theme:force_highlight(tooltip_text, true)
	return tooltip_text
end
