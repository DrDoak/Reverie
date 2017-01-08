local InfoPistols = Class.create("InfoPistols",Entity)

InfoPistols.dependencies = {"AISurvival"}

function InfoPistols:calculateThreat( obj )
	if obj.type == "ObjPistol" then
		return 1.0
	end
end

-- function InfoPistols:identifyTags( eventName, tags, params )
-- 	local tags = {	}

-- 	return tags
-- end

-- function InfoPistols:tagResponseFunction(params,tagName,eventTags,aiPiece)
-- 	self:proposeAction( InfoPistols.actionFunction, params, "askForName")
-- end

-- function InfoPistols:actionFunction( score, params )
-- 	-- body
-- end

-- InfoPistols.tagResponses = {
-- 	{InfoPistols.tagResponseFunction,"stranger"}
-- }
return InfoPistols