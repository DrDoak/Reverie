local Keymap = require "xl.Keymap"
local Gamestate = require "hump.gamestate"
-- local Dialog = require "state.Dialog"

local IST = {}

local function default_callback( item, index ) 
end

function IST:init(  )
	self.inv = nil
end

function IST:enter( previous, inventory1, inventory2 )
	love.keyboard.setKeyRepeat( true )
	self.inventory1 = inventory1
	self.inventory2 = inventory2
	self.activeInv = self.inventory1
	self.selRow = 1
	self.selCol = 1
	self.moveRow = 1
	self.moveCol = 1
	self.moveMode = false
	self.canRepeat = 0
	self.callItQuits = false
end

function IST:leave(  )
	love.keyboard.setKeyRepeat( false )
end

function IST:update( dt )
	self.canRepeat = math.max( self.canRepeat - dt, 0 )
end

function IST:draw(  )
	self.inventory1:setPosition(0,0)
	if self.inventory1.userName then
		love.graphics.print( self.inventory1.userName, self.inventory1.x,self.inventory1.y, 0, 2, 2)
	end
	if self.activeInv == self.inventory1 then
		self.inventory1:draw( self.selRow, self.selCol )
	else
		self.inventory1:draw()
	end
	if self.inventory2 then
		self.inventory2:setPosition(love.graphics.getWidth() - (self.inventory2.cols*160) ,0)
		if self.activeInv == self.inventory2 then
			self.inventory2:draw( self.selRow, self.selCol )
		else
			self.inventory2:draw()
		end
		if self.inventory2.userName then
			love.graphics.print( self.inventory2.userName, self.inventory2.x ,self.inventory2.y, 0, 2, 2)
		end
	end
	if self.callItQuits then -- we pop here so that previous state starts on a new frame
		self.callItQuits = false
		Gamestate.pop()
	end
end

function IST:getSelected(  )
	return self.selRow, self.selCol
end

function IST:keypressed( key, isrepeat )
	if isrepeat and self.canRepeat ~= 0 then
		return
	end
	local inv = self.activeInv
	if     Keymap.check( "up", key ) then
		self.selRow = util.loopvalue( self.selRow - 1, 1, inv.rows )
	elseif Keymap.check( "down", key ) then
		self.selRow = util.loopvalue( self.selRow + 1, 1, inv.rows )
	elseif Keymap.check( "left", key ) then
		if self.activeInv == self.inventory2 and self.selCol == 1 then
			self.activeInv = self.inventory1
			inv = self.activeInv
			self.selCol = inv.cols
			if self.selRow > inv.rows then
				self.selRow = inv.rows
			end
		else
			self.selCol = util.loopvalue( self.selCol - 1, 1, inv.cols )
		end
	elseif Keymap.check( "right", key ) then
		if self.activeInv == self.inventory1 and self.inventory2 and self.selCol == inv.cols then
			self.activeInv = self.inventory2
			inv = self.activeInv
			self.selCol = 1
			if self.selRow > inv.rows then
				self.selRow = inv.rows
			end
		else
			self.selCol = util.loopvalue( self.selCol + 1, 1, inv.cols )
		end
	elseif Keymap.check( "use", key ) then
		local item,index = inv:get( self.selRow, self.selCol )
		if self.moveMode == false and item then
			local name
			if item then
				name = item.name
				-- Game.WorldManager:setJournal(name, true) 
			else
				name = "Empty Slot"
			end
			local Items = {
			title = name,
			exit = 4}
			if item.isPrimary then
				table.insert(Items,
				{
					text = "Set Primary",
					action = function ()
						if self.activeInv == self.inventory2 then
							self.inventory1:insert(item)
							self.inventory2:remove(self.selRow, self.selCol)
						end
						if item.invSlot then
							self.inventory1:setEquip(nil,nil,item.invSlot)
						end
						self.inventory1:setEquip(item,nil,"primary")
					end,
				})
			else
				table.insert(Items,{
					text = "Set Up Item",
					action = function ()
						lume.trace(self)
						lume.trace(self.activeInv, self.inventory2, self.inventory1,item)
						if self.activeInv == self.inventory2 then
							self.inventory1:insert(item)
							self.inventory2:remove(self.selRow, self.selCol)
						end
						if item.invSlot then
							self.inventory1:setEquip(nil,nil,item.invSlot)
						end
						self.inventory1:setEquip(item,nil,"up")
					end,
				})
				table.insert(Items,{
					text = "Set Neutral Item",
					action = function ()
						if self.activeInv == self.inventory2 then
							self.inventory1:insert(item)
							self.inventory2:remove(self.selRow, self.selCol)
						end
						if item.invSlot then
							self.inventory1:setEquip(nil,nil,item.invSlot)
						end
						self.inventory1:setEquip(item,nil,"neutral")
					end,
				})
				table.insert(Items,{
					text = "Set Down Item",
					action = function ()
						if self.activeInv == self.inventory2 then
							self.inventory1:insert(item)
							self.inventory2:remove(self.selRow, self.selCol)
						end
						if item.invSlot then
							self.inventory1:setEquip(nil,nil,item.invSlot)
						end
						self.inventory1:setEquip(item,nil,"down")
					end,
				})
				table.insert(Items,{
					text = "Move Item",
					action = function ()
						self.moveMode = true
						self.moveRow = self.selRow
						self.moveCol = self.selCol
						self.originInv = inv
						self.originItm = item
					end,
				})
				table.insert(Items,{
					text = "Drop Item",
					action = function ()
						if self.activeInv == self.inventory1 then
							local r,c = self.inventory1:getRC(self.currentEquip)
							inv:dropItem(self.selRow, self.selCol)
						end
					end,
				})
				table.insert(Items,{
					text = "Back",
					action = function ()
						self.callItQuits = true
					end
				})
			end
			
			-- Dialog.display(Items, self)
		elseif self.moveMode == true then
			local i1, i2 = inv:get(self.selRow, self.selCol)
			local j1, j2 = self.originInv:get(self.moveRow,self.moveCol)
			if self.originInv == inv then
				inv:swap(i2,j2)
			else
				local itm = inv:get(self.selRow, self.selCol)
				inv:remove(self.selRow, self.selCol)
				inv:insert(self.originItm, self.selRow, self.selCol)
				self.originInv:remove(self.moveRow, self.moveCol)
				self.originInv:insert(itm, self.moveRow, self.moveCol)
				if self.originItm == self.inventory1.currentEquip then
					self.inventory1:setEquip(itm)
				end
			end
			self.moveMode = false
		end
	elseif Keymap.check( "exit", key ) then
		self.moveMode = false
		self.callItQuits = true
	end
	self.canRepeat = 0.1
end

function IST:keyreleased( key, isrepeat )
end

function IST:open( inventory1, inventory2 )
	Gamestate.push( IST, inventory1, inventory2 )
end

return IST