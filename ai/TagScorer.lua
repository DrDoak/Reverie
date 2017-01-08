local TagScorer = {}

function TagScorer:direct( actionName,tagName,tagValue,allTags, topic,score,weight)
	local offset = math.max(0, topic.acceptance * topic.relevance * tagValue * weight)
	return score + offset
end

function TagScorer:inverse( actionName,tagName,tagValue,allTags, topic,score,weight)
	local offset = math.max(0, -topic.baseAcceptance * topic.relevance * tagValue * weight)
	return score + offset
end

function TagScorer:directFull( actionName,tagName,tagValue,allTags, topic,score,weight)
	local offset = topic.acceptance * topic.relevance * tagValue * weight
	return score + offset
end

function TagScorer:inverseFull( actionName,tagName,tagValue,allTags, topic,score,weight)
	local offset = -topic.acceptance * topic.relevance * tagValue * weight
	return score + offset
end

function TagScorer:directMore( actionName,tagName,tagValue,allTags, topic,score,weight)
	local offset = topic.acceptance * topic.relevance * tagValue * weight
	if topic.acceptance < 0 then
		offset = offset * 0.5
	end
	return score + offset
end

function TagScorer:inverseMore( actionName,tagName,tagValue,allTags, topic,score,weight)
	local offset = topic.acceptance * topic.relevance * tagValue * weight
	if topic.acceptance > 0 then
		offset = offset * 0.5
	end
	return score + offset
end

function TagScorer:extremes( actionName,tagName,tagValue,allTags, topic,score,weight)
	local offset = math.abs(topic.acceptance * topic.relevance * tagValue * weight)
	return score + offset
end

function TagScorer:centers( actionName,tagName,tagValue,allTags, topic,score,weight)
	local maxValue = 100 * topic.relevance * tagValue * weight
	local offset = math.abs(maxValue - math.abs(topic.acceptance * topic.relevance * tagValue * weight))
	return score + offset
end

TagScorer.dom = 1.5
TagScorer.domNeg = -1.5
TagScorer.main = 1.0
TagScorer.mainNeg = -1.0
TagScorer.major = 0.7
TagScorer.majorNeg = -0.7
TagScorer.mid = 0.5
TagScorer.midNeg = -0.5
TagScorer.aux = 0.3
TagScorer.auxNeg = -0.3
TagScorer.minor = 0.1
TagScorer.minorNeg = -0.1

return TagScorer