
local _NOOP = function () end

local ObjBase = Class.new {
	persistent = false,
	world = function () return Game.world end,
	type = "ObjBase",

	-- overridable methods
	create = _NOOP,
	draw = _NOOP,
	onCollide = _NOOP,
	postCollide = _NOOP,
}

function ObjBase:addModule( newModule )
	if not self.modules then self.modules = {} end
	if not self.removableModules then self.removableModules = {} end
	if not self.allFuncts then 
		self.allFuncts = {}
		self.allFuncts["create"]= {}
		self.allFuncts["create"]["default"] = self.create

		self.allFuncts["tick"]= {}
		self.allFuncts["tick"]["default"] = self.default

		self.allFuncts["destroy"]= {}
		self.allFuncts["destroy"]["default"] = self.destroy

		self.allFuncts["onRemove"]= {}
		self.allFuncts["onRemove"]["default"] = self.onRemove
	end
	if not self.overRideFuncts then
		self.overRideFuncts = {"create","tick","destroy","onRemove"}
	end
	local modName = newModule.type

	if newModule.dependencies then
		for i,v in ipairs(newModule.dependencies) do
			if not self:hasModule(v) then
				-- lume.trace("module: ",v,"added through dependency to module: ", modName)
				local dependencyPath = "modules." .. v
				self:addModule(require(dependencyPath))
			end
		end
	end

	if newModule.trackFunctions then
		for i,v in ipairs(newModule.trackFunctions) do
			if not self.allFuncts[v] then
				self:trackFunction(v)
			end
		end
	end

	for i,v in ipairs(self.overRideFuncts) do
		if newModule[v] then
			if not self.allFuncts[v] then
				self.allFuncts[v] = {}
			end
			self.allFuncts[v][modName] = newModule[v]
		end
	end
	Class.include(self,newModule)

	if newModule.create then
		newModule.create(self)
	end
	if newModule.onRemove then
		self.allFuncts["onRemove"][modName] = newModule.onRemove
	end

	for i,v in ipairs(self.overRideFuncts) do
		local function iterateFunctions( self, ... )
			local returnVals = {}
			if self.allFuncts[v] then
				for k,funct in pairs(self.allFuncts[v]) do
					if funct then
						local ret = funct(self,...)
						if ret then
							table.insert(returnVals,ret)
						end
					end
				end
			end
			return returnVals
		end
		--local funct = lume.fn(iterateFunctions, self)
		self[v] = iterateFunctions
	end
	self.modules[modName] = true
	if newModule.removable then
		self.removableModules[modName] = true
	end
end

function ObjBase:hasModule( modName )
	return self.modules[modName]
end

function ObjBase:removeModule(modName )
	if self.allFuncts["onRemove"] and self.allFuncts["onRemove"][modName] then
		self.allFuncts["onRemove"][modName](self)
	end
	for k,v in pairs(self.allFuncts) do
		v[modName] = nil
	end
	self.modules[modName] = nil
	self.removableModules[modName] = nil
end

function ObjBase:getModules()
	return self.modules
end

function ObjBase:getAllRemovableModules()
	local newTable = {}
	for k,v in pairs(self.removableModules) do
		table.insert(newTable,k)
	end
	return newTable
end

function ObjBase:trackFunction( functionName )
	table.insert(self.overRideFuncts,functionName)
	if self[functionName] and self[functionName] ~= _NOOP then
		if not self.allFuncts[functionName] then 
			self.allFuncts[functionName] = {}
		end
		self.allFuncts[functionName]["default"] = self[functionName]
	end

	local function iterateFunctions( self, ... )
		for k,funct in pairs(self.allFuncts[functionName]) do
			funct(self,...)
		end
	end
	self[functionName] = iterateFunctions
end

return ObjBase

