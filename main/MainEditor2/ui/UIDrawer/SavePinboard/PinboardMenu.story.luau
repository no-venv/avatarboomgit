local save_to_pinboard = require("../SavePinboard")
return {
	render = function(props)
		local instance = save_to_pinboard(props.target)
		return function()
			instance:Destroy()
		end
	end,
}
