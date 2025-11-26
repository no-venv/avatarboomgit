local move = Instance.new("Handles")
local rotation = Instance.new("ArcHandles")
local scale = Instance.new("Handles")
local uniform_scale_handles = Instance.new("CylinderHandleAdornment")
do
	move.Style = Enum.HandlesStyle.Movement
	move.Visible = false
	scale.Visible = false
	rotation.Visible = false
end
do
	uniform_scale_handles.Color3 = Color3.new(1,1,1)
	uniform_scale_handles.AlwaysOnTop = true
	uniform_scale_handles.Angle = 360
	uniform_scale_handles.Height = 0.03
	uniform_scale_handles.InnerRadius = 2.2
	uniform_scale_handles.ZIndex = 2
	uniform_scale_handles.Visible = false
end

local container = Instance.new("Model")
do
	move.Parent = container
	rotation.Parent = container
	scale.Parent = container
	uniform_scale_handles.Parent = container
end
return function(parent : Instance?)
	local container = Instance.new("Model")
	local cloned_move = move:Clone()
	local cloned_rotation = rotation:Clone()
	local cloned_uniform_scale_handles = uniform_scale_handles:Clone()
	cloned_move.Parent = container
	cloned_rotation.Parent = container
	cloned_uniform_scale_handles.Parent = container
	return {
		container = container;
		Move = cloned_move;
		Rotation = cloned_rotation;
		UniformScale = cloned_uniform_scale_handles
	}
end