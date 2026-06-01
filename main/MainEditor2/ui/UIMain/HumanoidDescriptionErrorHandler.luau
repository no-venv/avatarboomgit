local error_window = require("../components/error_popup")
local shs = require("../../singletons/SimpleHumanoidDescription")
shs.on_error = function(error)
	if error.type == "id_operation" then
		error_window({
			error = `AvatarBoom has tried two times to update your rig, but something went wrong.\n\nThis can be a problem with your rig (especially if you manually modified it or is using other plugins), or Roblox is down.\n\n{error.message}`,
		})
	else
		error_window({
			error = `{error.message}`,
		})
	end
end
return true
