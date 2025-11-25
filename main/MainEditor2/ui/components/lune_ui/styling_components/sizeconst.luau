return function(parent : Instance?,min : Vector2, max : Vector3)
	local size_const = Instance.new("UISizeConstraint")
	size_const.MinSize = min;
	size_const.MaxSize = max;
	size_const.Parent = parent
	return size_const
end