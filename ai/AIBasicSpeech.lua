local AIBasicSpeech = Class.create("AIBasicSpeech", Entity)

AIBasicSpeech.dependencies = {"AITrust"}
AIBasicSpeech.trackFunctions = {"getDialogOptions"}

AIBasicSpeech.baseConfidence = 100
AIBasicSpeech.baseRelevance = 80

function AIBasicSpeech:identifyTags( eventName, newTags, params )
	local tags = {}
	tags["social"] = 100
	if eventName == "initiateConversation" then
		tags["initiateConversation"] = 100
	end
	if eventName == "receivingConversation" then
		tags["receivingConversation"] = 100
	end
	-- if eventName == "talk" then
	-- 	tags["talk"] = 100
	-- end
	-- if eventName == "ask" then
	-- 	tags["ask"] = 100
	-- end
	return tags
end

function AIBasicSpeech:initiateConversation(params,tagName,eventTags,aiPiece)
	self:addAudience(params.other)
	self.conversationOptions = {}
	self:getDialogOptions(self.conversationOptions)
	if self:hasModule("ModControllable") then
		self:setDialogItems({self.conversationOptions})
		self:startDialog(self.audience[1])
	else
		local speech = self:chooseDialog(options,extraParams)
		self:speak(speech)
	end
end

function AIBasicSpeech:receivingConversation() end

function AIBasicSpeech:getDialogOptions() end

function AIBasicSpeech.categorizeDialogType( self, dialogueType)
	self.dialogType = dialogueType
end
-- function AIBasicSpeech:communicateToOther( other, details )
-- 	other:respondToEvent(self.dialogType, {other=self,topic = details.text })
-- end

AIBasicSpeech.tagResponses = {
	{AIBasicSpeech.receivingConversation,"receivingConversation"},

	{AIBasicSpeech.initiateConversation,"initiateConversation"}
}

return AIBasicSpeech