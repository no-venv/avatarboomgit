return {
	render = function(prop)
		local skin_brick_colour = require(script.Parent)(prop.target)
		skin_brick_colour.on_brick_colour_click = function(colour)
			print(colour)
		end
		return function()
			skin_brick_colour.instance:Destroy()
		end
	end,
}