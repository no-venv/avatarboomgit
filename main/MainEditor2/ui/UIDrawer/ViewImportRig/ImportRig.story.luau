local import_rig = require(script.Parent)
return {
	render = function(props)
		local import_rig_instance = import_rig(props.target)
		import_rig_instance.Visible = true
		return function()
			import_rig_instance:Destroy()
		end
	end,
}