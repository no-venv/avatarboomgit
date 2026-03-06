--!strict
-- Event Bus for the views
local CatalogFetcher = require("../singletons/CatalogFetcher")
local utils = require("../utils")
local event_real = utils.TypedBindables
type UiOverlay = "Wearing" | "Favourites" | "None"
type Events = {
	catalog_search: {
		query: string,
	},
	catalog_set_search_filter: {
		CreatorName: string?,
		CreatorId: number?,
		CreatorType: Enum.CreatorTypeFilter?,
		SortType: Enum.CatalogSortType?,
		IncludeOffSale: boolean?,
		BundleTypes: { Enum.BundleType }?,
		AssetTypes: { Enum.AvatarAssetType }?,
	},
	accessory_modification_ready: {
		bool: boolean,
	},
	catalog_show_overlay: {
		overlay: UiOverlay,
	},
	avatar_item_selected: {
		asset_info: typeof(CatalogFetcher.ExportAssetType),
	},

	select_rig_overlay: {
		bool: boolean,
	},
	drawer_open: {
		bool: boolean?,
	},
	pop_out_drawer: {
		bool: boolean,
	},
	avatar_boom_post_init: {},
	save_pinboard: {
		asset_info: { typeof(CatalogFetcher.ExportAssetType) },
		operation: ("Save" | "Move")?,
		move_src: string?,
	},
	save_pinboard_success: {},
	topbar_register_custom_button: {
		image: number,
		button_id: string,
		allowed_overlay: UiOverlay,
		has_state: boolean?,
		on_click: (state: boolean) -> any,
	},
	topbar_unregister_custom_button: {
		button_id: string | { string },
	},
	topbar_visibility_custom_button: {
		button_id: string | { string },
		show: boolean,
	},
	topbar_on_custom_button: {
		button_id: string,
	},
	topbar_set_state: {
		button_id: string,
		state: boolean,
	},
}
local nothing_meta = {
	__index = function()
		return nil
	end,
}
local janitor = utils.ui_labs.Environment.GetJanitor()
local hook = false
local event_id = 1
local event: typeof(event_real) = function(...)
	local captured_event = event_real(...)
	if janitor then
		-- janitor:Add(captured_event.raw)
	end
	if hook then
		local captured_event_id = event_id
		captured_event.connect(function(parm): nil
			print("Event", captured_event_id)
			print(parm)
			return
		end)
	end
	event_id += 1
	return captured_event
end

local events_table = setmetatable({}, nothing_meta) :: typeof(setmetatable({} :: Events, {} :: typeof(nothing_meta)))

return {
	catalog_search = event(events_table.catalog_search),
	catalog_set_search_filter = event(events_table.catalog_set_search_filter),
	avatar_item_selected = event(events_table.avatar_item_selected),
	drawer_open = event(events_table.drawer_open),
	pop_out_drawer = event(events_table.pop_out_drawer),
	select_rig_overlay = event(events_table.select_rig_overlay),
	catalog_show_overlay = event(events_table.catalog_show_overlay),
	accessory_modification_ready = event(events_table.accessory_modification_ready),
	avatar_boom_post_init = event(events_table.avatar_boom_post_init),
	save_pinboard = event(events_table.save_pinboard),
	save_pinboard_success = event(events_table.save_pinboard_success),
	topbar_register_custom_button = event(events_table.topbar_register_custom_button),
	topbar_unregister_custom_button = event(events_table.topbar_unregister_custom_button),
	topbar_visibility_custom_button = event(events_table.topbar_visibility_custom_button),
	topbar_on_custom_button = event(events_table.topbar_on_custom_button),
	topbar_set_state = event(events_table.topbar_set_state),
}
