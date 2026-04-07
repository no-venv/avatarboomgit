local viewport = require("@self/instance")

return function(parent: Instance, instance: Instance, fov: number?)
	local new_viewport = viewport:Clone()
	local world_model = new_viewport:FindFirstChild("WorldModel") :: WorldModel
	local camera = world_model:FindFirstChild("Camera") :: Camera
	local model = Instance.new("Model")
	local cloned_instance = instance:Clone()

	new_viewport.CurrentCamera = camera
	cloned_instance.Parent = model
	model.Parent = world_model
	new_viewport.Parent = parent
	local cf, size = model:GetBoundingBox()
	camera.CFrame = CFrame.lookAt(cf.Position + cf.LookVector * 20, cf.Position)

	return new_viewport
end
