export type Event<T> = {
	raw : BindableEvent;
	emit : (T) -> nil;
	connect : ((parm : T) -> nil) -> RBXScriptConnection;
	once :  ((parm : T) -> nil) -> RBXScriptConnection;
}
return function<T>(type : T) : Event<T>
	local bindable = Instance.new("BindableEvent")
	return {
		raw = bindable;
		emit = function(...)
			bindable:Fire(...)
		end,
		connect = function(...)
			bindable.Event:Connect(...)
		end,
		once = function(...)
			bindable.Event:Once(...)
		end,
	}
end