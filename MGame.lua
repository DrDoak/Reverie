----
-- MGame.lua
--
-- The primary gamestate which the game runs in. This gamestate handles all
-- entities, room loading, rendering, updating, etc. This is where most of
-- the core game code lies.
----

local Scene  = require "xl.Scene"
local STI    = require "libs.sti"
local Camera = require "hump.camera"
local Lights = require "xl.Lights"
local Gamestate = require "hump.gamestate"
local ObjWorldManager = require "objects.ObjWorldManager"

local MGame = {}
local function __NULL__() end

-- Metatable used for TileLayers to give them a draw method and the lessThan
-- comparators needed for the TileLayer to go into the scenes.
local TileLayermt = {
	__lt = Scene.lessThan,
	__le = Scene.lessThan,
	draw = function ( self )
		MGame.map:drawLayer( self )
	end,
	tick = __NULL__,
	create = __NULL__,
	destroy = __NULL__,
}
TileLayermt.__index = TileLayermt

-- MGamestate callback
function MGame:init()
	self.locked = false     -- is the game state locked or isn't it
	self.ticks  = 0         -- how many ticks have we run through so far?
	self.gameTime = 0
	self.scene  = Scene.new(40)      -- the main drawing scene. Scene = everything that is on screen in the Game world. Very important and very common in every game
	self.hud    = Scene.new(20)      -- the HUD scene. 
	self.backgrounds = Scene.new(10) -- the level backgrounds.
	self.cam    = Camera()  -- a camera! 
	self.listeners = { -- Listeners are simple, they simply sit around and wait for something to happen. If it does happen it will call a function.
		keypressed = {}, -- These are events. You use this one the most.
		keyreleased = {},
		pretick = {},
		posttick = {},
		roombegin = {},
		roomend = {},
	}
	
	self.savedata  = {}  -- misc save data. THis is just game save data, represented in table format.

	self.permdata  = {}  -- stores permanent object state (i.e. switches, etc.)
	self.scissor   = {} 
	self.entities  = {}  -- list of entities. This is a list of everything currently in the world. It is importante because.....
	self.toDestroy = {}	
	self.world     = love.physics.newWorld()

	self.lights    = Lights.newLightScene(GAME_SIZE.w, GAME_SIZE.h)
	self.wrapPreSolve  = lume.fn(self.preSolve, self)
	self.wrapPostSolve = lume.fn(self.postSolve, self)
	self.wrapOnContactBegin = lume.fn(self.onContactBegin, self)
	self.wrapOnContactEnd   = lume.fn(self.onContactEnd, self)

	self:resize( love.graphics.getDimensions() )

	self.worldManager = ObjWorldManager()
	self.worldManager:create()
	self.listeners["roombegin"][self.worldManager] = self.worldManager

	-----Initialize Canvases for drawing
	self.ActiveCanvas = love.graphics.newCanvas( GAME_SIZE.w, GAME_SIZE.h) --this canvas will hold all active objects (sprites,tiles)
	love.graphics.setBackgroundColor(0,0,0,0)
	------------------------ 
end

