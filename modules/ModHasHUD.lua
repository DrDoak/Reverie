local ModHasHUD = Class.create("ModHasHUD", Entity)
local Healthbar = require "mixin.Healthbar"
local EquipIcon = require "mixin.EquipIcon"
local TextInterface = require "mixin.TextInterface"


function ObjChar:setHealth( health ,redHealth)
	health = math.min( health, self.max_health )
	self.healthbar.redValue = redHealth or health
	self.healthbar.value = health
	ObjBaseUnit.setHealth(self,health)
end

function ObjChar:setGuard( guard )
	guard = math.min( guard, self.maxShield )
	guard = math.max(guard, 0)
	self.shield = guard
	self.guardbar.value = guard
end


return ModHasHUD