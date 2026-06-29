local error_window = require("../components/error_popup")
local shs = require("../../singletons/SimpleHumanoidDescription")
local error_messages = {
	id_operation_fetch_asset_type = "Something went wrong while downloading information for the asset.\n\n Roblox may be down, or you might be rate limited. You can try again later to check if the issue is resolved.",
	id_operation = "AvatarBoom has tried two times to update your rig, but something went wrong.\n\nThis can be a problem with your rig (especially if you manually modified it or is using other plugins), or Roblox is down.",
}
shs.on_error = function(error)
	error_window({
		error = `{error_messages[error.type]}\n\n{error.message}`,
	})
end
return true
