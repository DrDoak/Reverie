local zzz = Class.create("zzz",Entity)

function zzz:identifyTags( eventName, tags, params )
	local tags = {	}
	return tags
end

function zzz:tagResponseFunction(params,tagName,eventTags,aiPiece)
	self:proposeAction( zzz.actionFunction, params, "askForName")
end

function zzz:actionFunction( score, params )
	-- body
end

zzz.tagResponses = {
	{zzz.tagResponseFunction,"stranger"}
}
return zzz