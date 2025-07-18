local major, minor, revision, codename = love.getVersion()
print(string.format("LÖVE version: %d.%d.%d - %s", major, minor, revision, codename))

local loadStep = 0
local loadMessage = "init"

function love.load()
    loadStep = 1
end

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
        love.load()
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