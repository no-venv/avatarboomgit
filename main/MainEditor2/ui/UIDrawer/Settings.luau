--!strict
local lune = require("../components/lune_ui")
local settings = require("../../shared/settings")
return function(parent: Instance?)
	local container = lune.empty_frame()
	container.Name = "Settings"
	local scrolling_container = lune.scrolling_frame(container, "List")
	for key, setting in settings :: settings.SettingsGeneric do
		-- some setting
		if setting.hidden then
			continue
		end
		local setting_container = lune.empty_frame(scrolling_container)
		setting_container.Size = UDim2.fromScale(1, 0)
		setting_container.AutomaticSize = Enum.AutomaticSize.Y

		local split_text = key:split("_")
		for index, text in split_text do
			split_text[index] = `{text:sub(1, 1):upper()}{text:sub(2, #text)}`
		end

		local vbox = lune.styling.vbox(setting_container)
		vbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
		vbox.HorizontalFlex = Enum.UIFlexAlignment.Fill
		lune.collasped_view(table.concat(split_text, " "), setting_container, container)
		lune.textlabel(setting.description, setting_container)
		if setting.value_options then
			-- usually this is a table.
			local _, func = lune.option_buttons(setting_container, setting.value_options, function(value: string) end)
			setting.changed.connect(function(parm)
				func.set(parm.value)
			end)
			func.set(setting.value)
			continue
		end

		local setting_type = type(setting.default_value)
		if setting_type == "boolean" then
			local button = lune.textbutton("", setting_container, function()
				setting.set(not setting.value, true)
			end)
			local function change_state(boolean)
				button.Text = setting.value and "On" or "Off"
				lune.theme_manager:force_highlight(button, boolean)
			end

			setting.changed.connect(function(parm)
				change_state(parm.value)
			end)
			change_state(setting.value)
		end
	end
	return container
end
