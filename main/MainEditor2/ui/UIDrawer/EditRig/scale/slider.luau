--!strict
local lune = require("../../../components/lune_ui")
local humanoid_editor = require("../../../../singletons/SimpleHumanoidDescription")
local function line(one: Instance, two: Instance, parent: Instance?)
	local container = lune.empty_frame()
	local horz_layout = Instance.new("UIListLayout")
	horz_layout.SortOrder = Enum.SortOrder.LayoutOrder
	horz_layout.FillDirection = Enum.FillDirection.Horizontal
	horz_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	horz_layout.HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween
	horz_layout.VerticalAlignment = Enum.VerticalAlignment.Center
	horz_layout.Padding = UDim.new(0, 8)
	horz_layout.Parent = container
	one.Parent = container
	two.Parent = container
	container.Size = UDim2.new(1, 0, 0, 32)
	container.Parent = parent
	return container
end

return function(parent: Instance?)
	local container = lune.empty_frame(parent)
	container.Name = "Slider"
	local vbox = lune.styling.vbox(container)
	vbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
	vbox.VerticalAlignment = Enum.VerticalAlignment.Center
	local default_body_scale = humanoid_editor:get_body_scale()
	local slider_height, slider_height_control = lune.slider(
		default_body_scale.Height,
		nil,
		function(value: number): nil
			humanoid_editor:set_body_scale("Height", value)
			return
		end
	)
	local slider_width, slider_w_control = lune.slider(default_body_scale.Width, nil, function(value: number): nil
		humanoid_editor:set_body_scale("Width", value)
		return
	end)
	local slider_head, slider_head_control = lune.slider(default_body_scale.Head, nil, function(value: number): nil
		humanoid_editor:set_body_scale("Head", value)
		return
	end)
	local slider_depth, slider_d_control = lune.slider(default_body_scale.Depth, nil, function(value: number): nil
		humanoid_editor:set_body_scale("Depth", value)
		return
	end)
	local slider_prop, slider_p_control = lune.slider(default_body_scale.Proportion, nil, function(value: number): nil
		humanoid_editor:set_body_scale("Proportion", value)
		return
	end)
	local sliders = {
		Height = slider_height_control,
		Width = slider_w_control,
		Head = slider_head_control,
		Depth = slider_d_control,
		Proportion = slider_p_control,
	}
	line(lune.textlabel("Height Scale"), slider_height, container)
	line(lune.textlabel("Width Scale"), slider_width, container)
	line(lune.textlabel("Head Scale"), slider_head, container)
	line(lune.textlabel("Depth Scale"), slider_depth, container)
	line(lune.textlabel("Proportion Scale"), slider_prop, container)
	lune.textbutton("Reset", container, function()
		for _, slider_impl in sliders do
			slider_impl.reset()
		end
	end)
	local on_changed = humanoid_editor.humanoid_changed.Event:Connect(function(...: any)
		if not humanoid_editor:is_init() then
			return
		end
		local updated_scale = humanoid_editor:get_body_scale()
		for scale: any, value in updated_scale do
			sliders[scale].set(value)
		end
	end)
	container.Destroying:Connect(function(...)
		on_changed:Disconnect()
	end)

	return container
end
