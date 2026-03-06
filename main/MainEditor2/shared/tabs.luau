local HttpService = game:GetService("HttpService")
local plugin_fs = require("../singletons/PluginFS")
local plugin_save_name = "BoomTabs"

export type Tabs = {
	opened_tabs: {
		{
			asset_thumbs: {
				{
					thumb: string,
				}
			},
			tab_name: string,
			tab_uuid: string,
			filter: {},
		}
	},
}

local tab_data: Tabs = {
	init_base_tab = false,
	opened_tabs = {},
}
local saved_tabs = plugin_fs.get(plugin_save_name)
if saved_tabs then
	tab_data = HttpService:JSONDecode(saved_tabs)
end

local self = {
	new_tab = function()
		local uuid = HttpService:GenerateGUID(false)
		table.insert(tab_data.opened_tabs, {
			tab_name = "New Tab",
			tab_uuid = uuid,
			filter = {},
			asset_thumbs = {},
		})
		plugin_fs.save(plugin_save_name, HttpService:JSONEncode(tab_data))
		return uuid
	end,
	update_tab = function(uuid: string, name: string, filter: {}, asset_thumbs: {})
		for _, tab in tab_data.opened_tabs do
			if tab.tab_uuid == uuid then
				tab.tab_name = name
				tab.filter = filter
				tab.asset_thumbs = asset_thumbs
				break
			end
		end
		plugin_fs.save(plugin_save_name, HttpService:JSONEncode(tab_data))
	end,
	close_tab = function(uuid: string)
		local removed_index = 0
		for index, tab in tab_data.opened_tabs do
			if tab.tab_uuid == uuid then
				table.remove(tab_data.opened_tabs, index)
				removed_index = index
				break
			end
		end
		plugin_fs.save(plugin_save_name, HttpService:JSONEncode(tab_data))
		return removed_index
	end,
	get_tab = function()
		return tab_data
	end,
	get_tabs = function()
		return tab_data.opened_tabs
	end,
}

return self
