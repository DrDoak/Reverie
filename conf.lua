
io.stdout:setvbuf("no")

GAME_SIZE = { w = 800, h = 600, }

local function compare_versions( versiona, versionb )
	local am = versiona:gmatch( "%d+" )
	local bm = versionb:gmatch( "%d+" )
	local a,b = am(),bm()
	while a or b do
		a,b = tonumber(a) or 0, tonumber(b) or 0
		local d = a - b
		if d ~= 0 then
			return d
		end
		a,b = am(),bm()
	end
	return 0
end

function version_check(  )
	if not love.getVersion then
		return "0.9.1"
	end
	local major,minor,revision,codename = love.getVersion()
	local versionstr = string.format("%d.%d.%d", major, minor, revision)
	return versionstr
end

function love.conf(t)
	t.identity = "Reverie"
	t.version = version_check()
	t.console = false
	
	t.window.title = "Reverie"
	t.window.icon  = "assets/icon32.png"
	t.window.fullscreen = false
	-- t.window.fullscreentype = "normal"
	t.window.width = GAME_SIZE.w
	t.window.height = GAME_SIZE.h
	t.window.resizable = false
	t.window.vsync = true
	t.window.fsaa = 0
	
	t.modules.joystick = false
end
