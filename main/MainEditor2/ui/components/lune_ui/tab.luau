--!strict
type void = nil
export type Tab = {
	on_tab_count: ((count: number) -> ())?,
	on_view_change: ((view: string) -> ())?,
	views: {
		[string]: {
			tab_view: GuiObject,
			tab_button: TextButton,
		},
	},
}
export type TabImpl = {
	toggle: (target_view: string, bool: boolean) -> (),
	hide_tab_bar: (bool: boolean) -> (),
	hide_tab_bar_button: (target_view: string, bool: boolean) -> (),
	add_views: (views: { GuiObject }) -> (),
	get_current_view: () -> string,
	get_tab_count: () -> number,
}
local textbutton = require("./textbutton")
local theme_manager = require("./theme_manager")
return function(
	views: { GuiObject },
	default_view: string,
	parent: Instance?,
	tab_bar_parent: Instance?
): (Frame, ScrollingFrame, TabImpl & Tab)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 1, 0)
	container.Transparency = 1
	container.Parent = parent
	local vert_list_layout = Instance.new("UIListLayout")
	vert_list_layout.Padding = UDim.new(0, 8)
	vert_list_layout.Parent = container
	vert_list_layout.VerticalFlex = Enum.UIFlexAlignment.Fill
	vert_list_layout.SortOrder = Enum.SortOrder.LayoutOrder
	local scrolling_frame = Instance.new("ScrollingFrame")
	scrolling_frame.Name = "Tab"
	scrolling_frame.Transparency = 1
	scrolling_frame.CanvasSize = UDim2.new()
	scrolling_frame.AutomaticCanvasSize = Enum.AutomaticSize.X
	scrolling_frame.Size = UDim2.new(1, 0, 0, 32)
	scrolling_frame.BorderSizePixel = 0
	scrolling_frame.ScrollBarThickness = 1
	scrolling_frame.Parent = tab_bar_parent or container
	local horiz_list_layout = Instance.new("UIListLayout")
	horiz_list_layout.FillDirection = Enum.FillDirection.Horizontal
	horiz_list_layout.Padding = UDim.new(0, 8)
	horiz_list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	horiz_list_layout.Parent = scrolling_frame
	local size_const = Instance.new("UISizeConstraint")
	size_const.MinSize = Vector2.new(0, 32)
	size_const.MaxSize = Vector2.new(math.huge, 32)
	size_const.Parent = scrolling_frame
	local current_view: string = nil
	local tab_count = #views
	-- local view_map = {}
	local tab = {} :: Tab & TabImpl
	tab.views = {}
	tab.toggle = function(target_view, bool)
		if current_view then
			local view = tab.views[current_view]
			view.tab_view.Visible = false
			theme_manager:force_highlight(view.tab_button, false)
		end
		local view = tab.views[target_view]
		view.tab_view.Visible = true
		theme_manager:force_highlight(view.tab_button, true)
		current_view = target_view
		if tab.on_view_change then
			tab.on_view_change(target_view)
		end
	end
	tab.hide_tab_bar = function(bool)
		scrolling_frame.Visible = not bool
	end
	tab.hide_tab_bar_button = function(target_view, bool)
		local view = tab.views[target_view]
		if (not bool) == view.tab_button.Visible then
			return
		end
		tab.views[target_view].tab_button.Visible = not bool
		if view.tab_button.Visible then
			tab_count += 1
		else
			tab_count -= 1
		end
		if tab.on_tab_count then
			tab.on_tab_count(tab.get_tab_count())
		end
	end
	tab.add_views = function(views)
		for _, view_frame in views do
			local view_name = view_frame.Name
			local existing_button = scrolling_frame:FindFirstChild(view_name)
			local existing_view = container:FindFirstChild(view_name)
			if existing_button then
				existing_button:Destroy()
			end
			if existing_view then
				existing_view:Destroy()
			end
			local button = textbutton(view_name, scrolling_frame)
			tab.views[view_name] = {
				tab_view = view_frame,
				tab_button = button,
			}
			button.MouseButton1Click:Connect(function()
				tab.toggle(view_name, true)
				-- self.on_view_change(view_name)
			end)
			view_frame.Visible = false
			view_frame.Parent = container
			if view_name == current_view then
				view_frame.Visible = true
			end
			if view_name == default_view then
				tab.toggle(view_name, true)
			end
			tab_count += 1
		end
	end
	tab.get_current_view = function()
		return current_view
	end
	tab.get_tab_count = function()
		return tab_count
	end
	tab.add_views(views)
	return container, scrolling_frame, tab
end
