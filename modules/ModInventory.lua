local ModInventory = Class.create("ModInventory", Entity)

function ModInventory:create()
	self.inventory = self.inventory or Inventory(1,1)
	self.inventory:setUser(self)
	self.inventory.currentEquips = self.currentEquips
	self.inventory.currentPrimary = self.currentPrimary
	
	if self.currentEquip then
		local newEquip = self.currentEquip
		self.currentEquip = nil
		Game:add( newEquip )
		self:setEquip( newEquip , false)
	end
	if self.currentPrimary then
		local newEquip = self.currentPrimary
		self.currentPrimary = nil
		Game:add( newEquip )
		self:setEquip( newEquip ,false,true)
	end
end

function ModInventory:tick( dt )
	self:manageInt()
end

function ModInventory:manageInt( )
	if self.detectBox then
		local xOffset = 10 * self.dir
		local yOffset = 0
		--self.exclamation:setPosition(self.x, self.y - 48)
		Game.world:queryBoundingBox(self.x + xOffset - 8, self.y + yOffset - 8, self.x + xOffset + 8, self.y + yOffset + 8, self.wrapDetectInt)
		-- if self.exclamationAdded and (not self.displayExclamation or self.numInt <= 0) then
		-- 	Game.scene:remove(self.exclamation)
		-- 	self.exclamationAdded = false
		-- elseif self.numInt > 0 and not self.exclamationAdded and self.displayExclamation then
		-- 	Game.scene:insert(self.exclamation)
		-- 	self.exclamationAdded = true
		-- end
	end
end

function ModInventory:checkInt(fixture)
	if fixture then
		local other = fixture:getBody():getUserData()
		if other and Class.istype(other, "ObjInteractive") and other.intBoxActive then
			if not Class.istype(other, "ObjEquippable") and other ~= self.currentEquips and other ~= self.currentPrimary then
				self.numInt = self.numInt + 1
			end
		end
	end
	return 1
end

function ModInventory:drop(slot,removeFromInv,destroy)
	local r, c
	if slot ~= "primary" and not self.currentEquips[slot] then return end
	if slot == "primary" and not self.currentPrimary then return end
	-- lume.trace(slot)
	-- lume.trace(self.currentPrimary)
	if slot == "primary" then
		r, c = self.inventory:getRC(self.currentPrimary.type)
		if self.currentPrimary and self.currentPrimary.sprClass then
			self:delSpritePiece(self.currentPrimary.sprClass)
		end
	else
		slot = slot or "neutral"
		-- lume.trace(self.currentEquips[slot])
		r, c = self.inventory:getRC(self.currentEquips[slot].type)
		if self.currentEquips[slot] and self.currentEquips[slot].sprClass then
			self:delSpritePiece(self.currentEquips[slot].sprClass)
		end
	end
	-- lume.trace(r, c)
	if r and c then
		-- lume.trace(self)
		self.inventory.currentEquips[slot] = nil
		self.inventory.user = self
		-- lume.trace(removeFromInv)
		if removeFromInv then
			self.inventory:dropItem(r,c,destroy) 
		end
	else 
	end
	--self:setEquip(nil, true)
end

--sets the player's current equip to a provided ObjEquippable subclass

function ModInventory:setPrimary(active)
	if self.currentPrimary then
		if self.currentPrimary.continous then
			self.currentPrimary:setLightActive(active)
		else
			if active then 
				self.currentPrimary:use()
			end
		end
	end
end 

function ModInventory:setPassive(name,effect)
	for i,v in pairs(self.passiveEffects) do
		lume.trace(i)
		if i == name then
			self.passiveEffects[i] = nil
			self.passiveVars[i] = nil
			return
		end
	end
	self.passiveEffects[name] = effect
	lume.trace("Added to set passive: ", self.passiveEffects[name])
	self.passiveVars[name] = {}
end

function ModInventory:setEquip( item, slot )
	-- lume.trace(slot)
	self.inventory:setEquip(item,self,slot)
	self:updateIntAmount()
end

