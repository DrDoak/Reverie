local ObjBase = require "ObjBase"
local ObjBox = Class.create("ObjBox", ObjBase)
	
function ObjBox:create()
	-- local active = require "modules.ModActive"
	-- self:addModule(active)
	local body = require "modules.ModActive"
	self:addModule(body)
	self:createBody( "dynamic" ,true, true)

	self.shape = love.physics.newRectangleShape(32, 32)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self:setFixture(self.shape, 22.6)
	-- local drawable = require "modules.ModDrawable"
	-- self:addModule(drawable)
	--self:addSpritePiece(require("assets.spr.scripts.PceWheel"))
	self.fixtureDRAW = xl.SHOW_HITBOX(self.fixture)

end

return ObjBox
