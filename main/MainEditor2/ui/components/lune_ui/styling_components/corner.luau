local ui_corner = Instance.new("UICorner")
ui_corner.CornerRadius = UDim.new(0,14)
return function(parent : Instance?)
	local clone = ui_corner:Clone()
	clone.Parent = parent
	return clone
end
