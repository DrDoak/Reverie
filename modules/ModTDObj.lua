local ModTDObj = Class.create("Mod3DObj", Entity)
ModTDObj.dependencies = {"ModDrawable","ModPhysics"}

function ModTDObj:matchBodyToSpr(sprPiece)
	self:addSpritePiece( sprPiece )
	local imgY = (sprPiece.imgY or sprPiece.height/2)
	self:createBody( "dynamic" ,true, false)
	local vert = (sprPiece.vert or imgY) * (imgY/sprPiece.height)
	local h = imgY - vert
	self.shape = love.physics.newRectangleShape(sprPiece.imgX or sprPiece.width/2,h)
	self:setFixture(self.shape, 50)
end

return ModTDObj