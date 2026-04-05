local Provider = game:GetService("KeyframeSequenceProvider")
local InsertService = game:GetService("InsertService")
local animation_legnth_cache = {}
local animation_object_cache = {}
local animation_keyframe_cache = {}
local animation_r6_cache = {}

type UtilsImpl = {
	preload_animation_object : (animation : number) -> (),
	get_animation_length : (animation : number) -> (),
	get_keyframe_cache : (animation : number) -> (),
	convert_animation_to_r6 : (animation : number) -> (),
}
local self = {}
self.preload_animation_object = function(animation: number)
	-- preloads the animation and keyframes
	if animation_object_cache[animation] then
		return animation_object_cache[animation]
	end
	local animation_model = InsertService:LoadAsset(animation)
	local animation_object = animation_model:FindFirstChildOfClass("Animation")
	if not animation_object then
		-- el oh el
		print("animation object not found")
		return
	end
	animation_object_cache[animation] = animation_object
	animation_keyframe_cache[animation] = Provider:GetKeyframeSequenceAsync(animation_object.AnimationId)
	return animation_object
end
self.get_animation_length = function(animation: number)
	-- Bruh
	if animation_legnth_cache[animation] then
		return animation_legnth_cache[animation]
	end

	self.preload_animation_object(animation)
	local Sequence = animation_keyframe_cache[animation]
	local Keyframes = Sequence:GetKeyframes()
	local Length = 0
	for i = 1, #Keyframes do
		local Time = Keyframes[i].Time
		if Time > Length then
			Length = Time
		end
	end

	animation_legnth_cache[animation] = Length
	return Length
end
self.get_keyframe_cache = function(animation : number)
	return animation_keyframe_cache[animation] 
end
self.convert_animation_as_r6 = function(animation: number)
	-- if animation_r6_cache[animation] then
	-- 	return animation_r6_cache[animation]
	-- end

	-- local r6Sequence = require("./animation_converter").Convert(animation_keyframe_cache[animation])
	-- local compiled_animation = Provider:RegisterKeyframeSequence(r6Sequence)
	-- local animation_object = Instance.new("Animation")
	-- animation_object.AnimationId = compiled_animation
	-- animation_r6_cache[animation] = animation
	-- return animation_object
end
return self
