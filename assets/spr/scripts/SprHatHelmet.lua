local ane = {
	stand = {
		row = 1,
		range = 1,
		downRow = 1,
		downRange = 2,
		upRow = 1,
		upRange = 8,
		delay = 0.1,
		priority = 1,
		-- attachMod = {{{angle=0,x=0,y=0}}},
		-- attachUp = {{{angle=0,x=0,y=0,z=-10}}},
		-- attachDown = {{{angle=0,x=0,y=0,z=10}}}

	},
	walk = {
		row = 1,
		range = 1,
		downRow = 1,
		downRange = 2,
		upRow = 1,
		upRange = 8,
		delay = 0.1,
		priority = 1,
		-- attachMod = {{{angle=0,x=0,y=0}}},
		-- attachUp = {{{angle=0,x=0,y=0,z=-10}}},
		-- attachDown = {{{angle=0,x=0,y=0,z=10}}}
	},
}

local pce = {
	name = "hat",
	path = "assets/spr/head/head_helmet.png",
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