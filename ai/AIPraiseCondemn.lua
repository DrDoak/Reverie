local AIPraiseCondemn = Class.create("AIPraiseCondemn", Entity)

AIPraiseCondemn.dependencies = {"AIBasicSpeech"}
AIQuestionAnswer.trackFunctions = {"formulatePraise","formulateCondemn"}

function AIPraiseCondemn:getDialogOptions()
	local mainAudience = self.audience[1]
	-- Praise
	local praise = {}
	praise.text = "Praise"
	praise.action = self.categorizeDialogType
	praise.response = self:formulateAllPraise()
	praise.args = {self,mainAudience, "praise"}
	table.insert(self.conversationOptions,praise)

	-- Condemn
	local condemn = {}
	condemn.text = "Condemn"
	condemn.action = self.categorizeDialogType
	condemn.response = self:formulateAllCondemn()
	condemn.args = {self,mainAudience, "condemn"}
	table.insert(self.conversationOptions,condemn)

	-- Request
	local request = {}
	request.text = "Request"
	request.action = self.categorizeDialogType
	-- request.response = self.iTopics
	request.args = {self,mainAudience,"request"}
	table.insert(self.conversationOptions,request)
end

function AIQuestionAnswer:formulateAllPraise()
	local praise = {}
	for k,v in pairs(self.topics) do
		self:formulatePraise(v,praise)
	end
	return {praise}
end
function AIQuestionAnswer:formulatePraise( topic, PraiseList ) end

function AIQuestionAnswer:formulateAllCondemn()
	local condemn = {}
	for k,v in pairs(self.topics) do
		self:formulateCondemn(v,condemn)
	end
	return {condemn}
end

function AIQuestionAnswer:formulateCondemn( topic, CondemnList ) end

function AIPraiseCondemn:respondPraise( params,tagName,eventTags,aiPiece)
end

function AIPraiseCondemn:respondCondemn( params,tagName,eventTags,aiPiece)
end
AIPraiseCondemn.tagResponses = {
	{AIPraiseCondemn.respondCondemn,"respondCondemn"}
	{AIPraiseCondemn.respondPraise,"respondPraise"}
}
return AIPraiseCondemn