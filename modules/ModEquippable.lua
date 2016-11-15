local Keymap  = require "xl.Keymap"
local ModEquippable = Class.create("ModEquippable", Entity)
-- local FXExplosion = require "objects.fx.FXExplosion"

ModEquippable.dependencies = {"ModInteractive","ModPhysics","ModDrawable"}

function ModEquippable:create()
	-- physics initialization
	self:createBody( "dynamic" ,true, true)
	self.shape = love.physics.newRectangleShape(32,32)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self:setFixture(self.shape, 20)
	self.fixture:setCategory(CL_NPC)
	self.fixture:setMask(CL_CHAR , CL_NPC)

	--set default values
	self.dir = 1
	self.inserted = true
	self.midAirSlash = 0
	self.name = "default_item"
	self.gettingPutDown = false
	self.isKeyItem = false
	self.disabled = self.disabled or false
	self.created = true
	self:createIntBox()
	self.attackList = {}
	self.numInInv = 1
	self.velX = 0
	self.velY = 0
	-- self.fixtureDRAW = xl.SHOW_HITBOX(self.fixture)
end

function ModEquippable:tick(dt)
	local user = self.user
	if not self.destroyed then
		self.x, self.y = self.body:getPosition()
		self.velX, self.velY = self.body:getLinearVelocity()
		if user ~= nil then
			self.body:setGravityScale(0.0)
			self.dir = user.dir
			self.x = user.x
			self.y = user.y
			if user.inAir == false then self.hasTouchedGround = true end
			if user.isCrouching == true then
				self:setPosition(8,16)
			else
				self:setPosition(0,0)
			end
			if self.inserted then
				self.inserted = false
				Game.scene:remove(self.sprite)
			end
			if user.inAir == false then
				self.midAirSlash = 0
			end
			if self.user.status == "hit" or self.user.status == "stun" then 
				self.inUse = false
				self.isPrimaryActive = false 
			end
		else
			--lume.trace()
		end

		if self.gettingPutDown == true then
			self.body:setPosition(self.x, self.y + 32)
			self.user = nil
			self.gettingPutDown = false
		end

		self:updateIntBox()
		self.sprite:setPosition(self.x, self.y + 16)
		self.sprite:setAngle((self.angle or self.body:getAngle()))
		if self.depth then Game.scene:move(self.sprite, self.depth) end
	end
	if self.toDestroy then Game:del(self) end
end

function ModEquippable:onPlayerInteract(player,data)
	if self.isKeyItem and Class.istype(player,"ObjChar") then
		-- Game.savedata["hasItem_" .. self.type] = true
		table.insert(player.keyItemList, self.invSprite)
		-- player:setActionState("crouch",1)
		self.toDestroy = true
	elseif not self.isKeyItem and not self.toDestroy then 
		if player ~= self.user and not self.gettingPutDown then
			player:addToInv(self,self.stackable,nil,false,true)
			if self.depth then self.depth = nil end
			if self.inserted then
				self.inserted = false
				Game.scene:remove(self.sprite)
			end
		end
	end
end

function ModEquippable:createSpritePiece( originX,originY ,sprClass,predefSprite)
	local newTable = {}
	newTable.name = sprClass or "weapon"
	if predefSprite then
		self.sprClass = predefSprite.name
		newTable = predefSprite
	else
		self.sprClass = newTable.name
		newTable.path = imagePath or self.sprite.imagename or "assets/spr/weapons/spear.png"
		newTable.width = self.sprite.frameWidth
		newTable.height = self.sprite.frameHeight
		local ogX = originX or self.sprite.frameWidth/2
		local ogY = originY or self.sprite.frameHeight/2
		newTable.originX = ogX
		newTable.originY = ogY
		newTable.attachPoints = {
				grip1 = {x = ogX,y=ogY}
			}
		newTable.connectSprite = "body"
		newTable.connectPoint = "hand1"
		newTable.connectMPoint = "grip1"
	end
	self.spritePiece = newTable
	return newTable
end

function ModEquippable:activateSpritePiece( user )
	user = user or self.user
	lume.trace()
	if user then
		user:addSpritePiece(self.spritePiece,self.depth)
	end
end

function ModEquippable:use()
	lume.trace()
	local isDown = love.keyboard.isDown
	local user = self.user
	self.user.status = "offense"

	-- if not self.inserted then
	-- 	self.inserted = true
	-- 	Game.scene:insert(self.sprite)
	-- end

	if user.state ~= 4 and user.state ~= 3 and not self.disabled then
		user:setSpecialState(self)
	end

	if not user.inAir then
		user.isMoving = false
	end
	if self.invSlot ~= "primary" then
		self.action = "useItem"
	elseif user.inAir or user.jumping then
		self.aerialAttack = true
		if isDown("w") then
			self.action = "useAirUp"
		elseif isDown("s") then
			self.action = "useAirDown"
		elseif isDown("d", "a") then
			self.action = "useAirSide"
		else
			self.action = "useAir"
		end
	else
		self.aerialAttack = false
		if isDown("w")then
			self.action = "useUp"
		elseif isDown("s") then
			self.action = "useDown"
		elseif isDown("d", "a") then
			self.action = "useSide"
		else
			self.action = "useStand"
		end
	end
