local ObjBaseUnit = require "objects.ObjBaseUnit"
local Keymap  = require "xl.Keymap"
local Healthbar = require "mixin.Healthbar"
local EquipIcon = require "mixin.EquipIcon"
local TextInterface = require "mixin.TextInterface"

local Inventory = require "xl.Inventory"
local InventoryMenu = require "state.InventoryMenu"
local gamestate = require "hump.gamestate"
local Lights = require "xl.Lights"
-- local ObjCape = require "objects.ObjCape"
--local JBase = require "state.Journal.JBase"
--local FXSpellText = require "objects.fx.FXSpellText"
-- local ObjIntHitbox  = require("objects.ObjIntHitbox")
-- local FXExplosion = require "objects.fx.FXExplosion"

local Sound = require "xl.Sound"
local ObjChar = Class.create("ObjChar", ObjBaseUnit)
local abs = math.abs
util.transient( ObjChar, "healthbar", "guardbar" , "equipIcons" , "equipIcon2" , "sprite")

--Initializes values of ObjChar, only runs once at the start of the game
-- sets up values which initial conditions
function ObjChar:init(  )
	-- inventory initialization
	self.inventory = Inventory(3,3)
	self.keyItemList = {}
	self.canPressUse = true

	-- init other data
	self.max_health = 100
	self.max_light = 100
	self.health = 100
	self.light_meter = 100

	--initialize movement data
	self.maxJumpTime = 300
	self.currentJumpTime = 0
	self.jumpSpeed = 490
	self.maxAirJumps = 1
	self.airJumps = 0
	self.deceleration = -9
	self.maxSpeed = 6 * 32
	self.acceleration = 20 * 32
	self.currentEquips = {}
	self.currentPrimary = nil
	self.x = 0
	self.y = 0
	self.relevance = 100
	self.money = self.money or 0
	self.reals = self.reals or 0
	self.persistent = true
	self.attackTimer = 0
	self.charHeight = 22
	self.canControl = true
	self.deflectable = true

	self.inventoryLocked = self.inventoryLocked or false
	self.faction = "player"
	Game.savedata["count_deaths"] = 0

	self.maxShield = 100
	self.shield = 100
end


