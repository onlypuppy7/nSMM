--compatability: unchecked
--tested: no

local function dataStringToNumber(str)
	local len	= #str
	local out	= 0
	for i=1, len do
		out	= out + string.byte(str:sub(i,i)) * 2^(i*8-8)
	end
	return out
end

local function l_shift(n, m)
	return n * (2^m)
end

local function r_shift(n, m)
	return math.floor(n / (2^m))
end

imageClass = class()

function imageClass:init(input)
    if type(input) == "string" then
        self:parse(input)
    elseif type(input) == "table" then
        self.w = input.w
        self.h = input.h
        self.sx = input.sx or 1
        self.sy = input.sy or 1
        self.r = input.r or 0
        self.data = input.data
        self.header = input.header
        self.framebuffer = input.framebuffer
    end
end

function imageClass:parse(imgstr)
	self.data	= imgstr
	self.header	= imgstr:sub(1,  20)
	self.data	= imgstr:sub(21, -1)

	self.w	= dataStringToNumber(self.header:sub(1, 4))
	self.h	= dataStringToNumber(self.header:sub(5, 8))
    self.sx	= 1
    self.sy	= 1
    self.r = 0 --rotation
    -- self.imgstr = imgstr
	self.framebuffer	= love.graphics.newCanvas(self.w, self.h)
    if not __DS then self.framebuffer:setFilter("nearest", "nearest") end
	love.graphics.setCanvas(self.framebuffer)
	love.graphics.setBackgroundColor(1, 1, 1)
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

		love.graphics.setColor(r / 255, g / 255, b / 255, isAlpha and 0 or 1)
		love.graphics.points(x+.5, y+.5)
	end
	
	--love.graphics.present()
	love.graphics.setCanvas()
	
	-- if platform.window then
	-- 	platform.window:invalidate()
	-- end
end

function imageClass:copy(newWidth, newHeight)
    local newImg = image.new(self)

    newImg.sx = newWidth and (newWidth / self.w) or self.sx
    newImg.sy = newHeight and (newHeight / self.h) or self.sy
    
    return newImg
end

function imageClass:rotate(rotation)
    local newImg = image.new(self)
    newImg.r = (newImg.r - (rotation or 0)) % 360
    return newImg
end

local function deg2rad(deg)
    return deg * math.pi / 180
end

function imageClass:width()
    local angle = deg2rad(self.r or 0)
    local cosA = math.abs(math.cos(angle))
    local sinA = math.abs(math.sin(angle))
    return math.floor(self.w * cosA + self.h * sinA)
end

function imageClass:height()
    local angle = deg2rad(self.r or 0)
    local cosA = math.abs(math.cos(angle))
    local sinA = math.abs(math.sin(angle))
    return math.floor(self.h * cosA + self.w * sinA)
end

imageClass.__index = imageClass

image = {
    new = function(str)
        local img = imageClass(str)
        return img
    end,
    copy = function(img, newWidth, newHeight)
        return img:copy(newWidth, newHeight)
    end,
    rotate = function(img, rotation)
        return img:rotate(rotation)
    end,
    width = function(img)
        return img:width()
    end,
    height = function(img)
        return img:height()
    end,
}