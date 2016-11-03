
local _NOOP = function () end

local ModuleTest = Class.new {
	persistent = false,
	world = function () return Game.world end,
	type = "ModuleTest",

	-- overridable methods
	create = _NOOP,
	destroy = _NOOP,
	draw = _NOOP,
	onCollide = _NOOP,
	postCollide = _NOOP,
	createFuncts = {},
	destroyFuncts = {},
	drawFuncts = {},
	onCollideFuncts = {},
	modules = {}
}

function ModuleTest:tick( dt )
end

function ModuleTest:addModule( newModule )
	local modName = newModule.type
	if newModule.tick then
		self.tickFuncts[modName] = newModule.tick
	end
	if newModule.create then
		self.createFuncts[modName] = newModule.create
	end
	if newModule.destroy then
		self.destroyFuncts[modName] = newModule.destroy
	end
	if newModule.draw then
		self.drawFuncts[modName] = newModule.draw
	end
	if newModule.onCollide then
		self.onCollideFuncts[modName] = newModule.onCollide
	end
	Class.include(self,newModule)
	self.create = self.mCreate
	self.destroy = self.mDestroy
	self.draw = self.mDraw
	self.onCollide = self.mOnCollide
	self.tick = self.mTick
	self.modules[modName] = true
end

function ModuleTest:hasModule( modName )
	return self.modules[modName]
end

function ModuleTest:removeModule(modName )
	self.createFuncts[modName] = nil
	self.destroyFuncts[modName] = nil
	self.drawFuncts[modName] = nil
	self.onCollideFuncts[modName] = nil
	self.tickFuncts[modName] = nil
	self.modules[modName] = nil
end

function ModuleTest:getModules()
	return self.modules
end

function ModuleTest:mTick( dt )
	for k,v in pairs(self.tickFuncts) do
		v(self,dt)
	end
end

function ModuleTest:mCreate()
	for k,v in pairs(self.createFuncts) do
		v(self)
	end
end

function ModuleTest:mDestroy()
	for k,v in pairs(self.destroyFuncts) do
		v(self)
	end
end

function ModuleTest:mDraw()
	for k,v in pairs(self.drawFuncts) do
		v(self)
	end
end

function ModuleTest:mOnCollide(other, collision)
	for k,v in pairs(self.onCollideFuncts) do
		v(self,other,collision)
	end
end

return ModuleTest

