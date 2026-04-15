local base = require("./base")
local empty_frame = require("../empty_frame")
local label = require("../textlabel")
local option_buttons = require("../option_buttons")
local styling = require("../styling_components")
type PromptArgument = {
	prompt_text: string,
	options: { string },
	on_prompt_result: (result: string) -> nil,
} & base.BaseWindowArguments
return function(arg: PromptArgument)
	local window
	local container = empty_frame()
	local vbox = styling.vbox(container)
	vbox.VerticalAlignment = Enum.VerticalAlignment.Center
	vbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
	label(arg.prompt_text, container)
	option_buttons(container, arg.options, function(value: string)
		window:Destroy()
		arg.on_prompt_result(value)
		return
	end)
	arg.view = container
	arg.hide_exit = true
	window = base(arg)
	return window
end
