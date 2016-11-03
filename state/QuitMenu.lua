
local BasicMenu = require "xl.BasicMenu"

local Items = {
	{
		text = "Yes",
		action = function (  )
			love.event.quit()
			return true -- return true so we don't pop the gamestate and quit actually gets called
		end
	},
	{
		text = "No",
		action = function (  )
		end
	}
}

local menu = BasicMenu.new( Items, BasicMenu.GREEN_PALLET )
return menu
