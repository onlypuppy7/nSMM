--compatability: unchecked
--tested: no

platform.gc	= class()

function platform.gc:init(framebuffer, w, h)
	self.w	= w or 318
	self.h	= h or 212
end

function platform.gc:begin()
	love.graphics.setBackgroundColor(255, 255, 255)
	love.graphics.clear()
	self:default()
end

function platform.gc:default()
	love.graphics.setColor(0, 0, 0)
	self:setPen(10)
	fonts.setFont(12)
end

platform.gc["finish"]	= function (self)
	--love.graphics.setRenderTarget(globalGC.framebuffer)
end

platform.gc.offsets	= {}
platform.gc.offsets["top"     ]	= function () return 0 end
platform.gc.offsets["bottom"  ]	= function () return -platform.gc.font[4] end
platform.gc.offsets["middle"  ]	= function () return -platform.gc.font[4]/2 end
platform.gc.offsets["baseline"]	= function () return -platform.gc.font[4]+4 end

platform.gc.font	=	{"", "r", 1, 12}

function platform.gc:setFont(family, style, size)
	fonts.setFont(size, style)
end

function platform.gc:drawString(str, x, y, pos)
	love.graphics.print(str, x, y + (self.offsets[pos] or self.offsets["bottom"])() )
end

function platform.gc:fillRect(x, y, w, h)
	love.graphics.rectangle("fill", x, y, w, h)
end

function platform.gc:fillPolygon(vertices)
	love.graphics.polygon("fill", vertices)
end

function platform.gc:drawPolygon(vertices)
	love.graphics.polygon("line", vertices)
end

function platform.gc:drawPolyLine(vertices)
	local x, y, x2, y2 = vertices[1], vertices[2]
	for i=3, #vertices, 2 do
		x2, y2	= vertices[i], vertices[i+1]
		drawLine(x, y, x2, y2)
		x	= x2
		y	= y2
	end
end

function platform.gc:drawArc(x, y, w, h, startangle, angle, style)
	w,h=w/2,h/2
	startangle=startangle+90
	points	= {}
	local cos,sin=math.cos,math.sin
	local d= math.round(math.max((w+h)/2, 10))
	if style == "fill" then
		table.insert(points, x+w)
		table.insert(points, y+h)
	end
	for i=0, d do
		local a=math.rad(startangle+angle*(i/d))
		table.insert(points, sin(a)*w + w + x)
		table.insert(points, cos(a)*h + h + y)
		
	end
	if style == "fill" then
		table.insert(points, x+w)
		table.insert(points, y+h)
		love.graphics.polygon("fill",unpack(points))
	else
		love.graphics.line(unpack(points))
	end
end

function platform.gc:fillArc(x, y, w, h, startangle, angle)
	self:drawArc(x, y, w, h, startangle, angle, "fill")
end

local function drawLine(x1, y1, x2, y2)
    -- x1 = math.ceil(x1)
    -- y1 = math.ceil(y1)
    -- x2 = math.ceil(x2)
    -- y2 = math.ceil(y2)

    x1 = x1 + 1
    x2 = x2 + 1
    y1 = y1 + 1
    y2 = y2 + 1

	if __PC.penStyle == "smooth" then
		-- love.graphics.line(math.round(x1), math.round(y1), math.round(x2), math.round(y2))
        love.graphics.line(x1, y1, x2, y2)
		return
	end

	local dx, dy = x2 - x1, y2 - y1
	local length = math.sqrt(dx * dx + dy * dy)
	local angle = math.atan2(dy, dx)

	local dashLength = 4
	local gapLength = 2

	if __PC.penStyle == "dotted" then
		dashLength = love.graphics.getLineWidth()
		gapLength = dashLength * 1.5
	end

	local progress = 0
	while progress < length do
		local seg = math.min(dashLength, length - progress)
		local sx = x1 + math.cos(angle) * progress
		local sy = y1 + math.sin(angle) * progress
		local ex = x1 + math.cos(angle) * (progress + seg)
		local ey = y1 + math.sin(angle) * (progress + seg)

		if __PC.penStyle == "dotted" then
			love.graphics.points(sx, sy)
		else
			-- love.graphics.line(math.ceil(sx), math.ceil(sy), math.ceil(ex), math.ceil(ey))
            love.graphics.line(sx, sy, ex, ey)
		end

		progress = progress + dashLength + gapLength
	end
end

function platform.gc:drawLine(x1, y1, x2, y2)
    -- x1 = x1 + 1
    -- x2 = x2 + 1
    -- y1 = y1 + 1
    -- y2 = y2 + 1
    x1 = math.round(x1)
    y1 = math.round(y1)
    x2 = math.round(x2)
    y2 = math.round(y2)

    drawLine(x1, y1, x2, y2)
end

function platform.gc:drawRect(x, y, w, h)
	local x2, y2 = x + w, y + h
    -- local offset = 1
	drawLine(x -1,     y +0,   x2,     y   ) -- top
	drawLine(x2+0,     y,      x2,     y2  ) -- right
	drawLine(x2+0,     y2+0,   x,      y2  ) -- bottom
	drawLine(x +0,     y2,     x,      y   ) -- left
end


function platform.gc:clipRect(op, x, y, width, height)
	if op == "reset" then
		love.graphics.setScissor(0, 0, platform.window:width() * __PC.scale, platform.window:height() * __PC.scale)
	elseif op == "set" then
		love.graphics.setScissor(x, y, width, height)
	elseif op == "null" then
		love.graphics.setScissor(0, 0, 0, 0)
	end
end

__PC.penStyle = "smooth" --dashed, dotted, smooth

function platform.gc:setPen(thickness, style)	
	local w	= 1
	if thickness == "medium" then
		w = 3
	elseif thickness == "thick" then
		w = 8
	end

	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(w)

    -- print("Setting pen style to", tostring(style))

    __PC.penStyle = style or "smooth"
end

function platform.gc:setColorRGB(r, g, b, a)
	love.graphics.setColor(r / 255, g / 255, b / 255, a and a/255 or 1)	
end

function platform.gc:getStringWidth(str)
    local font = love.graphics.getFont()
    return font:getWidth(str)
end

function platform.gc:getStringHeight(str)
    local font = love.graphics.getFont()
    return font:getHeight()
end

function platform.gc:setAlpha() end

function platform.gc:drawImage(img, x, y)
    local r, g, b, a = love.graphics.getColor()

    -- if img.r ~= 0 then print("image r", img.r) end

    love.graphics.setColor(1, 1, 1, 1) -- white (no tint)

    if not img then return print("ALERT! img is a nil value!", img, x, y) end

    local w = img:width()
    local h = img:height()

    local originX=(x + (img.sx * w) / 2)
    local originY=(y + (img.sy * h) / 2)

    local rotation=(img.r) * math.pi / 180

    local scaleX=(img.sx)
    local scaleY=(img.sy)

    local offsetX=(img.w / 2)
    local offsetY=(img.h / 2)

    love.graphics.draw(img.framebuffer, originX, originY, rotation, scaleX, scaleY, offsetX, offsetY)
    -- love.graphics.draw(img.framebuffer, math.floor(x + (img.sx * w) / 2), math.floor(y + (img.sy * h) / 2), (img.r) * math.pi / 180, img.sx, img.sy, img.w / 2, img.h / 2)
    -- love.graphics.draw(img.framebuffer, x, y, (img.r) * math.pi / 180, img.sx, img.sy)

    love.graphics.setColor(r, g, b, a)
end