--Initializes values of ObjChar which will occur at the beginning of every room
--Recreates b2 body in every room.
function ObjChar:create()
	ObjBaseUnit.create(self)
	--initialize b2 Physics bodies. Everytime we create a new object, not only do we need to create
	-- a "game logic" instance of the object (which is just this file), but we also need to add the object to the physics world.
	-- Of course, some objects don't need to be added to the physics world, like special effects (no collisions).

	-- We start by defining a body. A body is simply any single physics object. Bodies have mass, as well as a position.
	self.body = love.physics.newBody( Game.world, self.x, self.y, "dynamic" ) -- Here we make a new body, 
		-- We tell it which world we want to put it in. In this case, the game's current world. (my game only has one world at a time.)
		-- We specify the location of the body
		-- We also make it dynamic, which means it can be pushed around and interact with things. Other types are:
			-- Static: No movement whatsoever, but can stop things (walls)
			-- Kinematic: Cannot be pushed around, but can move (moving platforms.) 
			--Whenever possible, try to used dynamic. Consistency = fewer bugs.
	self.body:setFixedRotation(true) -- My character physics object is essentially just a hitbox, so we don't want it rotating.
	self.body:setUserData(self) -- Always set this to self.
	self.body:setBullet(true) -- Technically a "bullet" is slang for a "high-precision" physics object.
		-- It is called a bullet because bullets travel really quickly and need high precision.
		-- Since this is the player character, I want as high precision as possible. tap. questions point.

	-- self:addSpritePieces(require("assets.spr.enemy.heavy_enemy.PceBlue"))
	-- self.animations = require "assets.sprsskssssws.enemy.heavy_enemy.AneBlue"

	self:addSpritePiece(require("assets.spr.scripts.PceWheel"))
	-- self:addSpritePiece(require("assets.spr.scripts.PceLegsMedThin"))
	-- self:addSpritePiece(require("assets.spr.scripts.PceLegsLgBoots"))

	-- self:addSpritePiece(require("assets.spr.scripts.PceBodyMedGirl"))
	-- self:addSpritePiece(require("assets.spr.scripts.PceBodyWhite"))
	--self:addSpritePiece(require("assets.spr.scripts.PceBodyLgUniform"))
	self:addSpritePiece(require("assets.spr.scripts.PceBody"))
	-- -- self:addSpritePiece(require("assets.spr.scripts.PceBodyLgUniform"))


	-- self:addSpritePiece(require("assets.spr.scripts.PceHeadVirgule"))
	-- self:addSpritePiece(require("assets.spr.scripts.PceHeadSayer"))
	-- self:addSpritePiece(require("assets.spr.scripts.PceHeadIrrelevant"))
	-- self:addSpritePiece(require("assets.spr.scripts.PceHeadHetairoi"))
	-- self:addSpritePiece(require("assets.spr.scripts.PceHeadTest"))


	-- self:addSpritePieces(require("assets.spr.enemy.scripts.PceFadedGhost"))
	-- self.animations = require "assets.spr.enemy.scripts.AneFadedGhost"

	self.clip = false
	--initializes sprite and hud
	if not (self.sprites and self.healthbar and self.guardbar and self.equipIcons) then
		-- create sprite
		-- self:addSpritePieces(require("assets.spr.player.PceIrrelevant"))
		-- self.animations = require "assets.spr.player.AneIrrelevant"
		self.imgX = 64
		self.imgY = 64
		self.initImgH = 64
		self.initImgW = 64

		-- healthbar
		self.healthbar = Healthbar( self.max_health )
		self.healthbar.fgcolor = { 150, 0, 0 }
		self.healthbar.redcolor = { 255, 0, 0 }
		self.healthbar:setPosition( 72, 5 )
		self.healthbar.bgcolor = {100,100,100}
		--self.healthbar:setImage(love.graphics.newImage( "assets/HUD/interface/marble.png" ))

		-- guardbar
		self.guardbar = Healthbar( self.max_light )
		self.guardbar.fgcolor = { 40, 200, 40 }
		self.guardbar:setPosition( 72, 20 )
		self.guardbar:setImage(love.graphics.newImage( "assets/HUD/interface/gold.png" ))

		--Primary Equip Icon
		self.equipIcons = {}

		if self.currentPrimary then
			self.equipIcons["primary"] = EquipIcon( self.currentPrimary.invSprite )
			self.equipIcons["primary"]:setPosition( 2 , 2 )
		else
			self.equipIcons["primary"] = EquipIcon( nil )
			self.equipIcons["primary"]:setPosition( 2 , 2 )
		end
		
		--Equip Icon
		-- if self.currentEquip then
		-- 	self.equipIcon = EquipIcon( self.currentEquip.invSprite )
		-- 	self.equipIcon:setPosition( 2 , 5 )
		-- else
		-- 	self.equipIcon = EquipIcon( nil )
		-- 	self.equipIcon:setPosition( 2 , 5 )
		-- end
		self.equipIcons["up"] = EquipIcon(nil)
		self.equipIcons["up"]:setPosition(2,74)
		self.equipIcons["neutral"] = EquipIcon(nil)
		self.equipIcons["neutral"]:setPosition(2,146)
		self.equipIcons["down"] = EquipIcon(nil)
		self.equipIcons["down"]:setPosition(2,218)

		for k,v in pairs(self.currentEquips) do
			if self.equipIcons[k] then
				self.equipIcons[k]:setImage(v.invSprite)
			end
		end
		self.TextInterface = TextInterface()
	end
	Game.hud:insert( self.healthbar )
	Game.hud:insert( self.guardbar  )
	Game.hud:insert( self.TextInterface )
	for k,v in pairs(self.equipIcons) do
		Game.hud:insert( v )
	end
	self:setDepth(self.depth or 5000)
	
	--if set to true, the game will maintain a hitbox that displays "!" when
	-- near an interactable object
	-- self.detectBox = true
	ObjChar.currentPlayer = self
	Game:setPlayer(self)
	self.deathShade = 255

	--initialize player hitboxes
	self.shape = love.physics.newRectangleShape(7, 38)
	self.shapeCrouch = love.physics.newRectangleShape(8,20)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self:setFixture(self.shape, 22.6) -- you may notice that the player has a body, but I never define the shape of the body.
	-- That is because there are things called "Fixtures" which are essentially just shapes. One body can be comprised of multiple fixtures.
	-- this is all part of love2d. I wrote the function setFixture which takes a shape and a weight and sets it as the 
	-- fixture of the player character. This simplifies things a bit. The reason why is that you can simply swap shapes whenever you need to
	-- without worrying about the complexities of deleting fixtures (deleting fixtures suck.)
	self.fixture:setCategory(CL_CHAR)
	self.fixture:setRestitution( 0.0 )
	self.canBeDeflected = true
	--self.fixtureDRAW = xl.SHOW_HITBOX(self.fixture)

	--initialize Inventory
	Inventory:initialize(self, "Peridot")
	self.inventory:setUser(self)
	self.inventory.currentEquips = self.currentEquips
	self.inventory.currentPrimary = self.currentPrimary
	if self.currentEquip then
		local newEquip = self.currentEquip
		self.currentEquip = nil
		Game:add( newEquip )
		self:setEquip( newEquip , false)
	end
	if self.currentPrimary then
		local newEquip = self.currentPrimary
		self.currentPrimary = nil
		Game:add( newEquip )
		self:setEquip( newEquip ,false,true)
	end
	-- self.myChain = ObjCape(self)
	-- Game:add(self.myChain)

	-- self:addLight("myLight")
	--self.lighting = Lights.newGradSpotLight(25, 2, -90,0.35)
	--self.lighting:setColor(255,0,0)
	--Game.lights:add(self.lighting)

	-- self:setEquipCreateItem("EqpTest")
