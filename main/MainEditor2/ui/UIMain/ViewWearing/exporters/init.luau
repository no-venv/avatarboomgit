local exports = {
	Minecraft = require("@self/blockbench"),
	OBJ = require("@self/obj"),
}

local lune = require("../../components/lune_ui")
return function()
	local upload_view = lune.empty_frame()
	local vbox = lune.styling.vbox(upload_view)
	vbox.HorizontalFlex = Enum.UIFlexAlignment.Fill
	for name, export_func in exports do
		lune.textbutton(`Export to {name}`, upload_view, function(...)
			local view = export_func()
			if view then
				lune.window.base({
					title = "Post Export Instructions",
					view = view,
					important = true,
				})
			end
		end)
	end

	lune.window.base({
		title = "Export your avatar",
		view = upload_view,
		important = true,
	})
end
