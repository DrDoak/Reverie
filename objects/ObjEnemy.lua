local ObjBase = require "ObjBase"
local ObjEnemy = Class.create("ObjEnemy", ObjBase)
	
function ObjEnemy:create()
	local active = require "modules.ModActive"
	self:addModule(active)
	local body = require "modules.ModPhysicsTD"
	local body = require "modules.ModTDAI"
	self:addModule(body)
	self:addModule(require "modules.ModCharacter")

	self:createBody( "dynamic" ,true, false)

	self.shape = love.physics.newRectangleShape(12, 4)
	self:setFixture(self.shape, 22.6)

	self:addModule(require "modules.ModDrawable")
	self:addSpritePiece(require("assets.spr.scripts.PceWheel"))
	self:addSpritePiece(require("assets.spr.scripts.PceBody"))
	self:setMaxHealth(100)
	self.maxSpeedX = 3 * 32
	self.maxSpeedY = 3 * 32
	self:setGoal({x=6*32,y=10*32},"testRoom2")
end

function ObjEnemy:normalState()
	self:moveToGoal()
end

return ObjEnemy