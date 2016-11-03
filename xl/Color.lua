
local Color = {
    RED    = {255,  0,  0},
    GREEN  = {0,  255,  0},
    BLUE   = {0,    0,255},
    WHITE  = {255,255,255},
}

function Color.HSLtoRGB(h,s,l,a)
	if type(h) == "table" then h,s,l,a = unpack(h) end
	a = a or 255
    if s<=0 then return l,l,l,a end
    h, s, l = h/256*6, s/255, l/255
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m)*255,(g+m)*255,(b+m)*255,a
end

function Color.RGBtoHSL(r,g,b)
    if type(r) == "table" then
        r,g,b = unpack(r)
    end
    r,g,b = r/255 , g/255 , b/255
    local mx = math.max(r, g, b)
    local mn = math.min(r, g, b)
    local h,s,l
    l = (mx + mn) / 2
    if mx == mn then h, s = 0, 0
    else -- achromatic
        local d = mx - mn
        if l > 0.5 then s = d / ( 2 - mx - mn)
                   else s = d / (mx + mn) end
        if mx == r     then h = (g - b) / d + (g < b and 6 or 0)
        elseif mx == g then h = (b - r) / d + 2
        elseif mx == b then h = (r - g) / d + 4
        end
        h = h / 6
    end
    return h, s, l
end

function Color.RGBtoHSV( r, g, b )
    if type(r) == "table" then
        r, g, b = unpack( r )
    end
    local hue, saturation, value
    local r2 = r/255
    local g2 = g/255
    local b2 = g/255
    local Cmax = math.max(r2, g2, b2)
    local Cmin = math.min(r2, g2, b2)
    value = Cmax
    local delta = Cmax - Cmin
    if Cmax ~= 0 then
        saturation = delta/Cmax
    else
        saturation = 0
        hue = -1
        return hue, saturation, value
    end

    if r2 == Cmax then
        hue = (g2 - b2)/delta
    elseif g2 == Cmax then
        hue = 2 + (b2 - r2)/ delta
    else
        hue = 4 + (r2 - g2)/ delta
    end
    hue = hue * 60
    if (hue < 0) then
        hue = hue + 360
    end

    return hue, saturation, value
end

function Color.HSVtoRGB( hue, saturation, value , alpha )
    local i, f, p, q, t
    local r, g, b, a = unpack(self.color)
    a = alpha or a
    if (saturation == 0 ) then -- for achromatic colors (greys)
        r, g, b = value, value, value
        return r, g, b
    end

    hue = hue/60
    i = math.floor(hue)
    f = hue - i
    p = value * (1 - saturation)
    q = value * (1 - (saturation * f))
    t = value * ( 1 - (saturation * (1 - f)))

    if i == 0 then
        r = value
        g = t
        b = p
    elseif i == 1 then
        r = q
        g = value
        b = p
    elseif i == 2 then
        r = p
        g = value
        b = t
    elseif i == 3 then
        r = p
        g = q
        b = value
    elseif i == 4 then
        r = t
        g = p
        b = value
    else
        r = value
        g = p
        b = q
    end
    return r, g, b
end

return Color
