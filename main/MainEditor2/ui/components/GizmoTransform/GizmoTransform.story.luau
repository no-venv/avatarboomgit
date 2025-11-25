local gizmo_transform = require(script.Parent)
return {
	render = function(parm)
		--local part = Instance.new("Part")
		local gizmo_instance = gizmo_transform(workspace.Part,function(type, value: Vector3): nil 
			if type == "Move" then
				workspace.Part.Position += value
			end
			if type == "Scale" then
				workspace.Part.Size += value
				--print(value)
			end
			return
		end)
		return function()
			gizmo_instance.instance:Destroy()
		end
	end,
}