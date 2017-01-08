local ObjBase = require "ObjBase"
local ObjSlope = Class.create("ObjSlope", ObjBase)
	
function ObjSlope:create()
	self:addModule(require "modules.ModPhysics")
	self:addModule(require "modules.ModSpeedZone")

	self:createBody( "kinematic" ,true, false)
	self.shape = love.physics.newRectangleShape(self.width,self.height)

	self:setFixture(self.shape, 1)
	-- self.slope = self.slope
	self.fixture:setSensor(true)
end



return ObjSlope