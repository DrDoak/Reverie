-- local ObjcharacterReference = require "objects.ObjcharacterReference"
-- local Objcharacter = require "objects.Objcharacter"
local ObjWorldManager = Class.create("ObjWorldManager", Entity)
local STI    = require "libs.sti"

function ObjWorldManager:create()
	Game.worldManager = self
	self.roomNodes = {}
	self.characters = {}
	self.timeEvents = {}
	self.totalTime = 0
	self.timeInRoom = 0
	self.worldMapCreated = false
	self.roomObjects = {}
	self.map = self.map or {}
	self.spawnZones = {}
	-- local permanentObjects = require("")
	-- for i,v in ipairs(permanentObjects) do
	-- 	print(i,v)
	-- end
end

function ObjWorldManager:onRoomLoad( roomName, prevRoomName )
	-- lume.trace(self.worldMapCreated)
	self.timeInRoom = 0
	self.currentRoom = roomName
	self.spawnZones[roomName] = {}
	if not self.worldMapCreated then
		self:createWorldMap(roomName)
	end
	for i,v in ipairs(self.characters) do
		if v.currentRoom ~= roomName then
			v.offScreen = true
		else
			v.offScreen = false
		end
	end
end

function ObjWorldManager:roombegin()
	self:recreateAllChars()
end

function ObjWorldManager:recreateAllChars()
	-- lume.trace(self.currentRoom)
	if self.roomObjects[self.currentRoom] then
		for _,object in ipairs(self.roomObjects[self.currentRoom]) do
			self:recreateCharacter(object)
		end
	end
end

function ObjWorldManager:recreateCharacter( character )
	if not Game.entities[character] and not character:hasModule("ModControllable") then
		local class = require("objects." .. character.type)
		local inst = class()
		inst.name, inst.x, inst.y = character.name, character.x, character.y
		inst.width, inst.height = 0,0
		inst.offScreen = false
		if inst.moving and self.spawnZones then
		end
		Game:add(inst)
		inst:onReturnScreen()
		util.deleteFromTable(self.roomObjects[self.currentRoom], character)
		table.insert(self.roomObjects[self.currentRoom],inst)
	end
end

function ObjWorldManager:nearestSpawnPoint( character,room )
	-- body
end

function ObjWorldManager:createWorldMap( startingRoom )
	self.map = {}
	self.worldMapCreated = true
	self:processRoom(startingRoom)
end

function ObjWorldManager:processRoom( roomName )
	if not self.map[roomName] then
		local roomInfo = {}
		roomInfo.connectedRooms = {}
		roomInfo.exits = {}
		local newMap = STI.new(roomName)
		self.map[roomName] = roomInfo

		for _,layer in ipairs(newMap.layers) do
			if layer.type == "objectgroup" then
				for _,object in pairs(layer.objects) do
					if object.type == "ObjRoomChanger" then
						local props = object.properties
						local newExit = {}
						newExit.pos = {x=object.x,y=object.y}
						local newRoomName = "assets/rooms/".. props.nextRoom .. (props.nextZone or "")
						roomInfo.connectedRooms[newRoomName] = true

						local exName = "R:"..newRoomName.."X:"..newExit.pos.x.."Y:"..newExit.pos.y
						if not self.map[newRoomName] then 
							self:processRoom(newRoomName) 
						end
						newExit.nextRoom = newRoomName
						newExit.nextPos = {x=props.nextX * 32 + 16,y=props.nextY * 32} 

						newExit.intConns = {}
						for k,v in pairs(roomInfo.exits) do
							local otherRoom = v.nextRoom
							if otherRoom ~= newRoomName and v.zone == newExit.zone then
								if not v.intConns[newRoomName] then 
									v.intConns[newRoomName] = {} 
									v.intConns[newRoomName].dist = 999999
								end
								if not newExit.intConns[otherRoom] then 
									newExit.intConns[otherRoom] = {} 
									newExit.intConns[otherRoom].dist = 999999
								end
								local dist = xl.distance(newExit.pos.x,newExit.pos.y,exit.pos.x,exit.pos.y)
								if dist < v.intConns[newRoomName].dist then
									v.intConns[newRoomName].dist = dist
									v.intConns[newRoomName].exit = exName
								end
								if dist < nextRoom.intConns[otherRoom].dist then
									newExit.intConns[otherRoom].dist = dist
									newExit.intConns[otherRoom].exit = k
								end
							end
						end
						roomInfo.exits[exName] = newExit
					end
				end
			end
		end
	end
end
	
