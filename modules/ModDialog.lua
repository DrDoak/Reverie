local ModDialog = Class.create("ModInteractive", Entity)

ModDialog.dependencies = {"ModInteractive"}

local ObjDialogSequence = require "objects.ObjDialogSequence"

function ModDialog:create()
	self:setDialogOnInteract(true)
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
	self.interactingChar = interChar
	if self.turnToPoint then
		self:turnToPoint(interChar.x, interChar.y)
	end
	self.dialogSequence = ObjDialogSequence( self, interChar, self.dialogItems)
	Game:add(self.dialogSequence)
end

function ModDialog:setOnlyOnce( onlyOnce )
	self.dialogOnlyOnce = true
	self.dialogInteracted = false
end

function ModDialog:setDialogItems( items )
	self.dialogItems = items
end

return ModDialog