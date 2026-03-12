type arg = {
	assets: {
		{
			asset_id: number,
			asset_type: "Asset" | "Bundle",
		}
	},
	name: string,
	parent: Instance?,
	on_click: (() -> nil)?,
	on_rename: (() -> nil)?,
	on_share: (() -> nil)?,
	on_remove: (() -> nil)?,
}
local lune = require("../lune_ui")
local button_header = require("../ButtonHeader")
local iconbutton = lune.iconbutton
local textlabel = lune.textlabel
local container_udim = UDim2.new(0, 135, 0, 135)

return function(arg: arg): TextButton
	local name = arg.name
	local parent = arg.parent
	local on_click = arg.on_click
	local on_rename = arg.on_rename
	local on_share = arg.on_share
	local on_remove = arg.on_remove
	local asset_urls = {}
	for _, asset in arg.assets do
		table.insert(asset_urls, `rbxthumb://type={asset.asset_type}&id={asset.asset_id}&w=420&h=420`)
	end
	local asset_button = iconbutton({
		parent = parent,
		id = asset_urls,
		theme_enabled = false,
		on_click = function()
			if on_click then
				on_click()
			end
		end,
	})

	asset_button.Size = container_udim

	local label = textlabel(name, asset_button,true)
	label.AnchorPoint = Vector2.new(0, 1)
	label.Position = UDim2.fromScale(0, 1)
	label.TextYAlignment = Enum.TextYAlignment.Bottom
	button_header({
		parent = asset_button,
		left_topbar = {
			{
				id = 111453011062900,
				on_click = on_rename,
			},
		},
		right_topbar = {
			{
				id = 96060799177234,
				on_click = on_remove,
			},
		},
	})

	return asset_button
end

-- 	-- if on_share then
-- 	-- 	ibutton(left_container, 103742597823204, on_share)
-- 	-- end
-- end
