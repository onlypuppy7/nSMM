toolpalette = {
    register = function(menuStructure)
        print("Set menuStructure!")
        ToolPalette.menuStructure=menuStructure
    end,
    -- ignore below for now
    enable = function(toolname, itemname, enable)
    end,
    enableCut = function (enable)
    end,
    enableCopy = function (enable)
    end,
    enablePaste = function (enable)
    end,
}

ToolPalette = {}

ToolPalette.active = false

function ToolPalette:bindings(bindName, ...) --redirects any calls to ToolPalette:BIND if necessary
    if (self.active or bindName=="keypressed") and self[bindName] then
        print(true)
        self[bindName](self, ...)
    end

    return self.active --returning true will block other calls to bindings
end

function ToolPalette:activate(state)
    self.active=state==nil and (not self.active) or state

    if self.active then
        self.hoveredIndex = 1
        self.subHoveredIndex = nil
        self.submenuOpen = false
    end
end

__PC.ToolPalette = ToolPalette

local ENTRY_HEIGHT = 20
local DIVIDER_HEIGHT = 3
local DIVIDER_COLOR = {r=151, g=151, b=151}
local HIGHLIGHT_COLOR = {r=36, g=120, b=207}
local TEXT_COLOR = {r=0, g=0, b=0}
local HIGHLIGHT_TEXT_COLOR = {r=255, g=255, b=255}
local ENTRY_PADDING = 6

function ToolPalette:getMenuWidth(gc, entries)
    local maxWidth = 0
    for _, item in ipairs(entries) do
        if item ~= "-" then
            local text = item[1]
            local width = gc:getStringWidth(text)
            if width > maxWidth then maxWidth = width end
        end
    end
    return maxWidth + ENTRY_PADDING * 2
end

function ToolPalette:getEntryBounds(gc, x, y, entries)
    local width = self:getMenuWidth(gc, entries)
    local bounds = {}

    for i, item in ipairs(entries) do
        local drawY = y + (i - 1) * ENTRY_HEIGHT

        if item ~= "-" then
            table.insert(bounds, {
                x = x,
                y = drawY,
                w = width,
                h = ENTRY_HEIGHT,
                index = i
            })
        end
    end

    return bounds, width
end

ToolPalette.entryChars = {
    1, 2, 3, 4, 5, 6, 7, 8, 9, "A", "B", "C", "D", "E", "F", "G", "H", "I"
}

function ToolPalette:paintMenu(gc, x, y, entries, hoveredIndex, isSubmenu)
    local width = self:getMenuWidth(gc, entries)

    for i, item in ipairs(entries) do
        local drawY = y + (i - 1) * ENTRY_HEIGHT

        if item == "-" then
            gc:setColorRGB(DIVIDER_COLOR.r, DIVIDER_COLOR.g, DIVIDER_COLOR.b)
            gc:drawLine(x + width * 0.025, drawY + ENTRY_HEIGHT / 2, x + width * 0.975, drawY + ENTRY_HEIGHT / 2)
        else
            if i == hoveredIndex then
                gc:setColorRGB(HIGHLIGHT_COLOR.r, HIGHLIGHT_COLOR.g, HIGHLIGHT_COLOR.b)
                gc:fillRect(x, drawY, width, ENTRY_HEIGHT)
                gc:setColorRGB(HIGHLIGHT_TEXT_COLOR.r, HIGHLIGHT_TEXT_COLOR.g, HIGHLIGHT_TEXT_COLOR.b)
            else
                gc:setColorRGB(255, 255, 255)
                gc:fillRect(x, drawY, width, ENTRY_HEIGHT)
                gc:setColorRGB(TEXT_COLOR.r, TEXT_COLOR.g, TEXT_COLOR.b)
            end

            local entryChar = self.entryChars[i]

            gc:drawString(tostring(entryChar), x + ENTRY_PADDING, drawY + ENTRY_PADDING, "middle")

            gc:drawString(item[1], x + ENTRY_PADDING + 15, drawY + ENTRY_PADDING, "middle")

            if not isSubmenu then gc:drawString("▶", x + width - 10, drawY + ENTRY_PADDING, "middle") end
        end
    end

    return width
end

function ToolPalette:paint(gc)
    if not self.active or not self.menuStructure then return end

    local x, y = 0, 0
    local parentEntry = self.menuStructure[self.hoveredIndex]

    self.menuWidth = self:paintMenu(gc, x, y, self.menuStructure, self.hoveredIndex)

    if self.submenuOpen and type(parentEntry) == "table" and #parentEntry > 1 then
        local submenu = {}
        for i = 2, #parentEntry do
            table.insert(submenu, parentEntry[i])
        end

        local submenuX = x + self.menuWidth
        local submenuY = y
        self.submenuWidth = self:paintMenu(gc, submenuX, submenuY, submenu, self.subHoveredIndex or 1, true)
    end
end

function ToolPalette:keypressed(key, scancode, isrepeat)
    if key == "m" and love.keyboard.isDown("lctrl", "rctrl") then
        self:activate()
        return
    end

    if not self.active then return end

    local topEntry = self.menuStructure[self.hoveredIndex]
    local submenuEntries = type(topEntry) == "table" and #topEntry > 1 and topEntry or nil

    if self.submenuOpen and submenuEntries then
        -- Submenu navigation
        if key == "down" then
            repeat
                self.subHoveredIndex = (self.subHoveredIndex or 1) + 1
                if self.subHoveredIndex > #submenuEntries - 1 then self.subHoveredIndex = 1 end
            until submenuEntries[self.subHoveredIndex + 1] ~= "-"
        elseif key == "up" then
            repeat
                self.subHoveredIndex = (self.subHoveredIndex or 1) - 1
                if self.subHoveredIndex < 1 then self.subHoveredIndex = #submenuEntries - 1 end
            until submenuEntries[self.subHoveredIndex + 1] ~= "-"
        elseif key == "left" then
            self.submenuOpen = false
            self.subHoveredIndex = nil
        elseif key == "right" then
            -- Already open, ignore
        end
    else
        -- Top-level navigation
        if key == "down" then
            repeat
                self.hoveredIndex = self.hoveredIndex + 1
                if self.hoveredIndex > #self.menuStructure then self.hoveredIndex = 1 end
            until self.menuStructure[self.hoveredIndex] ~= "-"
        elseif key == "up" then
            repeat
                self.hoveredIndex = self.hoveredIndex - 1
                if self.hoveredIndex < 1 then self.hoveredIndex = #self.menuStructure end
            until self.menuStructure[self.hoveredIndex] ~= "-"
        elseif key == "right" then
            if submenuEntries then
                self.submenuOpen = true
                self.subHoveredIndex = 1
            end
        end
    end
end
