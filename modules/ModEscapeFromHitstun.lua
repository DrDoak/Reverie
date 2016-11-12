local ModEscapeFromHitstun = Class.create("ModEscapeFromHitstun", Entity)

function ModEscapeFromHitstun:hitState()
	self.isMoving = false

	if self.inAir then 
		self:changeAnimation("hitmore")
		if math.abs(self.angle) < (2*math.pi)/4 then
			self.angle = self.angle + (0.00004 * self.velX * math.min(30,self.stun))
		end
		self:setSprAngle(self.angle)
	end
	if not self.inAir and math.abs(self.angle) > math.pi/2 then
		self.angle = 0
		self:setSprAngle(self.angle)
		local function grounded( player, frame )
			if frame == 1 then
				self:changeAnimation("ground")
			end
			if frame > 15 and (Keymap.isDown("left") or Keymap.isDown("right") or Keymap.isDown("down") or Keymap.isDown("jump") or Keymap.isDown("up")) then
				frame = 600
			end
			if frame == 600 then
				player.exit = true
				local function hit_ground( player, count )
					player:changeAnimation("crouch")
					if count >= 24 then
						player:changeAnimation("stand")
						player.exit = true
					end
				end
				self:setSpecialState(hit_ground)
			end
		end
		self:setSpecialState(grounded)
		return
	end
	if self.stun > 0 then
		self.stun = self.stun - 1
	else
		if self.inAir and Keymap.isPressed("jump") then
			self.state = 1
			local function recover( player, frame )
				player:moveVertical()
				player:animate()
				player.angle = player.angle - (0.5 * self.dir)
				player:setSprAngle(player.angle)
				if frame == 1 then
					self.body:setLinearVelocity(self.velX, -self.jumpSpeed/10)
					self:drawJumpFX(math.random(5,7))
				end
				if frame >= 7 then
					player.angle = 0
					player:setSprAngle(player.angle)
					player.exit = true
				end
			end
			self:setSpecialState(recover)
		elseif not self.inAir then
			self.angle = 0
			self:setSprAngle(self.angle)
			self.state = 1
		end
	end
	self:overrideAnimation("legs")
	self:overrideAnimation("body")
	self:overrideAnimation("head")
	if self.status == "stunned" then
		--self:controlDash()
		self:changeAnimation({"stun","hit"})
	else
		self:changeAnimation("hit")
	end
end

return ModEscapeFromHitstun