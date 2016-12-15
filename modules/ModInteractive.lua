local ModInteractive = Class.create("ModInteractive", Entity)

ModInteractive.trackFunctions = {"onPlayerInteract"}


function ModInteractive:onPlayerInteract(player) 
end

function ModInteractive:tick( dt )
	if not self.intBody then
		self:createIntBox()
	end
	self:updateIntBox()
end
function ModInteractive:createIntBox()
	local posX, posY = self.body:getPosition()
	self.intBody = love.physics.newBody(self:world(),posX,posY,"kinematic")
	self.intFixture = love.physics.newFixture(self.intBody, self.fixture:getShape(), 1)
	self.intFixture:setCategory(CL_INT)
	self.intFixture:setMask(CL_CHAR, CL_WALL, CL_NPC)
	self.intBody:setUserData(self)
	self.intBody:setFixedRotation(true)
	self.intBoxActive = true
	-- self.fixtureDRAW = xl.SHOW_HITBOX(self.intFixture)
end

function ModInteractive:updateIntBox()
	if self.intBody ~= nil then
		local posX, posY = self.body:getPosition()
		self.intBody:setPosition(posX, posY)
	end
end

function ModInteractive:setIntBox( active )
	self.intBoxActive = active
end
	
function ModInteractive:destroy( ... )
	if self.intFixture then	
		self.intFixture:destroy()
	end
	if self.intBody then
		self.intBody:destroy()
	end
end
return ModInteractive