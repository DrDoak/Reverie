local FXReticle = require("objects.FXReticle")
local ModCharacter = Class.create("ModCharacter", Entity)
ModCharacter.dependencies = {"ModDialog","ModInteractor","ModPhysics","ModActive","ModOffscreen","ModDrawable"}

function ModCharacter:create()
	self.noTeleportTime = 0
	self.viewDist = 240
	self.lockOnSlow = -0.4


	self.allTagIdentifiers = self.allTagIdentifiers or {} -- Identify Events
	self.allTagResponses = self.allTagResponses or {} -- Propose Responses to Events
	self.allTagScores = self.allTagScores or {} -- Evaluate those Responses

	self.topics = self.topics or {} --Topics that can be dynamically added.

	self.allAI = {} --Basic AI pieces that cannot be dynamically added.

	self:addAIPiece(require("ai.AIHumanRecognition"))
	self:addAIPiece(require("ai.AIBasicSpeech"))
	self:addAIPiece(require("ai.AIQuestionAnswer"))
	
	self:addAIPiece(require("assets.ai.AIWeapons"))

end

--=========================Core Functions==============================---
function ModCharacter:respondToEvent( eventName, params )
	-- lume.trace("Responding to Event", eventName)
	local tags = self:identifyAllTags(eventName, params)
	self:performResponse(eventName, tags, params)
end

------ Tagging: Processing the information, and identifying it ------

function ModCharacter:identifyAllTags( eventName, params )
	local newTags = {}
	for i, taggingPiece in pairs(self.allTagIdentifiers) do
		local tags = taggingPiece.identifyTags(self,eventName, newTags, params)
		for k,v in pairs(tags) do
			if not newTags[k] then newTags[k] =0 end
			newTags[k] = newTags[k] + v
		end
	end
	return newTags
end

function ModCharacter:checkIfNeedNewTag(tagName,aipiece)
	if self.allTagResponses[tagName] == nil then 
		self.allTagResponses[tagName] = {} 
	end
	if aipiece and not self.allTagResponses[tagName][aipiece] then
		self.allTagResponses[tagName][aipiece] = {}
	end
end

function ModCharacter:checkIfNeedNewScorer( tagName, aipiece )
	if self.allTagScores[tagName] == nil then 
		self.allTagScores[tagName] = {} 
	end
	if aipiece and not self.allTagScores[tagName][aipiece] then
		self.allTagScores[tagName][aipiece] = {}
	end
end

------ Responding to the Information after it has been tagged ------
function ModCharacter:performResponse( eventName, eventTags, params )
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
	self:executeProposedActions()
end

function ModCharacter:proposeAction( actionFunction, actionParams, actionName,category)
	category = category or "general"
	local allTags = self:identifyAllTags(actionName, actionParams)
	local score = 1
	for tagName,tagValue in pairs(allTags) do
		self:checkIfNeedNewScorer(tagName)
		for topic,allFunctions in pairs(self.allTagScores[tagName]) do
			for i,scorer in ipairs(allFunctions) do
				score = scorer.action(self,actionName,tagName,tagValue,allTags, topic,score,scorer.weight)
			end
		end
	end
	if score > 0 then
		local newAction = {}
		newAction.action = actionFunction
		newAction.category = category
		newAction.params = actionParams
		newAction.score = score
		table.insert(self.proposedActions,newAction)
	end
end

function ModCharacter:executeProposedActions()
	if self:hasModule("ModControllable") then
		return
	end
	local actionsToExecute = {}
	for i,v in ipairs(self.proposedActions) do
		local cat = v.category
		if not actionsToExecute[cat] then
			actionsToExecute[cat] = {}
			actionsToExecute[cat].action = v.action
			actionsToExecute[cat].score = v.score
			actionsToExecute[cat].params = v.params
		elseif v.score > actionsToExecute[cat].score then
			actionsToExecute[cat].action = v.action
			actionsToExecute[cat].score = v.score
			actionsToExecute[cat].params = v.params
		end
	end
	for k,v in pairs(actionsToExecute) do
		v.action(self,v.score,v.params)
	end
end
-- Adds an Piece of AI to the character. Can also be a topic. ----

