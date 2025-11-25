local toolbar = plugin:CreateToolbar("avatarBOOM")
local init = false
local widget_info = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right,
	false,
	false,
	400,
	255,
	400,
	255
)

local widget = plugin:CreateDockWidgetPluginGui(
	"avatarBOOM editor",
	widget_info
)
widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local pluginButton = toolbar:CreateButton(
	"open avatarBOOM", --Text that will appear below button
	"avatarBoom",
	"rbxassetid://138362735192748"
) --Button icon
require("./main/MainEditor2")(widget,plugin,widget)
pluginButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled 
end)
