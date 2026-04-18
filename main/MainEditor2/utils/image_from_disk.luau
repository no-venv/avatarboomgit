--!strict
local StudioService = game:GetService("StudioService")
return function(): string?
	local file = StudioService:PromptImportFileAsync({ "png", "jpg" }) :: File
	if not file then
		return
	end
	return file:GetTemporaryId()
end
