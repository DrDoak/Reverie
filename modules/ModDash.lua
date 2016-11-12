local ModDash = Class.create("ModDash", Entity)

function ModDash:create()
	self.clip = false
end


function ModDash:normalState()
	if not self.isCrouching then
		if self.referenceVel ~= 0  and ((self.dir == 1 and self.referenceVel < 0) or (self.dir == -1 and self.referenceVel > 0)) then 
			self:controlDash()
		else
	end
end

function ModDash:controlDash() 
	if Keymap.isDown("dash") and self.redHealth > 0 then
		if self.state == 3 then
			self.state = 1
			self.stun = 0
			return
		end
		-- self.redHealth = math.max(0, self.redHealth - 20)
		-- self:setHealth(self.health,self.redHealth)
		-- self.redHealthDelay = 120
		self.invincibleTime = 15

		local function dash(player,frame)
			self.status = "dashing"
			self.fixture:setMask(CL_NPC)
			if frame < 14 then
				self:setSprColor(0,0,255,100)
				player.body:setLinearVelocity(12 * 32 * player.dir, 0) --player.velY)
			elseif frame < 16 then
				self:setSprColor(255,255,255,255)
				player.body:setLinearVelocity(( 16 - frame) * 32 * player.dir, 0)--player.velY)
			else
			end
			--player.dir = - player.dir
			player:changeAnimation({"dash","slideMore"})
			--player.dir = - player.dir
			if frame > 30 then
				self.fixture:setMask(16)
				player.exit = true
			end
		end
		self:setSpecialState(dash)
	end
end

return ModDash