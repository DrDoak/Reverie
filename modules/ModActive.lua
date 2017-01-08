local ModActive = Class.create("ModActive", Entity)

ModActive.dependencies = {"ModPartEmitter"}
ModActive.trackFunctions = {"setHitState","normalState","hitState","onDeath","onHitConfirm","onKill"}

function ModActive:create()
	--default state information
	self.stun = 0
	self.spcCount = self.spcCount or {}
	self.spcMove = self.spcMove or {}
	self.specialStates = self.specialStates or {}
	self.specialObj = self.specialObj or {}
	self.passiveEffects = {}
	self.passiveVars = {}

	self.state = 1 --Intend to Phase out and replace with "status" fully, but too many uses
	self.status = "normal"
	self.lastHitObj = nil

	self.aggressive = false
	self.isAlive = true
	self.invincibleTime = 0

	self.max_health = self.max_health or self.health or 20
	self.health = self.health or self.max_health
	self.redHealth = self.health
	self.redHealthDelay = 0
	self.killCount = 0

	self:addEmitter("hitFX" , self.hitFX or "assets/spr/fx/hit.png")
	self:setRandomDirection("hitFX" , 3 * 32)
	self:setRandRotation("hitFX",2,0,1)
	local hitFX = self.psystems["hitFX"]
	hitFX:setParticleLifetime(1, 2);
	self:setFade("hitFX")

	self:addEmitter("heal" , "assets/spr/fx/heal.png")
	local heal = self.psystems["heal"]
	heal:setDirection(((3*math.pi)/2))
	heal:setSpeed(64)
	heal:setSpread(math.pi/4)
	heal:setParticleLifetime(1, 1);
	self:setAreaSpread("heal","normal",2,2)
	self:setFade("heal")
end

function ModActive:destroy()
	if self.dmgHitbox then
		Game:del(self.dmgHitbox)
	end
end
function ModActive:tick( dt )
	self.forceX = 0
	self.forceY = 0
	self.isMoving = false
	self.isMovingY = false
	self.isMovingX = false	
	
	if self.state == 3 then self.jumping = false end

	self:processPassives()

	if self.health <= 0 then
		self.isAlive = false
		self:onDeath()
	elseif not self.destroyed then
		self.isAlive = true	
		if #self.specialStates > 0 then
		self:specialState( dt )
		elseif self.state ~= 3 then
			self.status = "normal"
			self:normalState()
		end
	
		if self.health > 0 and  self.state == 3 then
			self:hitState() 			-- self.status = "stun"
		end
	end
	self.isMoving = self.isMoving or  self.isMovingX or self.isMovingY

	self:updateHealth()
end

function ModActive:normalState()		end

function ModActive:setPassive(name,effect)
	for i,v in pairs(self.passiveEffects) do
		if i == name then
			self.passiveEffects[i] = nil
			self.passiveVars[i] = nil
			return
		end
	end
	if effect then
		self.passiveEffects[name] = effect
		lume.trace("Added to set passive: ", self.passiveEffects[name])
		self.passiveVars[name] = {}
	end
end

function ModActive:processPassives( )
	for k,v in pairs(self.passiveEffects) do
		-- lume.trace(self.passiveVars[k])
		v( self ,self.passiveVars[k])
	end
end

function ModActive:updateHealth()
	self.invincibleTime = math.max(0, self.invincibleTime - 1)
	if self.redHealthDelay > 0 then
		self.redHealthDelay = self.redHealthDelay - 1
	elseif self.redHealth < self.health then
		self.redHealth = math.min(self.health,self.redHealth + 1)
		self:setHealth(self.health,self.redHealth)
	end
end
function ModActive:setFaction( factionName )
	self.faction = factionName
end

function ModActive:setHitState(hitInfo)
	local stunTime = hitInfo.stun
	local forceX = hitInfo.forceX
	local forceY = hitInfo.forceY
	local damage = hitInfo.damage
	local element = hitInfo.element
	local faction = hitInfo.faction
	local shieldDamage = hitInfo.guardDamage
	local blockStun = hitInfo.guardStun
	local unblockable = hitInfo.isUnblockable
	self.lastHitObj = hitInfo.attacker
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

		local st = stunTime or 0
		local dm = damage or 0
		local ratio = self.KBRatio or 1

		if forceX and  math.abs(forceX) > 0 then
			if forceX and (forceX > 0) then
				self.dir = -1
			else
				self.dir = 1
			end
		end
		
		self.stun = st

		self:setHealth(self.redHealth - dm)
		if not self.superArmor then
			self.body:setLinearVelocity(forceX * ratio,forceY * ratio)
		end
		self.invincibleTime = 0
		return "hit"
	else
		return false
	end
end

