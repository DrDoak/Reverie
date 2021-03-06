local ObjBase = require "ObjBase"
local EqpHandgun = Class.create("EqpHandgun", ObjBase)
	
function EqpHandgun:create()
	self:addModule( require "modules.ModTargetEqp")
	self:addModule( require "modules.ModHitboxMaker")
	self:addModule(require "modules.ModDrawable")

	self.shape = love.physics.newRectangleShape(32,32)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self:setFixture(self.shape, 22)

	self:addSprite(require("assets.spr.scripts.SprHandgun"))

	self.isKeyItem = false
	self.isPrimary = true
	self.lockOnAnim = "aim_handgun"
	self.name = "Handgun" --String that displays in Inventory
	self.invSprite = love.graphics.newImage( "assets/spr/eqp/handgun_icon.png" )

	self.spritePiece = 	self:createSpritePiece(16,16,"weapon", require ("assets.spr.scripts.SprHandgun"))
	--self.fixtureDRAW = xl.SHOW_HITBOX(self.fixture)
end

function EqpHandgun:useStand(player,frame)
	-- player:animate()
	-- if frame == 1 then
	-- 	player:changeAnimation("slash_p")
	-- end
	-- if frame >= 8 then
	-- 	player:changeAnimation("slash_r")
	-- end
	-- if frame == 12 then
	-- 	lume.trace(self.x,self.y)
	-- 	self:createHitbox({width = 60, height = 15,xOffset = 10, yOffset = -5, damage = 15, guardDamage = 12,
	-- 		stun = 35, persistence = 0.15,xKnockBack = 4 * 32, yKnockBack = -3 * 32, element = "fire"})
	-- elseif frame >= 35 then
	-- 	player.exit = true
	-- end
end

return EqpHandgun