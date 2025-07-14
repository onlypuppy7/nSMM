local function dataStringToNumber(str)
    local out = 0
    for i = 1, #str do
        out = out + string.byte(str:sub(i, i)) * 2 ^ ((i - 1) * 8)
    end
    return out
end

local function l_shift(x, by) return x * 2 ^ by end
local function r_shift(x, by) return math.floor(x / 2 ^ by) end
local function band(x, y)
    local result = 0
    local bitval = 1
    while x > 0 and y > 0 do
        local xbit = x % 2
        local ybit = y % 2
        if xbit == 1 and ybit == 1 then
            result = result + bitval
        end
        x = math.floor(x / 2)
        y = math.floor(y / 2)
        bitval = bitval * 2
    end
    return result
end

function imageClass:parse(imgstr)
    self.header = imgstr:sub(1, 20)
    self.data = imgstr:sub(21, -1)

    self.w = dataStringToNumber(self.header:sub(1, 4))
    self.h = dataStringToNumber(self.header:sub(5, 8))

    self.sx, self.sy, self.r = 1, 1, 0

    self.framebuffer = Canvas.new()

    for pos = 1, #self.data, 2 do
        local pixelIndex = (pos - 1) / 2
        local x = pixelIndex % self.w
        local y = math.floor(pixelIndex / self.w)

        local byte1 = self.data:byte(pos)
        local byte2 = self.data:byte(pos + 1)

        local isAlpha = byte2 < 128
        if not isAlpha then byte2 = byte2 - 128 end

        local color = l_shift(byte2, 8) + byte1
        local r = band(r_shift(color, 10), 31)
        local g = band(r_shift(color, 5), 31)
        local b = band(color, 31)
        local a = isAlpha and 0 or 31

        r = math.min(r, 31)
        g = math.min(g, 31)
        b = math.min(b, 31)
        a = math.min(a, 31)

        local col = Color.new(r, g, b, a)

        if a > 0 then
            Canvas.add(self.framebuffer, Canvas.newFillRect(x, y, x + 1, y + 1, col))
        end
    end
end


function platform.gc:drawImage(img, x, y)
    if not img then
        print("ALERT! img is a nil value!", img, x, y)
        return
    end

    -- Note: No rotation or scaling support here (Canvas.draw is basic)
    Canvas.draw(SCREEN_UP, img.framebuffer, math.floor(x), math.floor(y))
end