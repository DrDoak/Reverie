----
-- xl/SpritePiece.lua
----
local Sprite = require "xl.Sprite"
local Scene = require "xl.Scene"
local anim8 = require "anim8"
local lume = lume

local WHITE = {255, 255, 255, 255}

local SpritePiece = Class.create("SpritePiece", Sprite)

function SpritePiece:init(image, frameWidth, frameHeight, border, z,name)
	Sprite.init(self,image, frameWidth, frameHeight, border, z)
	self.frameWidth = frameWidth
	self.name = name
	self.attachPoints = {}
	self.attachPoints["default"] = {}
	self.attachPoints["default"].offX = 0
	self.attachPoints["default"].offY = 0
	self.attachPoints["default"].attachF = 0
	self.attachPoints["default"].start = 1
	self.attachPoints["default"].attachMod = {{x=0,y=0}}
	self.rootSprite = nil
	self.ZangleType = "none"
	self.priority = self.priority or 0
	self.attachF = 0
	self.modDepth = 0
	self.offAngle = 0
	self.zDiff = 0

	self.currentAnim = "default"
	self.attachX = self.attachX or self.ox
	self.attachY = self.attachY or self.oy
	self.dir = 1
	self.mDir = 1
	self.currentDir = 1
	self.hubbub = "SpritePiece"
end

function SpritePiece:addPoint( name, px, py )
	self.attachPoints[name] = {x = px, y = py,offX = 0,offY = 0,offAngle = 0,attachMod = {{x=0,y=0}},attachF = 1,start=1}
end
function SpritePiece:setZAngleType( ztype )
	self.ZangleType = zType or "none"
end

function SpritePiece:updateAttach( updateTable )
	if updateTable then
		for i=1, #updateTable do
			local pointTable = updateTable[i]
			local pointID = pointTable[1]
			if type(pointID) ~= "string" then
				self.attachPoints["default"].attachMod = pointTable
				self.attachPoints["default"].start = 1
				self.attachPoints["default"].attachF = 0
			else
				self.attachPoints[pointID].attachMod = pointTable
				--self.attachPoints[pointID].attachF = 1
				self.attachPoints[pointID].start = 2
			end
		end
	end
end

function SpritePiece:onUpdate( )
	for key, value in pairs(self.attachPoints) do
		value.attachF = self.index + value.start
		if value.attachF > #value.attachMod then
			value.attachF = value.start
		end

		if value.attachMod[value.attachF] then
			value.offX =  value.attachMod[value.attachF].x
			value.offY =  value.attachMod[value.attachF].y
			local angle = value.attachMod[value.attachF].angle or 0

			if self.dir == -1 and angle ~= 0 then
				angle = 360 - angle
			end
			angle = angle/180
			angle = angle * math.pi
			value.offAngle = angle
			value.modDepth = 0 
			if value.attachMod[value.attachF].z then 
				value.modDepth = value.attachMod[value.attachF].z
			end
		else
			value.offX = 0
			value.offY = 0
			value.offAngle = 0
		end
	end
	-- local value = self.attachPoints["default"]
	-- value.attachF = self.index + 1
	-- if value.attachF > #value.attachMod then
	-- 	value.attachF = value.start
	-- end

	-- value.offX =  value.attachMod[value.attachF].x
	-- value.offY =  value.attachMod[value.attachF].y
	if self.frozen then 
		self.priority = 3
	end
end

function SpritePiece:freezeAnimation( dt )
	self.frozen = dt
end

function SpritePiece:addConnectPoint( sprite, pointName ,selfPoint)
	for key, mPoint in pairs(self.attachPoints) do
		if key == selfPoint then
			self.attachX = mPoint.x
			self.attachY = mPoint.y
		end
	end
	if self.attachPoints then
		for key, point in pairs(sprite.attachPoints) do
			if key == pointName then
				self.rootSprite = sprite
				self.rootPoint = pointName
				break;
			end
		end
	end
end

function SpritePiece:updatePos(px,py,depth)
	local currAttach = {}
	if self.rootSprite then
		local x = self.rootSprite.x
		local y = self.rootSprite.y 
		local offX = self.rootSprite.attachPoints[self.rootPoint].offX

		if offX == 0 then
			offX = self.rootSprite.attachPoints["default"].offX 
		end

		if self.rootSprite.dir == -1 then offX = offX - 1 end
		local offY = self.rootSprite.attachPoints[self.rootPoint].offY
		if offY == 0 then
			offY = self.rootSprite.attachPoints["default"].offY
		end
		local rootSprDir = 1
		if self.rootSprite.dir == -1 or self.rootSprite.dir == 1 then
			rootSprDir = self.rootSprite.dir
		end
		local xOffset = ((self.rootSprite.attachPoints[self.rootPoint].x/2) + offX )*rootSprDir
		xOffset = xOffset - (((self.attachX)/2) *self.dir * self.mDir)--* self.dir)
		local yOffset = (self.rootSprite.attachPoints[self.rootPoint].y/2) - offY - (self.attachY/2)
		
		local newAngle = self.rootSprite.angle 
		x = x + math.floor((xOffset * math.cos(newAngle)) - (yOffset * math.sin(newAngle)))
		y = y + math.floor((xOffset * math.sin(newAngle)) + (yOffset * math.cos(newAngle)))
		self:setPosition(x,y)
		local offAngle = self.rootSprite.attachPoints[self.rootPoint].offAngle
		if offAngle == 0 then
			offAngle = self.rootSprite.attachPoints["default"].offAngle or 0
		end 
		newAngle = newAngle + offAngle
		self:setAngle(newAngle)
		local z =  self.rootSprite.attachPoints[self.rootPoint].modDepth or 0-- self.z
		self.zDiff = z
		-- if self.name == "head" then
		-- 	lume.trace(self.zDiff)
		-- end
		
		-- Game.scene:move(self,z)
		-- lume.trace( self.rootSprite.attachPoints[self.rootPoint].modDepth ,self.zDiff)
		--self:setDepth(self.modDepth)
		for k,v in pairs(self.attachPoints) do
			if v.offX and v.offY then
				if not currAttach[k] then currAttach[k] = {} end
				-- lume.trace("X: ", (v.x * math.cos(newAngle)), "Y: ",(v.y * math.sin(newAngle)))
				currAttach[k].x = x + offX --self.rootSprite.x
				currAttach[k].y = y + offY --self.rootSprite.y
				-- lume.trace("k: ", k , v.offX,v.offY)
				-- currAttach[k].x =x + (v.x * math.cos(newAngle))
				-- currAttach[k].y =y + (v.y * math.sin(newAngle))
				-- currAttach[k].x = x
				-- currAttach[k].y = y
			end
		end
	else
		self.z = (depth or self.z) 
		self:setDepth(self.z)
		Game.scene:move(self,self.z);
		self:setPosition(px,py - 4 - self.sizey/2)
		for k,v in pairs(self.attachPoints) do
			if v.x and v.y then
				if not currAttach[k] then currAttach[k] = {} end
				currAttach[k].x = px + v.x
				currAttach[k].y = py + v.y
			end
		end
	end
	return currAttach
end

return SpritePiece
