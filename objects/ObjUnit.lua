----
-- ObjWall.lua
-- 
-- Currently imported from another project. Still requires clean-up. Could be broken down into multiple modules.
-- This file defines a Generic "Player-like" Object. By player-like, think of it as anything that at very least has health and can be killed.
-- The existence of this file is primarily for reference purposes when importing features.
-- 
----

local ObjAttackHitbox = require("objects.ObjAttackHitbox")
local Lights = require "xl.Lights"
local Inventory = require "xl.Inventory"
local ObjUnit = Class.create("ObjUnit", Entity, {health = 1})

util.transient(ObjUnit, 'sprite', 'grid', 'lighting')

----------------------Initialization-----------------
function ObjUnit:init( x, y )
	self.x = x
	self.y = y
end

function ObjUnit:create()
	--set default stats
	self.inventory = self.inventory or Inventory(1,1)
	self.animations = self.animations or {}
	self.maxJumpTime = 9
	self.currentJumpTime = 0
	self.jumpSpeed = 960
	self.deceleration = -12
	self.maxXSpeed = 6 * 32
	self.speedModifier = 1.0
	self.acceleration = 20 * 32

	--set Physics initializations
	self.dir = self.dir or 1
	self.inAir = false
	self.jumpCooldown = 0
	self.jmpCount1 = 0
	self.jmpCount2 = 0
	self.thruTimer = 0
	self.isMoving = false
	self.slopeDir = 0
	self.numContacts = 0
	self.height = self.height or 32

	--set default sprite information
	self.hitFrame = self.hitFrame or 1
	self.angle = 0
	self.imgX = 64
	self.imgY = 64
	self.initImgH = 64
	self.initImgW = 64
	self:setSprColor( 255, 255, 255, 255 )

	--default state information
	self.stun = 0
	self.spcCount = self.spcCount or {}
	self.spcMove = self.spcMove or {}
	self.specialStates = self.specialStates or {}
	self.specialObj = self.specialObj or {}
	self.forceX = 0
	self.forceY = 0
	self.velX = 0
	self.velY = 0
	self.state = 1 --Intend to Phase out and replace with "status" fully, but too many uses
	self.status = "normal"

	--self.idleCounter = 0 Not currently implemented
	self.aggressive = false
	self.isAlive = true
	self.invincibleTime = 0
	self.regainTime = 0
	self.destroyed = false
	-- self.spawnCooldown = 0
	self.referenceVel = 0
	self.depth = 5000
	self.max_health = self.max_health or self.health or 100

	self.sprites = self.sprites or {}
	self.lights = {}
	self.animationsPending = {}
	self.passiveEffects = {}
	self.passiveVars = {}

	self.maxShield = self.maxShield or 100
	self.shield = self.shield or self.maxShield
	self.shieldDelay = 0
	self.shieldRegain = 1.0

	self.redHealth = self.health
	self.redHealthDelay = 0
	self.prepTime = 0
	self.created = true
	self.idleCounter = 0
	self.currentEquips = self.currentEquips or {}

	self.wrapCheckGround = lume.fn(self.mCheckGround, self)
	self.checkJumpThru = lume.fn(self.mCheckJumpThru, self)
	self.wrapDetectInt = lume.fn(self.checkInt, self)
	self.attachPositions = {}
end

---------------------------Ticks---------------------------
function ObjUnit:tick(dt) 
		local body = self.body
		self.x,self.y = body:getPosition()
		self.velX, self.velY = body:getLinearVelocity()
		self.forceX = 0
		self.forceY = 0
		self.isMoving = false	

		--If the object is not affected by Gravity, apply force to oppose Gravity
		if self.noGrav == true then 
			self.body:applyForce(0, -self.body:getMass() * 480 * dt * 60) 

		elseif self.noGrav and self.noGrav > 0 then
			self.noGrav = self.noGrav - 1
			self.body:applyForce(0, -self.body:getMass() * 480 * dt * 60)
		end

		--Teleportation code, implementation of the function "SetPosition"
		if self.canTeleport == true and body then
			self.canTeleport = false
			body:setPosition(self.newX, self.newY)
		end
		
		if self.state == 3 then self.jumping = false end

		self:processJumpThru()	
		self:checkGround()
		self:processPassives()

		if #self.specialStates > 0 then
			self:specialState()
		elseif self.state ~= 3 then
			self.status = "normal"
			self:normalState()
		end
		
		if self.health <= 0 and not self.immortal then
			self.isAlive = false	
		elseif self.state == 2 then
			self:actionState()
		elseif self.state == 3 then
			self:hitState() 			-- self.status = "stun"
		end

		-- --Code for checking whether the object is on the ground
		self:manageInt()

		-- --Apply physics to the b2body
		self:move( dt, self.body, self.forceX, self.forceY, self.isMoving)

		self:updateHealthShields()
		self:updateSprites() 		--Update Sprite	to reflect physical body

		--Should be self explanatory
		if not self.isAlive and not self.immortal then
			self:die()
		end

		--Remove objects that have fell out of the world.
		if self.y > 9000 then
			self:die()
		end
end

