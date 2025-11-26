type OnTransformFunc = (type: "Move" | "Rotation" | "Scale" | "Reset", value: Vector3) -> nil
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
-- local gizmo = require(script.Gizmo)
local move = require("@self/move")
local rotation = require("@self/rotation")
local uniform_scale = require("@self/uniform_scale")
local ui_lib = require("@self/../lune_ui")
local shared = require("../../shared")
local plugin = shared.plugin.plugin
local core_gui = (game :: any).CoreGui
return function(primary_part: BasePart, on_transform: OnTransformFunc)
	local current_gizmo: HandlesBase? = nil
	local billboard_gui = Instance.new("BillboardGui")
	billboard_gui.Active = true
	billboard_gui.AlwaysOnTop = true
	billboard_gui.Size = UDim2.new(0, 96, 0, 256)
	billboard_gui.Parent = (game :: any).CoreGui
	local container = ui_lib.empty_frame(billboard_gui)
	local vert_layout = Instance.new("UIListLayout")
	vert_layout.Padding = UDim.new(0, 8)
	vert_layout.HorizontalFlex = Enum.UIFlexAlignment.Fill
	vert_layout.SortOrder = Enum.SortOrder.LayoutOrder
	vert_layout.Parent = container
	local gizmos = {
		Move = move(core_gui, primary_part, "Position", function(value: Vector3, scale: Vector3)
			on_transform("Move", value)
			return
		end),
		Rotation = rotation(core_gui, primary_part, function(value: Vector3)
			on_transform("Rotation", value)
			return
		end),
		Scale = move(core_gui, primary_part, "Scale", function(value: Vector3, scale: Vector3)
			on_transform("Move", value)
			on_transform("Scale", scale)
			return
		end),
		UniformScale = uniform_scale(core_gui, primary_part, function(scale: Vector3)
			on_transform("Scale", scale)
			return
		end),
	}
	local self = {
		update_position = function()
			billboard_gui.StudsOffsetWorldSpace = primary_part.Position + Vector3.new(2, 0, 0)
		end,
		toggle = function(gizmo_type: "Move" | "Rotation" | "Scale" | "UniformScale")
			if current_gizmo then
				current_gizmo.Visible = false
			end
			gizmos[gizmo_type].Visible = true
			current_gizmo = gizmos[gizmo_type]
		end,
		hide = function()
			for _, gizmo in gizmos do
				gizmo.Visible = false
			end
		end,
	}

	local move_button = ui_lib.textbutton("Move", container, function(): nil
		self.toggle("Move")
		return
	end)
	local rot_button = ui_lib.textbutton("Rotation", container, function(): nil
		self.toggle("Rotation")
		return
	end)
	local scale_button = ui_lib.textbutton("Scale", container, function(): nil
		self.toggle("Scale")
		return
	end)
	local uniform_scale_button = ui_lib.textbutton("Uniform Scale", container, function(): nil
		self.toggle("UniformScale")
		return
	end)
	local reset_button = ui_lib.textbutton("Reset", container, function(): nil
		on_transform("Reset", Vector3.zero)
		return
	end)
	local hide_gizmos_button = ui_lib.textbutton("Hide Gizmos", container, function(): nil
		self.hide()
		return
	end)

	local buttons = {
		rot_button,
		move_button,
		reset_button,
		scale_button,
		hide_gizmos_button,
		uniform_scale_button,
	}

	for _, button in buttons do
		button.MouseEnter:Connect(function(x: number, y: number)
			button.Transparency = 0
		end)
		button.MouseLeave:Connect(function(x: number, y: number)
			button.Transparency = 0.5
		end)
		button.Transparency = 0.5
	end
	if plugin then
		plugin:Activate(true)
	end

	local render_stepped = RunService.RenderStepped:Connect(function(a0: number)
		billboard_gui.StudsOffsetWorldSpace = primary_part.Position + Vector3.new(2, 0, 0)
		return
	end)

	local gizmo_transform_instance = Instance.new("Model")
	gizmo_transform_instance.Destroying:Connect(function(...)
		if plugin then
			plugin:Activate(false)
		end
		for _, gizmo in gizmos do
			gizmo:Destroy()
		end
		render_stepped:Disconnect()
		billboard_gui:Destroy()
		return
	end)
	return gizmo_transform_instance
end
