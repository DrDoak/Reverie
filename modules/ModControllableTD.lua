local ModControllable = require "modules.ModControllable"
local Keymap  = require "xl.Keymap"

local ModControllableTD = Class.create("ModControllableTD", ModControllable)
ModControllableTD.dependencies = {"ModActive","ModInventory"}
ModControllableTD.trackFunctions = {"normalState"}


function ModControllableTD:normalState()
	local maxSpeed, maxYSpeed = self.maxSpeed, self.maxYSpeed
	self:normalMove()
	self:animate()
	self:proccessInventory()
end

--Manages left/right
function ModControllableTD:normalMove(maxXSpeed, maxYSpeed)
	--Movement Code
	maxXSpeed = maxXSpeed or self.maxXSpeed
	maxYSpeed = maxYSpeed or self.maxYSpeed
	local accForce = self.acceleration * self.body:getMass()

	local dvX,xdir,dvY,ydir = 0,0,0,0
	if Keymap.isDown("up") then 
		dvY = dvY - 1
		self.dir = -1 --0
	end
	if Keymap.isDown("down") then 
		dvY = dvY + 1
	 	self.dir = 1 --2
	end

	if Keymap.isDown("left") then 
		dvX = dvX - 1
		self.dir = -1 
	end
	if Keymap.isDown("right") then 
		dvX = dvX + 1
	 	self.dir =   1 
	end
	if dvX ~= 0 and math.abs(self.velX - self.referenceVelX) < maxXSpeed * self.speedModX then
		self.forceX = dvX * accForce
		if util.sign(self.velX) == dvX then
			self.forceX = self.forceX * 2
		end
	end
	if dvX ~= 0 and math.abs(self.velX - self.referenceVelY) < maxYSpeed * self.speedModY then
		self.forceY = dvY * accForce
		if util.sign(self.velY) == dvY then
			self.forceY = self.forceY * 2
		end
	end
	self.forceX = self:calcForce( dvX, self.velX, accForce, maxXSpeed )
	self.forceY = self:calcForce( dvY, self.velY, accForce, maxYSpeed )
	self.isMovingX = (dvX ~= 0) or self.inAir 
	self.isMovingY = (dvY ~= 0) or self.inAir
end

return ModControllableTD