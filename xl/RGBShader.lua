
local RGBShader = love.graphics.newShader[[
extern float red;
extern float green;
extern float blue;
extern float alpha;

#ifdef PIXEL
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec4 c = Texel(texture, texture_coords);
	float total = red + green + blue;
	float avg = (c.r + c.g + c.b);
	float weight = alpha/255;
	float nred = c.r + (((red/255) * avg) - c.r) * weight;
	float ngreen = c.g + (((green/255) * avg) - c.g) * weight;
	float nblue = c.b + (((blue/255) * avg) - c.b) * weight;
	return vec4(nred,ngreen ,nblue, c.a); //average colorshade
	//return vec4(max(c.r,red), max(c.g,green), max(c.b,blue), c.a);
}
#endif
]]

RGBShader:send("red", 255)
RGBShader:send("green", 0)
RGBShader:send("blue", 0)
RGBShader:send("alpha", 1)

return RGBShader