-- MGamestate callback:. THis is called constantly.
function MGame:update( dt )
	-- after-tick operations occur before the next tick so the objects will still be updated
	-- before being draw. This preserves the correct function call order.
	if self.next_room then
		local nroom = self.next_room
		self.next_room = nil
		self:loadRoom(nroom)
	end

	self.ticks = self.ticks + 1
	self.gameTime = self.gameTime + dt
	if self.ticks == 1/0 then self.ticks = 0 end
	if self.gameTime == 1/0 then self.gameTime = 0 end

	-- lock the game and update stuff
	self.locked = true
	local baseTime = love.timer.getTime()

	self:emitEvent( "pretick" )
	--xl.DScreen.print("Num Objs: ", "(%f)", util.tablelength(self.entities))
	-- self.player:tick( dt, true ) -- The player object is ALWAYS updated first. Game logic.
	-- xl.DScreen.print("Character DT: ", "(%f)", (love.timer.getTime() - baseTime))
	baseTime = love.timer.getTime()

	self.worldManager:tick(dt)
	lume.each(self.entities, "tick", dt) --The game loops through all the entities in the entity list and calls the tick function for everyone of them.
	--xl.DScreen.print("Entities DT: ", "(%f)", (love.timer.getTime() - baseTime))

	self:emitEvent( "posttick" )
	self.scene:update(dt) -- This updates the sprites on screen to reflect what happened to their game objects.

	--xl.DScreen.print("Scene DT: ", "(%f)", (love.timer.getTime() - baseTime))
	baseTime = love.timer.getTime()

	self.hud:update(dt) -- HUD update

	--xl.DScreen.print("HUD DT: ", "(%f)", (love.timer.getTime() - baseTime))
	baseTime = love.timer.getTime()

	self.backgrounds:update(dt) -- Background update.

	--xl.DScreen.print("BKG DT: ", "(%f)", (love.timer.getTime() - baseTime))
	baseTime = love.timer.getTime()

	self._contacts = {}
	self.world:update(dt) -- update physics. Understand the difference between physics update and game update.

	--xl.DScreen.print("Physics: ", "(%f)", (love.timer.getTime() - baseTime))
	baseTime = love.timer.getTime()

	for k,v in pairs(self.toDestroy) do
		self:mDel(v)
	end
	self.locked = false
end

----
-- Gamestate callback
----
function MGame:draw()
	local loveGraphics = love.graphics
	love.graphics.clear()  -- clear screen
	self:setScissor( true )
	self.cam:attach() -- < do camera movements
	loveGraphics.setShader(Game.currentShader)
	-- draw backgrounds

	love.graphics.setCanvas(self.ActiveCanvas)
	-- self.ActiveCanvas:clear(0,0,0,0)
	love.graphics.clear()
	
	-- draw tilelayers
	for k,v in pairs(self.tilelayers) do
		self.map:drawLayer(v)
	end

	self.scene:draw()     -- < draw the scene
	
	loveGraphics.setShader()
	self.lights:process() -- < draw lights to light canvas
	self.cam:detach()     -- < undo the camera adjustment
	self.lights:overlay() -- < overlay the light canvas

	love.graphics.setCanvas()
	self.cam:attach() -- < do camera movements
	self.backgrounds:draw()
	self.cam:detach()     -- < undo the camera adjustment
	love.graphics.draw(self.ActiveCanvas,0,0)

	-- draw the HUD
	self:nocamera( true )
	self.hud:draw()
	self:nocamera( false )
	
	-- reset the scissor
	self:setScissor( false )
end

----
-- Gamestate callback
----
function MGame:resize(w,h)
	self.lights:resize( w,h )
	local scale, sciz = 1, self.scissor
	scale, sciz[1], sciz[2], sciz[3], sciz[4], sciz.ox, sciz.oy = xl.calculateViewport(GAME_SIZE, w, h, 1, 16)
	self.cam:zoomTo(scale * 2)
end

----
-- Gamestate callback
---
function MGame:mousepressed()
	--self:emitEvent( "mousereleased" )
end

----
-- Gamestate callback
----
function MGame:keypressed( key, isrepeat )
	if key == "escape" and not self.DialogActive then
		love.event.quit()
	end
	self:emitEvent( "keypressed", key, isrepeat )
end

----
-- Gamestate callback
----
function MGame:keyreleased( key, isrepeat )
	self:emitEvent( "keyreleased", key, isrepeat )
end

----
-- Gamestate callback
----
function MGame:quit()
	Gamestate.push( require "state.QuitMenu" )
	-- return true
end

----
-- Change the current overlay. The overlay can be and object with a draw()
-- function which will be the final thing to be drawn each frame. Alternately
-- the overlay can be a color table in the format {r,g,b,a}. In this case
-- a rectangle covering the screen will be drawn using this color.
-- @param {table} overlay - The new overlay or nil to diable it.
----
function MGame:setOverlay( overlay )
	self.overlay = overlay
end

----
-- Public accessor for the overlay.
-- @return the current overlay
----
function MGame:getOverlay(  )
	return self.overlay
