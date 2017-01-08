local ModDialog = Class.create("ModInteractive", Entity)

ModDialog.dependencies = {"ModInteractive"}

local ObjDialogSequence = require "objects.ObjDialogSequence"

function ModDialog:create()
	self.audience = {}
	self:setDialogOnInteract(false)
end

function ModDialog:tick( dt )
	for i,v in ipairs(self.audience) do
		if not self:testProximity(v.x,v.y,64) then
			self:removeAudience(v)
		end
	end
	-- if self.setNewDialog and self.audience then
	-- 	for i,v in ipairs(self.audience) do
	-- 		self:startDialog(v)
	-- 	end
	-- 	-- self:startDialog(self.audience[1])
	-- end
end

function ModDialog:onPlayerInteract( player,data )
	if self.dialogOnInteract and (not self.dialogOnlyOnce or not self.dialogInteracted) then
		self.dialogInteracted = true
		self:startDialog(player)
	end
end

function ModDialog:setDialogOnInteract( onInteract )
	self.dialogOnInteract = onInteract
end

function ModDialog:startDialog(interChar)
	self.interactingChar = interChar or self.audience[1]
	if self.turnToPoint then
		self:turnToPoint(interChar.x, interChar.y)
	end
	-- self.setNewDialog = false
	self.dialogSequence = ObjDialogSequence( self, interChar, self.dialogItems)
	Game:add(self.dialogSequence)
end

function ModDialog:setOnlyOnce( onlyOnce )
	self.dialogOnlyOnce = true
	self.dialogInteracted = false
end

function ModDialog:setDialogItems( items ,audience)
	self.dialogItems = items
	if audience then
		self.setNewDialog = audience
	end
	-- self.setNewDialog = true
end

function ModDialog:addAudience( player )
	if not util.hasValue(self.audience,player) then
		table.insert(self.audience,player)
	end
end

function ModDialog:removeAudience( player )
	util.deleteFromTable(self.audience,player)
end

return ModDialog