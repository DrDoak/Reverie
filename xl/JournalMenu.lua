--------------------------------------
-- A gamestate that contains the interface for accessing the "Journal"
-- Which is used for keeping track of collectible bits of information
-- as well as used for casting "sentiments" or spells when in the SS world
------------------------------------------------------------------

local gamestate = require "hump.gamestate"
local Keymap = require "xl.Keymap"
local TextBox = require "xl.TextBox"
local Scene = require "xl.Scene"
local EMPTY = {}
local font = xl.getFont( 20 )

local function __NULL__(  ) end
local JournalMenu = {}

--A create function that initializes the JournalState when called
function JournalMenu:enter( previous, npc)
	self.previousStates = {} --A table which will contian references to the previous gamestates
	--The following code sets references to previous states, as well as the "realState" or a reference
	-- to the default gamestate.
	self.realState = previous.realState or previous.previous or previous
	table.insert(self.previousStates, self.realState)
	if self.position == "mid" then
		table.insert(self.previousStates, previous)
	end
	if self.position == "right" then
		table.insert(self.previousStates, previous)
		table.insert(self.previousStates, previous.previous)
	end

	self.npc = npc --The Journal system is used when you are speaking to NPCs, this is a reference to the NPC
	love.keyboard.setKeyRepeat( true )
	self.old_bgcolor = {love.graphics.getBackgroundColor()}
	love.graphics.setBackgroundColor( self.bgcolor )
	self.description = ""
	self:displayText(self.description)
end

--A cleanup function for when the state is exited.
function JournalMenu:leave( )
	love.keyboard.setKeyRepeat( false )
	love.graphics.setBackgroundColor( self.old_bgcolor )
end

function JournalMenu:update( dt )
end

--Draws the menu, along with previous Game sttates in the background.
function JournalMenu:draw()
	local loveGraphics = love.graphics
	local numItems = #self.items
	local height = font:getHeight()
	local midX = loveGraphics.getWidth() / 2
	local y = loveGraphics.getHeight() / 2 - (height * numItems / 2)

	--Draw any previous states in the background
	if self.previousStates then
		for i=1,#self.previousStates do
			self.previousStates[i]:draw()
		end
		loveGraphics.setColor(0,0,0,120)
		loveGraphics.rectangle("fill",0,0,loveGraphics.getWidth(),loveGraphics.getHeight())
	end

	--Display the text of the menu
	loveGraphics.setFont( font )
	for k=1,numItems do
		local text = self.items[k].text
		local learned = Game.WorldManager.Journal[text]
		local width = font:getWidth( text )
		local x
		if self.position == "left" then
			x = 0
		elseif self.position == "mid" then
			x = 200
		else
			x = 400
		end
		if learned then
			loveGraphics.setColor( k == self.index and self.selcolor or self.fgcolor )
			loveGraphics.printf( text, x, y, width, "left" )
			self:drawIcon(self.items[k], x, y)
			y = y + height
		end
	end

	self.textbox:draw()
	loveGraphics.setColor( 255,255,255 )
end

function JournalMenu:drawIcon(item, x, y)
	if Game.spellList[item.text] then
		local icon = love.graphics.newImage("assets/HUD/icons/default.png")
		if Game.usedSpellList[item.text] then
			love.graphics.setColor(50,50,50,255)
		end
		love.graphics.draw( icon, x - 32, y - 4)
		love.graphics.setColor(255,255,255,255)
	end
end

-- Displays the textbox with appropriate descriptive
function JournalMenu:displayText( text )
	self.textbox = TextBox({ {align="center"}, text }, 496, 128 ):setPosition(2, 2)
	self.textboxNode = Scene.wrapNode( self.textbox, 10000 )
end

function JournalMenu:keypressed( key, isrepeat )
	if Keymap.check( "up", key ) then
		--first move the index one upward
		self.index = self.index > 1 and self.index - 1 or #self.items
		--keep flipping through the index until you find something that is learned
		while (not Game.WorldManager.Journal[self.items[self.index].text]) do
			self.index = self.index > 1 and self.index - 1 or #self.items
		end
	end
	if Keymap.check( "down", key ) then
		self.index = self.index < #self.items and self.index + 1 or 1
		while (not Game.WorldManager.Journal[self.items[self.index].text]) do
			self.index = self.index < #self.items and self.index + 1 or 1
		end
	end
	if Keymap.check( "use", key ) then
		local item = self.items[self.index]
		--If we are interacting with an NPC and on the "topic" or "mid" level, let the NPC respond.
		if self.npc and self.position ~= "left" and item.text ~= "Back" then
			if  self.npc.name == item.text then -- NPCs get more specific responses for themselves
				gamestate.push(item.subTree , self.npc)
			else
				gamestate.pop()
				gamestate.pop()
				self.npc:respond(item.text)
			end
		else --Otherwise, look at the subtree, and open the submenu
			if item.subTree then
				gamestate.push(item.subTree , self.npc)
			end
		end

		-- Perform any special action if needed. If action returns true don't pop
		if item.action and not item.action( unpack( item.args or EMPTY ) ) then
		 	gamestate.pop()
		end
		-- Check for a spell and cast if possible
		self:useSpell(item.text)
	end
	if Keymap.check( "exit", key ) then
		if not (self.exit or __NULL__)(self) then
			gamestate.pop()
		end
	end
	--display description if the object has one
	if self.items and self.items[self.index].description then
		self:displayText(self.items[self.index].description)
	else
		self:displayText("")
	end
end

-- Checks whether the item highlighted as a possible spell in the current SS World
-- if there is one, this will pop out of the Journal Menu and call the spell
function JournalMenu:useSpell( topic )
	if self.position == "right" and Game.looptype == "side" and Game.spellList then
		local spellList = Game.spellList
		-- if the character has a responses specific to the topic, then run the dialogue for that topic
		if spellList[topic] and not Game.usedSpellList[topic] then
			for i=1,(#self.previousStates+1) do
				gamestate.pop()
			end
			Game.player:castSpell(spellList[topic])
			Game.usedSpellList[topic] = true
			return true
		else
			return false
		end
	else
		return false
	end
end

--Initialization function for the list.
local function new( items, bgcolor, position)
	local fgcolor, selcolor
	if type( bgcolor[1] ) == "table" then
		bgcolor,fgcolor,selcolor = unpack( bgcolor )
	end
	local self = {
		index = 1,
		items = items,
		bgcolor = bgcolor,
		fgcolor = fgcolor,
		selcolor = selcolor,
		position = position,
	}
	Class.include( self, JournalMenu )
	return self
end

local BW_PALLET = {
	{ 0, 0, 0 ,255},
	{ 255, 255, 255 ,255},
	{ 255, 255, 0 ,255},
}

return {
	new = new,
	BW_PALLET = BW_PALLET,
}