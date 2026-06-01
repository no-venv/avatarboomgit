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

type Error = {
	type: string,
	message: string,
	retry: (() -> ())?,
}
type Struct = {
	__index: SimpleHumanoidDescription,
	_id_operations_lock: boolean,
	Humanoid: Humanoid?,
	BaseHumanoidDescription: HumanoidDescription,
	humanoid_loading: BindableEvent,
	humanoid_changed: BindableEvent,
	id_added: BindableEvent,
	id_removed: BindableEvent,
	id_operations_ready_event: BindableEvent,
	on_error: ((error: Error) -> ())?,
	inited_humanoids: { [Humanoid]: {
		mutex: boolean,
		fully_init: boolean,
	} },
	accessory_added_connection: RBXScriptConnection?,
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
		-- forceful: boolean?
	) -> boolean,
	batch_add_id: (self: SimpleHumanoidDescription, ids: { number }) -> boolean,
	remove_id: (
		self: SimpleHumanoidDescription,
		id: number,
		humanoid_desc_override: HumanoidDescription?
		-- forceful: boolean?
	) -> boolean,
	add_bundle_id: (self: SimpleHumanoidDescription, id: number) -> boolean,
	remove_bundle_id: (self: SimpleHumanoidDescription, id: number) -> boolean,
	set_id_operation_lock: (self: SimpleHumanoidDescription, lock: boolean) -> (),
	is_id_operations_ready: (self: SimpleHumanoidDescription) -> boolean,
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
	convert_humanoid_type: (self: SimpleHumanoidDescription, humanoid_type: "R6" | "R15") -> Model?,
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
	set_id_texture: (self: SimpleHumanoidDescription, id: number, texture_id: number | string) -> string?,
	reset_id_texture: (self: SimpleHumanoidDescription, id: number) -> void,

	get_clothing_colour: (self: SimpleHumanoidDescription, type: "Shirt" | "Pants") -> Color3?,
	set_clothing_colour: (self: SimpleHumanoidDescription, type: "Shirt" | "Pants", colour: Color3) -> void,
	get_id_asset_info_list: (self: SimpleHumanoidDescription) -> { any },
	set_makeup_order: (self: SimpleHumanoidDescription, id: number, order: number) -> (),
	get_makeup_order: (self: SimpleHumanoidDescription) -> { MakeupDescription },
	set_layered_clothing_order: (self: SimpleHumanoidDescription, id: number, order: number) -> (),
	get_highest_layered_clothing_count: (self: SimpleHumanoidDescription) -> number,
	get_layered_clothing_order: (self: SimpleHumanoidDescription) -> { AccessoryDescription },
	_generate_error_event: (
		self: SimpleHumanoidDescription,
		type: string,
		message: string,
		method: (() -> ())?
	) -> (),
}

export type SimpleHumanoidDescription = Impl & Struct
local AvatarEditorService = game:GetService("AvatarEditorService")
local HttpService = game:GetService("HttpService")
local AssetService = game:GetService("AssetService")
local PlayerService = game:GetService("Players")

local id_to_accessory_description = require("@self/id_to_accessory_description")
local id_to_accessory_mat = require("@self/id_to_accessory_mat")
local asset_type_map = require("@self/asset_type_map")
local accessory_type_map = require("@self/accessory_type_map")
local other_prop = require("@self/other_prop")
local get_accessory_mesh_id = require("@self/get_accessory_mesh_id")
local wearing_cache = require("@self/wearing_cache")
local makeup_description_helper = require("@self/makeup_description_helper")
local position_accessory_handle = require("@self/position_accessory_handle")
local fix_rig_position = require("@self/fix_rig_position")
local SimpleHumanoidDescription = {} :: SimpleHumanoidDescription
SimpleHumanoidDescription.__index = SimpleHumanoidDescription
local constructor = {}
function SimpleHumanoidDescription:is_init()
	return self.Humanoid
