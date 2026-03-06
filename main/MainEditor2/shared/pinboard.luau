local HttpService = game:GetService("HttpService")
local plugin_fs = require("../singletons/PluginFS")
local catalog_fetcher = require("../singletons/CatalogFetcher")
local plugin_save_name = "BoomPinboard"
export type Board = { catalog_fetcher.AssetType }
export type PinboardData = {
	[string]: Board,
}
export type Pinboard = {
	lookup: {
		[number]: { [string]: boolean },
	},
	data: PinboardData,
}

local pinboard_data: Pinboard = {
	data = {},
	lookup = {},
}
local saved_pinboard = plugin_fs.get(plugin_save_name)
if saved_pinboard then
	pinboard_data = HttpService:JSONDecode(saved_pinboard)
end
local self
self = {
	pinboard_data = pinboard_data,
	new_pinboard = function(name: string)
		pinboard_data.data[name] = {}
		plugin_fs.save(plugin_save_name, HttpService:JSONEncode(pinboard_data))
	end,

	delete_pinboard = function(name: string)
		for _, value in pinboard_data.data[name] do
			pinboard_data.lookup[value.Id][name] = nil
		end
		pinboard_data.data[name] = nil
		plugin_fs.save(plugin_save_name, HttpService:JSONEncode(pinboard_data))
	end,

	pinboard_exists = function(name: string)
		return pinboard_data.data[name]
	end,
	lookup_id = function(id: number)
		return pinboard_data.lookup[id]
	end,

	rename_pinboard = function(old: string, new: string)
		local old_pinboard = pinboard_data.data[old]
		self.delete_pinboard(old)
		pinboard_data.data[new] = old_pinboard
		plugin_fs.save(plugin_save_name, HttpService:JSONEncode(pinboard_data))
	end,

	share_pinboard = function(name: string) end,

	insert_pin = function(name: string, asset_type: catalog_fetcher.AssetType)
		local id = asset_type.Id
		if not pinboard_data.data[name] then
			pinboard_data.data[name] = {}
		end
		if not pinboard_data.lookup[id] then
			pinboard_data.lookup[id] = {}
		elseif pinboard_data.lookup[id][name] then
			return
		end
		pinboard_data.lookup[id][name] = true
		table.insert(pinboard_data.data[name], asset_type)
		plugin_fs.save(plugin_save_name, HttpService:JSONEncode(pinboard_data))
	end,

	remove_pin = function(name: string, ids: { number })
		local board = pinboard_data.data[name]
		for index, value in board do
			if table.find(ids, value.Id) then
				pinboard_data.lookup[value.Id][name] = nil
				board[index] = nil
			end
		end
		local rebuilt = {}
		for _, value in board do
			table.insert(rebuilt, value)
		end
		pinboard_data.data[name] = rebuilt
		plugin_fs.save(plugin_save_name, HttpService:JSONEncode(pinboard_data))
	end,
}

return self
