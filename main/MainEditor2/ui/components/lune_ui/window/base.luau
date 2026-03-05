local lune_overlay = require("../lune_overlay")
local empty_frame = require("../empty_frame")
local textlabel = require("../textlabel")
local iconbutton = require("../iconbutton")
local styling = require("../styling_components")
local theme_manager = require("../theme_manager")
export type BaseWindowArguments = {
	title: string,
	size: Vector2?,
	view: Frame?,
	important: boolean?,
	custom_embed: Frame?,
}
return function(arg: BaseWindowArguments)
	local title = arg.title
	local size = arg.size
	local view = arg.view
	local important = arg.important
	local custom_embed = arg.custom_embed
	local shadow_container = empty_frame()
	shadow_container.BackgroundColor3 = Color3.new()
	styling.corner(shadow_container)
	local container = empty_frame(shadow_container)
	container.ZIndex = 10
	local size = size or Vector2.new(320, 240)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.new(0.5, 0, 0.5, 0)
	container.Size = UDim2.new(
		size.X < 1 and size.X or 0,
		size.X > 1 and size.X or 0,
		size.Y < 1 and size.Y or 0,
		size.Y > 1 and size.Y or 0
	)
	container.Transparency = 0
	styling.corner(container)
	styling.stroke(container)
	styling.padding(container)
	do
		local vbox = styling.vbox(container)
		vbox.Padding = UDim.new(0, 8)
		vbox.VerticalFlex = Enum.UIFlexAlignment.Fill
	end

	local topbar = empty_frame(container)
	topbar.Size = UDim2.new(1, 0, 0, 32)
	textlabel(title, topbar).Size = UDim2.new(1, 0, 1, 0)
	local exit = iconbutton({
		id = 95107155761501,
		theme_enabled = true,
		on_click = function()
			shadow_container:Destroy()
		end,
		parent = topbar,
	})

	exit.AnchorPoint = Vector2.new(1, 0)
	exit.Position = UDim2.new(1, 0, 0, 0)
	--styling.hbox(topbar)
	--	.HorizontalFlex = Enum.UIFlexAlignment.Fill

	--div(container)
	local view_container = empty_frame(container)
	view.Parent = view_container
	theme_manager:add_custom_gui_instance(container, "Foreground")
	shadow_container.Parent = custom_embed or lune_overlay
	if important then
		shadow_container.Transparency = 0.5
	end
	return shadow_container
end
