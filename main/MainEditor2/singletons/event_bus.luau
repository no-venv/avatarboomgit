--!strict
-- Event Bus for the views
local CatalogFetcher = require(script.Parent.CatalogFetcher)
local utils = require(script.Parent.Parent.utils)
local event_real = require(script.Parent.Parent.utils.TypedBindables)
type Events = {
	catalog_search : {
		query : string,
	};
	catalog_set_search_filter : {
		CreatorName : string?;
		CreatorId : number?;
		CreatorType : Enum.CreatorTypeFilter?;
		SortType : Enum.CatalogSortType?;
		IncludeOffSale : boolean?;
		BundleTypes : {Enum.BundleType}?;
		AssetTypes : {Enum.AvatarAssetType}?;
	};
	accessory_modification_ready : {
		bool : boolean;
	};
	catalog_show_overlay : {
		overlay : "Wearing" | "Favourites" | "None"
	};
	avatar_item_selected : {
		asset_info : typeof(CatalogFetcher.ExportAssetType)
	};
	
	select_rig_overlay : {
		bool : boolean
	};
	drawer_open : {
		bool : boolean?
	};
	pop_out_drawer : {
		bool : boolean
	};
	avatar_boom_post_init : {
		
	}
}
local nothing_meta = {
	__index = function()
		return nil
	end,
}
local janitor = utils.ui_labs.Environment.GetJanitor()
local hook = false
local event_id = 1
local event : typeof(event_real) = function(...)
	local captured_event = event_real(...)
	if janitor then
		janitor:Add(captured_event.raw)
	end
	if hook then
		local captured_event_id = event_id
		captured_event.connect(function(parm): nil 
			print("Event",captured_event_id)	
			print(parm)
			return
		end)
	end
	event_id +=1
	return captured_event
end

local events_table = setmetatable({},nothing_meta) :: typeof(setmetatable({}::Events,{}::typeof(nothing_meta)))

return {
	catalog_search = event(events_table.catalog_search);
	catalog_set_search_filter = event(events_table.catalog_set_search_filter);
	avatar_item_selected = event(events_table.avatar_item_selected);
	drawer_open = event(events_table.drawer_open);
	pop_out_drawer = event(events_table.pop_out_drawer);
	select_rig_overlay = event(events_table.select_rig_overlay);
	catalog_show_overlay = event(events_table.catalog_show_overlay);
	accessory_modification_ready = event(events_table.accessory_modification_ready);
	avatar_boom_post_init = event(events_table.avatar_boom_post_init);
}
