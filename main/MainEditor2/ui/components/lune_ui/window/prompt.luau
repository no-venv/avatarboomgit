local base = require("./base")
local empty_frame = require("../empty_frame")
local textbox = require("../textbox")
local textbutton = require("../textbutton")
local textlabel = require("../textlabel")
local styling = require("../styling_components")
type PromptArgument = {
	prompt_hint_text: string,
	prompt_close_text: string,
	verify_prompt_failure_text: string?,
	on_verify_prompt: ((result: string) -> boolean)?,
	on_prompt_result: (result: string) -> nil,
} & base.BaseWindowArguments
return function(arg: PromptArgument)
	local window
	local container = empty_frame()
	local vbox = styling.vbox(container)
	vbox.VerticalAlignment = Enum.VerticalAlignment.Center
	vbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local pinboard_name_textbox = textbox(arg.prompt_hint_text, container)
	local prompt_close_textbutton
	if arg.on_verify_prompt and arg.verify_prompt_failure_text then
		local prompt_error = textlabel(arg.verify_prompt_failure_text, container)
		prompt_error.Visible = false
		pinboard_name_textbox:GetPropertyChangedSignal("Text"):Connect(function(...)
			prompt_error.Visible = not arg.on_verify_prompt(pinboard_name_textbox.Text)
			prompt_close_textbutton.Visible = arg.on_verify_prompt(pinboard_name_textbox.Text)
		end)
	end
	prompt_close_textbutton = textbutton(arg.prompt_close_text, container, function(...)
		arg.on_prompt_result(pinboard_name_textbox.Text)
		window:Destroy()
	end)
	arg.view = container
	window = base(arg)
	return window
end
