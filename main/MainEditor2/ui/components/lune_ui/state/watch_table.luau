--!strict
type WatchingInstance = {
	reference_count: number,
	stored: any,
	evaluate_functions: {
		[string]: (value: any) -> any,
	},
}
type Watching = { [any]: { [string]: WatchingInstance } }
type Arguments = {
	watched_table: {},
	key: string,
	evaluate: (value: any) -> (),
}
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
--attaches a gui element to a state
local watching = {} :: Watching

task.spawn(function()
	while RunService.Heartbeat:Wait() do
		-- track each changes to heartbeat
		for watched_table, watched in watching do
			for key, watched_instance in watched do
				if watched_instance.reference_count == 0 then
					watched[key] = nil
					continue
				end
				if watched_table[key] == watched_instance.stored then
					continue
				else
					watched_instance.stored = watched_table[key]
					for _, eval in watched_instance.evaluate_functions do
						eval(watched_instance.stored)
					end
				end
			end
		end
	end
end)

return function(args: Arguments)
	local generated_eval_function_id = HttpService:GenerateGUID()
	if not watching[args.watched_table] then
		watching[args.watched_table] = {
			[args.key] = {
				reference_count = 1,
				stored = args.watched_table[args.key],
				evaluate_functions = {
					[generated_eval_function_id] = args.evaluate,
				},
			},
		}
	else
		-- increase reference_count, and add to evaluate_functions
		watching[args.watched_table][args.key].reference_count += 1
		watching[args.watched_table][args.key].evaluate_functions[generated_eval_function_id] = args.evaluate
	end

	return {
		disconnect = function()
			watching[args.watched_table][args.key].reference_count -= 1
			watching[args.watched_table][args.key].evaluate_functions[generated_eval_function_id] = nil
		end,
	}
end
