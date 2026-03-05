local pin_button = require("../PinBoardButton")
return {
	render = function(prop)
		local button = pin_button({
			assets = {
				{
					asset_id = 16846343979,
					asset_type = "Asset",
				},
				{
					asset_id = 16846343979,
					asset_type = "Asset",
				},
				{
					asset_id = 16846343979,
					asset_type = "Asset",
				},
			},
			name = "Goth",
			parent = prop.target,
		})
		return function()
			button:Destroy()
		end
	end,
}
