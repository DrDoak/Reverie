local AIQuestionAnswer = Class.create("AIQuestionAnswer", Entity)

AIQuestionAnswer.dependencies = {"AIBasicSpeech"}
AIQuestionAnswer.trackFunctions = {"formulateInfo","formulateQuestions"}

function AIQuestionAnswer:identifyTags( eventName, params )
	local tags = {}
	if eventName == "respondQuestion" then
		tags["respondQuestion"] = 1.0
	end
	if eventName == "respondInfo" then
		tags["respondInfo"] = 1.0
	end
	return tags
end

function AIQuestionAnswer:getDialogOptions()
	local mainAudience = self.audience[1]
	-- Chat
	-- local chat = {}
	-- chat.text = "Talk About Topic"
	-- chat.action = self.categorizeDialogType
	-- chat.response = self:getAllInfoTargets()
	-- chat.args = {self,"respondInfo"}
	-- table.insert(self.conversationOptions,chat)

	-- Ask About
	local ask = {}
	ask.text = "Ask about Topic"
	ask.action = self.categorizeDialogType
	ask.response = self:getAllQuestionTopics()
	ask.args = {self,"respondQuestion"}
	table.insert(self.conversationOptions,ask)
end

function AIQuestionAnswer:formulateAllInfo()
	local info = {}
	for k,v in pairs(self.topics) do
		self:formulateInfo(v,info)
	end
	return {info}
end

function AIQuestionAnswer:formulateInfo( topic, infoList ) 
	if topic.subTopics then
		for subTopicName,subTopic in pairs(topic.subTopics) do
			local newTopic = {}
			newTopic.text = subTopics.text
			newTopic.closeAction = self.respondToDialog
			newTopic.closeArgs = {self,subTopic}
			table.insert(infoList,newTopic)
		end
	end
end

function AIQuestionAnswer:getAllQuestionTopics( ... )
	local questions = {}
	for k,v in pairs(self.topics) do
		self:checkQuestionTopic(v,questions)
	end
	return {questions}
end
function AIQuestionAnswer:checkQuestionTopic(v,qList)
	lume.trace(v,v.name,v.character)
	if v.character then 
		local newTopic = {}
		newTopic.text = v.text
		newTopic.action = self.getQuestions
		newTopic.args = {self,v}
		table.insert(qList,newTopic)
	end
end
function AIQuestionAnswer:getQuestions( topic)
	local newOptions = {}
	self:formulateQuestions(topic,newOptions)
	lume.trace(#newOptions)
	if #newOptions > 0 then
		self:setDialogItems({newOptions})
		self:startDialog(self.audience[1])
	end
end

function AIQuestionAnswer:formulateQuestions( topic ,questionList) end

function AIQuestionAnswer:respondQuestion(  params,tagName,eventTags,aiPiece)
	local topic = params.topic
	util.shallow_print(topic)
	--lume.trace(topic.name)
	if self:knowsTopic(topic) then
		self:proposeAction(self.provideAnswer,{},"speech",10,"AIQuestionAnswer")
	else
		self:proposeAction(self.claimNoAnswer,{},"speech",10,"AIQuestionAnswer")
	end
end

function AIQuestionAnswer:provideAnswer( topic )
	lume.trace()
end

function AIQuestionAnswer:claimNoAnswer( topic )
	lume.trace()
end

function AIQuestionAnswer:respondInfo( params,tagName,eventTags,aiPiece)
	local otherChar = params.other
	if not self:knowsTopic(params.topic) then
		self:setDialogItems({"Thank you For telling me this", "I appreciate it"})
	else
		self:setDialogItems({"I already know this"})
	end
	self:startDialog(otherChar)
	-- self:addAIPiece(params.topic.module)
end

AIQuestionAnswer.tagResponses = {
	{AIQuestionAnswer.respondInfo,"respondInfo"},
	{AIQuestionAnswer.respondQuestion,"respondQuestion"}
}

return AIQuestionAnswer