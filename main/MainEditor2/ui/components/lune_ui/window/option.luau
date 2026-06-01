local base = require("./base")
local empty_frame = require("../empty_frame")
local label = require("../textlabel")
local option_buttons = require("../option_buttons")
local styling = require("../styling_components")
type PromptArgument = {
	prompt_text: string,
	custom_view: GuiBase?,
	options: { string },
	on_prompt_result: (result: string) -> nil,
} & base.BaseWindowArguments
return function(arg: PromptArgument)
	local window
	local container = empty_frame()
	local vbox = styling.vbox(container)
	vbox.VerticalAlignment = Enum.VerticalAlignment.Center
	vbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
	vbox.VerticalFlex = Enum.UIFlexAlignment.Fill
	if arg.custom_view then
		arg.custom_view.Parent = container
	else
		label(arg.prompt_text, container)
	end
	local button_container = option_buttons(container, arg.options, function(value: string)
		window:Destroy()
		arg.on_prompt_result(value)
		return
	end)
	styling.sizeconst(button_container, Vector2.new(0,32), Vector2.new(math.huge,32))
	arg.view = container
	arg.hide_exit = true
	window = base(arg)
	return window
end