function ModCharacter:addAIPiece( aipiece )
	local pieceName = aipiece.name or aipiece.type or "incomprehensible"
	if self:knowsTopic(pieceName) then wrhiewohr() end

	local newTopic = {}
	newTopic.name = pieceName
	newTopic.confidence = aipiece.baseConfidence or 50
	newTopic.acceptance = aipiece.baseAcceptance or 0
	newTopic.relevance = aipiece.baseRelevance or 50
	if aipiece.extraInfo then
		for k,v in pairs(aipiece.extraInfo) do
			newTopic[k] = v
		end
	end
	newTopic.weight = aipiece.weight or (newTopic.confidence * 2 + newTopic.relevance)
	newTopic.identifyTags = aipiece.identifyTags
	if newTopic.identifyTags then
		local inserted = false
		for i,v in ipairs(self.allTagIdentifiers) do
			if v.weight < newTopic.weight then
				table.insert(self.allTagIdentifiers,i,newTopic)
				inserted = true
				break
			end
		end
		if not inserted then table.insert(self.allTagIdentifiers,newTopic) end
	end
	
	if aipiece.tagResponses then
		for i,v in ipairs(aipiece.tagResponses) do
			self:setRunOnTag(v[1],v[2],newTopic)
		end
	end

	if aipiece.tagScores then
		for i,v in ipairs(aipiece.tagScores) do
			self:setScoreOnTag(v[1],v[2],newTopic,v[3])
		end
	end
	-- if aipiece.isModule then
	-- 	newTopic.module = aipiece
		self:addModule(aipiece)
	-- end
	if aipiece.isTopic then -- "Topics" are just AI Pieces that users are able to see and can be freely learned and shared --
		-- local newTopic = {}
		newTopic.text = aipiece.text or pieceName
		newTopic.timeAdded = Game.worldManager.totalTime
		if aipiece.parentTopic then
			local pName = aipiece.parentTopic
			newTopic.parentTopic = pName

			if not self.topics[aipiece.parentTopic] then
				--lume.trace("Parent Topic does not exist, creating new parent", pName,"for",pieceName)
				local newAIPiece = Class.create(pName, Entity)
				newAIPiece.baseConfidence = 100
				newAIPiece.baseRelevance = 30
				newAIPiece.name = pName
				newAIPiece.isTopic = true
				self:addAIPiece(newAIPiece)
			end
			self.topics[aipiece.parentTopic].subTopics[pieceName] = newTopic
		else
			newTopic.subTopics = {}
			-- newTopic.response = newTopic.subTopics
			self.topics[pieceName] = newTopic
		end
	end
	self.allAI[pieceName] = newTopic
	return newTopic
end

function ModCharacter:respondToDialog(topic)
	for i,otherPlayer in ipairs(self.audience) do
		otherPlayer:respondToEvent(self.dialogType, {topic = topic, other=self})
	end
end

--- Sets the function to run when the given tags are called
function ModCharacter:setRunOnTag( actionFunct, tags , topic)
	if type(tags) == "table" then
		for i,tagName in ipairs(tags) do
			self:checkIfNeedNewTag(tagName,topic)
			table.insert(self.allTagResponses[tagName][topic],actionFunct)
		end
	else
		-- lume.trace(topic.name, actionFunct,tags)
		self:checkIfNeedNewTag(tags,topic)
		table.insert(self.allTagResponses[tags][topic],actionFunct)
	end
end

function ModCharacter:setScoreOnTag( evalFunct, tags, topic ,weight)
	if type(tags) == "table" then
		for i,tagName in ipairs(tags) do
			self:checkIfNeedNewScorer(tagName,topic)
			self.allTagScores[tagName][topic] = {}
			self.allTagScores[tagName][topic].score = 	actionFunct
			self.allTagScores[tagName][topic].weight = 	weight or 1
		end
	else
		-- lume.trace(topic.name, actionFunct,tags)
		self:checkIfNeedNewScorer(tags,topic)
		self.allTagScores[tagName][topic] = {}
		self.allTagScores[tagName][topic].score = 	actionFunct
		self.allTagScores[tagName][topic].weight = 	weight or 1
	end
end

--- Topic Related ---
function ModCharacter:knowsTopic( topic )
	if topic.parentTopic then
		if self.topics[topic.parentTopic] and self.topics[topic.parentTopic][topic.name] then
			return true
		else
			return false
		end
	else
		if self.topics[topic.name] then
			return true
		else
			return false
		end
	end
end

-----------------------------------------

-- Initiating a conversation with another character
function ModCharacter:onInteractionWithObject( otherCharacter )
	if otherCharacter:hasModule("ModCharacter") then
		self:respondToEvent("initiateConversation",{other = otherCharacter})
	end
end

-- Responding to a conversation initiated by the other character
function ModCharacter:onPlayerInteract( otherCharacter )
	if otherCharacter:hasModule("ModCharacter") then
		self:respondToEvent("receivingConversation", {other=otherCharacter})
	end
end

function ModCharacter:evaluationAverage( tags ,evalTable)
	local total = 0
	for k,v in pairs(tags) do
		if not evalTable[k] then evalTable[k] = 0 end
		total = total + (evalTable[k] * v)
	end
	return total / #tags
end
--=============Planning and Execution functions=================-----

---===============Animation ============---
function ModCharacter:animate()
	if self.targetObj then
		self:strafeAnimation()
	else
		self:normalAnimation()
	end
end

