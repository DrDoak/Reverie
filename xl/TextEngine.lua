----
-- xl/TextEngine.lua
-- 
-- The text engine proccesses text and then renders it. It sports features
-- including bold, italics and colors. Send the text engine a table with your
-- text interspersed with format commands and then call renderText and watch
-- in awe. Or you could call renderTextFull because it's easier to use.
----

local TextEngine = Class("TextEngine")

function TextEngine:init( text, width, font , align)
	assert(type(text) == "table", "text must be a table")
	self.font = font
	-- lume.trace(text)
	-- util.print_table(text)
	self.text = text
	self.align = align or "left"
	self:resize( width )
end

function TextEngine:resize( w )
	self.width = w
	self.blocks,self.lines = TextEngine.ProccessText( self.text, self.width, self.font )
end

function TextEngine:findBlock( goalindex, startblock, startindex )
	local bix = startblock or 1
	local cix = startindex or 1
	local blocks = self.blocks
	while bix <= #blocks do
		if type(blocks[bix]) == "string" then
			local slen = #blocks[bix]
			if goalindex > cix + slen then
				return bix,cix
			else
				bix = bix + 1
				cix = cix + slen
			end
		end
	end
	return nil,nil
end


----
-- Renders a part of the text.
-- @param {number} first - The first block to render
-- @param {number} last - The last block to render
-- @param {number} lastChar - Index of the last character to render
----
function TextEngine:renderText(first, last, lastChar)
	local blocks = self.blocks
	local style = {bold = false, italic=false}
	local dx, dy, line = 0, 0, 0
	local scaleX, shearX = 1, 0
	local align = self.align 
	love.graphics.setColor(0,0,0)
	love.graphics.setFont(self.font)
	for k=1,#blocks do
		local v = blocks[k]
		if type(v) == "table" then
			if v.color then 
				love.graphics.setColor(v.color) 
				-- util.print_table(v.color)
			end
			love.graphics.setColor(255,0,0,255)
			if v.font  then love.graphics.setFont(v.font) end
			if v.align then align = v.align end
			if v.bold ~= nil then style.bold = v.bold end
			if v.italic ~= nil then style.italic = v.italic end
			scaleX = style.bold and 1.1 or 1
			shearX = style.italic and -0.5 or 0
		else
			local ptext = (k ~= last) and v or v:sub(1,lastChar)
			if k >= first then
				love.graphics.setColor(255,255,255,255)
				love.graphics.printf(ptext, dx, dy, self.width, align, 0, scaleX, 1, 0, 0, shearX, 0)
			end
			dx, dy, line = TextEngine.proccessLocation(v, dx, dy, line, self.width)
			if k > last then
				break
			end
		end
	end
end

function TextEngine:renderTextFull(  )
	return self:renderText( 1, #self.blocks, -1 )
end


function TextEngine.proccessLocation(text, dx, dy, line, width)
	local ft = love.graphics.getFont()
	local w,l = ft:getWrap(text, width)
	l = #l
	dx = dx + w
	if text:sub(-1) == "\n" then
		l = l + 1
	end
	l = l - 1 
	if l > 0 then
		dx = 0
		dy = dy + l * ft:getHeight()
	end
	return dx, dy, line + l
end

-- This is the backbone of TextEngine. ProccessText performs the line splitting, etc.
-- which allows the text rendering engine to efficiently render text.
function TextEngine.ProccessText(textList, width, font)
	local blocks = {}
	local x,y,line = 0,0,0

	-- Insert a string and update the locations
	local function InsertAndUpdate(text)
		table.insert(blocks, text)
		x,y,line = TextEngine.proccessLocation(text, x, y, line, width)
	end

	-- Split a string at its final newline and insert both parts of the text as different blocks.
	local function InsertPost(text)
		local sub1 = string.match(text,".+\n") or ""
		if sub1 ~= "" then
			InsertAndUpdate(sub1)
		end
		if #sub1 < #text then
			InsertAndUpdate( string.sub(text, #sub1 + 1) )
		end
	end

	-- If you aren't beginning at x = 0 then doing printf will draw things with a weird indent.
	-- Here we off the first line so that the first line may be indented with the rest of the
	-- text can go back to its normal location
	local function SplitWrappedText(text)
		local w,l = font:getWrap(text, width - x)
		if l == 1 then
			return text,nil
		else
			local i1,i2,iprev
			i2 = 1
			repeat
				iprev = i2
				i1,i2 = string.find(text,"%s+",i2+1)
				local prefix = text:sub(1,i2)
				local w,l = font:getWrap(prefix, width - x)
			until l > 1
			return text:sub(1,iprev) .. "\n", text:sub(iprev+1)
		end
	end

	-- main text-processing loop
	for k,v in ipairs(textList) do
		if type(v) == "string" then
			local w,l = font:getWrap(v,width)
			l = #l
			if x ~= 0 or l > 1 then
				local s1,s2 = SplitWrappedText(v)
				InsertAndUpdate(s1)
				if s2 then
					InsertPost(s2)
				end
			else
				InsertPost(v)
			end
		else
			table.insert(blocks, v)
		end
	end

	return blocks, line
end

return TextEngine
