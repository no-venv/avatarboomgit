local edit_rig = require(script.Parent.Init)
return {
	render = function(prop)
		local edit_rig_instance = edit_rig(prop.target)
		edit_rig_instance.Visible = true
		return function()
			edit_rig_instance:Destroy()
		end
	end,
}