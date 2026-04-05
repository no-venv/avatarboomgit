--!strict
local RunService = game:GetService("RunService")
local animation_types = require(".")
local animation_utils = require("./utils")
local typed_event = require("../../../../utils/TypedBindables")
type PlayingState = "playing" | "paused" | "stop" | "seek"
type Events = {
	playing_state_change: {
		state: PlayingState,
	},
}
export type AnimationPlayer = {
	events: {
		playing_state_change: typed_event.Event<{
			state: PlayingState,
		}>,
		time_position_change: typed_event.Event<{
			time: number,
		}>,
	},
	playing_state: PlayingState,
	time_position: number,
	humanoid: Humanoid,
	animator: Animator,
	loaded_animations: {
		{
			playing_at: number,
			animation_track: AnimationTrack,
			animation_start: number,
			animation_end: number,
			gap: number,
			length: number,
		}
	},
}
export type AnimationPlayerImpl = {
	set_humanoid: (humanoid: Humanoid) -> (),
	load_animation: (animation: animation_types.AnimationObject) -> (),
	play: () -> (),
	seek: (time: number) -> (),
	get_time: () -> number,
	pause: () -> (),
	stop: () -> (),
}

return function()
	local player = {} :: AnimationPlayer & AnimationPlayerImpl
	player.events = {
		playing_state_change = typed_event(),
		time_position_change = typed_event(),
	}
	player.playing_state = "stop"
	player.time_position = 0
	player.loaded_animations = {}
	player.set_humanoid = function(humanoid)
		player.humanoid = humanoid
		player.animator = humanoid:FindFirstChildOfClass("Animator") :: Animator
	end
	player.load_animation = function(animation)
		-- Loads animation to humanoid
		-- 1st track is only supported
		player.loaded_animations = {}
		local track_1 = animation.get_track(1)
		if not track_1 then
			warn("Track 1 is missing")
			return
		end
		local clip_times = {}
		for clip_time, clip in track_1 do
			table.insert(clip_times, clip_time)
		end
		table.sort(clip_times)
		for index = 1, #clip_times do
			local clip_time = clip_times[index]
			local next_clip_time = clip_times[index + 1]
			local clip = track_1[clip_time]
			local anim = animation_utils.preload_animation_object(clip.asset_id)
			local animation_track = player.animator:LoadAnimation(anim)
			animation_track.Looped = false
			local gap = next_clip_time and (next_clip_time - (clip_time + animation.compute_clip_length(1, clip_time)))
				or 0
			table.insert(player.loaded_animations, {
				playing_at = clip_time,
				animation_track = animation_track,
				-- duration of animation plus gap to next clip
				length = animation.compute_clip_length(1, clip_time),
				animation_start = clip.animation_start,
				animation_end = clip.animation_end,
				gap = gap,
			})
		end
	end
	player.play = function()
		--[[
			Plays animation with seeking support
		]]
		if not player.loaded_animations then
			return
		end

		if player.playing_state ~= "seek" then
			player.stop()
			player.playing_state = "playing"
			player.events.playing_state_change.emit({ state = "playing" })
		end

		local force_quit = false
		-- Handle cases with the animation being seeked
		local starting_index = 1
		local offset_start = 0
		local time_position_inside_animation = false

		for index, animation_track in player.loaded_animations do
			-- check if the time_position is 'inside' an animation
			local global_start = animation_track.playing_at
			local global_end = animation_track.playing_at + animation_track.length
			if player.time_position >= global_start and player.time_position <= global_end then
				-- time position is within the animation clip, offset from the start
				offset_start = player.time_position - global_start
				starting_index = index
				time_position_inside_animation = true
				break
			end
		end
		--
		local nearest_clip_index_distance = math.huge
		if not time_position_inside_animation then
			local found = false
			starting_index = #player.loaded_animations
			-- the time position is outside an animation clip, so get the nearest next clip
			for index, animation_track in player.loaded_animations do
				local global_start = animation_track.playing_at
				if nearest_clip_index_distance < math.abs(global_start - player.time_position) then
					starting_index = index
					nearest_clip_index_distance = math.abs(global_start - player.time_position)
					found = true
				end
			end
			if not found then
				-- there nothing to play??
				return
			end
			-- nearest_clip_index_distance is the gap between time position and the next clip
			-- so it's the amount of time to wait
			local previous_clip = player.loaded_animations[starting_index - 1]
			if previous_clip then
				-- freezeframe the previous clip
				previous_clip.animation_track.TimePosition = previous_clip.length
				previous_clip.animation_track:Play(0.0)
				player.animator:StepAnimations(0)
			end

			local duration = nearest_clip_index_distance
			while duration > 0 do
				local delta = RunService.Heartbeat:Wait()
				duration -= delta
				if player.playing_state == "seek" then
					return
				end
				if player.playing_state == "paused" then
					continue
				end
				if player.playing_state == "stop" then
					return
				end
				player.time_position += delta
				player.events.time_position_change.emit({ time = player.time_position })
			end
		end
		local currentTrack: AnimationTrack? = nil
		for index = starting_index, #player.loaded_animations do
			local animation_track = player.loaded_animations[index]
			animation_track.animation_track:Play(player.playing_state == "seek" and 0 or 0.5)
			animation_track.animation_track.TimePosition = animation_track.animation_start + offset_start
			if player.playing_state == "seek" then
				-- animation_track.animation_track:AdjustSpeed(0)
			end

			if currentTrack then
				currentTrack:Stop(0.5)
			end
			local gap_duration = animation_track.gap
			local track_duration = math.max(0, animation_track.length - 0.5)
			while (track_duration > 0) or (gap_duration > 0) do
				local delta = RunService.Heartbeat:Wait()
				if player.playing_state == "paused" then
					continue
				end
				if player.playing_state == "stop" then
					force_quit = true
					break
				end
				track_duration -= delta
				if track_duration < 0 then
					gap_duration -= delta
				end

				player.animator:StepAnimations(delta)
				if player.playing_state == "seek" then
					return
				end
				player.time_position += delta

				player.events.time_position_change.emit({ time = player.time_position })
				player.playing_state = "playing"
			end

			currentTrack = animation_track.animation_track
			if force_quit then
				break
			end
			if offset_start > 0 then
				offset_start = 0
			end
		end

		if currentTrack then
			currentTrack:Stop(0)
			player.animator:StepAnimations(0)
		end
		player.time_position = 0
	end
	player.seek = function(seek)
		-- Seeking will stop the animation to switch control here
		-- player.stop()
		player.playing_state = "seek"
		player.time_position = seek
		player.play()
	end
	player.pause = function()
		player.playing_state = "paused"
		player.events.playing_state_change.emit({
			state = "paused",
		})
	end
	player.stop = function()
		player.playing_state = "stop"
		task.wait() -- sync to next frame
		for _, playing in player.animator:GetPlayingAnimationTracks() do
			playing:Stop(0)
		end
		-- reset the joints
		player.animator:StepAnimations(0)
		for _, descendant in pairs(((player.humanoid.Parent) :: Instance):GetDescendants()) do
			if descendant:IsA("Motor6D") then
				local joint = descendant
				joint.CurrentAngle = 0
				joint.Transform = CFrame.new()
			end
		end
		player.events.playing_state_change.emit({
			state = "stop",
		})
	end
	return player
end
