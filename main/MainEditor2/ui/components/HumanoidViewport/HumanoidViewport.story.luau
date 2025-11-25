local hum_viewport = require(script.Parent)
return {
	render = function(props)
		local viewport = hum_viewport(props.target)
		return function()
			viewport.instance:Destroy()
		end
	end,
}