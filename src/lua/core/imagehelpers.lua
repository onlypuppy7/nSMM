function rgb2ti(R,G,B,A) --these functions are mostly just here for fun - they cannot actually be used to generate an image on the fly unfortunately. they do return accurate colour codes that can be used to hardcode values though
    if A==0 then return "\000\000" end
    R=toBinary(math.floor(R/8),5)
    G=toBinary(math.floor(G/8),5)
    B=toBinary(math.floor(B/8),5)
    local data="1"..R..G..B
    data={string.sub(data, 1, 8),string.sub(data, 9, 16)}
    return ("\\"..addZeros(tonumber(data[2],2),3).."\\"..addZeros(tonumber(data[1],2),3))
end

function ti2rgb(data) --will not return fully accurate values due to compressing values to make it TI-image compatible
    data={string.sub(data,2,4),string.sub(data,6,8)}
    data=(toBinary(tonumber(data[2]),8))..(toBinary(tonumber(data[1]),8))
    local R=((tonumber(string.sub(data,2,6),2)+1)*8)-1
    local G=((tonumber(string.sub(data,7,11),2)+1)*8)-1
    local B=((tonumber(string.sub(data,12,16),2)+1)*8)-1
    return{R,G,B}
end

function string2image(name,flipImage,string,recolour) --recolour={{{"\000\000","\100\100","newname"},more colour swaps},etc}
    local function toInt(v) return string.byte(v) end --if flipping, assumes input string is facing left
    local function toPairs(str)
        local t = {}
        for i = 1, #str, 2 do
            t[#t+1] = string.sub(str, i, i+1)
        end
        return t
    end
    local function substitute(body, lookFor, replaceWith)
        local pairs = toPairs(body)
        for i = 1, #pairs do
            if pairs[i] == lookFor then
                pairs[i] = replaceWith
            end
        end
        return table.concat(pairs)
    end

    for flip=0,(flipImage and 1 or 0) do
        if flip==1 then name=flipImage
            local function flipImage(img)
                local imageString,imageTable,flippedTable=string.sub(img,21),{},{}
                local w,h=toInt(string.sub(img,1,1))+(toInt(string.sub(img,2,2))*255),toInt(string.sub(img,5,5))+(toInt(string.sub(img,6,6))*255) --retrieve width and height
                for i=1,#imageString,2 do --conv to table
                    local colorValue=string.sub(imageString,i,i+1)
                    table.insert(imageTable,colorValue)
                end
                for i=1,h do --flip horizontally
                    local startIndex,endIndex,row=(i-1)*w+1,i*w,{}
                    for i2=endIndex,startIndex,-1 do table.insert(row,imageTable[i2]) end
                    table.insert(flippedTable,table.concat(row))
                end
                local flippedString=table.concat(flippedTable) --reconstruct string
                return string.sub(img,1,20)..flippedString
            end string=flipImage(string)
        end
        if recolour then for i=1,#recolour do -- recolour = all recoloured images, i = recolours for new img, i2[1] = old colour, i2[2] = new colour, i2[3] = new name
            local newImg=string
            for i2=3,#recolour[i] do --all recolours
                newImg=string.sub(newImg,1,20)..substitute(string.sub(newImg,21),recolour[i][i2][1],recolour[i][i2][2])
            end
            local imgName=(flip==0) and recolour[i][1] or recolour[i][2]
            texs[imgName]=image.new(newImg)
        end end
        texs[name]=image.new(string)
end end