--!strict
local HttpService = game:GetService("HttpService")
local plugin_fs = require("../singletons/PluginFS")
local typed_events = require("../utils/TypedBindables")
local plugin_save_name = "BoomSettingsR2"
local settings_data = {} :: Settings

export type SettingProperty<Default, Value> = {
	description: string,
	value_options: Value,
	default_value: Default,
	value: Value,
	hidden: boolean?,
	saveable: boolean?,
	changed: typed_events.Event<{ value: Value }>,
	set: (value: Value, save: boolean?) -> (),
}

export type SettingsGeneric = { [string]: SettingProperty<any, any> }
export type Settings = {
	auto_try_on_click: SettingProperty<false, boolean>,
	send_crash_logs: SettingProperty<true, boolean>,
	ui_scaling: SettingProperty<"1.0", "1.0" | "0.75" | "0.50" | "0.25">,

	test_property: SettingProperty<"Option1", "Option1" | "Option 2">,
	show_crash_log_consent: SettingProperty<false, boolean>,
}

local function init_prop(prop: any)
	prop.changed = typed_events()
	prop.set = function(value, save)
		prop.value = value
		if save and prop.saveable then
			plugin_fs.save(plugin_save_name, HttpService:JSONEncode(settings_data))
		end
		prop.changed.emit({ value = value })
	end
end

local function SettingProperty(arg: {
	desc: string,
	default_value: any,
	hidden: boolean?,
	saveable: boolean?,
	value_options: any?,
}): any
	local prop
	prop = {
		value_options = arg.value_options,
		description = arg.desc,
		default_value = arg.default_value,
		value = arg.default_value,
		saveable = arg.saveable or true,
		hidden = arg.hidden or false,
	}
	init_prop(prop)
	return prop
end

local default_setting: Settings = {
	auto_try_on_click = SettingProperty({
		desc = "",
		default_value = false,
		hidden = true,
		saveable = false,
	}),
	send_crash_logs = SettingProperty({
		desc = "Sends anonymized crash logs when the plugin errors",
		default_value = true,
	}),
	ui_scaling = SettingProperty({
		desc = "Scales the UI so it can be bigger or smaller",
		default_value = "1.0",
		value_options = { "1.0", "0.75", "0.50", "0.25" },
	}),
	test_property = SettingProperty({
		desc = "Test Internal Property",
		default_value = "Option1",
		hidden = true,
		saveable = false,
		value_options = { "Option1", "Option2" },
	}),
	show_crash_log_consent = SettingProperty({
		desc = "",
		default_value = true,
		hidden = true,
	}),
}

local function init()
	-- check for new settings
	for name, setting in default_setting do
		if not settings_data[name] then
			settings_data[name] = setting
		end
	end
	for _, prop in settings_data do
		init_prop(prop)
	end
end

settings_data = plugin_fs.get(plugin_save_name, true) or default_setting
init()
return settings_data :: Settings
