local UI = script:FindFirstAncestor("MainEditor2")
local singletons = require(UI.singletons)
local humanoid_editor = singletons.humanoid_description
local ui_lib = require(UI.ui.components.lune_ui)
local function line(one : Instance, two : Instance, parent : Instance?)
	local container = ui_lib.empty_frame()
	local horz_layout = Instance.new("UIListLayout")
	horz_layout.SortOrder = Enum.SortOrder.LayoutOrder
	horz_layout.FillDirection = Enum.FillDirection.Horizontal
	horz_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	horz_layout.HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween
	horz_layout.VerticalAlignment = Enum.VerticalAlignment.Center
	horz_layout.Padding = UDim.new(0,8)
	horz_layout.Parent = container
	one.Parent = container
	two.Parent = container
	container.Size = UDim2.new(1,0,0,32)
	container.Parent = parent
	return container
end

return function(parent : Instance?)
	local container = ui_lib.empty_frame(parent)
	container.Name = "Body Scale"
	local r15_warning_overlay = ui_lib.empty_frame(container)
	local textlabel = ui_lib.textlabel("You need a R15 rig to change the body scale.",r15_warning_overlay)
	textlabel.AnchorPoint = Vector2.new(0.5,0.5)
	textlabel.Position = UDim2.new(0.5,0,0.5)
	
	r15_warning_overlay.Visible = false
	local inner_container = ui_lib.empty_frame(container)
	
	local vert_layout = Instance.new("UIListLayout")
	vert_layout.SortOrder = Enum.SortOrder.LayoutOrder
	vert_layout.Padding = UDim.new(0,8)
	vert_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	--vert_layout.HorizontalFlex = Enum.UIFlexAlignment.Fill
	vert_layout.VerticalAlignment = Enum.VerticalAlignment.Center
	vert_layout.Parent = inner_container
	container.BackgroundColor3 = Color3.new(1,1,1)
	container.Visible = true
	local default_body_scale = humanoid_editor:get_body_scale()
	local slider_height,slider_height_control = ui_lib.slider(default_body_scale.Height,nil,function(value: number): nil 
		humanoid_editor:set_body_scale("Height",value)
		return
	end)
	local slider_width,slider_w_control = ui_lib.slider(default_body_scale.Width,nil,function(value: number): nil 
		humanoid_editor:set_body_scale("Width",value)
		return
	end)
	local slider_head,slider_head_control = ui_lib.slider(default_body_scale.Head,nil,function(value: number): nil 
		humanoid_editor:set_body_scale("Head",value)
		return
	end)
	local slider_depth,slider_d_control = ui_lib.slider(default_body_scale.Depth,nil,function(value: number): nil 
		humanoid_editor:set_body_scale("Depth",value)
		return
	end)
	local slider_prop,slider_p_control = ui_lib.slider(default_body_scale.Proportion,nil,function(value: number): nil 
		humanoid_editor:set_body_scale("Proportion",value)
		return
	end)
	local sliders = {
		Height = slider_height_control;
		Width =  slider_w_control;
		Head = slider_head_control;
		Depth = slider_d_control;
		Proportion = slider_p_control;
	}
	humanoid_editor.humanoid_changed.Event:Connect(function(...: any) 
		if not humanoid_editor:is_init() then
			return
		end
		if humanoid_editor:get_humanoid_type() == "R6" then
			r15_warning_overlay.Visible = true
			inner_container.Visible = false
			return
		else
			r15_warning_overlay.Visible = false
			inner_container.Visible = true
		end
		local updated_scale = humanoid_editor:get_body_scale()
		
		for scale : any,value in updated_scale do
			sliders[scale].set(value)
		end
	end)
	
	line(ui_lib.textlabel("Height Scale"),slider_height,inner_container)
	line(ui_lib.textlabel("Width Scale"),slider_width,inner_container)
	line(ui_lib.textlabel("Head Scale"),slider_head,inner_container)
	line(ui_lib.textlabel("Depth Scale"),slider_depth,inner_container)
	line(ui_lib.textlabel("Proportion Scale"),slider_prop,inner_container)
	ui_lib.textbutton("Reset",inner_container,function()
		for _,slider_impl in sliders do
			slider_impl.reset()
		end
	end)

	return container
end