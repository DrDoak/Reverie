
local Gamestate = require "hump.gamestate"
local Keymap = require "xl.Keymap"
local font = xl.getFont( 30 )

local function __NULL__(  ) end
local BasicMenu = {}

function BasicMenu:enter( previous )
	self.previous = previous
	love.keyboard.setKeyRepeat( true )
	self.old_bgcolor = {love.graphics.getBackgroundColor()}
	love.graphics.setBackgroundColor( self.bgcolor )
end

function BasicMenu:leave(  )
	love.keyboard.setKeyRepeat( false )
	love.graphics.setBackgroundColor( self.old_bgcolor )
end

function BasicMenu:update( dt )
end

function BasicMenu:draw()
	local loveGraphics = love.graphics
	local numItems = #self.items
	local height = font:getHeight()
	local midX = loveGraphics.getWidth() / 2
	local y = loveGraphics.getHeight() / 2 - (height * numItems / 2)
	--Draw the game in the background
	if self.previous ~= self and Game.player then
		self.previous:draw()
		loveGraphics.setColor(0,0,0,200)
		loveGraphics.rectangle("fill",0,0,loveGraphics.getWidth(),loveGraphics.getHeight())
	end

	loveGraphics.setFont( font )
	for k=1,numItems do
		local text = self.items[k].text
		local width = font:getWidth( text )
		local x = midX - (width / 2)
		loveGraphics.setColor( k == self.index and self.selcolor or self.fgcolor )
		loveGraphics.printf( text, x, y, width, "center" )
		y = y + height
	end
	loveGraphics.setColor( 255,255,255 )
end

local EMPTY = {}

function BasicMenu:keypressed( key, isrepeat )
	if Keymap.check( "up", key ) then
		self.index = self.index > 1 and self.index - 1 or #self.items
	end
	if Keymap.check( "down", key ) then
		self.index = self.index < #self.items and self.index + 1 or 1
	end
	if Keymap.check( "use", key ) then
		local item = self.items[self.index]
		-- if the action returns true we don't pop
		if not item.action( unpack( item.args or EMPTY ) ) then
			Gamestate.pop()
		end
	end
	if Keymap.check( "exit", key ) then
		if not (self.exit or __NULL__)(self) then
			Gamestate.pop()
		end
	end
end

local function new( items, bgcolor, fgcolor, selcolor)
	if type( bgcolor[1] ) == "table" then
		bgcolor,fgcolor,selcolor = unpack( bgcolor )
	end
	local self = {
		index = 1,
		items = items,
		bgcolor = bgcolor,
		fgcolor = fgcolor,
		selcolor = selcolor,
	}
	Class.include( self, BasicMenu )
	return self
end

local GREEN_PALLET = {
	{ 0x00, 0x71, 0x43 },
	{ 0x00, 0xAE, 0x68 },
	{ 0x60, 0xD6, 0xA7 },
}

local BW_PALLET = {
	{ 0, 0, 0 ,255},
	{ 255, 255, 255 ,255},
	{ 255, 255, 0 ,255},
}

return {
	new = new,
	GREEN_PALLET = GREEN_PALLET,
	BW_PALLET = BW_PALLET,
}


