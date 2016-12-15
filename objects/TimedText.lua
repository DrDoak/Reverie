--local FXBase = require "objects.fx.FXBase"
local TimedText = Class.create("TimedText", Entity)
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

function TimedText:init(text, time, fadeSpeed, hasTextbox)
	self.text = text
	self.timer = time or 2.4 * #self.text 
	self.fs = fadeSpeed or 30
	self.box = (hasTextbox == true)
end

function TimedText:create()
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
		self.alpha = 220
		self.fs = 0
	end
	self.textbox:setColor(255,255,255,self.alpha)
end

function TimedText:tick(dt)
	Game.hud:move(self.textboxNode, 10000)
	self.timer = self.timer - 1
	if self.timer >= 0 then
		self.alpha = math.min(self.alpha + self.fs, 220)
		self.textbox:setColor(255,255,255,self.alpha)
	else
		if self.fs == 0 then self.alpha = 0 end
		self.alpha = math.max(self.alpha - self.fs, 0)
		self.textbox:setColor(255,255,255,self.alpha)
		if self.alpha == 0 then
			self.textbox = nil
			Game:del(self)
		end
	end
end

function TimedText:setPosition( x , y ,depth )
	self.textbox:setPosition( x , y , depth or self.depth)
end

function TimedText:setPtSize(size)
	self.textbox:setPtsize(size)
end

function TimedText:destroy( )
	Game.hud:remove(self.textboxNode)
end

return TimedText