----
-- startup.lua
-- 
-- This file contains numerous routines used when starting the game. This is
-- to help prevent main.lua from becoming too confusing.
----

local Keymap = require "xl.Keymap"
local Gamestate = require "hump.gamestate"
local DebugMenu = require "state.DebugMenu"
local ObjChar   = require "objects.ObjChar"
local InventoryMenu = require "state.InventoryMenu"

local startup = { window = {} }
----
-- Perform basic checks to ensure the graphics card has support for everything we need.
-- Fail with asserts if it doesn't.
----
function startup.sanityCheck()
	-- local function sancheck(s,m) assert(love.graphics.isSupported(s), "Your graphics card doesn't support " .. m) end
	-- sancheck("canvas", "Framebuffers.")
	-- sancheck("shader", "shaders")
	-- sancheck("subtractive", "the subtractive blend mode.")
	-- sancheck("npot", "non-power-of-two textures.")
end

function startup.takeScreenshot()
	local fname = string.format("%s/Screenshot %s.png", love.filesystem.getUserDirectory(), os.date("%Y-%m-%d_%H.%M.%S"))
	love.graphics.newScreenshot():encode("temp.png")
	util.moveFile("temp.png", fname)
	xl.AddMessage(string.format("Screenshot saved to '%s'",fname))
end

function startup.GotoDebugMenu(  )
	Gamestate.push( DebugMenu )
end

function startup.ToggleFullscreen(  )
	local fs = not love.window.getFullscreen()
	love.window.setFullscreen( fs, "normal" )
end

function startup.dothings()
	-- print out graphics card information
	local _, version, vendor, device = love.graphics.getRendererInfo()
	print( "OpenGL Version: " .. version .. "\nGPU: " .. device )

	-- otherwise sprites look weird
	love.graphics.setDefaultFilter("nearest", "nearest")
	-- default log level
	Log.setLevel("debug")
	xl.DScreen.toggle()
	-- screenshot function
	Keymap.pressed("screenshot", startup.takeScreenshot)
	-- debug menu
	Keymap.pressed("debug", startup.GotoDebugMenu)
	Keymap.pressed("fullscreen", startup.ToggleFullscreen)
	love.physics.setMeter(32)
	-- register Gamestate functions
	Gamestate.registerEvents({"focus", "mousefocus", "quit", "textinput", "threaderror", "visible"})
end

return startup
