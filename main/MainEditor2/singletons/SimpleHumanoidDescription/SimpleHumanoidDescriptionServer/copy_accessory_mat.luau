--!strict
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
	local handle_part = src:FindFirstChild("Handle") :: MeshPart
	local target_handle_part = target:FindFirstChild("Handle")
	if not handle_part or not target_handle_part then
		-- this shouldn't happen !
		return
	end
	local src_accessory_material = FindFirstDescendantOfClass(src, "SpecialMesh")
		or FindFirstDescendantOfClass(src, "SurfaceAppearance")

	local target_accessory_material = FindFirstDescendantOfClass(target, "SpecialMesh")
		or FindFirstDescendantOfClass(target, "SurfaceAppearance")
	if not src_accessory_material then
		-- there is nothing to copy over
		return
	end

	if target_accessory_material then
		target_accessory_material:Destroy()
	end
	src_accessory_material:Clone().Parent = target_handle_part
end
