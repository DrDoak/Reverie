
local BasicMenu = require "xl.BasicMenu"
local SaveIO = require "SaveIO"

local function goto_room( name )
	Game:loadRoom( name )
end

local Items = {
	{
		text = "Load Game",
		action = SaveIO.load_game,
		args = { 1 },
	},
	{
		text = "New Game",
		action = goto_room,
		args = { "assets/rooms/initial_room" },
	},
	{
		text = "Debug Room",
		action = goto_room,
		args = { "assets/rooms/test_roomS" },
	},
	{
		text = "Rotating Test Room",
		action = goto_room,
		args = { "assets/rooms/initial_room2" },
	},
	{
		text = "Random Generation Test",
		action = goto_room,
		args = { "assets/rooms/RandGen_test" },
	},
}

local MainMenu = BasicMenu.new( Items, BasicMenu.GREEN_PALLET )

function MainMenu:exit(  )
	love.event.quit()
	return true
end


local function draw_text( text, align, x, y, offx, offy, font )
	local width,lines = font:getWrap( text, 9999 )
	local height = lines * font:getHeight()
	local ox = x + (width * offx)
	local oy = y + (height * offy)
	love.graphics.setFont( font )
	love.graphics.printf( text, ox, oy, width, align )
end

local function draw_text_centered( text, x, y, font )
	draw_text( text, "center", x, y, -0.5, -0.5, font )
end

return MainMenu
