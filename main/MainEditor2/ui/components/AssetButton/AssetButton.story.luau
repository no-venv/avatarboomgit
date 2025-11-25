local assetbutton = require(script.Parent)
return {
	render = function(prop)
		local button = assetbutton {
			price = 10;
			asset_id = 16846343979;
			asset_type = "Asset";
			parent = prop.target
		}
		return function()
			button:Destroy()
		end
	end,
}