--!strict
--[[
	Fetches the Catalog and returns an `AssetArray`
]]
local AvatarEditorService = game:GetService("AvatarEditorService")
export type AssetType = {
	Id: number,
	AssetType: string,
	ItemType: "Asset" | "Bundle",
	Name: string,
	Description: string,
	ProductId: number,
	CreatorName: string,
	Price: number,
}
export type AssetArray = {
	[number]: AssetType,
}
type PageImpl = {
	Next: (self: PageImpl) -> AssetArray?,
}
type Struct = {
	Filter: CatalogSearchParams,
	ExportAssetType: AssetType,
}
type Impl = {
	Pages: (self: CatalogFetcher, page: Pages) -> PageImpl,
	GetRecommendedAssets: (self: CatalogFetcher, id: number, avatar_asset_type: Enum.AvatarAssetType) -> AssetArray,
	GetRecommendedBundles: (self: CatalogFetcher, id: number) -> AssetArray,
	GetBatchItemDetails: (self: CatalogFetcher, id: { number }, type: Enum.AvatarItemType?) -> AssetArray,
	Search: (self: CatalogFetcher, query: string, filter_override: CatalogSearchParams?) -> PageImpl?,
	FilterAsTable: (self: CatalogFetcher) -> {},
}
export type CatalogFetcher = Impl & Struct
local Avatar = {} :: CatalogFetcher
Avatar.Filter = CatalogSearchParams.new();
(Avatar.Filter :: any).Limit = 120
Avatar.Filter.AssetTypes = { Enum.AvatarAssetType.HairAccessory }
function Avatar:Pages(Pages: Pages)
	local meta = {}
	local First = true

	function meta:Next()
		if First then
			First = false
			return Pages:GetCurrentPage()
		end

		if Pages.IsFinished and not First then
			return {}
		end

		local Ok, _ = pcall(function()
			Pages:AdvanceToNextPageAsync()
		end)

		if Ok then
			return Pages:GetCurrentPage()
		end

		return nil
	end

	return meta
end

function Avatar:Search(Query: string, filter_override)
	self.Filter.SearchKeyword = Query
	local Ok, Result = pcall(function()
		return AvatarEditorService:SearchCatalogAsync(filter_override or self.Filter)
	end)

	if not Ok then
		-- Log:Error(`couldn't search, error: {Result}`)
		return nil
	end

	return Avatar:Pages(Result)
end

function Avatar:GetRecommendedAssets(Id: number, avatar_asset_type: Enum.AvatarAssetType)
	--[[
		Returns an array of recommended assets
	]]
	local ok, asset_array = pcall(function(...)
		local Recommended = AvatarEditorService:GetRecommendedAssetsAsync(avatar_asset_type, Id)
		local asset_array: { AssetType } = {}
		for _, Item in Recommended do
			table.insert(asset_array, {
				Id = Item.Item.AssetId,
				AssetType = avatar_asset_type.Name,
				ItemType = "Asset",
				Name = Item.Item.Name,
				Description = "",
				ProductId = Item.Product.Id,
				CreatorName = Item.Creator.Name,
				Price = Item.Item.Price,
			})
		end
		return asset_array
	end)

	if not ok then
		return {}
	end

	return asset_array
end

function Avatar:GetRecommendedBundles(Id: number)
	local ok, asset_array = pcall(function(...)
		local Recommended = AvatarEditorService:GetRecommendedBundlesAsync(Id)
		local asset_array: { AssetType } = {}
		for _, Item in Recommended do
			table.insert(asset_array, {
				Id = Item.Id,
				AssetType = "",
				ItemType = "Bundle",
				Name = Item.Name,
				Description = "",
				ProductId = Item.Product.Id,
				CreatorName = Item.Creator.Name,
				Price = Item.Product.PriceInRobux,
			})
		end
		return asset_array
	end)

	if not ok then
		return {}
	end
	return asset_array
end

function Avatar:GetBatchItemDetails(ids, type)
	local ok, asset_array = pcall(function(...)
		return AvatarEditorService:GetBatchItemDetailsAsync(ids, type or Enum.AvatarItemType.Asset)
	end)
	if not ok then
		return {}
	end
	return asset_array
end

function Avatar:FilterAsTable()
	return {
		AssetTypes = table.clone(Avatar.Filter.AssetTypes),
		BundleTypes = table.clone(Avatar.Filter.BundleTypes),
		CategoryFilter = Avatar.Filter.CategoryFilter,
		CreatorId = Avatar.Filter.CreatorId,
		CreatorName = Avatar.Filter.CreatorName,
		CreatorType = Avatar.Filter.CreatorType,
		IncludeOffSale = Avatar.Filter.IncludeOffSale,
		Limit = Avatar.Filter.Limit,
		MaxPrice = Avatar.Filter.MaxPrice,
		MinPrice = Avatar.Filter.MinPrice,
		SearchKeyword = Avatar.Filter.SearchKeyword,
		SortAggregation = Avatar.Filter.SortAggregation,
		SortType = Avatar.Filter.SortType,
	}
end

return Avatar
