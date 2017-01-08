local ane = {
	stand = {
		row = 1,
		range = 1,
		upRow = 3,
		upRange = 1,
		downRow = 2,
		downRange = 1,
		delay = 0.1,
		priority = 1,
		attachMod = {{"waist",{angle=0,x=0,y=0}}},
		attachUp = {{"waist",{angle=0,x=-1,y=0}}},
		attachDown = {{"waist",{angle=0,x=-5,y=0}}},
	},
	walk = {
		row = 1,
		range = "2-5",
		upRow = 3,
		upRange = "2-5",
		downRow = 2,
		downRange = "2-5",
		delay = 0.1,
		priority = 1,
		attachMod = {{"waist",{angle=0,x=-1,y=-3},{x=-1,y=-2},{x=-1,y=-1},{x=-1,y=-2}}},
		attachUp = {{"waist",{angle=0,x=-1,y=-3},{x=-1,y=-2},{x=0,y=-3},{x=0,y=-2}}},
		attachDown = {{"waist",{angle=0,x=-5,y=-2},{x=-5,y=-1.5},{x=-4,y=-2},{x=-4,y=-1.5}}}
	}
}

local pce = {
	name = "legs",
	path = "assets/spr/legs/large_boots.png",
	width = 96,
	height = 64,
	originX = 48,
	originY = 20,
	attachPoints = {
		center = {x = 48,y=80},
		waist = {x = 48,y = 6}
	},
	animations = ane
}
return pce