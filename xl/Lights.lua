----
-- xl/Lights.lua
-- 
-- Lights is the lighting engine used by Reverie. I will try to add more
-- documentation in as I go but for now this is what you get.
----

local AREA_COLOR = {0, 0, 0, 10}
local SPOT_COLOR = {0, 0, 0, 10}
local DARK_COLOR = {0, 0, 0, 250}

local LightShader = love.graphics.newShader[[
extern float bright;
extern float dark;
extern float red;
extern float green;
extern float blue;

#ifdef PIXEL
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{

	float gradient = mix(dark, bright, color.a);
	float newR = mix(dark, red, color.r);
	float newG = mix(dark, green, color.g);
	float newB = mix(dark, blue, color.b);
	return vec4(newR, newG, newB, gradient);
}
#endif
]]

LightShader:send("bright", 255 / 255)
LightShader:send("dark", 10 / 255)

-- A copy of util.counter. I'm not sure why we need it here but I'm not
-- dealing with that right now.
local function counter( v )
	local count = v or 0
	return function ( value )
		count = value or count + 1
		return count
	end
end

-- set a light's position
local function light_setPosition( self, x, y )
	self.x,self.y = x,y
end

-- set a light's color
local function light_setColor( self, r,g,b)
	self.red,self.green,self.blue = r,g,b
end

-- draw a light
local function light_draw( mesh, self )
	--lume.trace(r,g,b,a)
	--love.graphics.setColor(255,0,0,255)
	LightShader:send("red", self.red)
	LightShader:send("green", self.green)
	LightShader:send("blue", self.blue)
	love.graphics.draw( mesh, self.x, self.y, self.r, self.scale[1] * self.i, self.scale[2] * self.i )
	--love.graphics.setColor(r,g,b,a)
end

local function light_init( self, x, y, i, r )
	self.x = x or 0
	self.y = y or 0
	self.i = i or 1
	self.r = r or 0
	self.red = self.red or 255
	self.green = self.green or 255
	self.blue = self.blue or 255
	self.scale = {}
	self.enabled = true
end

-- generates a color.rcular light mesh with radius 1
local function GenerateAreaLight()
	local color = AREA_COLOR
	local segments = 40
	local vertices = {}

	-- The first vertex is at the center and is white
	table.insert(vertices, {0, 0, 0, 0, 255, 255, 255, 255})

	-- Create the vertices at the edge of the color.rcle.
	for i=0, segments do
		local angle = (i / segments) * math.pi * 2
		local x = math.cos(angle)
		local y = math.sin(angle)
		table.insert(vertices, {x, y, 0, 0, unpack(color)})
	end
	local mesh = love.graphics.newMesh(vertices, "fan") -- use "fan" draw mode
 	mesh:setAttributeEnabled("VertexColor", true)
	return mesh
end

----
-- Generate a new "spotlight" mesh. Spotlights aren't circular. They look more
-- like flashlights actually. I'm not sure why I called them spotlights but I did.
--
-- @param {number} radius - the radius or length of the spotlight. Suggest > 10
-- @param {number} width - the radial width of the spotlight. Suggest values 1 - 3.
-- @param {function} modfunc - a function receiving a parameter x which is a
--        value 0 - 1 saying how close the vertex is to the center (where the
--        distance is the largest). Returns a multiplier which will be used to
--        calculate the distance of each point from the center point.
-- @return the mesh for the spotlight
----
local function GenerateSpotlight(radius, width, modfunc)
	local cos,sin = math.cos, math.sin
	local color = SPOT_COLOR
	local segments = 20
	local vertices = {}
	table.insert(vertices, {0, 0, 0, 0, 255, 255, 255})
	local baseAngle = width / 2
	for i = 0, segments do
		local angle = baseAngle - (i * width / segments)
		local mod = radius * modfunc(1 - math.abs(angle) / baseAngle)
		local x,y = mod * cos(angle), mod * sin(angle)
		table.insert(vertices, {x, y, 0, 0, unpack(color)})
	end
	local mesh = love.graphics.newMesh(vertices, nil, "fan")
	mesh:setVertexColors(true)
	return mesh
end

local AreaLightMesh = GenerateAreaLight()

