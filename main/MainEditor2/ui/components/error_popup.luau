--!strict
local lune = require("./lune_ui")
local report_bugs_text =
	`Please report this bug to https://devforum.roblox.com/t/avatarboom-create-avatars-in-roblox-studio/4083842/`
return function(error: string)
	local window
	local container = lune.scrolling_frame(nil, "List", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
	})

	lune.textlabel(error, container)
	local link = lune.textbox("placeholder", container)
	link.ClearTextOnFocus = false
	link.Text = report_bugs_text
	link.AutomaticSize = Enum.AutomaticSize.Y

	lune.textbutton("Okay", container, function(...)
		window:Destroy()
	end)
	window = lune.window.base({
		size = Vector2.new(0.8, 0.6),
		title = "An error has occurred",
		view = container,
		important = true,
	})
end
