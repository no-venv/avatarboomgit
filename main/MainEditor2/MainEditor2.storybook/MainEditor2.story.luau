local editor = require(script:FindFirstAncestor("MainEditor2"))

return {
	render = function(props)
		local editor_container = editor(props.target)
		return function()
			editor_container:Destroy()
		end
	end,
}
