local shared = require("../shared")
local lune = require("../ui/components/lune_ui")
if shared.settings.show_crash_log_consent.value then
	lune.window.option({
		title = "Automated Error Reporting Update",
		prompt_text = "hey!\n\navatarboom will now automatically send errors, so that bugs can be quickly fixed.\n\nyou can disable it at any time in the settings menu.",
		options = { "Okay" },
		on_prompt_result = function()
			shared.settings.show_crash_log_consent.set(false)
		end,
		important = true,
	})
end
return nil
