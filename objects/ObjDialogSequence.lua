local DialogActive = require "mixin.DialogActive"
local ClickText = require "mixin.ClickText"
local Shop = require "mixin.Shop"
local ObjDialogSequence = Class.create("ObjDialogSequence", Entity)


function ObjDialogSequence:init( creator , interactor, sequence, parent)
	self.speaker = creator
	self.interactor = interactor
	self.sequence = sequence
	lume.trace("init")
	self.parent = parent
end

function ObjDialogSequence:create()
	self.currentIndex = 1
	self.started = true
	self:setStopWhenLeave(self.noLeave, self.radius)
	self.speaker.dialogSequence = self
	lume.trace("Dialog Sequence created")
end

function ObjDialogSequence:addTextBox( text )
	table.insert(self.sequence,text)
end

function ObjDialogSequence:addDialogOption( options )
	table.insert(self.sequence,options)
end

function ObjDialogSequence:addSequence( sequence )
	self.sequence = sequence
end

function ObjDialogSequence:setStopWhenLeave( stop , radius)
	self.noLeave = stop
	self.radius = radius or 64
end

function ObjDialogSequence:tick( dt )
	if self.speaker and self.interactor and not self.speaker.destroyed and not self.interactor.destroyed then
		self.x, self.y = self.speaker.body:getPosition()
		if not self.noLeave then
			local otherX, otherY = self.interactor.body:getPosition()
			if self:getDistanceToPoint(otherX,otherY) > self.radius then
				self.toClose = true
			end
		end
	else
		lume.trace(self.speaker,self.interactor,self.speaker.destroyed,self.interactor.destroyed)
		self.toClose = true
	end
	if self.started == true and (not self.currentDialog or self.currentDialog.destroyed)then
		self:processNextElement()
	end

	if self.toClose == true then
		Game:del(self)
	end
	-- lume.trace(self.currentDialog)
end


function ObjDialogSequence:getDistanceToPoint( pointX, pointY )
	return math.sqrt(math.pow(pointX - self.x,2) + math.pow(pointY - self.y,2 ) )
end

function ObjDialogSequence:destroy()
	-- lume.trace("destroying dialog sequence")
	self.destroyed = true
	if self.parent and not self.parent.destroyed then
		self.parent:continueDialogue()
	end
	if self.currentDialog then
		-- lume.trace(self.currentDialog)
		-- lume.trace(self.currentDialog.type)
		self.currentDialog:endDialog()
	end
end

function ObjDialogSequence:processNextElement( sequence, index )
	sequence = sequence or self.sequence
	index = index or self.currentIndex
	if self.currentIndex > table.getn(self.sequence) then
		lume.trace()
		self.toClose = true
	else
		-- if self.currentDialog then
		-- 	lume.trace(self.currentDialog.type)
		-- 	lume.trace(self.currentDialog.destroyed)
		-- end
		self.currentElement = sequence[index]
		util.print_table(self.currentElement)
		self:processElement(self.currentElement)
		self.currentIndex = self.currentIndex + 1
	end
end

function ObjDialogSequence:processElement( element )
	if type(element) == "string" then
		lume.trace()
		self.currentDialog = ClickText(element,nil,nil,true)
		Game:add(self.currentDialog)
	else
		if element.cond then
			lume.trace()
			if not element.cond(self.speaker,self.interactor) then
				return
			elseif type(element[1]) == "string" then
				lume.trace()
				self.currentDialog = ClickText(element[1],nil,nil,true)
				Game:add(self.currentDialog)
				return
			end
		end
		if element[1].cond then
			for i,v in ipairs(element) do
				if element.cond(self.speaker,self.interactor) then
					self:processElement(v)
					return
				end
			end
		end
		if element.random then
			lume.trace("random dialogue")
			element = element[math.random(1,#element)]
			self:processElement(element)
			return
		end
		if element.shop then
			lume.trace()
			self.currentDialog = Shop.startShop(self.speaker,self.interactor,element,element.shop)
		else
			lume.trace()
			self.currentDialog = DialogActive(element,self.speaker,self.interactor)
			Game.scene:insert(self.currentDialog)
		end
	end
	return true
end
return ObjDialogSequence