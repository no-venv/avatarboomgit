return {
	render = function(props)
		local gui
		local gui_instance
		local ok,error = pcall(function(...) 
			gui = require(script.Parent)
			gui_instance = gui(props.target)
		end)
		print(ok,error)
	
		gui_instance.Size = UDim2.new(1,0,1,0)
		--gui_instance.Size = UDim2.new(1,0,1,0)		
		return function()
			gui_instance:Destroy()
		end
	
	end,

}