
local Text = require "xl.Text"
local Transformable = require "xl.Transformable"
local Notification = Class.create("Notification", Entity)

-- function which creates a default font
function Notification:init()
end

function Notification:addMessage( msg )
	self.string = msg
	self.text = Text(self.string,128,32,9000)
	self.textNode = Scene.wrapNode( self.text, 10000 )
	Game.hud:insert(self.textNode)
end
function Notification:update(dt)

end

return Text
