local ObjBase = require "ObjBase"
local ObjGenericObj = Class.create("ObjGenericObj", ObjBase)
	
function ObjGenericObj:create()
	self:addModule(require "modules.ModActive")
	self:addModule(require "modules.ModTDObj")
	self:matchBodyToSpr(require(self.image or "assets.spr.scripts.SprCrate3D"))
	self:setMaxHealth(100)
end

return ObjGenericObj