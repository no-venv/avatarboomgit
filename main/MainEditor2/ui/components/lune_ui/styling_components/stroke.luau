local theme_manager = require("../theme_manager")
local stroke = Instance.new("UIStroke")
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
stroke.Transparency = 0.8
stroke.Color = Color3.new()
local gradient = Instance.new("UIGradient")
gradient.Rotation = -45
gradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0.0, 1.0),
	NumberSequenceKeypoint.new(0.5, 0.0),
	NumberSequenceKeypoint.new(1.0, 1.0),
})
gradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
return function(parent: Instance?)
	-- local stroke_appl = stroke:Clone()
	-- stroke_appl.Color = Color3.new(1, 1, 1)
	-- stroke_appl.Thickness = 0.5
	-- stroke_appl.Transparency = 0.5
	-- -- stroke_appl.Color = gradient
	-- gradient:Clone().Parent = stroke_appl
	-- stroke_appl.Parent = parent
	local clone = stroke:Clone()
	clone.Parent = parent
	theme_manager:add_custom_gui_instance(clone, "Foreground")
	return clone
end