end

function MGame:emitEvent( name, ... )
	for _,entity in pairs(self.listeners[name]) do
		-- lume.trace(name)
		-- lume.trace(entity)
		entity[name](entity, ...)
	end
end

----
-- Adds an entity to the game.
-- @param {Entity} entity - The entity to be added to the game.
-- @return entity
----
function MGame:add(entity)
	-- add entity to the entity list
	self.entities[entity] = entity
	-- try to call load on the entity
	if entity.permanentid and self.permdata[entity.permanentid] then
		entity:load( self.permdata[entity.permanentid] )
	end
	-- call create on the entity
	entity:create()
	-- add entity to listeners
	for k,v in pairs(self.listeners) do
		if entity[k] then
			v[entity] = entity
		end
	end
	return entity
end

----
-- Removes an entity from the game.
-- @param {Entity} entity - The entity to be removed.
-- @return entity
----
function MGame:del(entity)
	self.entities[entity].destroyed = true
	self.entities[entity] = nil
	self.toDestroy[entity] = entity
end

function MGame:mDel( entity )
	local permid = entity.permanentid
	self.toDestroy[entity] = nil
	if permid then
		self.permdata[permid] = self.permdata[permid] or {}
		entity:save( self.permdata[permid] )
	end
	entity:destroy()
	self.entities[entity] = nil

	-- remove entity from listeners
	for k,v in pairs(self.listeners) do
		v[entity] = nil
	end
	return entity
end

-- Check if an entity exists
function MGame:exists( entity )
	return self.entities[entity]
end

----
-- Recreates entities from a list of previously stored entities.
-- Each entity will be recreated using util.recreateObject then it will be
-- loaded and added in to the game.
-- @param {table<?,entity>} entities - The table of entity definitions to
--        recreate. 
----
function MGame:recreateEntities( entities )
	for _,entity in pairs(entities) do
		local inst = util.recreateObject( entity )
		self:add(inst)
	end
end

----
-- Loads the named room. If the game is locked then this will be delayed until
-- the game state is again unlocked.
-- @param {string} name - Path of the room to load (like in a require statement)
----
function MGame:loadRoom( name )
	if (type(name) == "table") then
		-- lume.trace("load pre-loaded Table")
		self.curMapTable = util.deepcopy(name)
	else
		assert(love.filesystem.isFile(name..".lua"), "Room resource '" .. name .. "' doesn't exist")
	end

	if self.locked then
		self.next_room = name
	else
		self:emitEvent( "roomend" )
		-- save references to persistent entities
		local persistentEntities = {}
		for k,v in pairs(self.entities) do
			if v.persistent then
				table.insert(persistentEntities, v)
			end
		end
		self:i_loadRoom( name, true )
		for k,v in pairs(persistentEntities) do
			self:add(v)
		end
	end
end

----
-- Callback for World
-- @param {Body} a - the first body
-- @param {Body} b - the second body
-- @param {Contact} contact - the contact between them
----
function MGame:onContactBegin(a, b, contact)
	local ct = self._contacts
	if ct[contact] then return end
	ct[contact] = true
	local udA, udB = a:getBody():getUserData(), b:getBody():getUserData()
	if contact:isTouching() and udA and udB then
		local onCollide = __NULL__
		;(udA.onCollide or onCollide)( udA, udB, contact )
		;(udB.onCollide or onCollide)( udB, udA, contact )
	end
end

----
-- Callback for World
-- @param {Body} a - the first body
-- @param {Body} b - the second body
-- @param {Contact} contact - the contact between them
----
function MGame:onContactEnd(a, b, contact)
	local ct = self._contacts
	if ct[contact] then return end
	ct[contact] = true
	local udA, udB = a:getBody():getUserData(), b:getBody():getUserData()
	if not contact:isTouching() and udA and udB then
		local postCollide = __NULL__
		;(udA.postCollide or postCollide)( udA, udB, contact )
		;(udB.postCollide or postCollide)( udB, udA, contact )
	end
end

