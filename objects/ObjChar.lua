local ObjBaseUnitTD = require "objects.ObjBaseUnitTD"
local Inventory = require "xl.Inventory"
-- local Sound = require "xl.Sound"

local ObjChar = Class.create("ObjChar", ObjBaseUnitTD)
--util.transient( ObjChar, "healthbar", "guardbar" , "equipIcons" , "equipIcon2" , "sprite")

-- Initializes values of ObjChar, only runs once at the start of the game
-- sets up values which initial conditions
function ObjChar:init( )
	-- inventory initialization
	self.inventory = Inventory(3,3)

	-- init other data
	self.max_health = 100
	self.health = 100

	--initialize movement data
	self.maxJumpTime = 9
	self.currentJumpTime = 0
	self.jumpSpeed = 990
	self.maxAirJumps = 1
	self.airJumps = 0
	self.deceleration = -9
	self.maxSpeed = 6 * 32
	self.acceleration = 20 * 32
	self.currentEquips = {}
	self.currentPrimary = nil
	self.x = 0
	self.y = 0
	self.persistent = true
	self.attackTimer = 0
	-- self.charHeight = 22
	self.canControl = true
	self.deflectable = true

	self.inventoryLocked = self.inventoryLocked or false
	self.faction = "player"
	Game.savedata["count_deaths"] = 0
end

--Initializes values of ObjChar which will occur at the beginning of every room
--Recreates b2 body in every room.
function ObjChar:create()
	ObjBaseUnitTD.create(self)

	self:addModule(require "modules.ModControllable")
	
	-- self:addSpritePiece(require("assets.spr.scripts.SprLegPeridot"))
	-- self:addSpritePiece(require("assets.spr.scripts.SprBodyPeridot"))
	-- self:addSpritePiece(require("assets.spr.scripts.SprHeadPeridot"))
	self:addSpritePiece(require("assets.spr.scripts.SprLegBoots"))
	self:addSpritePiece(require("assets.spr.scripts.SprBodyUniform"))
	self:addSpritePiece(require("assets.spr.scripts.SprHeadGeneric"))
	self:addSpritePiece(require("assets.spr.scripts.SprHatHelmet"))

	self:setDepth(self.depth or 5000)
	
	--if set to true, the game will maintain a hitbox that displays "!" when
	-- near an interactable object (NOT IMPLEMENTED)
	-- self.detectBox = true

	Game:setPlayer(self)

	--initialize player hitboxes
	self:createBody( "dynamic" ,true, true)
	self.shape = love.physics.newRectangleShape(12, 4)
	self.shapeCrouch = love.physics.newRectangleShape(8,20)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self:setFixture(self.shape, 22.6) 
	self.fixture:setCategory(CL_CHAR)
	self.name = "Mr Character"
	self:addNewCharacterInfo("Test Character")

	--initialize Inventory

	-- self:addModule(require "modules.ModInventory")
	-- self:setEquipCreateItem("ObjTorch")
	self:setEquipCreateItem("EqpHandgun")
end

--
function ObjChar:die()
	self.isAlive = false
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

return ObjChar
