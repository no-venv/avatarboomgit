return function(rig: Model)
	local hrp = rig:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	rig.PrimaryPart = hrp
end
