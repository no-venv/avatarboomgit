--!strict
type Arguments = {
	error: string,
	options: { string }?,
	on_option_select: (string) -> ()?,
}
local lune = require("./lune_ui")
local report_bugs_text =
	`== Please report to https://devforum.roblox.com/t/avatarboom-create-avatars-in-roblox-studio/4083842/ ==`

return function(args: Arguments)
	local container = lune.scrolling_frame(nil, "List", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
		VerticalFlex = Enum.UIFlexAlignment.SpaceBetween,
	})
	local link = lune.textbox("placeholder", container)
	link.Size = UDim2.fromScale(1, 1)
	link.ClearTextOnFocus = false
	link.TextEditable = false
	link.Text = `{report_bugs_text}\n\n{args.error}`
	link.AutomaticSize = Enum.AutomaticSize.Y

	lune.window.option({
		size = Vector2.new(0.8, 0.6),
		prompt_text = "",
		custom_view = container,
		on_prompt_result = args.on_option_select or function(result) end,
		title = "An error has occurred",
		options = args.options or { "Okay" },
		important = true,
	})
end
