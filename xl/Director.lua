local Keymap  = require "xl.Keymap"
local Director = Class( "Director" )

function Director:init( f ,args)
	self.func = f
	self.routine = coroutine.create( self.func )
	self.args = args
	self.timer = self.timer or 0
end

function Director.wrap( f ,...)
	local args = {...}
	return function ()
		return Director( f ,args)
	end
end

function Director:update( dt )
	if not self:isFinished() then
		if self.key then
			if Keymap.isPressed(self.key) then
				self.key = nil
				self:processCo()
			end
		else
			self.dt = dt
			if self.timer > 0 then
				self.timer = self.timer - dt
			end
			if self.timer <= 0 then
				self:processCo()
			end
		end
	end
end

function Director:processCo(  )
	local params = { self }
	repeat
		params = { coroutine.resume( self.routine, unpack(params) ) }
		-- lume.trace( unpack(params) )
		if table.remove(params, 1) then
			if #params > 0 then
				local cmd = params[1]
				if cmd == "pause" then
					self.timer = params[2] or 0
					params = {}
				elseif cmd == "create" then
					local tempObj = util.create( unpack(params, 2) )
					Game:add( tempObj )
					params = { tempObj }
				elseif cmd == "key" then
					self.key = params[2] or "use"
					params = {}
				elseif type(cmd) == "function" then
					params = { cmd( unpack(params, 2) ) }
				end
			end
		else
			local errorMessage = debug.traceback( self.routine, params[1] )
			error( "\n\nReal Error:\n" .. errorMessage )
		end
	until #params == 0
end

function Director.pause( time )
	coroutine.yield( "pause", time )
end

function Director.pauseK( key )
	coroutine.yield( "key", key)
end
function Director.run( fn, ... )
	coroutine.yield( fn, ... )
end

function Director:isFinished(  )
	return coroutine.status(self.routine) == "dead"
end

return Director