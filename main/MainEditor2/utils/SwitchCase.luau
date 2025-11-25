return function<T>(case : T, switch : {[T] : () -> nil})
	if not switch[case] then
		return
	end
	switch[case]()
end