--!strict
local lune = require("../../components/lune_ui")
local singletons = require("../../../singletons")
local function camera_spawn()
	local current_camera = workspace.CurrentCamera
	local spawn_position = (current_camera.CFrame.Position - Vector3.new(0, 1.5, 0))
		+ (current_camera.CFrame.LookVector * 8)
	return spawn_position
end
return function(parent: Instance?)
	local container = lune.empty_frame()
	container.Name = "Convert Rig"
	do
		local grid = lune.styling.grid(container)
		grid.VerticalAlignment = Enum.VerticalAlignment.Center
	end
	lune.textbutton("R6", container, function(...)
		local model = singletons.humanoid_description:convert_humanoid_type("R6")
		model.Parent = workspace
		model:MoveTo(camera_spawn())
	end)
	lune.textbutton("R15", container, function(...)
		local model = singletons.humanoid_description:convert_humanoid_type("R15")
		model.Parent = workspace
		model:MoveTo(camera_spawn())
	end)

	return container
end
