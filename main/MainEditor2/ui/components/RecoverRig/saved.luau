--!strict
local singletons = require("../../../singletons")
local viewport_frame = require("../ViewportFrame")
local lune = require("../lune_ui")
local events = require("./events")
return function(parent: Frame?, events: events.Events)
	-- get selected rig and show saved
	local container = lune.empty_frame(parent)
	do
		lune.styling.sizeconst(
			lune.textlabel("Select the Rig you want to restore:", container),
			Vector2.zero,
			Vector2.new(math.huge, 32)
		)
		local vbox = lune.styling.vbox(container)
		vbox.VerticalFlex = Enum.UIFlexAlignment.Fill
		vbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
	end
	container.Name = "Restore Rig"
	local scrolling_container
	local function update(humanoid_model)
		if scrolling_container then
			scrolling_container:Destroy()
		end
		scrolling_container = lune.scrolling_frame(container, "Grid")
		local rig_saves = singletons.data_recovery.get_rig_saves_by_model(humanoid_model)
		if not rig_saves then
			return
		end
		for _, saved_rigs in rig_saves do
			local last_opened_time = DateTime.fromUnixTimestamp(tonumber(saved_rigs.time) :: number)
			local formatted_local_time = last_opened_time:FormatLocalTime("LL", "en-ca")
			local local_time = last_opened_time:ToLocalTime() :: { [any]: any }
			local rig_button = lune.textbutton("", scrolling_container, function(...)
				-- clone rig to workspace in front of camera
				local current_camera = workspace.CurrentCamera
				local spawn_position = (current_camera.CFrame.Position - Vector3.new(0, 1.5, 0))
					+ (current_camera.CFrame.LookVector * 8)
				local cloned_rig = saved_rigs.rig:Clone()
				cloned_rig.Parent = workspace
				cloned_rig:MoveTo(spawn_position)
				lune.window.option({
					title = "",
					size = Vector2.new(0.7, 256),
					prompt_text = `Do you want avatarBOOM to detect the restored rig?\n\nIf you choose no, you can't edit your rig with avatarBOOM unless you restore the rig again.`,
					options = { "Yes", "No" },
					important = true,
					on_prompt_result = function(result)
						if result == "Yes" then
							cloned_rig
								:FindFirstChild(singletons.data_recovery.magic_keyword_ignore_avatarboom)
								:Destroy()
						end
					end,
				})
			end)
			lune.tooltips(rig_button, `Saved at {formatted_local_time} at {local_time.Hour}:{local_time.Minute}`)
			viewport_frame(rig_button, saved_rigs.rig)
		end
	end
	local update_rig_event = events.update_saved_rigs.connect(function(parm)
		update(parm.rig)
	end)
	container.Destroying:Connect(function(...)
		update_rig_event:Disconnect()
	end)
	return container
end
