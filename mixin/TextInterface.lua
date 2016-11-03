
local Scene = require "xl.Scene"
local Transformable = require "xl.Transformable"
local TextInterface = Class("TextInterface")
TextInterface.__lt = Scene.lessThan
TextInterface.__le = Scene.lessThan
TextInterface.setPosition = Transformable.setPosition

function TextInterface:init()
	self.color = {255, 255, 255, 255}
	self.x = 5
	self.y = 5
	self.z = 5
	self.scale = 1
	self.enabled = true
	self.dataset = {}
	Scene.makeNode( self )
end
function TextInterface:set(id,value)
	assert(type(id)=="string", "id must be a string")
	if value == nil then value = "nil" end
	if value == "" then value = nil end
	self.dataset[id] = value
end

function TextInterface:print(id,format,...)
	local value = string.format(format,...)
	self:set(id,value)
end

function TextInterface:setColor(r,g,b,a)
	self.color = {r,g,b,a}
end

function TextInterface:setPosition(x,y)
	self.x = x
	self.y = y
end

function TextInterface:getPosition()
	return self.x, self.y
end

function TextInterface:setScale(scale)
	self.scale = scale
end

function TextInterface:getScale()
	return self.scale
end

function TextInterface:update( dt )
end

function TextInterface:clear()
	self.dataset = {}
end

function TextInterface:draw()
	--if self.enabled then
		local xx = self.x
		local yy = self.y
		love.graphics.setFont( xl.getFont() )
		love.graphics.setColor(self.color)
		love.graphics.push()
		love.graphics.origin()
		love.graphics.scale(self.scale, self.scale)
		for k,v in pairs(self.dataset) do
			love.graphics.print(k .. "= " .. tostring(v), xx, yy)
			yy = yy + love.graphics.getFont():getHeight()
		end
		love.graphics.pop()
	--end
end

-- function TXTI.toggle()
-- 	self.enabled = not self.enabled
-- end

-- function TXTI.enable(enabled)
-- 	assert(enabled == true or enabled == false, "paramater must be true or false")
-- 	self.enabled = enabled
-- end

-- function TXTI.isEnabled()
-- 	return self.enabled
-- end

return TextInterface
