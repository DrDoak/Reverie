local ModWooden = Class.create("ModWooden", Entity)
ModWooden.dependencies = {"ModPartEmitter", "ModActive","ModHitboxMaker"}

ModWooden.trackFunctions = {}

function ModWooden:create()
	self:addEmitter("wood" , "assets/spr/woodchip.png")
	self:setRandomDirection("wood" , 3 * 32)
	self:setRandRotation("wood",32,0,1)
	local wood = self.psystems["wood"]
	wood:setParticleLifetime(1, 2);
	self:setFade("wood")

	self:addEmitter("fire" , "assets/spr/fire.png")
	self:setRandomDirection("fire" , 3 * 32)

	self:setAreaSpread("fire","normal",8,8)
	self.fireTime = 90
	self:setFade("fire")

end

function ModWooden:setHitState(stunTime, forceX, forceY, damage, element,faction,shieldDamage,blockStun,unblockable)
	if element == "fire" then
		local function onFire(player,extraInfo)
			if not extraInfo.frame then extraInfo.frame = 0 end
			extraInfo.frame = extraInfo.frame + 1
			local frame = extraInfo.frame

			if frame % 16 == 0 then
				self.health = self.health - 4
				self:createHitbox({width = 60, height = 15,xOffset = 10, yOffset = -5, damage = 15, guardDamage = 12,
					stun = 35, persistence = 8,xKnockBack = 4 * 32, yKnockBack = -3 * 32, element = "fire"})
				self:emit("fire", 2)
			end
			
			if frame > self.fireTime then
				player:setPassive("onFire",nil)
			end
		end
		self:setPassive("onFire",onFire)
	end
	self:emit("wood", 4)
end

function ModWooden:destroy()
	self:emit("wood",16)
end

return ModWooden