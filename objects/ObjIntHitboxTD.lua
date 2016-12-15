local ObjIntHitbox = Class.create("ObjIntHitbox", Entity)

function ObjIntHitbox:init(creator,data)
	self.creator = creator
	self.data = data
end

function ObjIntHitbox:setCreator(creator)
	if creator ~= nil then
	end
	self.creator = creator
	if self.creator ~= nil then
	end
end

function ObjIntHitbox:create()
	local creator = self.creator
	self.hasTicked = false
	self.dir = creator.dir
	local positionX = creator.x + (6 * self.dir)
	local positionY = creator.y


	-- if Game.looptype == "side" then
		positionY = positionY + 6	
	-- end
	self.body = love.physics.newBody(self:world(), positionX, positionY, "dynamic")
	self.shape = love.physics.newRectangleShape(32, 48)

	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self.body:setUserData(self)	
	self.fixture:setCategory(CL_INT)
	self.fixture:setMask(CL_WALL, CL_NPC)
	-- self.fixtureDRAW = xl.SHOW_HITBOX(self.fixture)
	self.fixture:setSensor(true)
end

function ObjIntHitbox:tick(dt)
	if self.hasTicked then
		Game:del(self)
	else
		self.hasTicked = true
	end	
end

function ObjIntHitbox:destroy()
	self.body:destroy()
end

function ObjIntHitbox:onCollide(other, collision)
	if other then
		if Class.istype(other, "ObjBase") and other:hasModule("ModInteractive") then
			other:onPlayerInteract(self.creator, self.data)
		end
	end
end

return  ObjIntHitbox
