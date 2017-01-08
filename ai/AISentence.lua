local AISentence = Class.create("AIConscientiousness", Entity)

function AISentence:init(subject, actionName, action, directObject)
	self.subject = subject
	self.subjectName = subject.name or subject.type
	self.actionName = actionName
	self.action = action
	
	self.directObject = self.directObject
	self.directObjectName = directObject.name or directObject.type
	self.questionType = false
end

function AISentence:setSubject( subject )
	self.subject = subject
	self.subjectName = subject.name or subject.type
end

function AISentence:setSubject( actionName, action )
	self.actionName = actionName
	self.action = action
end

function AISentence:setDirectObject( directObject )
	self.directObject = directObject
	self.directObjectName = directObject.name or directObject.type
end

function AISentence:setString( string )
	self.string = string
end
function AISentence:toString()
	local autoString = "Fhiewofhew"
	return string
end

return AISentence