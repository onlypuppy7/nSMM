platform	=	{}

platform._hwLevel	= 5
platform.apiLevel	= '1.5'


function platform.hw()
	return platform._hwLevel
end

function platform.isColorDisplay()
	return true
end

function platform.isDeviceModeRendering()
	return true
end


------------------
-- Window Class --
------------------

Window	= class()

function Window:init(w, h)
	self.w	= w or error("FATAL: No height specified for Window object!")
	self.h	= h or error("FATAL: No width specified for Window object! ")
		
	self.gc	= platform.gc(w, h)
	self.gc:begin()
	
	self.invalidated	= false
	self.invaliddata	= 0
	self:update()
end



function Window:invalidate(x, y, w, h)
	self.invalidated	= true
	
	if x and y and w and h then
		x=x-1
		y=y-1
		w=w+2
		h=h+2
		if type(self.invaliddata) == "table" then
			local id	= self.invaliddata
			local xo, yo, wo, ho	= id[1], id[2],id[3],id[4]
			local xn	= math.min(x, xo)
			local yn	= math.min(y, yo)
			local wn	= math.max(x+w, xo+wo) - xn + 2
			local hn	= math.max(y+h, yo+ho) - yn + 2
			
			self.invaliddata	= {xn, yn, wn, hn}
		else
			self.invaliddata	= {x, y, w, h}
		end
	else
		self.invaliddata	= 0
	end
end

function Window:height()
	return self.h
end

function Window:width()
	return self.w
end

function Window:update()
	PCspire.callEvent(on.resize, self.w, self.h)
end

function Window:setHeight(h)
	self.h	= h>0 and h or error("Specified window height is smaller or equal to 0! Are you crazy?")
	PCspire.callEvent(on.resize, self.w, self.h)
end

function Window:setWidth(w)
	self.w	= w>0 and w or error("Specified window width is smaller or equal to 0! Are you crazy?")
	PCspire.callEvent(on.resize, self.w, self.h)
end


-----------------------------
-- Graphical Context Class --
-----------------------------

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
	self.font	= {family, style, size/12, size}
	fonts.setFont(size, style)
end

function platform.gc:drawString(str, x, y, pos)
	love.graphics.print(str, x, y + (self.offsets[pos] or self.offsets["bottom"])() )--, 0, self.font[3], self.font[3])
end

function platform.gc:drawRect(x, y, w, h)
	love.graphics.rectangle("line", x+1, y+1, w, h)
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
		self:drawLine(x, y, x2, y2)
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

function platform.gc:drawLine(x1, y1, x2, y2)
	love.graphics.line(x1, y1, x2, y2)
end

function platform.gc:clipRect(op, x, y, width, height)
	if op == "reset" then
		love.graphics.setScissor(0, 0, platform.window:width(), platform.window:height())
	elseif op == "set" then
		love.graphics.setScissor(x, y, width, height)
	elseif op == "null" then
		love.graphics.setScissor(0, 0, 0, 0)
	end
end

function platform.gc:setPen(thickness, style)	
	local w	= 1
	if thickness == "medium" then
		w	= 3
	elseif thickness == "thick" then
		w	= 8
	end

	--love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(w)
end

function platform.gc:setColorRGB(r, g, b)
	love.graphics.setColor(r, g, b, 255)	
end

function platform.gc:getStringWidth(str)
	return 0.6*self.font[4]*#tostring(str)
end

function platform.gc:getStringHeight(str)
	return self.font[4]+5
end

function platform.gc:setAlpha() end

function platform.gc:drawImage(img, x, y)
	love.graphics.setColorMode("replace")
	love.graphics.setColor(0,0,0,255)
	love.graphics.draw(img.framebuffer, x, y)
	love.graphics.setColorMode("modulate")
end

-------------------
-- Platform menu --
-------------------

_menuState	= false
function toggleMenu()
	error("fake error, triggered")
	_menuState	= not _menuState
	if _menuState then
		
	end
end
