local ModPathFinder = Class.create("ModPathFinder", Entity)
ModPathFinder.dependencies = {"ModActive","ModPhysics"}

function ModPathFinder:create()
	self.wrapCheckFree = lume.fn(ModPathFinder.mCheckFree, self)
	self.currDest = {x = 0, y = 0}
	self.nodeList = {}
	self.currTarget = {x=0,y=0}
	self.nodeThreashold = 8 --self.width/2
	self.threasholdFromGoal = self.threasholdFromGoal or 16
	self.lastPos = {x = self.x, y = self.y}
	self.goalPosition = {}
	self.roomPaths = {}
end

function ModPathFinder:setGoal(goalPosition, roomName )
	self.finalDestination = goalPosition
	if not roomName or (roomName == self.currentRoom) then
		self.goalPosition = goalPosition
	else
		self.roomPaths = Game.worldManager:pathToPoint(self.currentRoom, {x=self.x,y=self.y}, roomName)
		local curPath = self.roomPaths[1]
		self.goalPosition = curPath.pos
		util.print_table(self.goalPosition)
		lume.trace(self.x,self.y)
		table.remove(self.roomPaths,1)
	end
end

function ModPathFinder:moveToGoal()
	-- self:moveToPoint(self.goalPosition.x,self.goalPosition.y,self.nodeThreashold)
	-- lume.trace(self.goalPosition.x,self.goalPosition.y, self.x,self.y)
	if self.goalPosition then
		if not self.finalDestination and self:testProximity(self.goalPosition.x,self.goalPosition.y,self.threasholdFromGoal) then
			self.goalPosition = nil
			return true
		end
		if self:moveToPoint(self.goalPosition.x,self.goalPosition.y,self.nodeThreashold) then
			self.goalPosition = nil
			if #self.roomPaths > 0 then
				self.goalPosition = self.roomPaths[1].pos
				table.remove(self.roomPaths,1)
			elseif self.finalDestination then
				self.goalPosition = self.finalDestination
				self.finalDestination = nil
			else
				lume.trace()
			end
		end
		return false
	else
		lume.trace()
		return true
	end
end

function ModPathFinder:moveToPoint( destinationX,destinationY ,proximity)
	self.numCasts = 0

	if self:testProximity(destinationX,destinationY,proximity) then
		return true
	end 
	-- lume.trace(destinationX,destinationY,proximity)
	if self:checkClear(self.x,self.y,destinationX,destinationY,16) then--proximity) then
		self.nodeList = {}
		self:directToPoint(destinationX,destinationY,proximity)
	else
		if xl.distance(destinationX,destinationY,self.currDest.x ,self.currDest.y) > 4 then
			self.currDest.x = destinationX
			self.currDest.y = destinationY
			self:planPath(destinationX,destinationY,proximity)
		end
		if self.currTarget then
			local i = #self.nodeList
			local found = false
			while (i > 1) do 
				if not found and self:checkClear(self.x,self.y,self.nodeList[i].x,self.nodeList[i].y,4) then
					-- self:directToPoint(self.currTarget.x,self.currTarget.y,proximity)
					self.currTarget = self.nodeList[i]
					found = true
					--lume.trace("hohoionfeowiohioh")
				elseif found then
					table.remove(self.nodeList,1)
				end
				i = i - 1
			end
			self:directToPoint(self.currTarget.x,self.currTarget.y,proximity)
			if self:testProximity(self.currTarget.x,self.currTarget.y,self.nodeThreashold) then
				self:nextNode()
			end
			if Game:getTicks()% 90 == 0 then
				if self:testProximity(self.x,self.y,self.lastPos.x,self.lastPos.y,2) then
					--lume.trace("Hoooooo")
					self:planPath(destinationX,destinationY,proximity)
				end
				self.lastPos = {x = self.x,y = self.y}
			end
		else
			self:planPath(destinationX,destinationY,proximity)
		end
	end
	xl.DScreen.print("numCasts: ", "(%f)",self.numCasts)
	return false
