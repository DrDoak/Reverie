local ModPhysics = Class.create("ModPhysics", Entity, {health = 1})

----------------------Initialization-----------------
function ModPhysics:init( x, y )
	self.x = x
	self.y = y
end

function ModPhysics:create()
	--set default stats
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

	--default state information
	self.forceX = 0
	self.forceY = 0
	self.velX = 0
	self.velY = 0

	self.referenceVel = 0

	self.created = true

	self.wrapCheckGround = lume.fn(ModPhysics.mCheckGround, self)
	self.checkJumpThru = lume.fn(ModPhysics.mCheckJumpThru, self)
	self.attachPositions = {}
end

---------------------------Ticks---------------------------
function ModPhysics:tick(dt) 
	local body = self.body
	self.x,self.y = body:getPosition()
	self.velX, self.velY = body:getLinearVelocity()

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

	-- --Apply physics to the b2body
	self:move( dt, self.body, self.forceX, self.forceY, self.isMoving)
end

-------------------Physics Modifiers----------------------

function ModPhysics:setSpeedModifier(modifier)
	local velX, velY = self.body:getLinearVelocity()
	self.body:setLinearVelocity(velX * modifier, velY * modifier)
	self.speedModifier = modifier
end

function ModPhysics:move( dt, body, forceX, forceY, isMovingX)
	local decForce = self.deceleration * body:getMass()
	local velX, velY = body:getLinearVelocity()

	-- Staying stable on slopes
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

function ModPhysics:setFixture( shape, mass, isSensor)
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
function ModPhysics:onCollide(other, collision)
	if self.state == 1 and self.velY > 400 then
		self:landing()
	end
end

function ModPhysics:landing( )
	local function hit_ground( player, count )
		player:changeAnimation("crouch")
		if count >= 15 then
			player.exit = true
		end
	end
	self:setSpecialState(hit_ground)
end

-------------------------Physics--------------------------
function ModPhysics:testProximity(destinationX, destinationY, proximity)
	if 	math.sqrt(((destinationX - self.x) * (destinationX - self.x)) +
		((destinationY - self.y) * (destinationY - self.y)) ) <= proximity then
		return true
	else
		return false
	end
end

function ModPhysics:setPosition(x,y)
	self.canTeleport = true
	self.newX = x
	self.newY = y
end

function ModPhysics:getDistanceToPoint( pointX, pointY )
	return math.sqrt(math.pow(pointX - self.x,2) + math.pow(pointY - self.y,2 ) )
end

function ModPhysics:setJumpThru( timer )
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

function ModPhysics:processJumpThru()
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

function ModPhysics:mCheckJumpThru(fixture, x, y, xn, yn, fraction )
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

function ModPhysics:getAngleToPoint(x, y)
	local angle = math.atan2(y - self.y, x - self.x)
	return angle
end

function ModPhysics:turnToPoint(x, y)
	if x > self.x then
		self.dir = 1
	else
		self.dir = -1
	end
end

function ModPhysics:checkGround()
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

function ModPhysics:mCheckGround(fixture, x, y, xn, yn, fraction )
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

function ModPhysics:destroy()
	if self.body then
		self.body:destroy()
	end
end

return ModPhysics