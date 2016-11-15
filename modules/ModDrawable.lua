local ModDrawable = Class.create("ModDrawable", Entity)

ModDrawable.trackFunctions = {"draw"}

function ModDrawable:create()
	self.animations = self.animations or {}
	self.sprites = self.sprites or {}
	self.idleCounter = 0
	-- self.angle = 0
	self.imgX = 64
	self.imgY = 64
	self.initImgH = 64
	self.initImgW = 64
	self.animationsPending = {}
	self.attachPositions = {}
end

function ModDrawable:tick(dt)
	self:updateSprites() 
end

function ModDrawable:destroy()
	for key, value in pairs(self.sprites) do
		self:delSpritePiece(key)
	end
	if self.sprite then
		Game.scene:remove(self.sprite)
	end 
end

function ModDrawable:changeAnimation(animation,speedMod,spritePieces)
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
		--local noOverride = (anim.noOverride and (#self.animationsPending == 0))
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
					local priority = (anim2.priority or 1)
					-- if #self.animationsPending ~= 0 then
					-- 	lume.trace()
					-- 	table.insert(self.animationsPending,key)
					-- 	if (self.sprites[key].priority == 0) then
					-- 		lume.trace()
					-- 		for i=1,#self.animationsPending do
					-- 			if self.animationsPending[i] == key then
					-- 				table.remove(self.animationsPending,i)
					-- 			end
					-- 		end
					-- 	end
					-- end
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
		else
			-- if self.sprites[sprites] then
			-- 	local row = anim.row
			-- 	local range = anim.range
			-- 	local delay = anim.delay
			-- 	local onLoop = anim.onLoop
			-- 	local startFrame = anim.startFrame or 1
			-- 	if value.attachPoints then
			-- 		for key, point in pairs(piece.attachPoints) do
			-- 			sprite:addPoint(key,(point.x -sprite.ox),(point.y -sprite.oy))
			-- 		end
			-- 	end
			-- 	if value.attachMod then
			-- 		self.sprites[key]:updateAttach(value.attachMod or {{{x=0,y=0}}})
			-- 	end
			-- 	local priority = anim2.priority or 1
			-- 	if priority > self.sprites[key].priority then
			-- 		--self:orientSprite(row,range,delay,startFrame, key,onLoop)
			-- 		self:orientAllSprites()
			-- 	end
			-- end
		end
	end
	return hasAnimation
end

function ModDrawable:updateSprites()
	if not self.angle and (self.body and not self.body:isFixedRotation()) then
		self:setSprAngle(self.body:getAngle())
	end
	for key,value in pairs(self.sprites) do
		if self.sprites[key].noLoop == false then
			self:changeAnimation(self.sprites[key].currentAnim )
		end
	end
	self.referenceVel = 0
	-- lume.trace(self.height)
	self:setSprPos(self.x,self.y + 24 + (self.charHeight or self.height)/2)
end

function ModDrawable:orientAllSprites()
	for key,value in pairs(self.sprites) do
		value:setScale(self.dir * value.mDir,1)
		value.dir = self.dir
		--self:setSprPos(self.x,self.y + 16 + self.charHeight/2)
	end
end
function ModDrawable:orientSprite(row,range,delay,startFrame, sprite, onLoop)
	local spr = self.sprites[sprite] or self.sprite
	if delay == 0 then delay = 0.1 end
	local md = self.sprites[sprite].mDir
	spr:setScale(self.dir * md,1)
	spr:setAnimation(range,row,1/delay,onLoop)
	spr.dir = self.dir * md
	-- if startFrame and startFrame ~= -1 then
	-- 	spr:setIndex(startFrame)
	-- end
end

function ModDrawable:freezeAnimation(sprite, duration)
	if self.sprites[sprite] then
		self.sprites[sprite]:pause(duration)
	end
end

function ModDrawable:resetAnimation(spritePiece)
	if self.sprites[spritePiece] then
		self.sprites[spritePiece]:resetAnimation()
		self.sprites[spritePiece]:onUpdate()
	end
end
function ModDrawable:overrideAnimation(spritePiece)
	if self.sprites[spritePiece] then
		self.sprites[spritePiece].priority = 0
	end
end

function ModDrawable:normalizeSprSize( speed )
	local s = speed or 8
	self.imgX = math.min( self.imgX + s, self.initImgW )
	self.imgY = math.min( self.imgY + s, self.initImgH)
end


function ModDrawable:animate()
	local maxXSpeed, maxYSpeed = self.maxXSpeed, self.maxYSpeed
	local walkanim = math.abs(4 / self.velX)
	local newVelX = self.velX - self.referenceVel
	walkanim = math.max(walkanim, 0.18)

	if self.inAir then 
		if self.turnTime and self.turnTime > 0 then
				self:changeAnimation({"fallTurn","fall"})
		elseif not self.turnTime and self.velY < 0 or self.jumping then
			self:changeAnimation("jump")
		else
			self:changeAnimation({"fall","jump"})
		end
	elseif self.isCrouching then
		self:changeAnimation({"crouch","stand"})
	elseif self.isMoving then
		self.idleCounter = 0
		if (self.dir == 1 and newVelX < -16) or (self.dir == -1 and newVelX > 16) then
			self:changeAnimation({"slideMore","slide","stand"})
		else
			if self.status == "offense" and self.prepTime > 5 then
				--self:changeAnimation("prep2")
				
				--self:freezeAnimation("body",0.0)
				--self:freezeAnimation("head",0.0)
			end 
			if math.abs(newVelX) >= maxXSpeed - 52 then
				self:changeAnimation({"run","walk"})
			else
				self:changeAnimation("walk")
			end
		end
	else
		if math.abs(newVelX) <= 32 then
			self.idleCounter = self.idleCounter + 1
			if self.status == "offense" and self.prepTime > 5 then
			--	self:changeAnimation({"prep","stand"})
			else
				if self.idleCounter >= 60 and self.idleCounter < 89 then
					self:changeAnimation({"idleStart","idle","stand"})
				elseif self.idleCounter > 84 then
					self:changeAnimation({"idle","stand"})
				else
					self:changeAnimation("stand")
				end
			end
			-- if self.idleCounter >= 84 then
			-- 	self.idleCounter = 0
			-- end
		else
			self:changeAnimation({"slide","stand"})
		end
	end
	if self.isHolding then
		self:changeAnimation({"holding","guard"})
	end

	-- if self.shieldDelay > 165 then
	-- 	self:changeAnimation({"guard","stand"})
	-- end

end

function ModDrawable:addSpritePieces( newPieces )
	local depth = self.depth
	for key, piece in pairs(newPieces) do
		self:addSpritePiece(piece ,depth)
		depth = depth + 1
	end
end

function ModDrawable:addSprite( piece )
	self.sprite = xl.Sprite(piece.path, piece.width, piece.height)
	self.sprite:setSize((piece.imgX or piece.width/2), (piece.imgY or piece.height/2))
	self.sprite:setOrigin((piece.originX or piece.width/2), (piece.originY or piece.height/2))
	self:changeAnimation(1,1,0, 1)
	Game.scene:insert(self.sprite)
end
function ModDrawable:addSpritePiece( piece , d)
	local sprite
	local SpritePiece = require "xl.SpritePiece"
	d = d or self.depth or 9000
	self.advancedSprites = true
	util.print_table(piece)
	lume.trace(piece.path)
	sprite = SpritePiece(piece.path, (piece.width or 128), (piece.height or 128),0,d)
	--sprite:setOrigin(16,16)
	sprite:setOrigin((piece.originX or piece.width/2), (piece.originY or piece.height/2))
	sprite:setSize((piece.imgX or piece.width/2), (piece.imgY or piece.height/2))
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
	sprite:setDepth(d + (piece.z or 0))
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

function ModDrawable:delSpritePiece( pieceName )
	if self.sprites[pieceName] then
		Game.scene:remove(self.sprites[pieceName])
		self.sprites[pieceName] = nil
	end
end

function ModDrawable:getAttachPos(attachPoint )
	return self.attachPositions[attachPoint]
end

function ModDrawable:setSprPos( x , y )
	for key, piece in pairs(self.sprites) do
		local piecesPos = piece:updatePos(x,y)
		for k,v in pairs(piecesPos) do
			self.attachPositions[k] = v
		end
	end
	if self.sprite then
		self.sprite:setPosition(x,y)
	end
end

function ModDrawable:setSprAngle( angle )
	for key, piece in pairs(self.sprites) do
		piece:setAngle(angle)
	end
	if self.sprite then
		self.sprite:setAngle(angle)
	end
end

function ModDrawable:setDepth( depth )
	self.depth = depth
end

return ModDrawable