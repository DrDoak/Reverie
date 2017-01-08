local ModOffscreen = Class.create("ModOffscreen", Entity)

ModOffscreen.dependencies = {"ModActive", "ModPhysics"}

function ModOffscreen:create()
	Game.worldManager:addCharacter(self,self.room or Game.roomname)
	self.noTeleportTime = 0
	self.events = self.events or {}
end

function ModOffscreen:setNoTeleportTime( time )
	self.noTeleportTime = time
end

function ModOffscreen:offScreenTick( dt ) end

function ModOffscreen:onExitScreen()
	--lume.trace()
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
		timeOffset = timeOffset + ((dist * 2)/self.maxSpeedX)
		self:addPositionEvent(timeOffset,futPos,futRoom)
	end
end

function ModOffscreen:onReturnScreen() end

function ModOffscreen:addPositionEvent( timeOffset,position ,room)
	room = room or self.currentRoom
	local function posUpdate()
		self.x = position.x
		self.y = position.y
		if room ~= self.currentRoom then
			Game.worldManager:moveCharacter(self,room)
		end
	end
	self:addEvent(timeOffset,posUpdate,true)
end

function ModOffscreen:addEvent( time,events,relative )
	local timeKey = Game.worldManager:addEvent( time, events, relative )
	self.events[timeKey] = events
end

function ModOffscreen:cancelFutureEvents()
	local cT = Game.worldManager.totalTime
	for k,v in pairs(self.events) do
		if k < cT then
			v[k] = nil
		end
	end
end

function ModOffscreen:getTimeInRoom()
	return Game.worldManager.totalTime - self.timeStartedInRoom
end

return ModOffscreen