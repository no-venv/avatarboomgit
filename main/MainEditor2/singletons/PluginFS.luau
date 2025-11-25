--!strict
type void = nil;
local Editor = script:FindFirstAncestor("MainEditor2")
local shared = require(Editor.shared.Plugin)
local plugin = shared.plugin
type Impl = {
	get : (key : string) -> any;
	save : (key : string, data : any) -> void;
	on_save : {() -> void};
}

local PluginFS : Impl = {
	get = function(key)
		if not plugin then
			return
		end
		return plugin:GetSetting(key)
	end,
	save = function(key,data)
		if not plugin then
			return
		end
		plugin:SetSetting(key,data)
	end,
	on_save = {}
}

return PluginFS