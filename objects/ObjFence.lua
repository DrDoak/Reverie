local ObjBase = require "ObjBase"
local ObjFence = Class.create("ObjFence", ObjBase)
	
function ObjFence:create()
	self:addModule(require "modules.ModDrawable")
	self.image = self.image or "assets.spr.scripts.SprFence"
	self.y = self.y + self.height
	self.x = self.x + 16
	local sprite = require(self.image)
	sprite.imgX = sprite.imgX or sprite.width
	sprite.originX = sprite.originX or sprite.width/2
	-- local xMax = self.x + self.width
	self.vert = 32
	-- local currentX = self.x
	local offset = sprite.imgX
	local totalOffset = 0
	local numImgs = 0
	local edgeRow = 1
	local edgeRange = 1
	if sprite.animations["edge"] then
		edgeRange = sprite.animations["edge"].range
		edgeRow = sprite.animations["edge"].row
	end

	while (totalOffset < self.width) do
		local newSprite = util.deepcopy(sprite)
		newSprite.name = "fenceX"..numImgs + 1

		newSprite.originY = 24
		newSprite.attachPoints["center"] = {x = 0,y = 24}
		newSprite.attachPoints["nextSegment"] = {x = 64,y = 24}
		if numImgs > 0 then
			newSprite.connectSprite = "fenceX" .. numImgs
			newSprite.connectPoint = "nextSegment"
			newSprite.connectMPoint = "center"
			newSprite.attachPoints["nextSegment"] = {x = 64,y = 24}
		end
		self:addSpritePiece(newSprite)
		local newS = self.sprites[newSprite.name]
		if totalOffset == 0 then
			local edgeX = 
			newS:setAnimation(edgeRange,edgeRow,1)
			newS:setScale(-1,1)
		elseif totalOffset == self.width - offset then
			newS:setAnimation(edgeRange,edgeRow,1)			
		end
		totalOffset = totalOffset + offset
		numImgs = numImgs + 1
	end
end

return ObjFence