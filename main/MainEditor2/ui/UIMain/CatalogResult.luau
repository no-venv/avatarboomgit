--!strict
-- The purpose is to display the result of a search query, and to setup an endless scrolling page
local Editor = script:FindFirstAncestor("MainEditor2") 
local TweenService = game:GetService("TweenService")
local components = require(Editor.ui.components)
local lune = components.lune_ui
local empty_frame = lune.empty_frame
local scrolling_frame = lune.scrolling_frame
local styling = lune.styling
local EventFrames = components.event_frames
local asset_button = components.asset_button
local asset_button_header = components.asset_button_header
local singletons = require(Editor.singletons)
local utils = require(Editor.utils)
local shared = require(Editor.shared)
local event_bus = singletons.event_bus
local CatalogFetcher = singletons.catalog_fetcher

local function search(query : string, parent : Instance?)
	event_bus.catalog_show_overlay.emit({overlay = "None"})
	local asset_id = tonumber(query)
	local roblox_uri = query:match("catalog/(%d+)/")
	if roblox_uri then
		asset_id = tonumber(roblox_uri)
	end
	if asset_id then
		local asset_info = CatalogFetcher:GetBatchItemDetails({asset_id})
		if #asset_info ~= 0 then
			event_bus.avatar_item_selected.emit({asset_info = asset_info[1]})
			return
		end
		-- bundle?
		local asset_info = CatalogFetcher:GetBatchItemDetails({asset_id},Enum.AvatarItemType.Bundle)
		if #asset_info ~= 0 then
			event_bus.avatar_item_selected.emit({asset_info = asset_info[1]})
			return
		end
		return
	end
	local scrolling_container = scrolling_frame(parent,"Grid")
	styling.padding(scrolling_container)
		.PaddingTop = UDim.new(0,50)
	-- split off into another thread
	task.spawn(function()
		local Spinner = EventFrames.spinner(scrolling_container)
		local result = CatalogFetcher:Search(query)
		Spinner.Parent = nil
		if not result then
			EventFrames.error(scrolling_container,function() 
				scrolling_container:Destroy()
				search(query,parent)
				return
			end)
			return
		end
		local RefreshAt = math.huge
		local RefreshMutex = false
		local function CompileResult()
			RefreshMutex = true
			local TargetSize = (scrolling_container.AbsoluteWindowSize.Y) + (scrolling_container.AbsoluteCanvasSize.Y) 
			while true do
				Spinner.Parent = scrolling_container
				local AssetArray = result:Next()
				if not AssetArray then
					-- we have errored
					Spinner.Parent = nil
					EventFrames.error(scrolling_container,function() 
						CompileResult()	
					end)
					break
				end
				if #AssetArray == 0 then
					-- that means we are done
					Spinner.Parent = nil
					break
				end
				Spinner.Parent = nil
				for _,Asset in AssetArray do
					local button = asset_button {
						price = Asset.Price;
						asset_id = Asset.Id;
						asset_type = Asset.ItemType;
						parent = scrolling_container;
						on_click = function()
							event_bus.avatar_item_selected.emit({
								asset_info = Asset
							})
						end,
					}
					asset_button_header(Asset,{["Favourite"] = true;["Remove"]=true},button)
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
		local canvas_position_change = scrolling_container:GetPropertyChangedSignal("CanvasPosition")
		canvas_position_change:Connect(utils.MutexFunction(function() 
			local Y = (scrolling_container.CanvasPosition.Y + scrolling_container.AbsoluteWindowSize.Y) / scrolling_container.AbsoluteCanvasSize.Y
			if Y >= 0.90 and not RefreshMutex then
				CompileResult()
			end
		end))	
	end)
	return scrolling_container
end

return function(parent : Instance?)
	local container = empty_frame(parent)
	local current_scroll_page : ScrollingFrame? = nil

	event_bus.catalog_search.connect(function(parm)
		if current_scroll_page then
			current_scroll_page:Destroy()
		end
		current_scroll_page = search(parm.query,container)
	end)
	
	event_bus.catalog_set_search_filter.connect(function(parm): nil 
		
		for filter_option,value in parm do
			CatalogFetcher.Filter[filter_option] = value
		end
		if current_scroll_page then
			current_scroll_page:Destroy()
		end
		current_scroll_page = search(CatalogFetcher.Filter.SearchKeyword,container)
		return
	end)
	
	event_bus.catalog_show_overlay.connect(function(parm): nil 
		container.Visible = parm.overlay == "None"
		return
	end)
	return container
end