local SpotLight_mt = {
	init = function ( self, radius, width, angle, modfunc )
		light_init(self)
		local ang = math.rad(angle)
		self:setRadius( radius )
		self:setWidth( width )
		self:setAngleTo(self.x, self.y, self.x + math.cos(ang), self.y + math.sin(ang))
		self.mesh = GenerateSpotlight(radius, width, modfunc)
	end,

	setPosition = light_setPosition,

	setColor = light_setColor,

	setRadius = function ( self, radius )
		self.scale[1] = radius / 10
	end,

	getRadius = function ( self )
		return self.scale[1] * 10
	end,

	setWidth = function ( self, width )
		self.scale[2] = width
	end,

	getWidth = function ( self )
		return self.scale[2]
	end,

	setAngleTo = function (self, x, y, x2, y2)
		if not x2 or not y2 then
			x2,y2 = x,y
			x,y = self.x,self.y
		else
			self.x,self.y = x,y
		end
		self.r = math.atan2(y2 - y, x2 - x)
	end,

	setAngle = function( self,ang )
		self:setAngleTo(self.x, self.y, self.x + math.cos(ang), self.y + math.sin(ang))
	end,

	draw = function(self)
		if self.enabled then
			light_draw( self.mesh, self )
		end
	end,

	clone = function ( self )
		return util.clone_shallow( self )
	end
}

local AreaLight_mt = {
	init = function ( self, radius)
		light_init(self)
		self:setRadius( radius )
		self.mesh = AreaLightMesh
	end,

	setPosition = light_setPosition,

	setColor = light_setColor,

	setRadius = function ( self, radius )
		self.scale[1] = radius + 10
		self.scale[2] = self.scale[1]
	end,

	getRadius = function ( self )
		return self.scale[1]
	end,

	draw = function ( self )
		if self.enabled then
			light_draw( AreaLightMesh, self )
		end
	end,
}

local LightScene_mt = {
	init = function ( self, w, h )
		self._canvas = love.graphics.newCanvas( w,h )
		self._lights = {}
		self._id = counter(2)
		self.enabled = true
		self:setDark(0,0,0,255)
	end,

	add = function ( self, light )
		light.id = light.id or self._id()
		self._lights[light.id] = light
	end,

	del = function ( self, light )
		assert(light.id, "Light must have id property")
		self._lights[light.id] = nil
	end,

	resize = function ( self, w, h )
		if self._canvas:getWidth() ~= w or self._canvas:getHeight() ~= h then
			self._canvas = love.graphics.newCanvas( w,h )
		end
	end,

	process = function ( self, force )
		if self.enabled or force then
			local prev_shader = love.graphics.getShader()
			local prev_canvas = love.graphics.getCanvas()
			-- prepare for lighting
			love.graphics.setCanvas(self._canvas)
			self._canvas:clear(unpack(self._dark))
			love.graphics.setShader( LightShader )
			LightShader:send("bright", 255 / 255)
			LightShader:send("dark", 10 / 255)
			love.graphics.setBlendMode("additive")
			
			-- draw lights
			for k,v in pairs(self._lights) do
				v:draw()
			end

			-- end lighting
			love.graphics.setShader( prev_shader )
			love.graphics.setCanvas(prev_canvas)
			love.graphics.setBlendMode("alpha")
		end
	end,
	iter = function ( self )
		return pairs( self._lights )
	end,

	overlay = function ( self, x, y, force )
		x,y = x or 0, y or 0
		if self.enabled or force then
			love.graphics.setBlendMode("multiplicative")
			love.graphics.draw(self._canvas, x, y)
			love.graphics.setBlendMode("alpha")
		end
	end,

	clear = function ( self )
		for k,v in pairs(self._lights) do
			self:del(v)
		end
	end,

	setDark = function ( self, r, g, b, a )
		if not r then
			-- reset color by cloning DARK_COLOR
			r,g,b,a = unpack(DARK_COLOR)
		elseif type(r) == "table" then
			r,g,b,a = unpack(r)
		else
			r,g,b,a = r, g, b, a or 255
		end
		self._dark = {r, g, b, a}
	end,

	getDark = function ( self )
		return self._dark
	end,
}

local function MakeCtor(meta)
	meta.__index = meta
	return function ( ... )
		local obj = setmetatable({}, meta)
		obj:init(...)
		return obj
	end
end

local Lights = {
	newSpotLight  = MakeCtor(SpotLight_mt),
	newAreaLight  = MakeCtor(AreaLight_mt),
	newLightScene = MakeCtor(LightScene_mt),
}

function Lights.newGradSpotLight( radius, width, angle, rate )
	rate = rate or 1
	return Lights.newSpotLight(radius, width, angle, function ( pos ) return math.pow(pos,rate) end)
end

return Lights