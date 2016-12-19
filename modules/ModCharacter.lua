local ModCharacter = Class.create("ModCharacter", Entity)

ModCharacter.dependencies = {"ModDialog","ModInteractor","ModPhysicsTD","ModActive"}

function ModCharacter:create()
	Game.worldManager:addCharacter(self,self.room or Game.roomname)
	self.noTeleportTime = 0
	self.events = {}
end

function ModCharacter:setNoTeleportTime( time )
	self.noTeleportTime = time
end
function ModCharacter:offScreenTick( dt )
	if self.roomPaths then
		self.moving = true
	end
end

function ModCharacter:onExitScreen()
	lume.trace()
	if self.finalDestination then
		local timeOffset = 0
		local futPos = {x=self.x,y=self.y}
		local futRoom = self.currentRoom
		if #self.roomPaths > 0 then
			for i,v in ipairs(self.roomPaths) do
				local dist = xl.distance(futPos.x,futPos.y,v.pos.x,v.pos.y)
				timeOffset = timeOffset + ((dist * 2)/self.maxSpeedX)
				futPos = v.nextPos
				futRoom = v.nextRoom
				self:addPositionEvent(timeOffset,futPos,futRoom)
			end
		end
		local dist = xl.distance(futPos.x,futPos.y,self.finalDestination.x,self.finalDestination.y)
		futPos = {x=self.finalDestination.x,y=self.finalDestination.y}
		lume.trace(self.maxSpeedX)
		timeOffset = timeOffset + ((dist * 2)/self.maxSpeedX)
		self:addPositionEvent(timeOffset,futPos,futRoom)
	end
end

function ModCharacter:onReturnScreen()
	-- body
end
function ModCharacter:addPositionEvent( timeOffset,position ,room)
	lume.trace(timeOffset)
	room = room or self.currentRoom
	local function posUpdate()
		lume.trace(position)
		lume.trace(position.x,position.y)
		lume.trace(self.x,self.y)
		self.x = position.x
		self.y = position.y
		if room ~= self.currentRoom then
			Game.worldManager:moveCharacter(self,room)
		end
	end
	self:addEvent(timeOffset,posUpdate,true)
end

function ModCharacter:addEvent( time,events,relative )
	local timeKey = Game.worldManager:addEvent( time, events, relative )
	self.events[timeKey] = events
end

function ModCharacter:cancelFutureEvents()
	local cT = Game.worldManager.totalTime
	for k,v in pairs(self.events) do
		if k < cT then
			v[k] = nil
		end
	end
end

function ModCharacter:getTimeInRoom()
	return Game.worldManager.totalTime - self.timeStartedInRoom
end

return ModCharacter