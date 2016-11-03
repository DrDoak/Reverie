--[[
	class TextBox

	TextBox displays text in text boxes. The text is actually a table containing a mix of
	strings and format specifiers. Format specifiers change the formatting of the text.
]]--

local Scene = require "xl.Scene"
local TextEngine = require "xl.TextEngine"

local function load9draw( path )
	local images = {}
	for i=1,9 do
		local fname = path .. tostring(i) .. ".png"
		images[i] = assert( love.graphics.newImage( fname ), "Unable to load image "..fname )
	end
	return images
end

local backgrounds = load9draw( "assets/gui/textbox/textbox" )
local border_size = 24
local DefaultFont = xl.getFont()

local TB = Class.create("TextBox")
TB.__lt = Scene.lessThan -- for Scene
TB.__le = Scene.lessThan -- for Scene 

function TB:init(text, boxWidth, boxHeight, font,align)
	text.color = {255,0,0,255}
	self.engine = TextEngine( text, boxWidth - border_size, font or DefaultFont ,align)
	self.boxWidth = boxWidth
	self.textWidth = boxWidth - (border_size * 2)
	self.boxHeight = boxHeight
	self.backgroundData = TB.BuildBackgroundData( self.boxWidth, self.boxHeight )
	self.relative = "view"
	self.yoffset = 0
	self.z = 0
	Scene.makeNode( self )
	self:setColor()
end

function TB:setWidth(w)
	self.boxWidth = w
	self.textWidth = w - (border_size * 2)
	self.engine:resize( self.textWidth )
	self.backgroundData = TB.BuildBackgroundData( self.boxWidth, self.boxHeight )
	return self
end

function TB:setHeight(h)
	self.boxHeight = h
	self.viewHeight = math.floor( h / self.engine.font:getHeight() )
	self.backgroundData = TB.BuildBackgroundData( self.boxWidth, self.boxHeight )
	return self
end

function TB:setText( text )
	self.engine.text ={text, color={255,0,0,255}}
	self.engine:resize( self.textWidth )
end

function TB:draw()
	-- draw box
	Game:nocamera( true )
	love.graphics.translate( self.x, self.y )
	-- love.graphics.setColor( self.red,self.green,self.blue, self.alpha)
	love.graphics.setColor(self.red,self.green,self.blue,self.alpha)
	TB.drawBackgroundData( self.backgroundData )
	love.graphics.translate( border_size, border_size )
	local scissor_prev = {love.graphics.getScissor()}
	love.graphics.setScissor( Game.scissor[1] + self.x, Game.scissor[2] + self.y,
		self.boxWidth - border_size, self.boxHeight - border_size )
	love.graphics.translate( 0, -self.yoffset )
	self.engine:renderTextFull()
	love.graphics.setScissor( unpack(scissor_prev) )
	love.graphics.setColor( 255,255,255 )
	Game:nocamera( false )
end

function TB:setColor( r, g, b, a )
	self.red = r or 255
	self.green = g or 255
	self.blue = b or 255
	self.alpha = a or 255
end
function TB:update( dt )
end

function TB:setPosition(x,y)
	self.x = x
	self.y = y
	return self
end

function TB:scroll( delta )
	if delta then
		self.yoffset = self.yoffset + delta
		return self
	else
		return self.yoffset
	end
end

function TB:getBox()
	return self.x, self.y, self.boxWidth, self.boxHeight
end

function TB:setRange(first, last)
	local fblock,fblockIndex = self:findBlock( first )
	local lblock,lblockIndex = self:findBlock( last, fblock, fblockIndex )
	-- TODO finish
end

function TB.drawBackgroundData( bgdata )
	local lgdraw = love.graphics.draw
	local qq = bgdata
	local bkgW,bkgH = qq.bkgW,qq.bkgH
	lgdraw(backgrounds[5], qq.center)
	lgdraw(backgrounds[2], qq.top)
	lgdraw(backgrounds[8], qq.top, 0, qq.height - bkgH)
	lgdraw(backgrounds[4], qq.left)
	lgdraw(backgrounds[6], qq.left, qq.width - bkgW, 0)
	lgdraw(backgrounds[1], 0, 0)
	lgdraw(backgrounds[3], qq.width - bkgW, 0)
	lgdraw(backgrounds[7], 0, qq.height - bkgH)
	lgdraw(backgrounds[9], qq.width - bkgW, qq.height - bkgH)
end

function TB.BuildBackgroundData(width, height)
 	local bkgW = backgrounds[1]:getWidth()
 	local bkgH = backgrounds[1]:getHeight()
 	return {
 		center = love.graphics.newQuad(0,0,width,height,bkgW,bkgH),
 		top =    love.graphics.newQuad(0,0,width,bkgH,bkgW,bkgH),
 		left =   love.graphics.newQuad(0,0,bkgW,height,bkgW,bkgH),
 		width =  width,
 		height = height,
 		bkgW = bkgW,
 		bkgH = bkgH,
	}
end

function TB.UpdateBackgroundData( width, height, bgdata )
 	local bkgW = backgrounds[1]:getWidth()
 	local bkgH = backgrounds[1]:getHeight()
 	bgdata.center:setViewport( 0, 0, width, height )
 	bgdata.top:setViewport( 0, 0, width, bkgH )
 	bgdata.left:setViewport( 0, 0, bkgW, height )
 	bgdata.width = width
 	bgdata.height = height
end

do
local bgdata = TB.BuildBackgroundData( 1, 1 )
function TB.drawBackground( x, y, w, h )
	TB.UpdateBackgroundData( w, h, bgdata )
	love.graphics.push()
	love.graphics.translate( x, y )
	TB.drawBackgroundData( bgdata )
	love.graphics.pop()
end
end

return TB

