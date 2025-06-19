--compatability: unchecked

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