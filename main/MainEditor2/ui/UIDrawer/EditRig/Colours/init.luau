--!strict
local Editor = script:FindFirstAncestor("MainEditor2")
local components = require(Editor.ui.components)
local singletons = require(Editor.singletons)
local humanoid_editor = singletons.humanoid_description
local colour_wheel = components.colour_wheel
local skin_brick_colour = components.skin_brick_colour
local humanoid_viewport = components.humanoid_viewport
local ui_lib = components.lune_ui
local empty_frame = ui_lib.empty_frame

return function(parent : Instance?)
	local container = Instance.new("Frame")	
	container.Name = "Body Colour"
	container.Transparency = 1
	container.Size = UDim2.new(1,0,1,0)
	container.Parent = parent
	
	do
		local list_layout = Instance.new("UIListLayout")
		list_layout.Padding = UDim.new(0,8)
		list_layout.SortOrder = Enum.SortOrder.LayoutOrder
		list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		list_layout.VerticalFlex = Enum.UIFlexAlignment.Fill
		list_layout.Parent = container
	end
	
	local humanoid_viewport = humanoid_viewport(container)
	humanoid_viewport.instance.Size = UDim2.new(1,0,.8,0)
	local size_const = Instance.new("UISizeConstraint")
	size_const.MinSize = Vector2.new(0,32)
	local select_all_limbs = ui_lib.textbutton("Select All Limbs",container,function(): nil 
		humanoid_viewport.reset()
		return
	end)
	
	select_all_limbs.Size = UDim2.new(1,0,0,32)
	size_const.Parent = select_all_limbs
	local selected_body_part : string = "All"
	humanoid_viewport.on_body_part_click = function(body_part)
		selected_body_part = body_part
	end
	
	humanoid_editor.humanoid_changed.Event:Connect(function(...: any)
		if not humanoid_editor:is_init() then
			return
		end
		local body_colour = humanoid_editor:get_body_colours()
		for limb,colour in body_colour do
			humanoid_viewport.set_body_part_colour(limb,colour)
		end
	end)
	
	local function set_rig_colour(colour : Color3)
		humanoid_viewport.set_selected_body_part_colour(colour)
		if humanoid_editor:is_init() then
			humanoid_editor:set_body_colour(selected_body_part,colour)
		end
	end
	
	local hsv_container = empty_frame()
	local hsv_colour_picker = colour_wheel(hsv_container)
	hsv_colour_picker.on_colour = set_rig_colour
	local brick_colour_container = empty_frame()
	local brick_colour_picker = skin_brick_colour(brick_colour_container)
	brick_colour_picker.on_brick_colour_click = set_rig_colour
	hsv_container.Name = "HSV"
	brick_colour_container.Name = "Brick Colour"	
	local tab = ui_lib.tab({
		hsv_container;
		brick_colour_container;
	},"HSV",container)
	
	return container
end