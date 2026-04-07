--!strict
local typed_events = require("../../../utils/TypedBindables")
export type Events = {
	update_saved_rigs: typed_events.Event<{
		rig: Model,
	}>,
}

return function()
	return {
		update_saved_rigs = typed_events(),
	} :: Events
end
