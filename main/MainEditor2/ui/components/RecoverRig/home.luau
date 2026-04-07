--!strict
local lune = require("../lune_ui")
local viewport_frame = require("../ViewportFrame")
local singletons = require("../../../singletons")
local events = require("./events")
return function(parent: Instance?,events : events.Events)
	local recovery_folder = singletons.data_recovery.get_recovery_folder()
	local container = lune.empty_frame(parent)
	container.Name = "Restore Rig Menu"
	local scrolling_container
	local function update()
		if scrolling_container then
			scrolling_container:Destroy()
		end
		scrolling_container = lune.scrolling_frame(container, "Grid")
		for _, saved in recovery_folder:GetChildren() do
			local saved_folder_children = saved:GetChildren()
			if #saved_folder_children == 0 then
				continue
			end
			local saved_rig = saved_folder_children[1]
			local saved_rig_button = lune.textbutton("", scrolling_container, function()
				events.update_saved_rigs.emit({ rig = saved_rig })
			end)
			viewport_frame(saved_rig_button, saved_rig)
		end
	end
	local child_added = recovery_folder.ChildAdded:Connect(update)
	local child_removed = recovery_folder.ChildRemoved:Connect(update)
	container.Destroying:Connect(function(...)
		child_added:Disconnect()
		child_removed:Disconnect()
	end)
	update()
	return container
end
