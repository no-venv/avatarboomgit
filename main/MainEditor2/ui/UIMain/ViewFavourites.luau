--!strict
local Editor = script:FindFirstAncestor("MainEditor2") 
local components = require(Editor.ui.components)
local EventFrames = components.event_frames
local asset_button = components.asset_button
local asset_button_header = components.asset_button_header
local lune = components.lune_ui
local empty_frame = lune.empty_frame
local scrolling_frame = lune.scrolling_frame
local styling = lune.styling
local singletons = require(Editor.singletons)
local shared = require(Editor.shared)

local utils = require(Editor.utils)
local event_bus = singletons.event_bus
local humanoid_editor = singletons.humanoid_description
local CatalogFetcher = singletons.catalog_fetcher

return function(parent : Instance?)
	local container = empty_frame(parent)
	local current_view_wearing : Frame? = nil;
	local is_enabled = false
	local function update()
		local view_wearing_instance = scrolling_frame(container,"Grid")
		styling.padding(view_wearing_instance)
			.PaddingTop = UDim.new(0,50)
		view_wearing_instance.Name = "ViewFavourites"

		if current_view_wearing then
			current_view_wearing:Destroy()
		end

		local wearing_ids = shared.favourites.favourites
		for _,asset in wearing_ids do
			local button = asset_button {
				price = asset.Price;
				asset_id = asset.Id;
				asset_type = asset.ItemType;
				parent = view_wearing_instance;
				on_click = function()
					event_bus.avatar_item_selected.emit({
						asset_info = asset
					})	
				end,
			}
			asset_button_header(asset,{["Favourite"]=true},button)
		end

		current_view_wearing = view_wearing_instance
		return
	end
	
	event_bus.catalog_show_overlay.connect(function(parm): nil 
		is_enabled = parm.overlay == "Favourites"
		container.Visible = is_enabled
		if is_enabled then
			update()
		else
			if current_view_wearing then
				current_view_wearing:Destroy()
				current_view_wearing = nil
			end
		end
		return
	end)
	container.Visible = false
	return container
end
