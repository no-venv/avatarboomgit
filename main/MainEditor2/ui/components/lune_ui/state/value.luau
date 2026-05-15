--!strict
export type LuneValue<T> = {
	set: (T) -> (),
	get: () -> T,
	watch: (func: (T) -> ()) -> (),
	unwatch: (func: (T) -> ()) -> (),
}
return function<T>(value: T)
	local connected_functions: { [(T) -> ()]: boolean } = {}
	local internal_value = value
	return {
		set = function(value: T)
			internal_value = value
			for func, _ in connected_functions do
				task.spawn(func, internal_value)
			end
		end,
		get = function(): T
			return internal_value
		end,
		watch = function(func)
			connected_functions[func] = true
		end,
		unwatch = function(func)
			connected_functions[func] = nil
		end,
	}
end
