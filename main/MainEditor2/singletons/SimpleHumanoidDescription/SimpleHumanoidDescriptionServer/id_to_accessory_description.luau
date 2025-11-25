local cache : {AccessoryDescription} = {}
return {
	get = function(humanoid : Instance,id : number) : AccessoryDescription?
		--if cache[id] then
		--	return cache[id]
		--end
		for _,description in humanoid:FindFirstChild("HumanoidDescription"):GetChildren() do
			if not description:IsA("AccessoryDescription") then
				continue
			end
			if description.AssetId ~= id then
				continue
			end
			--cache[id] = description
			return description
		end
		return
	end;
	remove = function(id : number)
		cache[id] = nil
	end,
}