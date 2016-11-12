local ModPartEmitter = Class.create("ModPartEmitter", Entity)

function ModPartEmitter:addEmitter(emitterName , image,funct)
	self.psystems = self.psystems or {}
	emitterName = emitterName or "default"
	local img = love.graphics.newImage(image  or "assets/spr/orb_burst.png")
	self.psystems[emitterName] = love.graphics.newParticleSystem(img, 32);
	funct(self.psystems[emitterName])

	-- self.psystems[emitterName]:setParticleLifetime(2, 5); -- Particles live at least 2s and at most 5s.
	-- self.psystems[emitterName]:setLinearAcceleration(-5, -5, 50, 100); -- Randomized movement towards the bottom of the screen.
	-- self.psystems[emitterName]:setColors(255, 255, 255, 255, 255, 255, 255, 0); -- Fade to black.
	
	self.psystems[emitterName].node = Scene.wrapNode( function (  )
		love.graphics.draw(self.psystems[emitterName], self.x, self.y);
	end,
	9000)
	Game.scene:insert( self.psystems[emitterName].node )
	Game.scene:move(self.psystems[emitterName].node, 9000)
end
function ModPartEmitter:emit( emitterName, numParticles )
	self.psystems[emitterName]:emit(numParticles)
end
function ModPartEmitter:destroy()
	for k,v in ipairs(table_name) do
		Game.scene:remove(v.node)
	end
end
return ModPartEmitter