local shared = require("../shared")
local lune = require("../ui/components/lune_ui")
if shared.settings.show_crash_log_consent.value then
	lune.window.option({
		title = "Automated Error Reporting Update",
		prompt_text = "avatarBoom has a feature to automatically send errors so that bugs can be quickly fixed.\n\nDo you want to enable it?\n\nAt any time you can enable or disable this feature in settings.",
		options = { "Yes", "No" },
		on_prompt_result = function(result)
			if result == "Yes" then
				lune.window.option({
					title = "Accept Network Permissions",
					prompt_text = "Roblox Studio will prompt you to allow:\n\n- ask_plugin_permissions.avatarboom.qzz.io\n\n- bugs.avatarboom.qzz.io\n\n",
					options = { "Okay" },
					important = true,
					on_prompt_result = function()
						shared.settings.send_crash_logs.set(true)
						shared.settings.show_crash_log_consent.set(false)
					end,
				})
			else
				shared.settings.show_crash_log_consent.set(false)
			end
		end,
		important = true,
	})
end
return nil
