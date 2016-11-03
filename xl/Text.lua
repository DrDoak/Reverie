
local Transformable = require "xl.Transformable"
local Scene = require "xl.Scene"

-- function which creates a default font
local MakeFont = function (size)
	return love.graphics.newFont(size)
end

local DEFAULT_FONT = MakeFont(12)
local WHITE = {255,255,255}

local Text = Class.create("Text", Transformable, {
	__lt = Scene.lessThan,
	__le = Scene.lessThan,
})

function Text:init(msg, x, y, z,camera)
	self.message = msg
	self.x = x
	self.y = y
	self.z = z
	self.font = DEFAULT_FONT
	self.ptsize = 20
	self.color = WHITE
	self.camera = camera or false
	Transformable.init(self)
	Scene.makeNode(self)
end
function Text:setPtsize(size)
	self.ptsize = size
	self.font = MakeFont(size)
end
function Text:setColor( r,g,b,a )
	self.color = {r, g , b ,a}
end
function Text:setPosition( x,y )
	self.x = x
	self.y = y
end
function Text:draw()
	love.graphics.setColor(self.color)
	love.graphics.setFont(self.font)
	if not self.camera then Game:nocamera(true) end
	love.graphics.print(self.message, self.x, self.y, self.angle, self.sx, self.sy, self.originx, self.originy)
	if not self.camera then Game:nocamera(false) end
	love.graphics.setColor(WHITE)
end
function Text:update(dt)
end

return Text
