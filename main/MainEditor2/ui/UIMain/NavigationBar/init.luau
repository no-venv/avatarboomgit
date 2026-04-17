local lune = require("../components/lune_ui")
local singletons = require("../../singletons")
export type NavigationViews = {
	{
		icon: number,
		tooltip: string,
		overlay: string?,
		custom: (() -> ())?,
	}
}

return function(parent: Instance, views: NavigationViews)
	local container = lune.empty_frame(parent)
	container.AnchorPoint = Vector2.new(0, 1)
	container.Position = UDim2.fromScale(0, 1)
	container.Size = UDim2.new(1, 0, 0, 48)
	lune.styling.padding(container)
	-- container.ZIndex = -1
	local hbox = lune.styling.hbox(container)
	hbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
	hbox.VerticalAlignment = Enum.VerticalAlignment.Center
	hbox.HorizontalFlex = Enum.UIFlexAlignment.Fill
	for _, view in views do
		-- local button = navigation_button(container, view.icon, view.tooltip)
		local button = lune.iconbutton({
			parent = container,
			id = view.icon,
			theme_enabled = true,
			aspect_ratio = false,
			on_click = function()
				if view.custom then
					view.custom()
					return
				end
				singletons.event_bus.catalog_show_overlay.emit({ overlay = view.overlay })
			end,
		})
		lune.tooltips(button, view.tooltip)
		button.Size = UDim2.fromScale(1, 1)
		singletons.event_bus.catalog_show_overlay.connect(function(parm)
			lune.theme_manager:force_highlight(button, parm.overlay == view.overlay)
		end)
		local stroke = button:FindFirstAncestorOfClass("UIStroke")
		if stroke then
			stroke.Enabled = false
		end
	end
	return container
end
