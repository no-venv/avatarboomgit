--!strict
local singletons = require("../../singletons")
local components = require("../components")
local utils = require("../../utils")
local catalog_fetcher = singletons.catalog_fetcher
local event_bus = singletons.event_bus
local asset_button = components.asset_button
local asset_button_header = components.asset_button_header
local ui_lib = components.lune_ui
local styling = ui_lib.styling
local textlabel = ui_lib.textlabel
local textbutton = ui_lib.textbutton
local empty_frame = ui_lib.empty_frame
local humanoid_editor = singletons.humanoid_description

local function build_asset_info_container(parent: Instance?, parm: typeof(catalog_fetcher.ExportAssetType))
	local asset_info_container = empty_frame()
	asset_info_container.Size = UDim2.new(1, 0, 0, 0)
	asset_info_container.AutomaticSize = Enum.AutomaticSize.Y
	-- centered vert layout
	local vert_layout = Instance.new("UIListLayout")
	vert_layout.SortOrder = Enum.SortOrder.LayoutOrder
	vert_layout.Padding = UDim.new(0, 8)
	vert_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	vert_layout.Parent = asset_info_container

	local asset_button = components.lune_ui.iconbutton({
		parent = asset_info_container,
		id = utils.generate_asset_thumb({ parm }),
		on_click = function() end,
	})

	asset_button.Size = UDim2.new(0, 135, 0, 135)
	asset_button_header(parm, { ["Favourite"] = true }, asset_button)
	ui_lib.property_scope({
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 0),
	}, function()
		textlabel(`<b>{parm.Name}</b>`, asset_info_container).TextSize = 24
		textlabel(parm.CreatorName, asset_info_container).TextSize = 20
		return
	end)

	local item_equipped = false
	local insert_asset_button: TextButton
	local function update_equipped_state()
		if not humanoid_editor:is_init() then
			return
		end
		item_equipped = humanoid_editor:is_init() and humanoid_editor:id_equipped(parm.Id) or false
		insert_asset_button.Text = item_equipped and "Take off" or "Try on"
	end

	ui_lib.property_scope({
		Size = UDim2.new(1, 0, 0, 32),
	}, function()
		insert_asset_button = textbutton("Put on", asset_info_container, function()
			local item_type = parm.ItemType
			local asset_type = parm.AssetType
			local asset_id = parm.Id
			if item_equipped then
				if item_type == "Asset" then
					humanoid_editor:remove_id(asset_id)
				else
					humanoid_editor:remove_bundle_id(asset_id)
				end
			else
				if item_type == "Asset" then
					humanoid_editor:add_id(asset_id, Enum.AvatarAssetType:FromName(asset_type))
				else
					humanoid_editor:add_bundle_id(asset_id)
				end
			end
			update_equipped_state()
		end)

		local asset_type
		if parm.AssetType then
			asset_type = Enum.AvatarAssetType:FromName(parm.AssetType)
		end
		textbutton(`Set filter to {parm.CreatorName}`, asset_info_container, function()
			if asset_type then
				event_bus.catalog_set_search_filter.emit({
					CreatorName = parm.CreatorName,
					AssetTypes = { asset_type },
				})
			else
				event_bus.catalog_set_search_filter.emit({
					CreatorName = parm.CreatorName,
				})
			end
			event_bus.drawer_open.emit({
				bool = false,
			})
		end)
		return
	end)

	local id_added_signal = humanoid_editor.id_added.Event:Connect(update_equipped_state)
	local id_remove_signal = humanoid_editor.id_removed.Event:Connect(update_equipped_state)
	local humanoid_change_signal = humanoid_editor.humanoid_changed.Event:Connect(update_equipped_state)

	asset_info_container.Destroying:Once(function()
		id_added_signal:Disconnect()
		id_remove_signal:Disconnect()
		humanoid_change_signal:Disconnect()
	end)

	update_equipped_state()
	asset_info_container.Parent = parent
	return asset_info_container
end

local function build_recommended_container(parent: Instance?, asset: typeof(catalog_fetcher.ExportAssetType))
	local container = empty_frame()
	container.Size = UDim2.new(1, 0, 0, 0)
	container.AutomaticSize = Enum.AutomaticSize.Y
	styling.grid(container)
	container.Parent = parent
	task.spawn(function()
		local recommended = asset.ItemType == "Asset"
				and catalog_fetcher:GetRecommendedAssets(asset.Id, Enum.AvatarAssetType:FromName(asset.AssetType))
			or catalog_fetcher:GetRecommendedBundles(asset.Id)

		if not recommended then
			return
		end

		for _, asset in recommended do
			if not container.Parent then
				break
			end
			local button = asset_button({
				asset = asset,
				parent = container,
				on_click = function()
					event_bus.avatar_item_selected.emit({ asset_info = asset })
				end,
			})
			asset_button_header(asset, { ["Favourite"] = true }, button)
			button.Parent = container
		end
	end)
	return container
end

return function(parent: Instance?)
	local container = ui_lib.scrolling_frame(parent, "List")
	container.Name = "View Asset"
	local asset_info_container: Frame? = nil
	local recommended_container: Frame? = nil
	event_bus.avatar_item_selected.connect(function(parm)
		if asset_info_container then
			asset_info_container:Destroy()
		end
		if recommended_container then
			recommended_container:Destroy()
		end
		asset_info_container = build_asset_info_container(container, parm.asset_info)
		recommended_container = build_recommended_container(container, parm.asset_info)
		return
	end)

	container.Parent = parent
	return container
end
