local rigs = {}
return {
	set_rig_position = function(humanoid: Humanoid)
		local rig: Model? = humanoid.Parent :: Model?
		if rig then
			rigs[rig] = rig:GetPivot()
		end
	end,
	apply_rig_position = function(humanoid: Humanoid)
		local rig: Model? = humanoid.Parent :: Model?
		if rig then
			task.defer(function()
				rig:PivotTo(rigs[rig])
			end)
		end
	end,
}
