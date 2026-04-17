export type Event<T> = {
	emit: (T) -> any,
	connect: ((parm: T) -> ()) -> RBXScriptConnection,
	once: ((parm: T) -> ()) -> RBXScriptConnection,
}

local function create_evt_return(connected_ref, id)
	local self = {}
	function self:Disconnect()
		connected_ref[id] = nil
	end
	return self
end

return function()
	-- creates a typed signal object
	local connected = {}
	local func_id = 0
	return {
		emit = function(...)
			for _, func in connected do
				task.spawn(func, ...)
			end
		end,
		connect = function(connected_function)
			func_id += 1
			connected[func_id] = connected_function
			return create_evt_return(connected, func_id)
		end,
		once = function(connected_function)
			func_id += 1
			local strong_func_id = func_id
			connected[strong_func_id] = function(...)
				connected_function(...)
				connected[strong_func_id] = nil
			end
			return create_evt_return(connected, strong_func_id)
		end,
	}
end
