--!strict
local components = require("../components")
local singletons = require("../../singletons")
local catalog_filters = require("@self/catalog_filters")
local ui_lib = components.lune_ui
local event_bus = singletons.event_bus
local scrolling_frame = ui_lib.scrolling_frame
local textbox = ui_lib.textbox
local textbutton = ui_lib.textbutton
local collasped_view = ui_lib.collasped_view
local empty_frame = ui_lib.empty_frame
local option_buttons = ui_lib.option_buttons
local textlabel = ui_lib.textlabel

local function line(parent: Instance?)
	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, 0, 0, 1)
	line.BorderSizePixel = 0
	line.Transparency = 0.67
	line.Parent = parent
	return line
end
local function filter_topbar(children: { GuiObject }, parent: Instance?)
	local container = ui_lib.empty_frame()
	container.Size = UDim2.new(1, 0, 0, 32)
	local horz_layout = Instance.new("UIListLayout")
	horz_layout.SortOrder = Enum.SortOrder.LayoutOrder
	horz_layout.FillDirection = Enum.FillDirection.Horizontal
	horz_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	horz_layout.HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween
	horz_layout.VerticalAlignment = Enum.VerticalAlignment.Center
	horz_layout.Padding = UDim.new(0, 8)
	horz_layout.Parent = container
	for _, child in children do
		child.Parent = container
	end
	return container
end

local function vbox(parent: Instance?)
	local vbox = Instance.new("UIListLayout")
	vbox.SortOrder = Enum.SortOrder.LayoutOrder
	vbox.HorizontalFlex = Enum.UIFlexAlignment.Fill
	vbox.Padding = UDim.new(0, 8)
	vbox.Parent = parent
	return vbox
end

local function filter_section(title: string, filter_section_children: { TextButton }, parent: Instance?)
	local container = ui_lib.empty_frame()
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.Size = UDim2.new(1, 0, 0, 0)
	vbox(container)

	local topbar = ui_lib.empty_frame(container)
	topbar.Size = UDim2.new(1, 0, 0, 32)
	local hbox = Instance.new("UIListLayout")
	hbox.SortOrder = Enum.SortOrder.LayoutOrder
	hbox.FillDirection = Enum.FillDirection.Horizontal
	hbox.HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween
	hbox.Parent = topbar
	local text_label = textlabel(title, topbar)

	--textbutton("Select All",topbar,function()

	--end)

	local children_container = ui_lib.empty_frame(container)
	children_container.AutomaticSize = Enum.AutomaticSize.Y
	children_container.Size = UDim2.new(1, 0, 0, 0)
	local hbox = Instance.new("UIListLayout")
	hbox.Padding = UDim.new(0, 8)
	hbox.SortOrder = Enum.SortOrder.LayoutOrder
	hbox.FillDirection = Enum.FillDirection.Horizontal
	hbox.Wraps = true
	hbox.Parent = children_container

	for _, child in filter_section_children do
		child.Parent = children_container
	end
	-- create a seperate line
	line(container)
	container.Parent = parent
	return container
end

