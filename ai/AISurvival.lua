local AISurvival = Class.create("ModCharacter", Entity)
AISurvival.trackFunctions("evaluateThreat")
function AISurvival:create( player )
	local ai = "AISurvival"

	self.threatTags = {}
	self:runOnTag(self.evaluateThreat,ai,"danger")
	self:addAIBit(ai)
end

function AISurvival:evaluateThreat( threatItem )
end

function AISurvival:respondToThreat( params,tagName,eventTags,aiPiece)
	self:proposeAction(AISurvival.fightResponse,params,"fight")
	self:proposeAction(AISurvival.flightResposne,params,"flight")
end

function AISurvival:fightResponse( score, params )
	-- body
end

function AISurvival:flightResposne( score, params )
	-- body
end

AISurvival = {
	{AISurvival.respondToThreat,"threat"}
}

return AISurvival