end

--destroys the current player object, and cleans up the currentEquip/Primary for the player
--insure that the player tick is first
function ObjChar:tick( dt, is_precall )
	if not is_precall then
		return
	else
		self:setGuard(self.shield)
		ObjBaseUnit.tick( self, dt )
	end
end

--calculates necessary force to make the character move in a certain direction
function ObjChar:calcForce( dv, vel, accel, maxSpeed )
	local f = dv * accel-- - vel
	if math.abs( vel - self.referenceVel) >= (maxSpeed ) and dv == util.sign( vel ) then
		f = dv * 0.000001
	end
	return f
end

--The player's normal state of control in the Top Down sections
-- in this state, the player can move freely, interact with items
-- and  r her inventory

function ObjChar:normalState()
	--self.lighting:setPosition(self.x, self.y + self.height-2)
	local maxXSpeed, maxYSpeed = self.maxXSpeed, self.maxYSpeed
	--local decForce = self.deceleration * self.body:getMass() 
	if not self.isCrouching then
		if self.referenceVel ~= 0  and ((self.dir == 1 and self.referenceVel < 0) or (self.dir == -1 and self.referenceVel > 0)) then 
			self:moveLateral(self.maxXSpeed, self.maxYSpeed, self.acceleration * 2)
		else
			self:moveLateral(self.maxXSpeed, self.maxYSpeed, self.acceleration)
		end
	end
	self:moveVertical()
	if Keymap.isDown("down") and Keymap.isDown("jump") then
		self:setJumpThru(1)
	end
	self:setPrimary(Keymap.isPressed("primary"))
	self:animate()
	--self:normalizeSprSize()
	self:proccessInventory()
	self:debugDisplay()
end

function ObjChar:normalMove()
	lume.trace()
	if self.referenceVel ~= 0  and ((self.dir == 1 and self.referenceVel < 0) or (self.dir == -1 and self.referenceVel > 0)) then
		self:moveLateral(self.maxXSpeed, self.maxYSpeed, self.acceleration * 2)
	else
		self:moveLateral(self.maxXSpeed, self.maxYSpeed, self.acceleration)
	end
 	self:moveVertical()
end