----
-- Callback for World
-- @param {Body} a - the first body
-- @param {Body} b - the second body
-- @param {Contact} contact - the contact between them
----
function MGame:preSolve( a, b, contact )
	-- body
	local udA, udB = a:getBody():getUserData(), b:getBody():getUserData()
	if contact:isTouching() and udA and udB then
		local preSolve = __NULL__
		;(udA.preSolve or preSolve)( udA, udB, contact )
		;(udB.preSolve or preSolve)( udB, udA, contact )
	end
end

----
-- Callback for World
-- @param {Body} a - the first body
-- @param {Body} b - the second body
-- @param {Contact} contact - the contact between them
-- @param {...} ... yeah that stuff...
----
function MGame:postSolve( a, b, contact, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)
	-- body
	local udA, udB = a:getBody():getUserData(), b:getBody():getUserData()
	if contact:isTouching() and udA and udB then
		local postSolve = __NULL__
		;(udA.postSolve or postSolve)( udA, udB, contact )
		;(udB.postSolve or postSolve)( udB, udA, contact )
	end
end

----
-- Load a new room replacing the old one.
-- @param {string} name - room name
-- @param {boolean} loadData - load objects from the room
----

-- This function loads a room from a table containing the room's information.
function MGame:i_loadRoom( name, loadData )
	self.worldManager:onRoomLoad( name, self.roomname )
	if type(name) == "table" then
		self.roomname = name.name
	else
		self.roomname = name
	end

	-- clear all entities 
	-- Before we can create a new room, we must clear our entities list to remove objects in the old room.
	-- Otherwise, we would be updating objects that are not currently relevant, and wastes time.
	-- So we delete everything else.
	while next( self.entities ) do
		for key,value in pairs(self.entities) do
			self:mDel(value)
		end
	end

	-- reset room
	-- We clear the other things as well.
	self.backgrounds:clear()
	self.scene:clear()
	self.lights:clear()
	self.tilelayers = {}

	-- reset world
	self.world:destroy() -- leave the old world behind
	self.world = love.physics.newWorld(0,0, true) -- create a brand new world. 
	-- This is an external engine we use.
	-- It is called Love2d, and handles most physics for us. We just need to add objects to the world and define their properties.
	-- All love2d physics objects take place in a world.
	-- When a room is loaded, a new world is created and the old world is destroyed. Any objects that persist between worlds, 
	-- like the character. Are copied back into the new world with the same parameters. tap me when done. Do that always.
	self.world:setCallbacks(self.wrapOnContactBegin, self.wrapOnContactEnd, self.wrapPreSolve, self.wrapPostSolve)

	
	-- load the new room and various properties/options/settings
	if type(name) == "table" then
		self.map = STI.fromTable(name)
		name = name.name
	else
		self.map = STI.new(name)
	end

	local p = self.map.properties
	-- Here we grab a few variables from the map we loaded as set the physics world's properties, such as gravity.
	self.gravity = {(p.gravX or 0), (p.gravY or 480)}
	self.lights.enabled = (p.use_lights == "true")
	if p.camOffX then
		Game.debugCam.offsetx = p.camOffX
	end
	if p.camOffY then
		lume.trace()
		Game.debugCam.offsety = p.camOffY
	end
	self.world:setGravity(unpack(self.gravity)) -- we do it here. tap. Do you want me to talk more about world create or physics. Okay.
	-- New file then.


	for _,layer in ipairs(self.map.layers) do
		if layer.type == "tilelayer" then
			if layer.properties.depth then
				local depth = (tonumber( layer.properties.depth )+ 1) * 32
				setmetatable(layer, TileLayermt)
				layer.z = depth
				self.scene:insert( Scene.makeNode( layer ) )
			else
				table.insert(self.tilelayers, layer)
			end
		end
		if layer.type == "objectgroup" and loadData then
			for _,object in pairs(layer.objects) do
				Log.verbose("Loading object type %q at (%i,%i)", object.type, object.x, object.y)
				--lume.trace(object.type)
				local class = require("objects." .. object.type)
				local inst = class()
				inst.name, inst.x, inst.y, inst.width, inst.height = object.name, object.x, object.y , object.width, object.height
				if object.polyline then
					local x,y,polyline = inst.x, inst.y, object.polyline
					-- x = x - 16
					y = y - 16
					local pointlist = {}
					for k=1,#polyline do
						table.insert(pointlist, x + polyline[k].x)
						table.insert(pointlist, y + polyline[k].y)
					end
					inst.pointlist = pointlist
				end
				for k,v in pairs(object.properties) do
					inst[k] = v
				end			
				self:add( inst )
			end
		end
	end

	if loadData then
		local roomname = string.match( name, "([%w_]-)$" )
		local success,func = pcall( require, "scripts/room/" .. roomname )

		-- this maintains support for the deprecated form of loading room scripts
		-- this should be removed when all old rooms are converted
		if not success then
			print("name=",name,"roomname=",roomname)
			local scriptname = self.map.properties["script"]
			if scriptname then
				require( "scripts/rooms/" .. scriptname )()
			end
			local backgroundScript = self.map.properties["backgroundScript"]
			-- lume.trace("Loading room bkg: " , backgroundScript)
			if backgroundScript then
				require( "scripts/rooms/" .. backgroundScript)()
			end
		else
			func()
		end
		self:emitEvent( "roombegin" )
	end
