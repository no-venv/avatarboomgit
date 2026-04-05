-- main view of the keyframes
local lune = require("../../components/lune_ui")
local animations_catalog = require("@self/animations_catalog")
local animations_clip_view = require("@self/animations_clip_view")
local animation_types = require("@self/../animation")
return function(parent: Instance, animation_data: animation_types.AnimationObject)
	local container = lune.empty_frame(parent)
	container.Name = "Animator"
	do
		local vbox = lune.styling.vbox(container)
		vbox.VerticalFlex = Enum.UIFlexAlignment.Fill
	end
	animations_clip_view(container, animation_data)
	lune.tab({ animations_catalog(nil, animation_data) }, "Animation Catalog", container)
	return container
end
