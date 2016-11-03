
local LogLevels = {}
local CurrentLevel = 500

local function addLevel(name, value, prefix)
	local lvl = {name = name, value = value, prefix = prefix}
	LogLevels[name] = lvl
	LogLevels[value] = lvl
end

local function validateLevel(inlevel)
	local lvl = LogLevels[inlevel]
	if lvl then
		return lvl.value
	elseif type(inlevel) == "number" then
		return inlevel
	else
		error("Invalid log level")
	end
end

local function message(level, ...)
	local lvl = validateLevel(level)
	if lvl >= CurrentLevel then
		-- local outmsg = string.format("%s|" .. fmt, LogLevels[lvl].prefix, ...)
		print(...)
	end
end

local function setLevel(level) CurrentLevel = validateLevel(level) end

addLevel("critical", 1000, "CRT")
addLevel("error",     900, "ERR")
addLevel("warn",      700, "WRN")
addLevel("info",      500, "INF")
addLevel("debug",     300, "DBG")
addLevel("verbose",   200, "VER")
addLevel("all",         0, "ALL")

local function makeShortcut(level) return function (...) message(level, ...) end end

local LOG = {
	critical = makeShortcut("critical"),
	error    = makeShortcut("error"),
	warn     = makeShortcut("warn"),
	info     = makeShortcut("info"),
	debug    = makeShortcut("debug"),
	verbose  = makeShortcut("verbose"),
	message  = message,
	setLevel = setLevel,
	addLevel = addLevel,
	where    = function ()
		local info = debug.getinfo(2)
		return string.format("%s:%i", info.name, info.currentline)
	end,
}

return LOG
