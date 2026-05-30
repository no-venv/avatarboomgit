local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CLIENT = RunService:IsClient()

export type Event<T> = {
	emit: (T) -> any,
	connect: ((parm: T) -> ()) -> integer,
	once: ((parm: T) -> ()) -> integer,
	disconnect: (id: integer) -> (),
}

export type TypedRemoteEvent<T, R> = {
	emit: ((player: Player, T) -> any) | ((T) -> any),
	emit_all: (T) -> any,
	emit_and_await: (T) -> R,
	connect: ((parm: T) -> ()) -> integer,
	once: ((parm: T) -> ()) -> integer,
	disconnect: (id: integer) -> (),
}

local function local_event()
	-- creates a typed signal object
	local connected = {}
	local func_id = 0
	return {
		emit = function(...)
			for _, func in connected do
				task.spawn(func, ...)
			end
		end,
		connect = function(connected_function)
			func_id += 1
			connected[func_id] = connected_function
			return func_id
		end,
		once = function(connected_function)
			func_id += 1
			local strong_func_id = func_id
			connected[strong_func_id] = function(...)
				connected_function(...)
				connected[strong_func_id] = nil
			end
			return strong_func_id
		end,
		disconnect = function(id: integer)
			connected[id] = nil
		end,
	}
end

local function global_event(group_name: string)
	-- creates a typed signal object
	local remote_id = 0
	local event_folder
	if CLIENT then
		event_folder = ReplicatedStorage:WaitForChild(group_name)
	else
		event_folder = Instance.new("Folder")
		event_folder.Name = group_name
		event_folder.Parent = ReplicatedStorage
	end
	return function(remote_type: "reliable" | "unreliable")
		local connected = {}
		local awaiting_id = 0
		local awaiting_threads = {}
		local client_connect_event: RBXScriptConnection?
		local server_connect_event: RBXScriptConnection?
		local func_id = 0
		remote_id += 1
		local remote: RemoteEvent & UnreliableRemoteEvent

		if CLIENT then
			remote = event_folder:WaitForChild(remote_id)
			client_connect_event = remote.OnClientEvent:Connect(function(...)
				local var = { ... }
				local remote_meta = var[#var]
				if type(remote_meta) == "table" then
					if remote_meta._request_id then
						coroutine.resume(awaiting_threads[remote_meta._request_id], ...)
						awaiting_threads[remote_meta._request_id] = nil
						return
					end
				end
				for _, func in connected do
					task.spawn(func, ...)
				end
			end)
		else
			remote = remote_type == "reliable" and Instance.new("RemoteEvent") or Instance.new("UnreliableRemoteEvent")
			remote.Name = remote_id
			remote.Parent = event_folder
			server_connect_event = remote.OnServerEvent:Connect(function(...)
				-- usually the last would contain the _request_id
				local var = { ... }
				local remote_meta = var[#var]
				if type(remote_meta) == "table" then
					if remote_meta._request_id then
						local result = { connected[1](...) }
						table.insert(result, remote_meta)
						remote:FireClient(var[1], table.unpack(result))
						return
					end
				end
				for _, func in connected do
					task.spawn(func, ...)
				end
			end)
		end
		return {
			emit = CLIENT and function(...)
				remote:FireServer(...)
			end or function(player, ...)
				remote:FireClient(player, ...)
			end,
			emit_all = function(...)
				if CLIENT then
					return
				else
					remote:FireAllClients(...)
				end
			end,
			emit_and_await = function(...)
				-- client only!
				if CLIENT then
					-- blocks the thread to await a response
					awaiting_id += 1
					local var = { ... }
					table.insert(var, { _request_id = awaiting_id })
					remote:FireServer(table.unpack(var))
					awaiting_threads[awaiting_id] = coroutine.running()
					return coroutine.yield()
				end
				return
			end,
			connect = function(connected_function)
				func_id += 1
				connected[func_id] = connected_function
				return func_id
			end,
			once = function(connected_function)
				func_id += 1
				local strong_func_id = func_id
				connected[strong_func_id] = function(...)
					connected_function(...)
					connected[strong_func_id] = nil
				end
				return strong_func_id
			end,
			disconnect = function(id: integer)
				connected[id] = nil
			end,
		}
	end
end

return {
	server = global_event,
	client = local_event,
}
