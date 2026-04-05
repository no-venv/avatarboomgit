local view = require("../Composer")
return {
	render = function(prop)
		local instance = view(prop.target)
		instance.Visible = true
		return function()
			instance:Destroy()
		end
	end,
}
