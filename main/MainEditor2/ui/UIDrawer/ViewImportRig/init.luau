local components = require("../components")
local rig_models = require("@self/rigs")
local Players = game:GetService("Players")
local ui_lib = components.lune_ui
local fem_rigs = rig_models:FindFirstChild("Fem")
local masc_rigs = rig_models:FindFirstChild("Masc")
local function selectable_rig(rig: Model)
	for _, limb in rig:GetChildren() do
		if limb:IsA("Part") or limb:IsA("MeshPart") then
			limb.Locked = false
			limb.CollisionGroup = "Default"
		end
	end
end
local function load_rig(selected_rig_folder: Instance, rig_type: "R6" | "R15", username: string): string
	local current_camera = workspace.CurrentCamera
	local spawn_position = (current_camera.CFrame.Position - Vector3.new(0, 1.5, 0))
		+ (current_camera.CFrame.LookVector * 8)
	if username ~= "" then
		local rig_type_enum = rig_type == "R6" and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
		local to_userid = Players:GetUserIdFromNameAsync(username)
		local hum_desc = Players:GetHumanoidDescriptionFromUserId(to_userid)
		local rig_model = Players:CreateHumanoidModelFromDescription(hum_desc, rig_type_enum) :: Model
		rig_model.Parent = workspace
		rig_model:MoveTo(spawn_position)
		selectable_rig(rig_model)
		return `Created {username}`
	end

	local rig = selected_rig_folder:FindFirstChild(rig_type)
	local cloned_rig = rig:Clone() :: Model
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
		local selected_folder = fem_rigs
		ui_lib.property_scope({ Size = UDim2.new(0, 0, 0, 32), Parent = import_rig_view }, function()
			local username_input = ui_lib.textbox("Enter username or leave blank for default rig")
			local R6 = ui_lib.textbutton("R6", nil, function()
				load_rig(selected_folder, "R6", username_input.Text)
			end)

			local R15 = ui_lib.textbutton("R15", nil, function()
				load_rig(selected_folder, "R15", username_input.Text)
			end)

			return
		end)
		ui_lib.option_buttons(import_rig_view, { "Male Rig", "Female Rig" }, function(value: string): nil
			local mappings = {
				["Male Rig"] = masc_rigs,
				["Female Rig"] = fem_rigs,
			}
			selected_folder = mappings[value]
			return
		end)
		--container.Parent = import_rig_view
	end
	return import_rig_view
end
