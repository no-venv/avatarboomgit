local components = require("../components")
local singletons = require("../../singletons")
local plugin_fs = singletons.plugin_fs
local lune = components.lune_ui
local colour_wheel = components.colour_wheel
local ui_themes = lune.theme_manager.themes
local tab = lune.tab
local empty_frame = lune.empty_frame
local scrolling_frame = lune.scrolling_frame
local option_buttons = lune.option_buttons
local textbox = lune.textbox
local textbutton = lune.textbutton
local styling = lune.styling

return function(parent: Instance?)
	local current_theme = lune.theme_manager.current_theme
	local container = empty_frame(parent)
	container.Name = "Set Theme"
	local preset_themes = scrolling_frame(nil, nil, { HorizontalFlex = Enum.UIFlexAlignment.Fill })
	preset_themes.Name = "Preset Themes"
	for _, theme: ModuleScript in ui_themes:GetChildren() do
		if theme:IsA("ModuleScript") then
			lune.textbutton(theme.Name, preset_themes, function(): nil
				current_theme = theme
				lune.theme_manager:set_theme(theme)
				plugin_fs.save("Theme", theme.Name)
				return
			end)
		end
	end
	--
	local custom_theme = empty_frame()
	custom_theme.Name = "Custom Theme"
	do
		local vbox = styling.vbox(custom_theme)
		vbox.HorizontalFlex = Enum.UIFlexAlignment.Fill
		vbox.VerticalFlex = Enum.UIFlexAlignment.Fill
	end

	local theme_keys: { string } = {}
	for key, _ in lune.theme_manager.base_theme do
		table.insert(theme_keys, key)
	end

	local applied_custom_theme = lune.theme_manager:get_base_theme()
	local current_custom_theme_key = ""
	local save_custom_theme_mutex = false

	local picker = colour_wheel(custom_theme)
	local hex_input = textbox("", custom_theme)
	hex_input.ClearTextOnFocus = false
	local reset = textbutton("Reset Custom Theme", custom_theme, function()
		applied_custom_theme = lune.theme_manager:get_base_theme()
		picker.set_colour(applied_custom_theme[current_custom_theme_key])
		return
	end)

	styling.sizeconst(hex_input, Vector2.new(0, 32), Vector2.new(math.huge, 32))
	styling.sizeconst(reset, Vector2.new(0, 32), Vector2.new(math.huge, 32))

	hex_input.FocusLost:Connect(function(enterPressed: boolean, inputThatCausedFocusLoss: InputObject)
		if enterPressed then
			local colour = Color3.fromHex(hex_input.Text)
			picker.set_colour(colour)
		end
	end)
	picker.on_colour = function(colour)
		applied_custom_theme[current_custom_theme_key] = colour
		lune.theme_manager:set_theme(applied_custom_theme)
		hex_input.Text = colour:ToHex()
		if save_custom_theme_mutex then
			return
		end
		save_custom_theme_mutex = true
		task.delay(1, function()
			local saved = {}
			for key, value in applied_custom_theme do
				saved[key] = value:ToHex()
			end
			plugin_fs.save("CustomTheme", saved)
			save_custom_theme_mutex = false
		end)
	end

	local _, custom_theme_buttons = option_buttons(custom_theme, theme_keys, function(value: string): nil
		current_custom_theme_key = value
		picker.set_colour(applied_custom_theme[value])
		return
	end)

	custom_theme_buttons.set(theme_keys[1])
	current_custom_theme_key = theme_keys[1]

	local _, _, tab_func = tab({ preset_themes, custom_theme }, "Preset Themes", container)
	tab_func.on_view_change = function(view)
		local is_preset = view == "Preset Themes" and "Preset" or "Custom"
		if is_preset == "Preset" then
			lune.theme_manager:set_theme(current_theme)
		else
			lune.theme_manager:set_theme(applied_custom_theme)
		end
		plugin_fs.save("ThemeType", is_preset)
	end

	singletons.event_bus.avatar_boom_post_init.connect(function(parm: {}): nil
		local saved_theme = plugin_fs.get("Theme")
		local custom_theme = plugin_fs.get("CustomTheme")
		local type_of_theme = plugin_fs.get("ThemeType")
		type_of_theme = type_of_theme or "Preset"
		if type_of_theme == "Custom" and custom_theme then
			for key, value in custom_theme do
				applied_custom_theme[key] = Color3.fromHex(value)
			end
			picker.set_colour(applied_custom_theme[current_custom_theme_key])
			tab_func.toggle("Custom Theme")
			return
		end
		if saved_theme then
			current_theme = ui_themes:FindFirstChild(saved_theme)
			lune.theme_manager:set_theme(current_theme)
		else
			lune.theme_manager:set_theme(ui_themes.Light)
		end
		return
	end)
	return container
end
