local VirtualStick = {}
VirtualStick.__index = VirtualStick

function VirtualStick.new(x, y, size, isCStick)
    local self = setmetatable({}, VirtualStick)
    self.x, self.y = x, y
    self.size = size
    self.knobRatio = 0.6
    self.deadzone = 0.1
    self.active = false
    self.pointer = nil
    self.knobX, self.knobY = self.x, self.y
    self.axisX, self.axisY, self.magnitude = 0, 0, 0
    self.isCStick = isCStick
    return self
end

function VirtualStick:reset()
    self.active = false
    self.knobX, self.knobY = self.x, self.y
    self.axisX, self.axisY, self.magnitude = 0, 0, 0
end

function VirtualStick:updatePosition(px, py)
    local dx, dy = px - self.x, py - self.y
    local dist = math.sqrt(dx*dx + dy*dy)

    local knobRadius = self.size * self.knobRatio
    local maxR = self.size - knobRadius
    if dist > maxR then
        dx, dy = dx / dist * maxR, dy / dist * maxR
        dist = maxR
    end

    self.knobX, self.knobY = self.x + dx, self.y + dy
    local nx, ny = dx / maxR, - dy / maxR
    if self.isCStick then
        nx, ny = nx / 40, ny / 40
    end
    self.axisX, self.axisY = nx, ny
    self.magnitude = math.sqrt(nx*nx + ny*ny)

    if self.magnitude <= self.deadzone and not self.isCStick then
        self.axisX, self.axisY, self.magnitude = 0, 0, 0
    end
end

function VirtualStick:press(px, py, id)
    if VirtualControls.hiddenButtons then return end

    local dx, dy = px - self.x, py - self.y
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist <= self.size then
        self.active, self.pointer = true, id
        self:updatePosition(px, py)
        -- print("pressing stick id", id, px, py)
        return true
    end
    return false
end

function VirtualStick:move(px, py, id)
    if VirtualControls.hiddenButtons then return end

    if self.pointer == id then
        self:updatePosition(px, py)
        -- print("moving stick id", id, px, py)
        return true
    end
    return false
end

function VirtualStick:release(id)
    if self.pointer == id then
        self:reset()
        self.pointer = false
        -- print("released stick id", id)
        return true
    end
    return false
end

function VirtualStick:draw()
    if VirtualControls.hiddenButtons then return end

    local lg = love.graphics
    lg.setColor(1, 1, 1, 0.9)
    lg.circle("line", self.x, self.y, self.size)
    lg.setColor(1, 1, 1, 0.15)
    lg.circle("fill", self.x, self.y, self.size)
    if self.active then
        lg.setColor(1, 1, 1, 0.15)
        lg.circle("fill", self.x, self.y, self.size * 0.45)
    end
    local knobRadius = self.size * self.knobRatio
    local knobAlpha = self.active and 0.45 or 0.6
    lg.setColor(1, 1, 1, knobAlpha)
    lg.circle("fill", self.knobX, self.knobY, knobRadius)
end

local VirtualButton = {}
VirtualButton.__index = VirtualButton

function VirtualButton.new(x, y, opts)
    local self = setmetatable({}, VirtualButton)
    self.x, self.y = x, y
    self.shape = opts.shape or "circle" -- "circle" or "rect"
    self.radius = opts.radius or 40     -- used if circle
    self.w = opts.w or 80               -- used if rect
    self.h = opts.h or 80
    self.name = opts.name or "btn"
    self.active = false
    self.pointer = nil
    self.clickFunc = opts.clickFunc
    self.releaseFunc = opts.releaseFunc
    self.bypassHide = opts.bypassHide
    return self
end

