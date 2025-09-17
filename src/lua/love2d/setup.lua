local major, minor, revision, codename = love.getVersion()
print(string.format("LÖVE version: %d.%d.%d - %s", major, minor, revision, codename))

local loadStep = 0
local loadMessage = "init"

function love.load()
    loadStep = 1

    function love.update(dt)
        if loadStep == 1 then
            loadMessage = "pc"
            require("love2d.pc")
            loadStep = loadStep + 1
            loadMessage = "sound engine apollolite"
        elseif loadStep == 2 then
            require("love2d.sound.apollolite")
            loadStep = loadStep + 1
            loadMessage = "ti-nspire polyfills"
        elseif loadStep == 3 then
            require("love2d.polyfill.all")
            loadStep = loadStep + 1
            loadMessage = "ti-nspire polyfills"
        elseif loadStep == 4 then
            require("love2d.ttf.fonts")
            loadStep = loadStep + 1
            loadMessage = "cursors loading"
        elseif loadStep == 5 then
            require("love2d.cursors.setup")
            loadStep = loadStep + 1
            loadMessage = "bindings"
        elseif loadStep == 6 then
            require("love2d.bindings")
            love.load() --its rebound after running love2d.bindings

            --this is debug info here
            print("Operating System:", __PC.os)

            --get desktop dimensions
            if love.window and love.window.getDesktopDimensions then
                local width, height = love.window.getDesktopDimensions(1)
                print("Desktop Dimensions: "..width.."x"..height) --on android its 2400x1080
            else
                print("Desktop Dimensions: Unknown")
            end
            print("Scale: "..__PC.scale.." OffsetX: "..__PC.screenOffsetX.." OffsetY: "..__PC.screenOffsetY.." PaddingX: "..__PC.screenPaddingX.." PaddingY: "..__PC.screenPaddingY)

            -- if __PC.os == "Android" then
            --     local winW, winH = love.graphics.getDimensions()

            --     -- Safe drawable area in pixels
            --     local drawW, drawH = love.graphics.getWidth(), love.graphics.getHeight()

            --     -- Desktop resolution (monitor)
            --     local deskW, deskH = love.window.getDesktopDimensions(1)

            --     -- Current window position and size
            --     local wx, wy, ww, wh = love.window.getPosition()
            --     -- local winInfo = love.window.getMode()

            --     print("=== Dimension Stats ===")
            --     print("Window Dimensions:", winW, "x", winH)
            --     print("Drawable Area:", drawW, "x", drawH)
            --     print("Desktop Resolution:", deskW, "x", deskH)
            --     print("Window Position:", wx, wy)
            --     -- print("Window Mode:")
            --     -- for k, v in pairs(winInfo) do
            --     --     print("  ", k, v)
            --     -- end
            --     print("=======================")
            -- end

            __loadGame__()
        end
    end

    function love.draw(screen)
        if screen == "top" then return end

        love.graphics.clear(0, 0, 0)
        love.graphics.setColor(1, 1, 1)
        
        if loadStep == 0 then
            love.graphics.print("Waiting to start loading...", 20, 20)
        else
            love.graphics.print("Loading step "..loadStep..": "..loadMessage.."...", 20, 20)
        end
    end
end