local AIHumanRecognition = Class.create("AIHumanRecognition", Entity)
local Sentence = require "ai.AISentence"
AIHumanRecognition.dependencies = {"AITrust","AIQuestionAnswer"}

AIHumanRecognition.baseConfidence = 100
AIHumanRecognition.baseRelevance = 100

function AIHumanRecognition:identifyTags( eventName, tags, params )
	local tags = {}
	if params.other then
		tags["social"] = 1.0
		if self.topics[params.other] then
			local otherName = params.other
			if self.topics[otherName].knowName == true then
				tags[otherName] = 1.0
			else
				tags["stranger"] = 1.0
			end
			for k,v in pairs(self.topics[otherName].characterAssociations) do
				tags[k] = v
			end
		else
			tags["stranger"] = 1.0
			self:addNewCharacterInfo(params.other.name)
		end
	else
		tags["private"] = 1.0
	end

	return tags
end

function AIHumanRecognition:addNewCharacterInfo( characterName )
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
function AIHumanRecognition:formulateQuestions( topic ,questionList) 
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

function AIHumanRecognition:getCharacterInfo( characterName , setToKnowName)
	if self.topics[characterName] then
		return self.topics[characterName]
	else
		self:addNewCharacterInfo(characterName)
		self.topics[characterName].knowName = true
	end
end

function AIHumanRecognition:meetingNewPerson(params,tagName,eventTags,aiPiece)
	-- lume.trace()
	self:proposeAction( AIHumanRecognition.askForName, params, "askForName")

end

function AIHumanRecognition:askForName( score, params )
	-- lume.trace(self.type)
	self:approachCharacter(params.other)
end

AIHumanRecognition.tagResponses = {
	{AIHumanRecognition.exchangeGreetings,"social"},
	{AIHumanRecognition.meetingNewPerson,"stranger"}
}

return AIHumanRecognition