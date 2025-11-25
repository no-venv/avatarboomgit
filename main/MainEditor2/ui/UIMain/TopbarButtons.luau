local UI = script:FindFirstAncestor("MainEditor2")
local singletons = require(UI.singletons)
local components = require(UI.ui.components)
local lune = components.lune_ui
local empty_frame = lune.empty_frame
local styling = lune.styling
local theme_manager = lune.theme_manager
local iconbutton = lune.iconbutton
local textbutton = lune.textbutton
local floating_menu = lune.float_menu
local textbox = lune.textbox
local utils = require(UI.utils)
local function state()
	local first = false
	local consumed : string = nil
	return function(state : string)
		if consumed ~= state then
			consumed = state
			first = false
		end
		if not consumed then
			return "None"
		end
		first = not first
		return first and consumed or "None"
	end
end
--
local container = empty_frame()
container.Size = UDim2.new(1,0,0,48)
container.BackgroundTransparency =0
container.ZIndex = 10
do
	local gradient_background = Instance.new("UIGradient")
	gradient_background.Rotation = 90
	gradient_background.Transparency = NumberSequence.new(
		{
			NumberSequenceKeypoint.new(0,0);
			NumberSequenceKeypoint.new(0.8,1);
			NumberSequenceKeypoint.new(1,1)
		}
	)
	gradient_background.Parent = container
	theme_manager:add_custom_gui_instance(gradient_background,"Foreground")
	styling.corner(container)
	styling.padding(container)
	local flex = Instance.new("UIListLayout")
	flex.HorizontalFlex = Enum.UIFlexAlignment.Fill
	flex.SortOrder = Enum.SortOrder.LayoutOrder
	flex.FillDirection = Enum.FillDirection.Horizontal
	flex.Parent = container
end

local button_container_layout = Instance.new("UIListLayout")
button_container_layout.Padding = UDim.new(0,8)
button_container_layout.FillDirection = Enum.FillDirection.Horizontal
button_container_layout.SortOrder = Enum.SortOrder.LayoutOrder
local button_container = empty_frame()
button_container.Size = UDim2.new(.5,0,1,0)
--
return function(parent : Instance?)
	local state = state()
	local dropdown_state = false
	local topbar_container = container:Clone()
	local left_button_container = button_container:Clone()
	left_button_container.Parent = topbar_container
	local search = textbox("search or paste ID here",topbar_container)
	search.Size = UDim2.new(1,0,1,0)
	search.ClearTextOnFocus = false
	search.FocusLost:Connect(function(enterPressed: boolean, inputThatCausedFocusLoss: InputObject) 
		if not enterPressed then
			return
		end	
		local query = search.Text

		singletons.event_bus.catalog_search.emit({
			query = query
		})
	end)
	do
		--local size_const = Instance.new("UISizeConstraint")
		--size_const.MinSize = Vector2.new(200,0)
		--size_const.MaxSize = Vector2.new(200,math.huge)
		--size_const.Parent = search
	end

	local right_button_container = button_container:Clone()
	right_button_container.Parent = topbar_container
	do
		local left_layout = button_container_layout:Clone()
		left_layout.Parent = left_button_container
		local right_layout = button_container_layout:Clone()
		right_layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		right_layout.Parent = right_button_container
	end
	local dropdown_button = iconbutton {
		id = 134883261664446;
		parent = left_button_container;
		theme_enabled = true;
		on_click = function()
			dropdown_state = not dropdown_state
			singletons.event_bus.drawer_open.emit({
				bool = dropdown_state
			})
		end,
	}
	
	--local save_progress : TextButton
	--local save_menu : Frame
	--save_progress = iconbutton {
	--	id = 94356110802200;
	--	parent = left_button_container;
	--	theme_enabled = true;
	--	on_click = function()
	--		if save_menu then
	--			save_menu:Destroy()
	--			return
	--		end
	--		local pos = save_progress.AbsolutePosition
	--		save_menu = floating_menu(170,pos.X - 8,pos.Y,function() 
	--			textbutton("View Saved Progress",nil,function() 

	--			end)	
	--			textbutton("Save Progress",nil,function()

	--			end)
	--		end)
	--	end,
	--}
	--94356110802200
	local favourites_button = iconbutton {
		id = 106335234167054;
		parent = right_button_container;
		theme_enabled = true;
		on_click = function()
			singletons.event_bus.catalog_show_overlay.emit({
				overlay = state("Favourites")
			})
		end,
	}
	local wearing_button = iconbutton {
		id = 112085719237258;
		parent = right_button_container;
		theme_enabled = true;
		on_click = function()
			singletons.event_bus.catalog_show_overlay.emit({
				overlay = state("Wearing")
			})
		end,
	}
	singletons.event_bus.drawer_open.connect(function(parm): nil 
		if not parm.bool then
			dropdown_state = false
		end
		
		theme_manager:force_highlight(dropdown_button,parm.bool)
		--ui_lib.theme_manager:force_highlight(topbar.LeftButtons.Dropdown,parm.bool)
		return
	end)
	singletons.event_bus.avatar_item_selected.connect(function(parm): nil 
		theme_manager:force_highlight(dropdown_button,false)
		--ui_lib.theme_manager:force_highlight(topbar.LeftButtons.Dropdown,false)
		dropdown_state = false
		return		
	end)
	
	singletons.event_bus.catalog_show_overlay.connect(function(parm): nil 
		theme_manager:force_highlight(favourites_button,parm.overlay=="Favourites")
		theme_manager:force_highlight(wearing_button,parm.overlay=="Wearing")
		--ui_lib.theme_manager:force_highlight(topbar.RightButtons.Favourites,parm.overlay=="Favourites")
		--ui_lib.theme_manager:force_highlight(topbar.RightButtons.ViewWearing,parm.overlay=="Wearing")
		if parm.overlay == "None" then
			state("None")
		end
		return
	end)
	
	topbar_container.Parent = parent
	return container
end