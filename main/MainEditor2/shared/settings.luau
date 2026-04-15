--!strict
local HttpService = game:GetService("HttpService")
local plugin_fs = require("../singletons/PluginFS")
local typed_events = require("../utils/TypedBindables")
local plugin_save_name = "BoomSettingsR5"
local settings_data = {} :: Settings

export type SettingProperty<Default, Value> = {
	description: string,
	value_options: Value,
	default_value: Default,
	value: Value,
	hidden: boolean?,
	ignore_save: boolean?,
	changed: typed_events.Event<{ value: Value }>,
	set: (value: Value) -> (),
}

export type SettingsGeneric = { [string]: SettingProperty<any, any> }
export type Settings = {
	auto_try_on_click: SettingProperty<false, boolean>,
	send_crash_logs: SettingProperty<true, boolean>,
	test_property: SettingProperty<"Butter", "Pizza" | "Bread" | "Butter">,
	show_crash_log_consent: SettingProperty<false, boolean>,
}

local function SettingProperty(arg: {
	description: string,
	default_value: any,
	hidden: boolean?,
	ignore_save: boolean?,
	value_options: any?,
}): any
	local prop: SettingProperty<any, any>
	prop = {
		value_options = arg.value_options,
		description = arg.description,
		default_value = arg.default_value,
		value = arg.default_value,
		ignore_save = arg.ignore_save,
		hidden = arg.hidden or false,
		changed = typed_events(),
		set = function(value)
			prop.value = value
			if not prop.ignore_save then
				plugin_fs.save(plugin_save_name, HttpService:JSONEncode(settings_data))
			end
			prop.changed.emit({ value = value })
		end,
	}
	return prop
end

local default_setting: Settings = {
	auto_try_on_click = SettingProperty({
		description = "",
		default_value = false,
		hidden = true,
		ignore_save = true,
	}),
	send_crash_logs = SettingProperty({
		description = "Sends anonymized crash logs when the plugin errors",
		default_value = true,
	}),
	show_crash_log_consent = SettingProperty({
		description = "",
		default_value = true,
		hidden = true,
	}),
	test_property = SettingProperty({
		description = "Second Test Internal Property",
		default_value = "Butter",
		hidden = true,
		ignore_save = true,
		value_options = { "Pizza", "Bread", "Butter" },
	}),
}

local function init()
	for name, setting in default_setting :: SettingsGeneric do
		if not settings_data[name] then
			continue
		end
		if setting.ignore_save then
			continue
		end
		setting.value = settings_data[name].value
	end
	settings_data = default_setting
end
local saved = plugin_fs.get(plugin_save_name, true)
settings_data = saved or default_setting
if saved then
	init()
end
return settings_data :: Settings
