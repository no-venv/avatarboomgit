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
	container.Name = "Custom"
	local vbox = lune.styling.vbox(container)
	vbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
	vbox.VerticalAlignment = Enum.VerticalAlignment.Center
	local default_body_scale = humanoid_editor:get_body_scale()

	local textbox_height = lune.textbox("Height Scale", nil, function(value: string)
		local number = tonumber(value)
		if not number then
			return
		end
		humanoid_editor:set_body_scale("Height", number)
		return
	end)

	local textbox_width = lune.textbox("Width Scale", nil, function(value: string)
		local number = tonumber(value)
		if not number then
			return
		end
		humanoid_editor:set_body_scale("Width", number)
		return
	end)

	local textbox_head = lune.textbox("Head Scale", nil, function(value: string)
		local number = tonumber(value)
		if not number then
			return
		end
		humanoid_editor:set_body_scale("Head", number)
		return
	end)

	local textbox_depth = lune.textbox("Depth Scale", nil, function(value: string)
		local number = tonumber(value)
		if not number then
			return
		end
		humanoid_editor:set_body_scale("Depth", number)
		return
	end)

	local textbox_proportion = lune.textbox("Width Scale", nil, function(value: string)
		local number = tonumber(value)
		if not number then
			return
		end
		humanoid_editor:set_body_scale("Proportion", number)
		return
	end)

	local function update_textbox(scale_data)
		textbox_height.Text = scale_data.Height
		textbox_width.Text = scale_data.Width
		textbox_head.Text = scale_data.Head
		textbox_depth.Text = scale_data.Depth
		textbox_proportion.Text = scale_data.Proportion
	end

	line(lune.textlabel("Height Scale"), textbox_height, container)
	line(lune.textlabel("Width Scale"), textbox_width, container)
	line(lune.textlabel("Head Scale"), textbox_head, container)
	line(lune.textlabel("Depth Scale"), textbox_depth, container)
	line(lune.textlabel("Proportion Scale"), textbox_proportion, container)
	lune.textbutton("Reset", container, function()
		for key, value in default_body_scale do
			humanoid_editor:set_body_scale(key, value)
		end
		update_textbox(default_body_scale)
	end)
	local on_changed = humanoid_editor.humanoid_changed.Event:Connect(function(...: any)
		if not humanoid_editor:is_init() then
			return
		end
		local updated_scale = humanoid_editor:get_body_scale()
		update_textbox(updated_scale)
	end)
	container.Destroying:Connect(function(...)
		on_changed:Disconnect()
	end)
	update_textbox(default_body_scale)
	return container
end
