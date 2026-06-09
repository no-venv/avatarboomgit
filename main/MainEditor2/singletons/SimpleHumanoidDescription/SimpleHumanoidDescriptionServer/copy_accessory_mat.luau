local function FindFirstDescendantOfClass(instance: Instance, target: string): Instance?
	local descendant = instance:GetDescendants()
	for _, child: Instance in descendant do
		if child:IsA(target) then
			return child
		end
	end
	return
end

return function(src: Accessory, target: Accessory)
	local src_accessory_material = FindFirstDescendantOfClass(src, "SpecialMesh")
		or FindFirstDescendantOfClass(src, "SurfaceAppearance")

	local target_accessory_material = FindFirstDescendantOfClass(target, "SpecialMesh")
		or FindFirstDescendantOfClass(target, "SurfaceAppearance")

	if not src_accessory_material then
		-- there is nothing to copy over
		return
	end

	if target_accessory_material then
		local target_parent = target_accessory_material.Parent
		target_accessory_material:Destroy()
		src_accessory_material:Clone().Parent = target_parent
	end
end
