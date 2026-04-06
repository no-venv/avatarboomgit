type Argument = {
	{
		ItemType: string,
		Id: string | number,
	}
}
return function(args: Argument)
	local img = {}
	for _, asset in args do
		if not asset then
			break
		end
		local asset_type = asset.ItemType
		local asset_id = asset.Id
		if asset_type == "Bundle" then
			asset_type = "BundleThumbnail"
		end
		table.insert(img, `rbxthumb://type={asset_type}&id={asset_id}&w=420&h=420`)
	end
	return img
end
