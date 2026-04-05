--!strict
local HttpService = game:GetService("HttpService")
local typed_event = require("../../../utils/TypedBindables")
local animation_utils = require("@self/utils")
type RobloxAnimation = Animation
export type InterpolationType = "LINEAR"
export type AnimationEffects = "Speed"
export type AnimationClip = {
	effects: { [AnimationEffects]: boolean },
	asset_id: number,
	animation_start: number,
	animation_end: number,
	animation_length: number,
}
export type AnimationClipList = {
	[number]: AnimationClip,
}
export type Animation = {
	uuid: string,
	animation_clip_list: { AnimationClipList },
	audio: {
		name: string,
		is_file: boolean,
		asset_id: number,
		data: string,
		instance: Sound?,
		time_start: number,
	},
}

export type AnimationImplPrivate = {
	test_clip_collision: (track: number, time: number, move_to: number) -> { time: number, clip_hit: AnimationClip }?,
	test_clip_full_collision: (
		track: number,
		time: number,
		move_to: number,
		move_to_end: number
	) -> { { time: number, clip_hit: AnimationClip } }?,
	fix_overlapping: (track: number) -> (),
}
type Events = {
	animation_modified: {
		track: number,
		event: "track_update" | "track_add" | "track_remove",
		time: number?,
		clip: AnimationClip?,
	},
}
export type AnimationImpl = {
	animation_data: Animation,
	new_track: () -> (),
	get_track: (track: number) -> AnimationClipList,
	get_all_tracks: () -> { AnimationClipList },
	delete_track: (track: number) -> (),
	compute_clip_length: (track: number, time: number) -> number,
	add_animation_clip: (track: number, time: number?, asset_id: number) -> (),
	resize_animation_clip: (track: number, time: number, animation_start: number?, animation_end: number?) -> (),
	move_animation_clip: (track: number, time: number, move_to: number) -> (),
	duplicate_animation_clip: (track: number, time: number) -> (),
	split_animation_clip: (track: number, time: number, offset: number) -> (),
	remove_animation_clip: (track: number, time: number) -> (),
	get_animation_length: () -> number,
}

local types = {
	AnimationClip = function(asset_id: number): AnimationClip
		-- load in the animation and apply information
		local animation_length = animation_utils.get_animation_length(asset_id)
		return {
			effects = {},
			animation_start = 0,
			animation_end = animation_length,
			asset_id = asset_id,
			animation_length = animation_length,
		}
	end,
	Animation = function(): Animation
		return {
			uuid = HttpService:GenerateGUID(),
			animation_clip_list = {
				{},
			},
			audio = {
				name = "",
				is_file = false,
				asset_id = 0,
				data = "",
				instance = nil,
				time_start = 0,
			},
		}
	end,
	AnimationObject = function() end,
}

