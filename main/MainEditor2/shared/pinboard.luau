--!strict
local HttpService = game:GetService("HttpService")
local plugin_fs = require("../singletons/PluginFS")
local catalog_fetcher = require("../singletons/CatalogFetcher")
local event_bus = require("../singletons/event_bus")
local plugin_save_name = "BoomPinboard"
export type Board = { catalog_fetcher.AssetType }
export type PinboardData = {
	[string]: Board,
}
export type Pinboard = {
	lookup: {
		[number]: {
			stored_boards_count: number,
			stored_boards: {},
		},
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

local pinboard_interface = {
	pinboard_data = pinboard_data,
}

function pinboard_interface.new_pinboard(name: string)
	if pinboard_data.data[name] then
		return
	end
	pinboard_data.data[name] = {}
	plugin_fs.save(plugin_save_name, HttpService:JSONEncode(pinboard_data))
end

-- function pinboard_interface.add_pin_to_lookup(board_name: string, pin_id: number)
-- 	local lookup = pinboard_data.lookup
-- 	if not lookup[pin_id] then
-- 		lookup[pin_id] = {
-- 			stored_boards_count = 1,
-- 			stored_boards = { [board_name] = true },
-- 		}
-- 		return
-- 	end
-- 	lookup[pin_id].stored_boards_count += 1
-- 	lookup[pin_id].stored_boards[board_name] = true
-- end

-- function pinboard_interface.remove_pin_from_lookup(board_name: string, pin_id: number)
-- 	local lookup = pinboard_data.lookup
-- 	print(lookup)
-- 	lookup[pin_id].stored_boards_count -= 1
-- 	if lookup[pin_id].stored_boards_count == 0 then
-- 		lookup[pin_id] = nil
-- 	else
-- 		lookup[pin_id].stored_boards[board_name] = nil
-- 	end
-- end

function pinboard_interface.delete_pinboard(name: string)
	local data = pinboard_data.data
	-- for _, value in data[name] do
	-- 	pinboard_interface.remove_pin_from_lookup(name, value.Id)
	-- end
	data[name] = nil
	plugin_fs.save(plugin_save_name, HttpService:JSONEncode(pinboard_data))
	event_bus.save_pinboard_success.emit({})
end

function pinboard_interface.pinboard_exists(name: string)
	return pinboard_data.data[name]
end

function pinboard_interface.check_pin_in_board(name: string, id: number)
	local data = pinboard_data.data
	local board = data[name]
	if not board then
		return false
	end
	for _, asset in board do
		if asset.Id == id then
			return true
		end
	end
	return false
end

function pinboard_interface.rename_pinboard(old: string, new: string)
	local old_pinboard = pinboard_data.data[old]
	pinboard_interface.delete_pinboard(old)
	-- for _, value in old_pinboard do
	-- 	pinboard_interface.add_pin_to_lookup(new, value.Id)
	-- end
	pinboard_data.data[new] = old_pinboard
	plugin_fs.save(plugin_save_name, HttpService:JSONEncode(pinboard_data))
	event_bus.save_pinboard_success.emit({})
end

function pinboard_interface.share_pinboard(name: string) end

function pinboard_interface.insert_pin(name: string, asset_type: { catalog_fetcher.AssetType })
	local data = pinboard_data.data
	if not data[name] then
		data[name] = {}
	end
	for _, asset in asset_type do
		if pinboard_interface.check_pin_in_board(name, asset.Id) then
			continue
		end
		-- pinboard_interface.add_pin_to_lookup(name, asset.Id)
		table.insert(data[name], asset)
	end
	plugin_fs.save(plugin_save_name, HttpService:JSONEncode(pinboard_data))
	event_bus.save_pinboard_success.emit({})
end

function pinboard_interface.remove_pin(name: string, ids: { number })
	local data = pinboard_data.data
	local board = data[name]
	local rebuilt = {}
	for index, value in board do
		if table.find(ids, value.Id) then
			-- pinboard_interface.remove_pin_from_lookup(name, value.Id)
			continue
		end
		table.insert(rebuilt, value)
	end
	pinboard_data.data[name] = rebuilt
	plugin_fs.save(plugin_save_name, HttpService:JSONEncode(pinboard_data))
	event_bus.save_pinboard_success.emit({})
end

return pinboard_interface
