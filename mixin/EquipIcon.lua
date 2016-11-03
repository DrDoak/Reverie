
local Scene = require "xl.Scene"
local Transformable = require "xl.Transformable"

local EquipIcon = Class("EquipIcon")
EquipIcon.__lt = Scene.lessThan
EquipIcon.__le = Scene.lessThan
EquipIcon.setPosition = Transformable.setPosition

function EquipIcon:init( icon )
	self.fgcolor = { 255, 255, 255 }
	self.bgcolor = { 0, 0, 0 }
	self.x = 0
	self.y = 0
	self.width = 32
	self.height = 32
	self.z = 0
	self.baseImage = love.graphics.newImage( "assets/HUD/interface/item_small.png")
	if icon then
		self.image = icon
	else
		self.image = love.graphics.newImage( "assets/HUD/interface/empty.png" )
	end
	Scene.makeNode( self )
end

function EquipIcon:setImage( image )
	if image then
		self.image = image
	else
		self.image = love.graphics.newImage( "assets/HUD/interface/empty.png" )
	end
end

function EquipIcon:setCount( count )
	self.count = count
end

function EquipIcon:update( dt )
end

function EquipIcon:draw(  )
	love.graphics.draw(self.baseImage, self.x, self.y,0,0.75,0.75)
	if self.image then
		love.graphics.draw( self.image, self.x + 19, self.y + 16)
		if self.count and self.count > 1 then
			love.graphics.print(self.count , self.x + 60, self.y + 58)
		end
	end
end

return EquipIcon