function ObjChar:moveVertical()
	--Jumping code
	if self.flying then
		self.inAir = false --Uncomment this to jump infinately (fly)
	end
	if Keymap.isPressed("clip") then
		self:setFixture(self.shape, 22.6)
		if self.clip == false then
			self.fixture:setMask(CL_WALL)
		else
			self.fixture:setMask(16)
		end
		self.flying = not self.flying
		self.clip = not self.clip
	end

	
	if Keymap.isPressed("jump") and not Keymap.isDown("down") and self.jumpCooldown == 0 then
		self.noGrav = false
		if not self.inAir then
			self.body:setLinearVelocity(self.velX, -self.jumpSpeed/15) 
			self.jumpCooldown = 10 
			self.jumping = true
			self.isMoving = true
			self:drawJumpFX(math.random(2,3))
		elseif self.airJumps > 0 then
			if Keymap.isDown("left") then
				self.dir = -1
			elseif Keymap.isDown("right") then
				self.dir = 1
			end
			self:drawJumpFX(math.random(2,3))
			self.body:setLinearVelocity(self.velX, -self.jumpSpeed/20) 
			self.jumpCooldown = 10 
			self.jumping = true
			self.isMoving = true
			self.airJumps = self.airJumps - 1
		end
	elseif self.jumping then
		self.currentJumpTime = self.currentJumpTime + 1
	end
	if self.currentJumpTime > self.maxJumpTime then
		self.jumping = false
	end
	if not Keymap.isDown("jump") then
		self.currentJumpTime = 0
		self.jumping = false
	end
	
	--check for crouching, you cannot move while crouching.
	if Keymap.isDown("down") and not self.inAir then
		if self.isCrouching == false then --enter crouching state
			-- self:setFixture(self.shapeCrouch, 22.6)
			-- self.body:setPosition(self.x, self.y - 9)	
			self.isCrouching = true
			--self:setActionState(1,"5-7",0.2,5,7)
		end
		self.isMoving = false
	else --if you are not crouching, you are counted as standing
		if self.isCrouching then --return back to standing orientation
			-- self:setFixture(self.shape, 22.6)
			-- self.body:setPosition(self.x, self.y - 9)	
		end
		self.isCrouching = false
	end
end

--Manages left/right
function ObjChar:moveLateral(maxXSpeed, maxYSpeed, acceleration)
	--Movement Code
	maxXSpeed = maxXSpeed or self.maxXSpeed
	local accForce
	if acceleration then
		accForce = acceleration * self.body:getMass()
	else
		accForce = self.acceleration * self.body:getMass()
	end
	local dvX,xdir = 0,0
	if not self.inAir then self.turnTime = nil end
	if Keymap.isDown("left") then 
		dvX = dvX - 1
		if self.dir == 1 and self.velX > 0 then
			self.turnTime = 16
		end
		--if not self.inAir  or self.velX < 0 then
			self.dir = -1 
		--end
	end
	if Keymap.isDown("right") then 
		dvX = dvX + 1
		if self.dir == -1 and self.velX < 0 then
			self.turnTime = 16
		end
		 	self.dir =   1 
		--end
	end
	if self.turnTime then self.turnTime = self.turnTime - 1 end
	if dvX ~= 0 and math.abs(self.velX - self.referenceVel) < maxXSpeed * self.speedModifier then
		self.forceX = dvX * accForce
		if util.sign(self.velX) == dvX then
			self.forceX = self.forceX * 2
		end
	end
	self.forceX = self:calcForce( dvX, self.velX, accForce, maxXSpeed )
	if self.inAir then
		self.forceX = self.forceX * 0.8
	end
	self:controlDash()
	self.isMoving = (dvX ~= 0) or self.inAir
end

function ObjChar:controlDash() 
	if Keymap.isDown("dash") and self.redHealth > 0 then
		if self.state == 3 then
			self.state = 1
			self.stun = 0
			return
		end
		self.redHealth = math.max(0, self.redHealth - 20)
		self:setHealth(self.health,self.redHealth)
		self.redHealthDelay = 120
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
--Selects the appropriate sprite based on the character's current position,
-- speed, whether she is in air, crouching, and whatnot.
-- function ObjChar:animate()

-- end

--Manages character's inventory management, item usage and environmental interaction code.
function ObjChar:proccessInventory()
	--Open Inventory
	if Keymap.isDown("inv") and not self.inventoryLocked then
		--Sound.playFX("stapler.mp3")
		InventoryMenu:open(self.inventory)
	end
	--Item using code
	if Keymap.isPressed("use") and self.canPressUse then
		if Keymap.isDown("up") and self.currentEquips["up"] then
			self.currentEquips["up"]:use()
		elseif Keymap.isDown("down") and self.currentEquips["down"] then
			self.currentEquips["down"]:use()
		elseif self.currentEquips["neutral"] then
			self.currentEquips["neutral"]:use()
		end
		-- elseif self.currentPrimary then
		-- 	self.currentPrimary:use()
		-- end
	end
	--interaction code

	-- if Keymap.isPressed("interact") and not Game.DialogActive then
	-- 	local intHitbox = ObjIntHitbox(self) 
	-- 	Game:add(intHitbox)
	-- end
	--if Keymap.isPressed("journal") then gamestate.push(JBase) end	
end

