local ane = {}

local pce = {
	name = "weapon",
	path = "assets/spr/torch_item.png",
	width = 64,
	height = 32,
	imgX = 32,
	imgY = 16,
	originX = 8,
	originY = 16,
	attachPoints = {
			grip1 = {x = 8,y=16}
		},
	connectSprite = "body",
	connectPoint = "hand1",
	connectMPoint = "grip1",
	animations = ane
}

return pce