end

function SimpleHumanoidDescription:init(humanoid)
	if self.Humanoid == humanoid then
		return true, ""
	end

	if self.accessory_added_connection then
		self.accessory_added_connection:Disconnect()
		self.accessory_added_connection = nil
	end

	self.Humanoid = humanoid
	if not self.Humanoid then
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

	local character = self.Humanoid.Parent
	if character then
		self.accessory_added_connection = character.ChildAdded:Connect(function(child)
			if child:IsA("Accessory") then
				position_accessory_handle(child, character)
			end
		end)
	end

	if self:apply_fix() == "Pending" then
		return true, "Avatar is loading"
	end
	if self.Humanoid ~= humanoid then
		-- mismatch
		return false, "Rig switched during loading"
	end
	self.humanoid_changed:Fire()
	self:set_id_operation_lock(false)
	return true, "Avatar has loaded"
end

function SimpleHumanoidDescription:apply_fix()
	-- applys fixes so that HumanoidDescription behaves
	-- This is a fix for the accessory bug
	-- where some wont be removed after leaving and reopening the place
	if not self.Humanoid then
		return "Pending"
	end
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
		-- this usually is a model
		local humanoid_parent = humanoid.Parent :: Model
		local saved_pivot = humanoid_parent:GetPivot()
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
				(child :: BasePart).Locked = false
			end
		end
		--
		local new_accessories: { Accessory } = humanoid:GetAccessories()
		-- now i guess transfer the references to the new accessories/shirts? also clone the
		-- children as well in case of modifications?
		local new_shirt = humanoid_parent:FindFirstChild("Shirt") :: Shirt
		local new_pants = humanoid_parent:FindFirstChild("Pants") :: Pants
		--
		if old_shirt and new_shirt then
			new_shirt.Color3 = old_shirt.Color3
		end
		if old_pants and new_pants then
			new_pants.Color3 = old_pants.Color3
		end
		for _, new_accessory in new_accessories do
			local new_a_mesh_id = get_accessory_mesh_id(new_accessory)
			for _, old_accessory in old_accessories do
				local old_a_mesh_id = get_accessory_mesh_id(old_accessory)
				if old_a_mesh_id == new_a_mesh_id then
					local new_a_handle = new_accessory:FindFirstChild("Handle")
					if new_a_handle then
						new_a_handle:Destroy()
					end
					local old_a_handle = old_accessory:FindFirstChild("Handle")
					if old_a_handle then
						old_a_handle.Parent = new_accessory
					end
					-- old_accessory["Handle"].Parent = new_accessory
					break
				end
			end
		end
		for _, new_accessory in new_accessories do
			position_accessory_handle(new_accessory, humanoid_parent)
		end
		task.defer(function()
			humanoid_parent:PivotTo(saved_pivot)
		end)
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
	if not self.Humanoid then
		return {}
	end
	local humanoid = self.Humanoid
	local ids = {}
	local description = humanoid:GetAppliedDescription()
	local accessories = description:GetAccessories(true)
	for _, accessory in accessories do
		-- Exclude asset bundles
		if humanoid:GetAttribute(`b_asset_id_{accessory.AssetId}`) then
			continue
		end
		table.insert(ids, accessory.AssetId)
	end

	if not only_accessories then
		local makeup_ids = makeup_description_helper.get_makeup(description)
		for _, prop in other_prop do
			local prop_id = (description :: any)[prop]
			if prop_id > 0 then
				table.insert(ids, prop_id)
			end
		end
		for _, makeup in makeup_ids do
			table.insert(ids, makeup.AssetId)
		end
	end

	return ids
end

