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
		attachMod = {{"waist",{angle=0,x=0,y=0}}}
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
		attachMod = {{"waist",{angle=0,x=1,y=-3},{x=1,y=-2},{x=1,y=-1},{x=1,y=-2}}},
		attachUp = {{"waist",{angle=0,x=0,y=-3},{x=0,y=-2},{x=0,y=-3},{x=0,y=-2}}},
		attachDown = {{"waist",{angle=0,x=0,y=-3},{x=0,y=-2},{x=0,y=-3},{x=0,y=-2}}}
	}
}

local pce = {
	name = "legs",
	path = "assets/spr/legs/red_skirt.png",
	width = 96,
	height = 64,
	attachPoints = {
		waist = {x = 48,y = 18}
	},
	animations = ane
}
return pce