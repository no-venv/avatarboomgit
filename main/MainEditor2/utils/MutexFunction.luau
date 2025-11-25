return function(f)
	local locked = false
	return function(...)
		if locked then
			return
		end	
		locked = true
		local v = f(...)
		locked = false
		return v
	end
end