function ObjChar:setHealth( health ,redHealth)
	health = math.min( health, self.max_health )
	self.healthbar.redValue = redHealth or health
	self.healthbar.value = health
	ObjBaseUnit.setHealth(self,health)
end

function ObjChar:setGuard( guard )
	guard = math.min( guard, self.maxShield )
	guard = math.max(guard, 0)
	self.shield = guard
	self.guardbar.value = guard
end

--
function ObjChar:die()
	self.isAlive = false
	-- self.deathShade = math.max(0, self.deathShade - 2)
	-- self:setHitState(17,64 * -self.dir,-1 * 32,0) 
	-- Game.scene:move(self.sprite, 10000)
	local function death( player, frame )
		lume.trace(frame)
		if frame == 1 then
			Game.WorldManager:fade(2)
 			Game.savedata["count_deaths"] = Game.savedata["count_deaths"] + 1
		elseif frame > 120 then
			Game.WorldManager:respawnFromDeath(self)
			player.exit = true
		end
	end
	if not self.onDeath then
		lume.trace("on death")
		self.onDeath = true
		self:setSpecialState(death,false,true)
	end
end

function ObjChar:debugDisplay()
	-- local inAir
	-- if self.inAir then inAir = 1 else inAir = 0 end
	-- local isDown 
	-- if Keymap.isDown("down") then isDown = 1 else isDown = 0 end
	-- xl.DScreen.print("ObjChar.numContacts", "(%f)", self.numContacts)
	-- xl.DScreen.print("ObjChar.inAir", "(%f)", inAir)
	-- -- xl.DScreen.print("ObjWorldManager.timeInRoom", "(%f)", Game.WorldManager.timeInRoom)
	-- -- xl.DScreen.print("ObjChar.force", "(%f,%f)", self.forceX, self.forceY)
	-- -- xl.DScreen.print("ObjChar.pos", "(%d,%d)", self.x, self.y)
	-- -- xl.DScreen.print("ObjChar.vel", "(%d,%d)", self.velX, self.velY)
	-- -- xl.DScreen.print("ObjChar.status: ","(%s)", self.status)
	-- xl.DScreen.print("ObjChar.thruTime: ","(%f)", self.thruTimer)

	-- -- xl.DScreen.print("ObjChar.slopeDir", "(%f)", self.slopeDir)
	-- local roomX = math.ceil(math.floor(self.x/16)/8)
	-- local roomY = math.ceil(math.floor(self.y/16)/8)
	-- xl.DScreen.print("ObjChar.structCoord", "(%d,%d)", roomX, roomY)
	-- -- local area = Game.WorldManager.evalArea
	-- local areaName = "None"
	-- local timeStamp = 0
	-- if area and area[roomX] and area[roomX][roomY] then
	-- 	areaName = area[roomX][roomY]["type"]
	-- 	if area[roomX][roomY]["structNum"] then
	-- 		timeStamp = area[roomX][roomY]["structNum"]
	-- 	end
	-- end
	-- --lume.trace(areaName)
	-- xl.DScreen.print("Current struct time: ","(%d)",timeStamp)
	-- xl.DScreen.print("Current Struct: ","(%s)",areaName)
	-- self.TextInterface:setPosition(74,32)
	-- self.TextInterface:print("Relevance", "%i", self.relevance)
	-- self.TextInterface:print("Money", "%i", self.money)
	-- -- xl.TextInterface.setposition(146,32)
	-- self.TextInterface:print("Reals", "%i", self.reals)
end

function ObjChar:hitState()
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
		self:controlDash()
		self:changeAnimation({"stun","hit"})
	else
		self:changeAnimation("hit")
	end
end

function ObjChar:drawJumpFX( amount )
	-- local angle = 0
	-- for i=1,amount do
	-- 	local FX = FXExplosion(self.x, self.y + self.height/2, "assets/spr/fx/jump_blue.png",32,48)
	-- 	Game:add(FX)
	-- 	FX:setMaxSize(16,24)
	-- 	FX.sprite:setAnimation(math.random(1,4),1,5)
	-- 	FX:setDepth(9000)
	-- 	angle = angle +  math.random(math.pi, math.pi * 2)
	-- 	FX:setAngle(angle)
	-- 	local speed = math.random(1,2)
	-- 	FX:setSpeed(speed * math.cos(angle),speed * math.sin(angle))
	-- end
end

return ObjChar
