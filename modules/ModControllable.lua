local Keymap  = require "xl.Keymap"
local ObjIntHitbox = require "objects.ObjIntHitbox"

local ModControllable = Class.create("ModControllable", Entity)
ModControllable.dependencies = {"ModActive","ModInventory","ModCharacter","ModCharacterDetector"}
ModControllable.trackFunctions = {"normalState"}


function ModControllable:normalState()
	local maxSpeed, maxSpeedY = self.maxSpeed, self.maxSpeedY
	self:normalMove()
	self:animate()
	self:proccessInventory()
 	xl.DScreen.print("charpos: ", "(%f,%f)",self.x,self.y)
 	xl.DScreen.print("charDir: ", "(%f)",self.dir)
 	xl.DScreen.print("speedMod: ", "(%f,%f)",self.speedModX,self.speedModY)
end

--Manages left/right
function ModControllable:normalMove(maxSpeedX, maxSpeedY)
	--Movement Code
	maxSpeedX = maxSpeedX or self.maxSpeedX
	maxSpeedY = maxSpeedY or self.maxSpeedY
	local accForce = self.acceleration * self.body:getMass()

	local dvX,xdir,dvY,ydir = 0,0,0,0
	if Keymap.isDown("up") then 
		dvY = dvY - 1
		self.dir = 0
	end
	if Keymap.isDown("down") then 
		dvY = dvY + 1
	 	self.dir = 2
	end

	if Keymap.isDown("left") then 
		dvX = dvX - 1
		self.dir = -1 
		-- self.body:setLinearVelocity(-32*3,0)
	end
	if Keymap.isDown("right") then 
		dvX = dvX + 1
	 	self.dir =   1 
		-- self.body:setLinearVelocity(32*3,0)
	end
	if dvX ~= 0 and math.abs(self.velX - self.referenceVelX) < (maxSpeedX * self.speedModX) then
		self.forceX = dvX * accForce
		if util.sign(self.velX) == dvX then
			self.forceX = self.forceX * 2
		end
	end
	if dvY ~= 0 and math.abs(self.velY - self.referenceVelY) < (maxSpeedY * self.speedModY) then
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

function ModControllable:lockOnControls( )
	if Keymap.isPressed("lockon") then
		local targets = Game:findObjectsWithModule("ModCharacter")
		for i,obj in ipairs(targets) do
			-- lume.trace(obj.type)
			if self:validTarget(obj) then
				self:setTarget(obj)
			end
		end
	end
end
function ModControllable:proccessInventory()
	self:lockOnControls()

	if Keymap.isPressed("interact") then
		if self.targetObj then
			self:setTarget(nil)
		elseif not Game.DialogActive then
			local intHitbox = ObjIntHitbox(self) 
			Game:add(intHitbox)
		end
	end
end

function ModControllable:performResponse( eventName, eventTags, params )
	self.proposedActions = {}
	for tagName,tagValue in pairs(eventTags) do
		self:checkIfNeedNewTag(tagName)
		for topic,allFunctions in pairs(self.allTagResponses[tagName]) do
			for i,realFunction in ipairs(allFunctions) do
				-- lume.trace(topic.name,tagName,realFunction)
				realFunction(self,params,tagName,eventTags,topic) --,self.AIPieces[aiPieceName])
			end
		end
	end
	-- self:executeProposedActions()
end

function ModControllable:proposeAction()
	-- body
end

function ModControllable:executeProposedActions()
	-- body
end

return ModControllable