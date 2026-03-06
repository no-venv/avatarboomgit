export type Event<T> = {
	emit: (T) -> nil,
	connect: ((parm: T) -> nil) -> RBXScriptConnection,
	once: ((parm: T) -> nil) -> RBXScriptConnection,
}

return function<T>(type: T): Event<T>
	local connected = {}
	local func_id = 0
	local function create_evt_return(id)
		local self = {}
		function self:Disconnect()
			connected[id] = nil
		end
		return self
	end
	return {
		emit = function(...)
			for _,func in connected do
				func(...)
			end
		end,
		connect = function(connected_function)
			-- print(connected_function)
			func_id += 1
			connected[func_id] = connected_function
			return create_evt_return(func_id)
		end,
		once = function(connected_function)
			func_id += 1
			local strong_func_id = func_id
			connected[strong_func_id] = function(...)
				connected_function(...)
				connected[strong_func_id] = nil
			end
			return create_evt_return(strong_func_id)
		end,
	}
end
