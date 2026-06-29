local shs = require("../singletons/SimpleHumanoidDescription")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

shs.id_added.Event:Connect(function(...)
	ChangeHistoryService:SetWaypoint("Id added")
end)

return true
