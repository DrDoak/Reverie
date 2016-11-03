
local Scene = require "xl.Scene"
local Transformable = require "xl.Transformable"

local Healthbar = Class("Healthbar")
Healthbar.__lt = Scene.lessThan
Healthbar.__le = Scene.lessThan
Healthbar.setPosition = Transformable.setPosition

function Healthbar:init( max, width, height )
	self.fgcolor = { 255, 255, 255 }
	self.bgcolor = { 0, 0, 0 }
	self.x = 0
	self.y = 0
	self.max = max
	self.value = max
	self.redValue = max
	self.width = width or max
	self.height = height or 10
	self.z = 0
	Scene.makeNode( self )
end

function Healthbar:setImage( image )
	if image then
		self.quad = love.graphics.newQuad( 0, 0, 1, 1, image:getDimensions() )
		self.image = image
		image:setWrap("repeat", "repeat")
	else
		self.image = nil
	end
end

function Healthbar:update( dt )
end

function Healthbar:draw(  )
	local loveGraphics = love.graphics
	local valuewidth = (self.value / self.max) * self.width
	loveGraphics.setColor( self.bgcolor )
	loveGraphics.rectangle( "fill", self.x, self.y, self.width + 2, self.height + 2 )
	loveGraphics.setColor( self.fgcolor )
	if self.image then
		self.quad:setViewport( 0, 0, valuewidth, self.height )
		loveGraphics.draw( self.image, self.quad, self.x, self.y + 1 )
	else
		loveGraphics.rectangle( "fill", self.x + 1, self.y + 1, valuewidth, self.height )
	end
	if self.redcolor then
		loveGraphics.setColor( self.redcolor )
		valuewidth = (self.redValue / self.max) * self.width
		loveGraphics.rectangle( "fill", self.x + 1, self.y + 1, valuewidth, self.height )
	end
	loveGraphics.setColor( 255,255,255 )
end

return Healthbar
