local lune = require("../../components/lune_ui")
local humanoid_editor = require("../../../singletons/SimpleHumanoidDescription")

local custom_scale = require("@self/custom")
local slider_scale = require("@self/slider")
return function(parent: Instance?)
	local container = lune.empty_frame(parent)
	container.Name = "Body Scale"
	local r15_warning_overlay = lune.empty_frame(container)
	local textlabel = lune.textlabel("You need a R15 rig to change the body scale.", r15_warning_overlay)
	textlabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textlabel.Position = UDim2.new(0.5, 0, 0.5)
	r15_warning_overlay.Visible = false
	local tab_container = lune.tab({ slider_scale(), custom_scale() }, "Slider", container)
	local on_changed = humanoid_editor.humanoid_changed.Event:Connect(function(...: any)
		if not humanoid_editor:is_init() then
			return
		end
		local rig_type = humanoid_editor:get_humanoid_type()
		tab_container.Visible = rig_type == "R15"
		r15_warning_overlay.Visible = rig_type == "R6"
	end)
	container.Destroying:Connect(function(...)
		on_changed:Disconnect()
	end)
	return container
end
