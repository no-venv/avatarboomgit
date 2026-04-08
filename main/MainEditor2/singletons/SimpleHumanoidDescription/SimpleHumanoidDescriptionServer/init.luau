--!strict
-- Split functions up in the future
type Limb = "Left Arm" | "Left Leg" | "Right Arm" | "Right Leg" | "Head" | "Torso"
type void = nil
type BodyColours = {
	["Left Arm"]: Color3,
	["Left Leg"]: Color3,
	["Right Arm"]: Color3,
	["Right Leg"]: Color3,
	["Head"]: Color3,
	["Torso"]: Color3,
}
type BodyScale = {
	Width: number,
	Height: number,
	Head: number,
	Depth: number,
	Proportion: number,
}
type BundleInfo = {
	BundleType: "BodyParts" | "Shoes" | "Animations" | "DynamicHead",
	Items: { number },
}
type Struct = {
	__index: SimpleHumanoidDescription,
	Humanoid: Humanoid,
	BaseHumanoidDescription: HumanoidDescription,
	humanoid_loading: BindableEvent,
	humanoid_changed: BindableEvent,
	id_added: BindableEvent,
	id_removed: BindableEvent,
	inited_humanoids: { [Humanoid]: {
		mutex: boolean,
		fully_init: boolean,
	} },
}
type Impl = {
	is_init: (self: SimpleHumanoidDescription) -> Humanoid?,
	init: (self: SimpleHumanoidDescription, desc: Humanoid) -> (boolean, string),
	apply_fix: (self: SimpleHumanoidDescription) -> "Init" | "Pending",
	add_id: (
		self: SimpleHumanoidDescription,
		id: number,
		asset_type: Enum.AvatarAssetType?,
		humanoid_desc_override: HumanoidDescription?
	) -> boolean,
	remove_id: (self: SimpleHumanoidDescription, id: number) -> boolean,
	add_bundle_id: (self: SimpleHumanoidDescription, id: number) -> boolean,
	remove_bundle_id: (self: SimpleHumanoidDescription, id: number) -> boolean,
	--reset : (self : SimpleHumanoidDescription) -> void;
	id_equipped: (self: SimpleHumanoidDescription, id: number) -> boolean,
	get_id_accessory: (self: SimpleHumanoidDescription, id: number) -> Accessory?,
	get_id_list: (self: SimpleHumanoidDescription, only_accessories: boolean?) -> { number },
	get_bundle_id_list: (self: SimpleHumanoidDescription) -> { number },
	set_body_colour: (self: SimpleHumanoidDescription, limb: Limb | "All", colour: Color3) -> void,
	set_body_scale: (
		self: SimpleHumanoidDescription,
		type: "Width" | "Height" | "Head" | "Depth" | "Proportion",
		scale: number
	) -> void,
	get_body_scale: (self: SimpleHumanoidDescription) -> BodyScale,
	get_body_colours: (self: SimpleHumanoidDescription) -> BodyColours,
	get_humanoid_type: (self: SimpleHumanoidDescription) -> "R15" | "R6",
	convert_humanoid_type: (self: SimpleHumanoidDescription, humanoid_type: "R6" | "R15") -> Model,
	--
	set_id_transformation: (
		self: SimpleHumanoidDescription,
		id: number,
		type: "Pos" | "Rot" | "Scale",
		value: Vector3
	) -> void,
	get_id_transformation: (self: SimpleHumanoidDescription, id: number, type: "Pos" | "Rot" | "Scale") -> Vector3?,
	set_id_colour: (self: SimpleHumanoidDescription, id: number, colour: Color3) -> (),
	get_id_colour: (self: SimpleHumanoidDescription, id: number) -> Color3?,

	get_id_texture: (self: SimpleHumanoidDescription, id: number) -> string?,
	set_id_texture: (self: SimpleHumanoidDescription, id: number, texture_id: number) -> string?,
	reset_id_texture: (self: SimpleHumanoidDescription, id: number) -> void,

	get_clothing_colour: (self: SimpleHumanoidDescription, type: "Shirt" | "Pants") -> Color3?,
	set_clothing_colour: (self: SimpleHumanoidDescription, type: "Shirt" | "Pants", colour: Color3) -> void,
}
export type SimpleHumanoidDescription = Impl & Struct
local AvatarEditorService = game:GetService("AvatarEditorService")
local HttpService = game:GetService("HttpService")
local AssetService = game:GetService("AssetService")
local PlayerService = game:GetService("Players")
local SimpleHumanoidDescription = {} :: SimpleHumanoidDescription
SimpleHumanoidDescription.__index = SimpleHumanoidDescription
local id_to_accessory_description = require("@self/id_to_accessory_description")
local id_to_accessory_mat = require("@self/id_to_accessory_mat")
local asset_type_map = require("@self/asset_type_map")
local accessory_type_map = require("@self/accessory_type_map")
local other_prop = require("@self/other_prop")
local get_accessory_mesh_id = require("@self/get_accessory_mesh_id")
function SimpleHumanoidDescription:is_init()
	return self.Humanoid
