local watch_table = require("./watch_table")
local theme_manager = require("../theme_manager")
type Arguments<T> = {
	watch: {},
	key: string,
	eval_type: "compare",
	eval_argument: any,
}
return function<T>(parent: T & GuiObject, args: Arguments<T>)
	local watched = watch_table({
		key = args.key,
		watched_table = args.watch,
		evaluate = function(value)
			if args.eval_type then
				local switch = {
					compare = function()
						theme_manager:force_highlight(parent, value == args.eval_argument)
					end,
				}
				switch[args.eval_type]()
			end
		end,
	})
	parent.Destroying:Connect(function(...)
		watched.disconnect()
	end)
	return parent
end