function SimpleHumanoidDescription:get_bundle_id_list()
	if not self.Humanoid then
		return {}
	end

	local ids = {}
	for bundle_header, bundle_ids in self.Humanoid:GetAttributes() do
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
	if not self.Humanoid or (self._id_operations_lock and not humanoid_desc_override) then
		return false
	end
	local humanoid = self.Humanoid
	if self:id_equipped(id) then
		return true
	end
	if not humanoid_desc_override then
		fix_rig_position.set_rig_position(humanoid)
		self:set_id_operation_lock(true)
	end
	local description = humanoid_desc_override or humanoid:GetAppliedDescription()
	local accessories = description:GetAccessories(true)
	local AccessoryType = asset_type :: Enum.AvatarAssetType
	if not asset_type then
		local ok, result = pcall(function(...)
			return AvatarEditorService:GetItemDetailsAsync(id, Enum.AvatarItemType.Asset)
		end)
		if not ok then
			self:set_id_operation_lock(false)
			-- probably propagate an error here, though there has to be a cleaner method than this
			task.wait()
			error(result)
			-- return false
		end
		local to_asset_type = Enum.AvatarAssetType:FromName(result.AssetType)
		if not to_asset_type then
			print(`{result.AssetType} failed with Enum.AvatarAssetType:FromName`)
			self:set_id_operation_lock(false)
			return false
		end
		AccessoryType = to_asset_type
	end

	local legacy_success, _ = pcall(function(...)
		local map = asset_type_map[AccessoryType.Name]
		local property_type = typeof((description :: any)[map])
		if property_type == "number" then
			(description :: any)[map] = id
		else
			(description :: any)[map] ..= `,{id}`
		end
	end)

	if not legacy_success then
		if
			(AccessoryType == Enum.AvatarAssetType.FaceMakeup)
			or (AccessoryType == Enum.AvatarAssetType.EyeMakeup)
			or (AccessoryType == Enum.AvatarAssetType.LipMakeup)
		then
			makeup_description_helper.add_makeup(description, id, AccessoryType)
		else
			local order = self:get_highest_layered_clothing_count() + 1
			local is_layered = accessory_type_map[AccessoryType] and true or false
			table.insert(accessories, {
				Order = is_layered and order or 1,
				AssetId = id,
				AccessoryType = accessory_type_map[AccessoryType],
				IsLayered = is_layered,
			})
			description:SetAccessories(accessories, true)
		end
	end

	if not humanoid_desc_override and humanoid == self.Humanoid then
		local ok, result
		ok = pcall(function(...)
			humanoid:ApplyDescriptionAsync(description)
		end)
		if not ok then
			ok, result = xpcall(function(...)
				-- forcefully reset & apply description
				humanoid:ApplyDescriptionResetAsync(description)
			end, debug.traceback)
		end
		if not ok then
			self:_generate_error_event("id_operation", result)
			self:set_id_operation_lock(false)
			task.wait()
			error(result)
		end
		fix_rig_position.apply_rig_position(humanoid)
		self.id_added:Fire(id)
	end
	if not humanoid_desc_override then
		self:set_id_operation_lock(false)
	end
	return true
end

function SimpleHumanoidDescription:batch_add_id(ids)
	-- Adds the ids in batches. Useful in cases where GetBatchItemDetailsAsync should be used
	if not self.Humanoid or self._id_operations_lock then
		return false
	end
	self:set_id_operation_lock(true)
	local humanoid = self.Humanoid
	fix_rig_position.set_rig_position(humanoid)
	local description = humanoid:GetAppliedDescription()
	local asset_info = AvatarEditorService:GetBatchItemDetailsAsync(ids, Enum.AvatarItemType.Asset)
	for _, asset in asset_info do
		local to_asset_type = Enum.AvatarAssetType:FromName(asset.AssetType)
		if not to_asset_type then
			print(`{asset.AssetType} failed with Enum.AvatarAssetType:FromName`)
			self:set_id_operation_lock(false)
			return false
		end
		self:add_id(asset.Id, to_asset_type, description)
	end
	local ok, result = xpcall(function(...)
		humanoid:ApplyDescriptionAsync(description)
		fix_rig_position.apply_rig_position(humanoid)
	end, debug.traceback)
	self:set_id_operation_lock(false)
	if not ok then
		task.wait()
		error(result)
	end
	return true
