local ModToggleClip = Class.create("ModToggleClip", Entity)

function ModToggleClip:create()
	self.clip = false
end

function ModToggleClip:setClipKey( keyName)
	self.keyName = keyName
	Keymap.pressed(self.keyName,self.setClip)
end

function ModToggleClip:setClip()
	self:setFixture(self.shape, 22.6)
	if self.clip == false then
		self.fixture:setMask(CL_WALL)
	else
		self.fixture:setMask(16)
	end
	self.flying = not self.flying
	self.clip = not self.clip
end

return ModToggleClip