local toolbar = plugin:CreateToolbar("avatarBOOM")
local widget_info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, false, false, 400, 255, 400, 255)
local widget = plugin:CreateDockWidgetPluginGuiAsync("avatarBOOM editor", widget_info)
widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local pluginButton = toolbar:CreateButton(
	"open avatarBOOM", --Text that will appear below button
	"avatarBoom",
	"rbxassetid://138362735192748"
) --Button icon
pluginButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)
require("./main/MainEditor2")(widget, plugin, widget)
