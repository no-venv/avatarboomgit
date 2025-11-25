local div = Instance.new("Frame")
div.Size = UDim2.new(1,0,0,1)
div.Transparency = 0.67
div.BackgroundColor3 = Color3.new()
return function(parent : Instance?)
	local clone = div:Clone()
	clone.Parent = parent
	return clone
end