end

----
-- Finds objects based on their types.
-- @param {string...} - list of type names to search for
-- @return List of tables one for each argument containing the matching entities
----
function MGame:findAllObjects( ... )
	local args = {...}
	local results = {}
	for k,_ in pairs( args ) do
		results[k] = {}
	end
	for _,entity in pairs( self.entities ) do
		for k,ty in pairs( args ) do
			if Class.istype( entity, ty ) then
				table.insert( results[k], entity )
			end
		end
	end
	return unpack( results )
end

function MGame:findObjects( ... )
	local args = {...}
	local results = {}
	for _,entity in pairs( self.entities ) do
		for _,ty in pairs( args ) do
			if Class.istype( entity, ty ) then
				table.insert( results, entity )
			end
		end
	end
	return results
end

function MGame:findObjectsWithModule( ... )
	local args = {...}
	local results = {}
	for _,entity in pairs( self.entities ) do
		if Class.istype( entity, "ObjBase" ) then
			for _,ty in pairs( args ) do
				if entity:hasModule( ty ) then
					table.insert( results, entity )
				end
			end
		end
	end
	return results
end

function MGame:findObjectsAt( x, y )
	local x1,y1,x2,y2 = x, y, x + 0.1, y + 0.1
	return self:findObjectsIn( x1, y1, x2, y2 )
end

----
-- Uses Box2D collision detection to find all objects on the line path between
-- points 1 and 2. Point 1 is given by (x1,y1) and point 2 is given by (x2,y2).
-- @param {number} x1 - x-coordinate of first point
-- @param {number} y1 - y-coordinate of first point
-- @param {number} x2 - x-coordinate of second point
-- @param {number} y2 - y-coordinate of second point
-- @return A list of all the objects which have Box2D fixtures on the line
--         between (x1,y1) and (x2,y2)
----
function MGame:findObjectsIn( x1, y1, x2, y2 )
	local duptracker = {}
	local objects = {}
	local function callback( fixture, x, y, xn, yn, fraction )
		local ud = fixture:getBody():getUserData()
		if not duptracker[ud] then
			duptracker[ud] = true
			table.insert( objects, ud )
		end
		return 1
	end
	self.world:rayCast( x1, y1, x2, y2, callback )
	return objects
end

function MGame:getTicks()
	return self.ticks
end

function MGame:nocamera(on)
	local loveGraphics = love.graphics
	if on then
		loveGraphics.push()
		loveGraphics.origin()
		loveGraphics.translate(self.scissor.ox, self.scissor.oy)
	else
		loveGraphics.pop()
	end
end

function MGame:setScissor( on )
	if on then
		love.graphics.setScissor( unpack( self.scissor ) )
	else
		love.graphics.setScissor()
	end
end

function MGame:setPlayer( player, useFrame )
	self.player = player
end
return MGame