function ObjUnit:updateSprites()
	if not self.angle and not self.body:isFixedRotation() then
		self:setSprAngle(self.body:getAngle())
	end
	for key,value in pairs(self.sprites) do
		if self.sprites[key].noLoop == false then
			self:changeAnimation(self.sprites[key].currentAnim )
		end
	end
	self.referenceVel = 0
	self:setSprPos(self.x,self.y + 16 + (self.charHeight or self.height)/2)
end

function ObjUnit:updateHealthShields()
	self.invincibleTime = math.max(0, self.invincibleTime - 1)
	if self.redHealthDelay > 0 then
		self.redHealthDelay = self.redHealthDelay - 1
	elseif self.redHealth < self.health then
		self.redHealth = math.min(self.health,self.redHealth + 1)
		self:setHealth(self.health,self.redHealth)
	end

	--Shield stuff
	if self.shieldDelay > 0 then
		self.shieldDelay = self.shieldDelay - 1
	elseif self.shield < self.maxShield then
		self.shield = math.min(self.maxShield,self.shield + (1 * self.shieldRegain))
	end
end
---------------------State information---------------
function ObjUnit:normalState()		end

function ObjUnit:setHitState(stunTime, forceX, forceY, damage, element,faction,shieldDamage,blockStun,unblockable)
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
		--self:changeAnimation("slash",-1.0)
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

function ObjUnit:hitState()
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

function ObjUnit:processPassives( )
	for i,v in pairs(self.passiveEffects) do
		v( self ,self.passiveVars[i])
	end
end

function ObjUnit:setSpecialState(stateObject, canMove,uninterruptable)
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

function ObjUnit:specialState()
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

function ObjUnit:actionState()
	local body = self.fixture:getBody()
	self.isMoving = false
	if self.sprites["legs"]:getIndex() == self.finishFrame then
		self.state = 1
	end
	body:applyForce(self.forceX, self.forceY, body:getWorldCenter())
end

function ObjUnit:setActionState(animation,exitFrame)
	if self.state ~= 3 then
		self:changeAnimation(animation)
		self.finishFrame = exitFrame 
		self.state = 2
	end
end

-------------------Physics Modifiers----------------------

function ObjUnit:setSpeedModifier(modifier)
	local velX, velY = self.body:getLinearVelocity()
	self.body:setLinearVelocity(velX * modifier, velY * modifier)
	self.speedModifier = modifier
end

function ObjUnit:move( dt, body, forceX, forceY, isMovingX)
	local decForce = self.deceleration * body:getMass()
	local velX, velY = body:getLinearVelocity()

	-- Staying stable in slopes
	if self.groundLevel and not self.jumping and (self.state ~= 3) then
		if self.groundLevel - self.y > 2 then
			self.body:applyForce(0, self.body:getMass() * math.max(2500,(6000 * math.abs(self.velX/self.maxXSpeed))))
		end
	end
	if self.jumping or self.numContacts == 0 then
		self:setJumpThru(1)
		self.inAir = true
	else
		self.inAir = false
	end

	--Jumping code        
	if self.jumping then
		self.body:applyForce(0, -self.body:getMass() * 480)
		self.inAir = true
		if self.currentJumpTime - math.floor(self.currentJumpTime/2) * 2 == 0 then
			body:applyLinearImpulse(0,-(self.jumpSpeed- (self.currentJumpTime * 64)))
		end
	end
	if not self.inAir then
		self.currentJumpTime = 0
	end
	if self.jumpCooldown > 0 then
		if velY > 0 then
			self.jumpCooldown = 0
		else
			self.jumpCooldown = self.jumpCooldown - 1
		end
	end
	
	-- reset gravity change due to slope
	self.body:setGravityScale(1.0)
	--deceleration
	if  not self.inAir and (isMovingX == false or math.abs(self.velX- self.referenceVel) > math.abs(self.maxXSpeed) * 1.1) then
		if self.state == 3 then
			forceX = velX * (decForce/4)
		else
			forceX = velX * decForce
		end
		if self.slopeDir ~= 0 and not self.inAir then --negate sliding down slopes, if the player wants to stop, force the object to stop.
			self.body:setGravityScale(0.0)
		end
		if self.dir == self.slopeDir * -1 then
			forceX = forceX * 2
		end
	end
	if self.noGrav == true and self.isMoving == false then
		forceY = velY * decForce
	end 

	if isMovingX and self.dir == self.slopeDir then
		self.body:applyForce(0, -self.body:getMass() * 480)
	end
	--Apply force updates.
	body:applyForce(forceX*60*dt,forceY*60*dt)
end

function ObjUnit:jump()
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

function ObjUnit:createHitbox(wth, hgt, XOffset, YOffset, dmg, stn, pers, Xforce, Yforce, elem, deflect)
	local x = self.x + (XOffset * self.dir)
	local y = self.y + YOffset
	Xforce = Xforce * self.dir
	local ObjAttackHitbox = ObjAttackHitbox(x, y, wth, hgt, self, dmg, stn, pers, Xforce, Yforce, elem, deflect)
	Game:add(ObjAttackHitbox)
	return ObjAttackHitbox
