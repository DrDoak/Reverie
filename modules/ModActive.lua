local ModActive = Class.create("ModActive", Entity)

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

	self.aggressive = false
	self.isAlive = true
	self.invincibleTime = 0
	self.regainTime = 0

	self.max_health = self.max_health or self.health or 100
	self.health = self.health or self.max_health
	self.redHealth = self.health
	self.redHealthDelay = 0
end

function ModActive:tick( dt )
	self.forceX = 0
	self.forceY = 0
	self.isMoving = false	
	
	if self.state == 3 then self.jumping = false end

	self:processPassives()

	if #self.specialStates > 0 then
		self:specialState()
	elseif self.state ~= 3 then
		self.status = "normal"
		self:normalState()
	end
	
	if self.health <= 0 and not self.immortal then
		self.isAlive = false	
	-- elseif self.state == 2 then
	-- 	self:actionState()
	elseif self.state == 3 then
		self:hitState() 			-- self.status = "stun"
	end
	
	self:updateHealth()
end

function ModActive:setPassive(name,effect)
	for i,v in pairs(self.passiveEffects) do
		lume.trace(i)
		if i == name then
			self.passiveEffects[i] = nil
			self.passiveVars[i] = nil
			return
		end
	end
	self.passiveEffects[name] = effect
	lume.trace("Added to set passive: ", self.passiveEffects[name])
	self.passiveVars[name] = {}
end

function ModActive:processPassives( )
	for i,v in pairs(self.passiveEffects) do
		v( self ,self.passiveVars[i])
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

	--Shield stuff
	-- if self.shieldDelay > 0 then
	-- 	self.shieldDelay = self.shieldDelay - 1
	-- elseif self.shield < self.maxShield then
	-- 	self.shield = math.min(self.maxShield,self.shield + (1 * self.shieldRegain))
	-- end
end


function ModActive:hitState()
	self:overrideAnimation("legs")
	self:overrideAnimation("body")
	self:overrideAnimation("head")

	if self.status == "stunned" then
		-- lume.trace("stunned")
		--self:controlDash()
		self:changeAnimation({"stun","hit"})
	else
		-- lume.trace("Changing animation to Hit")
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

function ModActive:specialState()
	local canMove = false
	for k, v in pairs(self.specialStates) do 
		self.exit = false
		self.newFrame = false
		v.count = v.count + 1
		local frame
		local ty = type( v.funct )
		if (self.status == "hit" or self.status == "stunned") and not v.unInterruptable then
			frame = 10000
			self.exit = true
			if ty == "table" then
				v.funct:specialState(self,frame)
			else
				v.funct( self ,frame)
			end
			-- lume.trace("Setting state to 3")
			self.state = 3
		else
			if v.canMove then
				self:normalMove()
			end
			frame = v.count or 0
			if ty == "table" then
				v.funct:specialState(self,frame)
			else
				v.funct( self ,frame)
			end
		end
	
		v.count = self.newFrame or v.count
		if self.exit == true then
			table.remove(self.specialStates,k)
		end
	end
end

return ModActive