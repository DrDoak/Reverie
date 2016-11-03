
local keymap = {}
local reverseMap = {}
local eventList = {}
local KM = {}

local kbisDown = love.keyboard.isDown

local function __NULL__() end
local __EMPTY__ = {}

function KM.setkey(id, key)
	keymap[id] = {
		key = key,
		keypressed = {},
		keyreleased = {},
	}
	reverseMap[key] = reverseMap[key] or {}
	table.insert(reverseMap[key], id)
end

function KM.getids( key )
	return reverseMap[key]
end

function KM.getkey( id )
	return keymap[id].key
end

function KM.isDown(id)
	local k = keymap[id]
	return kbisDown( k.key )
end

function KM.check( id, key )
	return KM.getkey( id ) == key
end

function KM.isPressed( id )
	return eventList[id] == "pressed"
end

function KM.isReleased( id )
	return eventList[id] == "released"
end

function KM.pressed( id, callback, remove )
	keymap[id].keypressed[callback] = not remove and callback or nil
end

function KM.released( id, callback, remove )
	keymap[id].keyreleased[callback] = not remove and callback or nil
end

function KM.clearEvents(  )
	for k,v in pairs(eventList) do
		eventList[k] = nil
	end
end

function KM.keypressed( key, isrepeat )
	local ids = KM.getids(key)
	for _,id in pairs(ids or __EMPTY__) do
		eventList[id] = not eventList[id] and "pressed" or nil
		for _,callback in pairs( keymap[id].keypressed ) do
			local ty = type(callback)
			if     ty == "function" then
				callback( key, isrepeat, id )
			elseif ty == "table" then
				callback:keypressed( key, isrepeat, id )
			end
		end
	end
end

function KM.keyreleased( key, isrepeat )
	local ids = KM.getids(key)
	for _,id in pairs(ids or __EMPTY__) do
		eventList[id] = not eventList[id] and "released" or nil
		for _,callback in pairs( keymap[id].keyreleased ) do
			local ty = type(callback)
			if     ty == "function" then
				callback( key, isrepeat, id )
			elseif ty == "table" then
				callback:keyreleased( key, isrepeat, id )
			end
		end
	end
end

function KM.mousepressed( x, y, button )
end

function KM.mousereleased( x, y, button )
end

return KM