end

function SimpleHumanoidDescription:remove_id(id, humanoid_desc_override)
	if not self.Humanoid or (self._id_operations_lock and not humanoid_desc_override) then
		return false
	end
	local humanoid = self.Humanoid
	if not humanoid_desc_override then
		self:set_id_operation_lock(true)
		fix_rig_position.set_rig_position(humanoid)
	end

	local description = humanoid:GetAppliedDescription()
	local accessories = description:GetAccessories(true)
	for index, item in accessories do
		if item.AssetId == id then
			table.remove(accessories, index)
			break
		end
	end
	description:SetAccessories(accessories, true)

	for _, prop in other_prop do
		if (description :: any)[prop] == id then
			(description :: any)[prop] = 0
		end
	end
	local accessory_cache = humanoid:FindFirstChild(tostring(id))
	if accessory_cache then
		accessory_cache:Destroy()
	end
	id_to_accessory_description.remove(id)
	id_to_accessory_mat.remove(humanoid, id)
	makeup_description_helper.remove_makeup(description, id)

	if not humanoid_desc_override then
		local ok, result
		ok = pcall(function(...)
			humanoid:ApplyDescriptionAsync(description)
		end)
		if not ok then
			ok, result = xpcall(function(...)
				humanoid:ApplyDescriptionResetAsync(description)
			end, debug.traceback)
		end
		self:set_id_operation_lock(false)
		if not ok then
			self:_generate_error_event("id_operation", result)
			task.wait()
			error(result)
		end
		fix_rig_position.apply_rig_position(humanoid)
		if humanoid == self.Humanoid then
			self.id_removed:Fire(id)
		end
	end
	return true
end

function SimpleHumanoidDescription:add_bundle_id(id)
	if not self.Humanoid or self._id_operations_lock then
		return false
	end
	self:set_id_operation_lock(true)
	local humanoid = self.Humanoid
	fix_rig_position.set_rig_position(humanoid)
	local bundle_details = AssetService:GetBundleDetailsAsync(id)
	-- local saved_bundle_data: BundleInfo = {
	-- 	BundleType = bundle_details.BundleType,
	-- 	Items = (function()
	-- 		local ids: { number } = {}
	-- 		for _, item in bundle_details.Items do
	-- 			if item.Type == "UserOutfit" then
	-- 				continue
	-- 			end
	-- 			table.insert(ids, item.Id)
	-- 		end
	-- 		return ids
	-- 	end)(),
	-- }

	local ids = {}
	for _, item in bundle_details.Items do
		if item.Type == "UserOutfit" then
			continue
		end
		table.insert(ids, item.Id)
	end
	local description = humanoid:GetAppliedDescription()
	local batch_fetch = AvatarEditorService:GetBatchItemDetailsAsync(ids, Enum.AvatarItemType.Asset)

	for _, item in batch_fetch do
		self:add_id(item.Id, Enum.AvatarAssetType:FromName(item.AssetType), description)
	end

	local ok, result = xpcall(function(...)
		humanoid:ApplyDescriptionResetAsync(description)
		fix_rig_position.apply_rig_position(humanoid)
		if humanoid == self.Humanoid then
			self.id_added:Fire(id)
		end
	end, debug.traceback)
	-- local save_shoes = saved_bundle_data.BundleType == "Shoes"
	-- local save_body = saved_bundle_data.BundleType == "BodyParts"
	-- if save_shoes or save_body then
	-- 	humanoid:SetAttribute(tostring(id), HttpService:JSONEncode(saved_bundle_data))
	-- end
	self:set_id_operation_lock(false)
	if not ok then
		task.wait()
		error(result)
	end
	return true
end