end

function ModEquippable:specialState(player, frame)
	self.dir = player.dir
	self.inUse = true
	if self.action == "useItem" then self:useItem(player,frame)
	elseif self.action == "useAirSide" then self:useAirSide(player,frame)
	elseif self.action == "useAirDown" then self:useAirDown(player,frame)
	elseif self.action == "useAirUp" then self:useAirUp(player,frame)
	elseif self.action == "useAir" then self:useAir(player,frame)
	elseif self.action == "useSide" then self:useSide(player,frame)
	elseif self.action == "useUp" then self:useUp(player,frame)
	elseif self.action == "useDown" then self:useDown(player,frame)
	elseif self.action == "useStand" then self:useStand(player,frame)
	elseif self.action == "useLight" then self:useLight(player,frame)
	elseif self.action == "useOver" then self:useOver(player,frame)
	end
	if self.aerialAttack == true and player.inAir == false and player.jumpCooldown == 0 then
		    player.exit = true
		    player:landing()
	end
	if player.exit == true then
		self.inUse = false
	end
end

function ModEquippable:onPrimaryEnd( )
end
--Default Use commands
function ModEquippable:useItem( player,frame )
	self:useStand(player,frame)
end
function ModEquippable:useAirSide(player,frame)
	self.canMove = true
	self:useSide(player,frame)
end
function ModEquippable:useAirUp(player,frame)
	self:useUp(player,frame)
end
function ModEquippable:useAirDown(player,frame)
	self.canMove = true
	self:useDown(player,frame)
end
function ModEquippable:useAir(player,frame)
	self.canMove = true
	self:useStand(player,frame)
end
function ModEquippable:useSide(player,frame)
	self:useStand(player,frame)
end
function ModEquippable:useUp(player,frame)
	self:useStand(player,frame)
end
function ModEquippable:useStand(player,frame)
	player.exit = true
end
function ModEquippable:useDown(player,frame)
	self:useStand(player,frame)
end

function ModEquippable:setPosition(xOffset , yOffset)
	local userX, userY = self.user.body:getPosition()
	self.body:setPosition(userX + (xOffset * self.user.dir), userY + (yOffset or 0))
	self.sprite:setPosition(self.x, self.y + 16) --update sprite position to match physics location
end

--Only left/right orientation
--no orientation

function ModEquippable:drop(toDestroy)
	self.user = nil
	-- lume.trace()
	self.body:setGravityScale(1.0)
	if not self.inserted then
		self.inserted = true
		Game.scene:insert(self.sprite)
	end
end
-- function ModEquippable:destroy()
-- 	if self.user and not self.user.destroyed then
-- 	elseif not self.destroyed then
-- 		self.destroyed = true
-- 	end
-- end


function ModEquippable:checkInt(fixture)
	if fixture then
		local other = fixture:getBody():getUserData()
		if other and Class.istype(other, "ObjInteractive") then
			if not Class.istype(other, "ModEquippable") or other ~= self.currentEquip then
				self.numInt = self.numInt + 1
			end
		end
	end
	return 1
end

function ModEquippable:setLightActive( active )
	if not self.inUse then
		self.isPrimaryActive = active
	end
end

function ModEquippable:registerHit(target, hitType, hitbox)
	if self.user then
		self.user:registerHit(target,hitType,hitbox)
	end
end


-- function ModEquippable:drawEffect( xOffset,yOffset,amount ,image)
-- 	local angle = 0
-- 	for i=1,amount do
-- 		local FX = FXExplosion(self.x + xOffset, self.y + yOffset, (image or "assets/spr/fx/smoke.png"),32,32)
-- 		Game:add(FX)
-- 		FX:setMaxSize(16,16)
-- 		-- FX.sprite:setAnimation(math.random(1,4),1,5)
-- 		FX:setDepth(9000)
-- 		angle = angle +  math.random(math.pi, math.pi * 2)
-- 		FX:setAngle(angle)
-- 		local speed = math.random(1,2)
-- 		FX:setSpeed(speed * math.cos(angle),speed * math.sin(angle))
-- 	end
-- end

function ModEquippable:makeCopy()
	local class = require( "objects.eqp." .. self.type )
	local inst = class()
	inst.x = self.x 
	inst.y = self.y
	inst.faction = self.user.faction
	-- inst.tossX = self.tossX
	-- inst.tossY = self.tossY
	-- inst.toDestroy = self.toDestroy
	inst.user = self.user
	inst.numInInv = self.numInInv
	Game:add(inst)
	return inst
	-- self.user:addToInv(inst,self.stackable,true)
end

return ModEquippable