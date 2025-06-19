--compatability: unchecked
--tested: no

image	= class()

image.h	= 32
image.w	= 32

function dataStringToNumber(str)
	local len	= #str
	local out	= 0
	for i=1, len do
		out	= out + string.byte(str:sub(i,i)) * 2^(i*8-8)
	end
	return out
end

function l_shift(n, m)
	return n * (2^m)
end

function r_shift(n, m)
	return math.floor(n / (2^m))
end

function image:init(imgstr)
	self.data	= imgstr
	self.header	= imgstr:sub(1,  20)
	self.data	= imgstr:sub(21, -1)

	self.w	= dataStringToNumber(self.header:sub(1, 4))
	self.h	= dataStringToNumber(self.header:sub(5, 8))
	self.framebuffer	= love.graphics.newFramebuffer(self.w, self.h)
	love.graphics.setRenderTarget(self.framebuffer)
	love.graphics.setBackgroundColor(255, 255, 255)
	love.graphics.clear()
	love.graphics.setPointSize(1)
	
	local x, y, byte1, byte2, isAlpha, color, r, g, b
	for pos=1, #self.data, 2 do
		isAlpha	= false
		y	= math.floor((pos/2)/self.w)
		x	= (((pos+1)/2-1)%self.w)
		byte1	= self.data:sub(pos  , pos  ):byte()
		byte2	= self.data:sub(pos+1, pos+1):byte()
		if byte2 < 128 then
			isAlpha	= true
		else
			byte2	= byte2-128
		end
		
		color	= l_shift(byte2, 8) + byte1
		r	= r_shift(color, 10)                  
		g	= r_shift(color, 5)-l_shift(r, 5)     
		b	= color-(l_shift(r, 10)+l_shift(g, 5))
		r	= r*256/32
		g	= g*256/32
		b	= b*256/32

		love.graphics.setColor(r, g, b, isAlpha and 0 or 255)
		love.graphics.point(x+.5, y+.5)
	end
	
	--love.graphics.present()
	love.graphics.setRenderTarget()
	
	if platform.window then
		platform.window:invalidate()
	end
end

image.new	= function (str)
	return image(str)
end

function image:width()
	return self.w
end

function image:height()
	return self.h
end