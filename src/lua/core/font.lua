fontLookup={           --all special characters - <>&^&@.!-+
    ["["] = "_1", --coin icon 1
    ["{"] = "_2", --coin icon 2
    ["}"] = "_3", --coin icon 3
    ["'"] = "_a", --apostrophe
    [")"] = "_b", --close brackets
    ["("] = "_bc", --open brackets
    [":"] = "_c", --colon
    ["@"] = "_cp", --copyright icon
    ["."] = "_d", --period
    ["="] = "_e", --equal
    ["!"] = "_ex", --exclamation mark
    ["$"] = "_h", --home icon
    ["-"] = "_hy", --hyphen
    [","] = "_k", --comma
    ["<"] = "_m", --mario icon
    ["~"] = "_n", --back icon
    ["^"] = "_p", --power
    ["?"] = "_q", --question mark
    [";"] = "_s", --semicolon
    ["/"] = "_sf", --forward slash
    [">"] = "_t", --clock/time icon
    ["+"] = "_x"  --X icon
}

require("data.textures-font")

function drawFont(gc,text,x,y,position,spacing,backdrop,size,FONT)
    if fontsLoaded then
        local function countFont(text,spacing) -- this is for font2, small font
            local length=0 local spacing=spacing or 0
            for i=1,#text do
                length=length+((string.lower(string.sub(text,i,i))=="m" or string.lower(string.sub(text,i,i))=="w") and 6 or 5)+spacing
        end return length end
        x=x or 158 y=y or 106 size=size or 1 spacing=spacing or 0 FONT=FONT or "font1"
        local drawOffset,totalLength=0,FONT=="font2" and countFont(text,spacing)-1 or (#text*((8*size)+spacing))-1
        if position~=nil then
            if position=="left" then drawOffset=0
            elseif position=="centre" or position=="center" then drawOffset=1-math.ceil(totalLength/2) --british english and american english #_#
            elseif position=="right" then drawOffset=-totalLength
            end
        end
        if backdrop and #text>0 then
            gc:setColorRGB(0,0,0)
            if backdrop=="rgb" then timer2rainbow(gc,framesPassed+200,10) end
            local height=(FONT=="font2") and 6 or 10
            gc:fillRect(x+drawOffset-1,y-1,totalLength+2,height)
        end
        for i=1,#text do
            local letter,texture=string.sub(text,i,i)
            if letter:isAlphaNumeric() then
                texture=texs[FONT.."_"..string.lower(letter)]
            elseif fontLookup[letter]~=nil then
                texture=texs[FONT.."_"..fontLookup[letter]]
            end
            if texture then
                if size~=1 then texture=image.copy(texture,8*size,8*size) end
                gc:drawImage(texture,x+drawOffset,y)
            end
            drawOffset=drawOffset+(FONT~="font2" and (8*size)+spacing or countFont(letter,spacing))
        end
    else
        y=y or 106 x=x or 158
        local width=gc:getStringWidth(text)
        if position=="centre" then
            x=x-(width/2)
        elseif position=="right" then
            x=x-width
        end
        gc:setColorRGB(255,255,255)
        gc:drawString(text,x,y,"top")
    end
end

function drawFont2(gc,text,x,y,position,spacing,backdrop,size,FONT) drawFont(gc,text,x,y,position,spacing,backdrop,size,"font2") end