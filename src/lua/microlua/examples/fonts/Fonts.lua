--[[

        ==>[ MICROLUA EXAMPLE ]<==
                    ==>{ Fonts }<==
        
        About using custom fonts to make
                 your texts look better.

]]--

font = Font.load("test.oft")
for i = 32, 126 do -- printable ASCII
    screen.printFont(SCREEN_DOWN, 0, (i - 32) * 8, string.char(i), Color.new(31, 31, 0), font)
end
render()
while not Keys.newPress.Start do Controls.read() end


Font.destroy(font)                                                    -- Destroy the custom font
font = nil
