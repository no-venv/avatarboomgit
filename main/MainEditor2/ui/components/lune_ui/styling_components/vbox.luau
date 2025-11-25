local vert_layout = Instance.new("UIListLayout")
vert_layout.Padding = UDim.new(0,8)
vert_layout.SortOrder = Enum.SortOrder.LayoutOrder
return function(parent : Instance?)
	local clone = vert_layout:Clone()
	clone.Parent = parent
	return clone
end