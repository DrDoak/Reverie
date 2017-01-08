local ObjBase = require "ObjBase"
local ObjRoomChanger = Class.create("ObjRoomChanger", ObjBase)
	
function ObjRoomChanger:create()
	self:addModule(require "modules.ModPhysics")
	self:addModule(require "modules.ModRoomChanger")

	self:createBody( "kinematic" ,true, false)
	self.shape = love.physics.newRectangleShape(self.width,self.height)

	self:setFixture(self.shape, 1)
	self.fixture:setSensor(true)
	self.fixtureDRAW = xl.SHOW_HITBOX(self.fixture) --Uncomment to see hitbox.

end

return ObjRoomChanger