function ModInventory:reduceEquip( slot, amount )
	amount = (amount or 1)  
	-- lume.trace(self.currentEquips[slot])
	local currentItem
	lume.trace()
	if slot == "primary" then
		currentItem = self.currentPrimary
	else
		currentItem = self.currentEquips[slot]
	end
	currentItem.numInInv = math.max(0, currentItem.numInInv - amount)
		-- lume.trace("-----------")

	-- self.inventory:setEquipAmount(item,self,amount,self.currentEquips[slot].numInInv)
	if currentItem.numInInv <= 0 then
		lume.trace("pppp")
		-- currentItem:drop()
		self:drop(slot,true)
		self:setEquip(nil,slot)
	else
		local new = currentItem:makeCopy()

		currentItem:drop()
		-- self.currentEquips[slot] = new
		
		self:addToInv(new,true,0,true)

		--currentItem.toDestroy = true
		-- lume.trace(self.currentEquips[slot])
		-- self:setEquip(new,new.invSlot)

		-- currentItem.numInInv = currentItem.numInInv - 1
	end
	self:updateIntAmount()
end

function ModInventory:updateIntAmount()
	if self.equipIcons then
		for k,v in pairs(self.equipIcons) do
			if self.currentEquips[k] then
				v:setCount(self.currentEquips[k].numInInv)
			end
		end
	end
end

function ModInventory:mSetEquip(newEquip, animate, slot)
	local ce 
	self.isHolding = false
	slot = slot or "neutral"
	if newEquip then
		-- lume.trace(newEquip)
		self:delSpritePiece(newEquip.sprClass)
		if newEquip.passive then
			self:setPassive(newEquip.name, newEquip.passiveEffect)
		else
			newEquip.toDestroy = false
			-- if animate then self:setActionState("crouch",1) end
			newEquip.user = self
			newEquip.faction = self.faction
			if self.equipIcons then
				self.equipIcons[slot]:setImage(newEquip.invSprite)
			end
			self.isHolding = newEquip.isHolding
			-- lume.trace(newEquip.spritePiece)
			if newEquip.spritePiece then
				-- lume.trace(newEquip.spritePiece)
				self:addSpritePiece(newEquip.spritePiece,self.depth)
			end
		end
	else
		if slot == "primary" and self.currentPrimary then
			self:delSpritePiece(self.currentPrimary.sprClass)
		elseif self.currentEquips[slot] and self.currentEquips[slot].sprClass then
			self:delSpritePiece(self.currentEquips[slot].sprClass)
		end
		if self.equipIcons and self.equipIcons[slot] then
			self.equipIcons[slot]:setImage(nil)
			self.equipIcons[slot]:setCount(0)
		end
		self:drop(slot)
	end

	if slot == "primary" then
		self.currentPrimary = newEquip
	else
		self.currentEquips[slot] = newEquip
	end
	self:updateIntAmount()

end

--Adds an ObjEquippable subclass to the player's inventory
function ModInventory:addToInv(item, stackable, amount,overwrite, animate)
	-- if animate then self:setActionState("crouch",1) end
	lume.trace()
	if stackable then
		for _,v in self.inventory:iter() do
			if v.type == item.type then
				-- item.inInv = true
				-- lume.trace(item.type)
				-- lume.trace(overwrite)
				if overwrite then
					-- lume.trace("overwrite")
					-- lume.trace(amount)
					item.numInInv = v.numInInv + (amount or 1)
				else
					-- lume.trace()
					v.numInInv = v.numInInv + (amount or 1)
					item.toDestroy = true
					self:updateIntAmount()
					return
				end
			end
		end
	end
	self:equipIfOpen(item, item.isPrimary)
	self.inventory:insert( item )
	self:updateIntAmount()
end

function ModInventory:equipIfOpen(item, isPrimary)
	lume.trace()
	if isPrimary then
		if not self.currentPrimary then
			self.inventory:setEquip(item,self,"primary")
		end
	else
		if self.currentEquips["neutral"] and self.currentEquips["neutral"].type == item.type then
			lume.trace()
			self:setEquip(item,"neutral")
		elseif self.currentEquips["up"] and self.currentEquips["up"].type == item.type then
			self:setEquip(item, "up")
		elseif self.currentEquips["down"] and self.currentEquips["down"].type == item.type then
			self:setEquip(item, "down")
		elseif not self.currentEquips["neutral"] then
			self:setEquip(item,"neutral")
		elseif not self.currentEquips["up"] then
			self:setEquip(item,"up")
		elseif not self.currentEquips["down"] then
			self:setEquip(item,"down")
		end
	end
end

function  ModInventory:setEquipCreateItem(item ,animate)
	local class = require( "objects." .. item )
	local inst = class()
	Game:add(inst)
	lume.trace(inst.onPlayerInteract)
	inst:onPlayerInteract(self)
	return inst
end

return ModInventory