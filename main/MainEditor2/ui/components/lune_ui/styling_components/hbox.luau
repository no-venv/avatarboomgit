local horz_layout = Instance.new("UIListLayout")
horz_layout.Padding = UDim.new(0,8)
horz_layout.FillDirection = Enum.FillDirection.Horizontal
horz_layout.SortOrder = Enum.SortOrder.LayoutOrder
return function(parent : Instance?)
	local clone = horz_layout:Clone()
	clone.Parent = parent
	return clone
end