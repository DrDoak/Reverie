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
