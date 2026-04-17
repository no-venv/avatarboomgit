local lune = require("../components/lune_ui")
local asset_button = require("../components/AssetButton")
local catalog_fetcher = require("../../singletons/CatalogFetcher")
local utils = require("../../utils")
local shared = require("../../shared")
return function(parent: Instance?, assets: catalog_fetcher.AssetArray)
	return lune.iconbutton({
		id = shared.icons.buy,
		theme_enabled = true,
		tooltip = "Buy Wearing",
		on_click = function()
			local sum_price = 0
			for _, asset in assets do
				if not asset.Price then
					continue
				end
				sum_price += asset.Price
			end
			local buy_container = lune.scrolling_frame(nil, "List")
			buy_container.Name = "Buy"
			local shared_asset_text = { `My Outfit! ⭐ ({sum_price} robux) (may change with dynamic pricing)` }
			for index, asset in assets do
				local asset_container = lune.empty_frame(buy_container)
				asset_container.Size = UDim2.new(1, 0, 0, 72)
				lune.styling.sizeconst(asset_container, Vector2.new(0, 72), Vector2.new(math.huge, 72))
				asset_container.AutomaticSize = Enum.AutomaticSize.Y
				local hbox = lune.styling.hbox(asset_container)
				hbox.HorizontalFlex = Enum.UIFlexAlignment.Fill
				hbox.VerticalFlex = Enum.UIFlexAlignment.Fill

				asset_button({
					parent = asset_container,
					asset = asset,
					on_click = function() end,
				})
				local catalog_link = `https://www.roblox.com/catalog/{asset.Id}`
				local textbox = lune.textbox("", asset_container)
				textbox.Text = catalog_link
				textbox.ClearTextOnFocus = false
				textbox.TextEditable = false
				table.insert(
					shared_asset_text,
					`{index}. {asset.Name} ({not asset.Price and 0 or asset.Price} robux): {catalog_link}`
				)
			end

			local share_container = lune.scrolling_frame(nil, "List")
			share_container.Name = "Share"

			local textbox = lune.textbox("", share_container)
			textbox.Size = UDim2.fromScale(1, 1)
			textbox.AutomaticSize = Enum.AutomaticSize.Y
			textbox.Text = table.concat(shared_asset_text, "\n\n")
			textbox.ClearTextOnFocus = false
			textbox.TextEditable = false
			lune.window.base({
				size = Vector2.new(0.9, 0.9),
				title = "Copy and Paste the links by pressing 'Ctrl' and 'C' at the same time",
				view = lune.tab({ buy_container, share_container }, "Buy"),
				important = true,
			})
		end,
		parent = parent,
	})
end
