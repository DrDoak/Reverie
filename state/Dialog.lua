
local Gamestate = require "hump.gamestate"
local TextEngine = require "xl.TextEngine"
local Keymap = require "xl.Keymap"
local TextBox = require "xl.TextBox"

local EMPTY = {}
local Dialog = {
	fgcolor = { 100, 100, 100 },
	selcolor = { 0, 0, 0 },
}
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

function Dialog:enter( previous, items , bkgState)
	assert(type(items)=="table", "'items' must be a table")
	self.items = items
	self.index = 1
	self.bkgState = bkgState or Game
	--Gamestate.pop()
	Game.dialogState = self
	self:_processOptions( items )
end

function Dialog:_processOptions( items )

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

function Dialog:update( dt )

end

function Dialog:draw( )
	self.bkgState:draw()

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

function Dialog:keypressed( key, isrepeat )
	if Keymap.check( "menuUp", key ) then
		self.index = self.index > 1 and self.index - 1 or #self.items
	end
	if Keymap.check( "menuDown", key ) then
		self.index = self.index < #self.items and self.index + 1 or 1
	end
	if Keymap.check( "menuEnter", key ) then
		self:_tryUse( self.items[ self.index ] )
	end
	if Keymap.check( "exit", key ) and self.exit then
		self:_tryUse( self.exit )
	end
end

function Dialog:_tryUse( item )
	-- if the action returns true we don't pop
	if item.action then
		if not item.action( unpack( item.args or EMPTY ) ) then
			Gamestate.pop()
		end
	else
		Log.warn( "action = nil for option \"" .. item.text .. "\"" )
		Gamestate.pop()
	end
end

function Dialog:setText( text )
	lume.trace(text)
	self.textbox:setText( text )
	self.textbox:update()
end

function Dialog.display( items , bkgState)
	Gamestate.push( Dialog, items, bkgState)
	--coroutine.yield( true )
end

return Dialog


