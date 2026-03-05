type void = nil;
type TabImpl = {
	toggle : (target_view : string, bool :boolean) -> void;
	hide_button : (target_view : string, bool :boolean) -> void;
	get_current_view : () -> string;
	on_view_change : (view : string) -> void;
}
local textbutton = require("./textbutton")
local theme_manager = require("./theme_manager")
return function(views : {Frame},default_view : string,parent : Instance?,tab_bar_parent : Instance?) : (Frame,ScrollingFrame,TabImpl)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1,0,1,0)
	container.Transparency = 1
	container.Parent = parent
	local vert_list_layout = Instance.new("UIListLayout")
	vert_list_layout.Padding= UDim.new(0,8)
	vert_list_layout.Parent = container
	vert_list_layout.VerticalFlex = Enum.UIFlexAlignment.Fill
	vert_list_layout.SortOrder = Enum.SortOrder.LayoutOrder
	local scrolling_frame = Instance.new("ScrollingFrame")
	scrolling_frame.Name = "Tab"
	scrolling_frame.Transparency = 1
	scrolling_frame.CanvasSize = UDim2.new()
	scrolling_frame.AutomaticCanvasSize = Enum.AutomaticSize.X
	scrolling_frame.Size = UDim2.new(1,0,0,32)
	scrolling_frame.BorderSizePixel = 0
	scrolling_frame.ScrollBarThickness = 1
	scrolling_frame.Parent = tab_bar_parent or container
	local horiz_list_layout = Instance.new("UIListLayout")
	horiz_list_layout.FillDirection = Enum.FillDirection.Horizontal
	horiz_list_layout.Padding = UDim.new(0,8)
	horiz_list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	horiz_list_layout.Parent = scrolling_frame
	local size_const = Instance.new("UISizeConstraint")
	size_const.MinSize = Vector2.new(0,32)
	size_const.MaxSize = Vector2.new(math.huge,32)
	size_const.Parent = scrolling_frame
	local current_view : string = nil;
	local view_map = {}
	local self 
	local function toggle(target_view: string, bool : boolean)
		if current_view then
			local view = view_map[current_view]
			view[1].Visible = false
			theme_manager:force_highlight(view[2],false)
		end
		local view = view_map[target_view]
		view[1].Visible = true
		theme_manager:force_highlight(view[2],true)
		current_view = target_view
		-- self.on_view_change(target_view)
	end
	self = {
		toggle = toggle,
		on_view_change = function(view)
			return
		end,
		hide_button = function(view,bool)
			view_map[view][2].Visible = not bool
		end,	
		get_current_view = function()
			return current_view
		end,
	}
	for _,view_frame in views do
		local view_name = view_frame.Name
		local button = textbutton(view_name,scrolling_frame)
		view_map[view_frame.Name] = {
			view_frame;
			button;
		}
		button.MouseButton1Click:Connect(function()
			toggle(view_name,true)
			self.on_view_change(view_name)
		end)
		view_frame.Visible = false
		view_frame.Parent = container
		if view_name == default_view then
			toggle(view_name,true)
		end
	end
	return container,scrolling_frame,self
end
