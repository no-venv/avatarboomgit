local players = game:GetService("Players")
local lune = require("../../components/lune_ui")
local get_spawn_position = require("./spawn_position")
local selectable_rig = require("./selectable_rig")
local fix_rig = require("./fix_rig")
return function(parent: Instance?, user_id: number)
	local container = lune.empty_frame(parent)
	container.Name = "Import From Friends"
	local vbox = lune.styling.vbox(container)
	vbox.VerticalFlex = Enum.UIFlexAlignment.Fill
	local friends = players:GetFriendsAsync(user_id)
	local selected_rig_type = Enum.HumanoidRigType.R15
	local scrolling_container
	local function generate()
		if friends.IsFinished then
			return false
		end
		for _, friend in friends:GetCurrentPage() do
			local user = lune.iconbutton({
				id = 0,
				on_click = function()
					local hum_desc = players:GetHumanoidDescriptionFromUserIdAsync(friend.Id)
					local rig_model = players:CreateHumanoidModelFromDescriptionAsync(hum_desc, selected_rig_type)
					fix_rig(rig_model)
					rig_model.Parent = workspace
					rig_model:MoveTo(get_spawn_position())
					selectable_rig(rig_model)
				end,
				parent = scrolling_container,
			})
			task.spawn(function()
				user:SetAttribute(
					"image",
					players:GetUserThumbnailAsync(
						friend.Id,
						Enum.ThumbnailType.AvatarThumbnail,
						Enum.ThumbnailSize.Size420x420
					)
				)
			end)
		end
		friends:AdvanceToNextPageAsync()
		return true
	end

	scrolling_container = lune.scrolling_frame(container, "Grid", nil, generate)
	lune.option_buttons(container, { "R6", "R15" }, function(value: string)
		selected_rig_type = (value == "R6") and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
		return
	end)
	return container
end