end

function SimpleHumanoidDescription:init(humanoid)
	if self.Humanoid == humanoid then
		return true, ""
	end

	self.Humanoid = humanoid
	if not humanoid then
		-- clean up since nil
		self.humanoid_changed:Fire()
		return true, ""
	end

	if not self.Humanoid:FindFirstChildOfClass("HumanoidDescription") then
		self.Humanoid = nil
		self.humanoid_changed:Fire()
		return false,
			"To avoid corruption, this Rig cannot be used because Humanoid Description is not found.\n\nYou probably have used a rig from the toolbox, or used an insert tool to customize the selected rig.\n\nAvatarBoom requires rigs to have HumanoidDescription otherwise your rigs will be reset to black.\n\nYou may need to create a new rig and rebuild your outfit."
	end

	if self:apply_fix() == "Pending" then
		return true, "Avatar is loading"
	end
	if self.Humanoid ~= humanoid then
		-- mismatch
		return false, "Rig switched during loading"
	end
	self.humanoid_changed:Fire()
	return true, "Avatar has loaded"
end

function SimpleHumanoidDescription:apply_fix()
	-- applys fixes so that HumanoidDescription behaves
	-- This is a fix for the accessory bug
	-- where some wont be removed after leaving and reopening the place
	local humanoid = self.Humanoid
	local init_humanoid = self.inited_humanoids[humanoid]
	if init_humanoid then
		if init_humanoid.mutex then
			return "Pending"
		end
		if init_humanoid.fully_init then
			return "Init"
		end
	end
	self.inited_humanoids[humanoid] = {
		mutex = true,
		fully_init = false,
	}
	local ok = pcall(function()
		local hum_desc = humanoid:GetAppliedDescription()
		local humanoid_parent = humanoid.Parent :: Instance
		-- save old shirts
		local old_shirt = humanoid_parent:FindFirstChild("Shirt") :: Shirt
		local old_pants = humanoid_parent:FindFirstChild("Pants") :: Pants
		-- save old accessories because "get_id_object" has reference to them
		local old_accessories: { Accessory } = {}
		for _, accessory in humanoid:GetAccessories() do
			table.insert(old_accessories, accessory:Clone())
		end
		-- make humanoid description behave
		humanoid:ApplyDescriptionResetAsync(hum_desc)
		-- fix dragging
		for _, child in humanoid_parent:GetChildren() do
			if child:IsA("BasePart") or child:IsA("MeshPart") then
				child.Locked = false
			end
		end
		--
		local new_accessories: { Accessory } = humanoid:GetAccessories()
		-- now i guess transfer the references to the new accessories/shirts? also clone the
		-- children as well in case of modifications?
		local new_shirt = humanoid_parent:FindFirstChild("Shirt") :: Shirt
		local new_pants = humanoid_parent:FindFirstChild("Pants") :: Pants
		--
		if old_shirt then
			new_shirt.Color3 = old_shirt.Color3
		end
		if old_pants then
			new_pants.Color3 = old_pants.Color3
		end
		for _, new_accessory in new_accessories do
			local new_a_mesh_id = get_accessory_mesh_id(new_accessory)
			for _, old_accessory in old_accessories do
				local old_a_mesh_id = get_accessory_mesh_id(old_accessory)
				if old_a_mesh_id == new_a_mesh_id then
					local new_a_handle = new_accessory["Handle"]
					new_a_handle:Destroy()
					old_accessory["Handle"].Parent = new_accessory
					break
				end
			end
		end
	end)

	if not ok then
		self.inited_humanoids[humanoid] = nil
		return "Pending"
	end

	self.inited_humanoids[humanoid].mutex = false
	self.inited_humanoids[humanoid].fully_init = true
	return "Init"