end
function ModPathFinder:nextNode()
	table.remove(self.nodeList,1)
	if #self.nodeList > 0 then
		self.currTarget = self.nodeList[1]
	else
		self.currTarget = nil
	end
end

function ModPathFinder:planPath(dX,dY,prox)
	local foundPath = false
	local i = 1
	while (i <= #self.nodeList) do 
		local v = self.nodeList[i]
		if self:checkClear(v.x,v.y,dX,dY,prox) then
			foundPath = true
			i = i + 1
		end
		if foundPath then
			table.remove(self.nodeList,i)
		else
			i = i + 1
		end
	end
	if foundPath then
		return
	end
	local start = {x=self.x,y=self.y}
	local goal = {x=dX ,y=dY }

	self:newPath(start,goal,prox)
	if #self.nodeList > 0 then
		self.currTarget = {}
		self.currTarget.x = self.nodeList[1].x
		self.currTarget.y = self.nodeList[1].y
	else
		self.currTarget = nil
	end
end

function ModPathFinder:getNeighbors( current, goal, proximity)
	local newNeighbors = {}
	-- lume.trace("CurrentPOs:")
	-- util.print_table(current)
	-- lume.trace("GoalPos: ")
	-- util.print_table(goal)

	self:checkClear(current.x,current.y,goal.x,goal.y,proximity)
	local minDist = 9999999
	local minPoint = nil
	for i,v in ipairs(self.scanContacts) do
		local vDist = v.distance
		if vDist < minDist and vDist > 2 then
			minDist = v.distance
			minPoint = v
		end
	end
	if minPoint then
		-- lume.trace("advancingPos: ")
		if minPoint.x > current.x then
			minPoint.x = minPoint.x - 4
		elseif minPoint.x < current.x then
			minPoint.x = minPoint.x + 4
		end
		if minPoint.y > current.y then
			minPoint.y = minPoint.y - 4
		elseif minPoint.y < current.y then
			minPoint.y = minPoint.y + 4
		end
		--util.print_table(minPoint)
		table.insert(newNeighbors,minPoint)
	end
	if current.fixture then
		local shape = current.fixture:getShape()
		local sType = shape:getType()
		--lume.trace(sType)
		if sType == "circle" then
			local point = shape:getPoint()
			local radius = shape:getRadius()
		elseif sType == "polygon" then
			local points = util.pack(shape:getPoints())
			local offX,offY = current.fixture:getBody():getPosition()
			--lume.trace(offX,offY)
			local i = 1
			while (i < #points) do
				local testX, testY
				testX = points[i] + offX
				testY = points[i+1] + offY
				if xl.distance(current.x,current.y,testX,testY) > 3 then
					if testX > current.x then
						testX = testX - 3
					elseif testX < current.x then
						testX = testX + 3
					end
					if testY > current.y then
						testY = testY - 3
					elseif testY < current.y then
						testY = testY + 3
					end
					--lume.trace("testX",testX,"testY",testY)
					if self:checkClear(current.x,current.y,testX,testY,proximity) then
						local newPos = {}
						newPos.x = testX
						newPos.y = testY
						table.insert(newNeighbors,newPos)
					end
				end
				i = i + 2
			end
		elseif sType == "chain" then
			local points = util.pack(shape:getPoints())

			self:getChainNeighbors(newNeighbors,current,points,proximity)
		end
	end
	--util.print_table(newNeighbors)
	return newNeighbors
end

function ModPathFinder:getChainNeighbors( neighborsTable, current,points,prox)
	-- lume.trace("Wall Coordinates: ")
	-- util.print_table(points)
	local i = 1
	local prevPoint = nil
	local currPoint = {}
	local nextPoint = nil
	local currentDirection
	while (i < #points) do
		currPoint.x = points[i]
		currPoint.y = points[i+1]
		nextPoint = nil
		local testX, testY
		local xDiff = points[i] - current.x
		local yDiff = points[i+1] - current.y
		if xDiff > 0 then
			testX = points[i] - 2
			currentDirection = "left"
		elseif xDiff < 0 then
			testX = points[i] + 2
			currentDirection = "right"
		end
		if yDiff > 0 then
			testY = points[i+1] - 2
			currentDirection = "up"
		elseif yDiff < 0 then
			testY = points[i+1] + 2
			currentDirection = "down"
		end
		-- lume.trace("testX",testX,"testY",testY)
		if self:checkClear(current.x,current.y,testX,testY,prox) then
			if i + 2 <= #points then
				nextPoint = {}
				nextPoint.x = points[i+2]
				nextPoint.y = points[i+3]
			end
			-- lume.trace("Before: " , testX,testY)
			if not prevPoint then
				-- lume.trace()
				xDiff = nextPoint.x - testX
				yDiff = nextPoint.y - testY
				if math.abs(xDiff) > math.abs(yDiff) and self:checkClear(current.x,current.y,testX + util.sign(xDiff) * 16,testY) then
					testX = testX + util.sign(xDiff) * 16
				elseif math.abs(yDiff) > math.abs(xDiff) and self:checkClear(current.x,current.y,testX,testY + util.sign(yDiff) * 16) then
					testY = testY - util.sign(yDiff) * 16
				end
			-- elseif not nextPoint then
			-- 	xDiff = prevPoint.x - testX
			-- 	yDiff = prevPoint.y - testY
			-- 	if math.abs(xDiff) > math.abs(yDiff) and self:checkClear(current.x,current.y,testX + util.sign(xDiff) * 16,testY) then
			-- 		testX = testX + util.sign(xDiff) * 16
			-- 	elseif math.abs(yDiff) > math.abs(xDiff) and self:checkClear(current.x,current.y,testX,testY + util.sign(yDiff) * 16) then
			-- 		testY = testY - util.sign(yDiff) * 16
			-- 	end
			elseif prevPoint then
				xDiff = prevPoint.x - testX
				yDiff = prevPoint.y - testY
				local xPro = math.abs(xDiff) / (math.abs(xDiff) + math.abs(yDiff))
				local yPro = math.abs(yDiff) / (math.abs(xDiff) + math.abs(yDiff))
				if self:checkClear(current.x,current.y,testX + xPro * util.sign(xDiff) * 16,testY+ yPro * util.sign(yDiff) * 16) then
					testX = testX + xPro * util.sign(xDiff) * 16
					testY = testY + yPro * util.sign(yDiff) * 16
				end
			end
			-- lume.trace("After: " , testX,testY)
			-- lume.trace("inserting point")
			local newPos = {x=testX,y=testY}
			table.insert(neighborsTable,newPos)
		end
		prevPoint = {x= points[i],y=points[i+1]}
		i = i + 2
	end
end

function ModPathFinder:newPath(start,goal,prox, goCloseAsPossibleIfNoPath) --start, goal,map,width,height,noList,pathType)
	-- lume.trace("initializing A star search")
	prox = prox or 4
	-- local start = {x=self.x,y=self.y}
    -- The set of nodes already evaluated.
    local closedSet = {}
    local openSet = {}
    local closestNode = {}
    local closestToGoalDist = 99999
    table.insert(openSet,start)

    local cameFrom = {}
    start.gScore = 0
    start.fScore = xl.distance(start.x,start.y,goal.x,goal.y)
    start.cameFrom = nil
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
    	local distToGoal = xl.distance(current.x,current.y,goal.x,goal.y)
        if distToGoal < prox * 2 then
        	-- lume.trace()
        	self.nodeList = xl.reconstructPath(current)
            return self.nodeList
        elseif distToGoal < closestToGoalDist then
        	closestToGoalDist = distToGoal
        	closestNode = current
        end

        table.remove(openSet,minI)
        table.insert(closedSet,current)
        local neighbors = self:getNeighbors(current,goal,prox)
        for i,v in ipairs(neighbors) do
            if not self:hasCoordinate(closedSet,v,prox) then
	            --The distance from start to a neighbor
	            local tentative_gScore = current.gScore + xl.distance(current.x,current.y, v.x,v.y)
	            if not self:hasCoordinate(openSet,v,prox)	then -- Discover a new node
	                table.insert(openSet, v)
	                -- This path is the best until now. Record it!
	                v.cameFrom = current
	                local newValue = {}
	                v.gScore = tentative_gScore
	                v.fScore = v.gScore + xl.distance(v.x,v.y,goal.x,goal.y)
	            --elseif tentative_gScore >= gScore[v.x][v.y] then
	            end
	        end           
        end
        newIteration = newIteration + 1
        if newIteration > 500 then
        	lume.trace()
        	break
        end
    end
    if goCloseAsPossibleIfNoPath then
    	lume.trace("no path, going the closest possible")
    	self.nodeList = xl.reconstructPath(closestNode)
        return self.nodeList
    end
    return false
end

function ModPathFinder:hasCoordinate( list,point,prox )
	for i,v in ipairs(list) do
		if xl.distance(v.x,v.y,point.x,point.y) < prox then
			return true
		end
	end
	return false
end

function ModPathFinder:directToPoint(destinationX, destinationY, proximity)
	local velX, velY = self.body:getLinearVelocity()
	if proximity ~= nil and self:testProximity(destinationX,destinationY,proximity) then
		return false
	else
		if self.y - destinationY > 2 then -- must move up
			self.dir = 0
			if velY < (self.maxSpeedY * self.speedModY) then
				self.forceY = -self.acceleration  * self.body:getMass()
			end
			self.isMovingY = true
		elseif self.y - destinationY < -2 then -- must move down
			self.dir = 2
			if velY > -(self.maxSpeedY * self.speedModY) then
				self.forceY = self.acceleration  * self.body:getMass()
			end
			self.isMovingY = true
		end
		if self.x - destinationX < - 2 then
			self.dir = 1
			if velX < (self.maxSpeedX * self.speedModX) then
				self.forceX = self.acceleration  * self.body:getMass()
			end
			self.isMovingX = true
		elseif self.x - destinationX > 2 then
			self.dir = -1
			if velX > -(self.maxSpeedX * self.speedModX) then
				self.forceX = -self.acceleration  * self.body:getMass()
			end
			self.isMovingX = true
		end
		self.isMoving = true
	end
	xl.DScreen.print("destPos,distance: ", "(%f,%f,%f,%f)",destinationX,destinationY,xl.distance(self.x,self.y,destinationX,destinationY),self.nodeThreashold)
	-- xl.DScreen.print("selfpos: ", "(%f,%f)",self.x,self.y)

	-- lume.trace(destinationX,destinationY)
	-- lume.trace("FX: ",self.forceX,"FY: ",self.forceY)
	return true
end

function ModPathFinder:checkClear(startX,startY,destX,destY,proximity)
	self.numCasts = self.numCasts + 1
	local checkGroundY = self.y + (self.charHeight or self.height) + 4
	self.scanContacts = {}
	self.startCastPoint = {x = startX, y = startY}
	Game.world:rayCast(startX, startY,destX, destY, self.wrapCheckFree)
	-- util.print_table(self.scanContacts)
	for i,v in ipairs(self.scanContacts) do
		local dist = xl.distance(v.x,v.y,destX,destY)
		-- lume.trace(proximity, dist)
		-- lume.trace(v.otherType,v.x,v.y)
		-- if dist > proximity then
		--if not v.fixture:getBody():getType() == "dynamic" or v.fixture:getBody():getMass() > 40 then
			return false
		--end
	end
	return true
end

function ModPathFinder:mCheckFree(fixture, x, y, xn, yn, fraction )
	if fixture then
		local other = fixture:getBody():getUserData()
		local category = fixture:getCategory()
		if fixture:isSensor() == false and other ~= nil and category ~= CL_INT and other ~= self  then
			local newEntry = {}
			newEntry.x = x
			newEntry.y = y
			newEntry.distance = xl.distance(self.startCastPoint.x,self.startCastPoint.y,x,y)
			--newEntry.object = other
			newEntry.otherType = other.type
			newEntry.fixture = fixture
			table.insert(self.scanContacts, newEntry )
		end
	end
	return 1
end

return ModPathFinder