local frame = Instance.new("Frame")
frame.Transparency = 1
frame.Size = UDim2.new(1,0,1,0)
return function(parent : Instance?)
	local clone = frame:Clone()
	clone.Parent = parent
	return clone
end