function ModActive:hitState()
	self:overrideAnimation("legs")
	self:overrideAnimation("body")
	self:overrideAnimation("head")

	if self.status == "stunned" then
		self:changeAnimation({"stun","hit"})
	else
		self:changeAnimation("hit")
	end

	self.isMoving = false
	if self.body:getGravityScale() ~= 1.0 then
		self.body:setGravityScale(1.0)
	end
	if self.inAir then 
		self:changeAnimation({"hitmore","hit"})
		if math.abs(self.angle) < (2*math.pi)/4 then
			self.angle = self.angle + (0.00004 * self.velX * math.min(30,self.stun))
		end
		self:setSprAngle(self.angle)
	end
	if not self.inAir and math.abs(self.angle) > math.pi/2 then
		self.angle = 0
		self:setSprAngle(self.angle)
		local function grounded( player, frame )
			if frame == 1 then
				self:changeAnimation("ground")
			end
			if frame > math.random(40,100) then
				player.exit = true
				local function hit_ground( player, count )
					player:changeAnimation("crouch")
					if count >= 24 then
						self.lastHitObj = nil
						player.exit = true
					end
				end
				self:setSpecialState(hit_ground)
			end
		end
		self:setSpecialState(grounded)
	end

	if self.stun > 0 then
		self.stun = self.stun - 1
	else
		-- lume.trace("end of stun")
		if self.inAir and math.random(1,30) == 2 then
			-- lume.trace("setting state to 1")
			-- lume.trace("recovering")
			self.status = "normal"
			self.state = 1
			local function recover( player, frame )
				-- lume.trace("Recovering: ", frame)
				player:animate()
				player.angle = player.angle - (0.5 * self.dir)
				player:setSprAngle(player.angle)
				if frame == 1 then
					self.body:setLinearVelocity(self.velX, -self.jumpSpeed/10)
				end
				if frame >= 7 then
					player.angle = 0
					player:setSprAngle(player.angle)
					player.exit = true
				end
			end
			self:setSpecialState(recover)
		elseif not self.inAir then
			self:animate()
			self:resetAnimation("body")
			self:resetAnimation("head")
			self:resetAnimation("legs")
			self.angle = 0
			self:setSprAngle(self.angle)
			self.status = "normal"
			self.state = 1
		end
	end
end

function ModActive:setSpecialState(stateObject, canMove,uninterruptable)
	--self.state = 4
	self.prepTime = -5
	self.currentJumpTime = 0
	self.jumping = false
	local state = {}
	state.funct = stateObject
	state.count = 0
	state.canMove = canMove
	state.unInterruptable = uninterruptable
	--self.specialStates[#self.specialObj + 1] = state
	table.insert(self.specialStates,state)
	-- self.spcCount[#self.specialObj+1] = 0
	-- self.spcMove[#self.specialObj+1] = canMove
	self.count2 = 0
	--self.specialObj = stateObjec
	--table.insert(self.specialObj,stateObject)
end

function ModActive:specialState(dt )
	local canMove = false
	for k, v in pairs(self.specialStates) do 
		self.exit = false
		self.newFrame = false
		v.count = v.count + 1
		local totalTime
		local ty = type( v.funct )
		if (self.status == "hit" or self.status == "stunned") and not v.unInterruptable then
			totalTime = 10000
			self.exit = true
			if ty == "table" then
				v.funct:specialState(self,totalTime,dt)
			else
				v.funct( self ,totalTime , dt)
			end
			-- lume.trace("Setting state to 3")
			self.state = 3
		else
			if v.canMove then
				self:normalMove()
			end
			totalTime = v.count or 0
			if ty == "table" then
				v.funct:specialState(self,totalTime , dt)
			else
				v.funct( self ,totalTime , dt)
			end
		end
	
		v.count = self.newFrame or v.count
		if self.exit == true then
			table.remove(self.specialStates,k)
		end
	end
end

function ModActive:setHealth( health )
	local diff = health - self.health
	self.health = math.min(self.max_health,math.max(health,0))
	self.redHealth = math.min(self.redHealth,self.health)
	if diff > 0 then
		self:emit("heal", math.max(math.min(math.floor(math.abs(diff)/4),2),2))
	elseif diff < 0 then
		self:emit("hitFX", math.max(math.min(math.floor(math.abs(diff)/4),2),2))
	end
end

function ModActive:setMaxHealth( maxHealth, noRefill )
	self.max_health = maxHealth
	if not noRefill then
		self.health = self.max_health
	end
end

function ModActive:getHealth(  )
	return self.health
end


function ModActive:onDeath()
	if not self.immortal then
		Game:del(self)
	end
end

function ModActive:onHitConfirm(target, hitType, hitbox)
	if target.destroyed or target.health <= 0 then
		self:onKill(target,hitType,hitbox)
	end
end

function ModActive:onKill( target,hitType,hitbox )
	self.killCount = self.killCount + 1
end

function ModActive:jump()
	local velX, velY = self.body:getLinearVelocity()
	if not self.inAir and self.jumpCooldown == 0 then
		if self.jumpSpeed ~= 0  then
			self.body:setLinearVelocity(velX, -self.jumpSpeed)
		end
		self.jumpCooldown = 15
		self.jumping = true
		self.isMoving = true
	end
	if self.jumping then
		self.currentJumpTime = self.currentJumpTime + 1
	end
	if self.currentJumpTime > self.maxJumpTime then
		self.jumping = false
	end
end

return ModActive