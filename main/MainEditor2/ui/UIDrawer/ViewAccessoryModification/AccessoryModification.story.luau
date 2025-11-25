local view = require(script.Parent)
return {
	render = function(prop)
		local instance = view(prop.target)
		instance.Visible = true
		return function()
			instance:Destroy()
		end
	end,
}