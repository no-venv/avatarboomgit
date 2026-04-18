--!nonstrict
local lune = require("@self/../../components/lune_ui")
local singletons = require("@self/../../../singletons")
local pinboard_shared = require("../../shared/pinboard")
local pinboard_viewer = require("@self/../../components/PinboardPicker")
local utils = require("../../utils")
return function(parent: Frame?)
	local container = lune.empty_frame()
	container.Name = "Save to Board"
	lune.textlabel("<b>Save to Pin Board:</b>", container)
	local save_text = lune.textlabel("Save <> to", container)
	local vbox = lune.styling.vbox(container)
	vbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
	vbox.VerticalFlex = Enum.UIFlexAlignment.Fill
	local pinboard_viewer_container
	local item_button
	singletons.event_bus.save_pinboard.connect(function(parm)
		if pinboard_viewer_container then
			pinboard_viewer_container:Destroy()
		end
		if item_button then
			item_button:Destroy()
		end
		local stuff_to_save = parm.asset_info
		local cocat_msg_1 = #stuff_to_save > 1 and `and {#stuff_to_save - 1}` or ""
		local cocat_msg_2 = ((#stuff_to_save == 2) and "other") or (#stuff_to_save > 2 and "others") or ""
		save_text.Text = `{stuff_to_save[1].Name} {cocat_msg_1} {cocat_msg_2}`
		local ids = {}

		for index = 1, 3 do
			if stuff_to_save[index] then
				ids[index] = utils.generate_asset_thumb({
					stuff_to_save[index],
				})[1]
			end
		end
		item_button = lune.iconbutton({
			id = ids,
			parent = container,
			on_click = function() end,
		})
		item_button.Size = UDim2.fromOffset(130, 130)
		pinboard_viewer_container = pinboard_viewer({
			parent = container,
			on_picked_pinboard = function(picked)
				if parm.operation == "Move" then
					local ids = {}
					for _, save in stuff_to_save do
						table.insert(ids, save.Id)
					end
					pinboard_shared.remove_pin(parm.move_src, ids)
				end
				pinboard_shared.insert_pin(picked.name, stuff_to_save)
				singletons.event_bus.drawer_open.emit({ bool = false })
				return
			end,
		})
	end)
	return container
end
