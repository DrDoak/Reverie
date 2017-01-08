----
-- ObjWall.lua
-- 
-- This file defines a "Wall Object". Wall objects are loaded in through a TMX file when an object is specified as type: "ObjWall"
----
local ObjWall = Class.create("ObjWall", Entity)

function ObjWall:create()
	self.body = love.physics.newBody(self:world(), -1,-1, "static")
	self.chainShape = love.physics.newChainShape(false, unpack(self.pointlist))
	self.fixture = love.physics.newFixture(self.body, self.chainShape, 1)
	self.fixture:setCategory(CL_WALL)

	self.fixture:setFriction(0.0)
	self.body:setUserData(self)
end

function ObjWall:tick(dt) end

return ObjWall
