local ModPlanning = Class.create("ModPlanning",Entity)

function ModPlanning:create()
	self.currentPlan = {}
end
function ModPlanning:tick( dt )
	self:executePlan()
end
function ModPlanning:executePlan()
	
end
function ModPlanning:setCurrentPlan()
	-- body
end
return ModPlanning