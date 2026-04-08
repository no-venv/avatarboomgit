local cache: {
	[Instance]: { SpecialMesh | SurfaceAppearance },
} = {}
local function FindFirstDescendantOfClass(instance: Instance, target: string): Instance?
	local descendant = instance:GetDescendants()
	for _, child: Instance in descendant do
		if child:IsA(target) then
			return child
		end
	end
	return
end
return {
	get = function(humanoid: Instance, id: number): (SpecialMesh | SurfaceAppearance)?
		local local_cache = cache[humanoid]
		if local_cache then
			local accessory_cache = local_cache[id]
			if accessory_cache then
				return accessory_cache
			end
		else
			cache[humanoid] = {}
			local_cache = cache[humanoid]
		end

		local humanoid_description = humanoid:FindFirstChild("HumanoidDescription")
		if not humanoid_description then
			return
		end
		for _, description in humanoid_description:GetChildren() do
			if not description:IsA("AccessoryDescription") then
				continue
			end
			if description.AssetId ~= id then
				continue
			end
			local ok, result = pcall(function(...)
				return description:GetAppliedInstance() -- what the hell? this can error??
			end)
			if not ok then
				warn(result)
				return
			end
			local accessory = result
			local handle_part = accessory:FindFirstChild("Handle") :: MeshPart
			local accessory_material = FindFirstDescendantOfClass(accessory, "SpecialMesh")
				or FindFirstDescendantOfClass(accessory, "SurfaceAppearance")
			if accessory_material then
				local_cache[id] = accessory_material
				return accessory_material
			end
			if not accessory_material and handle_part then
				local surface_appearence_patch = Instance.new("SurfaceAppearance")
				surface_appearence_patch.ColorMapContent = Content.fromUri(handle_part.TextureID)
				surface_appearence_patch.Parent = handle_part
				local_cache[id] = surface_appearence_patch
				return surface_appearence_patch
			end
		end
		return
	end,
	remove = function(humanoid: Instance, id: number)
		if cache[humanoid] then
			cache[humanoid][id] = nil
		end
	end,
}
