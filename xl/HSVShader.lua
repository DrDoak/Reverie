
local HSVShader = love.graphics.newShader[[
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
	float avg = (c.r + c.g + c.b)/3
	return vec4((255/red) * avg, (255/green) * avg , (255/blue) * avg, c.a);
}
#endif
]]

HSVShader:send("red", 1)
HSVShader:send("green", 0)
HSVShader:send("blue", 1)
HSVShader:send("alpha", 1)

return HSVShader