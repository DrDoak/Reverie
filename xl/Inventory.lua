local Entity = require "objects.Entity"
local Gamestate = require "hump.gamestate"
local InventoryMenu = require "state.InventoryMenu"

local Inventory = Class("Inventory")

local function __NULL__() end

local function slotsprite( name )
	local spr = love.graphics.newImage( "assets/HUD/interface/".. name )
	spr:setWrap( "repeat", "repeat" )
	return spr
end
local slot_mid  = slotsprite( "middle.png" )
local slot_top  = slotsprite( "top.png" )
local slot_side = slotsprite( "side.png" )
local slot_selected = slotsprite( "selected.png" )
local default_item_sprite = slotsprite( "diamond_hoe100.png" )
local slot_width,slot_height = slot_mid:getDimensions()
local item_draw_offset = 4 -- offset to draw item at

-- Invetory constructor
-- @param Invetory source - the source inventory to construct from
-- OR
-- @param number rows - number of rows in the inventory
-- @param number cols - number of columns in the inventory
-- @param object user - a reference to the user
function Inventory:init( ... )
	if select("#",...) == 1 then
		-- load from self
		local o = select(1,...)
		self.x = o.x
		self.y = o.y
		self.items = o.items
		self.rows = o.rows
		self.cols = o.cols
		self.user = o.user
	else
		local rows,cols,user = select(1,...)
		assert(rows and cols, "an invalid argument was given to the constructor")
		self.x = 0
		self.y = 0
		self.items = {}
		self.rows = rows
		self.cols = cols
		self.user = user
	end
	self.equipIco = love.graphics.newImage( "assets/HUD/interface/equip.png" )
	self.smallEquipIco = love.graphics.newImage( "assets/HUD/interface/equipSM.png" )
	self:build_quads()
	self.colorTable = {}
	self.currentEquips = {}
end

function Inventory:setUser(user)
	self.user = user
end

function Inventory:initialize( user , name)
	self.user = user
	if name then 
		self.userName = name
	end
	-- create a new inventory based on the old one
	user.inventory = Inventory(user.inventory)
	-- recreate the inventory items if neccessary
	for k,entity in pairs(user.inventory.items) do
		local inst = util.recreateObject( entity )
		inst:create()
		user.inventory.items[k] = inst
		if entity == user.currentEquip then
			user.currentEquip = inst
		end
		if entity == user.currentPrimary then
			user.currentPrimary = inst
		end
		user.inventory.items[k]:destroy()
	end
end

function Inventory:setEquip(item , destination,slot,destroy)
	local dest = destination or self.user
	if item and item.inInv then
		lume.trace("inventory setEquip: ", item.type, "inInv", item.inInv)
		local inst = item
		if item.destroyed then
			local class = require( "objects.eqp." .. item.type )
			inst = class()
			Game:add(inst)
		end
		-- if self.currentEquips[slot] then
		-- 	self.currentEquips[slot].invSlot = nil
		-- end
		item.invSlot = slot
		if item.passive then
			item.passiveEquip = true
			if dest.passiveEffects[item.name] then
				item.passiveEquip = false
			end
			dest:mSetEquip( inst, false )
		elseif slot == "primary" then
			self.currentPrimary = inst
			dest:mSetEquip( inst, true , "primary")
		else
			self.currentEquips[slot] = inst
			dest:mSetEquip( inst, true , slot)
		end
	elseif item then
		-- lume.trace("inventory setEquip: ", item.type, "inInv", item.inInv)
		-- lume.trace("setting to slot: " , slot)
		-- if self.currentEquips[slot] then
		-- 	self.currentEquips[slot].invSlot = nil
		-- end
		item.invSlot = slot

		if item and item.passive then
			-- lume.trace()
		elseif slot == "primary" then
			dest:mSetEquip(nil, true, "primary")
			self.currentPrimary = item
			-- lume.trace()
			dest:mSetEquip(item, true, "primary")
		else
			-- lume.trace()
			dest:mSetEquip(nil, true,slot,destroy)
			-- lume.trace(item)
			self.currentEquips[slot] = item
			dest:mSetEquip(item, true,slot)
		end 
	else
		if item and item.passive then
		elseif slot == "primary" then
			self.currentPrimary = item
			dest:mSetEquip(nil, true, "primary")
		else
			dest:mSetEquip(nil, true,slot)
		end
	end
