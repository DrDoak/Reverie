local ModNPC = Class.create("ModNPC", Entity)

ModNPC.dependencies = {"ModDrawable","ModCharacter","ModPathFinder"}--,"ModCharacterDetector"}

function ModNPC:create()
	Game.worldManager:addCharacter(self,self.room or Game.roomname)
	self.noTeleportTime = 0
	self.queuedActions = {}
end

function ModNPC:setNoTeleportTime( time )
	self.noTeleportTime = time
end

function ModNPC:loadNPCScript( npcData )
	local npcData = require( "assets.npcs." .. npcData )
	if not self.npc or self.npc ~= npcData then
		self.npc = npcData.name
		self.name = npcData.name
		self.mass = npcData.mass or 25
		if npcData.spritePieces then
			for i,v in ipairs(npcData.spritePieces) do
				self:addSpritePiece(require(v))
			end
		end
		if npcData.knowledge then
			for i,v in ipairs(npcData.knowledge) do
				self:addAIPiece(require(v))
			end
		end
	end
end

function ModNPC:tick( dt )
	if #self.queuedActions > 0 and self.state ~= 4 then
		-- lume.trace(#self.queuedActions)
		local nextAction = self.queuedActions[1]
		table.remove(self.queuedActions,1)
		if nextAction.preperation then
			nextAction.preperation(self)
		end
		self:setSpecialState(nextAction.action)
	end
end
function ModNPC:setActionList( actionList )
	self.queuedActions = {}
	for i,v in ipairs(actionList) do
		local nextAction = v.action
		local prep = v.preperation
		prep(self)
		table.insert(self.queuedActions,nextAction)
	end
end
function ModNPC:clearQueue()
	self.queuedActions = {}
end

function ModNPC:queueAction( actionFunction,preperationFunction )
	local nextAction = {}
	nextAction.action = actionFunction
	nextAction.preperation = preperationFunction
	table.insert(self.queuedActions,nextAction)
end

------------Shortcut Actions to Queue--------------

function ModNPC:approachCharacter( character )
	self.followCharacter = character
	local function specialFunct( player, count )
		self:setGoal({x=self.followCharacter.x, y=self.followCharacter.y},self.followCharacter.currentRoom)
		if player:moveToGoal() then
			lume.trace()
			player.exit = true
		end
		player:animate()
	end
	self:queueAction(specialFunct)

end

function ModNPC:talkToCharacter( character, text )
	self:createIntHitbox()
end

function ModNPC:getProposedActions()
	return self.proposedActions
end

return ModNPC