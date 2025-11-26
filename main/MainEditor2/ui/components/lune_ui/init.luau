--!strict
local theme_manager = require("@self/theme_manager")
local utils = require("@self/utils")
return {
	-- init_all_lume_instances = function()
	-- 	for _,textbox in CollectionService:GetTagged("LumeButton") do
	-- 		theme_manager:add_highlight(textbox)
	-- 	end
	-- end,
	lune_overlay = require("@self/lune_overlay");
	theme_manager = theme_manager;
	property_scope = utils.prop_scope.scope;
	textbox = require("@self/textbox");
	textbutton = require("@self/textbutton");
	iconbutton = require("@self/iconbutton");
	slider = require("@self/slider");
	tab = require("@self/tab");
	option_buttons = require("@self/option_buttons");
	textlabel = require("@self/textlabel"),
	empty_frame = require("@self/empty_frame"),
	scrolling_frame = require("@self/scrolling_frame"),
	collasped_view = require("@self/collasped_view");
	styling = require("@self/styling_components");
	float_menu = require("@self/float_menu");
 	window = require("@self/window")
}
