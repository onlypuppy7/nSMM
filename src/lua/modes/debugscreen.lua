debugScreen=class()

--use _DEBUG_ to track state, eg nil/false=disabled, true=debug mode enabled, "menu"=debug menu open

function debugScreen:init()
end

function debugScreen:reset()
end

function debugScreen:charIn(chr) --hooked up
    if _DEBUG_=="menu" then
        if chr=="1" then
            _DEBUG_="textureViewer"
            self.currentTextureIndex=1
            self.textureNames={}
            for k,v in pairs(texs) do
                table.insert(self.textureNames,k)
            end
            print("Total textures: "..#self.textureNames)
        end
    elseif _DEBUG_=="textureViewer" then
        print(chr)
        if chr=="[" then
            self.currentTextureIndex=self.currentTextureIndex-1
            if self.currentTextureIndex<1 then self.currentTextureIndex=#self.textureNames end
        elseif chr=="]" then
            self.currentTextureIndex=(self.currentTextureIndex+1)%#self.textureNames
        end
    end
end

function debugScreen:escapeKey() --not hooked up
    _DEBUG_="menu"
end

function debugScreen:mouseDown() --not hooked up
end

function debugScreen:paint(gc) --hooked up
    if _DEBUG_=="menu" then
        gc:setColorRGB(0,0,0)
        gc:fillRect(50,50,220,120)
        drawFont(gc,"DEBUG MENU",160,20,"centre",0)
        drawFont(gc,"Press 'd' to exit debug mode",160,30,"centre",0)
        gc:setColorRGB(255,255,255)
        gc:drawRect(50,50,220,120)
        drawFont(gc,"1 - Texture Viewer",60,60,"left",0)
    elseif _DEBUG_=="textureViewer" then
        gc:setColorRGB(0,0,0)
        gc:fillRect(0,0,screenWidth,screenHeight)
        drawFont(gc,"TEXTURE VIEWER",160,20,"centre",0)
        drawFont(gc,"Press 'esc' to return to debug menu",160,30,"centre",0)
        --view them one at a time, incrementing the index with each press of a key (eg space)
        local texName=self.textureNames[self.currentTextureIndex]
        local tex=texs[texName]
        if tex then
            gc:setColorRGB(255,255,255)
            drawFont(gc,"Texture "..self.currentTextureIndex.." of "..#self.textureNames..":",160,40,"centre",0)
            gc:drawString(texName,160-(gc:getStringWidth(texName)/2),58)
            drawFont(gc,tex:width().."x"..tex:height(),160,63,"centre",0)

            gc:drawImage(tex,(screenWidth/2)-(tex:width()/2),80)

            gc:drawString("Use [ and ] to cycle through textures",20,screenHeight-30)
        else
            drawFont(gc,"No texture found at index "..self.currentTextureIndex,160,40,"centre",0)
        end
    end
    
    gc:setColorRGB(255,0,0)
    gc:drawString("DEBUG SCREEN",0,screenHeight-8)
end