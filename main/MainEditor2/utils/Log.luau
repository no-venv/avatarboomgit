local Log = {}

function Log:Warn(s)
	print(`[warn] {s}`)
end

function Log:Error(s)
	print(`[error] {s}`)
end

function Log:Info(s)
	print(`[info] {s}`)
end

return Log
