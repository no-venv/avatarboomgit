local shared = require("../../shared")
local singletons = require("../../singletons")
local lune = require("@self/../lune_ui")
type arg = {
	asset: typeof(singletons.catalog_fetcher.ExportAssetType),
	parent: Instance?,
	on_click: (() -> ())?,
}

local iconbutton = lune.iconbutton
local container_udim = UDim2.new(0, 135, 0, 135)
return function(arg: arg): TextButton
	-- local price = arg.price
	local asset_id = arg.asset.Id
	local asset_type = arg.asset.ItemType
	local parent = arg.parent
	local on_click = arg.on_click
	if asset_type == "Bundle" then
		asset_type = "BundleThumbnail"
	end
	local auto_try_click = shared.settings.auto_try_on_click
	local asset_button
	asset_button = iconbutton({
		parent = parent,
		id = `rbxthumb://type={asset_type}&id={asset_id}&w=420&h=420`,
		theme_enabled = false,
		on_click = function()
			if on_click then
				on_click()
			else
				-- default function, in process of centralizing logic to reduce redundancy
				local auto_try = auto_try_click.value
				if auto_try then
					if singletons.humanoid_description:id_equipped(asset_id) then
						singletons.humanoid_description:remove_id(asset_id)
						lune.theme_manager:force_highlight(asset_button, false)
					else
						singletons.humanoid_description:add_id(asset_id)
						lune.theme_manager:force_highlight(asset_button, true)
					end
				else
					singletons.event_bus.avatar_item_selected.emit({
						asset_info = arg.asset,
					})
				end
			end
		end,
	})

	if not on_click then
		local on_setting_changed = auto_try_click.changed.connect(function(parm)
			if not parm.value then
				lune.theme_manager:force_highlight(asset_button, false)
			else
				lune.theme_manager:force_highlight(asset_button, singletons.humanoid_description:id_equipped(asset_id))
			end
		end)
		-- initially set if the id is equipped
		if auto_try_click.value then
			lune.theme_manager:force_highlight(asset_button, singletons.humanoid_description:id_equipped(asset_id))
		end
		asset_button.Destroying:Connect(function(...)
			on_setting_changed:Disconnect()
		end)
	end
	asset_button.Size = container_udim
	return asset_button
end
