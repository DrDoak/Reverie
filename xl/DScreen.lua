
local DBG = {
}

local opts = {
	color = {255, 255, 255, 255},
	x = 180,
	y = 5,
	scale = 1,
	enabled = true,
}
local dataset = {}

function DBG.set(id,value)
	assert(type(id)=="string", "id must be a string")
	if value == nil then value = "nil" end
	if value == "" then value = nil end
	dataset[id] = value
end

function DBG.print(id,format,...)
	local value = string.format(format,...)
	DBG.set(id,value)
end

function DBG.setColor(r,g,b,a)
	opts.color = {r,g,b,a}
end

function DBG.setPosition(x,y)
	opts.x = x
	opts.y = y
end

function DBG.getPosition()
	return opts.x, opts.y
end

function DBG.setScale(scale)
	opts.scale = scale
end

function DBG.getScale()
	return opts.scale
end

function DBG.clear()
	dataset = {}
end

function DBG.draw()
	if opts.enabled then
		local xx = opts.x
		local yy = opts.y
		love.graphics.setFont( xl.getFont() )
		love.graphics.setColor(opts.color)
		love.graphics.push()
		love.graphics.origin()
		love.graphics.scale(opts.scale, opts.scale)
		for k,v in pairs(dataset) do
			love.graphics.print(k .. "= " .. tostring(v), xx, yy)
			yy = yy + love.graphics.getFont():getHeight()
		end
		love.graphics.pop()
	end
end

function DBG.toggle()
	opts.enabled = not opts.enabled
end

function DBG.enable(enabled)
	assert(enabled == true or enabled == false, "paramater must be true or false")
	opts.enabled = enabled
end

function DBG.isEnabled()
	return opts.enabled
end

return DBG
