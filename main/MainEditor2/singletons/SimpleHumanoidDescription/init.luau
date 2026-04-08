local SelectionService = game:GetService("Selection")
local utils = require("../utils")
local shared = require("../shared")
local shs = require("@self/SimpleHumanoidDescriptionServer"):new()
local event_bus = require("./event_bus")
local recovery = require("./data_recovery")
local plugin_global = shared.plugin.plugin
local plugin_widget = shared.plugin.widget
local plugin_closed = false
local previous_failure = false
local selection_changed = SelectionService.SelectionChanged:Connect(function()
	if previous_failure then
		previous_failure = false
		return
	end
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
	if rig:FindFirstChild(recovery.magic_keyword_ignore_avatarboom) then
		return
	end
	if not shs.inited_humanoids[humanoid] then
		recovery.save_rig(rig)
	end
	local ok, error = shs:init(humanoid)
	if not ok then
		previous_failure = true
		event_bus.humanoid_description_error.emit({ error = error })
	end
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
