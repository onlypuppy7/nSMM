--compatability: full
--tested: yes

-- https://love2d.org/wiki/love.system.getClipboardText

local clipboardText = ""

clipboard = {
    addText = function(text)
        print("@COPY"..tostring(text))
        love.system.setClipboardText(text)
    end,
    getText = function()
        return clipboardText or love.system.getClipboardText()
    end
}

__PC.handleDecodedInput = function(decoded)
    print("Decoded input received:", decoded)
    clipboardText = decoded
end