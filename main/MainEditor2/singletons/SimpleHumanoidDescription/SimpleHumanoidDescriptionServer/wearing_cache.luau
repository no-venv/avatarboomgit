
--!strict
local AvatarEditorService = game:GetService("AvatarEditorService")
-- caches avatar asset type
-- gets the current wearing from `simple_humanoid_description`, caches as well
local MAX_CACHE_SIZE = 2 ^ 16
local cached_assets: {
	[number]: any,
} = {}

local pending_assets: { [number]: boolean } = {}
return function(wearing_ids: { number })
	if #cached_assets > MAX_CACHE_SIZE then
		-- too lazy to implement advanced cache management but
		-- i dont think people would put so many ids.. right??
		cached_assets = {}
	end
	local wearing = {}
	local cache_miss_ids = {}
	local wait_for_pending = {}

	for _, id in wearing_ids do
		local cached = cached_assets[id]
		if not cached then
			if pending_assets[id] then
				table.insert(wait_for_pending, id)
			else
				table.insert(cache_miss_ids, id)
				pending_assets[id] = true
			end
		end
	end

	if #cache_miss_ids > 0 then
		local ok, result = pcall(function(...)
			return AvatarEditorService:GetBatchItemDetailsAsync(cache_miss_ids, Enum.AvatarItemType.Asset)
		end)
		if not ok then
			for _, id in cache_miss_ids do
				pending_assets[id] = nil
			end
			return {}
		end
		local asset_info = result
		for _, asset in asset_info do
			cached_assets[asset.Id] = asset
		end
	end
	-- wait for pending
	while #wait_for_pending > 0 do
		local id_for_removal = {}
		for index, id in wait_for_pending do
			if not pending_assets[id] then
				table.insert(id_for_removal, id)
			end
		end
		for _, removal in id_for_removal do
			table.remove(wait_for_pending, table.find(wait_for_pending, removal))
		end
		task.wait()
	end
	for _, id in wearing_ids do
		table.insert(wearing, cached_assets[id])
	end
	for _, id in cache_miss_ids do
		pending_assets[id] = nil
	end
	return wearing
end