end

function SimpleHumanoidDescription:get_id_list(only_accessories)
	if not self:is_init() then
		return {}
	end

	local ids = {}
	local description = self.Humanoid:GetAppliedDescription()
	local accessories = description:GetAccessories(true)
	for _, accessory in accessories do
		-- Exclude asset bundles
		if self.Humanoid:GetAttribute(`b_asset_id_{accessory.AssetId}`) then
			continue
		end
		table.insert(ids, accessory.AssetId)
	end

	if not only_accessories then
		for _, prop in other_prop do
			local prop_id = description[prop]
			if prop_id > 0 then
				table.insert(ids, prop_id)
			end
		end
	end

	return ids
end

function SimpleHumanoidDescription:get_bundle_id_list()
	if not self:is_init() then
		return {}
	end

	local ids = {}
	for bundle_header, bundle_ids: string in self.Humanoid:GetAttributes() do
		if bundle_header == "BodyPartsBundleID" then
			continue
		end
		if bundle_header:match("b_asset_id") then
			continue
		end
		table.insert(ids, tonumber(bundle_header) :: number)
	end
	return ids
end

function SimpleHumanoidDescription:add_id(id, asset_type, humanoid_desc_override)
	-- adds accesories
	if self:id_equipped(id) then
		return true
	end
	local description = humanoid_desc_override or self.Humanoid:GetAppliedDescription()
	local accessories = description:GetAccessories(true)
	local AccessoryType = asset_type :: Enum.AvatarAssetType
	if not asset_type then
		local asset_info = AvatarEditorService:GetItemDetailsAsync(id, Enum.AvatarItemType.Asset)
		AccessoryType = Enum.AvatarAssetType:FromName(asset_info.AssetType)
		if not AccessoryType then
			print(`{asset_info.AssetType} failed with Enum.AvatarAssetType:FromName`)
			return false
		end
	end

	local legacy_success, error = pcall(function(...)
		local map = asset_type_map[AccessoryType.Name]
		local property_type = typeof(description[map])
		if property_type == "number" then
			description[map] = id
		else
			description[map] ..= `,{id}`
		end
	end)
	if not legacy_success then
		-- print(AccessoryType)
		-- if AccessoryType == Enum.AvatarAssetType.FaceMakeup then
		-- 	description
		-- end
		table.insert(accessories, {
			Order = 1,
			AssetId = id,
			AccessoryType = accessory_type_map[AccessoryType],
		})
		description:SetAccessories(accessories, true)
	end

	if not humanoid_desc_override then
		self.Humanoid:ApplyDescriptionAsync(description)
		self.id_added:Fire(id)
	end
	return true
end

function SimpleHumanoidDescription:remove_id(id)
	local description = self.Humanoid:GetAppliedDescription()
	local accessories = description:GetAccessories(true)
	for index, item in accessories do
		if item.AssetId == id then
			table.remove(accessories, index)
			break
		end
	end
	description:SetAccessories(accessories, true)

	for _, prop in other_prop do
		if description[prop] == id then
			description[prop] = 0
		end
	end
	local accessory_cache = self.Humanoid:FindFirstChild(tostring(id))
	if accessory_cache then
		accessory_cache:Destroy()
	end
	id_to_accessory_description.remove(id)
	id_to_accessory_mat.remove(self.Humanoid, id)
	self.Humanoid:ApplyDescriptionAsync(description)
	self.id_removed:Fire(id)
	return true
end

