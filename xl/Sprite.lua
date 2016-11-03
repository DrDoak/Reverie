----
-- xl/Sprite.lua
----

local Transformable = require "xl.Transformable"
local Scene = require "xl.Scene"
local anim8 = require "anim8"
local lume = lume

local WHITE = {255, 255, 255, 255}

local SpriteMT = Class.new{
	type = "Sprite",
	__includes = Transformable,
	__lt = Scene.lessThan,
	__le = Scene.lessThan,
}

function SpriteMT:init(image, frameWidth, frameHeight, border, z)
	if type(image) == "string" then
		self.imagename = image
		image = love.graphics.newImage(image)
	end
	frameWidth = frameWidth or image:getWidth()
	frameHeight = frameHeight or image:getHeight()
	self.image = image
	self.grid = anim8.newGrid(frameWidth, frameHeight, image:getWidth(), image:getHeight(), 0, 0, border)
	self._fps = 0
	self.frameWidth = frameWidth
	self.frameHeight = frameHeight
	self.timer = 0
	self.angle = 0
	self.index = 0
	self.color = WHITE
	self.paused = 0
	self._dirty = true
	self.blendMode = "alpha"
	self:setQuad( 0, 0, 0, 0 )
	self:setSize(false, false)
	self:setAnimation(1,1,1)
	Transformable.init(self)
	self.z = self.z or 0
	Scene.makeNode(self)
	self:updateQuad( true )
end

function SpriteMT:getImageName()
	return self.imagename
end

function SpriteMT:draw()
	local floor = math.floor
	local sx = self.sx * self.sizescalex
	local sy = self.sy * self.sizescaley
	local loveGraphics = love.graphics
	if self.blendMode ~= "alpha" then
		loveGraphics.setBlendMode(self.blendMode)
	end
	loveGraphics.setColor(self.color)
	loveGraphics.draw(self.image, self.frame, floor(self.x), floor(self.y), self.angle, sx, sy, self.ox, self.oy)
	loveGraphics.setColor(255,255,255,255)
	if self.blendMode ~= "alpha" then
		loveGraphics.setBlendMode("alpha")
	end
end

function SpriteMT:update(dt)
	if not self.paused then
		self.paused = 0
	end
	if self._fps ~= 0 and  self.paused <= 0 then
		local tm = self.timer + dt
		local rate = 1 / math.abs(self._fps)
		if tm > rate then
			tm = tm - rate
			if (self.noLoop and self.index == #self._frames -1) then
				self.priority = 0
				self._fps = 0
			else
				self:setIndex(self.index + lume.sign(self._fps))
				self:onUpdate()
			end
		end
		self.timer = tm
	end
	if self.paused and self.paused > -100 then
		self.paused = self.paused - dt
	end
	self:updateQuad()
end

function SpriteMT:onUpdate( )
end

function SpriteMT:setBlendMode( blendMode )
	self.blendMode = blendMode
end

function SpriteMT:setAngle(sAngle)
	self.angle = sAngle
end

function SpriteMT:setColor(red, green, blue, alpha)
	if not red then
		self.color = WHITE
	elseif type(red) == "table" then
		self.color = red
	else
		self.color = { red, green, blue, alpha or 255 }
	end
end

function SpriteMT:getColor()
	return unpack( self.color )
end

function SpriteMT:setSize(szx, szy)
	self.sizex = szx
	self.sizey = szy
	self._dirty = true
end

function SpriteMT:getSize()
	return self.sizex, self.sizey
end

function SpriteMT:getImgSize()
	return self.frameWidth, self.frameHeight
end

function SpriteMT:setIndex(index)
	--lume.trace(index)
	assert(index ~= 1/0, "index cannot be infinity")
	--lume.trace(index)
	assert(index == math.floor(index), "index must be an integer")
	local frameCount = #self._frames
	index = index < 0 and index + frameCount or (index % frameCount)
	if self.index ~= index then
		self.index = index
		self._dirty = true
	end
end

function SpriteMT:getIndex()
	return self.index
end

function SpriteMT:fps(v)
	if v then
		assert(v ~= 1/0, "fps cannot be infinity")
		self._fps = v
	end
	return self._fps
end

function SpriteMT:pause( time )
	self.paused = time
end

function SpriteMT:resume(  )
	self.paused = 0
end

function SpriteMT:resetAnimation( )
	if self.index then
		self:setIndex(0)
	end
	self.timer = 0
end

function SpriteMT:setAnimation( rangeX, rangeY, durations, noLoop )
	local rangexy
	if (self.rangeX ~= rangeX and self.rangeY ~= rangeY and self.noLoop ~= noLoop) then
		self:resetAnimation()
	end
	if type(rangeX) == "table" then
		rangexy = rangeX
		noLoop = durations
		lume.trace()
		durations = rangeY
	else
		rangexy = {rangeX, rangeY}
	end
	self:setFrames(self.grid(unpack(rangexy)))
	if not durations then
		self:pause()
	else
		self:fps(durations)
	end
	self.rangeX = rangeX
	self.rangeY = rangeY
	self.durations = durations
	self.noLoop = noLoop
end

function SpriteMT:setDepth( z )
	if z ~= 0 and self.z ~= z then
		self.z = z
		--lume.trace(self._fps)

		--Game.scene:move(self,z)
	end
end
function SpriteMT:getAnimation()
	return self.rangeX, self.rangeY, self.durations, self.onLoop
end

function SpriteMT:setQuad( x, y, w, h )
	local qq
	if tostring( x ) == "Quad" then
		qq = x
	else
		qq = love.graphics.newQuad( x, y, w, h, self.image:getWidth(), self.image:getHeight() )
	end
	self:setFrames( {qq} )
	-- self:pause()
end

function SpriteMT:setWrap( wrap )
	self.image:setWrap( wrap and "repeat" or "clamp" )
end

function SpriteMT:setFrames(frames)
	assert(type(frames) == "table", ("frames should be table was %q"):format(type(frames)) )
	assert(#frames > 0, "Length of frames must be > 0")
	self._frames = frames
	self.index = self.index % #self._frames
	self._dirty = true
end

function SpriteMT:getFrames()
	return self._frames
end

function SpriteMT:updateQuad( force )
	if force or self._dirty then
		self.frame = self._frames[self.index + 1]
		local fx, fy, fw, fh = self.frame:getViewport()
		self.sizescalex = self.sizex and self.sizex / fw or 1
		self.sizescaley = self.sizey and self.sizey / fh or 1
		self._dirty = false
	end
end

return SpriteMT
