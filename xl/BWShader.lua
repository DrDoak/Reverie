local test, test2, test3

local BWShader = love.graphics.newShader[[
extern float red;
extern float green;
extern float blue;
extern float alpha;

#ifdef PIXEL
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec4 c = Texel(texture, texture_coords);
	float total = red + green + blue;
	float rweight = red/total;
	float bweight = blue/total;
	float gweight = green/total;
	//return vec4(c.r, c.r,c.r,c.a); BW relative to red
	//return vec4((c.r + c.g + c.b) * rweight, (c.r + c.g + c.b) * gweight, (c.r + c.g + c.b) * bweight, c.a); //True BW
	return vec4((c.r + c.g + c.b)/3, (c.r + c.g + c.b)/3 , (c.r + c.g + c.b)/3, c.a); //True BW
	//return vec4(0.0, 0.0, (c.r + c.g + c.b)/3, c.a); //Blue mode
	//return vec4(c.b,c.g,c.r, c.a); swap blue and red
}
#endif
]]
--[[
float total = red + green + blue
float rweight = red/total
float bweight = blue/total
float gweight = green/total
(c.r + c.g + c.b)/3, (c.r + c.g + c.b)/3, (c.r + c.g + c.b)/3, c.a
]]
--BWShader:send("alpha", 1)

return BWShader