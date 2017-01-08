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
		attachMod = {{"neck",{angle=0,x=2,y=0}}},
		attachDown = {{"neck",{angle=0,x=0,y=0,z=-10}}},
		attachUp = {{"neck",{angle=0,x=0,y=0,z=10}}}
	},
	walk = {
		row = 1,
		range = 1,
		upRow = 3,
		upRange = 1,
		downRow = 2,
		downRange = 1,
		delay = 0.1,
		priority = 1,
		attachMod = {{"neck",{angle=0,x=2,y=0}}},
		attachDown = {{"neck",{angle=0,x=0,y=0,z=-10}}},
		attachUp = {{"neck",{angle=0,x=0,y=0,z=10}}}
	}
}

local pce = {
	name = "body",
	path = "assets/spr/body/peridot.png",
	width = 64,
	height = 64,
	-- z = 100,
	attachPoints = {
			waist = {x = 32,y = 56},
			neck = {x = 31,y = 28}
		},
	connectSprite = "legs",
	connectPoint = "waist",
	connectMPoint = "waist",
	animations = ane
}
return pce