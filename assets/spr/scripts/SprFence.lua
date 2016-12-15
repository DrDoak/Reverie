local ane = {
	edge = {
		row = 1,
		range = 2,
		delay = 0.1
	},
	main = {
		row = 1,
		range = 1,
		delay = 0.1
	}
}

local pce = {
	name = "main",
	path = "assets/spr/fence.png",
	width = 32,
	height = 32,
	imgX = 32,
	imgY = 32,
	originX = 16,
	originY = 16,
	attachPoints = {center = {x=16,y=16}},
	animations = ane
}
return pce