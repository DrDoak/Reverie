local gamestate = require "hump.gamestate"
local BasicMenu = require "xl.BasicMenu"
-- local SaveIO = require "SaveIO"

local Items = {
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
		text = "Back",
		action = function (  )
		end
	}
}

local DebugMenu = BasicMenu.new( Items, BasicMenu.BW_PALLET )
return DebugMenu
