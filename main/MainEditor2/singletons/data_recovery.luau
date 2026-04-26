--!strict
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")

type DataRecovery = {
	magic_keyword_ignore_avatarboom: string,
}
type DataRecoveryImpl = {
	get_recovery_folder: () -> Folder,
	save_rig: (rig: Model) -> (),
	get_rig_saves_by_model: (rig: Model) -> { { time: number, rig: Model } }?,
}
local recovery_folder: Folder
if not ServerStorage:FindFirstChild("AvatarBOOM_Recovery") then
	local folder = Instance.new("Folder")
	folder.Name = "AvatarBOOM_Recovery"
	folder.Parent = ServerStorage
	recovery_folder = folder
else
	recovery_folder = ServerStorage:FindFirstChild("AvatarBOOM_Recovery") :: Folder
end

local recovery = {} :: DataRecoveryImpl & DataRecovery

recovery.magic_keyword_ignore_avatarboom = "DELETE_THIS_IF_YOU_WANT_TO_USE_THIS_RIG"

recovery.save_rig = function(rig)
	local recovery_uuid = HttpService:GenerateGUID(false)
	if not rig:GetAttribute("recovery_uuid") then
		rig:SetAttribute("recovery_uuid", recovery_uuid)
	else
		recovery_uuid = rig:GetAttribute("recovery_uuid") :: string
	end
	local uuid_recovery_folder = recovery_folder:FindFirstChild(recovery_uuid) :: Folder
	if not uuid_recovery_folder then
		local new_uuid_folder = Instance.new("Folder") :: Folder
		new_uuid_folder.Name = recovery_uuid
		new_uuid_folder.Parent = recovery_folder
		uuid_recovery_folder = new_uuid_folder
	end

	-- keep it to a max of 10 rigs to avoid cluttering
	local rig_saves = recovery.get_rig_saves_by_model(rig)
	if not rig_saves then
		return
	end
	local rig_saves_len = #rig_saves
	if rig_saves_len > 10 then
		local old_rig_save = rig_saves[rig_saves_len]
		old_rig_save.rig:Destroy()
	end
	rig.Archivable = true
	local cloned = rig:Clone()
	cloned.Name = tostring(os.time())
	cloned.Parent = uuid_recovery_folder

	local ignore_avatarboom = Instance.new("BoolValue")
	ignore_avatarboom.Name = recovery.magic_keyword_ignore_avatarboom
	ignore_avatarboom.Parent = cloned
end

recovery.get_recovery_folder = function()
	return recovery_folder
end

recovery.get_rig_saves_by_model = function(rig)
	local recovery_uuid = rig:GetAttribute("recovery_uuid") :: string?
	if not recovery_uuid then
		return nil
	end
	local recovery_models = recovery_folder:FindFirstChild(recovery_uuid)
	if not recovery_models then
		return nil
	end
	-- sort from greatest to least
	local children = recovery_models:GetChildren()
	local sorted_time = {}
	for _, child in children do
		table.insert(sorted_time, tonumber(child.Name) :: number)
	end
	table.sort(sorted_time, function(a0, a1)
		return a0 > a1
	end)
	local sorted_rigs = {}
	for _, time in sorted_time do
		table.insert(sorted_rigs, {
			time = time,
			rig = recovery_models[tostring(time)],
		})
	end
	return sorted_rigs
end

return recovery
