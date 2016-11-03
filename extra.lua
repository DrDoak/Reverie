----
-- extra.lua
-- 
-- This file holds a bunch of miscellaneous utility functions that use other
-- libraries. Unlike util.lua, these functions are tied much more directly
-- to the game itself.
----

local Scene = require "xl.Scene"
local anim8  = require "anim8"
local Gamestate = require "hump.gamestate"
local MaxMessageTime = 2
local Messages = {}

local font_cache = {}
local DEFAULT_FONT = "assets/fonts/DejaVuSans.ttf"

local xl = {
	Sprite  = require "xl.Sprite",
	DScreen = require "xl.DScreen",
}

function xl.AddMessage(msg)
	table.insert(Messages, {msg = msg, time = love.timer.getTime()})
end

function xl.DrawMessages()
	local loveGraphics = love.graphics
	local font = xl.getFont()
	loveGraphics.setFont( font )
	local y = loveGraphics.getHeight() - 5
	for i=#Messages,1,-1 do
		y = y - font:getHeight()
		local ratio = (love.timer.getTime() - Messages[i].time) / MaxMessageTime
		if ratio >= 1 then
			table.remove(Messages, i)
		else
			local alpha = 255 * math.min(1 - ratio + 0.25, 1)
			loveGraphics.setColor(240,240,240,alpha)
			loveGraphics.printf(Messages[i].msg, 5, y, 9900, "left")
		end
	end
end

function xl.SHOW_HITBOX (hbox)
	local loveGraphics = love.graphics
	local node
	local drawFunc = function()
		local floor = math.floor
		local ok, shape = pcall(hbox.getShape, hbox)
		if not ok then
			Game.scene:remove( node )
		else
			local bx,by = hbox:getBody():getPosition()
			loveGraphics.push()
			loveGraphics.translate( bx, by + 16 )
			loveGraphics.rotate(hbox:getBody():getAngle())
			loveGraphics.setColor(50, 200, 50)
			local ty = tostring( shape )
			if ty == "ChainShape" or ty == "EdgeShape" then
				loveGraphics.line( shape:getPoints() )
			elseif ty == "PolygonShape" then
				love.graphics.polygon( "fill", shape:getPoints() )
			elseif ty == "CircleShape" then
				local x,y = shape:getPoint()
				local r = shape:getRadius()
				loveGraphics.circle( "fill", x, y, r, 20 )
			end
			loveGraphics.setColor(255, 255, 255)
			loveGraphics.pop()
		end
    end
	node = Scene.wrapNode({draw = drawFunc}, 9900)
	Game.scene:insert(node)
	return node
end

function xl.newGrid( frameWidth, frameHeight, ... )
	frameWidth = tonumber(frameWidth)
	frameHeight = tonumber(frameHeight)
	local args = {...}
	if type(args[1]) == "string" then
		args[1] = love.graphics.newImage( args[1] )
	end
	if type(args[1]) == "userdata" then
		local img = args[1]
		args[1] = img:getWidth()
		table.insert(args, 2, img:getHeight())
	end
	return anim8.newGrid(frameWidth, frameHeight, unpack(args))
end

function xl.newSprite(image, frameWidth, frameHeight, border, z)
	if type(image) == "string" then
		image = love.graphics.newImage( image )
	end
	local grid = anim8.newGrid(frameWidth, frameHeight, image:getWidth(), image:getHeight(), 0, 0, border or 0)
	local spr = xl.Sprite(image, 0, 0, z or 0)
	spr.grid = grid
	return spr, grid
end

-- Returns: scale, scissorX, scissorY, scissorW, scissorH, offsetX, offsetY
function xl.calculateViewport(sizes, winW, winH, scaleInterval, screenFlex )
	local gameW,gameH = sizes.w, sizes.h
	local screenW,screenH = winW + screenFlex, winH + screenFlex
	local scale = math.min(screenW / gameW, screenH / gameH)
	scale = math.floor(scale * scaleInterval) / scaleInterval
	local scissorW, scissorH = gameW * scale, gameH * scale
	local scissorX, scissorY = (winW - scissorW) / 2, (winH - scissorH) / 2
	local offsetX, offsetY = scissorX / scale, scissorY / scale
	return scale, scissorX, scissorY, scissorW, scissorH, offsetX, offsetY
end

function xl.getFont( size )
	size = size or 12
	if not font_cache[size] then
		local font = love.graphics.newFont(DEFAULT_FONT, size)
		font_cache[size] = font
	end
	return font_cache[size]
end

function xl.pushState( state, ... )
	Gamestate.push( state, ... )
end

function xl.switchState( state, ... )
	Gamestate.switch( state, ... )
end

-- disable xl.SHOW_HITBOX
-- xl.SHOW_HITBOX = function () end

return xl
