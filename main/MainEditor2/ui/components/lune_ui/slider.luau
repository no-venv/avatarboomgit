local textbutton = require(script.Parent.textbutton)
local theme_manager = require(script.Parent.theme_manager)
local styling = require(script.Parent.styling_components)
local utils = require(script.Parent.utils)
type SliderImpl = {
	set : (value : number) -> void;
	reset : () -> void;
}
return function(default_value :number,parent : Instance?,update_func: (value : number) -> void) : (TextButton,SliderImpl)
	local button = textbutton("",parent)
	button.Size = UDim2.new(0,128,0,32)
	local progress_background = Instance.new("Frame")
	progress_background.AnchorPoint = Vector2.new(0,0.5)
	progress_background.Position = UDim2.new(0,0,0.5,0)
	progress_background.Size = UDim2.new(1,0,0.5,0)
	progress_background.Parent = button
	styling.corner(progress_background)
	styling.stroke(progress_background)
	do
		local padding = styling.padding(progress_background)
		padding.PaddingBottom = UDim.new()
		padding.PaddingLeft = UDim.new()
		padding.PaddingTop = UDim.new()
	end
	do
		local ui_list = Instance.new("UIListLayout")
		ui_list.FillDirection = Enum.FillDirection.Horizontal
		ui_list.SortOrder = Enum.SortOrder.LayoutOrder
		ui_list.VerticalAlignment = Enum.VerticalAlignment.Center
		ui_list.VerticalFlex = Enum.UIFlexAlignment.Fill
		ui_list.Parent = progress_background
	end
	theme_manager:add_custom_gui_instance(progress_background,"Background")
	--
	local progress_background_complete = Instance.new("Frame")
	progress_background_complete.AnchorPoint = Vector2.new(0,0.5)
	progress_background_complete.Size =  UDim2.new(0,0,0.5,0)
	progress_background_complete.Parent = progress_background
	styling.corner(progress_background_complete)
	styling.stroke(progress_background_complete)
	theme_manager:add_custom_gui_instance(progress_background_complete,"Foreground")
	theme_manager:add_highlight(progress_background_complete)
	theme_manager:force_highlight(progress_background_complete,true)
	--
	local progress_slider = Instance.new("Frame")
	progress_slider.Parent = progress_background
	local aspect_1 = Instance.new("UIAspectRatioConstraint")
	aspect_1.AspectRatio = 1
	aspect_1.Parent = progress_slider
	styling.corner(progress_slider).CornerRadius = UDim.new(0,64)
	styling.stroke(progress_slider)
	theme_manager:add_custom_gui_instance(progress_slider,"Foreground")
	--
	local should_update = false
	local function update(x : number)
		progress_background_complete.Size = UDim2.new(x,0,0.5,0)
		update_func(x)
	end
	button.InputBegan:Connect(function(input: InputObject) 
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			should_update = true
			local release_event
			release_event = input.Changed:Connect(function(property: string) 
				if input.UserInputState == Enum.UserInputState.End then
					should_update = false
					release_event:Disconnect()
				end
			end)
		end
	end)

	local mutex = false
	button.InputChanged:Connect(function(input: InputObject) 
		if not should_update or mutex then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			mutex = true
			local release_event
			release_event = input.Changed:Connect(function(property: string) 
				if not should_update then
					release_event:Disconnect()
					mutex = false
				end
				
				local x,y = input.Position.X,input.Position.Y
				local x = utils.normalize_mouse(
					Vector2.new(x,y),
					progress_background.AbsolutePosition,
					progress_background.AbsoluteSize
				).X
				if should_update then
					update(x)
				end
			end)
		end
	end)
	
	update(default_value)
	return button,{
		reset = function()
			update(default_value)
		end,
		set = function(value)
			update(value)
		end,
	}
end