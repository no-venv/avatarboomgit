--!strict

-- Makeup description for Humanoid

type Impl = {
	get_highest_makeup_count: (description: HumanoidDescription) -> number,
	get_makeup: (description: HumanoidDescription) -> { MakeupDescription },
	add_makeup: (description: HumanoidDescription, id: number, makeup_type: Enum.AvatarAssetType) -> (),
	makeup_equipped: (description: HumanoidDescription, id: number) -> boolean,
	remove_makeup: (description: HumanoidDescription, id: number) -> (),
	set_makeup_order: (description: HumanoidDescription, id: number, order: number) -> (),
}

local makeup_type_lookup = {
	[Enum.AvatarAssetType.EyeMakeup] = Enum.MakeupType.Eye,
	[Enum.AvatarAssetType.LipMakeup] = Enum.MakeupType.Lip,
	[Enum.AvatarAssetType.FaceMakeup] = Enum.MakeupType.Face,
}

local makeup_description_helper = {} :: Impl

makeup_description_helper.get_highest_makeup_count = function(description)
	local children = description:GetChildren()
	local order = 1
	for _, child in children do
		if child:IsA("MakeupDescription") then
			if child.Order > order then
				order = child.Order
			end
		end
	end
	return order
end

makeup_description_helper.get_makeup = function(description)
	local children = description:GetChildren()
	local makeup = {}
	for _, child in children do
		if child:IsA("MakeupDescription") then
			makeup[child.Order] = child
		end
	end
	return makeup
end

makeup_description_helper.add_makeup = function(description, id, makeup_type)
	local makeup = Instance.new("MakeupDescription")
	makeup.Name = tostring(id)
	makeup.AssetId = id
	makeup.MakeupType = makeup_type_lookup[makeup_type]
	makeup.Order = makeup_description_helper.get_highest_makeup_count(description) + 1
	makeup.Parent = description
end

makeup_description_helper.makeup_equipped = function(description, id)
	local makeup = description:FindFirstChild(tostring(id))
	if makeup then
		return true
	end
	return false
end

makeup_description_helper.remove_makeup = function(description, id)
	local makeup = description:FindFirstChild(tostring(id))
	if makeup then
		makeup:Destroy()
	end
end

makeup_description_helper.set_makeup_order = function(description, id, order)
	local makeup = description:FindFirstChild(tostring(id)) :: MakeupDescription
	if makeup then
		makeup.Order = order
	end
end

return makeup_description_helper
