--!strict
local HttpService = game:GetService("HttpService")
local plugin_fs = require("../singletons/PluginFS")
local plugin_save_name = "BoomComposer"
export type ComposerSavedAnimation = {
	name: string,
	last_opened_unix_time: number,
	data: {},
}
export type Composer = { ComposerSavedAnimation }

local composer_data: Composer = {}
local saved_composer_data = plugin_fs.get(plugin_save_name)
if saved_composer_data then
	composer_data = HttpService:JSONDecode(saved_composer_data) :: Composer
end
return {
	get = function(index: number)
		return composer_data[index]
	end,
	get_all_animations = function()
		return composer_data
	end,
	delete = function(index: number)
		table.remove(composer_data, index)
	end,
	save = function(name: string, animation: {}, index: number?)
		local saved = {
			name = name,
			last_opened_unix_time = os.time(),
			data = animation,
		}
		if index then
			composer_data[index] = saved
		else
			table.insert(composer_data, 1, saved)
		end
	end,
}
