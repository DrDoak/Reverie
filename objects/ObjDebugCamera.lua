local ObjDebugCamera = Class.create("ObjDebugCamera", Entity)
local Timer = require "hump.timer"

local CAMERA_OFFSET = 35
local DIR_TWEEN_TABLE = {
	[0]   = { offsetx =  CAMERA_OFFSET, offsety = 0 },
	[90]  = { offsetx = 0, offsety = -CAMERA_OFFSET },
	[180] = { offsetx = -CAMERA_OFFSET, offsety = 0 },
	[270] = { offsetx = 0, offsety =  CAMERA_OFFSET },
}

ObjDebugCamera.instanceCount = 0
local function addinst(count)
	ObjDebugCamera.instanceCount = ObjDebugCamera.instanceCount + count
end

function ObjDebugCamera:create()
	local mprops = Game.map.properties
	local map = Game.map
	if ObjDebugCamera.instanceCount > 0 then
		Game:del(self)
	else
		addinst(1)
	end
	self.persistent = true
	self.trackPlayer = true
	self.tween = nil
	self.tween_off = function (  )
		self.tween = nil
	end
	Game.debugCam = self
	self.lastDirection = -1 -- force direction detection
	self.offsetx = self.offsetx or 0
	self.offsety = self.offsety or -32
	self.adjustSpeed = 1
	self.maxAdjust = 24
	self.x = 0
	self.y = 0
	self.shakeTime = 0
	self.shakeAngle = 0

	if mprops.minX then
		self.minX = mprops.minX * 16
	else
		self.minX = 0
	end

	if mprops.minY then
		self.minY = mprops.minY * 16
	else
		self.minY = 0
	end

	if mprops.maxX then
		self.maxX = mprops.maxX * 16
	else
		self.maxX = (map.width * map.tilewidth) - self.minX
	end

	if mprops.maxY then
		self.maxY = mprops.maxY * 16
	else
		self.maxY = (map.height * map.tileheight) - self.minY
	end
end

function ObjDebugCamera:destroy()
	addinst(-1)
end

function ObjDebugCamera:tick(dt)
	local mprops = Game.map.properties
	self:itrack()
	self:iShake()
end

function ObjDebugCamera:setOffset( x,y )
	self.offsetx = x
	self.offsety = y
end

function ObjDebugCamera:setTrack( ObjUnit )
	self.target = ObjUnit or Game.player
end

function ObjDebugCamera:itrack()
	local player
	if self.trackPlayer then 
		if self.target and not self.target.destroyed then
			player = self.target
		elseif not Game.player.destroyed then
			player = Game.player
		end

		-- detect player direction
		if player.dir ~= self.lastDirection then
			self.offsetx = self.offsetx + (player.dir * self.adjustSpeed)
		end
		self.lastDirection = player.dir
		if math.abs(self.offsetx) < (self.maxAdjust) then
			self.offsetx = self.offsetx + self.lastDirection
		end
		local px, py = player.body:getPosition()
		self.x = math.floor( px + (self.offsetx))
		self.y = math.floor( py + self.offsety )
	end
	self.x = math.max(self.minX, self.x - GAME_SIZE.w/4) + GAME_SIZE.w/4
	self.x = math.min(self.maxX, self.x + GAME_SIZE.w/4) - GAME_SIZE.w/4
	self.y = math.max(self.minY, self.y - GAME_SIZE.h/4) + GAME_SIZE.h/4
	self.y = math.min(self.maxY, self.y + GAME_SIZE.h/4) - GAME_SIZE.h/4
	
	Game.cam.offsetx = self.offsetx
	Game.cam.offsety = self.offsety
	Game.cam.x = self.x
	Game.cam.y = self.y
	-- if xl.DScreen.isEnabled() then
	-- 	xl.DScreen.set("offsetx", self.offsetx)
	-- 	xl.DScreen.set("offsety", self.offsety)
	-- end
end

function ObjDebugCamera:iShake()
	if self.shakeTime > 0 then
		self.shakeTime = self.shakeTime - 1
		self.shakeAngle = self.shakeAngle + math.pi + math.random(-math.pi/4,math.pi/4)
		local offsetX = math.cos(self.shakeAngle) * self.shakeIntensity
		local offsetY = math.sin(self.shakeAngle) * self.shakeIntensity
		Game.cam.x = self.x + offsetX
		Game.cam.y = self.y + offsetY
	end
end

function ObjDebugCamera:setShake( duration, intensity, speed )
	self.shakeTime = duration
	self.shakeIntensity = intensity or 4
	self.shakeSpeed = speed or 1
end

return ObjDebugCamera
