local ModSpeedZone = Class.create("ModSpeedZone",Entity)
local Scene = require "xl.Scene"

function ModSpeedZone:create()
	self.wrapCheckSpeedZone = lume.fn(ModSpeedZone.mCheckSpeedZone, self)
	self.modSpeedX = self.modSpeedX or -0.5
	self.modSpeedY = self.modSpeedY or self.modSpeedX
	self.speedModObjs = {}
	self.boundQuads = {self.x, self.y , self.x + self.width, self.y + self.height}
	local drawFunc = function()
		local floor = math.floor
		local loveGraphics = love.graphics
		loveGraphics.push()
		loveGraphics.setColor(50, 200, 50)
		loveGraphics.rectangle("fill",self.boundQuads[1],self.boundQuads[2],self.width,self.height)
		loveGraphics.setColor(255, 255, 255)
		loveGraphics.pop()
    end
	local node = Scene.wrapNode({draw = drawFunc}, 9900)
	Game.scene:insert(node)
end

function ModSpeedZone:tick( dt )
	Game.world:queryBoundingBox( self.boundQuads[1],self.boundQuads[2],self.boundQuads[3],self.boundQuads[4] , self.wrapCheckSpeedZone)
	-- Game.world:queryBoundingBox( self.x, self.y, self.x + self.width/2, self.y + self.height/2, self.wrapCheckSpeedZone)

	for i,v in ipairs(self.speedModObjs) do
		self:outOfZone(v)
	end
end

function ModSpeedZone:addInZone(other)
	lume.trace("aDD",other.type)
	other.speedModX = other.speedModX + self.modSpeedX
	other.speedModY = other.speedModY + self.modSpeedY
	table.insert(self.speedModObjs, other)
end

function ModSpeedZone:mCheckSpeedZone(fixture, x, y, xn, yn, fraction )
	if fixture then
		local other = fixture:getBody():getUserData()
		local category = fixture:getCategory()
		if other ~= nil and Class.istype(other,"ObjBase") and other:hasModule("ModActive") and other ~= self  then
			if not util.hasValue(self.speedModObjs,other) and xl.inRect({x=other.x,y=other.y},self.boundQuads) then
				self:addInZone(other)
			end
		end
	end
	return 1
end

function ModSpeedZone:outOfZone( object )
	local x, y = object.body:getPosition()
	if not xl.inRect({x=x,y=y},self.boundQuads) then
		lume.trace("Exit",object.type)
		-- lume.trace(object.speedModX)
		object.speedModX = object.speedModX - self.modSpeedX
		object.speedModY = object.speedModY - self.modSpeedY
		-- lume.trace(object.speedModX)
		util.deleteFromTable(self.speedModObjs,object)
	end
end

return ModSpeedZone