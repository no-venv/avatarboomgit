--!strict
local components = require("../components")
local singletons = require("../../singletons")
local asset_button = components.asset_button
local asset_button_header = components.asset_button_header
local lune = components.lune_ui
local empty_frame = lune.empty_frame
local scrolling_frame = lune.scrolling_frame
local styling = lune.styling
local event_bus = singletons.event_bus
local humanoid_editor = singletons.humanoid_description

return function(parent: Instance?)
	local container = empty_frame(parent)
	local current_view_wearing: ScrollingFrame? = nil
	local is_enabled = true
	local function update()
		if not humanoid_editor:is_init() then
			return
		end
		local view_wearing_instance = scrolling_frame(container, "Grid")
		styling.padding(view_wearing_instance).PaddingTop = UDim.new(0, 50)
		view_wearing_instance.Name = "ViewWearing"

		if current_view_wearing then
			current_view_wearing:Destroy()
		end
		current_view_wearing = view_wearing_instance

		local wearing_ids = singletons.wearing_cache.get_wearing()

		for _, asset in wearing_ids do
			local button = asset_button({
				asset = asset,
				parent = view_wearing_instance,
				on_click = function()
					event_bus.avatar_item_selected.emit({
						asset_info = asset,
					})
				end,
			})
			asset_button_header(asset, { ["Favourite"] = true, ["Remove"] = true }, button)
		end

		return
	end

	humanoid_editor.humanoid_changed.Event:Connect(update)
	humanoid_editor.id_added.Event:Connect(update)
	humanoid_editor.id_removed.Event:Connect(update)
	event_bus.catalog_show_overlay.connect(function(parm)
		is_enabled = parm.overlay == "Wearing"
		container.Visible = is_enabled
	end)
	-- tbh,just update in the background for more responsiveness
	container.Visible = false
	update()
	return container
end
