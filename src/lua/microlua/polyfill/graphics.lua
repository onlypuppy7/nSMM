love.graphics = {}

local currentColor = {31, 31, 31, 31}
local backgroundColor = {0, 0, 0, 31}

-- clamp helper
local function clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

function love.graphics.setColor(r, g, b, a)
    a = a or 1
    currentColor = {
        clamp(math.floor((r or 1) * 31), 0, 31),
        clamp(math.floor((g or 1) * 31), 0, 31),
        clamp(math.floor((b or 1) * 31), 0, 31),
        clamp(math.floor(a * 31), 0, 31),
    }
end

function love.graphics.getColor()
    return unpack(currentColor)
end

function love.graphics.setBackgroundColor(r, g, b)
    backgroundColor = {
        clamp(math.floor((r or 1) * 31), 0, 31),
        clamp(math.floor((g or 1) * 31), 0, 31),
        clamp(math.floor((b or 1) * 31), 0, 31),
        31
    }
end

function love.graphics.rectangle(mode, x, y, w, h)
    if mode == "fill" then
        screen.drawFillRect(SCREEN_UP, x, y, x + w, y + h, Color.new(unpack(currentColor)))
    else
        error("Unsupported rectangle mode: "..tostring(mode))
    end
end

function love.graphics.line(...)
    local args = {...}
    if #args < 4 or (#args % 2) ~= 0 then
        error("love.graphics.line requires an even number of at least 4 arguments")
    end

    for i = 1, #args - 2, 2 do
        local x1, y1, x2, y2 = args[i], args[i+1], args[i+2], args[i+3]
        if screen.drawLine then
            screen.drawLine(SCREEN_UP, x1, y1, x2, y2, Color.new(unpack(currentColor)))
        end
    end
end

function love.graphics.points(...)
    local args = {...}
    if (#args % 2) ~= 0 then
        error("love.graphics.points requires an even number of arguments")
    end

    for i = 1, #args, 2 do
        local x, y = args[i], args[i+1]
        if screen.drawPixel then
            screen.drawPixel(SCREEN_UP, x, y, Color.new(unpack(currentColor)))
        end
    end
end

function love.graphics.clear()
    screen.drawFillRect(SCREEN_UP, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, Color.new(unpack(backgroundColor)))
end

local currentFont = {
    __font = nil,
    getHeight = function(self)
        return 8 --Font.getCharHeight(self.__font)
    end,
    getWidth = function(self, text)
        return 6 * #text--getStringWidth(self.__font, text)
    end,
    destroy = function(self)
        -- Font.destroy(self.__font)
    end,
    raw = function(self)
        -- return self.__font
    end
}

function love.graphics.setFont(font)
    -- currentFont = font
end

function love.graphics.getFont()
    return currentFont
end

function love.graphics.newFont(path)
    --no-opping this. this will never work well.
    return currentFont
end

function love.graphics.print(text, x, y)
    x = x or 0
    y = y or 0
    -- if currentFont then
    --     screen.printFont(SCREEN_UP, x, y, tostring(text), Color.new(unpack(currentColor)), currentFont:raw())
    -- else
        screen.print(SCREEN_UP, x, y, tostring(text))
    -- end
end

function love.graphics.getWidth() return __DS.nativeWidth end

function love.graphics.getHeight() return __DS.nativeHeight end

local currentCanvas = nil
local canvasList = {}
local screenTarget = SCREEN_UP

function love.graphics.newCanvas()
    local c = Canvas.new()
    table.insert(canvasList, c)
    return c
end

function love.graphics.setCanvas(c)
    currentCanvas = c
end

function love.graphics.getCanvas()
    return currentCanvas
end

function love.graphics.draw(img, x, y)
    Canvas.draw(SCREEN_UP, img.image.raw or img.image, math.floor(x), math.floor(y))
end

function love.graphics.newImage(path)
    local raw = Image.load(path, VRAM)
    local img = {
        raw = raw,
        getWidth = function() return Image.width(raw) end,
        getHeight = function() return Image.height(raw) end,
    }
    return img
end

function love.graphics.setLineStyle(style)
    --no-op
end

local lineWidth = 1

function love.graphics.setLineWidth(width)
    lineWidth = width
end

function love.graphics.getLineWidth()
    return lineWidth
end

function love.graphics.setPointSize(width)
    --no-op
end

function love.graphics.present()
    if currentCanvas then
        Canvas.draw(screenTarget, currentCanvas, 0, 0)
    end
    render()
end