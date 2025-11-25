-- Intended for cloning frames when an event happens
local lune = require(script.Parent.lune_ui)
local TweenService = game:GetService("TweenService")
local empty_frame = lune.empty_frame
local textlabel = lune.textlabel
local textbutton = lune.textbutton
local anchor_point = Vector2.new(0.5,0.5)
local centre = UDim2.new(0.5,0,0.5,0)
return {
	error = function(parent : Instance?, func)
		local container = lune.empty_frame()
		container.AnchorPoint = anchor_point
		container.Position = centre
		container.Size = UDim2.new(0.5,0,0.5,0)
		do
			local list_layout = Instance.new("UIListLayout")
			list_layout.Padding = UDim.new(0,12)
			list_layout.SortOrder = Enum.SortOrder.LayoutOrder
			list_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			list_layout.VerticalAlignment= Enum.VerticalAlignment.Center
			list_layout.Parent = container
		end
		local error_image = Instance.new("ImageLabel")
		error_image.ImageContent = Content.fromAssetId(10967199105)
		error_image.BackgroundTransparency = 1
		error_image.Size = UDim2.new(1,0,1,0)
		do
			local aspect = Instance.new("UIAspectRatioConstraint")
			aspect.AspectRatio = 1
			aspect.Parent = error_image
		end
		error_image.Parent = container
		textlabel("oops! something went wrong!",container)
		textbutton("try again",container,function() 
			container:Destroy()
			func()
		end)
		container.Parent = parent
		return container
	end,
	spinner = function(parent : Instance?)
		local spinner = Instance.new("ImageLabel")
		spinner.BackgroundTransparency = 1
		spinner.AnchorPoint = anchor_point
		spinner.Position = centre
		spinner.Size = UDim2.new(0,100,0,100)
		spinner.ImageContent = Content.fromAssetId(4463059046)
		spinner.ImageTransparency = 0.5
		spinner.Parent = parent
		lune.theme_manager:add_custom_gui_instance(spinner,"Background")
		return spinner
	end,
}
