local ModCheckView = Class.create("ModCheckView", Entity)

function ModCheckView:create()
	self.wrapCheckView = lume.fn(self.mCheckView, self)
	self.dir = self.dir or 1
end

function ModCheckView:checkView(minX,maxX,minY,maxY, predict,startUpTime)
	local curY = minY or 0
	maxY = maxY or minY or 0
	minX = minX or 0
	maxX = maxX or 32
	self.detected = false
	self.velXPredict = nil
	self.otherX = nil
	local trueDetect = false
	self.detected = nil
	local trueMinX = math.min(self.x + (maxX*self.dir),self.x + (minX * self.dir))
	local trueMaxX = math.max(self.x + (maxX*self.dir),self.x + (minX * self.dir))
	Game.world:queryBoundingBox(trueMinX, self.y + minY, trueMaxX, self.y + maxY, self.wrapCheckView)

	trueDetect = self.detected
	if predict then 
		self.velXPredict = nil
		self.otherX = nil
		local trueMinX = math.min(self.x + (160*self.dir),self.x + (minX * self.dir))
		local trueMaxX = math.max(self.x + (160*self.dir),self.x + (minX * self.dir))

		Game.world:queryBoundingBox(trueMinX, self.y + minY, trueMaxX, self.y + maxY, self.wrapCheckView)
		if self.velXPredict then
			local nextPoint = self.otherX + ((self.velXPredict)/60) * startUpTime
			if self.dir == 1 and nextPoint > self.x + (minX * self.dir) and nextPoint < self.x + (maxX * self.dir) or
			 	self.dir == -1 and nextPoint < self.x + (minX * self.dir) and nextPoint > self.x + (maxX * self.dir) then
			 	trueDetect = true
			end
		end
	end
	return trueDetect
end 

function ModCheckView:mCheckView(fixture, x, y, xn, yn, fraction )
	if fixture then
		local other = fixture:getBody():getUserData()
		if other ~= nil and fixture:isSensor() == false and fixture:getCategory() ~= CL_INT and other ~= self then
			if ((Class.istype(other, "ObjUnit") and other.faction ~= self.faction) or Class.istype(other, self.target)) and other ~= self then
				-- lume.trace("Detected true")
				self.velXPredict = other.velX
				self.otherX = other.x
				self.detected = true
			end
		end
	end
	return 1
end

return ModCheckView