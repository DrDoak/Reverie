local ObjBase = require "ObjBase"
local ObjTestNPC = Class.create("ObjTestNPC", ObjBase)
	
function ObjTestNPC:create()
	self.maxSpeed = 2 * 32

	self:addModule(require "modules.ModNPC")

	self:createBody( "dynamic" ,true, false)
	self:loadNPCScript(self.npcScript)
	
	self.shape = love.physics.newRectangleShape(12, 8)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self:setFixture(self.shape, self.mass)

	self.fixtureDRAW = xl.SHOW_HITBOX(self.fixture)
	self:setGoal({x=10*32,y=9*32})
end

return ObjTestNPC