toolpalette = {
    register = function(menuStructure)
        print("Set menuStructure!")
        ToolPalette.menuStructure=menuStructure
        ToolPalette.active=false
    end,
    -- ignore below for now
    enable = function(toolname, itemname, enable)
        local menu = ToolPalette.menuStructure
        if not menu then return end

        for _, toolbox in ipairs(menu) do
            local toolboxName = toolbox[1]
            if toolboxName == toolname then
                -- Iterate submenu items (starting from index 2)
                for i = 2, #toolbox do
                    local item = toolbox[i]
                    if type(item) == "table" and item[1] == itemname then
                        item.disabled = not enable
                        return
                    end
                end
            end
        end
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
    local wasActive = self.active

    if (self.active or bindName=="keypressed") and self[bindName] then
        self[bindName](self, ...)
    end

    return wasActive --returning true will block other calls to bindings
end

function ToolPalette:activate(state)
    if not self.menuStructure then return end

    self.active=state==nil and (not self.active) or state

    if self.active then
        self.hoveredIndex = 1
        self.subHoveredIndex = nil
        self.submenuOpen = false
    end
end

__PC.ToolPalette = ToolPalette

local ENTRY_HEIGHT = 20
local FONT_HEIGHT = 16
local DIVIDER_HEIGHT = 3
local DIVIDER_COLOUR = {r=151, g=151, b=151}
local HIGHLIGHT_COLOUR = {r=36, g=120, b=207}
local SUB_HIGHLIGHT_COLOUR = {r=135, g=177, b=221}
local TEXT_COLOUR = {r=0, g=0, b=0}
local HIGHLIGHT_TEXT_COLOUR = {r=255, g=255, b=255}
local DISABLED_TEXT_COLOUR = {r=139, g=138, b=138}
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
    return maxWidth + 15 + ENTRY_PADDING * 2
end

function ToolPalette:getMenuHeight(entries, atEntry)
    local totalHeight = 0
    for i, item in ipairs(entries) do
        if item == "-" then
            totalHeight = totalHeight + DIVIDER_HEIGHT
        else
            totalHeight = totalHeight + ENTRY_HEIGHT
        end

        if atEntry and i == atEntry then
            return totalHeight
        end
    end
    return totalHeight
end

ToolPalette.entryChars = {
    1, 2, 3, 4, 5, 6, 7, 8, 9, "A", "B", "C", "D", "E", "F", "G", "H", "I"
}

function ToolPalette:paintMenu(gc, x, y, entries, hoveredIndex, isSubmenu)
    local width = self:getMenuWidth(gc, entries) + (isSubmenu and 0 or 12)

    if width+x>__PC.nativeWidth then
        x=__PC.nativeWidth-width
    end

    local height = self:getMenuHeight(entries)

    if height+y>__PC.nativeHeight then
        local heightUpToHovered = ToolPalette:getMenuHeight(entries, hoveredIndex)
        y = math.min(y, __PC.nativeHeight - heightUpToHovered)
    end

    if isSubmenu then
        local shadowLayers = 6
        local baseAlpha = 25
        local alphaStep = baseAlpha / shadowLayers
        local shadowOffsetX, shadowOffsetY = -4, -1

        for i = 1, shadowLayers do
            local alpha = baseAlpha - (i - 1) * alphaStep
            gc:setColorRGB(0, 0, 0, alpha)
            gc:fillRect(x + shadowOffsetX + i, y + shadowOffsetY + i, width, height)
        end
    end

    local currentY = 0
    local currentI = 0

    for i, item in ipairs(entries) do
        local entryHeight = (item == "-") and DIVIDER_HEIGHT or ENTRY_HEIGHT
        local drawY = y + currentY

        if item == "-" then
            gc:setColorRGB(255, 255, 255)
            gc:fillRect(x, drawY, width, DIVIDER_HEIGHT)
            gc:setColorRGB(DIVIDER_COLOUR.r, DIVIDER_COLOUR.g, DIVIDER_COLOUR.b)
            gc:drawLine(x + 1, drawY, x + width - 2, drawY + 1)
        else
            currentI = currentI + 1
            if i == hoveredIndex then
                if (not isSubmenu) and self.submenuOpen then
                    gc:setColorRGB(SUB_HIGHLIGHT_COLOUR.r, SUB_HIGHLIGHT_COLOUR.g, SUB_HIGHLIGHT_COLOUR.b)
                else
                    gc:setColorRGB(HIGHLIGHT_COLOUR.r, HIGHLIGHT_COLOUR.g, HIGHLIGHT_COLOUR.b)
                end
                gc:fillRect(x, drawY, width, entryHeight)
                gc:setColorRGB(HIGHLIGHT_TEXT_COLOUR.r, HIGHLIGHT_TEXT_COLOUR.g, HIGHLIGHT_TEXT_COLOUR.b)
            else
                gc:setColorRGB(255, 255, 255)
                gc:fillRect(x, drawY, width, entryHeight)
                if not item.disabled then
                    gc:setColorRGB(TEXT_COLOUR.r, TEXT_COLOUR.g, TEXT_COLOUR.b)
                else
                    gc:setColorRGB(DISABLED_TEXT_COLOUR.r, DISABLED_TEXT_COLOUR.g, DISABLED_TEXT_COLOUR.b)
                end
            end

            local entryChar = self.entryChars and self.entryChars[currentI] or ""
            gc:drawString(tostring(entryChar), x + ENTRY_PADDING, drawY + ENTRY_PADDING - 2, "middle")
            gc:drawString(item[1], x + ENTRY_PADDING + 15, drawY + ENTRY_PADDING - 2, "middle")

            if not isSubmenu then
                gc:drawString("▶", x + width - 10, drawY + ENTRY_PADDING, "middle")
            end
        end

        currentY = currentY + entryHeight
    end

    return width
end

function ToolPalette:paint(gc)
    if not self.active or not self.menuStructure then return end

    local x, y = 0, 0
    local parentEntry = self.menuStructure[self.hoveredIndex]
    gc:setFont("sansserif", "r", FONT_HEIGHT)

    self.menuWidth = self:paintMenu(gc, x, y, self.menuStructure, self.hoveredIndex)

    if self.submenuOpen and type(parentEntry) == "table" and #parentEntry > 1 then
        local submenu = {}
        for i = 2, #parentEntry do
            table.insert(submenu, parentEntry[i])
        end

        local submenuX = x + self.menuWidth
        local submenuY = y
        local heightAtEntry=self:getMenuHeight(self.menuStructure, self.hoveredIndex) - ENTRY_HEIGHT

        local heightOfSubmenu=self:getMenuHeight(submenu)

        submenuY = submenuY + math.min(heightAtEntry, math.max(0, __PC.nativeHeight-heightOfSubmenu))

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
            until submenuEntries[self.subHoveredIndex + 1] and submenuEntries[self.subHoveredIndex + 1] ~= "-" and not submenuEntries[self.subHoveredIndex + 1].disabled
        elseif key == "up" then
            repeat
                self.subHoveredIndex = (self.subHoveredIndex or 1) - 1
                if self.subHoveredIndex < 1 then self.subHoveredIndex = #submenuEntries - 1 end
            until submenuEntries[self.subHoveredIndex + 1] and submenuEntries[self.subHoveredIndex + 1] ~= "-" and not submenuEntries[self.subHoveredIndex + 1].disabled
        elseif key == "left" or key == "escape" then
            self.submenuOpen = false
            self.subHoveredIndex = nil
        elseif key == "right" then
        elseif key == "return" then
            local submenuItem = submenuEntries[self.subHoveredIndex + 1]
            if submenuItem and type(submenuItem) == "table" and type(submenuItem[2]) == "function" then
                submenuItem[2](topEntry[1], submenuItem[1])
            end
            self.active = false
        end
    else
        if key == "down" then
            repeat
                self.hoveredIndex = self.hoveredIndex + 1
                if self.hoveredIndex > #self.menuStructure then self.hoveredIndex = 1 end
            until self.menuStructure[self.hoveredIndex] and self.menuStructure[self.hoveredIndex] ~= "-" and not self.menuStructure[self.hoveredIndex].disabled
        elseif key == "up" then
            repeat
                self.hoveredIndex = self.hoveredIndex - 1
                if self.hoveredIndex < 1 then self.hoveredIndex = #self.menuStructure end
            until self.menuStructure[self.hoveredIndex] and self.menuStructure[self.hoveredIndex] ~= "-" and not self.menuStructure[self.hoveredIndex].disabled
        elseif key == "right" or key == "return" then
            if submenuEntries then
                self.submenuOpen = true
                self.subHoveredIndex = 1
            end
        elseif key == "escape" then
            self.active = false
        end
    end
end

function ToolPalette:mousemoved(mx, my)
    if not self.active or not self.menuStructure then return end

    local x, y = 0, 0
    local submenuOpen = self.submenuOpen
    local parentEntry = self.menuStructure[self.hoveredIndex]
    local submenuEntries = type(parentEntry) == "table" and #parentEntry > 1 and parentEntry or nil

    -- Helper to get absolute entry rectangles for main menu and submenu:
    local function getEntryRects(entries, baseX, baseY)
        local rects = {}
        local currentY = baseY
        for i, item in ipairs(entries) do
            local height = (item == "-") and DIVIDER_HEIGHT or ENTRY_HEIGHT
            if item ~= "-" then
                table.insert(rects, {index = i, x = baseX, y = currentY, w = self:getMenuWidth(gc, entries), h = height})
            end
            currentY = currentY + height
        end
        return rects
    end

    -- Calculate main menu rects
    local mainRects = getEntryRects(self.menuStructure, x, y)

    -- If submenu open, calculate submenu rects with proper position
    local submenuRects = nil
    if submenuOpen and submenuEntries then
        local submenu = {}
        for i = 2, #submenuEntries do
            table.insert(submenu, submenuEntries[i])
        end

        local submenuX = x + self.menuWidth
        local submenuY = y
        local heightAtEntry = self:getMenuHeight(self.menuStructure, self.hoveredIndex) - ENTRY_HEIGHT
        local heightOfSubmenu = self:getMenuHeight(submenu)

        submenuY = submenuY + math.min(heightAtEntry, math.max(0, __PC.nativeHeight - heightOfSubmenu))

        submenuRects = getEntryRects(submenu, submenuX, submenuY)
    end

    -- First check if mouse is over submenu (priority)
    if submenuRects then
        for i, rect in ipairs(submenuRects) do
            if mx >= rect.x and mx < rect.x + rect.w and my >= rect.y and my < rect.y + rect.h then
                -- i-th submenu item hovered (index in submenu is i)
                -- Remember submenu indexing is offset by +1 in the parent structure
                -- Also skip disabled and dividers
                local submenuItem = submenuEntries[i + 1]
                if submenuItem and submenuItem ~= "-" and not submenuItem.disabled then
                    self.subHoveredIndex = i
                    return
                end
            end
        end
        -- If mouse not on submenu, but submenu open, you can optionally clear subHoveredIndex or keep it
        -- self.subHoveredIndex = nil
    else

        -- Otherwise check main menu entries
        for _, rect in ipairs(mainRects) do
            if mx >= rect.x and mx < rect.x + rect.w and my >= rect.y and my < rect.y + rect.h then
                local item = self.menuStructure[rect.index]
                if item and item ~= "-" and not item.disabled then
                    self.hoveredIndex = rect.index
                    return
                end
            end
        end
    end

    -- Mouse outside menus: optionally do nothing or clear hovers
    -- self.subHoveredIndex = nil
    -- self.hoveredIndex = nil
end

function ToolPalette:mousepressed(x, y, button)
    self:keypressed("return")
end