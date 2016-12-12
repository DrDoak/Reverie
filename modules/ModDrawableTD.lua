local ModDrawable = require "modules.ModDrawable"
local ModDrawableTD = Class.create("ModDrawableTD", ModDrawable)

function ModDrawable:create()
	self.animations = self.animations or {}
	self.sprites = self.sprites or {}
	self.idleCounter = 0
	-- self.angle = 0
	self.imgX = 64
	self.imgY = 64
	self.initImgH = 64
	self.initImgW = 64

	self.lastDir = 0
	self.animationsPending = {}
	self.attachPositions = {}
	self.icons = {}
end

function ModDrawableTD:updateSprites()
	if not self.angle and (self.body and not self.body:isFixedRotation()) then
		self:setSprAngle(self.body:getAngle())
	end
	for key,value in pairs(self.sprites) do
		if self.sprites[key].noLoop == false then
			self:changeAnimation(self.sprites[key].currentAnim )
		end
		Game.scene:move(value,self.y)
	end
	xl.DScreen.print(self.type .. " depth:", "(%f)", self.y)
	self:setSprPos(self.x,self.y + 29 + self.height/2)
end

function ModDrawableTD:setSprPos( x , y )
	for key, piece in pairs(self.sprites) do
		local piecesPos = piece:updatePos(x,y - piece.vert/2)
		for k,v in pairs(piecesPos) do
			self.attachPositions[k] = v
		end
	end
	if self.sprite then
		self.sprite:setPosition(x,y)
	end
end

function ModDrawableTD:animate()
	local maxSpeed, maxYSpeed = self.maxSpeed, self.maxYSpeed
	local walkanim = math.abs(4 / self.velX)
	local newVelX = self.velX - self.referenceVelX
	local newVelY = (self.velY - self.referenceVelY) * 1.4
	local newVel = math.sqrt(math.pow(newVelX,2) + math.pow(newVelY,2))

	if self.isMoving then
		self.idleCounter = 0
		if (self.dir == 1 and newVelX < -16) or (self.dir == -1 and newVelX > 16) then
			self:changeAnimation({"slideMore","slide","stand"})
		else
			if math.abs(newVel) >= maxSpeed - 52 then
				self:changeAnimation({"run","walk"})
			else
				self:changeAnimation("walk")
			end
		end
	else
		if math.abs(newVelX) <= 32 then
			self.idleCounter = self.idleCounter + 1
			if self.idleCounter >= 60 and self.idleCounter < 89 then
				self:changeAnimation({"idleStart","idle","stand"})
			elseif self.idleCounter > 84 then
				self:changeAnimation({"idle","stand"})
			else
				self:changeAnimation("stand")
			end
		else
			self:changeAnimation({"slide","stand"})
		end
	end
	if self.isHolding then
		self:changeAnimation({"holding","guard"})
	end
end

function ModDrawableTD:orientAllSprites()
	for key,value in pairs(self.sprites) do
		if self.dir == -1 or self.dir == 1 then
			value:setScale(self.dir * value.mDir,1)
		else
			value:setScale(value.mDir,1)
		end
		value.dir = self.dir
	end
end
function ModDrawableTD:orientSprite(row,range,delay,startFrame, sprite, onLoop)
	local spr = self.sprites[sprite] or self.sprite
	if delay == 0 then delay = 0.1 end
	local md = self.sprites[sprite].mDir
	if self.dir == -1 or self.dir == 1 then
		spr:setScale(self.dir * md,1)
	else
		spr:setScale(md,1)
	end
	spr:setAnimation(range,row,1/delay,onLoop)
	spr.dir = self.dir * md
end

function ModDrawableTD:changeAnimation(animation,speedMod,spritePieces)
	if not self.advancedSprites then
		return 
	end
	local speed = speedMod or 1
	speed = 1/speed
	local hasAnimation = false
	local goodKey = "none"
	if type(animation) == "table" then
		for i=1,#animation do
			if self.animations[animation[i]] then
				goodKey = animation[i]
				break
			end
		end
	else
		goodKey = animation
	end
	if self.animations[goodKey] then
		hasAnimation = true
		local anim = self.animations[goodKey]
		local sprites = anim.sprites
		if type(sprites) == "table" then
			for key,value in pairs(sprites) do
				if (not spritePieces or util.hasValue(spritePieces,key)) and self.sprites[key] then
					local anim2 = value
					local row = anim2.row
					local range = anim2.range
					local delay = anim2.delay * speed
					local startFrame = anim2.startFrame or 1
					local noLoop = anim2.noLoop
					local mDir = anim2.dir or 1
					if self.dir == 0 then
						range = anim2.upRange or range
						row = anim2.upRow or row
					elseif self.dir == 2 then
						range = anim2.downRange or range
						row = anim2.downRow or row
					end
					local priority = (anim2.priority or 1)
					if (#self.animationsPending == 0 and priority >= self.sprites[key].priority) then
						self.sprites[key]:updateAttach(value.attachMod or {{{x=0,y=0}}})
						if goodKey ~= self.sprites[key].currentAnim then
							--self.sprites[key].attachF = #self.sprites[key].attachMod
							self.sprites[key]:setIndex(0)
							self.sprites[key]:onUpdate()
							self.sprites[key]:resume()
						end
						self.sprites[key].mDir = mDir
						self.sprites[key].currentAnim = goodKey
						self.sprites[key].priority = priority
						self:orientSprite(row,range,delay,startFrame, key,noLoop)
						self:orientAllSprites()
					end
				end
			end
		end
	end
	return hasAnimation
end

function ModDrawableTD:addSpritePiece( piece , d)
	local sprite
	local SpritePiece = require "xl.SpritePiece"
	self.advancedSprites = true

	sprite = SpritePiece(piece.path, (piece.width or 128), (piece.height or 128),0,d)
	local imgY = (piece.imgY or piece.height/2)
	sprite:setOrigin((piece.originX or piece.width/2), (piece.originY or piece.height/2))
	sprite:setSize((piece.imgX or piece.width/2), imgY)
	sprite.vert = piece.vert or imgY
	if piece.attachPoints then
		for key, point in pairs(piece.attachPoints) do
			self.attachPositions[key] = {x=(point.x -sprite.ox), y =(point.y -sprite.oy)}
			sprite:addPoint(key,(point.x -sprite.ox),(point.y -sprite.oy))
		end
	end
	if piece.connectSprite then
		local connectSprite
		for key, sprite in pairs(self.sprites) do
			if key == piece.connectSprite then
				connectSprite = sprite
				break
			end
		end
		sprite:addConnectPoint(connectSprite, piece.connectPoint,piece.connectMPoint)
	end
	sprite:setAnimation(1,1,1)
	--ssprite:setDepth(d + (piece.z or 0))
	Game.scene:insert(sprite)
	self.sprites[piece.name] = sprite
	if piece.animations then
		local animations
		if type(piece.animations) == "string" then
			animations = require(piece.animations)
		else
			animations = piece.animations
		end
		for k,v in pairs(animations) do
			if not self.animations[k] then
				self.animations[k] = {}
				self.animations[k]["sprites"] = {}
			end
			self.animations[k]["sprites"][piece.name] = v
		end
	end
end
return ModDrawableTD