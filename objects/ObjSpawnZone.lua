local ObjBase = require "ObjBase"
local ObjSpawnZone = Class.create("ObjSpawnZone", ObjBase)
	
function ObjSpawnZone:create()
	local newZone = {x = self.x, y = self.y, width = self.width, height = self.height}
	table.insert(Game.worldManager.spawnZones[Game.worldManager.currentRoom],newZone)
end

function ObjSpawnZone:tick( dt )
	Game:del(self)
end

return ObjSpawnZone