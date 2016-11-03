
local lume = lume
local Component = Class.create("Component")

function Component:init()
	self.x = 0
	self.y = 0
	self.width = 0
	self.height = 0
	self._children = {}
end

function Component:setPosition(x,y)
	self.x = x
	self.y = y
end

function Component:getPosition()
	return self.x, self.y
end

function Component:setSize(w,h)
	self.width = w
	self.height = h
end

function Component:update()
end

function Component:draw()
	love.graphics.push()
	love.graphics.translate(self.x,self.y)
	self:paintChildren()
	self:paintComponent()
	love.graphics.pop()
end

function Component:getAABB()
	return self.x, self.y, self.x + self.width, self.y + self.height
end

function Component:isInBounds(x,y)
	local x1,y1,x2,y2 = self:getAABB()
	return x1 <= x and x <= x2 and y1 <= y and y <= y2
end

function Component:paintComponent()
end

function Component:paintChildren()
	lume.each(self._children, "draw")
end


