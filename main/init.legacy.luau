local toolbar = plugin:CreateToolbar("avatarBOOM")
local pluginButton = toolbar:CreateButton(
	"avatarBOOM", --Text that will appear below button
	"open avatarBOOM",
	"rbxassetid://138362735192748"
) --Button icon
local widget_info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, false, false, 400, 255, 400, 255)
local widget = plugin:CreateDockWidgetPluginGuiAsync("avatarBOOM editor", widget_info)
widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pluginButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)
require("./main/MainEditor2")(widget, plugin, widget)
