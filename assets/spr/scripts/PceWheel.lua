local ane = {
	walk = {
				row = 1,
				range = "1-6",
				delay = 0.15,
				priority = 1,
				startFrame = 2
	},
	stand = {
				row = 1,
				range = 1,
				delay = 0.1,
				priority = 1,
				attachMod = {{{x=0,y=0}}}
	},
	run = {
				row = 1,
				range = "1-6",
				delay = 0.06,
				priority = 1,
				startFrame = 2
	},
	jump = {
				row = 1,
				range = 1,
				delay = 0.1,
				priority = 1,
				attachMod = {{{x=0,y=-3}}}
	},
	fall = {
				row = 1,
				range = 1,
				delay = 0.1,
				priority = 1,
				attachMod = {{{x=0,y=2}}}
	},
	slide = {
				row = 1,
				range = 1,
				delay = 0.1,
				priority = 1,
				attachMod = {{{angle = -20,x=0,y=2}}}
	},
	slideMore = {
				row = 1,
				range = 1,
				delay = 0.1,
				priority = 1,
				attachMod = {{{angle = -30,x=0,y=2}}}
	},
	crouch = {
				row = 1,
				range = 1,
				delay = 0.1,
				priority = 1,
				attachMod = {{{x=0,y=-4}}}
	},
	slash_p = {
				row = 1,
				range = 1,
				delay = 0.06,
				noLoop = true,
				attachMod = {{{x=0,y=0}}}
	},
	slash_r = {
				row = 1,
				range = 1,
				delay = 0.06,
				noLoop = true,
				attachMod = {{{x=0,y=0}}}
	},
	hit = {
				row = 1,
				range = 1,
				delay = 0.1,
				priority = 1,
				attachMod = {{{angle = -30,x=0,y=2}}}
	},
}

local pce = {
	name = "legs",
	path = "assets/spr/ugly_wheel.png",
	width = 32,
	height = 32,
	attachPoints = 
		{
			center = {x = 16,y = 16}
		},
	animations = ane
}

return pce