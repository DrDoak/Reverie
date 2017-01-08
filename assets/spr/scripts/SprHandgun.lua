local ane ={
	stand = {
		row = 1,
		range = 2,
		upRow = 3,
		upRange = 2,
		downRow = 2,
		downRange = 2,
		delay = 0.1,
		priority = 1,
	},
	aim_handgun = {
		row = 1,
		range = 1,
		upRow = 3,
		upRange = 1,
		downRow = 2,
		downRange = 1,
		delay = 0.1,
		priority = 1,
	}
}
ane.walk = ane.stand
local pce = {
	name = "weapon",
	path = "assets/spr/eqp/handgun.png",
	width = 32,
	height = 32,
	imgX = 16,
	imgY = 16,
	attachPoints = {
			grip1 = {x = 16,y=16}
		},
	connectSprite = "body",
	connectPoint = "hand1",
	connectMPoint = "grip1",
	animations = ane
}
return pce