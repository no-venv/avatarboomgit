return function(accessory : Accessory) : number?
	local children = accessory:GetDescendants()
	local comp_mesh_id : number? = nil
	for _,is_this_a_mesh in children do
		pcall(function(...) 
			comp_mesh_id  = is_this_a_mesh["MeshId"]
		end)
		if comp_mesh_id then
			break
		end
	end
	return comp_mesh_id
end