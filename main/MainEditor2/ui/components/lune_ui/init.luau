--!strict
local CollectionService = game:GetService("CollectionService")
local theme_manager = require(script.theme_manager)
local utils = require(script.utils)
local set_property_scope = {}
type void = nil;
type button_function = (() -> void)?

return {
	init_all_lume_instances = function()
		for _,textbox in CollectionService:GetTagged("LumeButton") do
			theme_manager:add_highlight(textbox)
		end
	end,
	lune_overlay = require(script.lune_overlay);
	theme_manager = theme_manager;
	property_scope = utils.prop_scope.scope;
	textbox = require(script.textbox);
	textbutton = require(script.textbutton);
	iconbutton = require(script.iconbutton);
	slider = require(script.slider);
	tab = require(script.tab);
	option_buttons = require(script.option_buttons);
	textlabel = require(script.textlabel),
	empty_frame = require(script.empty_frame),
	scrolling_frame = require(script.scrolling_frame),
	collasped_view = require(script.collasped_view);
	styling = require(script.styling_components);
	float_menu = require(script.float_menu);
 	window = require(script.window)
}