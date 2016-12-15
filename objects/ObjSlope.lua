local ObjBase = require "ObjBase"
local ObjSlope = Class.create("ObjSlope", ObjBase)
	
function ObjSlope:create()
	self:addModule(require "modules.ModPhysicsTD")

	self:createBody( "kinematic" ,true, false)
	self.shape = love.physics.newRectangleShape(self.width,self.height)

	self:setFixture(self.shape, 1)
	self.slope = self.slope or 1
	self.fixture:setSensor(true)
end

return ObjSlope