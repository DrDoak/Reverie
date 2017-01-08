local ModPartEmitter = Class.create("ModPartEmitter", Entity)
local Scene = require "xl.Scene"

function ModPartEmitter:create()
	self.psystems = self.psystems or {}
	self.nodes = self.nodes or {}
end

function ModPartEmitter:addEmitter(emitterName , image,size, funct)
	emitterName = emitterName or "default"
	local img = love.graphics.newImage(image  or "assets/spr/fx/orb_burst.png")
	self.psystems[emitterName] = love.graphics.newParticleSystem(img, size or 32);
	if funct then
		funct(self.psystems[emitterName])
	end
	--self.psystems[emitterName]:setLinearAcceleration(-5, -4, 100, 100); -- Randomized movement towards the bottom of the screen.
	--self.psystems[emitterName]:setColors(255, 255, 255, 255, 255, 255, 255, 0); -- Fade to black.
	self.nodes[emitterName] = Scene.wrapNode( function (  )
		love.graphics.draw(self.psystems[emitterName],self.x,self.y);
	end, 9000)
	Game.scene:insert( self.nodes[emitterName] )
end
function ModPartEmitter:emit( emitterName, numParticles )
	self.psystems[emitterName]:emit(numParticles)
end

function ModPartEmitter:setRandomDirection( emitterName, speed )
	local psys = self.psystems[emitterName]
	psys:setDirection(0)
	psys:setSpeed(speed)
	psys:setSpread(math.pi * 2)
end

function ModPartEmitter:tick( dt )
	for k,v in pairs(self.psystems) do
		v:update(dt)
	end
end

function ModPartEmitter:setAcceleration( emitterName, minSpeed, maxSpeed )
	local minX = minSpeed
	local maxX = maxSpeed or minSpeed
	local minY = minSpeed
	local maxY = maxSpeed or minSpeed
	self.psystems[emitterName]:setLinearAcceleration(minX, minY, maxX, maxY); -- Randomized movement towards the bottom of the screen.
end

function ModPartEmitter:setFade( emitterName )
	self.psystems[emitterName]:setColors(255, 255, 255, 255, 255, 255, 255, 0); -- Fade to black.
end

function ModPartEmitter:setRandRotation( emitterName, minR, maxR , variation)
	local psys = self.psystems[emitterName]
	psys:setSpin(minR,maxR)
	psys:setSpinVariation(variation)
end

function ModPartEmitter:setAreaSpread( emitterName, distribution, dx,dy)
	self.psystems[emitterName]:setAreaSpread( distribution, dx, dy )
end

function ModPartEmitter:destroy()
	for k,v in pairs(self.psystems) do
		v:reset()
		Game.scene:remove(self.nodes[k])
	end
end
return ModPartEmitter