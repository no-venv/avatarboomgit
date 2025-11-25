-- caches avatar asset type
-- gets the current wearing from `simple_humanoid_description`, caches as well
local MAX_CACHE_SIZE = 2^16
local catalog_fetcher = require(script.Parent.CatalogFetcher)
local event_bus = require(script.Parent.event_bus)
local utils = require(script.Parent.Parent.utils)
local humanoid_editor = require(script.Parent.SimpleHumanoidDescription)
local log = utils.Log

type Impl = {
	get_wearing : () -> catalog_fetcher.AssetArray
}

local cached_assets : {
	[number] : catalog_fetcher.AssetType
} = {} 
local cache = {}

function cache.get_wearing()
	if #cached_assets > MAX_CACHE_SIZE then
		-- too lazy to implement advanced cache management but
		-- i dont think people would put so many ids.. right??
		cached_assets = {}
	end
	local wearing = {}
	local cache_miss_ids = {}
	local cache_miss_bundle_ids = {}
	local wearing_ids = humanoid_editor:get_id_list()
	--local wearing_bundle_ids = humanoid_editor:get_bundle_id_list()		
	
	for _,id in wearing_ids do
		local cached = cached_assets[id]
		if not cached then
			table.insert(cache_miss_ids,id)
		end
	end
	--for _,id in wearing_bundle_ids do
	--	local cached = cached_assets[id]
	--	if not cached then
	--		table.insert(cache_miss_bundle_ids,id)
	--	end
	--end
	
	if #cache_miss_ids > 0 then
		local asset_info = catalog_fetcher:GetBatchItemDetails(wearing_ids)
		for _,asset in asset_info do
			cached_assets[asset.Id] = asset
		end
	end
	
	--if #cache_miss_bundle_ids > 0 then
	--	local asset_info_bundled = catalog_fetcher:GetBatchItemDetails(wearing_bundle_ids,Enum.AvatarItemType.Bundle)
	--	for _,asset in asset_info_bundled do
	--		cached_assets[asset.Id] = asset
	--	end
	--end
	
	for _,id in wearing_ids do
		table.insert(wearing,cached_assets[id])
	end
	--for _,id in wearing_bundle_ids do
	--	table.insert(wearing,cached_assets[id])
	--end
	
	return wearing
end



return cache
