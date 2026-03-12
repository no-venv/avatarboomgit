local HttpService = game:GetService("HttpService")
local event_bus = require("../singletons/event_bus")
local plugin_fs = require("../singletons/PluginFS")
local plugin_save_name = "BoomSettings"
export type Settings = {
	auto_try_on_click: boolean,
}

local settings_data: Settings = {
	auto_try_on_click = false,
}
local saved_settings = plugin_fs.get(plugin_save_name)
if saved_settings then
	settings_data = HttpService:JSONDecode(saved_settings)
end

return {
	data = settings_data,
	set = function<T>(key: keyof<Settings>, value: any)
		settings_data[key] = value
		plugin_fs.save(plugin_save_name, HttpService:JSONEncode(saved_settings))
		event_bus.plugin_settings_updated.emit({ setting = key, value = value })
		return
	end,
	get = function<T>(key: keyof<Settings> & T): index<Settings, T>
		return settings_data[key]
	end,
}
