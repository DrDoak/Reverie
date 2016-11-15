local ObjAttackHitbox = Class.create("ObjAttackHitbox", Entity)
--[[
Description: Base for all Attack Hitboxes
Tiled Map Requirements: Object cannot be created via tiled
Required Parameters:
x = x coordinate of the centre of the hitbox
y = y coordinate of the centre of the hitbox
width = width of the hitbox
height = height of the hitbox
"attacker" = reference to the attacker object
damage = The amount the hitbox lowers the HP of the target object
stun = the stun time the hitbox inflicts on the target object (Frames)
persistence = how long the hitbox stays active in frames (30 FPS) 
forceX = amount of the knockback the hitbox deals in the X direction
forceY = the amount of vertical knockback the hitbox deals
element = string, if the hitbox has an 
]]

function ObjAttackHitbox:init(posX, posY, width, height, attacker, damage ,
	stun, persistence , forceX , forceY, element, deflect)
	self.x = posX
	self.y = posY
	self.width = width
	self.height = height
	self.attacker = attacker
	self.damage = damage
	self.stun = stun
	self.persistence = persistence
	self.forceX = forceX
	self.forceY = forceY
	self.element = element
	self.deflect = deflect
end
function ObjAttackHitbox:setGuardDamage(guardDamage)
	self.guardDamage = guardDamage or self.damage
	-- lume.trace(self.guardDamage)
end
function ObjAttackHitbox:setGuardStun(guardStun)
	self.guardStun = guardStun or self.stun
end
function ObjAttackHitbox:setIsUnblockable(unblockable)
	self.isUnblockable = unblockable
end
function ObjAttackHitbox:setIsLight(light)
	self.isLight = light
end

function ObjAttackHitbox:create()
	self.body = love.physics.newBody(self:world(), self.x, self.y, "dynamic")
	self.body:setFixedRotation(true)
	self.body:setUserData(self)
	self.body:setGravityScale(0.0)
	self.faction = self.faction or self.attacker.faction
	if self.height == nil then
		self.shape = love.physics.newCircleShape(self.width)
	else
		self.shape = love.physics.newRectangleShape(self.width, self.height)
	end
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self.fixture:setSensor(true)
	self.objectsHit = {}
	self.refresh = 0
	-- self.fixtureDRAW = xl.SHOW_HITBOX(self.fixture)
	-- lume.trace(self.guardDamage)
end
 
function ObjAttackHitbox:setFaction( faction )
	self.faction = faction
end

function ObjAttackHitbox:tick(dt)
	-- lume.trace(self.guardDamage)
	self.x, self.y = self.body:getPosition()
	if self.refreshTime then
		-- self.refresh = self.refresh + 1
		-- if self.refresh >= self.refreshTime then
		-- 	self.objectsHit = {}
		-- end
		for k,v in pairs(self.objectsHit) do
			-- lume.trace(k, v)
			self.objectsHit[k] = v + 1
			if v > self.refreshTime then
				-- lume.trace("removed from list")
				self.objectsHit[k] = nil
			end
		end
	end
	if self.persistence then
		if self.persistence <= 0 then
			return Game:del(self)
		else 
			self.persistence = self.persistence  - dt
		end		
	end
	if self.followObj and not self.followObj.destroyed then
		self.body:setPosition(self.followObj.x + (self.offsetX * self.followObj.dir), self.followObj.y + self.offsetY)
	else
		self.body:setPosition(self.x,self.y)
	end
end

function ObjAttackHitbox:destroy()
	if not self.destroyed then
		self.body:destroy()
		self.destroyed = true
	end
end

function ObjAttackHitbox:setFollow(followObj,offsetX,offsetY)
	self.followObj = followObj
	self.offsetX = offsetX or 0
	self.offsetY = offsetY or 0
end
function ObjAttackHitbox:setPersistence( pers )
	self.persistence = pers
end

function ObjAttackHitbox:setHeavy( heavyAttack )
	self.heavyAttack = heavyAttack
end

function ObjAttackHitbox:setPosition( x,y )
	self.x = x
	self.y = y
	self.body:setPosition(self.x,self.y)
end

function ObjAttackHitbox:setRefreshTime( refreshTime )
	self.refreshTime = refreshTime
	self.refresh = 0
end

function ObjAttackHitbox:setAngle( angle )
	self.angle = angle
	self.body:setAngle(angle)
end

-- Anothing thing about physics is that upon collision between any two objects, it will call BOTH object''s
-- onCollide method. it will send the following parameters.
-- other: whatever the other object this object collided with.
-- collision: don't worry too much about it. I don't use this. But technically, this is a collision "event", with some
-- data about the collision, like collision points, etc. Thus, in this example, I create a hitbox, and if the hitbox hits anything,
-- it will call this function. tapp. 
function ObjAttackHitbox:onCollide(other, collision)
	if other ~= nil and other ~= self.attacker then
		-- for i = 1, #self.objectsHit do
		-- 	if other == self.objectsHit[i] then
		-- 		return
		-- 	end
		-- end
		for k,v in pairs(self.objectsHit) do
			if k == other then
				return
			end
		end
		if Class.istype(other, "ObjBase")  and other:hasModule("ModActive") then
			if (other == self.attacker) then
				return
			else
				if self.forceY == nil then
					local angle = math.atan2(other.y - self.y, other.x - self.x)
					if self.forceX then
						self.forceX = math.cos(angle) * self.forceX
						self.forceY = math.sin(angle) * self.forceX
					end
				end
				-- lume.trace(self.guardDamage)
				local hitType = other:setHitState(self.stun,self.forceX,self.forceY,self.damage, self.element,self.faction,self.guardDamage,self.guardStun,self.isUnblockable)
				if hitType then
					-- table.insert(self.objectsHit, other)
					self.objectsHit[other] = 1
					self.refresh = 0
					local posX2= other.x
					local posY2 = other.y
					local x = (self.x + posX2)/2
					local y = (self.y + posY2)/2
					if not self.attacker.registerHit then
						error("attacker: ", self.attacker.type, "cannot register hit")
					end
					self.attacker:registerHit(other, hitType, self)
				end
			end
		end
		if self.deflect and Class.istype(other, "SHBase") and not other.deflected and other.range > 0 then
			if other:setDeflectState(self.stun,self.forceX,self.forceY,self.damage, self.element,self.faction) then
				lume.trace(other.range)
				-- table.insert(self.objectsHit, other)
				self.objectsHit[other] = 1
				local posX2= other.x
				local posY2 = other.y
				local x = (self.x + posX2)/2
				local y = (self.y + posY2)/2
			end
		end
	end
end

return ObjAttackHitbox