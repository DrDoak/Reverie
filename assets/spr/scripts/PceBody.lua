local ane = {
	stand = {
		row = 1,
		range = 1,
		delay = 0.1,
		priority = 1,
		attachMod = {{{x=0,y=0}}}
	}
}

local pce = {
	name = "body",
	path = "assets/spr/body.png",
	width = 32,
	height = 32,
	attachPoints = {
			center = {x = 16,y = 24}
		},
	connectSprite = "legs",
	connectPoint = "center",
	connectMPoint = "center",
	animations = ane
}
return pce