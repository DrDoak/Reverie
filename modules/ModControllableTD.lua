local ModControllable = require "modules.ModControllable"
local Keymap  = require "xl.Keymap"

local ModControllableTD = Class.create("ModControllableTD", ModControllable)
ModControllableTD.dependencies = {"ModActive","ModInventory"}
ModControllableTD.trackFunctions = {"normalState"}


function ModControllableTD:normalState()
	local maxSpeed, maxSpeedY = self.maxSpeed, self.maxSpeedY
	self:normalMove()
	self:animate()
	self:proccessInventory()
 	xl.DScreen.print("charpos: ", "(%f,%f)",self.x,self.y)

end

--Manages left/right
function ModControllableTD:normalMove(maxSpeedX, maxSpeedY)
	--Movement Code
	maxSpeedX = maxSpeedX or self.maxSpeedX
	maxSpeedY = maxSpeedY or self.maxSpeedY
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
	if dvX ~= 0 and math.abs(self.velX - self.referenceVelX) < maxSpeedX * self.speedModX then
		self.forceX = dvX * accForce
		if util.sign(self.velX) == dvX then
			self.forceX = self.forceX * 2
		end
	end
	if dvX ~= 0 and math.abs(self.velX - self.referenceVelY) < maxSpeedY * self.speedModY then
		self.forceY = dvY * accForce
		if util.sign(self.velY) == dvY then
			self.forceY = self.forceY * 2
		end
	end
	self.forceX = self:calcForce( dvX, self.velX, accForce, maxSpeedX )
	self.forceY = self:calcForce( dvY, self.velY, accForce, maxSpeedY )
	self.isMovingX = (dvX ~= 0) or self.inAir 
	self.isMovingY = (dvY ~= 0) or self.inAir
end

return ModControllableTD