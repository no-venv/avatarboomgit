local norm = require("./normalize_mouse")
local UserInputService = game:GetService("UserInputService")

return function(
	gui: GuiObject,
	pos_changed: (screen_pos: Vector2, local_pos: Vector2, local_pos_norm: Vector2, size: Vector2) -> (),
	on_end: (() -> ())?
)
	local should_update
	gui.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			should_update = true

			local release_event
			release_event = input.Changed:Connect(function(property: string)
				if input.UserInputState == Enum.UserInputState.End then
					should_update = false
					release_event:Disconnect()
					if on_end then
						on_end()
					end
				end
			end)
		end
	end)

	local mutex = false
	gui.InputChanged:Connect(function(input: InputObject)
		if not should_update or mutex then
			return
		end
		mutex = true
		task.spawn(function()
			while task.wait() and should_update do
				local mouse_pos = Vector2.new(input.Position.X, input.Position.Y)
				local local_pos_norm = norm(mouse_pos, gui.AbsolutePosition, gui.AbsoluteSize)
				local local_pos = local_pos_norm * gui.AbsoluteSize
				pos_changed(mouse_pos, local_pos, local_pos_norm, gui.AbsoluteSize)
			end
			mutex = false
		end)
		-- if input.UserInputType == Enum.UserInputType.MouseMovement then
		-- 	pos_changed(Vector2.new(input.Position.X, input.Position.Y))
		-- end
	end)
end
