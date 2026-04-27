--!strict
local lune = require("../../components/lune_ui")
local utils = require("../../../utils")
type Argument = {
	parent: Instance?,
	name: string,
	items: { { Order: number, AssetId: number} },
	on_position_change: (id: number, position: number) -> (),
}
return function(args: Argument)
	local container = lune.scrolling_frame(args.parent, "List", {
		-- SortOrder = Enum.SortOrder.Name,
	})
	container.Name = args.name
	container.Size = UDim2.fromOffset(72, 0)
	container.AutomaticSize = Enum.AutomaticSize.Y
	-- create icon button
	-- local item_length = #args.items
	local sorted_items = {}
	local function fix_ui_order()
		table.sort(sorted_items, function(a0, a1)
			return a0.item.Order > a1.item.Order
		end)
		for index, buttons in sorted_items do
			buttons.gui.LayoutOrder = index
		end
	end
	for index, item in args.items do
		local button_container = lune.empty_frame(container)
		button_container.AutomaticSize = Enum.AutomaticSize.Y
		button_container.Size = UDim2.fromOffset(72, 72)
		lune.styling.vbox(button_container)
		local icon_button = lune.iconbutton({
			parent = button_container,
			id = utils.generate_asset_thumb({ {
				Id = item.AssetId,
			} })[1],
			on_click = function() end,
		})

		button_container.LayoutOrder = item.Order
		icon_button.Size = UDim2.fromScale(1, 1)
		local position_textbox = lune.textbox("Order", button_container, function(text: string, enter_pressed: boolean)
			if enter_pressed then
				local position = tonumber(text)
				if not position then
					return
				end
				item.Order = position
				button_container.LayoutOrder = position
				fix_ui_order()
				args.on_position_change(item.AssetId, position)
				return
			end
			return
		end)

		position_textbox.Text = tostring(item.Order)
		position_textbox.Size = UDim2.new(1, 0, 0, 24)
		table.insert(sorted_items, {
			item = item,
			gui = button_container,
		})
		-- icon_button.Position = UDim2.fromOffset(0, y_placement)
	end
	fix_ui_order()

	return container
end
