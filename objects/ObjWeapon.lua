local ObjBase = require "ObjBase"
local ObjWeapon = Class.create("ObjWeapon", ObjBase)
	
function ObjWeapon:create()
	self:addModule( require "modules.ModEquippable")
	self:addModule( require "modules.ModHitboxMaker")

	self.shape = love.physics.newRectangleShape(32,32)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self:setFixture(self.shape, 22.6)
	local drawable = require "modules.ModDrawable"
	self:addModule(drawable)
	self:addSprite(require("assets.spr.scripts.SprKnife"))

	self.isKeyItem = false
	self.isPrimary = true
	self.name = "Knife" --String that displays in Inventory
	self.invSprite = love.graphics.newImage( "assets/spr/sword.png" )

	self.spritePiece = 	self:createSpritePiece(8,8)
	--self.fixtureDRAW = xl.SHOW_HITBOX(self.fixture)
end

function ObjWeapon:useStand(player,frame)
	-- player:animate()
	if frame == 1 then
		player:changeAnimation("slash_p")
	end
	if frame >= 8 then
		player:changeAnimation("slash_r")
	end
	if frame == 12 then
		self:createHitbox({width = 60, height = 15,xOffset = 10, yOffset = -5, damage = 15, guardDamage = 12,
			stun = 35, persistence = 8,xKnockBack = 4 * 32, yKnockBack = -3 * 32, element = "slash"})
	elseif frame >= 35 then
		player.exit = true
	end
end

return ObjWeapon