return function()
	local current_camera = workspace.CurrentCamera
	local spawn_position = (current_camera.CFrame.Position - Vector3.new(0, 1.5, 0))
		+ (current_camera.CFrame.LookVector * 8)
	return spawn_position
end
