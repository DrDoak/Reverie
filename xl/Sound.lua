----
-- xl/Sound.lua
-- 
-- A sound engine for Reverie. That's really all there is to it. 
----

local Timer = require "hump.timer"

-- Constant specifying how long to fade out the music
local MUSIC_FADE_TIME = 2

local effectsPath = "assets/sfx/"
local musicPath = "assets/music/"
local effects = {}
local music = {}
local currentMusic = nil

local Sound = {}

local function createPath( prefix, name )
	return prefix .. name
end

----
-- Play a sound effect.
-- @param {string} name - name of the asset. This should be in the folder
--        "assets/sfx/"
----
function Sound.playFX( name )
	local path = createPath( effectsPath, name )
	if not effects[path] then
		effects[path] = love.audio.newSource( path, "static" )
	end
	love.audio.play( effects[path] )
end

----
-- Cuts off the music.
-- This is an internal function.
----
local function musicHardStop()
	if currentMusic then
		currentMusic:stop()
		currentMusic = nil
	end
end

----
-- Fade out the music over MUSIC_FADE_TIME seconds. Once the fade is finished
-- run after().
-- This is an internal function.
----
local function fadeMusicOut( after )
	-- see hump.timer
	local function done()
		musicHardStop()
		if after then
			after()
		end
	end
	local volume = { 1.0 }
	Timer.tween( MUSIC_FADE_TIME, volume, { 0.0 }, "linear" )
	Timer.do_for( MUSIC_FADE_TIME, function ()
		currentMusic:setVolume( volume[1] )
	end, done)
end

----
-- Fade out the current background music.
----
function Sound.stopMusic()
	if currentMusic and currentMusic:isPlaying() then
		fadeMusicOut( nil )
	end
end

----
-- Access the current background music
-- @return the current background music or nil
----
function Sound.getMusic()
	return currentMusic
end

----
-- Plays background music. If there is already background music playing that
-- will be faded out before the new music starts playing. If {name} is nil
-- then the current music will be faded out and stopped.
-- @param {string} name - name of the music to play. This file should be in
--        "assets/music/"
----
function Sound.playMusic( name )
	assert( name, "Music name cannot be nil" )
	local path = createPath( musicPath, name )
	if not music[path] then
		music[path] = love.audio.newSource( path, "stream" )
		music[path]:setLooping( true )
	end
	local m = music[path]
	-- Using this function we can play the music the same way no matter
	-- how we go about it.
	local function playIt()
		currentMusic = m
		m:setVolume( 1.0 )
		m:play()
	end
	if currentMusic and currentMusic:isPlaying() then
		fadeMusicOut( playIt )
	else
		playIt()
	end
end

function Sound.get( name )
	return effects[name] or music[name]
end

return Sound