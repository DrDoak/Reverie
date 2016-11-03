-- A variation of the dialog class that does not pause the game but is instead overlapped on top
-- local Gamestate = require "hump.gamestate"

local Scene = require "xl.Scene"
local Transformable = require "xl.Transformable"

local TextEngine = require "xl.TextEngine"
local Keymap = require "xl.Keymap"
local TextBox = require "xl.TextBox"
local ClickText = require "mixin.ClickText"
 
local DialogActive = Class("DialogActive")
DialogActive.__lt = Scene.lessThan
DialogActive.__le = Scene.lessThan
DialogActive.setPosition = Transformable.setPosition

local EMPTY = {}
local font = xl.getFont( 20 )
local TB_Size

do
local inset = 5
TB_Size = {
	x = inset,
	y = inset,
	w = GAME_SIZE.w - inset,
	h = (GAME_SIZE.h / 4) - inset,
}
end

function DialogActive:init( items , source, interactor, parent)
	assert(type(items)=="table", "'items' must be a table")
	self.items = items
	self.index = 1
	--Gamestate.pop()
	self.z = 9000
	self.fgcolor = { 255, 255, 255 }
	self.selcolor = { 255, 255, 0 }
	Scene.makeNode( self )
	self:_processOptions( items )
	if Game.DialogActive then
		Game.DialogActive:endDialog()
	end
	Game.DialogActive = self
	self.source = source
	self.interactor = interactor
	self.parent = parent
	-- Game.scene:insert(self)
end

-- function DialogActive:create()
-- end

function DialogActive:_processOptions( items )
	-- deal with the title
	if items.title then
		local title = items.title
		if type(title) ~= "table" then
			title = { title }
		end
		self.textbox = TextBox( title, TB_Size.w, TB_Size.h, font , "center")
		self.textbox.x = TB_Size.x
		self.textbox.y = TB_Size.y
	else
		self.textbox = nil
	end

	-- now for the exit option
	self.exit = nil
	if items.exit then
		local ty = type( items.exit )
		if ty == "number" and items[items.exit] then
			self.exit = items[items.exit]
		elseif ty == "function" then
			self.exit = { action = items.exit }
		elseif ty == "table" and items.exit.action then
			self.exit = items.exit
		end
	end

	-- deal with the dialog body
	local height = font:getHeight() * ( #items + 2 )
	local width = 0
	for k,v in ipairs(items) do
		local w = font:getWidth( v.text )
		if w > width then
			width = w
		end
	end
	width = width + 20
	
	self.box = {
		x = (GAME_SIZE.w / 2) - (width / 2),
		y = (GAME_SIZE.h / 2) - (height / 2),
		w = width,
		h = height,
	}
	self.boxData = TextBox.BuildBackgroundData( width, height )
end

function DialogActive:update( dt )
	-- if self.suspended then
	-- 	lume.trace("suspended: ", self.currentElement)
	-- 	if self.currentElement.destroyed then
	-- 		self:continueDialogue()
	-- 	end
	--else
		self:keypressed()
	--end
end

-- function DialogActive:tick( dt )
-- 	-- body
-- end

function DialogActive:draw( )
	if self.textbox then
		self.textbox:draw()
	end

	love.graphics.setFont( font )
	local height = font:getHeight()
	local midX = GAME_SIZE.w / 2
	local y = GAME_SIZE.h / 2 - (height * #self.items / 2)

	Game:nocamera( true )
	love.graphics.push()
	love.graphics.translate( self.box.x, self.box.y )
	love.graphics.setColor(0,0,0,150)
	TextBox.drawBackgroundData( self.boxData )
	love.graphics.pop()

	for k,v in ipairs(self.items) do
		local text = v.text
		local width = font:getWidth( text )
		local x = midX - (width / 2)
		love.graphics.setColor( k == self.index and self.selcolor or self.fgcolor )
		love.graphics.printf( text, x, y, width, "center" )
		y = y + height
	end
	love.graphics.setColor( 255,255,255 )
	Game:nocamera( false )
end

function DialogActive:keypressed()
	if Keymap.isPressed( "menuUp" ) then
		self.index = self.index > 1 and self.index - 1 or #self.items
	end
	if Keymap.isPressed( "menuDown" ) then
		-- lume.trace()
		self.index = self.index < #self.items and self.index + 1 or 1
	end
	if Keymap.isPressed( "menuEnter" ) or Keymap.isPressed("interact") then
		self:_tryUse( self.items[ self.index ] )
	end
	if Keymap.isPressed( "exit" ) and self.exit then
		self:_tryUse( self.exit )
	end
end

function DialogActive:_tryUse( item )
	-- if the action returns true we don't pop
	if item.action then
		if not item.action( unpack( item.args or EMPTY ) ) then
			self:endDialog()
		end
	end
	if item.response or item.aside then
		self.currentElement = (item.response or item.aside)
		local ObjDialogSequence = require "objects.ObjDialogSequence"
		if type(self.currentElement) == "string" then
			self.currentElement = {self.currentElement} --ClickText(self.currentElement,nil,nil,true)
			--Game:add(self.currentElement)
		end
		--elseif type(self.currentElement) == "table" then
		self.currentElement = ObjDialogSequence(self.source,self.interactor,self.currentElement,self)
		Game:add(self.currentElement)
		--end
		if item.aside then
			self.toSuspend = true
		end
		self:endDialog()
	end
	if not item.response and not item.aside then
		Log.warn( "action = nil for option \"" .. item.text .. "\"" )
		self:endDialog()
	end
end

function DialogActive:setText( text )
	lume.trace( text)
	self.textbox:setText( text )
	self.textbox:update()
end

function DialogActive:endDialog()
	if self.toSuspend then
		self:suspendDialogue()
	else
		self.destroyed = true
		Game.DialogActive = nil
		Game.scene:remove(self)
		if self.parent and not self.parent.destroyed then
			self.parent:continueDialogue()
		end
	end
end

function DialogActive:suspendDialogue()
	Game.DialogActive = nil
	Game.scene:remove(self)
	self.suspended = true
	lume.trace("Suspending dialogue")
end

function DialogActive:continueDialogue( )
	lume.trace("continueDialogue")
	-- self:_processOptions( items )
	if Game.DialogActive then
		Game.DialogActive:endDialog()
	end
	Game.DialogActive = self
	self.toSuspend = false
	self.suspended = false
	Game.scene:insert(self)
end

return DialogActive