function SimpleHumanoidDescription:add_bundle_id(id)
	local bundle_details = AssetService:GetBundleDetailsAsync(id)
	local saved_bundle_data: BundleInfo = {
		BundleType = bundle_details.BundleType,
		Items = (function()
			local ids: { number } = {}
			for _, item in bundle_details.Items do
				if item.Type == "UserOutfit" then
					continue
				end
				table.insert(ids, item.Id)
			end
			return ids
		end)(),
	}

	local ids = {}
	for _, item in bundle_details.Items do
		if item.Type == "UserOutfit" then
			continue
		end
		table.insert(ids, item.Id)
	end
	local description = self.Humanoid:GetAppliedDescription()
	local batch_fetch = AvatarEditorService:GetBatchItemDetailsAsync(ids, Enum.AvatarItemType.Asset)

	for _, item in batch_fetch do
		local asset_type = Enum.AvatarAssetType:FromName(item.AssetType)
		self:add_id(item.Id, Enum.AvatarAssetType:FromName(item.AssetType), description)
	end

	self.Humanoid:ApplyDescriptionResetAsync(description)
	self.id_added:Fire(id)

	local save_shoes = saved_bundle_data.BundleType == "Shoes"
	local save_body = saved_bundle_data.BundleType == "BodyParts"
	if save_shoes or save_body then
		self.Humanoid:SetAttribute(tostring(id), HttpService:JSONEncode(saved_bundle_data))
	end

	return true
end

function SimpleHumanoidDescription:remove_bundle_id(id)
	local id_string = tostring(id)
	local saved_bundle_data: BundleInfo = HttpService:JSONDecode(self.Humanoid:GetAttribute(id_string))

	if saved_bundle_data.BundleType == "BodyParts" then
		local description = self.Humanoid:GetAppliedDescription()
		description.Head = 0
		description.LeftArm = 0
		description.LeftLeg = 0
		description.RightArm = 0
		description.RightLeg = 0
		description.Torso = 0
		self.Humanoid:SetAttribute("BodyPartsBundleID", nil)
		self.Humanoid:SetAttribute(id_string, nil)
		self.Humanoid:ApplyDescriptionAsync(description)
		self.id_removed:Fire()
		return true
	end
	if saved_bundle_data.BundleType == "DynamicHead" then
		self.Humanoid:SetAttribute("DynamicHeadBundleID", nil)
	end
	for _, item in saved_bundle_data.Items do
		self.Humanoid:SetAttribute(`b_asset_id_{item}`, nil)
		self:remove_id(item)
	end

	self.Humanoid:SetAttribute(id_string, nil)
	return true
end

function SimpleHumanoidDescription:id_equipped(id)
	if not self:is_init() then
		return false
	end
	local description = self.Humanoid:GetAppliedDescription()
	local accessories = description:GetAccessories(true)

	for _, prop in other_prop do
		if description[prop] == id then
			return true
		end
	end

	for _, item in accessories do
		if item.AssetId == id then
			return true
		end
	end

	if self.Humanoid:GetAttribute(tostring(id)) then
		return true
	end

	return false
end

function SimpleHumanoidDescription:set_body_colour(limb, colour)
	local mapping = {
		["Left Arm"] = "LeftArmColor",
		["Left Leg"] = "LeftLegColor",
		["Right Arm"] = "RightArmColor",
		["Right Leg"] = "RightLegColor",
		["Head"] = "HeadColor",
		["Torso"] = "TorsoColor",
	}
	local description = self.Humanoid:GetAppliedDescription()
	if limb == "All" then
		for limb, limb_colour_mapping in mapping do
			description[limb_colour_mapping] = colour
		end
	else
		description[mapping[limb]] = colour
	end
	self.Humanoid:ApplyDescriptionAsync(description)
	return
end

function SimpleHumanoidDescription:set_body_scale(type, scale)
	if not self:is_init() then
		return
	end
	local description = self.Humanoid:GetAppliedDescription()
	local prop = {
		Width = "WidthScale",
		Height = "HeightScale",
		Head = "HeadScale",
		Depth = "DepthScale",
		Proportion = "ProportionScale",
	}

	description[prop[type]] = scale
	self.Humanoid:ApplyDescriptionAsync(description)
	return
end

