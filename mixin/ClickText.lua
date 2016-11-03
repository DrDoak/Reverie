local FXBase = require "objects.fx.FXBase"
local Keymap  = require "xl.Keymap"
local ClickText = Class.create("ClickText", FXBase)
local TextBox = require "xl.TextBox"
local Text = require "xl.Text"
local Scene = require "xl.Scene"

--[[
Description: An Object that displays text upon interaction
Tiled Map Requirements: Object cannot be created via tiled.
Required Parameters:
"text": string: the text the box wants to display
Optional Parameters:
"time": how long the textbox lasts before dissapearing. Default: 3 seconds.

]]

function ClickText:init(text, key, fadeSpeed, box)
	self.text = text
	self.key = key or "interact"
	self.fs = fadeSpeed or 30
	self.box = (box == true)
	-- lume.trace(self.key)
end

function ClickText:create()
	if not self.text then
		self.text = "Error!!! Text Parameter not defined"
	end
	if not self.text_delay then self.text_delay = 1 end
	self.depth = 10000
	if self.box then
		self.textbox = TextBox({ {align="center"}, self.text }, 600, 100 ):setPosition(64, 2)
		self.textboxNode = Scene.wrapNode( self.textbox, self.depth )
	else
		self.textbox = Text(self.text, Game.cam.x,16)
		--self.textbox:setPtsize(20)
		self.textboxNode = Scene.wrapNode(self.textbox, self.depth)
	end		
	Game.hud:insert(self.textboxNode)

	if self.fs then
		self.alpha = 0
	else
		self.alpha = 150
		self.fs = 0
	end
	self.exclamation = xl.Sprite("assets/spr/fx/exclamation.png", 32, 32, 0, 10000)
	self.exclamation:setAnimation(1,1,1)
	self.exclamation:setOrigin(16,16)
	self.exclamationAdded = true
	self.displayExclamation = true
	Game.hud:insert(self.exclamation)
	self.exclamation:setPosition(632,68)
	self.timer = 10000
	self.textbox:setColor(0,0,0,self.alpha)
	if Game.DialogActive then
		Game.DialogActive:endDialog()
	end
	Game.DialogActive = self
	-- lume.trace("Creating new click text", self.destroyed)
end

function ClickText:tick(dt)
	Game.hud:move(self.exclamation, 10001)
	Game.hud:move(self.textboxNode, 10000)
	self.timer = self.timer - 1
	-- lume.trace(self.timer)
	local exSize = math.max(math.min(10100-self.timer,32),1)
	self.exclamation:setSize(exSize,exSize)
	if Keymap.isPressed(self.key) then
		lume.trace("Key Pressed")
		self.timer = 0
	end
	if self.timer >= 0 then
		self.alpha = math.min(self.alpha + self.fs, 220)
		self.textbox:setColor(0,0,0,self.alpha)
	else
		if self.fs == 0 then self.alpha = 0 end
		self.alpha = math.max(self.alpha - self.fs, 0)
		self.textbox:setColor(0,0,0,self.alpha)
		-- lume.trace(self.alpha)
		if self.alpha == 0 then
			self.textbox = nil
			-- error()
			Game:del(self)
		end
	end
end

function ClickText:setPosition( x , y ,depth )
	self.textbox:setPosition( x , y , depth or self.depth)
end

function ClickText:setPtSize(size)
	self.textbox:setPtsize(size)
end

function ClickText:destroy( )
	-- lume.trace("Being destroyed?")
	-- error()
	self.destroyed = true
	Game.DialogActive = nil
	Game.hud:remove(self.textboxNode)
	Game.hud:remove(self.exclamation)
end

function ClickText:endDialog()
	lume.trace("ending dialog")
	self.timer = 0
end

return ClickText