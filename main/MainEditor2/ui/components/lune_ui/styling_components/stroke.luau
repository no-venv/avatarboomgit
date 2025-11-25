local stroke = Instance.new("UIStroke")
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
stroke.Transparency = 0.67
stroke.Color = Color3.new()
return function(parent : Instance?)
	local clone = stroke:Clone()
	clone.Parent = parent
	return clone
end