function SimpleHumanoidDescription:get_body_colours()
	local description = self.Humanoid:GetAppliedDescription()
	return {
		["Left Arm"] = description.LeftArmColor,
		["Left Leg"] = description.LeftLegColor,
		["Right Arm"] = description.RightArmColor,
		["Right Leg"] = description.RightLegColor,
		["Head"] = description.HeadColor,
		["Torso"] = description.TorsoColor,
	}
end

function SimpleHumanoidDescription:get_body_scale()
	local body_scale: BodyScale = {
		Width = 1,
		Height = 1,
		Head = 1,
		Depth = 1,
		Proportion = 0,
	}
	if self:is_init() then
		local description = self.Humanoid:GetAppliedDescription()
		body_scale.Width = description.WidthScale
		body_scale.Height = description.HeightScale
		body_scale.Head = description.HeadScale
		body_scale.Depth = description.DepthScale
		body_scale.Proportion = description.ProportionScale
		return body_scale
	else
		return body_scale
	end
end
function SimpleHumanoidDescription:get_humanoid_type()
	local type = (self.Humanoid.RigType == Enum.HumanoidRigType.R15) and "R15" or "R6"
	return type :: "R15" | "R6"
end

function SimpleHumanoidDescription:convert_humanoid_type(humanoid_type)
	-- Creates a new model
	local stored_humanoid = self.Humanoid
	local applied_description = self.Humanoid:GetAppliedDescription()
	local converted_model = PlayerService:CreateHumanoidModelFromDescriptionAsync(
		applied_description,
		humanoid_type == "R6" and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
	)
	converted_model.PrimaryPart = converted_model:FindFirstChild("HumanoidRootPart") :: BasePart
	-- fix dragging
	for _, child in converted_model:GetChildren() do
		if child:IsA("BasePart") or child:IsA("MeshPart") then
			child.Locked = false
		end
	end
	local id_colours = {}
	for _, accessories in applied_description:GetAccessories(true) do
		id_colours[accessories.AssetId] = self:get_id_colour(accessories.AssetId)
	end
	-- apply the colours and stuff
	local shirt_colour = self:get_clothing_colour("Shirt")
	local pants_colour = self:get_clothing_colour("Pants")

	self.Humanoid = converted_model:FindFirstChild("Humanoid") :: Humanoid
	if shirt_colour then
		self:set_clothing_colour("Shirt", shirt_colour)
	end
	if pants_colour then
		self:set_clothing_colour("Pants", pants_colour)
	end
	for id, colour in id_colours do
		if not colour then
			continue
		end
		self:set_id_colour(id, colour)
		id_to_accessory_mat.remove(self.Humanoid, id)
	end
	self.Humanoid = stored_humanoid
	return converted_model
end

function SimpleHumanoidDescription:set_id_transformation(id, trans_type, vec3)
	if not self:is_init() then
		return
	end
	local accessory_description = id_to_accessory_description.get(self.Humanoid, id)
	if accessory_description then
		local is_pos = trans_type == "Pos"
		local is_rot = trans_type == "Rot"
		local is_scale = trans_type == "Scale"
		if is_pos then
			accessory_description.Position = vec3
		end
		if is_rot then
			accessory_description.Rotation = vec3
		end
		if is_scale then
			accessory_description.Scale = vec3
		end
	end
	local description = self.Humanoid:GetAppliedDescription()
	self.Humanoid:ApplyDescriptionAsync(description)
	return
end

function SimpleHumanoidDescription:get_id_transformation(id, trans_type)
	if not self:is_init() then
		return
	end
	local accessory_description = id_to_accessory_description.get(self.Humanoid, id)
	local return_value: Vector3
	if accessory_description then
		local is_pos = trans_type == "Pos"
		local is_rot = trans_type == "Rot"
		local is_scale = trans_type == "Scale"
		if is_pos then
			return_value = accessory_description.Position
		end
		if is_rot then
			return_value = accessory_description.Rotation
		end
		if is_scale then
			return_value = accessory_description.Scale
		end
	end
	return return_value
end

function SimpleHumanoidDescription:set_id_colour(id, colour)
	if not self:is_init() then
		return
	end
	local id_material = id_to_accessory_mat.get(self.Humanoid, id)
	if not id_material then
		return
	end
	if id_material:IsA("SpecialMesh") then
		id_material.VertexColor = Vector3.new(colour.R, colour.G, colour.B)
	end
	if id_material:IsA("SurfaceAppearance") then
		id_material.Color = colour
	end
	return
