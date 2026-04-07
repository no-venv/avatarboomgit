local events = require("@self/events")
local lune = require("./lune_ui")
local home = require("@self/home")
local saved = require("@self/saved")
return function(parent: Frame?)
	-- get selected rig and show saved
	local local_events = events()
	local container = lune.empty_frame(parent)
	container.Name = "Restore Rig"
	local _, _, tab_func =
		lune.tab({ home(nil, local_events), saved(nil, local_events) }, "Restore Rig Menu", container, nil)
	tab_func.hide_tab_bar_button("Restore Rig", true)

	local on_update_rig = local_events.update_saved_rigs.connect(function(parm: { rig: Model })
		tab_func.toggle("Restore Rig", true)
	end)

	container.Destroying:Connect(function(...)
		on_update_rig:Disconnect()
	end)
	return container
end
