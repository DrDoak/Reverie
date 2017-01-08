local ModTargetEqp = Class.create("ModTargetEqp",Entity)
ModTargetEqp.dependencies = {"ModEquippable"}
local Scene = require "xl.Scene"

function ModTargetEqp:create()
	-- States
	self.stability = 0.5
	self.marksmanship = 0.5
	self.aimSpeed = 0.2
	self.quickDraw = 0.5
	self.critAimSpeed = self.aimSpeed * 0.6
	self.reactionSpeed = 0.7

	-- measurement values
	self.accuracy = 1.0
	self.criticalAccuracy = 1.0

	self.penaltyMovement = 0
	self.penaltyTarget = 0
	self.penaltyAim= 0
	self.penaltyReaction = 0

	self.critPenaltyMovement = 0
	self.critPenaltyTarget = 0
	self.critPenaltyAim = 0
	self.critPenaltyReaction = 0

	self.aimTime = 0
	self.lastTarget = nil
	self.lastVel = {x=0,y=0}
	self.lastTargetVel = {x=0,y=0}


	local drawFunc = function()
		local floor = math.floor
		local bx,by = self.targetX,self.targetY
		local loveGraphics = love.graphics
		loveGraphics.push()
		loveGraphics.translate( bx, by + 16 )
		-- loveGraphics.setColor(50, 200, 50)

		love.graphics.setFont( xl.getFont() )
		love.graphics.setPointSize(8)

		love.graphics.print("Body:".. math.floor(self.accuracy * 100) .. "%", 0, 0)
		love.graphics.print("Head:".. math.floor(self.criticalAccuracy * 100) .. "%", 0, 16)

		loveGraphics.pop()
    end
	self.infoText = Scene.wrapNode({draw = drawFunc}, 9900)
end

function ModTargetEqp:onEquipTick( dt )
	if self.user.targetObj then
		self:calculateAccuracy(self.user,self.user.targetObj,dt)
		self.targetX = self.user.targetObj.x - 48
		self.targetY = self.user.targetObj.y - 88
		if not self.insertedTargetText then
			Game.scene:insert(self.infoText)
			self.insertedTargetText = true
		end
	elseif self.insertedTargetText then
		self.lastTarget = nil
		Game.scene:remove(self.infoText)
		self.insertedTargetText = false
	end
end

function ModTargetEqp:calculateAccuracy( user, target ,dt)
	local dist = xl.distance(user.x,user.y,target.x,target.y)
 	xl.DScreen.print("d---: ", "(%f)",dist)

	-- Aiming penalty
	if self.lastTarget ~= target then
		self.aimTime = 0
		self.penaltyAim = 1.0 - self.quickDraw
		self.critPenaltyAim = 1.0 - (self.quickDraw * 0.5)
		self.lastTarget = target
	end
	self.aimTime = self.aimTime + dt
	self.penaltyAim = math.max(0, self.penaltyAim - (self.aimSpeed * ( self.penaltyAim/0.2 ) * (80/math.max(16,dist)) + 0.01)* dt )
	self.critPenaltyAim = math.max(0, self.critPenaltyAim - (self.critAimSpeed * (self.critPenaltyAim/0.4) * (80/math.max(16,dist)) +0.01)* dt)

	-- Reaction Penalty
	local timeSeen = 0
	if user.characterTrackInfo[target.name] and user.characterTrackInfo[target.name].timeInView then
		timeSeen = user.characterTrackInfo[target.name].timeInView 
	end
	self.penaltyReaction = math.max(0,0.8 - (timeSeen * self.reactionSpeed))
	self.critPenaltyReaction = math.max(0, 1.0 - (timeSeen * self.reactionSpeed))
	-- Movement penalty
	local newVelX = user.velX - user.referenceVelX
	local newVelY = (user.velY - user.referenceVelY) * 1.4

	if 	(math.abs(newVelX) > 16 and math.abs(self.lastVel.x) < 16) or
		(math.abs(newVelY) > 16 and math.abs(self.lastVel.y) < 16) or 
		(math.abs(newVelX) > 16 and (util.sign(newVelX) ~= util.sign(self.lastVel.x))) or 
		(math.abs(newVelY) > 16 and (util.sign(newVelY) ~= util.sign(self.lastVel.y))) then
		self.penaltyMovement = math.min(0.5, self.penaltyMovement + 0.2i)
		self.critPenaltyMovement = math.min(0.6,self.critPenaltyMovement + 0.2)
		
	else
		self.penaltyMovement = math.max(0, self.penaltyMovement - (self.stability * (self.penaltyMovement/0.5) + 0.03) * (48/math.max(16,dist)) * dt)
		self.critPenaltyMovement = math.max(0,self.critPenaltyMovement - (self.stability * (self.critPenaltyMovement/0.6) + 0.02)* (48/math.max(16,dist)) * dt)
	end

	self.lastVel.x = newVelX
	self.lastVel.y = newVelY
	-- target Movement penalty
	local relVelX = target.velX - target.referenceVelX
	local relVelY = (target.velY - target.referenceVelY) * 1.4
	if 	(math.abs(relVelX) > 16 and math.abs(self.lastTargetVel.x) < 16) or
		(math.abs(relVelY) > 16 and math.abs(self.lastTargetVel.y) < 16) or 
		(math.abs(relVelX) > 16 and (util.sign(relVelX) ~= util.sign(self.lastTargetVel.x))) or 
		(math.abs(relVelY) > 16 and (util.sign(relVelY) ~= util.sign(self.lastTargetVel.y))) then
		self.penaltyTarget = math.min(0.8, self.penaltyTarget + 0.2)
		self.critPenaltyTarget = math.min(1.0,self.critPenaltyTarget + 0.2)
	else
		self.penaltyTarget = math.max(0, self.penaltyTarget - (self.marksmanship * (self.penaltyTarget/0.5) * (64/math.max(16,dist) + (0.01) )) * dt)
		self.critPenaltyTarget = math.max(0,self.critPenaltyTarget - (self.marksmanship * 0.6 * (self.critPenaltyTarget/0.6)* ( 64/math.max(16,dist) + 0.01 )) * dt)
	end
	self.lastTargetVel.x = relVelX
	self.lastTargetVel.y = relVelY
	-- self.penaltyMovement = math.max(0, math.min())
	-- self.critPenaltyMovement = math.max(0,math.min())

	self.accuracy = math.max(0, 1.0 - self.penaltyMovement - self.penaltyTarget - self.penaltyAim - self.penaltyReaction)
	self.criticalAccuracy = math.max(0, 1.0 - self.critPenaltyMovement - self.critPenaltyTarget - self.critPenaltyAim - self.critPenaltyReaction)
end

return ModTargetEqp