local catalog_fetcher = require("../../../../singletons/CatalogFetcher")
local animation_types = require("../animation")
local components = require("../../../components")
local lune = components.lune_ui
local asset_button = components.asset_button
local asset_button_header = components.asset_button_header
return function(parent: Instance?, animation: animation_types.AnimationObject)
	local container = lune.empty_frame(parent)
	container.Name = "Animations Catalog"
	do
		local vbox = lune.styling.vbox(container)
		vbox.VerticalFlex = Enum.UIFlexAlignment.Fill
	end
	local search = lune.textbox("Search for animations", container)
	search.Size = UDim2.new(1, 0, 0, 32)
	lune.styling.sizeconst(search, Vector2.zero, Vector2.new(math.huge, 32))
	local current_scrolling: ScrollingFrame?
	
	local function generate()
		if current_scrolling then
			current_scrolling:Destroy()
		end
		local search_params = CatalogSearchParams.new()
		search_params.AssetTypes = { Enum.AvatarAssetType.EmoteAnimation }
		task.spawn(function()
			local search_results = catalog_fetcher:Search(search.Text, search_params)
			local scrolling_container = lune.scrolling_frame(container, "Grid", nil, function(root): boolean
				local asset_array = search_results:Next()
				if not asset_array then
					return false
				end
				for _, animation_asset in asset_array do
					local generated_button = asset_button({
						asset = animation_asset,
						parent = root,
						on_click = function()
							-- add to keyframe, or listen to drag and drops
							animation.add_animation_clip(1, nil, animation_asset.Id)
						end,
					})

					asset_button_header(
						animation_asset.AssetType,
						{ Favourite = true },
						generated_button,
						function(): boolean
							-- show popup to save to board
							local window
							local picker = components.pinboard_picker({
								on_picked_pinboard = function(picked)
									window:Destroy()
								end,
								internal_prefix = "Animation",
							})
							window = lune.window.base({
								title = "Save Emote",
								size = Vector2.new(0.9, 0.9),
								view = picker,
								custom_embed = container,
								important = true,
							})
							return false
						end
					)
				end

				return true
			end)
			current_scrolling = scrolling_container
		end)

		return
	end
	generate()
	return container
end
