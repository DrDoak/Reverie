----
-- xl/Background.lua
--
-- This represents a background. Backgrounds can, and should, be added to
-- Scenes.
----

local Scene = require "xl.Scene"

local Background = Class("Background")
Background.__lt = Scene.lessThan
Background.__le = Scene.lessThan

---- 
-- Utility function for rounding x upwards to the nearest multiple of d
----
local function roundblock_up( x, d )
	return math.ceil( x / d ) * d
end

function Background:init( imagepath, ywrap, xstart, ystart, depth, xspeed, yspeed )
	self.image = love.graphics.newImage( imagepath )
	self.imagepath = imagepath
	self.ywrap = ywrap
	ywrap = ywrap and "repeat" or "clamp"
	self.image:setWrap( "repeat", ywrap )
	self.xstart = xstart
	self.ystart = ystart
	self.xspeed = xspeed
	self.yspeed = yspeed
	self.invXspeed = 1 / self.xspeed
	self.invYspeed = 1 / self.yspeed
	self.z = depth
	Scene.makeNode( self )

	-- now create the all-important quad
	local imageWidth, imageHeight = self.image:getDimensions()
	self.imgWidth = imageWidth
	self.width = roundblock_up( GAME_SIZE.w, imageWidth ) * self.invXspeed
	self.height = ywrap and roundblock_up( GAME_SIZE.h * 2, imageHeight ) or imageHeight
	self.quad = love.graphics.newQuad( 0, 0, self.width * 2, self.height * 2, self.image:getWidth(), self.image:getHeight() )

	self.prevX , self.prevY = Game.cam:pos()

	-- set x and y
	self.x = self.xstart + ((self.prevX - ( GAME_SIZE.w/2) - self.xstart) * self.xspeed)
	self.y = self.ystart + ((self.prevY - ( GAME_SIZE.h/2) - self.ystart) * self.yspeed)
	self.offsetx = 0

	-- automatically insert self into Game.backgrounds
	Game.backgrounds:insert( self )
end

function Background:update( dt )
	local cx,cy = Game.cam:pos()

	self.offsetx = (cx - self.prevX) * self.xspeed
	self.prevX = cx
	self.x = self.x + self.offsetx

	self.offsety = (cy - self.prevY) * self.yspeed
	self.prevY = cy
	self.y = self.y + self.offsety

	if self.ywrap then
		--self.y = gy - ( (cy - gy) * self.yspeed )
	else
		-- self.y = self.ystart
	end
end

function Background:draw( )
	
	love.graphics.draw( self.image, self.quad, self.x, self.y )
end

return Background