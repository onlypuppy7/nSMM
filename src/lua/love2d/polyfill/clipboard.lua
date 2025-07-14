--compatability: full
--tested: yes

-- https://love2d.org/wiki/love.system.getClipboardText

local clipboardText = nil

clipboard = {
    addText = function(text)
        print("@COPY"..tostring(text))
        if love.system.setClipboardText then
            love.system.setClipboardText(text)
        end
    end,
    getText = function()
        return clipboardText or (love.system.getClipboardText and love.system.getClipboardText())
    end
}

__PC.handleDecodedInput = function(decoded)
    print("Decoded input received:", decoded)
    clipboardText = decoded
end