local SelectionService = game:GetService("Selection")
local utils = require("../utils")
local shared = require("../shared")
local shs = require("@self/SimpleHumanoidDescriptionServer"):new()
local plugin_global = shared.plugin.plugin
local plugin_widget = shared.plugin.widget
local plugin_closed = false
local selection_changed = SelectionService.SelectionChanged:Connect(function()
	if plugin_closed then
		return
	end
	local selection_get = SelectionService:Get()
	if #selection_get == 0 then
		shs:init(nil)
		return
	end
	local rig = selection_get[1] :: Model
	local humanoid: Humanoid? = rig:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end
	if shs.Humanoid == humanoid then
		return
	end
	shs:init(humanoid)
	SelectionService:Set({ rig })
end)

if plugin_global then
	plugin_widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		plugin_closed = not plugin_widget.Enabled
	end)
	plugin_closed = not plugin_widget.Enabled
end

-- for ui-labs to prevent memory leaks while debugging
-- this is not an issue with plugin releases since the scripts will
-- actually stop running
local janitor = utils.ui_labs.Environment.GetJanitor()
if janitor then
	janitor:Add(selection_changed)
end
return shs
