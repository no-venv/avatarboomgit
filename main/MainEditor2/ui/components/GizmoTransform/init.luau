--!strict
type OnTransformFunc = (type: "Move" | "Rotation" | "Scale" | "Reset", value: Vector3) -> ()
local move = require("@self/move")
local rotation = require("@self/rotation")
local uniform_scale = require("@self/uniform_scale")
local ui_lib = require("@self/../lune_ui")
local shared = require("../../shared")
local plugin = shared.plugin.plugin
local core_gui = (game :: any).CoreGui
return function(primary_part: BasePart, on_transform: OnTransformFunc)
	local current_gizmo: HandlesBase? = nil
	local billboard_gui = Instance.new("ScreenGui")
	billboard_gui.Parent = (game :: any).CoreGui
	local lune_overlay = ui_lib.empty_frame(billboard_gui)
	local container = ui_lib.empty_frame(billboard_gui)
	container.Position = UDim2.new(0, 8, 0.0, 8)
	container.Size = UDim2.new(1, 48, 0, 256)
	ui_lib.styling.vbox(container)

	local gizmos: { [string]: any } = {
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

	ui_lib.tooltips(
		ui_lib.iconbutton({
			parent = container,
			id = shared.icons.drag,
			theme_enabled = true,
			tooltip = "Move",
			on_click = function()
				self.toggle("Move")
			end,
		}),
		"Move",
		lune_overlay
	)

	ui_lib.tooltips(
		ui_lib.iconbutton({
			parent = container,
			id = shared.icons.rotation,
			theme_enabled = true,
			on_click = function()
				self.toggle("Rotation")
			end,
		}),
		"Rotation",
		lune_overlay
	)

	ui_lib.tooltips(
		ui_lib.iconbutton({
			parent = container,
			id = shared.icons.scale,
			theme_enabled = true,
			on_click = function()
				self.toggle("Scale")
			end,
		}),
		"Scale",
		lune_overlay
	)

	ui_lib.tooltips(
		ui_lib.iconbutton({
			parent = container,
			id = shared.icons.uniform_scale,
			theme_enabled = true,
			on_click = function()
				self.toggle("UniformScale")
			end,
		}),
		"Uniform Scale",
		lune_overlay
	)

	ui_lib.tooltips(
		ui_lib.iconbutton({
			parent = container,
			id = shared.icons.reset,
			theme_enabled = true,
			on_click = function()
				on_transform("Reset", Vector3.zero)
				gizmos.Rotation:SetAttribute("force_update_frame", true)
			end,
		}),
		"Reset",
		lune_overlay
	)

	ui_lib.tooltips(
		ui_lib.iconbutton({
			parent = container,
			id = shared.icons.hide,
			theme_enabled = true,
			on_click = function()
				self.hide()
			end,
		}),
		"Hide Gizmos",
		lune_overlay
	)

	if plugin then
		plugin:Activate(true)
	end

	local gizmo_transform_instance = Instance.new("Model")
	gizmo_transform_instance.Destroying:Connect(function(...)
		if plugin then
			plugin:Activate(false)
		end
		for _, gizmo in gizmos do
			gizmo:Destroy()
		end
		billboard_gui:Destroy()
		return
	end)
	return gizmo_transform_instance
end
