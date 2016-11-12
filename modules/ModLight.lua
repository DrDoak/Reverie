local ModLight = Class.create("ModLight", Entity)

local Lights = require "xl.Lights"

function ModLight:create()
	self.lights = {}
end

function ModLight:tick( dt )
	for key, piece in pairs( self.lights ) do
		self.lights[key].light:setPosition(x + self.lights[key].offsetX,y + self.lights[key].offsetY)
	end
end

function ModLight:addLight( lightName, x,y,radius, r,g,b)
	local lights = Lights.newGradSpotLight((radius or 32),8,270)
	lights:setPosition(self.x, self.y)
	lights:setColor((r or 1),(g or 1),(b or 1))
	Game.lights:add(lights)
	local table = {
	light = lights,
	offsetX = x or 0,
	offsetY = y or 0
	}
	self.lights[lightName] = table
end

function ModLight:delLight( lightName )
	if self.lights[lightName] then
		Game.lights:del(self.lights[lightName].light)
		self.lights[lightName] = nil
	end
end


end