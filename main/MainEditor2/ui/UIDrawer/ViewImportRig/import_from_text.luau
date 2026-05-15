--!strict
local rigbuilder = require("./rigbuilder")
local components = require("../../components")
local humanoid_description_server =
	require("../../../singletons/SimpleHumanoidDescription/SimpleHumanoidDescriptionServer")
local lune = components.lune_ui
return function(parent: Instance?)
	local container = lune.empty_frame(parent)
	container.Name = "Import from Text"
	do
		local vbox = lune.styling.vbox(container)
		vbox.HorizontalFlex = Enum.UIFlexAlignment.Fill
		vbox.VerticalFlex = Enum.UIFlexAlignment.Fill
	end
	local textbox = lune.textbox("Paste text containing ids", container)
	textbox.Size = UDim2.fromScale(1, 1)
	local selected_rig_type
	local option_container, option_interface = lune.option_buttons(container, { "R6", "R15" }, function(value: string)
		selected_rig_type = (value == "R6") and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
	end)
	option_interface.set("R15")

	lune.textbutton("Import Rig From Text", container, function()
		-- Create our own SimpleHumanoidDescriptionServer to avoid race conditions
		local humanoid_model = rigbuilder.from_base("base", selected_rig_type)
		local humanoid = humanoid_model:FindFirstChild("Humanoid") :: Humanoid
		humanoid_model.Parent = workspace

		local server = humanoid_description_server:new()
		server:init(humanoid)
		local ids = {}
		for value in textbox.Text:gmatch("%d+") do
			local id = tonumber(value)
			if id then
				table.insert(ids, id)
			end
		end
		local ok,result = pcall(function(...)
			server:batch_add_id(ids)
		end)
		if not ok then
			humanoid_model:Destroy()
			error(result)
		end
	end)
	return container
end
