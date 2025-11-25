local event_frames = require(script.Parent)
return {
	render = function(prop)
		local container = Instance.new("Frame")
		local list_layout = Instance.new("UIListLayout")
		list_layout.SortOrder = Enum.SortOrder.LayoutOrder
		list_layout.Parent = container
		container.Size = UDim2.new(1,0,1,0)
		container.Transparency = 1
		container.Parent = prop.target
		-- 
		event_frames.error(container)
		event_frames.spinner(container)
		return function()
			container:Destroy()
		end
	end,
}