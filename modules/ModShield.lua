local ModShield = Class.create("ModShield", Entity)

function ModShield:create()
	self.maxShield = self.maxShield or 100
	self.shield = self.shield or self.maxShield
	self.shieldDelay = 0
	self.shieldRegain = 1.0
end

function ModShield:tick( dt )
	--Shield stuff
	if self.shieldDelay > 0 then
		self.shieldDelay = self.shieldDelay - 1
	elseif self.shield < self.maxShield then
		self.shield = math.min(self.maxShield,self.shield + (1 * self.shieldRegain))
	end
end


function ModShield:setHitState(stunTime, forceX, forceY, damage, element,faction,shieldDamage,blockStun,unblockable)
	self.prepTime = 0
	if faction and self.faction and faction == self.faction then
		return false
	elseif self.isAlive and element == "guardDeflect" then
		self.state = 3
		local ratio = self.KBRatio or 1
		self.status = "stunned"
		self:overrideAnimation("legs")
		self:overrideAnimation("body")
		self:overrideAnimation("head")

		self.stun = blockStun or stunTime
		if not self.superArmor then
			self.body:setLinearVelocity(forceX * ratio,forceY * ratio)
		end
	elseif self.isAlive and self.invincibleTime == 0 then
		-- lume.trace(stunTime, forceX, forceY, damage, element,faction,shieldDamage,blockStun,unblockable)
		-- lume.trace()
		local st = stunTime or 0
		local dm = damage or 0
		local ratio = self.KBRatio or 1
		self.shieldDelay = 180
		if forceX > 0 then
			self.dir = -1
		else
			self.dir = 1
		end
		if not unblockable and self.status == "normal" and self.shield > 0 then
			self.shield = math.max(0,self.shield - (shieldDamage or damage))
			local fx = FXGeneric(self.x,self.y,self,40)
			fx:setImage("assets/spr/fx/shards.png",32,18,"1-6",0)
			fx:setAngle(math.random(0,math.pi*2))
			fx:setSpeed(forceX/60 + math.random(-0.5,0.5),forceY/60 + math.random(-0.5,0.5))
			local red = 255 * (100-self.shield)/100
			local green = math.max(0,(self.shield/100) * 255 - (100-self.shield))
			fx:setColor(red,green,0,100)
			Game:add(fx)

			local fx2 = FXGeneric(self.x + (4 * self.dir),self.y,self,16)
			fx2:setImage("assets/spr/fx/block_side.png",64,128,"1-8",30)
			fx2:setDir(self.dir)
			fx2:setDepth(9000)
			fx2:setSize(24,48)
			--fx2:setColor(red,green,0,100)
			Game:add(fx2)

			if not self.superArmor then
				self.body:setLinearVelocity(forceX * ratio * 0.75,forceY * ratio * 0.75)
			end
			if self.shield == 0 and self.maxShield ~= 0 then
				self.stun = 120
				for i=1,6 do
					local fx2 = FXGeneric(self.x,self.y,self,40)
					fx2:setImage("assets/spr/fx/shards.png",32,18,"1-6",0)
					fx2:setAngle(math.random(0,math.pi*2))
					fx2:setSpeed(math.random(-1,1),math.random(-1,1))
					fx2:setColor(255,255,0,200)
					Game:add(fx2)
				end
				self.status = "guard_broken"
				self.state = 3
			end
			if element == "fire" or element == "light" or element == "dark" then
				self:setHealth(self.redHealth - math.ceil(damage * 0.5))
			end
			return "blocked"
		else
			if st > 0 and not self.superArmor then 
				-- lume.trace("setting state to 3")
				if self.status == "guard_broken" then
					dm = dm * 2
					Game.WorldManager:flash()
				end
				self.state = 3 
				self.status = "hit"
				self:overrideAnimation("legs")
				self:overrideAnimation("body")
				self:overrideAnimation("head")
				self:changeAnimation("hit")
			end
			-- if element == "light" then
			-- 	self.stun = self.stun + st
			-- else
			-- 	self.stun = sts
			-- end
			self.stun = st
			-- lume.trace("Damage: ", dm, "current Red health", self.redHealth)
			self:setHealth(self.redHealth - dm)
			if not self.superArmor then
				self.body:setLinearVelocity(forceX * ratio,forceY * ratio)
			end
			self.regainTime = 240
			self.invincibleTime = 0
			return "hit"
		end
	else
		return false
	end
end

return ModShield