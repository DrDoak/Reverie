local ObjBaseUnit = require "objects.ObjBaseUnit"
local ObjTest = Class.create("ObjTest", ObjBaseUnit)
	
function ObjTest:create()
	ObjBaseUnit.create(self)


	self:createBody( "dynamic" ,false, true)
	self.shape = love.physics.newRectangleShape(16,16)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self:setFixture(self.shape, 22.6)
	self.health = 100

	self:addSpritePiece(require("assets.spr.scripts.SprBox"))
end

return ObjTest