end

-- function Inventory:setEquipAmount(item ,destination, slot, numInInv)
-- 	local dest = destination or self.user

-- 	if numInInv <= 0 then
-- 		self.setEquip(nil,destination,slot)
-- 	elseif item and item.inInv then
-- 		local inst = item
-- 		if not item.passive and item.destroyed then
-- 			local class = require( "objects.eqp." .. item.type )
-- 			inst = class()
-- 			Game:add(inst)
-- 			item = nil
-- 		end
-- 		if item.passive then
-- 			item.passiveEquip = true
-- 			if dest.passiveEffects[item.name] then
-- 				item.passiveEquip = false
-- 			end
-- 			dest:mSetEquip( inst, false )
-- 		elseif slot == "primary" then
-- 			self.currentPrimary = nil
-- 			dest:mSetEquip( inst, true , "primary")
-- 		else
-- 			self.currentEquips[slot] = nil
-- 			dest:mSetEquip( inst, true , slot)
-- 		end
-- 	else
-- 		if item and item.passive then
-- 		elseif slot == "primary" then
-- 			self.currentPrimary = nil
-- 			dest:mSetEquip(nil, true, "primary")
-- 		else
-- 			dest:mSetEquip(nil, true,slot)
-- 		end
-- 	end
-- end

function Inventory:dropItem( r, c ,destroy)
	-- lume.trace("!!!!")
	-- lume.trace(self.user, self.user.currentPrimary)
	local item = self:get(r,c)
	-- lume.trace(item, item.inInv)
	if item  then
		item.inInv = false
		-- lume.trace(item,self.user.currentEquip, self.user.currentPrimary)
		if item.invSlot then
			self.user.currentEquips[item.invSlot] = nil
			if self.user.state == 4 then
				self.user.exit = true
			end
			self.currentEquips[item.invSlot] = nil
		elseif item == self.user.currentPrimary then
			self.user.currentPrimary = nil
			if self.user.state == 4 then
				self.user.exit = true
			end
			self.currentPrimary = nil
		else
			Game:add( item )
		end
		self:remove(r,c)
		-- lume.trace(destroy)
		-- error()
		if destroy then
			lume.trace()
			item.inserted = true
			item:drop()
			item.user = nil
			item.toDestroy = true
		else
			-- lume.trace()
			item:drop()
		end
	end
end

function Inventory:get( r, c )
	local index = self:assertRC( r, c )
	return self.items[index], index
end

function Inventory:set( item, r, c )
	local index = self:assertRC( r, c )
	self.items[index] = item
end
function Inventory:geti( index )
	return self.items[index]
end

function Inventory:seti( item, index )
	self.items[index] = item
end

function Inventory:getRC( item )
	local row = nil
	local col = nil
	for r=1,self.rows do
		for c=1,self.cols do
			if self:get(r,c) then
				-- util.print_table(self:get( r,c ))
				if item == self:get( r,c ).type then
					row, col = r , c
				end
			end
		end
	end
	return row, col
end

function Inventory:getRCType( type )
	local row = nil
	local col = nil
	for r=1,self.rows do
		for c=1,self.cols do
			if self:get(r,c) then
				-- util.print_table(self:get( r,c ))
				if type == self:get( r,c ).type then
					row, col = r , c
				end
			end
		end
	end
	return row, col
end

function Inventory:findEmpty(  )
	for r=1,self.rows do
		for c=1,self.cols do
			if not self:get( r,c ) then
				return r,c
			end
		end
	end
	return nil,nil
end

function Inventory:inInv( itemName )
	local inInv = false
	local item = nil
	for r=1,self.rows do
		for c=1,self.cols do
			if self:get(r,c) and self:get(r,c).type == itemName then
				inInv = true
				item = self:get(r,c)
				break
			end
		end
	end
	return inInv, item
end

function Inventory:itemAt( itemName, r, c )
	if self:get(r,c) and self:get(r,c).type == itemName then
		return true
	else
		return false
	end
end

