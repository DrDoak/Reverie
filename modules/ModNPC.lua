local ModNPC = Class.create("ModNPC", Entity)

ModNPC.dependencies = {"ModDialog","ModInteractor"}

function ModNPC:create()
	Game.worldManager:addCharacter(self,self.room or Game.roomname)
	self.noTeleportTime = 0
end

function ModNPC:setNoTeleportTime( time )
	self.noTeleportTime = time
end
function ModNPC:offScreen( dt )
	-- body
end

function ModNPC:getTimeInRoom()
	return Game.worldManager.totalTime - self.timeStartedInRoom
end

return ModNPC