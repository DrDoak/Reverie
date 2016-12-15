local ObjBase = require "ObjBase"
local ObjTestInt = Class.create("ObjTestInt", ObjBase)
	
function ObjTestInt:create()
	-- self:addModule(require "modules.ModActive")
	self:addModule(require "modules.ModDialog")
	self:addModule(require "modules.ModPhysicsTD")

	self:createBody( "kinematic" ,false, false)

	self.shape = love.physics.newRectangleShape(32,32)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self:setFixture(self.shape, 22.6)

	self:addModule(require "modules.ModDrawableTD")
	self:addSpritePiece(require("assets.spr.scripts.SprCrate3D"))
	-- self:setMaxHealth(100)
	local speech = {
		"Hello, I am a Dialogue Node",
		"I can say things and you can respond",
		"good bye"}
	lume.trace()
	self:setDialogItems(speech)
end

return ObjTestInt