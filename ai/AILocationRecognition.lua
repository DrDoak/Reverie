local AILocationRecognition = Class.create("AILocationRecognition", Entity)
local Sentence = require "ai.AISentence"
AILocationRecognition.dependencies = {"AITrust","AIQuestionAnswer"}

AILocationRecognition.baseConfidence = 100
AILocationRecognition.baseRelevance = 100

function AILocationRecognition:identifyTags( eventName, tags, params )
	local tags = {}
	if params.other then
		tags["social"] = 100
		if self.topics[params.other] then
			local otherName = params.other
			if self.topics[otherName].knowName == true then
				tags[otherName] = 100
			else
				tags["stranger"] = 100
			end
			for k,v in pairs(self.topics[otherName].characterAssociations) do
				tags[k] = v
			end
		else
			tags["stranger"] = 100
			self:addNewCharacterInfo(params.other.name)
		end
	else
		tags["private"] = 100
	end
	return tags
end

function AILocationRecognition:addNewCharacterInfo( characterName )
	-- lume.trace(characterName)
	local newCharacter = Class.create(characterName, Entity)
	newCharacter.baseConfidence = 100
	newCharacter.baseRelevance = 30
	newCharacter.name = characterName
	newCharacter.isTopic = true
	newCharacter.extraInfo = {traits = {}, character = true, knowName= false,characterAssociations = {}}
	self:addAIPiece(newCharacter)
end

-- Questions about characters
function AILocationRecognition:formulateQuestions( topic ,questionList) 
	lume.trace(topic,topic.name,topic.character)
	if topic.character then
		local charName = topic.name
		local text, response = nil, nil
		if not self:knowAboutCharacter(charName,"charName") then
			local newEntry = {}
			newEntry.name = "charName"
			newEntry.text = "Ask for Name"
			newEntry.response = {"Do you know this person's name?"}
			newEntry.closeAction = self.respondToDialog
			newEntry.closeArgs = {self,newEntry}
			table.insert(questionList,newEntry)
		end
		if not self:knowAboutCharacter(charName,"location") then
			lume.trace()
			local newEntry = {}
			newEntry.name = "name"
			newEntry.text = "Ask for Location"
			local nResponse = "Do you know where " .. charName .. " is?"
			newEntry.response = {nResponse}
			newEntry.closeAction = self.respondToDialog
			newEntry.closeArgs = {self,newEntry}
			table.insert(questionList,newEntry)
		end
	end
end

function AILocationRecognition:getCharacterInfo( characterName , setToKnowName)
	if self.topics[characterName] then
		return self.topics[characterName]
	else
		self:addNewCharacterInfo(characterName)
		self.topics[characterName].knowName = true
	end
end

AILocationRecognition.tagResponses = {
	{AILocationRecognition.exchangeGreetings,"social"},
	{AILocationRecognition.meetingNewPerson,"stranger"}
}

return AILocationRecognition