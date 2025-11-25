local lune = script.Parent.Parent
local lune_overlay = require(lune.lune_overlay)
local empty_frame = require(lune.empty_frame)
local textlabel = require(lune.textlabel)
local iconbutton = require(lune.iconbutton)
local div = require(lune.divider)
local styling = require(lune.styling_components)
local theme_manager = require(lune.theme_manager)
return function(title : number, size : Vector2?, view : Frame, important : boolean?)

	local container = empty_frame()
	container.ZIndex = 10
	size = size or Vector2.new(320,240)
	container.AnchorPoint = Vector2.new(0.5,0.5)
	container.Position = UDim2.new(0.5,0,0.5,0)
	container.Size = UDim2.new(0,size.X,0,size.Y)
	container.Transparency = 0 
	styling.corner(container)
	styling.stroke(container)
	styling.padding(container)
	do
		local vbox = styling.vbox(container)
		vbox.Padding = UDim.new(0,8)
		vbox.VerticalFlex = Enum.UIFlexAlignment.Fill
	end
	
	local topbar = empty_frame(container)
	topbar.Size = UDim2.new(1,0,0,32)
	textlabel(title,topbar)
		.Size = UDim2.new(1,0,1,0)
	local exit = iconbutton {
		id = 95107155761501;
		theme_enabled = true;
		on_click = function()
			container:Destroy()
		end,
		parent = topbar
	}
	
	exit.AnchorPoint = Vector2.new(1,0)
	exit.Position = UDim2.new(1,0,0,0)
	--styling.hbox(topbar)
	--	.HorizontalFlex = Enum.UIFlexAlignment.Fill
	
	--div(container)
	local view_container = empty_frame(container)
	view.Parent = view_container
	theme_manager:add_custom_gui_instance(container,"Foreground")
	container.Parent = lune_overlay
	local shadow = empty_frame()
	shadow.Transparency = 0.5
	if important then
		shadow.Parent = lune_overlay
	end
	container.Destroying:Connect(function() 
		shadow:Destroy()	
	end)
	return container
end