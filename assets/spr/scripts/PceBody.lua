local ane = {
	stand = {
		row = 1,
		range = 1,
		delay = 0.1,
		priority = 1,
		attachMod = {{{angle=0,x=0,y=0}}}
	},
	slash_p = {
		row = 1,
		range = 2,
		delay = 0.1,
		priority = 1,
		attachMod = {{"hand1",{angle= 250,x=-5,y=0}}}
	},
	slash_r = {
		row = 1,
		range = 3,
		delay = 0.1,
		priority = 1,
		attachMod = {{"hand1",{angle=0,x=4,y=0}}}
	}
}

local pce = {
	name = "body",
	path = "assets/spr/body.png",
	width = 32,
	height = 32,
	attachPoints = {
			center = {x = 16,y = 24},
			hand1 = {x = 16,y = 16}
		},
	connectSprite = "legs",
	connectPoint = "center",
	connectMPoint = "center",
	animations = ane
}
return pce