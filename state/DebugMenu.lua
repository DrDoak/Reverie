local gamestate = require "hump.gamestate"
local BasicMenu = require "xl.BasicMenu"
local SaveIO = require "SaveIO"
local JBase = require "state.Journal.JBase"

local Items = {
	{
		text = "Save",
		action = function ()
			Game.savedata["plyrX"] = Game.player.x
			Game.savedata["plyrY"] = Game.player.y			
			Game.player:setPosition( 2, 3 )
			if Game.player.currentEquip then
				Game.player.currentEquip:drop()
			end
			Game.savedata["saveRoom"] = Game.roomname
			Game:loadRoom("assets/rooms/saveRoom")
			SaveIO.save_game(1)
		end,
		args = { 1 },
	},
	{
		text = "Load",
		action = SaveIO.load_game,
		args = { 1 },
	},
	{
		text = "Toggle Lights",
		action = function (  )
			Game.lights.enabled = not Game.lights.enabled
		end
	},
	{
		text = "Toggle DScreen",
		action = xl.DScreen.toggle,
	},
	{
		text = "Open Journal",
		action = function ( )
			if Game.WorldManager.Journal then
				gamestate.push(JBase)
			end
			return true
		end 
	},
	{
		text = "Back",
		action = function (  )
		end
	}
}

local DebugMenu = BasicMenu.new( Items, BasicMenu.BW_PALLET )
return DebugMenu
