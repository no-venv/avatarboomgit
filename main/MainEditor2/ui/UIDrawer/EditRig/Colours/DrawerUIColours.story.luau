local rig_edit_colours_ui = require(script.Parent)
return {
	render = function(props)

		local instance = rig_edit_colours_ui(props.target)
		return function()
			instance:Destroy()
		end
	end,
}