end


function ObjUnit:setFixture( shape, mass, isSensor)
	local s = self.fixture:getShape()
	local topLeftX, topLeftY, bottomRightX, bottomRightY = s:computeAABB( 0, 0, 0, 1 )
	local height1 = math.abs(topLeftY - bottomRightY)
	local width1 = math.abs(topLeftX - bottomRightY) 
	topLeftX, topLeftY, bottomRightX, bottomRightY = shape:computeAABB( 0, 0, 0, 1 )
	self.height = math.abs(topLeftY - bottomRightY)
	local height2 = self.height
	local width2 = math.abs(topLeftX - bottomRightY)
	self.fixture:destroy()
	self.fixture = love.physics.newFixture(self.body, shape, 1)
	local m = mass or self.mass or 25
	self.body:setMass(m)
	if self.imgY then
		--self.sprite:setOrigin(64, (self.imgY * 2) - height2 - 3)
	end
	local sensor = isSensor or false
	self.fixture:setSensor(sensor)
	self.fixture:setCategory(CL_CHAR)
	self.fixture:setFriction(0.01)
	self.fixture:setRestitution( 0.0 )
	self.body:setPosition(self.x, self.y - ((height2 - height1)/2))	
end

--when something lands on an object from a long fall, he/she will kneel down for a second.
function ObjUnit:onCollide(other, collision)
	if self.state == 1 and self.velY > 400 then
		self:landing()
	end
end

function ObjUnit:landing( )
	local function hit_ground( player, count )
		player:changeAnimation("crouch")
		if count >= 15 then
			player.exit = true
		end
	end
	self:setSpecialState(hit_ground)
end
-------------------------Equipment---------------------------
function ObjUnit:drop(slot,removeFromInv,destroy)
	local r, c
	if slot ~= "primary" and not self.currentEquips[slot] then return end
	if slot == "primary" and not self.currentPrimary then return end
	-- lume.trace(slot)
	-- lume.trace(self.currentPrimary)
	if slot == "primary" then
		r, c = self.inventory:getRC(self.currentPrimary.type)
		if self.currentPrimary and self.currentPrimary.sprClass then
			self:delSpritePiece(self.currentPrimary.sprClass)
		end
	else
		slot = slot or "neutral"
		-- lume.trace(self.currentEquips[slot])
		r, c = self.inventory:getRC(self.currentEquips[slot].type)
		if self.currentEquips[slot] and self.currentEquips[slot].sprClass then
			self:delSpritePiece(self.currentEquips[slot].sprClass)
		end
	end
	-- lume.trace(r, c)
	if r and c then
		-- lume.trace(self)
		self.inventory.currentEquips[slot] = nil
		self.inventory.user = self
		-- lume.trace(removeFromInv)
		if removeFromInv then
			self.inventory:dropItem(r,c,destroy) 
		end
	else 
	end
	--self:setEquip(nil, true)
end

--sets the player's current equip to a provided ObjEquippable subclass

function ObjUnit:setPrimary(active)
	if self.currentPrimary then
		if self.currentPrimary.continous then
			self.currentPrimary:setLightActive(active)
		else
			if active then 
				self.currentPrimary:usePrimary()
			end
		end
	end
end 

function ObjUnit:setPassive(name,effect)
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

function ObjUnit:setEquip( item, slot )
	-- lume.trace(slot)
	self.inventory:setEquip(item,self,slot)
	self:updateIntAmount()
end

function ObjUnit:reduceEquip( slot, amount )
	amount = (amount or 1)  
	-- lume.trace(self.currentEquips[slot])
	local currentItem
	lume.trace()
	if slot == "primary" then
		currentItem = self.currentPrimary
	else
		currentItem = self.currentEquips[slot]
	end
	currentItem.numInInv = math.max(0, currentItem.numInInv - amount)
		-- lume.trace("-----------")

	-- self.inventory:setEquipAmount(item,self,amount,self.currentEquips[slot].numInInv)
	if currentItem.numInInv <= 0 then
		lume.trace("pppp")
		-- currentItem:drop()
		self:drop(slot,true)
		self:setEquip(nil,slot)
	else
		local new = currentItem:makeCopy()

		currentItem:drop()
		-- self.currentEquips[slot] = new
		
		self:addToInv(new,true,0,true)

		--currentItem.toDestroy = true
		-- lume.trace(self.currentEquips[slot])
		-- self:setEquip(new,new.invSlot)

		-- currentItem.numInInv = currentItem.numInInv - 1
	end
	self:updateIntAmount()
end

function ObjUnit:updateIntAmount()
	if self.equipIcons then
		for k,v in pairs(self.equipIcons) do
			if self.currentEquips[k] then
				v:setCount(self.currentEquips[k].numInInv)
			end
		end
	end
end

