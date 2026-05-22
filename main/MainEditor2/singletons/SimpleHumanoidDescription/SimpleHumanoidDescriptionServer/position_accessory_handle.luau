--!strict
-- note: Studio's accessory positioning whilst editing is inconsistent: sometimes the Handle lands on the matching body Attachment, sometimes it's placed far from the character.
-- This helper sets the Handle's CFrame explicitly so the result is always the same.
local function position_accessory_handle(accessory: Accessory, character: Instance)
	local handle = accessory:FindFirstChild("Handle")
	if not handle or not handle:IsA("BasePart") then
		return
	end

	for _, handle_attachment in handle:GetChildren() do
		if not handle_attachment:IsA("Attachment") then
			continue
		end
		for _, candidate in character:GetDescendants() do
			if
				candidate:IsA("Attachment")
				and candidate.Name == handle_attachment.Name
				and candidate.Parent ~= handle
				and candidate.Parent:IsA("BasePart")
				and candidate.Parent.Parent == character
			then
				handle.CFrame = candidate.WorldCFrame * handle_attachment.CFrame:Inverse()
				return
			end
		end
	end
end

return position_accessory_handle