-- tolerance is a percentage, e.g. 0.2 for 20%
function VirtualButton:press(px, py, id, tolerance)
    if VirtualControls.hiddenButtons and not self.bypassHide then return end

    tolerance = tolerance or 0.25 

    if self.shape == "circle" then
        local dx, dy = px - self.x, py - self.y
        local r = self.radius * (1 + tolerance)
        if dx*dx + dy*dy <= r*r then
            self.active, self.pointer = true, id
            if self.clickFunc then self.clickFunc(self.x, self.y) end
            return true
        end
    elseif self.shape == "rect" then
        local extraW = self.w * tolerance
        local extraH = self.h * tolerance
        if px >= self.x - extraW and px <= self.x + self.w + extraW
        and py >= self.y - extraH and py <= self.y + self.h + extraH then
            self.active, self.pointer = true, id
            if self.clickFunc then self.clickFunc(self.x, self.y) end
            return true
        end
    end
    return false
end

function VirtualButton:move(px, py, id)
    if VirtualControls.hiddenButtons and not self.bypassHide then return end
    return self.pointer == id
end

function VirtualButton:release(id)
    if self.pointer == id then
        self.active, self.pointer = false, nil
        if self.releaseFunc then self.releaseFunc() end
        return true
    end
    return false
end

function VirtualButton:draw()
    if VirtualControls.hiddenButtons and not self.bypassHide then return end

    local lg = love.graphics
    lg.setColor(1, 1, 1, 0.9)

    if self.shape == "circle" then
        lg.circle("line", self.x, self.y, self.radius)
        lg.setColor(1, 1, 1, self.active and 0.4 or 0.2)
        lg.circle("fill", self.x, self.y, self.radius)
        lg.setColor(1, 1, 1)
        lg.printf(self.name:upper(), self.x - self.radius, self.y - 6, self.radius*2, "center")
    else -- rect
        lg.rectangle("line", self.x, self.y, self.w, self.h, 8, 8)
        lg.setColor(1, 1, 1, self.active and 0.4 or 0.2)
        lg.rectangle("fill", self.x, self.y, self.w, self.h, 8, 8)
        lg.setColor(1, 1, 1)
        lg.printf(self.name:upper(), self.x, self.y + self.h/2 - 6, self.w, "center")
    end
end

-- VirtualControls
VirtualControls = {}