function SimpleHumanoidDescription:remove_bundle_id(id)
	if not self.Humanoid or self._id_operations_lock then
		return false
	end
	self:set_id_operation_lock(true)
	local humanoid = self.Humanoid
	fix_rig_position.set_rig_position(humanoid)
	local id_string = tostring(id)
	local bundle_data_string = humanoid:GetAttribute(id_string) :: string?
	if not bundle_data_string then
		self:set_id_operation_lock(false)
		return false
	end
	local saved_bundle_data: BundleInfo = HttpService:JSONDecode(bundle_data_string)
	local description = humanoid:GetAppliedDescription()

	if saved_bundle_data.BundleType == "BodyParts" then
		description.Head = 0
		description.LeftArm = 0
		description.LeftLeg = 0
		description.RightArm = 0
		description.RightLeg = 0
		description.Torso = 0
		humanoid:SetAttribute("BodyPartsBundleID", nil)
		humanoid:SetAttribute(id_string, nil)
		humanoid:ApplyDescriptionAsync(description)
		if humanoid == self.Humanoid then
			self.id_removed:Fire(id)
		end
		self:set_id_operation_lock(false)
		return true
	end
	if saved_bundle_data.BundleType == "DynamicHead" then
		humanoid:SetAttribute("DynamicHeadBundleID", nil)
	end
	for _, item in saved_bundle_data.Items do
		humanoid:SetAttribute(`b_asset_id_{item}`, nil)
		self:remove_id(item, description)
	end
	local ok, result = xpcall(function(...)
		humanoid:ApplyDescriptionAsync(description)
		humanoid:SetAttribute(id_string, nil)
		fix_rig_position.apply_rig_position(humanoid)
	end, debug.traceback)
	self:set_id_operation_lock(false)
	if not ok then
		error(result)
	end
	return true
end

function SimpleHumanoidDescription:set_id_operation_lock(lock)
	self._id_operations_lock = lock
	self.id_operations_ready_event:Fire(not lock)
	return
end
function SimpleHumanoidDescription:is_id_operations_ready()
	return not self._id_operations_lock
end

function SimpleHumanoidDescription:id_equipped(id)
	if not self.Humanoid then
		return false
	end
	local humanoid = self.Humanoid
	local description = humanoid:GetAppliedDescription()
	local accessories = description:GetAccessories(true)

	for _, prop in other_prop do
		if (description :: any)[prop] == id then
			return true
		end
	end

	for _, item in accessories do
		if item.AssetId == id then
			return true
		end
	end

	if humanoid:GetAttribute(tostring(id)) then
		return true
	end

	if makeup_description_helper.makeup_equipped(description, id) then
		return true
	end

	return false
end

function SimpleHumanoidDescription:set_body_colour(limb, colour)
	if not self.Humanoid then
		return
	end
	local humanoid = self.Humanoid
	local mapping = {
		["Left Arm"] = "LeftArmColor",
		["Left Leg"] = "LeftLegColor",
		["Right Arm"] = "RightArmColor",
		["Right Leg"] = "RightLegColor",
		["Head"] = "HeadColor",
		["Torso"] = "TorsoColor",
	}
	local description = humanoid:GetAppliedDescription()
	if limb == "All" then
		for limb, limb_colour_mapping in mapping do
			(description :: any)[limb_colour_mapping] = colour
		end
	else
		(description :: any)[mapping[limb]] = colour
	end
	humanoid:ApplyDescriptionAsync(description)
	return
end

function SimpleHumanoidDescription:set_body_scale(scale_type, scale)
	if not self.Humanoid then
		return
	end
	local humanoid = self.Humanoid
	local description = humanoid:GetAppliedDescription()
	local prop = {
		Width = "WidthScale",
		Height = "HeightScale",
		Head = "HeadScale",
		Depth = "DepthScale",
		Proportion = "ProportionScale",
	}
	local index = prop[scale_type]
	if not index then
		warn(`{scale_type} is invalid for :set_body_scale`)
		return
	end
	(description :: any)[index] = scale
	humanoid:ApplyDescriptionAsync(description)
	return
