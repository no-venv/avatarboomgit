local pinboard_shared = require("../../../shared/pinboard")
local singletons = require("../../../singletons")
local utils = require("../../../utils")
local event_bus = singletons.event_bus
local catalog = singletons.catalog_fetcher
local asset_button = require("../../components/AssetButton")
local asset_button_header = require("../../components/AssetButtonHeader")
local lune = require("../../components/lune_ui")
local scrolling_frame = lune.scrolling_frame
return function(parent, name: string, contents: pinboard_shared.Board)
	local similar_items_container
	local cursor = 1
	local end_generate = false
	local function generate()
		if end_generate then
			return false
		end
		local asset = contents[cursor]
		if not asset then
			end_generate = true
			return false
		end
		local assets = asset.ItemType == "Asset"
				and catalog:GetRecommendedAssets(asset.Id, Enum.AvatarAssetType:FromName(asset.AssetType))
			or catalog:GetRecommendedBundles(asset.Id)

		-- local assets = catalog:GetRecommendedAssets(asset.Id, Enum.AvatarAssetType:FromName(asset.AssetType))
		for _, asset in assets do
			asset_button_header(
				asset,
				{ ["Favourite"] = true, ["Remove"] = true },
				asset_button({
					parent = similar_items_container,
					-- asset_id = asset.Id,
					-- asset_type = asset.ItemType,
					-- price = 0,
					asset = asset,
					on_click = function()
						event_bus.avatar_item_selected.emit({ asset_info = asset })
					end,
				}),
				function()
					if pinboard_shared.check_pin_in_board(name, asset.Id) then
						pinboard_shared.remove_pin(name, { asset.Id })
						return false
					else
						pinboard_shared.insert_pin(name, { asset })
						return true
					end
				end
			)
		end
		cursor += 1
		return true
	end
	similar_items_container = scrolling_frame(parent, "Grid", nil, generate)
	return similar_items_container
end
