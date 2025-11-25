local grid_layout = Instance.new("UIGridLayout")
grid_layout.CellPadding = UDim2.new(0,5,0,5)
grid_layout.CellSize = UDim2.new(0,135,0,135)
grid_layout.SortOrder = Enum.SortOrder.LayoutOrder
grid_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
return function(parent : Instance?)
	local clone = grid_layout:Clone()
	clone.Parent = parent
	return clone
end