function ObjUnit:mSetEquip(newEquip, animate, slot)
	local ce 
	self.isHolding = false
	slot = slot or "neutral"
	if newEquip then
		-- lume.trace(newEquip)
		self:delSpritePiece(newEquip.sprClass)
		if newEquip.passive then
			self:setPassive(newEquip.name, newEquip.passiveEffect)
		else
			newEquip.toDestroy = false
			if animate then self:setActionState("crouch",1) end
			newEquip.user = self
			newEquip.faction = self.faction
			if self.equipIcons then
				self.equipIcons[slot]:setImage(newEquip.invSprite)
			end
			self.isHolding = newEquip.isHolding
			-- lume.trace(newEquip.spritePiece)
			if newEquip.spritePiece then
				-- lume.trace(newEquip.spritePiece)
				self:addSpritePiece(newEquip.spritePiece,self.depth)
			end
		end
	else
		if slot == "primary" and self.currentPrimary then
			self:delSpritePiece(self.currentPrimary.sprClass)
		elseif self.currentEquips[slot] and self.currentEquips[slot].sprClass then
			self:delSpritePiece(self.currentEquips[slot].sprClass)
		end
		if self.equipIcons and self.equipIcons[slot] then
			self.equipIcons[slot]:setImage(nil)
			self.equipIcons[slot]:setCount(0)
		end
		self:drop(slot)
	end

	if slot == "primary" then
		self.currentPrimary = newEquip
	else
		self.currentEquips[slot] = newEquip
	end
	self:updateIntAmount()

end

--Adds an ObjEquippable subclass to the player's inventory
function ObjUnit:addToInv(item, stackable, amount,overwrite, animate)
	if animate then self:setActionState("crouch",1) end
	if stackable then
		for _,v in self.inventory:iter() do
			if v.type == item.type then
				-- item.inInv = true
				-- lume.trace(item.type)
				-- lume.trace(overwrite)
				if overwrite then
					-- lume.trace("overwrite")
					-- lume.trace(amount)
					item.numInInv = v.numInInv + (amount or 1)
				else
					-- lume.trace()
					v.numInInv = v.numInInv + (amount or 1)
					item.toDestroy = true
					self:updateIntAmount()
					return
				end
			end
		end
	end
	self:equipIfOpen(item, item.isPrimary)
	self.inventory:insert( item )
	self:updateIntAmount()
end

function ObjUnit:equipIfOpen(item, isPrimary)
	if isPrimary then
		if not self.currentPrimary then
			self.inventory:setEquip(item,self,"primary")
		end
	else
		if self.currentEquips["neutral"] and self.currentEquips["neutral"].type == item.type then
			self:setEquip(item,"neutral")
		elseif self.currentEquips["up"] and self.currentEquips["up"].type == item.type then
			self:setEquip(item, "up")
		elseif self.currentEquips["down"] and self.currentEquips["down"].type == item.type then
			self:setEquip(item, "down")
		elseif not self.currentEquips["neutral"] then
			self:setEquip(item,"neutral")
		elseif not self.currentEquips["up"] then
			self:setEquip(item,"up")
		elseif not self.currentEquips["down"] then
			self:setEquip(item,"down")
		end
	end
end

function  ObjUnit:setEquipCreateItem(item ,animate)
	-- util.print_table(self.sprites)
	local class = require( "objects.eqp." .. item )
	local inst = class()
	Game:add(inst)
	-- lume.trace(self.sprites)
	-- util.print_table(self.sprites)
	inst:onPlayerInteract(self)
	--character:setEquip(inst, animate)
	--Game:del(inst)
	return inst
end
-------------------------Animations--------------------------

