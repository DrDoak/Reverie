local AIOrder = Class.create("AIOrder", Entity)

AIOrder.trackFunctions("defyOrder")
function AIOrder:identifyTags( eventName, tags, params )
	local tags = {	}
	if util.sum(self:defyOrder(eventName,params)) > 0 then
	else
	end
	return tags
end

function AIOrder:defyOrder( eventName, params )
	return 0
end

return AIOrder