-- TODO
-- merge with `AssetButton`
--!strict
-- sepeate from AssetButton and is meant to be used with it, to avoid coupling of course
-- and to avoid having to majoirly rewrite some parts of the code
export type buttons_enabled_args = {
	["Favourite"]: boolean?,
	["Remove"]: boolean?,
}
local Editor = script:FindFirstAncestor("MainEditor2")
local lune = require("@self/../lune_ui")
local shared = require("../../shared")
local singletons = require("../../singletons")
local catalog_fetcher = singletons.catalog_fetcher
local humanoid_editor = singletons.humanoid_description
local empty_frame = lune.empty_frame
local styling = lune.styling
local theme_manager = lune.theme_manager
local favourites = shared.favourites
local function set_favourite_button_state(button: ImageButton, state: boolean)
	button.Image = state and "rbxassetid://94312408803509" or "rbxassetid://106335234167054"
	return
end
local function set_remove_button_state(button: ImageButton, state: boolean)
	button.Image = state and "rbxassetid://83901176085896" or "rbxassetid://84064340071493"
end
--
local image_button = Instance.new("ImageButton")
image_button.BackgroundTransparency = 1
image_button.Size = UDim2.new(1, 0, 1, 0)
do
	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio = 1
	aspect.Parent = image_button
end
--
local button_container_temp = empty_frame()
button_container_temp.Size = UDim2.new(1, 0, 0, 24)
do
	local h_list = Instance.new("UIListLayout")
	h_list.Padding = UDim.new(0, 6)
	h_list.HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween
	h_list.FillDirection = Enum.FillDirection.Horizontal
	h_list.SortOrder = Enum.SortOrder.LayoutOrder
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 3)
	padding.PaddingRight = UDim.new(0, 3)
	padding.PaddingTop = UDim.new(0, 3)
	h_list:Clone().Parent = button_container_temp
	padding:Clone().Parent = button_container_temp
end

return function(
	asset_type: typeof(catalog_fetcher.ExportAssetType),
	enabled_buttons: buttons_enabled_args,
	parent: Instance?
)
	local container = button_container_temp:Clone()
	local favourte_button = image_button:Clone()
	local remove_button = image_button:Clone()

	favourte_button.Visible = enabled_buttons["Favourite"]
	remove_button.Visible = enabled_buttons["Remove"]
	theme_manager:add_custom_gui_instance(favourte_button, "Foreground")
	theme_manager:add_custom_gui_instance(remove_button, "Foreground")

	if enabled_buttons["Favourite"] then
		favourte_button.MouseButton1Click:Connect(function()
			local is_favourited = favourites.favourites[asset_type.Id]
			if is_favourited then
				favourites.remove_favourite(asset_type.Id)
			else
				favourites.set_favourite(asset_type.Id, asset_type)
			end
			set_favourite_button_state(favourte_button, not is_favourited)
		end)
	end

	if enabled_buttons["Remove"] then
		local function set_add_remove_id_state()
			local wearing = humanoid_editor:id_equipped(asset_type.Id)
			set_remove_button_state(remove_button, wearing)
		end
		local function id_changed_event(id: number)
			if id ~= asset_type.Id then
				return
			end
			set_add_remove_id_state()
		end
		remove_button.MouseButton1Click:Connect(function()
			if not humanoid_editor:is_init() then
				return
			end
			local wearing = humanoid_editor:id_equipped(asset_type.Id)
			if wearing then
				if asset_type.ItemType == "Asset" then
					humanoid_editor:remove_id(asset_type.Id)
				else
					humanoid_editor:remove_bundle_id(asset_type.Id)
				end
			else
				if asset_type.ItemType == "Asset" then
					humanoid_editor:add_id(asset_type.Id)
				else
					humanoid_editor:add_bundle_id(asset_type.Id)
				end
			end
			set_add_remove_id_state()
		end)

		local id_added_event = humanoid_editor.id_added.Event:Connect(id_changed_event)
		local id_remove_event = humanoid_editor.id_removed.Event:Connect(id_changed_event)
		container.Destroying:Connect(function()
			id_added_event:Disconnect()
			id_remove_event:Disconnect()
		end)
		set_add_remove_id_state()
	end
	set_favourite_button_state(favourte_button, favourites.favourites[asset_type.Id])
	favourte_button.Parent = container
	remove_button.Parent = container
	container.Parent = parent
	return container
end
