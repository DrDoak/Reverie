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
		-- attachMod = {{{angle=0,x=0,y=0}}},
		-- attachUp = {{{angle=0,x=0,y=0,z=-10}}},
		-- attachDown = {{{angle=0,x=0,y=0,z=10}}}

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
		-- attachMod = {{{angle=0,x=0,y=0}}},
		-- attachUp = {{{angle=0,x=0,y=0,z=-10}}},
		-- attachDown = {{{angle=0,x=0,y=0,z=10}}}
	},
}

local pce = {
	name = "head",
	path = "assets/spr/head/peridot.png",
	width = 64,
	height = 80,
	attachPoints = {
			center = {x = 31,y = 40},
			neck = {x = 31,y = 39}
		},
	connectSprite = "body",
	connectPoint = "neck",
	connectMPoint = "neck",
	animations = ane
}
return pce