function Inventory:insert( item, r, c ,amount)
	if self:getRCType(item.type) then
		r,c = self:getRCType(item.type)
		local index = self:assertRC( r, c)
		self.items[index] = item
	else
		if (not r and not c) or self:get( r, c ) then -- if no r/c is provided or if the space is occupied
			r,c = self:findEmpty() -- find another avaliable empty space.
		end
		local index = self:assertRC( r,c ) --TODO, display message "No space is avaliable" instead of crash.
		if item then item.inInv = true end
		item.numInInv = item.numInInv or 1
		self.items[index] = item --{type=item.type,numInInv= (amount or 1)}
		return r, c --Returns the element that it was inserted in.
	end
end

function Inventory:remove( r , c )
	local item,index = self:get(r,c)
	self.items[index] = nil
end

function Inventory:assertRC( r, c )
	assert( r <= self.rows, "row out of bounds" )
	assert( c <= self.cols, "column out of bounds" )
	return r * self.cols + c
end

function Inventory:IndexToRC( index )
	local c = index - math.floor(self.rows/index)*index
	local r = math.floor(index/self.rows)
	return r,c
end

function Inventory:iter()
	return pairs( self.items )
end

function Inventory:take( r,c )
	local item = self.items[slot]
	local class = require( item.class )
	local inst = class( item )
	return inst
end

function Inventory:swap( slotFrom, slotTo )
	local it = self.items
	local temp = it[slotTo]
	it[slotTo] = it[slotFrom]
	it[slotFrom] = temp
end

function Inventory:draw( selectedRow, selectedCol  )
	local graphics, qpos = love.graphics, self.qpos
	Game.player.TextInterface:setPosition(240,32)
	Game.player.TextInterface:update()
	Game.player.TextInterface:draw()

	graphics.setColor( 255,255,255 )
	graphics.push()
	graphics.translate( self.x, self.y )
	graphics.draw( slot_mid, self.quad_mid, qpos[1], qpos[2] )
	-- graphics.draw( slot_side, self.quad_side, qpos[3], qpos[4] )
	-- graphics.draw( slot_side, self.quad_side, qpos[5], qpos[6], 0, -1, 1 )
	-- graphics.draw( slot_top, self.quad_top, qpos[7], qpos[8] )
	-- graphics.draw( slot_top, self.quad_top, qpos[9], qpos[10], 0, 1, -1 )
	graphics.pop()
	graphics.push()
	graphics.translate( self.x + self.qpos[1], self.y + self.qpos[2] )
	for r=1,self.rows do
		for c=1,self.cols do
			local x,y = slot_width * (c - 1), slot_height * (r - 1)
			local item = self:get( r,c )
			
			if r == selectedRow and c == selectedCol then
				graphics.draw( slot_selected, x, y )
			end
			
			if item then
				local cx,cy = x + (slot_width / 2), y + (slot_height / 2)
				local spr = item.invSprite or item.sprite or default_item_sprite
				if tostring(spr) == "Image" then
					graphics.draw( spr, cx - (spr:getWidth() / 2), cy - (spr:getHeight() / 2) )
				else
					graphics.translate( x, y )
					spr:draw()
				end
				if item.passiveEquip then
					graphics.draw( self.smallEquipIco, slot_width * (c - 1) + slot_width/2,
		 			slot_height * (r - 1) + slot_height/2)
				end
			end
		end
	end
	for k,v in pairs(self.currentEquips) do
		local r, c = self:getRC(v.type)
		graphics.draw( self.smallEquipIco, slot_width * (c - 1) + slot_width - 16,
		 			slot_height * (r - 1) + slot_height - 16)
		if v.numInInv > 1 then
			graphics.print(v.numInInv ,  slot_width * (c - 1) ,slot_height * (r - 1) + slot_height - 12)
		end
	end
	if self.currentPrimary then
		-- util.print_table(self.currentPrimary)
		local r, c = self:getRC(self.currentPrimary.type)
		graphics.draw( self.equipIco, slot_width * (c - 1) + slot_width/2,
		slot_height * (r - 1) + slot_height/2)
		if self.currentPrimary.numInInv > 1 then
			graphics.print(self.currentPrimary.numInInv ,  slot_width * (c - 1) ,slot_height * (r - 1) + slot_height - 12)
		end
	end
	-- if self.userName then
	-- 	love.graphics.print( self.userName, self.x,self.y, 0, 4,4)
	-- end
	if self.user.keyItemList then
		local i = 0
		for key, value in pairs(self.user.keyItemList) do
			graphics.draw( value, 32 * i, 320)
			i = i + 1
		end
	end

	if Game.WorldManager.worldGen then
		self:drawMap()
	end
	graphics.pop()
