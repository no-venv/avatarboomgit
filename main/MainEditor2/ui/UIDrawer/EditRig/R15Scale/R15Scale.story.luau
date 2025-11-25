local rig_r15_scale_edit = require(script.Parent)
return {
	render = function(props)

		local instance = rig_r15_scale_edit(props.target)
		return function()
			instance:Destroy()
		end
	end,
}