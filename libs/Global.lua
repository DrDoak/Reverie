

-- This module is for locking the global table. Locking the global table
-- helps to mititgate spelling errors by causing a crash if an undefined
-- variable is created or used.

local glob = _G
local GLB = {}

local function index(t,k)
	error("Unknown global "..k, 2)
end

local function newindex(t,k,v)
	error("Creating global "..k, 2)
end

local function call(self, ...)
	local args = {...}
	if type(args[1]) == "table" then
		for k,v in pairs(args[1]) do
			rawset(glob, k, v)
		end
	else
		for i=1,#args do
			rawset(glob, args[i], false)
		end
	end
end

function GLB.lock()
	local mt = getmetatable(glob) or {}
	mt.__index, mt.__newindex = index, newindex
	setmetatable(glob, mt)
end

function GLB.unlock()
	local mt = getmetatable(glob) or {}
	mt.__index, mt.__newindex = nil, nil
	setmetatable(glob, mt)
end

-- create a new global variable even when the state is locked
function GLB.new(k, v)
	rawset(glob, k, v or false)
end

return setmetatable(GLB, {__call = call}) 
