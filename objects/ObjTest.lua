local ObjBase = require "ObjBase"
local ObjTest = Class.create("ObjTest", ObjBase)
	
function ObjTest:create()
	-- local active = require "modules.ModActive"
	-- self:addModule(active)
	local body = require "modules.ModPhysics"
	self:addModule(body)
	self:createBody( "dynamic" ,false, true)

	self.shape = love.physics.newRectangleShape(32,32)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self:setFixture(self.shape, 22.6)
	local drawable = require "modules.ModDrawable"
	self:addModule(drawable)
	self:addSpritePiece(require("assets.spr.scripts.SprBox"))
	--self.fixtureDRAW = xl.SHOW_HITBOX(self.fixture)
end

return ObjTest
