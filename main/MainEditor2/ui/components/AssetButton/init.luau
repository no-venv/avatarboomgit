local shared = require("../../shared")
local singletons = require("../../singletons")
local lune = require("@self/../lune_ui")
local event_frames = require("./EventFrames")
type arg = {
	asset: typeof(singletons.catalog_fetcher.ExportAssetType),
	parent: Instance?,
	ignore_auto_try: boolean?,
	on_click: (() -> ())?,
}

local iconbutton = lune.iconbutton
local textlabel = lune.textlabel
local container_udim = UDim2.new(0, 135, 0, 135)
return function(arg: arg): TextButton
	local price = arg.asset.Price
	local asset_id = arg.asset.Id
	local asset_type = arg.asset.ItemType
	local parent = arg.parent
	local ignore_auto_try = arg.ignore_auto_try
	local on_click = arg.on_click
	if asset_type == "Bundle" then
		asset_type = "BundleThumbnail"
	end
	local auto_try_click = shared.settings.auto_try_on_click
	local asset_button
	local spinner
	asset_button = iconbutton({
		parent = parent,
		id = `rbxthumb://type={asset_type}&id={asset_id}&w=420&h=420`,
		padding = 32,
		theme_enabled = false,
		on_click = function()
			if on_click then
				on_click()
			else
				-- default function, in process of centralizing logic to reduce redundancy
				local auto_try = auto_try_click.value
				if auto_try and not ignore_auto_try then
					if not singletons.humanoid_description:is_id_operations_ready() then
						return
					end
					spinner.Visible = true
					if singletons.humanoid_description:id_equipped(asset_id) then
						if asset_type == "Asset" then
							singletons.humanoid_description:remove_id(asset_id)
						else
							singletons.humanoid_description:remove_bundle_id(asset_id)
						end
						lune.theme_manager:force_highlight(asset_button, false)
					else
						if asset_type == "Asset" then
							singletons.humanoid_description:add_id(asset_id)
						else
							singletons.humanoid_description:add_bundle_id(asset_id)
						end
						lune.theme_manager:force_highlight(asset_button, true)
					end
					spinner.Visible = false
				else
					singletons.event_bus.avatar_item_selected.emit({
						asset_info = arg.asset,
					})
				end
			end
		end,
	})

	spinner = event_frames.spinner(asset_button)
	spinner.ZIndex = 150
	spinner.AnchorPoint = Vector2.new(0.5, 0.5)
	spinner.Position = UDim2.fromScale(0.5, 0.5)
	spinner.Visible = false

	local grey_overlay = lune.empty_frame(asset_button)
	lune.styling.corner(grey_overlay)
	lune.theme_manager:add_custom_gui_instance(grey_overlay, "Background")
	grey_overlay.ZIndex = 100
	grey_overlay.AnchorPoint = Vector2.new(0.5, 0.5)
	grey_overlay.Position = UDim2.fromScale(0.5, 0.5)
	grey_overlay.Size = UDim2.new(1, 16, 1, 16)
	grey_overlay.Transparency = 1
	if price then
		local pricelabel = textlabel(`{price} {utf8.char(0xE002)}`, asset_button, true)
		pricelabel.AnchorPoint = Vector2.new(0, 1)
		pricelabel.Size = UDim2.new()
		pricelabel.Position = UDim2.fromScale(0, 1)
	end

	if not on_click then
		local function set_add_remove_id_state()
			lune.theme_manager:force_highlight(asset_button, singletons.humanoid_description:id_equipped(asset_id))
		end

		local function id_changed_event(id: number)
			if id ~= asset_id then
				return
			end
			set_add_remove_id_state()
		end

		local humanoid_changed = singletons.humanoid_description.humanoid_changed.Event:Connect(set_add_remove_id_state)
		local id_added_event = singletons.humanoid_description.id_added.Event:Connect(id_changed_event)
		local id_remove_event = singletons.humanoid_description.id_removed.Event:Connect(id_changed_event)
		local able_to_use_button = singletons.humanoid_description.id_operations_ready_event.Event:Connect(
			function(ready)
				lune.utils.spr.stop(grey_overlay)
				lune.utils.spr.target(grey_overlay, 1, 1.5, {
					Transparency = not ready and 0.2 or 1,
				})
			end
		)

		lune.theme_manager:force_highlight(asset_button, singletons.humanoid_description:id_equipped(asset_id))
		asset_button.Destroying:Connect(function(...)
			able_to_use_button:Disconnect()
			id_added_event:Disconnect()
			humanoid_changed:Disconnect()
			id_remove_event:Disconnect()
		end)
	end
	asset_button.Size = container_udim
	return asset_button
end