function ModCharacter:setTarget( obj )
	if obj then
		-- lume.trace("slowing down", self.lockOnSlow)
		self.speedModX = self.speedModX + self.lockOnSlow
		self.speedModY = self.speedModY + self.lockOnSlow
		lume.trace(obj)
		local target = FXReticle(self,obj,self.reticleSprite)
		Game:add(target)
	else
		-- lume.trace("speeding up",self.lockOnSlow)
		self.speedModX = self.speedModX - self.lockOnSlow
		self.speedModY = self.speedModY - self.lockOnSlow
	end
	self.targetObj = obj
end

function ModCharacter:orientTorwardsTarget()
	if self.targetObj and not self.targetObj.destroyed then
		local diffX = self.targetObj.x - self.x
		local diffY = self.targetObj.y - self.y
		if math.abs(diffX) > math.abs(diffY) then
			if diffX > 0 then
				self.dir = 1
			else
				self.dir = -1
			end
		else
			if diffY > 0 then
				self.dir = 2
			else
				self.dir = 0
			end
		end
		if not self:testProximity(self.targetObj.x,self.targetObj.y,self.viewDist * 1.2) then
			self:setTarget(nil)
		end
	else
		self:setTarget(nil)
	end
end


function ModCharacter:strafeAnimation( )
	self:orientTorwardsTarget()
	local maxSpeed, maxSpeedY = self.maxSpeedX, self.maxSpeedY
	local walkanim = math.abs(4 / self.velX)
	local newVelX = self.velX - self.referenceVelX
	local newVelY = (self.velY - self.referenceVelY) * 1.4
	local newVel = math.sqrt(math.pow(newVelX,2) + math.pow(newVelY,2))

	if self.isMovingX or self.isMovingY then
		self.idleCounter = 0
		if (self.dir == 1 and newVelX < -16) or (self.dir == -1 and newVelX > 16) then
			self:changeAnimation("walk",-0.8)
		else
			if math.abs(newVel) >= maxSpeed - 52 then
				self:changeAnimation({"run","walk"})
			else
				self:changeAnimation("walk",0.8)
			end
		end
	else
		if math.abs(newVelX) <= 32 then
			self.idleCounter = self.idleCounter + 1
			if self.idleCounter >= 60 and self.idleCounter < 89 then
				self:changeAnimation({"idleStart","idle","stand"})
			elseif self.idleCounter > 84 then
				self:changeAnimation({"idle","stand"})
			else
				self:changeAnimation("stand")
			end
		else
			self:changeAnimation({"slide","stand"})
		end
	end
	if self.currentEquips["neutral"] and self.currentEquips["neutral"].lockOnAnim then
		-- util.shallow_print(self.currentEquips)
		-- lume.trace(self.currentEquips["neutral"].lockOnAnim)
		-- lume.trace()
		self:changeAnimation({ self.currentEquips["neutral"].lockOnAnim ,"aim_handgun","guard"})
	end
end

function ModCharacter:normalAnimation( )
	local maxSpeed, maxSpeedY = self.maxSpeedX, self.maxSpeedY
	local walkanim = math.abs(4 / self.velX)
	local newVelX = self.velX - self.referenceVelX
	local newVelY = (self.velY - self.referenceVelY) * 1.4
	local newVel = math.sqrt(math.pow(newVelX,2) + math.pow(newVelY,2))

	if self.isMovingX or self.isMovingY then
		self.idleCounter = 0
		if (self.dir == 1 and newVelX < -16) or (self.dir == -1 and newVelX > 16) then
			self:changeAnimation({"slideMore","slide","stand"})
		else
			if math.abs(newVel) >= maxSpeed - 52 then
				self:changeAnimation({"run","walk"})
			else
				self:changeAnimation("walk")
			end
		end
	else
		if math.abs(newVelX) <= 32 then
			self.idleCounter = self.idleCounter + 1
			if self.idleCounter >= 60 and self.idleCounter < 89 then
				self:changeAnimation({"idleStart","idle","stand"})
			elseif self.idleCounter > 84 then
				self:changeAnimation({"idle","stand"})
			else
				self:changeAnimation("stand")
			end
		else
			self:changeAnimation({"slide","stand"})
		end
	end
	if self.isHolding then
		self:changeAnimation({"holding","guard"})
	end
end

function ModCharacter:validTarget( obj )
	if obj ~= self and obj ~= self.targetObj and self:testProximity(obj.x,obj.y,self.viewDist) then
		return true
	end
	return false
end

return ModCharacter

-- function ModCharacter:setHitState(hitInfo)
-- 	self:respondToEvent("hit",{other = hitInfo.attacker, damage = hitInfo.damage, stun = hitInfo.stun , element = hitInfo.element })
-- end

-- function ModCharacter:onHitConfirm(target, hitType, hitbox)
-- 	-- body
-- end

-- function ModCharacter:onKill( target,hitType,hitbox )
-- 	-- body
-- end