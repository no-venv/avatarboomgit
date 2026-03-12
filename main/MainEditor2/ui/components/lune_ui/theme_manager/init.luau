--!strict
type void = nil
type ThemeType = {
	Background: Color3,
	Foreground: Color3,
	Hover: Color3,
}

type Struct = {
	events: {
		[GuiObject]: {
			on_highlight: { (enabled: boolean) -> () },
		},
	},
	current_theme: ThemeType,
	base_theme: ThemeType,
	_gui_highlight: {
		[Instance]: {
			mouse_hover: RBXScriptConnection,
			mouse_leave: RBXScriptConnection,
			hover_disabled: boolean,
			highlight_enabled: boolean,
		},
	},
	themes: typeof(script),
}

type Impl = {
	set_theme: (self: Themer, theme: ModuleScript | ThemeType) -> (),
	add_highlight: (self: Themer, gui_instance: GuiObject) -> (),
	force_highlight: (self: Themer, gui_instance: GuiObject, bool: boolean) -> (),
	disable_highlight_hover: (self: Themer, gui_instance: GuiObject, bool: boolean) -> (),
	show_highlight: (self: Themer, gui_instance: GuiObject, bool: boolean) -> (),
	on_highlight: (self: Themer, gui_instance: GuiObject, func: (enabled: boolean) -> ()) -> (),
	compute_gui_instance_theme: (self: Themer, gui_instance: GuiObject, colour: Color3) -> (),
	add_custom_gui_instance: (self: Themer, gui_instance: GuiObject, tag: "Foreground" | "Background") -> (),
	get_base_theme: (self: Themer) -> ThemeType,
}
export type Themer = Impl & Struct

for _, theme_module in script:GetChildren() do
	local theme = require(theme_module) :: ThemeType
	for key, value in theme do
		theme[key] = Color3.fromHex(value)
	end
end

local CollectionService = game:GetService("CollectionService")
local theme_manager = {} :: Themer
theme_manager.themes = script
theme_manager.events = {}
theme_manager.current_theme = require("@self/Light")
theme_manager.base_theme = require("@self/Light")
theme_manager._gui_highlight = {}
function theme_manager:compute_gui_instance_theme(gui_instance: GuiObject, colour: Color3)
	local TextColor = (colour.R * 0.299 + colour.G * 0.587 + colour.B * 0.114) * 255 > 186 and Color3.new()
		or Color3.new(1, 1, 1)

	pcall(function(...)
		gui_instance.BackgroundColor3 = colour
		gui_instance:SetAttribute("SetBackground", colour)
	end)

	pcall(function(...)
		gui_instance.TextColor3 = TextColor
	end)

	pcall(function(...)
		gui_instance.PlaceholderColor3 = TextColor
	end)

	pcall(function(...)
		gui_instance.ImageColor3 = TextColor
	end)

	pcall(function(...)
		gui_instance.Color = TextColor
	end)

	pcall(function(...)
		gui_instance.Color = ColorSequence.new(colour)
	end)
	if self._gui_highlight[gui_instance] then
		self:show_highlight(gui_instance, self._gui_highlight[gui_instance].highlight_enabled)
	end
	return
end
function theme_manager:add_custom_gui_instance(gui_instance, tag)
	gui_instance:AddTag(tag)
	self:compute_gui_instance_theme(gui_instance, self.current_theme[tag])
	self.events[gui_instance] = {
		on_highlight = {},
	}
	gui_instance.Destroying:Connect(function(...)
		self.events[gui_instance] = nil
	end)
	return
end
function theme_manager:set_theme(theme)
	if not theme then
		return
	end
	local loaded_theme: ThemeType
	if typeof(theme) == "Instance" then
		loaded_theme = require(theme :: ModuleScript) :: ThemeType
	else
		loaded_theme = theme :: ThemeType
	end
	self.current_theme = loaded_theme
	for Tag, Color in loaded_theme do
		local Instances = CollectionService:GetTagged(Tag)
		for _, _Instance: GuiObject in Instances do
			if Tag == "Hover" then
				continue
			end

			self:compute_gui_instance_theme(_Instance, Color)
		end
	end
	return
end

function theme_manager:force_highlight(gui_instance, bool)
	self:show_highlight(gui_instance, bool)
	self:disable_highlight_hover(gui_instance, bool)
	return
end
function theme_manager:add_highlight(gui_instance)
	if self._gui_highlight[gui_instance] then
		return
	end
	self._gui_highlight[gui_instance] = {
		mouse_hover = gui_instance.MouseEnter:Connect(function()
			if self._gui_highlight[gui_instance].hover_disabled then
				return
			end
			self:show_highlight(gui_instance, true)
		end),
		mouse_leave = gui_instance.MouseLeave:Connect(function()
			if self._gui_highlight[gui_instance].hover_disabled then
				return
			end
			self:show_highlight(gui_instance, false)
		end),
		hover_disabled = false,
		highlight_enabled = false,
	}

	gui_instance.Destroying:Connect(function()
		self._gui_highlight[gui_instance] = nil
	end)
	return
end

function theme_manager:show_highlight(gui_instance, bool)
	self._gui_highlight[gui_instance].highlight_enabled = bool
	local colour = bool and self.current_theme.Hover or gui_instance:GetAttribute("SetBackground")
	local text_colour = (colour.R * 0.299 + colour.G * 0.587 + colour.B * 0.114) * 255 > 186 and Color3.new()
		or Color3.new(1, 1, 1)
	gui_instance.BackgroundColor3 = colour
	pcall(function(...)
		gui_instance.TextColor3 = text_colour
	end)
	pcall(function(...)
		gui_instance.ImageColor3 = text_colour
	end)
	for _, func in self.events[gui_instance].on_highlight do
		func(bool)
	end
	return
end

function theme_manager:on_highlight(gui_instance, func)
	table.insert(self.events[gui_instance].on_highlight, func)
end

function theme_manager:disable_highlight_hover(gui_instance, bool)
	self._gui_highlight[gui_instance].hover_disabled = bool
	return
end

function theme_manager:get_base_theme()
	-- base is light theme
	return {
		Background = self.base_theme.Background,
		Foreground = self.base_theme.Foreground,
		Hover = self.base_theme.Hover,
	}
end

return theme_manager
