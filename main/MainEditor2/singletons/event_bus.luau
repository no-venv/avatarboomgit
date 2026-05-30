--!strict
-- Event Bus for the views
local CatalogFetcher = require("../singletons/CatalogFetcher")
local event = require("../utils/TypedBindables")
local client_event = event.client
type UiOverlay = "Wearing" | "Favourites" | "None" | "Composer" | "All"
type Events = {
	catalog_search: event.Event<{
		query: string,
	}>,
	catalog_set_search_filter: event.Event<{
		CreatorName: string?,
		CreatorId: number?,
		CreatorType: Enum.CreatorTypeFilter?,
		SortType: Enum.CatalogSortType?,
		IncludeOffSale: boolean?,
		BundleTypes: { Enum.BundleType }?,
		AssetTypes: { Enum.AvatarAssetType }?,
	}>,
	catalog_show_overlay: event.Event<{
		overlay: UiOverlay,
	}>,
	avatar_item_selected: event.Event<{
		asset_info: CatalogFetcher.AssetType,
	}>,
	select_rig_overlay: event.Event<{
		bool: boolean,
	}>,
	drawer_open: event.Event<{
		bool: boolean?,
	}>,
	pop_out_drawer: event.Event<{
		bool: boolean,
	}>,
	avatar_boom_post_init: event.Event<{}>,
	save_pinboard: event.Event<{
		asset_info: { CatalogFetcher.AssetType },
		operation: ("Save" | "Move")?,
		move_src: string?,
	}>,
	save_pinboard_success: event.Event<{}>,
	topbar_register_custom_button: event.Event<{
		image: number,
		button_id: string,
		allowed_overlay: { UiOverlay } | UiOverlay,
		tooltip: string,
		has_state: boolean?,
		one_shot_visibility: boolean?,
		location: ("left" | "centre" | "right")?,
		on_click: (state: boolean) -> any,
	}>,
	topbar_register_custom_element: event.Event<{
		element: GuiBase2d,
		button_id: string,
		allowed_overlay: { UiOverlay } | UiOverlay,
		location: ("left" | "centre" | "right")?,
	}>,
	topbar_unregister_custom_button: event.Event<{
		button_id: string | { string },
	}>,
	topbar_visibility_custom_button: event.Event<{
		button_id: string | { string },
		show: boolean,
	}>,
	topbar_set_state: event.Event<{
		button_id: string,
		state: boolean,
	}>,
	humanoid_description_error: event.Event<{
		error: string,
	}>,
}
return {
	catalog_search = client_event(),
	catalog_set_search_filter = client_event(),
	avatar_item_selected = client_event(),
	drawer_open = client_event(),
	pop_out_drawer = client_event(),
	select_rig_overlay = client_event(),
	catalog_show_overlay = client_event(),
	avatar_boom_post_init = client_event(),
	save_pinboard = client_event(),
	save_pinboard_success = client_event(),
	topbar_register_custom_button = client_event(),
	topbar_register_custom_element = client_event(),
	topbar_unregister_custom_button = client_event(),
	topbar_visibility_custom_button = client_event(),
	humanoid_description_error = client_event(),
	-- topbar_hide_search
	topbar_set_state = client_event(),
} :: Events