function VirtualControls:setup()
    self.hiddenButtons = false

    local width, height = love.graphics.getDimensions()
    local stickHeight = math.min(140, height * 0.2)
    local sideOffset = math.min(120, width * 0.2)
    local topOffset = height - stickHeight - math.min(40, height * 0.05)
    local rightStickOffset = topOffset * 0.25

    self.stickleft = VirtualStick.new(sideOffset, topOffset, stickHeight)
    self.stickright = VirtualStick.new(width - sideOffset, rightStickOffset, stickHeight * 0.7, true)
    self.sticks = {self.stickleft, self.stickright}

    -- buttons (ABXY)
    local btnR = height * 0.08
    local baseX, baseY = width * 0.8, height * 0.75
    self.buttons = {
        VirtualButton.new(baseX + btnR*2, baseY, {shape="circle", radius=btnR, name="A", clickFunc=function() love.gamepadpressed(nil, "a") end, releaseFunc=function() end}), -- love.gamepadreleased(nil, "a")
        VirtualButton.new(baseX, baseY - btnR*2, {shape="circle", radius=btnR, name="X", clickFunc=function() love.gamepadpressed(nil, "x") end, releaseFunc=function() end}), -- love.gamepadreleased(nil, "x")
        VirtualButton.new(baseX - btnR*2, baseY, {shape="circle", radius=btnR, name="Y", clickFunc=function() love.gamepadpressed(nil, "y") end, releaseFunc=function() end}), -- love.gamepadreleased(nil, "y")
        VirtualButton.new(baseX, baseY + btnR*2, {shape="circle", radius=btnR, name="B", clickFunc=function() love.gamepadpressed(nil, "b") end, releaseFunc=function() end}), -- love.gamepadreleased(nil, "b")
    }

    -- L/R simulated mouse buttons, above the left stick
    local lrW, lrH = height * 0.15, height * 0.25
    local lrY = topOffset * 0.35
    local lX, rX = sideOffset - lrW - height * 0.04, sideOffset - lrW + height * 0.2

    table.insert(self.buttons, VirtualButton.new(lX, lrY, {shape="rect", w=lrW, h=lrH, name="L", clickFunc=function() __PC.callEvent("mouseDown",      __PC.cursorPos.x, __PC.cursorPos.y) end, releaseFunc=function() end}))
    table.insert(self.buttons, VirtualButton.new(rX, lrY, {shape="rect", w=lrW, h=lrH, name="R", clickFunc=function() __PC.callEvent("rightMouseDown", __PC.cursorPos.x, __PC.cursorPos.y) end, releaseFunc=function() end}))

    --hide button
    table.insert(self.buttons, VirtualButton.new(width - 60, 20, {shape="rect", w=btnR*2, h=btnR, name="Hide", bypassHide=true, clickFunc=function() self.hiddenButtons = not self.hiddenButtons end}))

    --start/select buttons
    local ssW, ssH = btnR*2, btnR*0.7
    local ssX, ssY = baseX * 0.95, baseY - btnR*4 - 10
    local ssSpacing = -20
    table.insert(self.buttons, VirtualButton.new(ssX - ssW - ssSpacing, ssY, {shape="rect", w=ssW, h=ssH, name="Select", clickFunc=function() love.gamepadpressed(nil, "back") end,  releaseFunc=function() love.gamepadreleased(nil, "back") end}))
    table.insert(self.buttons, VirtualButton.new(ssX + ssW + ssSpacing, ssY, {shape="rect", w=ssW, h=ssH, name="Start", clickFunc=function()  love.gamepadpressed(nil, "start") end, releaseFunc=function() love.gamepadreleased(nil, "start") end}))

    love.joystick.getJoysticks = function()
        return {self}
    end
end

function VirtualControls:draw()
    for _, stick in ipairs(self.sticks) do stick:draw() end
    for _, button in ipairs(self.buttons) do button:draw() end
end

function VirtualControls:getID() return "virtual" end
function VirtualControls:getGamepadAxis(axis)
    if axis == "leftx" then return self.stickleft.axisX
    elseif axis == "lefty" then return self.stickleft.axisY
    elseif axis == "rightx" then return self.stickright.axisX
    elseif axis == "righty" then return self.stickright.axisY
    end
    return 0
end

function VirtualControls:isGamepadDown(button)
    for _, b in ipairs(self.buttons) do
        if b.name:lower() == button and b.active then return true end
    end
    return false
end

function VirtualControls:touchpressed(id, x, y, dx, dy, pressure)
    local isBlocking = false
    for _, stick  in ipairs(self.sticks)  do isBlocking = stick:press(x, y, id)  or isBlocking end
    for _, button in ipairs(self.buttons) do isBlocking = button:press(x, y, id) or isBlocking end
    -- print("touchpressed isBlocking", isBlocking)
    return isBlocking
end

function VirtualControls:touchreleased(id, x, y, dx, dy, pressure)
    local isBlocking = false
    for _, stick  in ipairs(self.sticks)  do isBlocking = stick:release(id)  or isBlocking end
    for _, button in ipairs(self.buttons) do isBlocking = button:release(id) or isBlocking end
    -- print("touchreleased isBlocking", isBlocking)
    return isBlocking
end

function VirtualControls:touchmoved(id, x, y, dx, dy, pressure)
    local isBlocking = false
    for _, stick  in ipairs(self.sticks)  do isBlocking = stick:move(x, y, id)  or isBlocking end
    for _, button in ipairs(self.buttons) do isBlocking = button:move(x, y, id) or isBlocking end
    -- print("touchmoved isBlocking", isBlocking)
    return isBlocking
end
