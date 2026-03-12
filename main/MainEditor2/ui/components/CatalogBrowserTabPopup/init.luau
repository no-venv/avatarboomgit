local lune = require("@self/../lune_ui")
local shared = require("../../shared")
local button_header = require("@self/../ButtonHeader")
type TabInfo = {
	index: number,
	tab_uuid: string,
	saved_filter: {},
}
type Arguments = {
	parent: Frame,
	selected_uuid: string,
	on_click: (tab: TabInfo) -> any,
	on_new: (tab_uuid: string) -> any,
	on_close: (tab: TabInfo) -> any,
}

return function(arg: Arguments)
	local container = lune.empty_frame()
	local prev_scrolling: ScrollingFrame?
	local window

	local function generate()
		if prev_scrolling then
			prev_scrolling:Destroy()
		end
		local scrolling_container = lune.scrolling_frame(container, "Grid", {
			CellSize = UDim2.new(0, 160, 0, 160),
		})
		for index, tab_data in shared.tabs.get_tabs() do
			if index == 0 then
				continue
			end
			local asset_button = lune.iconbutton({
				parent = scrolling_container,
				id = tab_data.asset_thumbs,
				on_click = function()
					window:Destroy()
					arg.on_click({
						index = index,
						tab_uuid = tab_data.tab_uuid,
						saved_filter = tab_data.filter,
					})
				end,
			})

			local label = lune.textlabel((tab_data.tab_name == "" and "New Tab") or tab_data.tab_name, asset_button,true)
			label.AnchorPoint = Vector2.new(0, 1)
			label.Position = UDim2.fromScale(0, 1)
			label.TextYAlignment = Enum.TextYAlignment.Bottom
			lune.theme_manager:force_highlight(asset_button, tab_data.tab_uuid == arg.selected_uuid)
			button_header({
				parent = asset_button,
				left_topbar = {},
				right_topbar = {
					{
						id = 96060799177234,
						on_click = function()
							shared.tabs.close_tab(tab_data.tab_uuid)
							arg.on_close(tab_data)
							generate()
						end,
					},
				},
			})
		end
		prev_scrolling = scrolling_container
	end

	generate()
	window = lune.window.base({
		title = "Tabs",
		size = Vector2.new(0.8, 0.8),
		view = container,
		important = true,
		custom_embed = arg.parent,
		left_topbar = {
			lune.iconbutton({
				id = 104744952813054,
				theme_enabled = true,
				on_click = function()
					window:Destroy()
					arg.on_new(shared.tabs.new_tab())
					generate()
				end,
			}),
		},
	})
	return window
end
