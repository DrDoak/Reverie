
local TSF = Class.create("Transformable")
function TSF:init(x, y, angle)
	local s = self
	s.x = s.x or x or 0
	s.y = s.y or y or 0
	s.angle = s.angle or angle or 0
	s.sx = s.sx or 1
	s.sy = s.sy or 1
	s.ox = s.ox or 0
	s.oy = s.oy or 0
end
function TSF:setPosition(x,y) self.x, self.y = x, y end
function TSF:getPosition()    return self.x, self.y end
function TSF:translate(dx,dy)
	self.x = self.x + dx
	self.y = self.y + dy
	return self
end
function TSF:setScale(sx,sy) self.sx, self.sy = sx, sy end
function TSF:getScale()      return self.sx, self.sy end
function TSF:scale(dx,dy)
	self.sx = self.sx * dx
	self.sy = self.sy * dy
	return self
end
function TSF:setOrigin(x,y) self.ox, self.oy = x,y end
function TSF:getOrigin()    return self.ox,self.oy end
function TSF:rotate(a)
	self.angle = self.angle + a
	return self
end
function TSF:resetTransform()
	local s = self
	s.x, s.y, s.angle, s.sx, s.sy, s.ox, s.oy = 0, 0, 0, 1, 1, 0, 0
	return self
end

return TSF
