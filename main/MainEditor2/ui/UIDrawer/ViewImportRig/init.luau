--humanoid description for base rig
local base_hum_desc = Instance.new("HumanoidDescription")
do
	local white = Color3.new(127, 127, 127)
	base_hum_desc.HeadColor = white
	base_hum_desc.TorsoColor = white
	base_hum_desc.RightArmColor = white
	base_hum_desc.LeftArmColor = white
	base_hum_desc.LeftLegColor = white
	base_hum_desc.RightLegColor = white
end
local fem_hum_desc = base_hum_desc:Clone()
fem_hum_desc.Torso = 48474356
--
local components = require("../components")
local Players = game:GetService("Players")
local ui_lib = components.lune_ui
local function selectable_rig(rig: Model)
	for _, limb in rig:GetChildren() do
		if limb:IsA("Part") or limb:IsA("MeshPart") then
			limb.Locked = false
			limb.CollisionGroup = "Default"
		end
	end
end
local function load_rig(gender: "Base" | "Female", rig_type: "R6" | "R15", username: string): string
	local current_camera = workspace.CurrentCamera
	local rig_type_enum = rig_type == "R6" and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
	local spawn_position = (current_camera.CFrame.Position - Vector3.new(0, 1.5, 0))
		+ (current_camera.CFrame.LookVector * 8)
	if username ~= "" then
		local to_userid = Players:GetUserIdFromNameAsync(username)
		local hum_desc = Players:GetHumanoidDescriptionFromUserId(to_userid)
		local rig_model = Players:CreateHumanoidModelFromDescription(hum_desc, rig_type_enum) :: Model
		rig_model.Parent = workspace
		rig_model:MoveTo(spawn_position)
		selectable_rig(rig_model)
		return `Created {username}`
	end

	local cloned_rig = Players:CreateHumanoidModelFromDescriptionAsync(
		gender == "Base" and base_hum_desc or fem_hum_desc,
		rig_type_enum
	)
	cloned_rig.Parent = workspace
	cloned_rig:MoveTo(spawn_position)

	selectable_rig(cloned_rig)
	return `Created {rig_type} base rig`
end

return function(parent: Instance?)
	local import_rig_view = ui_lib.empty_frame()
	import_rig_view.Visible = false
	import_rig_view.Name = "Import Rig"
	import_rig_view.Parent = parent
	do
		local list_layout = Instance.new("UIListLayout")
		list_layout.Padding = UDim.new(0, 8)
		list_layout.SortOrder = Enum.SortOrder.LayoutOrder
		list_layout.FillDirection = Enum.FillDirection.Vertical
		list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		list_layout.VerticalAlignment = Enum.VerticalAlignment.Center
		list_layout.HorizontalFlex = Enum.UIFlexAlignment.Fill
		list_layout.Parent = import_rig_view
	end

	do
		local selected_gen = "Base"
		ui_lib.property_scope({ Size = UDim2.new(0, 0, 0, 32), Parent = import_rig_view }, function()
			local username_input = ui_lib.textbox("Enter username or leave blank for default rig")
			local R6 = ui_lib.textbutton("R6", nil, function()
				load_rig(selected_gen, "R6", username_input.Text)
			end)

			local R15 = ui_lib.textbutton("R15", nil, function()
				load_rig(selected_gen, "R15", username_input.Text)
			end)

			return
		end)
		ui_lib.option_buttons(import_rig_view, { "Base Rig", "Female Rig" }, function(value: string): nil
			local mappings = {
				["Base Rig"] = "Base",
				["Female Rig"] = "Female",
			}
			selected_gen = mappings[value]
			return
		end)
		--container.Parent = import_rig_view
	end
	return import_rig_view
end
