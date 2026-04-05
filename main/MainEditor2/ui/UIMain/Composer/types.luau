--!strict
export type InterpolationType = "LINEAR"
export type KeyframeData = {
	property: string,
	value: any,
	interpolation: InterpolationType,
}
export type Keyframe = {
	keyframes: { KeyframeData },
	time: number,
}
export type Audio = {
	name: string,
	is_file: boolean,
	asset_id: string,
	data: string,
}
export type Animation = {
	data: {
		audio: { Audio },
		[string]: any,
	},

	keyframes: {
		-- keyframes contains the relative path of the instance
		[string]: { Keyframe },
	},
	model: {
		-- absolute path to the model/instance
		[string]: number,
	},
}

return {

	new_animation = function()

	end,

}