local function new(animation_data: Animation?)
	local typed_event_list = {} :: Events
	local events = {
		on_animation_modified = typed_event(),
	}
	local animation = {} :: AnimationImpl & { events: typeof(events) }
	local private = {} :: AnimationImplPrivate
	private.test_clip_collision = function(track, time, move_to)
		for clip_time, clip in animation.animation_data.animation_clip_list[track] do
			if clip_time == time then
				continue
			end
			if move_to >= clip_time and move_to <= clip_time + animation.compute_clip_length(track, clip_time) then
				return {
					time = clip_time,
					clip_hit = clip,
				}
			end
			-- test if overlap
		end
		return
	end

	animation.events = events
	animation.animation_data = (animation_data or types.Animation()) :: Animation
	animation.new_track = function()
		table.insert(animation.animation_data.animation_clip_list, {})
		events.on_animation_modified.emit({
			event = "track_add",
			track = #animation.animation_data.animation_clip_list,
		})
	end
	animation.get_track = function(track)
		return animation.animation_data.animation_clip_list[track]
	end
	animation.get_all_tracks = function()
		return animation.animation_data.animation_clip_list
	end
	animation.delete_track = function(track)
		table.remove(animation.animation_data.animation_clip_list, track)
		events.on_animation_modified.emit({
			event = "track_remove",
			track = track,
		})
	end
	animation.compute_clip_length = function(track, time)
		local clip = animation.animation_data.animation_clip_list[track][time]
		return clip.animation_end - clip.animation_start
	end
	animation.add_animation_clip = function(track, time, asset_id)
		local clip_list = animation.animation_data.animation_clip_list[track]
		local last_time = 0

		for clip_time, clip in clip_list do
			local t = clip_time + clip.animation_end
			if t > last_time then
				last_time = t
			end
		end
		local clip = types.AnimationClip(asset_id)
		animation.animation_data.animation_clip_list[track][time or last_time] = clip
		if time then
			-- move clip to time
			animation.move_animation_clip(track, last_time, time)
		end
		-- print(animation.animation_data)
		events.on_animation_modified.emit({
			track = track,
			event = "track_update",
		})
	end
	animation.resize_animation_clip = function(track, time, animation_start, animation_end)
		local clip_track = animation.get_track(track)
		local clip = clip_track[time]

		if animation_start then
			local old_start = clip.animation_start
			clip.animation_start =
				math.clamp(animation_start - (time - clip.animation_start), 0.1, clip.animation_end - 0.1)
			animation.move_animation_clip(track, time, time + (clip.animation_start - old_start))
		end
		if animation_end then
			local delta = animation_end - (time + animation.compute_clip_length(track, time))
			clip.animation_end =
				math.clamp(clip.animation_end + delta, clip.animation_start + 0.1, clip.animation_length - 0.1)
			animation.move_animation_clip(track, time, time)
		end
	end
	animation.remove_animation_clip = function(track, time)
		animation.animation_data.animation_clip_list[track][time] = nil
		events.on_animation_modified.emit({
			track = track,
			event = "track_update",
		})
	end
	animation.move_animation_clip = function(track, time, move_to)
		-- move clip and check if its ok
		local clip_list = animation.animation_data.animation_clip_list[track]
		local clip = clip_list[time]

		-- Side Collisions
		local left_test = private.test_clip_collision(track, time, move_to)
		if left_test then
			-- hit, so nudge the move_to
			move_to += (left_test.time + animation.compute_clip_length(track, left_test.time)) - move_to
		end

		animation.animation_data.animation_clip_list[track][time] = nil
		if animation.animation_data.animation_clip_list[track][move_to] then
			-- taken, shift by 1/60
			print("taken, shifting by 1/60")
			animation.animation_data.animation_clip_list[track][move_to + 0.016] =
				animation.animation_data.animation_clip_list[track][move_to]
		end
		animation.animation_data.animation_clip_list[track][move_to] = clip
		-- fix overlapping
		local clip_times = {}
		local stored = {}
		for clip_time, clip in clip_list do
			-- get rid of all the clips after Move To
			if clip_time <= move_to then
				continue
			end
			table.insert(clip_times, clip_time)
		end
		table.sort(clip_times)
		for _, time in clip_times do
			table.insert(stored, { time = time, clip = animation.animation_data.animation_clip_list[track][time] })
			animation.animation_data.animation_clip_list[track][time] = nil
		end
		local drop_clip_at = move_to + (clip.animation_end - clip.animation_start)

		if #stored > 0 then
			local spacing = stored[1].time - drop_clip_at
			if spacing > 0 then
				drop_clip_at += spacing
			end
		end

		for index = 1, #stored do
			local clip = stored[index]
			animation.animation_data.animation_clip_list[track][drop_clip_at] = clip.clip
			local next_clip = stored[index + 1]
			if not next_clip then
				continue
			end
			-- print((next_clip.time - (clip.time + (clip.clip.animation_end - clip.clip.animation_start))))
			drop_clip_at += (clip.clip.animation_end - clip.clip.animation_start) + (next_clip.time - (clip.time + (clip.clip.animation_end - clip.clip.animation_start)))
		end

		events.on_animation_modified.emit({
			track = track,
			event = "track_update",
		})
	end
	animation.split_animation_clip = function(track, time, offset)
		local should_split = offset >= time and offset <= time + animation.compute_clip_length(track, time)
		if not should_split then
			return
		end
		local clip = animation.animation_data.animation_clip_list[track][time]
		local split_at = offset - time
		animation.animation_data.animation_clip_list[track][time + split_at] = {
			effects = clip.effects,
			animation_start = clip.animation_start + split_at,
			animation_end = clip.animation_end,
			asset_id = clip.asset_id,
			animation_length = clip.animation_length,
		}
		clip.animation_end = split_at + clip.animation_start
		events.on_animation_modified.emit({
			track = track,
			event = "track_update",
		})
	end
	animation.get_animation_length = function()
		local real_end_time = 0
		for track, clip_list in animation.get_all_tracks() do
			local end_time = 0
			for clip_time, clip in clip_list do
				end_time = clip_time + animation.compute_clip_length(track, clip_time)
			end
			if end_time > real_end_time then
				real_end_time = end_time
			end
		end
		return real_end_time
	end

	return animation
end

export type AnimationObject = typeof(new())

return new
