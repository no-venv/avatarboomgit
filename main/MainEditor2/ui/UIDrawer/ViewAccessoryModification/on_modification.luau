local typed_events = require("../../../utils/TypedBindables")
-- fired when an id is instered
export type EventParm = {
	id: number,
	event_type: "id_inserted" | "id_removed" | "humanoid_changed" | "selected_id" | "disable",
	is_accessory: boolean,
	is_clothing: boolean,
	clothing_type: string,
}
return typed_events() :: typed_events.Event<EventParm>
