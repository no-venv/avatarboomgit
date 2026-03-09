return function(rig: Model)
	for _, limb in rig:GetChildren() do
		if limb:IsA("Part") or limb:IsA("MeshPart") then
			limb.Locked = false
			limb.CollisionGroup = "Default"
		end
	end
end
