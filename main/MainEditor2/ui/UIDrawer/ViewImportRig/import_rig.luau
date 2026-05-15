--humanoid description for base rig
local components = require("../../components")
local rigbuilder = require("./rigbuilder")
local ui_lib = components.lune_ui
local function load_rig(gender: "base" | "female", rig_type: "R6" | "R15", username: string): string
	local rig_type_enum = rig_type == "R6" and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
	if username ~= "" then
		rigbuilder.from_user(username, rig_type_enum, workspace)
		return `Created {username}`
	end

	rigbuilder.from_base(gender, rig_type_enum, workspace)
	return `Created {rig_type} base rig`
end

return function(parent: Instance?)
	local import_rig_view = ui_lib.empty_frame()
	import_rig_view.Visible = false
	import_rig_view.Name = "Create Rig"
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
		ui_lib.option_buttons(import_rig_view, { "Base Rig", "Female Rig" }, function(value: string): nil
			local mappings = {
				["Base Rig"] = "base",
				["Female Rig"] = "female",
			}
			selected_gen = mappings[value]
			return
		end)
		ui_lib.property_scope({ Size = UDim2.new(0, 0, 0, 32), Parent = import_rig_view }, function()
			local username_input = ui_lib.textbox("Enter username or leave blank for default rig")
			local R6 = ui_lib.textbutton("Create new R6 Rig", nil, function()
				load_rig(selected_gen, "R6", username_input.Text)
			end)

			local R15 = ui_lib.textbutton("Create new R15 Rig", nil, function()
				load_rig(selected_gen, "R15", username_input.Text)
			end)

			return
		end)
		--container.Parent = import_rig_view
	end
	return import_rig_view
end
