--!strict
local lune = require("../components/lune_ui")
local event_bus = require("../../singletons/event_bus")
local animator = require("@self/animator_view")
local shared = require("../../shared")
local home = require("@self/home")
return function(parent: Instance)
	local container = lune.empty_frame(parent)
	lune.styling.padding(container).PaddingTop = UDim.new(0, 50)
	local animator_container = lune.empty_frame()
	animator_container.Name = "Animator"
	local animator_view
	local _, _, tab_func
	local home_view = home(container, function(animation)
		animator_view = animator(animator_container, animation)
		tab_func.toggle("Animator", true)
		event_bus.topbar_visibility_custom_button.emit({
			button_id = "composer_back",
			show = true,
		})
	end)
	_, _, tab_func = lune.tab({ home_view, animator_container }, "Home", container)
	tab_func.hide_tab_bar(true)
	container.Visible = false
	event_bus.catalog_show_overlay.connect(function(parm)
		container.Visible = parm.overlay == "Composer"
	end)
	event_bus.topbar_register_custom_button.emit({
		allowed_overlay = "Composer",
		button_id = "composer_back",
		image = shared.icons.back,
		-- one_shot_visibility = true,
		on_click = function()
			lune.window.option({
				title = "Comfirm",
				size = Vector2.new(0.9, 0.4),
				prompt_text = "Are you sure you want to quit?",
				options = { "Yes", "No" },
				custom_embed = container,
				important = true,
				on_prompt_result = function(result)
					if result == "Yes" then
						animator_view:Destroy()
						event_bus.topbar_visibility_custom_button.emit({
							button_id = "composer_back",
							show = false,
						})
						tab_func.toggle("Home", true)
					end
				end,
			})
			return
		end,
		tooltip = "Back",
	})
	event_bus.topbar_visibility_custom_button.emit({
		button_id = "composer_back",
		show = false,
	})

	return container
end
