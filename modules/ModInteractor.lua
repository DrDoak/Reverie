local ObjIntHitbox = require "objects.ObjIntHitbox"
local ModInteractor = Class.create("ModInteractor", Entity)

ModInteractor.dependencies = {"ModActive"}
ModInteractor.trackFunctions = {"processDialog","onInteractionWithObject"}

function ModInteractor:createIntHitbox()
	local intHitbox = ObjIntHitbox(self) 
	Game:add(intHitbox)
end

function ModInteractor:processDialog( dialog )
	-- body
end

function ModInteractor:onInteractionWithObject( otherObject )
	lume.trace()
	-- body
end
return ModInteractor