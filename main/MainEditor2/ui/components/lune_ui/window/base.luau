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
	hide_exit: boolean?,
	left_topbar: { GuiBase }?,
	middle_topbar: GuiBase?,
	right_topbar: { GuiBase }?,
}
return function(arg: BaseWindowArguments)
	local title = arg.title
	local view = arg.view
	local size = arg.size or Vector2.new(320, 240)
	local important = arg.important
	local custom_embed = arg.custom_embed
	local shadow_container = empty_frame()
	shadow_container.BackgroundColor3 = Color3.new()
	styling.corner(shadow_container)

	local container = empty_frame(shadow_container)
	container.ZIndex = 1000
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.new(0.5, 0, 0.5, 0)
	container.Size = UDim2.new(
		size.X < 1 and size.X or 0,
		size.X > 1 and size.X or 0,
		size.Y < 1 and size.Y or 0,
		size.Y > 1 and size.Y or 0
	)
	container.Transparency = 0
	local input_catcher = Instance.new("TextButton")
	input_catcher.Transparency = 1
	input_catcher.BorderSizePixel = 0
	input_catcher.AnchorPoint = container.AnchorPoint
	input_catcher.Position = container.Position
	input_catcher.Size = container.Size
	input_catcher.Parent = shadow_container
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

	local hbox = styling.hbox(topbar)
	hbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
	hbox.HorizontalFlex = Enum.UIFlexAlignment.Fill

	local left_topbar = empty_frame(topbar)
	left_topbar.Size = UDim2.new(0.0, 0, 1, 0)
	left_topbar.AutomaticSize = Enum.AutomaticSize.X
	styling.hbox(left_topbar)
	local middle_topbar = empty_frame(topbar)
	local right_topbar = empty_frame(topbar)
	right_topbar.Size = UDim2.new(0.0, 0, 1, 0)
	right_topbar.AutomaticSize = Enum.AutomaticSize.X

	styling.hbox(right_topbar).HorizontalAlignment = Enum.HorizontalAlignment.Right

	if not arg.middle_topbar then
		textlabel(title, middle_topbar).Size = UDim2.new(1, 0, 1, 0)
	end
	if not arg.hide_exit then
		iconbutton({
			id = 95107155761501,
			theme_enabled = true,
			on_click = function()
				shadow_container:Destroy()
			end,
			parent = right_topbar,
		})
	end
	if arg.left_topbar then
		for _, element in arg.left_topbar do
			element.Parent = left_topbar
		end
	end
	if arg.middle_topbar then
		arg.middle_topbar.Parent = middle_topbar
	end
	if arg.right_topbar then
		for _, element in arg.right_topbar do
			element.Parent = right_topbar
		end
	end

	-- exit.AnchorPoint = Vector2.new(1, 0)
	-- exit.Position = UDim2.new(1, 0, 0, 0)
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
