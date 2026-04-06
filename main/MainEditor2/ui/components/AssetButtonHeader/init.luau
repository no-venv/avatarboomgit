export type buttons_enabled_args = {
	["Favourite"]: boolean?,
	["Remove"]: boolean?,
}
local shared = require("../../shared")
local singletons = require("../../singletons")
local button_header = require("./ButtonHeader")
local catalog_fetcher = singletons.catalog_fetcher
local humanoid_editor = singletons.humanoid_description

return function(
	asset_type: typeof(catalog_fetcher.ExportAssetType),
	enabled_buttons: buttons_enabled_args,
	parent: GuiObject,
	override_button_favourite: (() -> boolean)?,
	override_button_remove: (() -> nil)?
)
	local left_topbar: { button_header.Button } = {}
	local right_topbar: { button_header.Button } = {}

	if enabled_buttons.Favourite then
		local favourite: button_header.Button = {
			id = shared.icons.heart,
			id_states = { 94312408803509 },
			on_click = function()
				local return_result = false
				if override_button_favourite then
					return_result = override_button_favourite()
					return return_result and 1 or nil
					-- set_favourite_button_state(favourte_button, return_result)
				else
					singletons.event_bus.save_pinboard.emit({
						asset_info = { asset_type },
					})
					-- return_result = shared.pinboard.lookup_id(asset_type.Id)
				end
				return nil
			end,
		}
		table.insert(left_topbar, favourite)
	end
	if enabled_buttons.Remove then
		local remove: button_header.Button = {
			id = shared.icons.add,
			id_states = { shared.icons.remove },
			on_click = function()
				if override_button_remove then
					override_button_remove()
				else
					if not humanoid_editor:is_init() then
						return nil
					end
					local wearing = humanoid_editor:id_equipped(asset_type.Id)
					if wearing then
						if asset_type.ItemType == "Asset" then
							humanoid_editor:remove_id(asset_type.Id)
						else
							humanoid_editor:remove_bundle_id(asset_type.Id)
						end
						return nil
					else
						if asset_type.ItemType == "Asset" then
							humanoid_editor:add_id(asset_type.Id)
						else
							humanoid_editor:add_bundle_id(asset_type.Id)
						end
						return 1
					end
				end
				return nil
			end,
		}
		table.insert(right_topbar, remove)
	end
	local header, header_func = button_header({
		parent = parent,
		left_topbar = left_topbar,
		right_topbar = right_topbar,
	})
	if enabled_buttons.Remove then
		local function set_add_remove_id_state()
			local wearing = humanoid_editor:id_equipped(asset_type.Id)
			header_func.set_button_image_state(shared.icons.add, wearing and 1 or nil)
		end

		local function id_changed_event(id: number)
			if id ~= asset_type.Id then
				return
			end
			set_add_remove_id_state()
		end
		local humanoid_changed = humanoid_editor.humanoid_changed.Event:Connect(set_add_remove_id_state)
		local id_added_event = humanoid_editor.id_added.Event:Connect(id_changed_event)
		local id_remove_event = humanoid_editor.id_removed.Event:Connect(id_changed_event)
		header.Destroying:Connect(function()
			id_added_event:Disconnect()
			humanoid_changed:Disconnect()
			id_remove_event:Disconnect()
		end)
		set_add_remove_id_state()
	end

	return header
end
