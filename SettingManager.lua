----
-- SettingManager.lua
--
-- Manages all the game's settings and options.
----

local Keymap = require "xl.Keymap"

local SettingManager = {}

SettingManager.DefaultSettings = {
	keys = {
		exit    = "escape",
		up      = "w",
		down    = "s",
		left    = "a",
		right   = "d",
		jump    = "space",
		inv     = "o",
		use     = "k",
		debug   = "-",
		lockon	= "j",
		dash	= "l",
		interact    = "i",
		screenshot  = "f1",
		fullscreen  = "f11",
		menuEnter = "return",
		menuUp = "up",
		menuDown = "down",
		menuLeft = "left",
		menuRight = "right",
		clip = "y",
		reset = "r",
	},
	options = {
		vsync = true
	}
}

SettingManager.currentSettings = {
	keys = util.copytableS( SettingManager.DefaultSettings.keys ),
	options = util.copytableS( SettingManager.DefaultSettings.options )
}

-- this is the game's timestep
-- it's in settings because the timestep counter is weird
SettingManager.timestep = 1/70

----
-- Perform processing of all the settings.
-- If you want to change the settings then change the settings table
-- and call processSettings again.
--
-- @param {table} ss - Table containing settings. See startup.DefaultSettings
--        for more information
----
function SettingManager.processSettings( ss )
	local function nilOr( value, default )
		if value == nil then
			return default
		else
			return value
		end
	end
	if ss.keys then
		for k,v in pairs(ss.keys) do
			Keymap.setkey(k,v)
		end
	end
	-- make sure we copy only keys we want for security purposes
	local ssopts = ss.options
	local opts = {
		vsync = nilOr(ssopts.vsync, true)
	}
	love.window.setMode( GAME_SIZE.w, GAME_SIZE.h, opts )
	if opts.vsync then
		SettingManager.timestep = 1/100
	else
		SettingManager.timestep = 1/70
	end
end

----
-- Load the settings from the file and process them.
-- 
-- @param {string} filename - name of the settings file to read
----
function SettingManager.loadSettings( filename )
	local ok, chunk, ss
	if not love.filesystem.isFile( filename ) then return true end
	chunk = love.filesystem.read( filename )
	ok = SettingManager.readSettings( chunk )
	if not ok then return false end
	SettingManager.processSettings( ok )
	return true
end

----
-- Read settings files and convert them to tables
-- 
-- @param {string} text - settings text
----
function SettingManager.readSettings( text )
	local sectionPattern = "%[(%w+)%]"
	local kvPattern = "%s*(%w+)%s*=%s*(.+)%s*"
	local commentPattern = "^(%#.*)"
	local linePattern = "(.-)\r?\n"

	local result = {}
	local section = nil
	for line in text:gmatch( linePattern ) do
		if not line:match( commentPattern ) then
			local sec = line:match( sectionPattern )
			if sec then
				if sec == "" then
					return nil
				end
				section = sec
				result[section] = result[section] or {}
			else
				local k,v = line:match( kvPattern )
				if (k or v) and not (k and v) then
					return nil
				end
				if v == "true" then v = true end
				if v == "false" then v = false end
				v = tonumber(v) or v
				result[section][k] = v
			end
		end
	end
	return result
end

return SettingManager
