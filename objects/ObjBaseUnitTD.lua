local ObjBase = require "ObjBase"
local ObjBaseUnitTD = Class.create("ObjBaseUnitTD", ObjBase)
	
	function ObjBaseUnitTD:create()
		self:addModule(require "modules.ModActive") 
		self:addModule( require "modules.ModPhysicsTD")
		self:addModule(require "modules.ModDrawableTD")
	end

return ObjBaseUnitTD
