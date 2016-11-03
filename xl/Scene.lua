local skiplist = require("libs.skiplist")

local __NULL__ = function () end

local counter = util.counter()
local lessThan = function(a,b)
	if a.z < b.z then return true
	elseif a.z==b.z and a.id < b.id then return true
	else return false
	end
end
local MakeNode = function (obj)
	-- the id field is necessary because, otherwise, items on the same plane would cause troubles.
	obj = obj or {}
	obj.id = counter()
	return obj
end

local SceneMT = Class.create("Scene")
function SceneMT:init(estimate)
	self.zlist = skiplist.new(estimate)
	self.len = 0
end
function SceneMT:draw()
	for _,item in self.zlist:iter() do item:draw()end
end
function SceneMT:update(dt)
	for _,item in self.zlist:iter() do item:update(dt) end
end
function SceneMT:insert(obj)
	assert(obj and obj.z and obj.id, "Cannot insert object into depth list")
	self.zlist:insert(obj)
end
function SceneMT:remove(obj)
	assert(obj)
	self.zlist:delete(obj)
end
function SceneMT:move(obj, newZ)
	self:remove(obj)
	obj.z = newZ
	self:insert(obj)
end
function SceneMT:clear()
	for _,item in self.zlist:ipairs() do self.zlist:delete(item) end
end
function SceneMT:size()
	return self.zlist.size
end

local BasicNodeWrapper = Class.create("BasicNodeWrapper", nil, {
	__lt = lessThan,
	__le = lessThan,
	init = function (self, object, z)
		if type(object) == "function" then 
			self.draw, self.update = object, __NULL__
		else
			self.object = object
		end
		self.z = z
		MakeNode(self)
	end,
	draw = function (self)
		(self.object.draw or __NULL__)(self.object)
	end,
	update = function (self, dt)
		(self.object.update or __NULL__)(self.object, dt)
	end,
})

return {
	new = function (...) return SceneMT(...) end,
	lessThan = lessThan,
	makeNode = MakeNode,
	wrapNode = function (...) return BasicNodeWrapper(...) end
}
