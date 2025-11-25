local wheel = require(script.Parent.Parent.ColourWheel)
return {
	render = function(props)
		
		local instance = wheel(props.target)
		instance.instance.Size = UDim2.new(0,200,0,200)
		--local component = Instance.new("Frame")
		--component.Size = UDim2.fromOffset(200, 100)
		--component.Visible = true
		--component.Parent = props.target
		--instance.on_colour = function(color)
		--	print(color)
		--end
		return function()
			instance.instance:Destroy()
		end
	end,
}