love.graphics = {}

local currentColor = {31, 31, 31, 31}

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

function love.graphics.clear()
    screen.drawFillRect(SCREEN_UP, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, Color.new(0, 0, 0, 31))
end

function love.graphics.newFont(filepath, size)
end

function love.graphics.setFont(font)
end

function love.graphics.getWidth() return __DS.nativeWidth end

function love.graphics.getHeight() return __DS.nativeHeight end

local currentCanvas = nil
local canvasList = {}
local screenTarget = SCREEN_UP

-- Canvas API
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
    if currentCanvas then
        local obj = Canvas.newImage(x or 0, y or 0, img)
        Canvas.add(currentCanvas, obj)
    else
        screen.blit(screenTarget, x or 0, y or 0, img)
    end
end

function love.graphics.newImage(path)
    return Image.load(path, VRAM)
end

function love.graphics.print(text, x, y)
    screen.print(screenTarget, x or 0, y or 0, tostring(text))
end

function love.graphics.setLineStyle(style)
    --no-op
end

function love.graphics.setLineWidth(width)
    --no-op
end

function love.graphics.present()
    if currentCanvas then
        Canvas.draw(screenTarget, currentCanvas, 0, 0)
    end
    render()
end