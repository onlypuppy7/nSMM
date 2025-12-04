--levelserialise.lua

function level2string(levelData,TEMPORARY)
    local starts=pixel2plot(levelData.startX,levelData.startY,true)
    local stageSettings="!" local currentBlock={nil,0} local i=0
    if levelData.disableBackScrolling==true         then stageSettings=stageSettings.."s" end
    if levelData.allowBidirectionalSpawning==true   then stageSettings=stageSettings.."b" end
    if levelData.enableGlobalEntities==true         then stageSettings=stageSettings.."g" end
    if levelData.enableShellBouncing==true          then stageSettings=stageSettings.."k" end
    if levelData.enableCoinOnKill==true             then stageSettings=stageSettings.."c" end
    if levelData.enablePowerUpBouncing==true        then stageSettings=stageSettings.."p" end
    if levelData.autoScroll                         then stageSettings=stageSettings..tostring(levelData.autoScroll) end
    if levelData.autoMove                           then stageSettings=stageSettings..levelData.autoMove end
    if levelData.showCeilingBlock==true             then stageSettings=stageSettings.."i" end
    local pipeData="!"
    for i=1,#levelData.pipeData do
        local pipe=levelData.pipeData[i] -- VV there is possibly a better way of doing this, but eh. not worth it
        pipeData=pipeData..(pipe[1][3]..pipe[2][3]):octalToBase64() --add ID
        pipeData=pipeData..string.upper(string.format("%x",pipe[1][2])) --add y of entrance
        pipeData=pipeData..string.upper(string.format("%x",pipe[1][1])) --add x of entrance
        pipeData=pipeData.."_" --add separator
        pipeData=pipeData..string.upper(string.format("%x",pipe[2][2])) --add y of exit
        pipeData=pipeData..string.upper(string.format("%x",pipe[2][1])) --add x of exit
        if (i~=#levelData.pipeData) then pipeData=pipeData.."|" end --add line to separate more pipes
    end
    local scrollStopData="!" table.sort(levelData.scrollStopL) table.sort(levelData.scrollStopR) --just to be sure it is the right order
    for i=2,#levelData.scrollStopL do --an example scrollStopL: {0,256,512}
        scrollStopData=scrollStopData..string.upper(string.format("%x",levelData.scrollStopL[i]/16))
        if (i~=#levelData.scrollStopL) then scrollStopData=scrollStopData.."_" end --add underscore to separate more scroll stops
    end scrollStopData=scrollStopData.."|" --line separates left and right
    for i=1,#levelData.scrollStopR-1 do --an example scrollStopL: {64*16-318,playStage.levelWidth-318}
        scrollStopData=scrollStopData..string.upper(string.format("%x",(levelData.scrollStopR[i]+318)/16))
        if (i~=(#levelData.scrollStopR-1)) then scrollStopData=scrollStopData.."_" end --add underscore to separate more scroll stops
    end
    local STRING="<"..levelData.END.."-v8-"..starts[1].."~"..starts[2].."-"..stageSettings.."-"..levelData.TIME.."-v"..versText.."-"..tostring(versNum).."-"..string.gsub(levelData.courseName or "my course","-","_").."-"..username.."-"..pipeData.."-"..scrollStopData..">" --header: end of stage, version of string conversion (for compatibility)
    for y=1,15 do -- y axis, bottom to top, in a column... 14th row initiates theme processing... 15th initiates finalisation
        for x=1,levelData.END do -- x axis, left to right, horizontally per row
            i=i+1
            local ID=levelData.get(x,y) or 0 --get ID of block at x,y
            if y==14 then ID=levelData.t[x] or 0 end --at the end, start processing of themes
            if ID==currentBlock[1] then -- same as last block
                currentBlock[2]=currentBlock[2]+1
            end
            if ID~=currentBlock[1] or y==15 then -- begin processing last block
                if currentBlock[2]>0 then -- apply to string
                    STRING=STRING.."," currentBlock[1]=currentBlock[1] or 0
                    if currentBlock[1]~=0 and currentBlock[1] or currentBlock[2]==1 then STRING=STRING..currentBlock[1] end -- write ID, remains blank if multiple air
                    if currentBlock[2]>1 then -- if multiple of the same
                        STRING=STRING.."*"..string.upper(string.format("%x", currentBlock[2])) -- formats as such: *FF <-- 255 blocks of air
                end end
                if y==15 then break end
                currentBlock={ID,1}
    end end end
    return STRING
end

function string2level(STRING,offsetX,offsetY,dataDepth) -- if offsetX is true, then returns table with only metadata
    offsetX=type(offsetX)=="number" and offsetX or 0 offsetY=offsetY or 0
    local levelDataTable,levelData,levelPos={},{},0
    levelDataTable=STRING:split(",")
    local HEADER=string.sub(levelDataTable[1],2,(#levelDataTable[1]-1))
    HEADER=HEADER:split("-")
-- dataDepth: 1 (for levelList)
    levelData.versText=HEADER[6] or "pre v0.9.0"
    levelData.versNum=tonumber(HEADER[7]) or 41
    levelData.courseName=string.gsub(HEADER[8] or "My Course","_","-")
    levelData.author=HEADER[9] or "Unknown"
    levelData.END=tonumber(HEADER[1])
    if dataDepth==1 then return {levelData.courseName,levelData.versNum,levelData.versText,levelData.author,levelData.END} end
-- dataDepth: full (playing level)
    levelData.version=       HEADER[2]
    local starts=HEADER[3]:split("~")
    local stageSettings=     HEADER[4]
    levelData.TIME= tonumber(HEADER[5]) or 500
    starts=plot2pixel(starts[1],starts[2])
    levelData.startX=starts[1]+1 levelData.startY=starts[2]
    levelData.loadedObjects={}
    levelData.pipeData={} -- deal with pipe data
    if HEADER[10] and ((#HEADER[10])>1) then --process pipes
        local pipes=(string.sub(HEADER[10],2,#HEADER[10])):split("|")
        -- print(HEADER[10],unpack(pipes))
        for i=1,#pipes do
            -- print(pipes[i],string.sub(pipes[i],1,1))
            local types=string.sub(pipes[i],1,1):base64ToOctal()
            types={tonumber(string.sub(types,1,1)),tonumber(string.sub(types,2,2))}
            -- print(unpack(types))
            local pos=(string.sub(pipes[i],2,#pipes[i])):split("_")
            -- print(string.sub(pos[2],2,#pos[2]))
            pos[1]={tonumber(string.sub(pos[1],2,#pos[1]),16),tonumber(string.sub(pos[1],1,1),16)}
            pos[2]={tonumber(string.sub(pos[2],2,#pos[2]),16),tonumber(string.sub(pos[2],1,1),16)}
            -- print(pos[1][1],"|",pos[1][2],"|",pos[2][1],"|",pos[2][2])
            table.insert(levelData.pipeData,{{pos[1][1],pos[1][2],types[1]},{pos[2][1],pos[2][2],types[2]}})
        end
    end
    -- levelData.pipeData={{{3,3,1},{5,5,2}},{{10,10,3},{20,10,1}}}
    levelData.scrollStopL={}
    levelData.scrollStopR={}
    if HEADER[11] and ((#HEADER[11])>1) then --process scroll stops
        local scrollStopData,offset=HEADER[11]:split("|"),0 -- [1]=left [2]=right
        scrollStopData[1]=string.sub(scrollStopData[1],2,#scrollStopData[1])
        local currentScrollStop=levelData.scrollStopL
        for i=1,#scrollStopData do
            local scrollStopPoints=scrollStopData[i]:split("_")
            for i2=1,#scrollStopPoints do
                table.insert(currentScrollStop,tonumber(scrollStopPoints[i2],16)*16-offset)
            end
            currentScrollStop,offset=levelData.scrollStopR,318
        end
    end table.insert(levelData.scrollStopL,1,0) table.insert(levelData.scrollStopR,(levelData.END)*16-318) --add start and level end
    -- levelData.scrollStopL={0,256,512}
    -- levelData.scrollStopR={64*16-318,(levelData.END)*16-318}
    if stageSettings and stageSettings~="!" then
        for i=2,#stageSettings do
            local attribute=string.sub(stageSettings,i,i)
            if     attribute=="s" then levelData.disableBackScrolling=true
            elseif attribute=="b" then levelData.allowBidirectionalSpawning=true
            elseif attribute=="g" then levelData.enableGlobalEntities=true
            elseif attribute=="k" then levelData.enableShellBouncing=true
            elseif attribute=="c" then levelData.enableCoinOnKill=true
            elseif attribute=="p" then levelData.enablePowerUpBouncing=true
            elseif attribute=="w" or attribute=="r" then levelData.autoMove=attribute
            elseif attribute:isInteger() then levelData.autoScroll=attribute
            elseif attribute=="i" then levelData.showCeilingBlock=true
        end end
    end

    levelData.xy={}
    levelData.t={}
    levelData.get=function(x,y) --get function for xy table
        local key=plot2key(x,y)
        return levelData.xy[key] or 0
    end
    levelData.set=function(x,y,ID) --set function for xy table
        local key=plot2key(x,y)
        -- if ID==0 then levelData.xy[key]=nil --delete if possible
        -- else
            levelData.xy[key]=ID
        -- end
    end

    for i=2,#levelDataTable do
        local data=levelDataTable[i]:split("*")
        if string.sub(levelDataTable[i],1,1)=="*" then table.insert(data,1,nil) end
        data={data[1] or "0",tonumber(data[2] or 1,16)}
        if data[1]:isInteger() then data[1]=tonumber(data[1]) end
        for i2=1,data[2] do
            levelPos=levelPos+1
            if levelPos<=levelData.END*13 then
                levelData.set(((levelPos-1)%levelData.END)+1+offsetX, math.ceil(levelPos/levelData.END)+offsetY, data[1])
            elseif levelPos<=levelData.END*14 then --prevents first block always being overworld theme
                levelData.t[((levelPos-1)%levelData.END)+1+offsetX]=data[1]
            end
        end
    end

    return levelData
end

function copyLevel(levelData)
    return string2level(level2string(levelData))
end