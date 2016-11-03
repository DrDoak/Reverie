

local Component = require "xl.gui.Component"
local Button = Class.create("Button", Component)

function Button:init(text)
	self:setText(text)
end

function Button:update()
	Component.update(self)
	local x,y = love.mouse.getPosition()
	if self:isInBounds(x,y) then
	end
end

function Button:mousepressed(x,y,button)

end

function Button:setText(t)
	self._text = t
end

function Button:getText()
	return self._text
end

function Button:paintComponent()
	
end


