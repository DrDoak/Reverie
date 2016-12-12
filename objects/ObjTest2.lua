local ObjBase = require "ObjBase"
local ObjTest = Class.create("ObjTest", ObjBase)
	
function ObjTest:create()
	local active = require "modules.ModActive"
	self:addModule(active)
	local body = require "modules.ModPhysics"
	self:addModule(body)

	self:createBody( "dynamic" ,false, false)

	self.shape = love.physics.newRectangleShape(16,16)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self:setFixture(self.shape, 22.6)

	self:addModule(require "modules.ModDrawable")
	self:addSpritePiece(require("assets.spr.scripts.SprSmallBox"))
	self:setMaxHealth(100)
end

return ObjTest