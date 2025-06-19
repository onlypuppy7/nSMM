--compatability: full
--tested: yes

-- https://love2d.org/wiki/love.system.getClipboardText

clipboard = {
    addText = function(text)
        love.system.setClipboardText( text )
    end,
    getText = function()
        return love.system.getClipboardText()
    end
}