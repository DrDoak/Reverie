local ObjBase = require "ObjBase"
local ObjTest = Class.create("ObjTest", ObjBase)
	
function ObjTest:create()
	local active = require "modules.ModActive"
	self:addModule(active)
	local body = require "modules.ModTDObj"
	self:addModule(body)

	-- self:createBody( "dynamic" ,true, false)
	-- self.shape = love.physics.newRectangleShape(32,16)
	-- self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	-- self:setFixture(self.shape, 22.6)

	self:addModule(require "modules.ModDrawableTD")
	self:matchBodyToSpr(require("assets.spr.scripts.SprCrate3D"))
	self:setMaxHealth(100)
	self.fixtureDRAW = xl.SHOW_HITBOX(self.fixture)
end

return ObjTest