----
-- main.lua
--
-- The entry-point of all Love2D games. This is where everything starts.
----

-- lock the global namespace so trying to create a global variable causes and error
local Global = require "libs.Global"
Global.lock()

-- add these values as global variables
Global( "util","lume","Class","Log","Game","Entity","xl" )

-- Initialize the values. Order is important here.
util    = require "util"
lume    = require "libs.lume"
Class   = require "libs.class"
Log     = require "xl.Log"
Game    = require "MGame"
Entity  = require "objects.Entity"
xl      = require "extra"

-- load more libraries which we will need
local Signal    = require "hump.signal"
local Gamestate = require "hump.gamestate"
local Timer     = require "hump.timer"
local startup   = require "startup"
local Keymap    = require "xl.Keymap"
local MainMenu  = require "state.MainMenu"


-- let's have some settings!
local Settings = require "SettingManager"
-- the (intended) framerate and world:update( dt ) time
local next_time = 0

-- Love2D callbacks
function love.load(args)
	startup.sanityCheck()
	Settings.processSettings( Settings.DefaultSettings )
	if not Settings.loadSettings("settings.txt") then
		xl.AddMessage("Invalid settings file")
	end
	startup.dothings()
	Gamestate.switch( Game )
	Gamestate.push( MainMenu )

	next_time = love.timer.getTime()
end

function love.update( dt )
	next_time = next_time + Settings.timestep
	love.window.setTitle( "FPS: " .. love.timer.getFPS() )
	Gamestate.update( dt )
	Timer.update( dt )
end

function love.draw()
	Gamestate.draw()
	xl.DScreen.draw()
	-- xl.TextInterface.draw()
	xl.DrawMessages()

	-- clear events after everything else
	Keymap.clearEvents()

	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
end

local function delegate_signal( name, ... )
	if not Gamestate[name]( ... ) then
		Signal.emit( name, ... )
	end
end

local function delegate_keymap( name, ... )
	if not Gamestate[name]( ... ) then
		Signal.emit( name, ... )
		Keymap[name]( ... )
	end
end

-- args: key, isrepeat
function love.keypressed( key, isrepeat )
	delegate_keymap( "keypressed", key, isrepeat )
end

-- args: key, isrepeat
function love.keyreleased( ... )
	delegate_signal( "keyreleased", ... )
end

-- args: x, y, button
function love.mousepressed( ... )
	delegate_signal( "mousepressed", ... )
end

-- args: x, y, button
function love.mousereleased( ... )
	delegate_keymap( "mousereleased", ... )
end

-- args: w, h
function love.resize( ... )
	Game:resize( ... )
	if Gamestate.current() ~= Game then
		delegate_signal( "resize", ... )
	end
end
