local toolbar = plugin:CreateToolbar("avatarBOOM")
local widget_info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, true, false, 400, 700, 400, 700)
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

local warn_container = Instance.new("Frame")
warn_container.BackgroundColor3 = Color3.new(1, 1, 1)
warn_container.Size = UDim2.fromScale(1, 1)
local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingRight = pad.PaddingTop
pad.PaddingLeft = pad.PaddingTop
pad.PaddingBottom = pad.PaddingTop
pad.Parent = warn_container
local vbox = Instance.new("UIListLayout")
vbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
vbox.VerticalFlex = Enum.UIFlexAlignment.Fill
vbox.VerticalAlignment = Enum.VerticalAlignment.Center
vbox.SortOrder = Enum.SortOrder.LayoutOrder
vbox.Padding = UDim.new(0, 8)
vbox.Parent = warn_container
local warn_text = Instance.new("TextLabel")
warn_text.AutomaticSize = Enum.AutomaticSize.Y
warn_text.Size = UDim2.fromScale(1, 0)
warn_text.TextWrapped = false
warn_text.BackgroundTransparency = 1
warn_text.BorderSizePixel = 0
warn_text.Size = UDim2.new(1,0,0,128)
warn_text.Text =
	"If you're seeing this, avatarBoom is either loading, or couldn't start because the script injection permission has been denied.\nFollow the instructions below to fix the issue."
warn_text.TextColor3 = Color3.new()
warn_text.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Regular)
warn_text.TextSize = 24
warn_text.TextWrapped = true
warn_text.Parent = warn_container
local instructions_image = Instance.new("ImageLabel")
instructions_image.BorderSizePixel = 0
instructions_image.ImageContent = Content.fromAssetId(74545950302223)
instructions_image.Parent = warn_container
instructions_image.Size = UDim2.fromScale(1, 1)
local aspect = Instance.new("UIAspectRatioConstraint")
aspect.AspectRatio = 0.8
aspect.Parent = instructions_image
warn_container.Parent = widget
warn_container.ZIndex = -1999
require("./main/MainEditor2")(widget, plugin, widget)
warn_container.Visible = false
