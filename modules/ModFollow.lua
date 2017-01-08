local ModFollow = Class.create("ModFollow", Entity)

function ModFollow:create()
end

function ModFollow:tick( dt )
	if self.followObj then
		if not  self.followObj.destroyed then
			self.x = self.followObj.x + self.followOffset.x
			self.y = self.followObj.y + self.followOffset.y
			if self:hasModule("ModPhysics") then
				self:setPosition(self.x,self.y)
			end
		else
			self.followObj = nil
		end
	end
end

function ModFollow:setFollowTarget( followObj ,offsetX,offsetY)
	self.followObj = followObj
	self:setOffset(offsetX,offsetY)
end

function ModFollow:setOffset( offsetX,offsetY )
	self.followOffset = {x=(offsetX or 0),y=(offsetY or 0)}
end

return ModFollow