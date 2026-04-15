--!strict
-- The purpose is to display the result of a search query, and to setup an endless scrolling page
local components = require("../components")
local singletons = require("../../singletons")
local utils = require("../../utils")
local shared = require("../../shared")
local lune = components.lune_ui
local empty_frame = lune.empty_frame
local scrolling_frame = lune.scrolling_frame
local styling = lune.styling
local EventFrames = components.event_frames
local asset_button = components.asset_button
local asset_button_header = components.asset_button_header
local event_bus = singletons.event_bus
local CatalogFetcher = singletons.catalog_fetcher
local function search(tab_uuid: string, query: string, parent: Instance?, on_failure: () -> nil): ScrollingFrame
	local scrolling_container = scrolling_frame(parent, "Grid")
	styling.padding(scrolling_container).PaddingTop = UDim.new(0, 50)
	event_bus.catalog_show_overlay.emit({ overlay = "None" })

	-- split off into another thread to avoid blocking
	task.spawn(function()
		local Spinner = EventFrames.spinner(scrolling_container)
		local result = CatalogFetcher:Search(query)
		Spinner.Parent = nil
		if not result then
			EventFrames.error(scrolling_container, on_failure)
			return
		end
		-- update tabs
		local RefreshMutex = false
		local asset_array = {}
		local function CompileResult()
			RefreshMutex = true
			local TargetSize = scrolling_container.AbsoluteWindowSize.Y + scrolling_container.AbsoluteCanvasSize.Y
			while true do
				Spinner.Parent = scrolling_container
				local AssetArray = result:Next()
				asset_array = AssetArray

				if not AssetArray then
					-- we have errored
					Spinner.Parent = nil
					EventFrames.error(scrolling_container, CompileResult)
					break
				end
				if #AssetArray == 0 then
					-- that means we are done
					Spinner.Parent = nil
					break
				end
				Spinner.Parent = nil
				for _, Asset in AssetArray do
					local button = asset_button({
						-- price = Asset.Price,
						-- asset_id = Asset.Id,
						-- asset_type = Asset.ItemType,
						asset = Asset,
						parent = scrolling_container,
						-- on_click = function()
						-- 	event_bus.avatar_item_selected.emit({
						-- 		asset_info = Asset,
						-- 	})
						-- 	return
						-- end,
					})
					asset_button_header(Asset, { ["Favourite"] = true, ["Remove"] = true }, button)
				end
				if scrolling_container.AbsoluteCanvasSize.Y >= TargetSize then
					-- we're done
					RefreshMutex = false
					Spinner.Parent = nil
					break
				end
			end
		end

		CompileResult()
		shared.tabs.update_tab(
			tab_uuid,
			`{CatalogFetcher.Filter.SearchKeyword}`,
			CatalogFetcher:FilterAsTable(),
			utils.generate_asset_thumb({
				asset_array[1],
				asset_array[2],
				asset_array[3],
			})
		)

		local canvas_position_change = scrolling_container:GetPropertyChangedSignal("CanvasPosition")
		canvas_position_change:Connect(utils.MutexFunction(function()
			local Y = (scrolling_container.CanvasPosition.Y + scrolling_container.AbsoluteWindowSize.Y)
				/ scrolling_container.AbsoluteCanvasSize.Y
			if Y >= 0.90 and not RefreshMutex then
				CompileResult()
			end
		end))
	end)
	return scrolling_container
end

