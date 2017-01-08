local ModIconObj = Class.create("ModIconObj", Entity)

ModIconObj.dependencies = {"ModDrawable"}

function ModIconObj:addIcon( newIcon )
	local newPieces
	local newTable = {}
	newIcon = util.deepcopy(newIcon)
	for i,v in ipairs(self.icons) do
		if v.path == newIcon.path then
			return 
		end
	end
	local iconName = "icon" .. #self.icons + 1
	newIcon.name = iconName
	if #self.icons > 0 then
		newIcon.connectSprite = "icon" .. (#self.icons)
	elseif self.sprites["main"] then
		newIcon.connectSprite = "main"
		newIcon.connectPoint = "center"
		newIcon.attachPoints.prevIco = {x=16,y=48}
	elseif self.sprites["legs"] then
		newIcon.connectSprite = "legs"
		newIcon.connectPoint = "center"
		newIcon.attachPoints.prevIco = {x=16,y=48}
	end
	-- lume.trace(newIcon.path)
	-- lume.trace(iconName)
	-- util.print_table(self.icons)
	-- lume.trace(Game:getTicks())

	self:addSpritePiece(newIcon)
	-- lume.trace(self.sprites[newIcon.name].setAngle)
	self.icons[#self.icons + 1] = newIcon

end

function ModIconObj:removeIcon( iconPath   )
	local pushBack = false
	local deletedInd = 0
	for i,v in pairs(self.icons) do
		if v.path == iconPath then
			pushBack = true
			self:delSpritePiece(v.name)
			deletedInd = i
			-- lume.trace("I is: ",i,"removed: ", v.name, "path: ",iconPath)
		elseif pushBack then
			self:delSpritePiece(v.name)
			v.connectSprite = "icon" .. (i - 2)
			v.name = "icon" .. (i - 1)
			if (i-1) == 1 then
				if self.sprites["main"] then
					v.connectSprite = "main"
				else
					v.connectSprite = "legs"
				end
				v.connectPoint = "center"
				v.attachPoints.prevIco = {x=16,y=48}
			end
			lume.trace("prev was: ", i, "Now is: " , v.name)
			lume.trace("trying to connect to: " , v.connectSprite)
			self:addSpritePiece(v)
		end
	end

	if deletedInd ~= 0 then
		table.remove(self.icons,deletedInd)
	else
		lume.trace("Attempting to remove icon that does not exist.")
	end
end

return ModIconObj