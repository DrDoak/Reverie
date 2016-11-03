
local _NOOP = function () end

local Entity = Class.new {
	persistent = false,
	world = function () return Game.world end,
	type = "Entity",

	-- overridable methods
	create = _NOOP,
	destroy = _NOOP,
	draw = _NOOP,
	onCollide = _NOOP,
	postCollide = _NOOP,
}

function Entity:tick( dt )
end

return Entity

