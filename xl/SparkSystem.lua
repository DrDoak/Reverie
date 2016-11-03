
local Lights = require "Lights"

local SS = {}
SS.__index = SS

function SS:update(dt)
	for k,v in pairs(self.sparks) do
		v.radius = v.radius - v.step * dt
		if v.radius < 0.1 then self.sparks[k] = nil end
	end
end
function SS:draw()
	for k,v in pairs(self.sparks) do v:draw() end
end
function SS:newSpark(x, y, radius, seconds)
	local spark = Lights.newAreaLight(x, y, radius)
	spark.step = radius / seconds
	self.sparks[self.nextID] = spark
	self.nextID = self.nextID + 1
	return spark
end

local function new()
	local obj = { sparks = {}, nextID = 1 }
	return setmetatable(obj, SS)
end

return {
    new = new
}
