local gui = require(script.Parent)
return {
	render = function(props)
		local gui_instance = gui(props.target)
		return function()
			gui_instance:Destroy()
		end
	end,
	
}