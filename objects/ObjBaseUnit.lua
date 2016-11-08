local ModuleTest = require "objects.ModuleTest"
local ObjBaseUnit = Class.create("ObjBaseUnit", ModuleTest)
	
	function ObjBaseUnit:create()
		local drawable = require "modules.ModDrawable"
		self:addModule(drawable)
		local active = require "modules.ModActive"
		self:addModule(active)
		local body = require "modules.ModPhysics"
		self:addModule(body)
		local inv = require "modules.ModInventory"
		self:addModule(inv)
	end

return ObjBaseUnit
