local HttpService = game:GetService("HttpService")
local plugin_fs = require("../singletons/PluginFS")
local catalog_fetcher = require("../singletons/CatalogFetcher")
local plugin_save_name = "BoomFavourties"
type Favourites = {
	[number] : catalog_fetcher.AssetType;
}

local favourites_data : Favourites = {}
local saved_favourites = plugin_fs.get(plugin_save_name)
if saved_favourites then
	local deocded_favourties = HttpService:JSONDecode(saved_favourites)
	for favourtie_id : string,favourites: catalog_fetcher.AssetType in deocded_favourties do
		favourites_data[tonumber(favourtie_id)::number] = favourites
	end
end
return {
	favourites = favourites_data;
	set_favourite = function(id : number,asset_type : catalog_fetcher.AssetType)
		favourites_data[id] = asset_type
		plugin_fs.save(plugin_save_name,HttpService:JSONEncode(favourites_data))
	end,
	remove_favourite = function(id : number)
		favourites_data[id] = nil
		plugin_fs.save(plugin_save_name,HttpService:JSONEncode(favourites_data))
	end,
}