end

function Inventory:drawMap()
	local graphics = love.graphics
	local worldMap = Game.WorldManager.worldGen.evalArea
	local worldX = 0
	local mapStartX = 128
	local mapStartY = -196
	local worldY = 0
	for i,v in ipairs(worldMap) do
		for i2,v2 in ipairs(v) do
			if v2["room"] then
				if not self.colorTable[v2["roomNo"]] then
					local r = math.random(0,255)
					local g = math.random(0,255)
					local b = math.random(0,255)

					self.colorTable[v2["roomNo"]] = {r,g,b}
				end
				graphics.setColor(unpack(self.colorTable[v2["roomNo"]]))
				love.graphics.rectangle("fill", worldX + mapStartX, worldY + mapStartY, 16,16)
				graphics.setColor(255,0,0)
				if v2["exitLeft"] then
					love.graphics.rectangle("fill", worldX + mapStartX,worldY + mapStartY + 4,12,8)
				elseif v2["exitRight"] then
					love.graphics.rectangle("fill", worldX + mapStartX + 4,worldY + mapStartY + 4,12,8)
				elseif v2["exitUp"] then
					love.graphics.rectangle("fill", worldX + mapStartX + 4,worldY + mapStartY,8,12)
				elseif v2["exitDown"] then
					love.graphics.rectangle("fill", worldX + mapStartX + 4,worldY + mapStartY + 4,8,12)
				end
			end
			graphics.setColor(0,0,255)
			if v2["horizontal"] then
				love.graphics.rectangle("fill", worldX + mapStartX,worldY + mapStartY + 6,16,4)
			end
			if v2["vertical"] then
				love.graphics.rectangle("fill", worldX + mapStartX + 6,worldY + mapStartY ,4,16)
			end
			if v2["corner"] then
				love.graphics.rectangle("fill", worldX + mapStartX + 6,worldY + mapStartY + 6,4,4)
			end
			if v2["spot"] then
				graphics.setColor(180,180,180)
				love.graphics.rectangle("fill", worldX + mapStartX + 3,worldY + mapStartY + 3,9,9)
			end
			if v2["goal"] then
				graphics.setColor(255,255,0)
				love.graphics.rectangle("fill", worldX + mapStartX + 3,worldY + mapStartY + 3,9,9)
			end
			worldY = worldY + 16
		end
		worldX = worldX + 16
		worldY = 0
	end
	graphics.setColor(255,0,255)
	love.graphics.rectangle("fill", (Game.WorldManager.worldX - 1)* 16 + mapStartX + 4 + math.floor((Game.player.x/16)/32) * 16,
		(Game.WorldManager.worldY-1) * 16 + mapStartY + 4 + math.floor((Game.player.y/16)/32) * 16, 8,8)
	graphics.setColor(255,255,255)
end
function Inventory:setPosition( x , y )
	self.x = x
	self.y = y
end

local function make_quad( rows, cols, image )
	local imgw,imgh = image:getDimensions()
	local quad = love.graphics.newQuad( 0, 0, cols * imgw, rows * imgh, imgw, imgh )
	return quad,imgw,imgh
end

function Inventory:open( ... )
	Gamestate.push( InventoryMenu, self, ... )
end

function Inventory:build_quads()
	local sidew,toph,_
	self.quad_mid = make_quad( self.rows, self.cols, slot_mid )
	self.quad_top = make_quad( 1, self.cols, slot_top )
	self.quad_side = make_quad( self.rows, 1, slot_side )

	local x,y,w,h
	x,y,w,h = self.quad_mid:getViewport()
	x,y = slot_side:getWidth(),slot_top:getHeight()
	w,h = w + 2*x, h + 2*y
	self.qpos = {
		x,y, -- middle
		0,y, -- left side
		w,y, -- right side
		x,0, -- top
		x,h, -- bottom
	}
end

return Inventory
