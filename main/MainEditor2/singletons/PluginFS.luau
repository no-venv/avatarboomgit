--!strict
local HttpService = game:GetService("HttpService")
type void = nil
local plugin = require("../shared/Plugin").plugin
type Impl = {
	get: (key: string, decode_as_json: boolean?) -> any,
	save: (key: string, data: any, encode_as_json: boolean?) -> void,
	on_save: { () -> void },
}

local PluginFS: Impl = {
	get = function(key, decode_as_json)
		if not plugin then
			return
		end
		local data = plugin:GetSetting(key)
		if not data then
			return nil
		end
		return decode_as_json and HttpService:JSONDecode(data) or data
	end,
	save = function(key, data, encode_as_json)
		if not plugin then
			return
		end
		plugin:SetSetting(key, encode_as_json and HttpService:JSONEncode(data) or data)
	end,
	on_save = {},
}

return PluginFS
