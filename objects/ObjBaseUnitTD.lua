local ObjBase = require "ObjBase"
local ObjBaseUnitTD = Class.create("ObjBaseUnitTD", ObjBase)
	
	function ObjBaseUnitTD:create()
		self:addModule(require "modules.ModDrawable")
		self:addModule(require "modules.ModActive") 
		self:addModule( require "modules.ModPhysics")
	end

return ObjBaseUnitTD
