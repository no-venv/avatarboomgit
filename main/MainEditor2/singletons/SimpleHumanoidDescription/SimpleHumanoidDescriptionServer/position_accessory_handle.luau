--!strict
-- note: Studio's accessory positioning whilst editing is inconsistent: sometimes the Handle lands on the matching body Attachment, sometimes it's placed far from the character.
-- This helper sets the Handle's CFrame explicitly so the result is always the same.
local RunService = game:GetService("RunService")

local function position_accessory_handle(accessory: Accessory, character: Instance)
	if not RunService:IsEdit() then
		return
	end
	local handle = accessory:FindFirstChild("Handle")
	if not handle or not handle:IsA("BasePart") then
		return
	end

	for _, handle_attachment in handle:GetChildren() do
		if not handle_attachment:IsA("Attachment") then
			continue
		end
		for _, body_part in character:GetChildren() do
			if not body_part:IsA("BasePart") then
				continue
			end
			local body_attachment = body_part:FindFirstChild(handle_attachment.Name)
			if body_attachment and body_attachment:IsA("Attachment") then
				handle.CFrame = body_attachment.WorldCFrame * handle_attachment.CFrame:Inverse()
				return
			end
		end
	end
end

return position_accessory_handle
