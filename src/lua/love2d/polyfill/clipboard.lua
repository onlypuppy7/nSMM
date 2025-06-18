-- https://love2d.org/wiki/love.system.getClipboardText

clipboard = {
    addText: function(text) {
        love.system.setClipboardText( text )
    },
    getText: function {
        return love.system.getClipboardText( )
    }
}