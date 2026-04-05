--!strict
local TextService = game:GetService("TextService")
local lune = require("../../../components/lune_ui")
local event_bus = require("../../../../singletons/event_bus")
local shared = require("../../../../shared")
local utils = require("../../../../utils")
local singletons = require("../../../../singletons")
local animation_types = require("../animation")
local animation_player = require("../animation/player")

return function(parent: Instance?, animation: animation_types.AnimationObject)
	--zoom is done by resizing the clips uis
	local pixel_per_second = 30
	local current_time = 0
	local player = animation_player()
	player.set_humanoid(singletons.humanoid_description.Humanoid)
	local container = lune.empty_frame(parent)
	container.Size = UDim2.new(1, 0, 1, 0)

	local inner_container = lune.empty_frame(container)
	do
		local hbox = lune.styling.vbox(inner_container)
		hbox.VerticalFlex = Enum.UIFlexAlignment.Fill
	end

	local scrolling_container = lune.scrolling_frame(inner_container, "None")
	scrolling_container.AutomaticCanvasSize = Enum.AutomaticSize.XY
	scrolling_container.ScrollingDirection = Enum.ScrollingDirection.XY

	local track_uis = {}

	local auto_scroll_active = false
	local auto_scroll_direction = Vector2.zero

	local function auto_scroll(direction: Vector2, active: boolean)
		if not auto_scroll_active and active then
			task.spawn(function()
				while task.wait() and auto_scroll_active do
					scrolling_container.CanvasPosition += auto_scroll_direction
				end
			end)
		end
		auto_scroll_active = active
		local norm = lune.utils.normalize_mouse(
			direction,
			scrolling_container.AbsolutePosition,
			scrolling_container.AbsoluteSize
		)

		auto_scroll_direction =
			Vector2.new(((norm.X < 0.3 and (norm.X - 0.3)) or (norm.X > 0.8 and (norm.X - 0.8)) or 0) * 40, 0)
	end

	local selected_clip_button
	local selected_clip_ui_stroke
	local selected_clip_track
	local selected_clip_seconds
	local function set_selected_clip(track: number, seconds: number, button: TextButton, stroke: UIStroke)
		if selected_clip_button then
			if selected_clip_button.Parent ~= nil then
				lune.theme_manager:force_highlight(selected_clip_button, false)
			end
		end
		if selected_clip_ui_stroke then
			selected_clip_ui_stroke.Enabled = false
		end
		selected_clip_track = track
		selected_clip_seconds = seconds
		selected_clip_button = button
		selected_clip_ui_stroke = stroke
		selected_clip_ui_stroke.Enabled = true
		lune.theme_manager:force_highlight(selected_clip_button, true)
	end
	local function reset_selected_clip()
		selected_clip_button = nil
	end

	local progress_line = lune.textbutton("", scrolling_container)
	do
		progress_line.ZIndex = 10
		progress_line.AutomaticSize = Enum.AutomaticSize.None
		progress_line.Size = UDim2.new(0, 4, 1, 0)
		lune.theme_manager:force_highlight(progress_line, true)
	end
	local function set_time(seconds: number)
		current_time = seconds
		progress_line.Position = UDim2.fromOffset(current_time * pixel_per_second, 0)
	end

	local time_container

	local function genereate_time()
		-- genereates time stamps ontop of scrolling container
		if time_container then
			time_container:Destroy()
		end
		local animation_length = scrolling_container.AbsoluteCanvasSize.X / pixel_per_second
		local container = lune.empty_frame()
		container.Size = UDim2.fromOffset(scrolling_container.AbsoluteCanvasSize.X, 32)
		local previous_label = nil
		for i = 1, animation_length do
			if previous_label then
				local previous_label_right_x = previous_label.AbsoluteSize.X + previous_label.AbsolutePosition.X
				if i * pixel_per_second <= previous_label_right_x then
					continue
				end
			end
			local date_string = `{os.date("%M:%S", i)}`
			local label = lune.textlabel(date_string, container)
			label.TextWrapped = false
			label.AnchorPoint = Vector2.new(0.5, 0.0)
			label.Position = UDim2.fromOffset(i * pixel_per_second, 0)

			local computed_size =
				TextService:GetTextSize(date_string, 16, Enum.Font.BuilderSans, Vector2.new(math.huge, math.huge))
			previous_label = {
				AbsoluteSize = computed_size,
				AbsolutePosition = Vector2.new(i * pixel_per_second, 0),
			}
		end

		local time_changer_button = lune.textbutton("", container)
		lune.utils.mouse_drag(time_changer_button, function(a0: Vector2)
			if player.playing_state == "playing" then
				return
			end
			local norm = lune.utils.normalize_mouse(a0, container.AbsolutePosition, container.AbsoluteSize)
			local seeked_time = animation_length * norm.X
			set_time(seeked_time)
			player.seek(seeked_time)
			auto_scroll(a0, true)
		end, function()
			auto_scroll(Vector2.zero, false)
		end)
		time_changer_button.Size = container.Size
		time_changer_button.Transparency = 1
		time_container = container
		container.Parent = scrolling_container
	end
	local function mouse_position_to_time(a0: Vector2)
		local norm_button_left_size =
			lune.utils.normalize_mouse(a0, scrolling_container.AbsolutePosition, scrolling_container.AbsoluteSize)
		-- get current time of the clip w canvas position and abs window size
		local start = scrolling_container.CanvasPosition.X
		local ending = (scrolling_container.CanvasPosition.X + scrolling_container.AbsoluteWindowSize.X)
		return math.lerp(start, ending, norm_button_left_size.X) / pixel_per_second
	end
	local function generate_track(track: number)
		-- generates track with clips
		-- genereate humanoid preview of animation
		if track_uis[track] then
			track_uis[track]:Destroy()
		end
		local track_container = lune.empty_frame(scrolling_container)
		lune.styling.stroke(track_container)
		lune.styling.corner(track_container)
		track_container.AutomaticSize = Enum.AutomaticSize.XY
		track_container.Name = track
		track_container.Position = UDim2.fromOffset(0, (track == 1 and 32 or 64) * track)
		track_container.Size = UDim2.new(1, 0, 0, 64)
		for seconds, clip in animation.get_track(track) do
			local rounded_seconds = math.ceil(seconds * pixel_per_second)
			local rounded_clip_end = math.ceil(animation.compute_clip_length(track, seconds) * pixel_per_second)

			local selected_stroke = lune.styling.stroke()
			selected_stroke.Thickness = 12
			selected_stroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
			selected_stroke.Enabled = false
			local button
			button = lune.iconbutton({
				parent = track_container,
				id = utils.generate_asset_thumb({ { Id = clip.asset_id, ItemType = "Asset" } }),
				aspect_ratio = false,
				on_click = function()
					set_selected_clip(track, seconds, button, selected_stroke)
				end,
			})
			selected_stroke.Parent = button

			button.AutomaticSize = Enum.AutomaticSize.None
			button.Position = UDim2.fromOffset(rounded_seconds, 0)
			button.Size = UDim2.new(0, rounded_clip_end, 0, 64)
			local drop_at_seconds = nil
			local button_mode: ("Drag" | "Resize")?
			local resize_mode_last_x_cord = nil
			local resize_mode_left_seconds = nil
			local resize_mode_right_seconds = nil

			local resize_mode_left = nil
			local resize_mode_right = nil
			lune.utils.mouse_drag(button, function(a0, local_pos, local_pos_norm, size)
				auto_scroll(a0, true)
				if not button_mode then
					if local_pos.X <= 24 or local_pos.X >= size.X - 24 then
						button_mode = "Resize"
					else
						button_mode = "Drag"
					end
				end
				if button_mode == "Resize" then
					button.Transparency = 0.8
					if not resize_mode_last_x_cord then
						resize_mode_last_x_cord = a0.X
						return
					end
					if resize_mode_left == nil or resize_mode_right == nil then
						resize_mode_left = local_pos.X <= 24
						resize_mode_right = local_pos.X >= size.X - 24
					end

					local delta = a0.X - resize_mode_last_x_cord
					local resize_to_seconds = mouse_position_to_time(a0)
					set_time(resize_to_seconds)
					if resize_mode_left then
						-- animation_start
						resize_mode_left_seconds = resize_to_seconds
						local resize = math.clamp(
							clip.animation_start + (delta / pixel_per_second),
							0,
							clip.animation_end
						) * pixel_per_second
						button.AnchorPoint = Vector2.new(1, 0)
						button.Position = UDim2.fromOffset(rounded_seconds + rounded_clip_end, 0)
						button.Size = UDim2.fromOffset((clip.animation_end * pixel_per_second) - resize, 64)
					else
						-- animation_end
						resize_mode_right_seconds = resize_to_seconds
						button.Size = UDim2.fromOffset(
							math.clamp(
								(rounded_clip_end / pixel_per_second) + (delta / pixel_per_second),
								0,
								clip.animation_length
							) * pixel_per_second,
							64
						)
					end
					-- resize the ui THEN we actually resize
					return
				else
					local norm = lune.utils.normalize_mouse(
						a0,
						scrolling_container.AbsolutePosition,
						scrolling_container.AbsoluteSize
					)

					-- button.AnchorPoint = Vector2.new(1.0, 0.5)
					button.Position = UDim2.fromScale(norm.X, norm.Y)
					button.Parent = container
					drop_at_seconds = mouse_position_to_time(a0)
					set_time(drop_at_seconds)
					return
				end
			end, function()
				auto_scroll(Vector2.zero, false)
				if drop_at_seconds then
					if math.abs(drop_at_seconds - seconds) > 0.1 then
						button:Destroy()
						reset_selected_clip()
						animation.move_animation_clip(track, seconds, drop_at_seconds)
						return
					end
				end
				if button_mode == "Resize" then
					reset_selected_clip()
					print(
						`Clip is at {seconds}, Animation Start {resize_mode_left_seconds} ; Animation End {resize_mode_right_seconds}`
					)
					animation.resize_animation_clip(track, seconds, resize_mode_left_seconds, resize_mode_right_seconds)
					return
				end
				button.Parent = track_container
				button.AnchorPoint = Vector2.new(0.0, 0.0)
				button.Position = UDim2.fromOffset(rounded_seconds, 0)
				button_mode = nil

				-- generate_track(track)
			end)
		end
		lune.styling.stroke(track_container)
		track_uis[track] = track_container
	end

	local function generate_all_tracks()
		for track, clip_list in animation.get_all_tracks() do
			generate_track(track)
		end
		genereate_time()
	end

	animation.events.on_animation_modified.connect(function(parm)
		if parm.event == "track_remove" then
			-- refresh track
			track_uis[parm.track]:Destroy()
		end
		if parm.event == "track_update" then
			generate_track(parm.track)
			genereate_time()
		end
	end)

	generate_all_tracks()

	lune.button_holder({
		parent = inner_container,
		left = {
			lune.iconbutton({
				id = shared.icons.add,
				theme_enabled = true,
				tooltip = "Add Track",
				on_click = function() end,
			}),
			lune.iconbutton({
				id = shared.icons.duplicate,
				theme_enabled = true,
				tooltip = "Duplicate",
				on_click = function() end,
			}),
			lune.iconbutton({
				id = shared.icons.split,
				theme_enabled = true,
				tooltip = "Split",
				on_click = function()
					if selected_clip_button then
						animation.split_animation_clip(selected_clip_track, selected_clip_seconds, current_time)
					end
				end,
			}),
			lune.iconbutton({
				id = shared.icons.delete,
				theme_enabled = true,
				tooltip = "Delete",
				on_click = function()
					if selected_clip_button then
						animation.remove_animation_clip(selected_clip_track, selected_clip_seconds)
					end
				end,
			}),
		},
		centre = {
			lune.state.watch_table_ui(
				lune.iconbutton({
					id = shared.icons.play,
					theme_enabled = true,
					tooltip = "Play",
					on_click = function()
						if player.playing_state == "playing" then
							player.pause()
						else
							player.load_animation(animation)
							player.play()
						end
					end,
				}),
				{
					key = "_playing_state",
					watch = player,
					eval_type = "compare",
					eval_argument = "playing",
				}
			),
			lune.iconbutton({
				id = shared.icons.stop,
				theme_enabled = true,
				tooltip = "Stop",
				on_click = function()
					player.stop()
				end,
			}),
		},
		right = {

			lune.iconbutton({
				id = shared.icons.music,
				theme_enabled = true,
				tooltip = "Add Music",
				on_click = function() end,
			}),

			lune.iconbutton({
				id = shared.icons.zoom_in,
				theme_enabled = true,
				tooltip = "Zoom In",
				on_click = function()
					pixel_per_second += 10
					generate_all_tracks()
				end,
			}),
			lune.iconbutton({
				id = shared.icons.zoom_out,
				theme_enabled = true,
				tooltip = "Zoom Out",
				on_click = function()
					pixel_per_second -= 10
					pixel_per_second = math.clamp(pixel_per_second, 8, math.huge)
					generate_all_tracks()
				end,
			}),
		},
	})

	player.events.time_position_change.connect(function(parm)
		set_time(parm.time)
	end)
	return container
end
