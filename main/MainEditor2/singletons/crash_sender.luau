--!strict
type struct = {}
type Impl = {
	start: () -> "OK" | "MORE_THAN_ONE_INSTANCE" | "HTTP_FAIL",
	stop: () -> (),
	allow_script: (name: string) -> (),
}

local EncodingService = game:GetService("EncodingService")
local HttpService = game:GetService("HttpService")
local ScriptContext = game:GetService("ScriptContext")
local shared = require("../shared")
local utils = require("../utils")
local on_script_error: RBXScriptConnection?
local allowed_scripts = { ["MainEditor2"] = true }

local function hash(string: string)
	return buffer.tostring(
		EncodingService:Base64Encode(
			buffer.fromstring(EncodingService:ComputeStringHash(string, Enum.HashAlgorithm.Md5))
		)
	)
end
local function to_stack_frames(stackTraceString)
	local frames = {}
	-- Split the string by newlines
	for line in stackTraceString:gmatch("[^\r\n]+") do
		table.insert(frames, 1, {
			instruction_addr = line,
		})
	end
	return frames
end

local crashlytics = {} :: Impl

crashlytics.start = function()
	if on_script_error then
		warn("More than one instance of crashlytics is not supported")
		return "MORE_THAN_ONE_INSTANCE"
	end

	local ok, result = pcall(function(...)
		local request = HttpService:RequestAsync({
			Url = "http://ask_plugin_permissions.avatarboom.qzz.io",
			Compress = Enum.HttpCompression.Gzip,
		})
		return request.Success
	end)
	if not ok then
		warn(`AvatarBOOM automatic crash log collection cannot connect to server: {result}`)
		return "HTTP_FAIL"
	end
	on_script_error = ScriptContext.Error:Connect(function(message, trace, script)
		local allowed = "MainEditor2"
		if message:find(allowed :: string) then
			local full_log = `{message}\n\n{trace}`
			local event_id = HttpService:GenerateGUID(false)
			local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time())
			local envelope = HttpService:JSONEncode({
				event_id = event_id,
				sent_at = timestamp,
			})
			local item = HttpService:JSONEncode({ type = "event", content_type = "application/json" })
			local encoded_payload = HttpService:JSONEncode({
				event_id = event_id,
				timestamp = timestamp,
				level = "error",
				platform = "other",
				fingerprint = {
					hash(full_log),
				},
				exception = {
					values = {
						{
							type = "Error",
							value = message,
							stacktrace = {
								frames = to_stack_frames(trace),
							},
						},
					},
				},
			})
			local ok, http_failure = pcall(function(...)
				return HttpService:RequestAsync({
					Url = `https://bugs.avatarboom.qzz.io`,
					Method = "POST",
					Body = table.concat({ envelope, item, encoded_payload }, "\n"),
					Compress = Enum.HttpCompression.None,
				})
			end)
			if not ok then
				warn(`AvatarBOOM failed sending the automated bug report: {http_failure}`)
			end
		end
	end)
	local janitor = utils.ui_labs.Environment.GetJanitor()
	-- for ui-labs to prevent memory leaks while debugging
	-- this is not an issue with plugin releases since the scripts will
	-- actually stop running
	if janitor then
		if on_script_error then
			janitor:Add(on_script_error)
		end
	end
	return "OK"
end

crashlytics.stop = function()
	if on_script_error then
		on_script_error:Disconnect()
		on_script_error = nil
	end
end

crashlytics.allow_script = function(name)
	allowed_scripts[name] = true
end

if shared.settings.send_crash_logs.value then
	crashlytics.start()
end
shared.settings.send_crash_logs.changed.connect(function(parm)
	if parm.value then
		crashlytics.start()
	else
		crashlytics.stop()
	end
end)
return crashlytics
