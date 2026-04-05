--!strict
-- view for saved animations stored in the plugin or in a file
local lune = require("../../components/lune_ui")
local button_header = require("../../components/ButtonHeader")
local shared_composer = require("../../../shared/composer")
local animation_types = require("./animation")
local function animation_list_button(parent, animation: shared_composer.ComposerSavedAnimation, on_click: () -> ())
	local trash_button: button_header.Button = {
		id = 96060799177234,
		on_click = function()
			return nil
		end,
	}
	local button = lune.textbutton("", parent, on_click)
	button_header({
		parent = button,
		left_topbar = {},
		right_topbar = { trash_button },
	})
	button.AutomaticSize = Enum.AutomaticSize.Y
	local last_opened_time = DateTime.fromUnixTimestamp(animation.last_opened_unix_time)
	local formatted_local_time = last_opened_time:FormatLocalTime("LL", "en-ca")
	local local_time = last_opened_time:ToLocalTime() :: { [any]: any }
	local animation_info_text = lune.textlabel(
		`{animation.name}\nLast opened on {formatted_local_time} at {local_time.Hour}:{local_time.Minute}`,
		button,
		true
	)
	animation_info_text.AnchorPoint = Vector2.new(0.5, 0.5)
	animation_info_text.Position = UDim2.fromScale(0.5, 0.5)
	return button
end
return function(parent: Instance, on_selected_animation: (animation: animation_types.AnimationObject) -> ())
	local outer_container = lune.empty_frame(parent)
	local container = lune.empty_frame(outer_container)
	outer_container.Name = "Home"
	do
		local vbox = lune.styling.vbox(container)
		vbox.VerticalFlex = Enum.UIFlexAlignment.Fill
	end

	local button_container = lune.empty_frame(container)
	button_container.Size = UDim2.new(1, 0, 0, 32)
	lune.styling.sizeconst(button_container, Vector2.zero, Vector2.new(math.huge, 32))
	do
		local hbox = lune.styling.hbox(button_container)
		hbox.VerticalFlex = Enum.UIFlexAlignment.Fill
		hbox.HorizontalFlex = Enum.UIFlexAlignment.Fill
	end
	lune.textbutton("Make A New Animation", button_container, function(...)
		lune.window.prompt({
			title = "Animation Name",
			size = Vector2.new(0.8, 0.2),
			custom_embed = outer_container,
			prompt_close_text = "Create Animation",
			prompt_hint_text = "",
			important = true,
			on_prompt_result = function(result)
				local animation = animation_types()
				shared_composer.save(result, animation)
				on_selected_animation(animation)
			end,
		})
	end)
	lune.textbutton("Import Animation From File", button_container, function(...) end)

	local current_scrolling_container: ScrollingFrame?

	local function generate()
		if current_scrolling_container then
			current_scrolling_container:Destroy()
		end
		current_scrolling_container = lune.scrolling_frame(container, "List", {
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		})

		for index, animation in shared_composer.get_all_animations() do
			animation_list_button(current_scrolling_container, animation, function() end)
		end
	end
	-- shared_composer.save("Moo", {})
	generate()
	-- wip
	return outer_container
end
