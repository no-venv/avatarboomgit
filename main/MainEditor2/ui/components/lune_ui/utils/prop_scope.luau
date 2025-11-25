type propertys = {
	{}
}
local prop = {}
return {
	auto_set_property = function(instance : Instance)
		for property,value in prop do
			instance[property] = value
		end
		return 
	end,	
	scope = function(default_prop,scope_func)
		
		prop = default_prop
		scope_func()
		prop = {}
	end,
}