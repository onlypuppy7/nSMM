dofile("Clavier.lua")  -- load the Clavier module

-- -- create a clavier instance
-- local clavv = clavier.new()

-- -- activate its default text screen
-- clavier.activeScreen(clavv, true)

-- main loop
local quit = false
local input = ""

while not quit do
    Controls.read()
    
    if Keys.newPress.Start then
        quit = true
    end

    if Stylus.newPress then
        local key = clavier.held(clavv, Stylus.X, Stylus.Y)
        if key == "Enter" then
            quit = true
        end
    end

    input = clavier.getText(clavv)

    screen.print(SCREEN_UP, 10, 10, "Input: " .. input)
    clavier.show(clavv)
    render()
end

clavier.del(clavv)