end

function SimpleHumanoidDescription:get_body_colours()
	if not self.Humanoid then
		local black = Color3.new()
		return {
			["Left Arm"] = black,
			["Left Leg"] = black,
			["Right Arm"] = black,
			["Right Leg"] = black,
			["Head"] = black,
			["Torso"] = black,
		}
	end
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
	local humanoid = self.Humanoid
	if humanoid then
		local description = humanoid:GetAppliedDescription()
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
	if not self.Humanoid then
		return "R15"
	end
	local humanoid = self.Humanoid
	local type = (humanoid.RigType == Enum.HumanoidRigType.R15) and "R15" or "R6"
	return type :: "R15" | "R6"
end

function SimpleHumanoidDescription:convert_humanoid_type(humanoid_type)
	-- Creates a new model
	if not self.Humanoid then
		return
	end
	local applied_description = self.Humanoid:GetAppliedDescription()
	-- @ fix for issues/issue/2451a3dd-4395-4992-83bd-f187406b63a1/event/5f6c401d-1a3f-429c-b4c2-e40a62dfd05b/details/
	-- ?
	local id_colours = {}
	for _, accessories in applied_description:GetAccessories(true) do
		id_colours[accessories.AssetId] = self:get_id_colour(accessories.AssetId)
	end
	-- apply the colours and stuff
	local shirt_colour = self:get_clothing_colour("Shirt")
	local pants_colour = self:get_clothing_colour("Pants")
	-- @
	local converted_model = PlayerService:CreateHumanoidModelFromDescriptionAsync(
		applied_description,
		humanoid_type == "R6" and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
	)
	converted_model.PrimaryPart = converted_model:FindFirstChild("HumanoidRootPart") :: BasePart
	-- fix dragging
	for _, child in converted_model:GetChildren() do
		if child:IsA("BasePart") or child:IsA("MeshPart") then
			(child :: BasePart).Locked = false
		end
	end
	-- instead we use a local shs server to avoid race conditions
	local local_shs = constructor:new()
	local_shs.Humanoid = converted_model:FindFirstChild("Humanoid") :: Humanoid
	if shirt_colour then
		local_shs:set_clothing_colour("Shirt", shirt_colour)
	end
	if pants_colour then
		local_shs:set_clothing_colour("Pants", pants_colour)
	end
	for id, colour in id_colours do
		if not colour then
			continue
		end
		local_shs:set_id_colour(id, colour)
		id_to_accessory_mat.remove(local_shs.Humanoid :: Humanoid, id)
	end
	return converted_model
end

function SimpleHumanoidDescription:set_id_transformation(id, trans_type, vec3)
	if not self.Humanoid then
		return
	end
	local humanoid = self.Humanoid
	local accessory_description = id_to_accessory_description.get(humanoid, id)
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
	local description = humanoid:GetAppliedDescription()
	humanoid:ApplyDescriptionAsync(description)
	return
end

function SimpleHumanoidDescription:get_id_transformation(id, trans_type)
	if not self.Humanoid then
		return
	end
	local humanoid = self.Humanoid
	local accessory_description = id_to_accessory_description.get(humanoid, id)
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
	if not self.Humanoid then
		return
	end
	local humanoid = self.Humanoid
	local id_material = id_to_accessory_mat.get(humanoid, id)
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
	if not self.Humanoid then
		return
	end
	local humanoid = self.Humanoid
	local return_value: Color3
	local id_material = id_to_accessory_mat.get(humanoid, id)
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
	if not self.Humanoid then
		return
	end
	local humanoid = self.Humanoid
	local humanoid_parent = humanoid.Parent
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
	if not self.Humanoid then
		return
	end
	local humanoid = self.Humanoid
	local humanoid_parent = humanoid.Parent
	local clothing = (humanoid_parent :: Instance):FindFirstChild(type)
	if not clothing then
		return
	end
	if clothing:IsA("Shirt") or clothing:IsA("Pants") then
		(clothing :: Clothing).Color3 = colour
	end
	return
