local recover_rig = require(".")
local lune = require("../lune_ui")
return {
	render = function(props)
		local container = lune.empty_frame(props.target)
		container.Transparency = 0
		lune.theme_manager:add_custom_gui_instance(container, "Background")
		lune.lune_overlay.Parent = container
		recover_rig(container)
		return function()
			container:Destroy()
		end
	end,
}