return function(parent: Instance?)
	local container = scrolling_frame(parent)
	container.Name = "Set Filter"
	local advanced_filter = empty_frame()
	local offsale_state = false
	advanced_filter.Size = UDim2.new(1, 0, 0, 0)
	advanced_filter.AutomaticSize = Enum.AutomaticSize.Y
	vbox(advanced_filter)
	---
	local filter_search_bar = textbox("Filter by Creator...", advanced_filter)
	filter_search_bar.ClearTextOnFocus = false
	filter_search_bar.FocusLost:Connect(function(enterPressed: boolean, inputThatCausedFocusLoss: InputObject)
		if not enterPressed then
			return
		end
		local creator_name = filter_search_bar.Text
		event_bus.catalog_set_search_filter.emit({
			CreatorName = creator_name,
		})
	end)
	line(advanced_filter)
	textlabel("Sort by", advanced_filter)
	local sorts_options = {
		"Relevance",
		"Most Favorited",
		"Bestselling",
		"Recently Published",
	}
	local _, sort_by_option_buttons = option_buttons(advanced_filter, sorts_options, function(value: string): nil
		local map = {
			["Relevance"] = Enum.CatalogSortType.Relevance,
			["Most Favorited"] = Enum.CatalogSortType.MostFavorited,
			["Bestselling"] = Enum.CatalogSortType.Bestselling,
			["Recently Published"] = Enum.CatalogSortType.RecentlyCreated,
		}
		event_bus.catalog_set_search_filter.emit({
			SortType = map[value],
		})
		return
	end)
	line(advanced_filter)
	textlabel("Unavailable Items", advanced_filter)
	local _, unavailable_option_buttons = option_buttons(
		advanced_filter,
		{ "Show", "Hide" },
		function(value: string): nil
			offsale_state = value == "Show"
			event_bus.catalog_set_search_filter.emit({
				IncludeOffSale = offsale_state,
			})
			return
		end
	)
	line(advanced_filter)
	local view_everything = textbutton("View Everything", advanced_filter, function()
		event_bus.catalog_set_search_filter.emit({
			AssetTypes = Enum.AvatarAssetType:GetEnumItems(),
			BundleTypes = Enum.BundleType:GetEnumItems(),
		})
	end)
	textbutton("Reset Filter", advanced_filter, function()
		unavailable_option_buttons.set("")
		sort_by_option_buttons.set("Relevance")
		unavailable_option_buttons.set("Hide")
		event_bus.catalog_set_search_filter.emit({
			AssetTypes = Enum.AvatarAssetType:GetEnumItems(),
			BundleTypes = Enum.BundleType:GetEnumItems(),
			IncludeOffSale = false,
			SortType = Enum.CatalogSortType.Relevance,
			CreatorName = "",
		})
	end)
	view_everything.Size = UDim2.new(1, 0, 0, 32)
	line(advanced_filter)
	collasped_view("More Filter Options", advanced_filter, container)
	--
	for _, catagory in catalog_filters do
		local catagory_name = catagory.catagory
		local buttons = {}
		for _, filter_options in catagory.filters do
			local filter_name = filter_options.filter_name
			local new_button = textbutton(filter_name, nil, function()
				event_bus.catalog_set_search_filter.emit({
					AssetTypes = { filter_options.avatar_asset_type },
					BundleTypes = { filter_options.bundle_type },
					IncludeOffSale = filter_options.offsale or offsale_state,
				})
				event_bus.drawer_open.emit({
					bool = false,
				})
			end)
			table.insert(buttons, new_button)
			event_bus.catalog_set_search_filter.connect(function(parm): nil
				local asset_type_len = parm.AssetTypes and #parm.AssetTypes or nil
				local bundle_type_len = parm.BundleTypes and #parm.BundleTypes or nil
				if not asset_type_len or not bundle_type_len then
					return
				end
				local asset_type = parm.AssetTypes and parm.AssetTypes[1]
				local bundle_type = parm.BundleTypes and parm.BundleTypes[1]
				local should_hover = (filter_options.avatar_asset_type == asset_type)
					and (filter_options.bundle_type == bundle_type)
				ui_lib.theme_manager:force_highlight(new_button, should_hover)
				return
			end)
		end
		filter_section(catagory_name, buttons, container)
	end

	event_bus.catalog_set_search_filter.connect(function(parm): nil
		if parm.CreatorName then
			filter_search_bar.Text = parm.CreatorName
		end
		if parm.SortType or parm.IncludeOffSale or parm.CreatorName then
			advanced_filter.Visible = true
		end
		local asset_type_len = parm.AssetTypes and #parm.AssetTypes or nil
		local bundle_type_len = parm.BundleTypes and #parm.BundleTypes or nil
		if not asset_type_len or not bundle_type_len then
			return
		end
		ui_lib.theme_manager:force_highlight(view_everything, asset_type_len > 1 or bundle_type_len > 1)
		return
	end)

	container.Parent = parent
	return container
end
