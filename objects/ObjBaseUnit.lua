local ObjBase = require "ObjBase"
local ObjBaseUnit = Class.create("ObjBaseUnit", ObjBase)
	
	function ObjBaseUnit:create()
		self:addModule(require "modules.ModActive") 
		self:addModule( require "modules.ModPhysics")
		self:addModule(require "modules.ModDrawable")
	end

return ObjBaseUnit
