--!strict
local humanoid_editor = require("../../../singletons/SimpleHumanoidDescription")
local on_modification = require("./on_modification")
local gizmo_transform = require("../../components/GizmoTransform")
return function(parent: Instance)
	local current_gizmo_transform: Model?
	local current_id
	on_modification.connect(function(parm)
		if current_gizmo_transform then
			current_gizmo_transform:Destroy()
			current_gizmo_transform = nil
		end
		if parm.event_type == "disable" then
			return
		end
		if parm.event_type == "selected_id" then
			current_id = parm.id
		end
		if not humanoid_editor:id_equipped(current_id) then
			return
		end
		if parm.is_accessory and not parm.is_clothing then
			local accessory = humanoid_editor:get_id_accessory(parm.id)
			if not accessory then
				return
			end
			local handle_part = accessory:FindFirstChild("Handle")
			if not handle_part then
				return
			end
			current_gizmo_transform = gizmo_transform(handle_part, function(type, value: Vector3)
				if type == "Move" then
					local cur_id_transform = humanoid_editor:get_id_transformation(current_id, "Pos")
					if not cur_id_transform then
						return
					end
					humanoid_editor:set_id_transformation(current_id, "Pos", cur_id_transform + value)
					return
				end
				if type == "Rotation" then
					local cur_id_rot = humanoid_editor:get_id_transformation(current_id, "Rot")
					if not cur_id_rot then
						return
					end
					humanoid_editor:set_id_transformation(current_id, "Rot", cur_id_rot + value)
					return
				end
				if type == "Scale" then
					local cur_id_scale = humanoid_editor:get_id_transformation(current_id, "Scale")
					if not cur_id_scale then
						return
					end
					humanoid_editor:set_id_transformation(current_id, "Scale", cur_id_scale + value)
					return
				end
				if type == "Reset" then
					humanoid_editor:set_id_transformation(current_id, "Pos", Vector3.zero)
					humanoid_editor:set_id_transformation(current_id, "Rot", Vector3.zero)
					humanoid_editor:set_id_transformation(current_id, "Scale", Vector3.new(1, 1, 1))
					return
				end
				return
			end)
		end
	end)
	parent.Destroying:Connect(function(...)
		if current_gizmo_transform then
			current_gizmo_transform:Destroy()
		end
	end)
	-- if is_accessory and not is_clothing then

	-- end
end