function ObjWorldManager:pathToPoint( startingRoom, startPos, goalRoom )
	lume.trace("initializing A star Room search")
	goalRoom = "assets/rooms/"..goalRoom
	lume.trace(goalRoom)

    -- The set of nodes already evaluated.
    local closedSet = {}
    local openSet = {}

    local cameFrom = {}

    local start = {}
    start = self:nearest(self.map[startingRoom].exits,{x=startPos.x,y=startPos.y})
    start.room = startingRoom
    start.gScore = 0
    start.fScore = self:heuristicAstar(startingRoom,goalRoom)
    start.cameFrom = nil
    table.insert(openSet,start)

    local newIteration = 0
    while (table.getn(openSet) > 0) do
    	local minI = 0
    	local minVal = 999999
    	for i,v in ipairs(openSet) do
    		local newScore = v.fScore 
    		if newScore < minVal then
    			minI = i
    			minVal = newScore
    		end
    	end
    	local current = openSet[minI]

    	if current.nextRoom == goalRoom then
    		return xl.reconstructPath(current)
    	end

        table.remove(openSet,minI)
        table.insert(closedSet,current)

        local neighbors = self:getNeighbors(current)
        for i,room in ipairs(neighbors) do
            if not self:hasRoom(closedSet,room) then
	            local tentative_gScore = current.gScore + room.dist 
	            if not self:hasRoom(openSet,room) then 
	                table.insert(openSet, room)

	                v.cameFrom = current
	                local newValue = {}
	                v.gScore = tentative_gScore
	                v.fScore = v.gScore + self:heuristicAstar(startingRoom, goalRoom)
	            end
	        end           
        end
        newIteration = newIteration + 1
        if newIteration > 500 then
        	lume.trace()
        	break
        end
    end
    return false
end

function ObjWorldManager:nearest( set, point )
	local curNearest = nil
	local curMinDist = 999999
	for k,v in pairs(set) do
		if xl.distance(point.x,point.y,v.pos.x,v.pos.y) < curMinDist then
			curMinDist = xl.distance(point.x,point.y,v.pos.x,v.pos.y)
			curNearest = v 
		end
	end
	return curNearest
end

function ObjWorldManager:getNeighbors( curExit )
	--local curExit = self:nearest(curRoom.exits,position)
	local neighbors = {}
	local nextExit = self.nearest(self.map[curExit.nextRoom],curExit.nextPos)
	nextExit.dist = 0
	table.insert(neighbors,nextExit)
	--lume.trace(#curExit.intConns)
	for k,v in pairs(curExit.intConns) do
		lume.trace(k)
		local newRoom = v --{room=k, dist=curRoom.intConns[k].dist, exit=curRoom.intConns[k].exit}
		newRoom.room = k
		table.insert(neighbors,newRoom)
	end
	return neighbors
end

function ObjWorldManager:hasRoom( set, node )
	for i,v in ipairs(set) do
		if v.room == node.room and node.pos.x == v.pos.x and node.pos.x == v.pos.x then
			return true
		end
	end
	return false
end

function ObjWorldManager:heuristicAstar( startNode,endNode )
	return 1
end

function ObjWorldManager:addCharacter( character , roomName)
	character.currentRoom = roomName or Game.roomName
	character.timeStartedInRoom = self.totalTime
	if roomName ~= self.currentRoom then
		self.offScreen = true
	else
		self.offScreen = false
	end

	self.characters[character.name] = character
	if not self.roomObjects[roomName]  then self.roomObjects[roomName]  = {} end
	table.insert(self.roomObjects[roomName], character)
end

function ObjWorldManager:moveCharacter( character, newRoom )
	for k,v in pairs(self.roomObjects) do
		print(k,v)
	end
	character:respondToEvent("roomChange",{room=newRoom})
	if self.roomObjects[character.currentRoom] then
		util.deleteFromTable(self.roomObjects[character.currentRoom],character)
	end
	if character.currentRoom == self.currentRoom and character ~= Game.player then
		self.offScreen = true
		Game:del(character)
		character.currentRoom = newRoom
		character:onExitScreen()
	end
	character.currentRoom = newRoom
	if character.currentRoom == self.currentRoom then
		self:recreateCharacter(character)
	end
	character.timeStartedInRoom = self.totalTime
	if not self.roomObjects[newRoom] then 
		self.roomObjects[newRoom] = {} 
	end
	table.insert(self.roomObjects[newRoom],character)
end


function ObjWorldManager:tick( dt )
	self.timeInRoom = self.timeInRoom + dt
	self.totalTime = self.totalTime + dt

	for k,v in pairs(self.characters) do
		if v.offScreen == true then
			v:offScreenTick(dt)
		end
	end
	local timeKey = "T:"..math.floor(self.totalTime)
	if self.timeEvents[timeKey] then
		for i,v in ipairs(self.timeEvents[timeKey]) do
			v()
		end
		self.timeEvents[timeKey] = nil
	end
end

function ObjWorldManager:getTime()
	return self.totalTime
end
function ObjWorldManager:addEvent( time, events, relative )
	local eventTime = math.floor(time)
	if relative then eventTime = math.floor(self.totalTime) + eventTime end
	local timeKey = "T:"..eventTime
	self.timeEvents[timeKey] = self.timeEvents[timeKey] or {}
	if type(events) == "function" then 
		table.insert(self.timeEvents[timeKey],events)
	else
		for i,v in ipairs(events) do
			table.insert(self.timeEvents[timeKey],v)
		end
	end
	return timeKey
end

function ObjWorldManager:cancelEvent( timeKey,events )
	local eventTime = self.timeEvents[timeKey]
	if not eventTime then
	else
		if type(events) == "function" then 
			util.deleteFromTable(eventTime,events)
		else
			for i,v in ipairs(events) do
				util.deleteFromTable(eventTime,v)
			end
		end
	end
end

function ObjWorldManager:getCharacters()
	local entities = Game:findObjects()
end
return ObjWorldManager