function ObjUnit:changeAnimation(animation,speedMod,spritePieces)
	if not self.advancedSprites then
		return 
	end
	local speed = speedMod or 1
	speed = 1/speed
	local hasAnimation = false
	local goodKey = "none"
	if type(animation) == "table" then
		for i=1,#animation do
			if self.animations[animation[i]] then
				goodKey = animation[i]
				break
			end
		end
	else
		goodKey = animation
	end
	if self.animations[goodKey] then
		hasAnimation = true
		local anim = self.animations[goodKey]
		local sprites = anim.sprites
		--local noOverride = (anim.noOverride and (#self.animationsPending == 0))
		if type(sprites) == "table" then
			for key,value in pairs(sprites) do
				if (not spritePieces or util.hasValue(spritePieces,key)) and self.sprites[key] then
					local anim2 = value
					local row = anim2.row
					local range = anim2.range
					local delay = anim2.delay * speed
					local startFrame = anim2.startFrame or 1
					local noLoop = anim2.noLoop
					local mDir = anim2.dir or 1
					local priority = (anim2.priority or 1)
					-- if #self.animationsPending ~= 0 then
					-- 	lume.trace()
					-- 	table.insert(self.animationsPending,key)
					-- 	if (self.sprites[key].priority == 0) then
					-- 		lume.trace()
					-- 		for i=1,#self.animationsPending do
					-- 			if self.animationsPending[i] == key then
					-- 				table.remove(self.animationsPending,i)
					-- 			end
					-- 		end
					-- 	end
					-- end
					if (#self.animationsPending == 0 and priority >= self.sprites[key].priority) then
						self.sprites[key]:updateAttach(value.attachMod or {{{x=0,y=0}}})
						if goodKey ~= self.sprites[key].currentAnim then
							--self.sprites[key].attachF = #self.sprites[key].attachMod
							self.sprites[key]:setIndex(0)
							self.sprites[key]:onUpdate()
							self.sprites[key]:resume()
						end
						self.sprites[key].mDir = mDir
						self.sprites[key].currentAnim = goodKey
						self.sprites[key].priority = priority
						self:orientSprite(row,range,delay,startFrame, key,noLoop)
						self:orientAllSprites()
					end
				end
			end
		else
			-- if self.sprites[sprites] then
			-- 	local row = anim.row
			-- 	local range = anim.range
			-- 	local delay = anim.delay
			-- 	local onLoop = anim.onLoop
			-- 	local startFrame = anim.startFrame or 1
			-- 	if value.attachPoints then
			-- 		for key, point in pairs(piece.attachPoints) do
			-- 			sprite:addPoint(key,(point.x -sprite.ox),(point.y -sprite.oy))
			-- 		end
			-- 	end
			-- 	if value.attachMod then
			-- 		self.sprites[key]:updateAttach(value.attachMod or {{{x=0,y=0}}})
			-- 	end
			-- 	local priority = anim2.priority or 1
			-- 	if priority > self.sprites[key].priority then
			-- 		--self:orientSprite(row,range,delay,startFrame, key,onLoop)
			-- 		self:orientAllSprites()
			-- 	end
			-- end
		end
	end
	return hasAnimation
end

function ObjUnit:orientAllSprites()
	for key,value in pairs(self.sprites) do
		value:setScale(self.dir * value.mDir,1)
		value.dir = self.dir
		--self:setSprPos(self.x,self.y + 16 + self.charHeight/2)
	end
end
function ObjUnit:orientSprite(row,range,delay,startFrame, sprite, onLoop)
	local spr = self.sprites[sprite] or self.sprite
	if delay == 0 then delay = 0.1 end
	local md = self.sprites[sprite].mDir
	spr:setScale(self.dir * md,1)
	spr:setAnimation(range,row,1/delay,onLoop)
	spr.dir = self.dir * md
	-- if startFrame and startFrame ~= -1 then
	-- 	spr:setIndex(startFrame)
	-- end
end

function ObjUnit:freezeAnimation(sprite, duration)
	if self.sprites[sprite] then
		self.sprites[sprite]:pause(duration)
	end
end

function ObjUnit:resetAnimation(spritePiece)
	if self.sprites[spritePiece] then
		self.sprites[spritePiece]:resetAnimation()
		self.sprites[spritePiece]:onUpdate()
	end
end
function ObjUnit:overrideAnimation(spritePiece)
	if self.sprites[spritePiece] then
		self.sprites[spritePiece].priority = 0
	end
end

function ObjUnit:normalizeSprSize( speed )
	local s = speed or 8
	self.imgX = math.min( self.imgX + s, self.initImgW )
	self.imgY = math.min( self.imgY + s, self.initImgH)
	--self.sprite:setSize(self.imgX, self.imgY)
end

function ObjUnit:normalizeSprColor( speed )
	local color = self.color
	local s = speed or 1
	for i=1,4 do
		color[i] = math.min( color[i] + s, 255 )
	end
	self.sprite:setColor( unpack(color) )
	if self.sprite2 then
		self.sprite2:setColor(unpack(color))
	end
	if self.sprite3 then
		self.sprite3:setColor( unpack(color))
	end
	if color[1] == 255 and color[2] == 255 and color[3] == 255 and color[4] == 255 then
		self.toNormalizeCol = false
	end
end

function ObjUnit:setSprColor( r, g, b, a )
	self.toNormalizeCol = true
	local color= { r, g, b, a or 255 }
	if self.advancedSprites then
		for k,v in pairs(self.sprites) do
			v:setColor( unpack(color) )
		end
	else
		if self.sprite then
			self.sprite:setColor( unpack(color) )
		end
		if self.sprite2 then
			self.sprite2:setColor(unpack(color) )
		end
		if self.sprite3 then
			self.sprite3:setColor( unpack(color) )
		end
	end
	self.color = color
end

function ObjUnit:animate()
	local maxXSpeed, maxYSpeed = self.maxXSpeed, self.maxYSpeed
	local walkanim = math.abs(4 / self.velX)
	local newVelX = self.velX - self.referenceVel
	walkanim = math.max(walkanim, 0.18)

	if self.inAir then 
		if self.turnTime and self.turnTime > 0 then
				self:changeAnimation({"fallTurn","fall"})
		elseif not self.turnTime and self.velY < 0 or self.jumping then
			self:changeAnimation("jump")
		else
			self:changeAnimation({"fall","jump"})
		end
	elseif self.isCrouching then
		self:changeAnimation({"crouch","stand"})
	elseif self.isMoving then
		self.idleCounter = 0
		if (self.dir == 1 and newVelX < -16) or (self.dir == -1 and newVelX > 16) then
			self:changeAnimation({"slideMore","slide","stand"})
		else
			if self.status == "offense" and self.prepTime > 5 then
				--self:changeAnimation("prep2")
				
				--self:freezeAnimation("body",0.0)
				--self:freezeAnimation("head",0.0)
			end 
			if math.abs(newVelX) >= maxXSpeed - 52 then
				self:changeAnimation({"run","walk"})
			else
				self:changeAnimation("walk")
			end
		end
	else
		if math.abs(newVelX) <= 32 then
			self.idleCounter = self.idleCounter + 1
			if self.status == "offense" and self.prepTime > 5 then
			--	self:changeAnimation({"prep","stand"})
			else
				if self.idleCounter >= 60 and self.idleCounter < 89 then
					self:changeAnimation({"idleStart","idle","stand"})
				elseif self.idleCounter > 84 then
					self:changeAnimation({"idle","stand"})
				else
					self:changeAnimation("stand")
				end
			end
			-- if self.idleCounter >= 84 then
			-- 	self.idleCounter = 0
			-- end
		else
			self:changeAnimation({"slide","stand"})
		end
	end
	if self.isHolding then
		self:changeAnimation({"holding","guard"})
	end

	if self.shieldDelay > 165 then
		self:changeAnimation({"guard","stand"})
	end

end

function ObjUnit:addSpritePieces( newPieces )
	local depth = self.depth
	for key, piece in pairs(newPieces) do
		self:addSpritePiece(piece ,depth)
		depth = depth + 1
	end
end

function ObjUnit:addSpritePiece( piece , d)
	local sprite
	local SpritePiece = require "xl.SpritePiece"
	d = d or self.depth
	self.advancedSprites = true
	sprite = SpritePiece(piece.path, (piece.width or 128), (piece.height or 128),0,d)
	sprite:setOrigin((piece.originX or piece.width/2), (piece.originY or piece.height/2))
	sprite:setSize((piece.imgX or piece.width/2), (piece.imgY or piece.height/2))
	if piece.attachPoints then
		for key, point in pairs(piece.attachPoints) do
			self.attachPositions[key] = {x=(point.x -sprite.ox), y =(point.y -sprite.oy)}
			sprite:addPoint(key,(point.x -sprite.ox),(point.y -sprite.oy))
		end
	end
	if piece.connectSprite then
		local connectSprite
		-- lume.trace(piece.connectSprite, piece.name,self.type)
		-- util.print_table(self.sprites)
		for key, sprite in pairs(self.sprites) do
			-- lume.trace(key, piece.connectSprite)
			if key == piece.connectSprite then
				connectSprite = sprite
				-- lume.trace("hh")
				break
			end
		end
		sprite:addConnectPoint(connectSprite, piece.connectPoint,piece.connectMPoint)
	end
	sprite:setAnimation(1,1,1)
	sprite:setDepth(d + (piece.z or 0))
	Game.scene:insert(sprite)
	self.sprites[piece.name] = sprite
	-- lume.trace(piece.animations)
	if piece.animations then
		-- lume.trace()
		local animations
		if type(piece.animations) == "string" then
			animations = require(piece.animations)
		else
			animations = piece.animations
		end
		for k,v in pairs(animations) do
			if not self.animations[k] then
				self.animations[k] = {}
				self.animations[k]["sprites"] = {}
			end
			self.animations[k]["sprites"][piece.name] = v
		end
	end
end

function ObjUnit:delSpritePiece( pieceName )
	if self.sprites[pieceName] then
		Game.scene:remove(self.sprites[pieceName])
		self.sprites[pieceName] = nil
	end
end

function ObjUnit:addLight( lightName, x,y,radius, r,g,b)
	local lights = Lights.newGradSpotLight((radius or 32),8,270)

	lights:setPosition(self.x, self.y)
	lights:setColor((r or 1),(g or 1),(b or 1))
	Game.lights:add(lights)
	local table = {
	light = lights,
	offsetX = x or 0,
	offsetY = y or 0
	}
	self.lights[lightName] = table
end

function ObjUnit:delLight( lightName )
	if self.lights[lightName] then
		Game.lights:del(self.lights[lightName].light)
		self.lights[lightName] = nil
	end
end

function ObjUnit:getAttachPos(attachPoint )
	return self.attachPositions[attachPoint]
end

function ObjUnit:setSprPos( x , y )
	for key, piece in pairs(self.sprites) do
		local piecesPos = piece:updatePos(x,y + 16)
		--util.print_table(piecesPos)
		for k,v in pairs(piecesPos) do
			-- error("Hiohio")
			self.attachPositions[k] = v
			-- util.print_table(self.attachPositions)
		end
		--util.print_table(self.attachPositions)
	end
	if self.sprite then
		self.sprite:setPosition(x,y - 8)
	end
	for key, piece in pairs( self.lights ) do
		self.lights[key].light:setPosition(x + self.lights[key].offsetX,y + self.lights[key].offsetY)
	end
end

function ObjUnit:setSprAngle( angle )
	for key, piece in pairs(self.sprites) do
		piece:setAngle(angle)
	end
	if self.sprite then
		self.sprite:setAngle(angle)
	end
end

function ObjUnit:setDepth( depth )
	self.depth = depth
end
-------------------------Physics--------------------------
function ObjUnit:testProximity(destinationX, destinationY, proximity)
	if 	math.sqrt(((destinationX - self.x) * (destinationX - self.x)) +
		((destinationY - self.y) * (destinationY - self.y)) ) <= proximity then
		return true
	else
		return false
	end
end

function ObjUnit:setPosition(x,y)
	self.canTeleport = true
	self.newX = x
	self.newY = y
end

function ObjUnit:getDistanceToPoint( pointX, pointY )
	return math.sqrt(math.pow(pointX - self.x,2) + math.pow(pointY - self.y,2 ) )
end

function ObjUnit:setJumpThru( timer )
	-- lume.trace(timer)

	self.oldMask = self.fixture:getMask()
	if self.oldMask == 3 then
		self.oldMask = nil
	end
	-- lume.trace(self.oldMask)
	local checkGroundY = self.y + (self.charHeight or self.height) + 4
	self.numJumpThru = 0
	Game.world:rayCast(self.x - 3, checkGroundY - 20, self.x - 3, checkGroundY, self.checkJumpThru)
	Game.world:rayCast(self.x + 3, checkGroundY - 20, self.x + 3, checkGroundY , self.checkJumpThru)
	if self.numJumpThru > 0 then
		self.isMoving = true
	end
	self.numJumpThru = nil
	if self.oldMask then
		self.fixture:setMask(self.oldMask,CL_PLAT)
	else
		self.fixture:setMask(CL_PLAT)
	end
	self.thruTimer = math.max(self.thruTimer, timer)
end

function ObjUnit:processJumpThru()
	if self.thruTimer and self.thruTimer > 0 then
		self.thruTimer = self.thruTimer - 1
		-- lume.trace(self.thruTimer)
		if self.thruTimer == 0 then
			-- lume.trace()
			local checkGroundY = self.y + (self.charHeight or self.height)
			self.numJumpThru = 0
			self.numContacts = 0
			Game.world:rayCast(self.x - 3, checkGroundY - 20, self.x - 3, checkGroundY, self.checkJumpThru)
			Game.world:rayCast(self.x + 3, checkGroundY - 20, self.x + 3, checkGroundY , self.checkJumpThru)
			if self.numJumpThru == 0 then
				if self.oldMask then
					self.fixture:setMask(self.oldMask)
				else
					self.fixture:setMask(16)
				end
				self.numJumpThru = nil
			else
				self.thruTimer = self.thruTimer + 1
			end
		end
	end
end

function ObjUnit:mCheckJumpThru(fixture, x, y, xn, yn, fraction )
	if fixture then
		local other = fixture:getBody():getUserData()
		local category = fixture:getCategory()
		if other ~= nil then
			-- local mask1, mask2, mask3 = fixture:getMask()
			if Class.istype(other,"ObjWall") then
				self.numContacts = self.numContacts + 1
				if category == CL_PLAT then
					self.numJumpThru = self.numJumpThru + 1
				end
			end
		end
	end
	return 1
end
---------------------------AI Tests----------------------------

function ObjUnit:registerHit(target, hitType, hitbox)
	-- lume.trace(target.type)
	-- lume.trace(target.health)
	-- lume.trace(target.max_health)
	if self.deflectable and hitType == "blocked" and not hitbox.heavyAttack then
		if Class.istype(self,"ObjChar") then 
			self:setHitState(30,64 * -self.dir,-1 * 32,0,"guardDeflect") 
		else
			self:setHitState(40,64 * -self.dir,-1 * 32,0,"guardDeflect") 
		end
	end
	if hitType == "hit" and (target.status == "guard_broken") then
		-- target:setHitState()
		Game.WorldManager:flash()
	end
	-- lume.trace(target.status)
	target.currentTarget = self
end

function ObjUnit:moveToPoint(destinationX, destinationY, proximity,grounded)
	local velX, velY = self.body:getLinearVelocity()
	local distance = math.sqrt(((destinationX - self.x) * (destinationX - self.x)) +
		((destinationY - self.y) * (destinationY - self.y)) )
	if proximity ~= nil and distance <= proximity then
		return
	else
		if self.x < destinationX then
			self.dir = 1
			self.isMoving = true
			if velX < (self.maxXSpeed * self.speedModifier) then
				self.forceX = self.acceleration  * self.body:getMass()
			end
		elseif self.x > destinationX then
			self.dir = -1
			self.isMoving = true
			if velX > -(self.maxXSpeed * self.speedModifier) then
				self.forceX = -self.acceleration  * self.body:getMass()
			end
		end
	end
	if not grounded and  math.abs(self.forceX) ~= 0 and math.abs(velX) <= 16 then-- if something is stopping you, try jumping
		self.jmpCount1 = self.jmpCount1 + 1
	else
		self.jmpCount1 = 0
	end

	if not grounded and destinationY - self.y < -24 then -- if target is higher than you, try jumping
		self.jmpCount2 = self.jmpCount2 + 1
	else
		self.jmpCount2 = 0
	end
	if not grounded and (self.jmpCount1 >= 8 or self.jmpCount2 >= 16) and (self.jmpCount2 < 240) then
		self:jump()
	else
		self.jumpCooldown = 0
		self.currentJumpTime = 0
		self.jumping = false
	end
end

function ObjUnit:getAngleToPoint(x, y)
	local angle = math.atan2(y - self.y, x - self.x)
	return angle
end

function ObjUnit:turnToPoint(x, y)
	if x > self.x then
		self.dir = 1
	else
		self.dir = -1
	end
end

function ObjUnit:checkGround()
	local checkGroundY = self.y + (self.charHeight or self.height) + 4
	self.numContacts = 0
	self.numInt = 0
	self.groundLevel = nil
	self.slopeDir = 0
	Game.world:rayCast(self.x - 3, checkGroundY - 24, self.x - 3, checkGroundY, self.wrapCheckGround)
	Game.world:rayCast(self.x + 3, checkGroundY - 24, self.x + 3, checkGroundY , self.wrapCheckGround)
	if self.numContacts > 0 then
		return true
	else
		return false
	end
end

function ObjUnit:mCheckGround(fixture, x, y, xn, yn, fraction )
	if fixture then
		local other = fixture:getBody():getUserData()
		local category = fixture:getCategory()
		if other ~= nil then
			local mask1, mask2, mask3 = fixture:getMask()
			if fixture:isSensor() == false and category ~= CL_INT and other ~= self and mask1 ~= CL_CHAR then--and not (category == CL_PLAT and self.thruTimer > 0)  then
					--and not Class.istype(other,"ObjChar") and other ~= self then
				self.numContacts = self.numContacts + 1
				if self.groundLevel and self.type == "ObjChar" then
					local newLevel = y - (self.height/2)
					self.slopeDir = 0
					--self.body:applyForce(0, -self.body:getMass() * 480)
					if self.groundLevel - newLevel < -2 then
						self.slopeDir = -1
						--self.body:applyForce(0, -self.body:getMass() * 480)
					elseif self.groundLevel - newLevel > 2 then
						self.slopeDir = 1
						--self.body:applyForce(0, -self.body:getMass() * 480)
					end
					self.groundLevel = math.min(self.groundLevel, newLevel)
				else
					if x > self.x then
						self.slopeDir = 1
					else
						self.slopeDir = -1
					end
					self.groundLevel = y - self.height/2
				end
				local oX,oY = other.body:getLinearVelocity()
				if math.abs(oX) > math.abs(self.referenceVel) then
					self.referenceVel = oX
					if not self.inAir and not self.jumping then 
						self.body:applyForce(self.body:getMass() * 12 * oX,0)
					end
				end
			end
		end
	end
	return 1
end

function ObjUnit:checkInt(fixture)
	if fixture then
		local other = fixture:getBody():getUserData()
		if other and Class.istype(other, "ObjInteractive") and other.intBoxActive then
			if not Class.istype(other, "ObjEquippable") and other ~= self.currentEquips and other ~= self.currentPrimary then
				self.numInt = self.numInt + 1
			end
		end
	end
	return 1
end

function ObjUnit:manageInt( )
	-- if self.detectBox then
	-- 	local xOffset = 10 * self.dir
	-- 	local yOffset = 0
	-- 	self.exclamation:setPosition(self.x, self.y - 48)
	-- 	Game.world:queryBoundingBox(self.x + xOffset - 8, self.y + yOffset - 8, self.x + xOffset + 8, self.y + yOffset + 8, self.wrapDetectInt)
	-- 	if self.exclamationAdded and (not self.displayExclamation or self.numInt <= 0) then
	-- 		Game.scene:remove(self.exclamation)
	-- 		self.exclamationAdded = false
	-- 	elseif self.numInt > 0 and not self.exclamationAdded and self.displayExclamation then
	-- 		Game.scene:insert(self.exclamation)
	-- 		self.exclamationAdded = true
	-- 	end
	-- end
end

function ObjUnit:setHealth( health )
	self.health = math.min(self.max_health,math.max(health,0))
	self.redHealth = math.min(self.redHealth,self.health)
end

function ObjUnit:getHealth(  )
	return self.health
end

function ObjUnit:setGoal( x, y ,tolerance)
	self.initX = x
	self.initY = y
	self.tolerance = tolerance or 4
end

function ObjUnit:moveToGoal( )
	if not self:testProximity(self.initX, self.initY, 16) then
		self:moveToPoint(self.initX, self.initY,8,true)
	end
end

function ObjUnit:destroy()
	if not self.destroyed then
		if self.currentEquips then
			for k,v in pairs(self.currentEquips) do
				self:drop(k, Class.istype(self,"ObjEnemy"))
			end
		end
		if self.currentPrimary then
			self:drop("primary", Class.istype(self,"ObjEnemy"))
		end
		for key, value in pairs(self.sprites) do
			self:delSpritePiece(key)
		end
		if self.sprite then
			Game.scene:remove(self.sprite)
		end 
		for key, value in pairs(self.lights) do
			self:delLight(key)
		end
		if self.dmgHitbox then
			Game:del(self.dmgHitbox)
		end
		if self.body then
			self.body:destroy()
		end
		self.destroyed = true
	end
end

return ObjUnit