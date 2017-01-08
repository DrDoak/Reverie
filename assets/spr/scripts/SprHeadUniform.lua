local ane = {
	stand = {
		row = 1,
		range = 1,
		upRow = 1,
		upRange = 8,
		downRow = 1,
		downRange = 2,
		delay = 0.1,
		priority = 1,
	},
	walk = {
		row = 1,
		range = 1,
		upRow = 1,
		upRange = 8,
		downRow = 1,
		downRange = 2,
		delay = 0.1,
		priority = 1,
	},
}

local pce = {
	name = "hat",
	path = "assets/spr/head/head_scarf.png",
	width = 80,
	height = 72,
	attachPoints = {
			center = {x = 40,y = 36},
			neck = {x = 40,y = 46},
			top = {x=40,y=13},
		},
	connectSprite = "head",
	connectPoint = "top",
	connectMPoint = "top",
	animations = ane
}
return pce