return function(parent: Instance?)
	-- currently default to the reserved tab
	local container = empty_frame(parent)
	-- local opened_uuid = ""
	local current_tab = nil
	local opened_tabs: {
		[string]: {
			ignore_search_filter: boolean,
			uuid: string,
			container: Frame,
			scrolling_container: ScrollingFrame?,
		},
	} =
		{}

	local function remove_tab(uuid: string)
		if current_tab then
			if current_tab.uuid == uuid then
				current_tab = nil
			end
		end
		opened_tabs[uuid].container:Destroy()
		opened_tabs[uuid] = nil
	end
	local function create_tab(uuid: string)
		-- creates new tab, and sets it as the default tab
		if current_tab then
			current_tab.container.Visible = false
		end
		current_tab = {
			ignore_search_filter = false,
			uuid = uuid,
			container = empty_frame(container),
			scrolling_container = nil,
		}
		opened_tabs[uuid] = current_tab
	end

	local function switch_tab(uuid: string)
		if current_tab then
			current_tab.container.Visible = false
		end
		local tab_switched = opened_tabs[uuid]
		if opened_tabs[uuid] then
			opened_tabs[uuid].container.Visible = true
			current_tab = opened_tabs[uuid]
		end
		return tab_switched
	end

	local function search_wrapper(query: string)
		local asset_id = tonumber(query)
		local roblox_uri = query:match("catalog/(%d+)/")
		if roblox_uri then
			asset_id = tonumber(roblox_uri)
		end
		if asset_id then
			local asset_info = CatalogFetcher:GetBatchItemDetails({ asset_id })
			if #asset_info ~= 0 then
				CatalogFetcher.Filter.SearchKeyword = ""
				event_bus.avatar_item_selected.emit({ asset_info = asset_info[1] })
				return
			end
			-- bundle?
			local asset_info = CatalogFetcher:GetBatchItemDetails({ asset_id }, Enum.AvatarItemType.Bundle)
			if #asset_info ~= 0 then
				CatalogFetcher.Filter.SearchKeyword = ""
				event_bus.avatar_item_selected.emit({ asset_info = asset_info[1] })
				return
			end
			-- probably a normal search,
		end
		-- create new tab if current_tab is not here
		if not current_tab then
			create_tab(shared.tabs.new_tab())
		end
		if current_tab.scrolling_container then
			current_tab.scrolling_container:Destroy()
		end
		shared.tabs.update_tab(current_tab.uuid, query, CatalogFetcher:FilterAsTable(), {})
		current_tab.scrolling_container = search(current_tab.uuid, query, current_tab.container, function()
			search_wrapper(query)
		end)
		return
	end

	event_bus.catalog_search.connect(function(parm)
		search_wrapper(parm.query)
	end)

	event_bus.catalog_set_search_filter.connect(function(parm)
		for filter_option, value in parm :: { any } do
			CatalogFetcher.Filter[filter_option] = value
		end
		if current_tab then
			if current_tab.ignore_search_filter then
				current_tab.ignore_search_filter = false
				return
			end
		end
		search_wrapper(CatalogFetcher.Filter.SearchKeyword)
		return
	end)

	event_bus.catalog_show_overlay.connect(function(parm)
		container.Visible = parm.overlay == "None"
	end)

	event_bus.topbar_register_custom_button.emit({
		allowed_overlay = "None",
		button_id = "catalog_tab",
		image = 108641844075033,
		tooltip = "Tabs",
		on_click = function()
			components.catalog_browser_tab_popup({
				parent = container,
				selected_uuid = (current_tab and current_tab.uuid) or "",
				tab_name = ``,
				preview_asset_info = {},
				on_click = function(tab)
					if not switch_tab(tab.tab_uuid) then
						-- new tab and set filters
						create_tab(tab.tab_uuid)
						event_bus.catalog_set_search_filter.emit(tab.saved_filter)
					else
						opened_tabs[tab.tab_uuid].ignore_search_filter = true
						event_bus.catalog_set_search_filter.emit(tab.saved_filter)
					end
					return
				end,
				on_new = function(index)
					create_tab(index)
					event_bus.catalog_set_search_filter.emit({
						AssetTypes = Enum.AvatarAssetType:GetEnumItems(),
						BundleTypes = Enum.BundleType:GetEnumItems(),
						IncludeOffSale = false,
						SortType = Enum.CatalogSortType.Relevance,
						CreatorName = "",
						SearchKeyword = "",
					})
					return
				end,
				on_close = function(tab)
					local opened_tabs = shared.tabs.get_tabs()
					local new_tab = shared.tabs.get_tabs()[tab.index]
					remove_tab(tab.tab_uuid)
					if new_tab then
						switch_tab(new_tab.tab_uuid)
					else
						local tab = opened_tabs[#opened_tabs]
						if not tab then
							return
						end
						switch_tab(tab.tab_uuid)
					end
					return
				end,
			})
			return
		end,
	})
	event_bus.topbar_register_custom_button.emit({
		allowed_overlay = "None",
		button_id = "catalog_auto_try",
		image = 88915445317633,
		tooltip = "Auto try on",
		has_state = true,
		on_click = function(state)
			shared.settings.auto_try_on_click.set(state, false)
			return
		end,
	})
	event_bus.topbar_visibility_custom_button.emit({
		button_id = { "catalog_tab", "catalog_auto_try" },
		show = true,
	})
	event_bus.topbar_set_state.emit({ button_id = "catalog_auto_try", state = shared.settings.auto_try_on_click.value })
	return container
end
