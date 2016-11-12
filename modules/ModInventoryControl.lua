local ModInventoryControl = Class.create("ModInventoryControl", Entity)
local Keymap  = require "xl.Keymap"
local InventoryMenu = require "state.InventoryMenu"
local Inventory = require "xl.Inventory"

function ModInventoryControl:create(  )
	self.keyItemList = self.keyItemList or {}
	self.canPressUse = true
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
end
return ModInventoryControl