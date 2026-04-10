local singletons = require("../../singletons")
local humanoid_editor = singletons.humanoid_description
local event_bus = singletons.event_bus
local on_modification = require("@self/on_modification")
local lune = require("../../ui/components/lune_ui")
local colour = require("@self/colour")
local gizmos = require("@self/gizmos")
local material = require("@self/material")
return function(parent: Instance?)
	local container = lune.empty_frame()
	container.Name = "Edit"
	local warning_overlay = lune.empty_frame(container)
	local warning_label = lune.textlabel("", warning_overlay)
	do
		local vbox = lune.styling.vbox(warning_overlay)
		vbox.VerticalAlignment = Enum.VerticalAlignment.Center
		vbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
	end
	local tab_container, _, tab_impl = lune.tab({}, "Colour", container)
	tab_impl.add_views({
		colour(tab_impl),
		material(tab_impl),
	})
	gizmos(container)
	tab_impl.toggle("Colour", true)
	tab_container.Visible = false
	local current_asset_info = nil
	local event_parm: on_modification.EventParm = {
		id = 0,
		event_type = "disable",
		is_accessory = true,
		is_clothing = true,
		clothing_type = "",
	}
	local function update_all()
		if not current_asset_info then
			return
		end
		local item_type = current_asset_info.ItemType
		local asset_type = current_asset_info.AssetType
		event_parm.id = current_asset_info.Id
		event_parm.is_accessory = item_type == "Asset"
		event_parm.is_clothing = asset_type == "Shirt" or asset_type == "Pants"
		event_parm.clothing_type = asset_type
		on_modification.emit(event_parm)
	end

	local function show_warning_overlay(bool, text)
		warning_label.Text = text
		warning_overlay.Visible = bool
		tab_container.Visible = not bool
	end
	local function on_tab_count(count)
		show_warning_overlay(
			not (count > 0),
			not humanoid_editor:id_equipped(current_asset_info.Id) and "Try on the asset to edit"
				or "Looks like this asset is not editable 😞 (or you need to wait)"
		)
	end
	humanoid_editor.humanoid_changed.Event:Connect(function(...)
		event_parm.event_type = "humanoid_changed"
		update_all()
	end)
	humanoid_editor.id_added.Event:Connect(function(...)
		event_parm.event_type = "id_inserted"
		update_all()
	end)
	humanoid_editor.id_removed.Event:Connect(function(...)
		event_parm.event_type = "id_removed"
		update_all()
	end)
	event_bus.avatar_item_selected.connect(function(parm)
		current_asset_info = parm.asset_info
		if not humanoid_editor:id_equipped(parm.asset_info.Id) then
			show_warning_overlay(true, "Try on the asset to edit!")
		end
		event_parm.event_type = "selected_id"
		on_tab_count(0)
		update_all()
		return
	end)
	event_bus.drawer_open.connect(function(parm)
		if current_asset_info ~= nil then
			event_parm.event_type = "disable"
			update_all()
		end
		current_asset_info = nil
	end)
	tab_impl.on_tab_count = on_tab_count
	return container
end
