----
-- ObjWall.lua
-- 
-- This file defines a "Wall Object". Wall objects are loaded in through a TMX file when an object is specified as type: "ObjWall"
-- Walls can have the "jumpThru" parameter, which can be specified through TMX. If set to true, then unit objects can jump through this wall.
----
local ObjWall = Class.create("ObjWall", Entity)
local Keymap  = require "xl.Keymap"

function ObjWall:create()
	self.body = love.physics.newBody(self:world(), -1,-1, "static")
	self.chainShape = love.physics.newChainShape(false, unpack(self.pointlist))
	self.fixture = love.physics.newFixture(self.body, self.chainShape, 1)
	if self.jumpThru then
		self.fixture:setCategory(CL_PLAT)
	else
		self.fixture:setCategory(CL_WALL)
	end
	self.fixture:setFriction(0.0)
	self.body:setUserData(self)
	self.thruTimer = -1
end

function ObjWall:tick(dt)
end

function ObjWall:onCollide(other, collision)
	if self.jumpThru and Class.istype(other,"ObjUnit") then
		local x1, y1, x2, y2 = collision:getPositions()
		local otherX, otherY = other.body:getPosition()
		if x1 ~= nil and y1 ~= nil and not other.inAir and not other.jumping then
			if otherY + other.height/2 - 2 > y1 then
				collision:setEnabled(false)
				other:setJumpThru(8)
			end
		end
		if x2 ~= nil and y2 ~= nil and not other.inAir and not other.jumping then
			if otherY + other.height/2 - 2 > y2 then
				collision:setEnabled(false)
				other:setJumpThru(8)
				return
			end
		end
	end
end

return ObjWall