end

function SimpleHumanoidDescription:get_id_colour(id)
	if not self:is_init() then
		return
	end
	local return_value: Color3
	local id_material = id_to_accessory_mat.get(self.Humanoid, id)
	if not id_material then
		return
	end
	if id_material:IsA("SpecialMesh") then
		local vertex_colour = id_material.VertexColor
		return_value = Color3.new(vertex_colour.X, vertex_colour.Y, vertex_colour.Z)
	end
	if id_material:IsA("SurfaceAppearance") then
		return_value = id_material.Color
	end
	return return_value
end

function SimpleHumanoidDescription:get_clothing_colour(type)
	if not self:is_init() then
		return
	end
	local humanoid_parent = self.Humanoid.Parent
	local clothing = (humanoid_parent :: Instance):FindFirstChild(type)
	if not clothing then
		return
	end
	if clothing:IsA("Shirt") or clothing:IsA("Pants") then
		return clothing.Color3
	end
	return
end

function SimpleHumanoidDescription:set_clothing_colour(type, colour)
	if not self:is_init() then
		return
	end
	local humanoid_parent = self.Humanoid.Parent
	local clothing = humanoid_parent:FindFirstChild(type)
	if clothing:IsA("Shirt") or clothing:IsA("Pants") then
		clothing.Color3 = colour
	end
	return
end

function SimpleHumanoidDescription:get_id_accessory(id)
	if not self:is_init() then
		return
	end
	local accessory_description = id_to_accessory_description.get(self.Humanoid, id)
	if not accessory_description then
		return
	end
	return accessory_description:GetAppliedInstance() :: Accessory
end

function SimpleHumanoidDescription:get_id_texture(id)
	if not self:is_init() then
		return
	end
	local id_material = id_to_accessory_mat.get(self.Humanoid, id)
	if not id_material then
		return
	end
	if id_material:IsA("SpecialMesh") then
		return id_material.TextureId
	end
	if id_material:IsA("SurfaceAppearance") then
		return id_material.ColorMapContent.Uri
	end
	return
end

function SimpleHumanoidDescription:set_id_texture(id, texture_id)
	if not self:is_init() then
		return
	end
	local id_material = id_to_accessory_mat.get(self.Humanoid, id)
	if not id_material then
		return
	end

	local material_id: string?
	if id_material:IsA("SpecialMesh") then
		material_id = id_material.TextureId
	end
	if id_material:IsA("SurfaceAppearance") then
		material_id = id_material.ColorMapContent.Uri
	end

	if not material_id then
		-- usually this means something went wrong!!
		return
	end

	local rbx_asset_uri = `rbxassetid://{texture_id}`

	if not id_material:GetAttribute("base_material_id") then
		-- set the base id for reverting later!!!
		id_material:SetAttribute("base_material_id", material_id)
	end

	if id_material:IsA("SpecialMesh") then
		id_material.TextureId = rbx_asset_uri
	end
	if id_material:IsA("SurfaceAppearance") then
		id_material.ColorMapContent = Content.fromUri(rbx_asset_uri)
	end

	return
end

function SimpleHumanoidDescription:reset_id_texture(id)
	if not self:is_init() then
		return
	end
	local id_material = id_to_accessory_mat.get(self.Humanoid, id)
	if not id_material then
		return
	end
	local base_material_id: string = id_material:GetAttribute("base_material_id")
	if not base_material_id then
		return
	end
	local texture_id = base_material_id:match("(%d+)")
	if not texture_id then
		return
	end
	self:set_id_texture(id, tonumber(texture_id))
	return
end

local constructor = {}

function constructor:new(): SimpleHumanoidDescription
	local struct = {
		Humanoid = nil,
		BaseHumanoidDescription = nil,
		humanoid_changed = Instance.new("BindableEvent"),
		id_added = Instance.new("BindableEvent"),
		id_removed = Instance.new("BindableEvent"),
		inited_humanoids = {},
	}
	return setmetatable(struct, SimpleHumanoidDescription)
end

return constructor
