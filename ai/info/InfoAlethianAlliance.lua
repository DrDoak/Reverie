local InfoAlethianAlliance = Class.create("InfoAlethianAlliance",Entity)

function InfoAlethianAlliance:identifyTags( eventName, tags, params )
	local tags = {	}
	if params.other and self:identifyAlliance(other) == "Alethia" then
		tags["threat"] = -0.5
		tags["trust"] = 1.0
	end
	return tags
end

-- function InfoAlethianAlliance:tagResponseFunction(params,tagName,eventTags,aiPiece)
-- 	self:proposeAction( InfoAlethianAlliance.actionFunction, params, "askForName")
-- end

-- function InfoAlethianAlliance:actionFunction( score, params )
-- 	-- body
-- end

-- InfoAlethianAlliance.tagResponses = {
-- 	{InfoAlethianAlliance.tagResponseFunction,"stranger"}
-- }
return InfoAlethianAlliance