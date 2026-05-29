--!strict
local Selection = game:GetService("Selection")
local lune = require("../../../components/lune_ui")
local humanoid_description_server =
	require("../../../../singletons/SimpleHumanoidDescription/SimpleHumanoidDescriptionServer")
local humanoid_description = require("../../../../singletons/SimpleHumanoidDescription")
local HEAD_COLOUR = Color3.fromRGB(255, 0, 0)
local LEFT_ARM_COLOUR = Color3.fromRGB(255, 255, 0)
local RIGHT_ARM_COLOUR = Color3.fromRGB(255, 255, 255)
local TORSO_COLOUR = Color3.fromRGB(0, 255, 0)
local LEFT_LEG_COLOUR = Color3.fromRGB(0, 255, 255)
local RIGHT_LEG_COLOUR = Color3.fromRGB(0, 0, 255)

local accessory_attachment = {
	[Enum.AvatarAssetType.BackAccessory] = TORSO_COLOUR,
	[Enum.AvatarAssetType.FaceAccessory] = HEAD_COLOUR,
	[Enum.AvatarAssetType.HairAccessory] = HEAD_COLOUR,
	[Enum.AvatarAssetType.Hat] = HEAD_COLOUR,
	[Enum.AvatarAssetType.NeckAccessory] = HEAD_COLOUR,
	[Enum.AvatarAssetType.FrontAccessory] = TORSO_COLOUR,
	[Enum.AvatarAssetType.PantsAccessory] = TORSO_COLOUR,
	[Enum.AvatarAssetType.ShirtAccessory] = TORSO_COLOUR,
	[Enum.AvatarAssetType.WaistAccessory] = TORSO_COLOUR,
	[Enum.AvatarAssetType.JacketAccessory] = TORSO_COLOUR,
	[Enum.AvatarAssetType.ShortsAccessory] = TORSO_COLOUR,
	[Enum.AvatarAssetType.TShirtAccessory] = TORSO_COLOUR,
	[Enum.AvatarAssetType.EyebrowAccessory] = HEAD_COLOUR,
	[Enum.AvatarAssetType.EyelashAccessory] = HEAD_COLOUR,
	[Enum.AvatarAssetType.SweaterAccessory] = TORSO_COLOUR,
	[Enum.AvatarAssetType.LeftShoeAccessory] = LEFT_LEG_COLOUR,
	[Enum.AvatarAssetType.ShoulderAccessory] = TORSO_COLOUR,
	[Enum.AvatarAssetType.RightShoeAccessory] = RIGHT_LEG_COLOUR,
	[Enum.AvatarAssetType.DressSkirtAccessory] = TORSO_COLOUR,
}

local limb_transparency_id = {
	Head = 0.0, -- 1.0
	LeftFoot = 0.15, -- 0.85
	LeftHand = 0.20, -- 0.80
	LeftLowerArm = 0.25, --0.75
	LeftLowerLeg = 0.30, -- 0.70
	LeftUpperArm = 0.35, -- 0.65
	LeftUpperLeg = 0.40, -- 0.60
	LowerTorso = 0.45, -- 0.55
	RightFoot = 0.50, -- 0.50
	RightHand = 0.55, --0.45
	RightLowerArm = 0.60, -- 0.40
	RightLowerLeg = 0.65, -- 0.35
	RightUpperArm = 0.70, -- 0.30
	RightUpperLeg = 0.75, -- 0.25
	UpperTorso = 0.80, -- 0.20
}

local function snap_model(model: Model)
	local _, bounding_size = model:GetBoundingBox()
	local current_pivot = model:GetPivot()
	model:PivotTo(CFrame.new(Vector3.new(current_pivot.Position.X, (bounding_size.Y / 2), current_pivot.Position.Z)))
end

return function()
	-- get the current rig and clone
	local humanoid = humanoid_description.Humanoid
	if not humanoid then
		return
	end
	local selected_rig = humanoid.Parent :: Model
	local rig = humanoid_description:get_humanoid_type() == "R6" and humanoid_description:convert_humanoid_type("R15")
		or selected_rig:Clone()

	local ignore_avatarboom = Instance.new("BoolValue")
	ignore_avatarboom.Name = "DELETE_THIS_IF_YOU_WANT_TO_USE_THIS_RIG"
	ignore_avatarboom.Parent = rig

	rig.Name = "EXPORT"
	rig.PrimaryPart.Position = Vector3.new(0, 3, 0)
	rig.Parent = workspace

	local humanoid = rig:FindFirstChild("Humanoid") :: Humanoid
	local local_humanoid_description = humanoid_description_server:new()
	local_humanoid_description:init(humanoid)

	for _,part in rig:GetChildren() do
		local transparency_id = limb_transparency_id[part.Name]
		if transparency_id then
			(part::BasePart).Transparency = transparency_id
		end
	end

	for _, asset in humanoid_description:get_id_asset_info_list() do
		local id = asset.Id
		local accessory = local_humanoid_description:get_id_accessory(id)
		if accessory then
			local handle_part = accessory:FindFirstChild("Handle") :: BasePart
			if not handle_part then
				return
			end
			local asset_type = Enum.AvatarAssetType:FromName(asset.AssetType)
			if not asset_type then
				return
			end

			local attachment_colour = accessory_attachment[asset_type]
			if not attachment_colour then
				warn(`{asset_type} is not able to be exported yet.`)
			else
				handle_part.Color = accessory_attachment[asset_type]
			end
		end
	end

	rig.Archivable = false
	
	local export_folder = Instance.new("Folder")
	export_folder.Archivable = false
	export_folder.Parent = workspace

	rig.Parent = export_folder
	Selection:Set({ export_folder })

	task.defer(function()
		-- FLINT AND STEEL
		-- ENDER PEARL
		-- CHICKEN JOCKEY
		rig:SetPrimaryPartCFrame(CFrame.new(0, 3, 0))
		snap_model(rig)
		PluginManager():ExportSelection()
	end)

	local container = lune.empty_frame()
	local vbox = lune.styling.vbox(container)
	vbox.HorizontalFlex = Enum.UIFlexAlignment.Fill
	vbox.VerticalFlex = Enum.UIFlexAlignment.SpaceEvenly
	lune.textlabel("Almost there!", container)
	lune.textlabel("You need to copy and paste this link in the browser to finish exporting the rig.", container)
	local link_textbox = lune.textbox("", container)
	link_textbox.TextEditable = false
	link_textbox.ClearTextOnFocus = false
	link_textbox.Text = "https://no-venv.github.io/blockbench/"
	container.Destroying:Connect(function()
		export_folder:Destroy()
		Selection:Set({ selected_rig })
	end)
	return container
end
