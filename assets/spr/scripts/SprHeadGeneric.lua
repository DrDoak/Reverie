local ane = {
	stand = {
		row = 1,
		range = 1,
		downRow = 1,
		downRange = 2,
		upRow = 1,
		upRange = 3,
		delay = 0.1,
		priority = 1,
		attachMod = {{"top",{angle=0,x=0,y=0}}},
		attachUp = {{"top",{angle=0,x=0,y=0,z=1}}},
		attachDown = {{"top",{angle=0,x=0,y=0,z=1}}}

	},
	walk = {
		row = 1,
		range = 1,
		downRow = 1,
		downRange = 2,
		upRow = 1,
		upRange = 3,
		delay = 0.1,
		priority = 1,
		attachMod = {{"top",{angle=0,x=0,y=0}}},
		attachUp = {{"top",{angle=0,x=0,y=0,z=1}}},
		attachDown = {{"top",{angle=0,x=0,y=0,z=1}}}
	},
}

local pce = {
	name = "head",
	path = "assets/spr/head/generic_head.png",
	width = 80,
	height = 72,
	attachPoints = {
			center = {x = 40,y = 36},
			neck = {x = 40,y = 46},
			top = {x=40,y=13}
		},
	connectSprite = "body",
	connectPoint = "neck",
	connectMPoint = "neck",
	animations = ane
}
return pce