end

function SimpleHumanoidDescription:get_id_accessory(id)
	if not self.Humanoid then
		return
	end
	local humanoid = self.Humanoid
	local accessory_description = id_to_accessory_description.get(humanoid, id)
	if not accessory_description then
		return
	end
	return accessory_description:GetAppliedInstance() :: Accessory
end

function SimpleHumanoidDescription:get_id_texture(id)
	if not self.Humanoid then
		return
	end
	local humanoid = self.Humanoid
	local id_material = id_to_accessory_mat.get(humanoid, id)
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
	if not self.Humanoid then
		return
	end
	local humanoid = self.Humanoid
	local id_material = id_to_accessory_mat.get(humanoid, id)
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

	local rbx_asset_uri = (type(texture_id) == "number" and `rbxassetid://{texture_id}` or texture_id) :: string

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
	if not self.Humanoid then
		return
	end
	local humanoid = self.Humanoid
	local id_material = id_to_accessory_mat.get(humanoid, id)
	if not id_material then
		return
	end
	local base_material_id = id_material:GetAttribute("base_material_id") :: string?
	if not base_material_id then
		return
	end
	local texture_id = base_material_id:match("(%d+)")
	if not texture_id then
		return
	end
	self:set_id_texture(id, tonumber(texture_id) :: number)
	return
end

function SimpleHumanoidDescription:get_id_asset_info_list()
	return wearing_cache(self:get_id_list())
end

function SimpleHumanoidDescription:set_makeup_order(id, order)
	if not self.Humanoid then
		return
	end
	local humanoid = self.Humanoid
	local description = humanoid:GetAppliedDescription()
	makeup_description_helper.set_makeup_order(description, id, order)
	humanoid:ApplyDescriptionAsync(description)
end

function SimpleHumanoidDescription:get_makeup_order()
	if not self.Humanoid then
		return {}
	end
	local description = self.Humanoid:GetAppliedDescription()
	return makeup_description_helper.get_makeup(description)
end

function SimpleHumanoidDescription:set_layered_clothing_order(id, order)
	if not self.Humanoid then
		return
	end
	local humanoid = self.Humanoid
	local accessory_description = id_to_accessory_description.get(humanoid, id)
	if not accessory_description then
		return
	end
	accessory_description.Order = order
	local description = humanoid:GetAppliedDescription()
	humanoid:ApplyDescriptionAsync(description)
end

function SimpleHumanoidDescription:get_layered_clothing_order()
	if not self.Humanoid then
		return {}
	end
	local humanoid = self.Humanoid
	local description = humanoid:GetAppliedDescription()
	return description:GetAccessories(false) :: any
end

function SimpleHumanoidDescription:get_highest_layered_clothing_count()
	local layered_clothing = self:get_layered_clothing_order()
	local order = 0
	for _, layered in layered_clothing do
		if layered.Order > order then
			order = layered.Order
		end
	end
	return order
end

function SimpleHumanoidDescription:_generate_error_event(error_type, message, method)
	if self.on_error then
		self.on_error({
			message = message,
			retry = method,
			type = error_type,
		})
	end
end

function constructor:new(): SimpleHumanoidDescription
	local struct = {
		Humanoid = nil,
		BaseHumanoidDescription = nil,
		humanoid_changed = Instance.new("BindableEvent"),
		id_added = Instance.new("BindableEvent"),
		id_removed = Instance.new("BindableEvent"),
		id_operations_ready_event = Instance.new("BindableEvent"),
		_id_operations_lock = false,
		on_error = nil,
		inited_humanoids = {},
	}
	return setmetatable(struct, SimpleHumanoidDescription)
end

return constructor
