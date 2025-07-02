editor=class()

function editor:init(gc)
    editor.showTrail=false editor.levelList=false
    editor.selectedID=1
    editor.highlightedTile={1,1}
    editor.selectionSize={16,16}
    editor.groupIndex={}
    editor.groupIndex[1]={"TERRAIN", "Ground",
    1  , 4  , 5  , 6  , 7  , 8  , 9  ,
    109, 105, 107, 106, 12 , 13 , 14 ,
    110, 11 , 108, 111, 15 , 16 , 17 ,
    152, 153, 60 , 61 , 62 , 18 , 29 ,
    166, 167, nil, 63 , 99 , 19 , 28 ,
    168, 170, 172, 174, nil, nil, nil,
    169, 171, 173, 175, nil, nil, nil,
    176, 178, 180, 182, nil, nil, nil,
    177, 179, 181, 183, nil, nil, nil,}
    editor.groupIndex[2]={"MYSTERY BOXES", "MysteryBox0",
    nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil,  nil, nil, nil,
    nil, 20 , 21 , 22 , 23 , 24 , nil,
    nil, nil, 2  , nil, 25 , nil, nil,
    nil, nil, nil, nil, nil, nil, nil}
    editor.groupIndex[3]={"BRICKS", "Brick",
    nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, 3  , nil, nil, nil,
    nil, 31 , 32 , 33 , 34 , 35 , nil,
    nil, nil, 30 , nil, 36 , nil, nil,
    nil, nil, nil, nil, nil, nil, nil}
    editor.groupIndex[4]={"INVIS. BLOCKS", "InvisibleBlock1",
    nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil,
    nil, 100, 101, 102, 103, 104, nil,
    nil, nil, 10 , nil, 112, nil, nil,
    nil, nil, nil, nil, nil, nil, nil}
    editor.groupIndex[5]={"ENEMIES", "goomba1",
    "koopa_G", "koopa_R", "Pkoopa_G", "Pkoopa_R_H", "Pkoopa_R_V", "Pkoopa_R_HV", "Pkoopa_R", -- o how the once nice neat formatting crumbles away once you introduce objects...
    "goomba", "piranhaplant_1", "piranhaplant_2", "piranhaplant_3", "piranhaplant_4", "shell_G", "shell_R",
    "bullet_L", "bullet_R", "blaster_L", "blaster_R", "blaster_LR", "shell_G_-4", "shell_G_4",
    "bowser", "flame_L", "flame_R", nil, nil, "shell_R_-6", "shell_R_6",
    nil, nil, nil, nil, nil, "koopa_B", "shell_B"}
    editor.groupIndex[6]={"POWER-UPS", "mushroom",
    nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, 
    nil, "mushroom", "fireflower", "Pfireflower", "star", "mushroom1up", nil,
    nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil}
    editor.groupIndex[7]={"PIPES", "group_pipe",
    nil, nil, 40 , 41 , 52 , 53 , nil,
    nil, nil, 48 , 49 , 55 , 54 , nil,
    nil, 47 , 59 , 56 , 51 , 44 , nil, 
    nil, 46 , 58 , 57 , 50 , 45 , nil,
    nil, nil, 43 , 42 , nil, nil, nil}
    editor.groupIndex[8]={"PLATFORMS", "platform",
    nil, "platform_0~2~au", nil,                nil, nil, "platform_0~2~fu", nil,
    "platform_0~2~al", nil, "platform_0~2~ar",  nil, "platform_0~2~fl", nil, "platform_0~2~fr", 
    nil, "platform_0~2~ad", nil,                nil, nil, "platform_0~2~fd", nil,
    nil, nil, nil, nil, nil, nil, nil,
    nil, "platform_0~2~ru", "platform_0~2~rd", nil, "platform_0~2~lx~64", "platform_0~2~ly~64", nil}
    editor.groupIndex[9]={"DECORATION", "Fence",
    80 , 81 , 82 , 83 , 84 , 85 , 86 ,
    65 , 66 , 67 , 71 , 72 , 73 , 87 ,
    68 , 69 , 70 , 74 , 75 , 76 , 88 , 
    77 , 78 , 79 , 89 , 91 , 93 , 95 ,
    129, 97 , 113, 90 , 92 , 94 , 96 ,
    128, 98 , 114, 122, nil, 121, 119,
    127, 126, 123, 124, 125, 118, 120,
    115, 116, 117, 130, 131, 132, 133}
    editor.groupIndex[10]={"THEMES", "theme0",
    nil, nil, nil, nil, nil, nil, nil,
    nil, nil, "theme0", nil, "theme1", nil, nil,
    nil, nil, "theme2", nil, "theme3", nil, nil, 
    nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil}
    editor.groupIndex[11]={"GIZMOS", "spring_O_1",
    154, 155, 156, 150, "spring_O", "spring_B", "spring_R",
    157, 158, 159, "switch_plo", "switch_plg", "switch_plb", "switch_plr",
    160, 161, 162, nil, nil, "switch_p", nil, 
    163, 164, 165, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil}
    editor.groupIndex[12]={"LEVEL CONFIG", "flag",
    nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, "mario", nil, nil, nil,
    "scrollStopL", nil, nil, nil, nil, nil, "flagpole",
    "scrollStopR", "viewpipe", nil, nil, nil, "magicorb_a1_m0", "magicorb_a1_m1",
    "scrollStopC", nil, nil, nil, nil, "magicorb_a0_m0", "magicorb_a0_m1"}
    -- editor.groupIndex[69]={"TEMPLATE", "texture",
    -- nil, nil, nil, nil, nil, nil, nil,
    -- nil, nil, nil, nil, nil, nil, nil,
    -- nil, nil, nil, nil, nil, nil, nil, 
    -- nil, nil, nil, nil, nil, nil, nil,
    -- nil, nil, nil, nil, nil, nil, nil}
    editor.tilebarTiles={1,2,3,4,5,6,7,8,9,10,11,12}
end

function editor:drawBackground(gc) --rendered in rows from bottom to top w/ the rows from left to right
    for i=math.ceil(editor.cameraOffset/16),math.ceil((screenWidth+editor.cameraOffset)/16) do --left to right, horizontally, only draw what is visible on screen
        local THEME=plot2theme(i,true)
        if THEME==0 then gc:setColorRGB(97,133,248) --daytime
        else gc:setColorRGB(0,0,0) --underground or nighttime or castle
        end
        gc:fillRect(((i-1)*16)-editor.cameraOffset,0,18,212) --backdrop
end end

function editor:setDisplayedGroup(group)
    gui:clear()
    editor.displayedGroup=group
    if group then
        local function countRow(num)
            for i=(num*7)-4,(num*7)+2 do
                if group[i] then return true end
            end return false
        end local rows,emptyRows=0,0
        while emptyRows<5 do rows=rows+1
            if countRow(rows) then emptyRows=0
            else emptyRows=emptyRows+1
            end
        end rows=rows-emptyRows
        editor.displayedGroup["rows"]=rows
        if rows>5 then
            editor.displayedGroup["scroll"]=0
            local x,y,h=-40,18,-55 --these values now specify position/height offset from original (in level list)
            gui:newButton("levelList_scrollUp",{"levelList_scrollUp",10,12},x+266,y+42,"gscrollU")
            gui:newButton("levelList_scrollDown",{"levelList_scrollDown",10,12},x+266,y+177+h,"gscrollD")
end end end

function editor:charIn(chr)
    if not gui.PROMPT and not editor.levelList then 
        if chr=="4" then
            editor.cameraOffset=editor.cameraOffset-21
        elseif chr=="5" then
            editor:setDisplayedGroup(editor.groupIndex[editor.tilebarTiles[1]])
        elseif chr=="6" then
            editor.cameraOffset=editor.cameraOffset+21
        elseif string.sub(editor.selectedID,1,4)~="warp" then
            if chr=="=" then
                if editor.select==false then
                    editor.eyedropperMode=not editor.eyedropperMode
                    editor.eraseMode=false
                    editor.playMode=false
                end
            elseif chr=="−" then
                editor.showTrail=not editor.showTrail
            elseif chr=="^" then
                editor.minimised=not editor.minimised
            elseif chr=="s" then toolpaletteSelection("File","Save")
            elseif chr=="o" then toolpaletteSelection("File","Open")
            elseif chr=="n" then toolpaletteSelection("File","Name")
            elseif chr=="c" then toolpaletteSelection("File","Copy to Clipboard")
            elseif chr=="l" then toolpaletteSelection("⇥Length","Current Length")
            elseif chr=="t" then toolpaletteSelection("Time","Current Time Limit")
            elseif chr=="play" then
                switchTimer(true)
                playStage:generate(level2string(level.current),false,true)
                playStage.active=true
            end
        end
    end
end
function editor:arrowLeft()
    if not gui.PROMPT and not editor.levelList then editor.cameraOffset=editor.cameraOffset-21 end
end
function editor:arrowRight()
    if not gui.PROMPT and not editor.levelList then editor.cameraOffset=editor.cameraOffset+21 end
end
function editor:arrowUp()
    if editor.displayedGroup and editor.displayedGroup["scroll"] then
        gui:click("gscrollU")
    end
end
function editor:arrowDown()
    if editor.displayedGroup and editor.displayedGroup["scroll"] then
        gui:click("gscrollD")
    end
end
function editor:mouseDown()
    if gui.PROMPT then
    elseif editor.highlightedArea=="grid" then
        local TILE=editor.selectedID
        if editor.eraseMode then TILE=0 end
        if editor.playMode==true then
            local pos=pixel2snapgrid(editor.mouseTile.x+editor.cameraOffset,editor.mouseTile.y-8,editor.selectionSize[1],editor.selectionSize[2])
            playStage:generate(level2string(level.current),false,pos)
            playStage.active=true
        elseif editor.eyedropperMode==true then
            local ID=pixel2ID(mouse.x,mouse.y-8,nil,true)
            if not (tostring(ID):isInteger() and ID<=0) then
                editor.selectedID=ID
            end
        elseif editor.platformSelect then
            local ID=level.current.get(editor.platformSelect[1],editor.platformSelect[2])
            local config=(string.sub(ID,10,#ID)):split("~")
            local mode=config[3]
            if string.sub(mode,1,1)=="l" and editor.platformSelect[3]~=true then
                editor.platformSelect[3]=true
            else
                editor.selectedID=ID
                editor.platformSelect=false
            end
        elseif editor.select==false then
            editor:placeTile(TILE,editor.highlightedTile[1],editor.highlightedTile[2])
            if editor.selectedIDCache then editor.selectedID=editor.selectedIDCache editor.selectedIDCache=false end
        elseif editor.select2==false then
            editor.select2=pixel2grid(editor.mouseTile.x,editor.mouseTile.y-8,editor.selectionSize[1],editor.selectionSize[2])
        else
            if editor.select2~=false then
                local posSelect=grid2pixel(editor.select[1],editor.select[2],editor.selectionSize[1],editor.selectionSize[2],true)
                local posSelect2=grid2pixel(editor.select2[1],editor.select2[2],editor.selectionSize[1],editor.selectionSize[2],true)
                local box=editor:determineSelectBox(posSelect[1],posSelect[2],editor.selectionSize[1]-1,editor.selectionSize[2]-1,posSelect2[1],posSelect2[2],editor.selectionSize[1]-1,editor.selectionSize[2]-1)
                if checkCollision(box[1],box[2]+8,box[3],box[4],editor.mouseTile.x,editor.mouseTile.y,1,1) then
                    editor:fillTiles(TILE,editor.select[1],editor.select[2],editor.select2[1],editor.select2[2])
                    if editor.selectedIDCache then editor.selectedID=editor.selectedIDCache editor.selectedIDCache=false end
                end
            end
            editor.select=false
            editor.select2=false
        end
        editor.eyedropperMode=false
        editor.playMode=false
    elseif editor.highlightedArea=="eraser" then
        editor:backspaceKey()
    elseif editor.highlightedArea=="trail" then
        editor:charIn("−")
    elseif editor.highlightedArea=="eyedropper" then
        editor:charIn("=")
    elseif editor.highlightedArea=="minimise" then
        editor:charIn("^")
    elseif editor.displayedGroup then -- a group is open
        if editor.highlightedArea=="group" then
            local ID=editor.displayedGroup[editor.highlightedTile[1]+2+(editor.highlightedTile[2]-1+(editor.displayedGroup["scroll"] and (editor.displayedGroup["scroll"]) or 0))*7]
            if ID~=nil then editor:selectID(ID) end
        elseif editor.highlightedArea==false then editor:selectID(false)
        end
    elseif editor.highlightedArea=="tilebar" then
        local groupID=table.remove(editor.tilebarTiles,editor.highlightedTile[1])
        if groupID~=nil then
            table.insert(editor.tilebarTiles,1,groupID)
            editor:setDisplayedGroup(editor.groupIndex[groupID])
        end
    elseif editor.highlightedArea=="pipes" then
        local group={"MANAGE WARPS", "texture"}
        for i=1,#level.current.pipeData do
            table.insert(group,"warp_"..i.."_edit")
        end table.insert(group,"newwarp")
        editor:setDisplayedGroup(group)
    elseif editor.highlightedArea=="play" then
        editor:enterKey()
    end
end
function editor:rightMouseDown()
    if editor.selectedID=="mario" then editor.selectedID=nil end
    if (editor.highlightedArea=="grid") and (not editor.platformSelect) and (string.sub(editor.selectedID,1,4)~="warp") then
        if editor.select==false then
            editor.select=pixel2grid(editor.mouseTile.x,editor.mouseTile.y-8,editor.selectionSize[1],editor.selectionSize[2])
        elseif editor.select2==false then
            editor.select2=pixel2grid(editor.mouseTile.x,editor.mouseTile.y-8,editor.selectionSize[1],editor.selectionSize[2])
        else editor:mouseDown()
        end
        editor.eyedropperMode=false
        editor.playMode=false
        editor.eraseMode=false
end end
function editor:backspaceKey()
    if editor.select==false and (string.sub(editor.selectedID,1,4)~="warp") then
        editor.eraseMode=not editor.eraseMode
        editor.eyedropperMode=false
        editor.playMode=false
    elseif editor.select2~=false and (editor.selectedID==nil or string.sub(editor.selectedID,1,5)~="theme" or string.sub(editor.selectedID,1,6)~="scroll") then
        editor:fillTiles(0,editor.select[1],editor.select[2],editor.select2[1],editor.select2[2])
        editor.select=false
        editor.select2=false
end end
function editor:enterKey()
    if editor.select==false and editor.playTimer==false and (string.sub(editor.selectedID,1,4)~="warp") then
        if editor.playMode==false then
            editor.playMode=true
            editor.eyedropperMode=false
            editor.eraseMode=false
        else
            editor.playMode=false
            editor.playTimer=5 --preserves the 'clacking' animation... to a degree
end end end
function editor:escapeKey()
    if editor.levelList then
        gui:clear() editor.levelList=false
    elseif string.sub(editor.selectedID,1,4)=="warp" then
        local config=editor.selectedID:split("_")
        local ID,action,option=config[2],tonumber(config[3]),config[4] --action (before) '2'=entr '4'=exit
        editor.selectedID=editor.selectedIDCache
        editor:selectID("warp_"..ID.."_"..(action-1))
    elseif editor.select then
        editor.select=false
        editor.select2=false
    elseif editor.platformSelect then
        level.current.set(editor.platformSelect[1],editor.platformSelect[2],0)
        editor.platformSelect=false
    elseif editor.eyedropperMode or editor.eraseMode or editor.playMode or editor.displayedGroup then
        editor.eyedropperMode=false
        editor.eraseMode=false
        editor.playMode=false
        editor:setDisplayedGroup(false)
    elseif not editor.PROMPT then
        editor:PAUSE()
end end

function editor:PAUSE() --true/false
    gui:clear()
    gui:createPrompt("PAUSED",nil,{{"RESUME","close"},{"QUIT","quit"}},false)
end

function editor:selectID(ID) --false means clicking outside of group (usually cancel)
    if ID and string.sub(ID,1,4)=="warp" then
        local config=ID:split("_")
        local pID,action,option=config[2],config[3],config[4]
        --'1'=select entrance type '2'=place entrance '3'=select exit type       '4'=place exit      '5'=set pipe ("new")     '6'=delete pipe
        --'7'=view entrance        '8'=view exit      '9'=disable enter entrance '10'=disable enter exit
        if action=="edit" then --display entrance type
            editor:setDisplayedGroup({"EDIT PIPE "..pID, "texture",
            nil, nil, nil, nil, nil, nil, nil,
            nil, "warp_"..pID.."_1", nil, nil, nil, "warp_"..pID.."_3", nil,
            nil, "warp_"..pID.."_7", nil, nil, nil, "warp_"..pID.."_8", nil,
            nil, nil, nil, "warp_"..pID.."_6", nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil})
        elseif action=="1" then --display select entrance type
            editor:setDisplayedGroup({"ENTRANCE TYPE", "texture",
            nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil,
            nil, nil,"warp_"..pID.."_2_1","warp_"..pID.."_2_2","warp_"..pID.."_2_3",nil, nil, 
            nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil})
        elseif action=="3" then --display select exit type
            editor:setDisplayedGroup({"EXIT TYPE", "texture",
            nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil,
            nil, nil,"warp_"..pID.."_4_1","warp_"..pID.."_4_2","warp_"..pID.."_4_3",nil, nil, 
            nil, nil, nil, "warp_"..pID.."_4_4", nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil})
        elseif action=="2" or action=="4" then --selected type and now placing
            editor.selectedIDCache=editor.selectedID
            editor.selectedID=ID
            editor:setDisplayedGroup(false)
        elseif action=="5" then --placed both exit and entrance for a new pipe
            table.insert(level.current.pipeData,{unpack(level.current.pipeData["n"])})
        elseif action=="6" then --delete pipe entirely
            gui:clear()
            gui:createPrompt("DELETE PIPE "..pID,{"REALLY DELETE?","THIS CANNOT","BE UNDONE!"},{{"CONFIRM","delwarp_"..pID},{"CANCEL","close"}},true,false)
        elseif action=="7" or action=="8" then --view pos of pipe
            pID=tonumber(pID)
            if     action=="7" then editor.cameraOffset=(level.current.pipeData[pID][1][1]*16)-159
            elseif action=="8" then editor.cameraOffset=(level.current.pipeData[pID][2][1]*16)-159 end
            editor:setDisplayedGroup(false)
        elseif action=="9" or action=="10" then --disable entering (TODO unimplemented in level string)
        end
    elseif ID=="newwarp" then editor:selectID("warp_n_1") --n=new (dont write to pipe until process finished)
    elseif ID then --no special actions
        editor.selectedID=ID
        editor:setDisplayedGroup(false)
    elseif not gui.highlightedButton then --close group
        editor:escapeKey()
    end
end

editor.pipeConfig={ --this is sort of randomly here. eh
    ["entrance"]={
        {-8,0,6,2}, --1: pipe facing left (text in top right)
        {1,-8,1,10}, --2: pipe facing up (text in bottom left)
        {0,0,2,2}, --3: pipe facing right (text in top left)
        {0,0,0,0} --4: unused as it is for teleport exit
    },
    ["exit"]={
        {-8,0,6,2}, --1: pipe facing left (text in top right)
        {1,-8,1,10}, --2: pipe facing up (text in bottom left)
        {0,0,2,2}, --3: pipe facing right (text in top left)
        {1,-1,6,10} --4: teleport (text in bottom right)
    }
}

function editor:drawPipe(gc,pipeID,posX,posY,TYPE,typeID) --for WARP pipes btw
    posX,posY=((posX-1)*16)-editor.cameraOffset,212-16*(posY)+8
    local x,y=posX+(editor.pipeConfig[TYPE][typeID][1]),posY+(editor.pipeConfig[TYPE][typeID][2])
    local tX,tY=posX+(editor.pipeConfig[TYPE][typeID][3]),posY+(editor.pipeConfig[TYPE][typeID][4])
    gc:drawImage(texs[TYPE.."_"..typeID],x,y)
    drawFont2(gc,addZeros(pipeID,2),tX,tY,nil,false,true)
    -- print(pipeID,x,y,TYPE,typeID)
end

function editor:drawScrollStop(gc,isRight,x)
    x=x+(isRight and 317 or 0)
    local THEME=plot2theme(math.ceil(x/16)+(isRight and 0 or 1),true)
    if THEME==0 then gc:setColorRGB(0,0,0) --daytime
    else gc:setColorRGB(255,255,255) --underground or nighttime or castle
    end gc:drawLine(x-editor.cameraOffset,0,x-editor.cameraOffset,212)
    if not isRight then gc:drawImage(texs.icon_scrollStopL,x-editor.cameraOffset+1,45) --left
    elseif isRight then gc:drawImage(texs.icon_scrollStopR,x-editor.cameraOffset-12,45) end --right
end

function editor:drawTerrain(gc) --rendered in rows from bottom to top w/ the rows from left to right
    local objectList={}
    for i2=math.ceil(editor.cameraOffset/16),math.ceil((screenWidth+editor.cameraOffset)/16) do --left to right, horizontally, only draw what is visible on screen
        local THEME=plot2theme(i2,true)
        for i=1,13 do --bottom to top, vertically (row 14 is reserved for hud/special events and is not drawn)
            local blockID=plot2ID(i2,i,true)
            if type(blockID)=='number' and blockID>=0 then --its a tile
                drawTile(gc, blockID, i2, i, "editor")
            else --its an object
                table.insert(objectList,{(i2-1)*16,212-16*(i),blockID}) --x,y,ID
    end end end
    for i=1,#objectList do
        drawTile(gc,objectList[i][3],nil,nil,"editor",nil,{objectList[i][1],objectList[i][2]})
    end
    for i=1,#level.current.pipeData do
        editor:drawPipe(gc,i,level.current.pipeData[i][1][1],level.current.pipeData[i][1][2],"entrance",level.current.pipeData[i][1][3])
        editor:drawPipe(gc,i,level.current.pipeData[i][2][1],level.current.pipeData[i][2][2],"exit",level.current.pipeData[i][2][3])
    end gc:setPen("thin","dashed") --for scroll stops
    for i=2,#level.current.scrollStopL do --skip out 0 (start)
        editor:drawScrollStop(gc,false,level.current.scrollStopL[i])
    end
    for i=1,(#level.current.scrollStopR-1) do --skip out last (end)
        editor:drawScrollStop(gc,true,level.current.scrollStopR[i])
    end
    gc:drawImage(texs.icon_start,level.current.startX-editor.cameraOffset+1,level.current.startY+7)
end

function editor:placeTile(ID,plotX,plotY)
    if ID~=nil then
        if string.sub(ID,1,11)=="platform_0~" then
            editor.platformSelect={plotX,plotY}
            level.current.set(plotX,plotY,"platform_1"..string.sub(ID,11,#ID))
        elseif string.sub(ID,1,5)=="theme" then --for themes
            level.current.t[plotX]=tonumber(string.sub(ID,6,#ID))
        elseif string.sub(ID,1,4)=="warp" then --for warps
            local config=editor.selectedID:split("_")
            local ID,action,option=config[2],tonumber(config[3]),config[4] --action (before) '2'=entr '4'=exit
            ID=ID:isInteger() and tonumber(ID) or ID
            if level.current.pipeData[ID]==nil then level.current.pipeData[ID]={} end --IMPORTANT: this should ONLY happen for when the ID is 'n' (new)!!!
            level.current.pipeData[ID][action/2]={plotX,plotY,tonumber(option)}
            if ID=="n" then editor:selectID("warp_n_"..(action+1)) end
        elseif string.sub(ID,1,6)=="scroll" then --for scroll stops
            if (plotX>1) and (plotX<level.current.END) then --avoid overwriting the default values.. i think
                local function removeInstances(tbl,val) local newTbl={}
                    for i=1,#tbl do if tbl[i]~=val then table.insert(newTbl,tbl[i]) end
                    end return newTbl
                end
                local valueL,valueR=(plotX-1)*16,(plotX*16)-318
                level.current.scrollStopL=removeInstances(level.current.scrollStopL,valueL)
                level.current.scrollStopR=removeInstances(level.current.scrollStopR,valueR)
                if ID=="scrollStopL"     then table.insert(level.current.scrollStopL,valueL)
                elseif ID=="scrollStopR" then table.insert(level.current.scrollStopR,valueR) end
                table.sort(level.current.scrollStopL) table.sort(level.current.scrollStopR)
            end
        elseif ID=="mario" then
            local starts=plot2pixel(plotX,plotY)
            level.current.startX=starts[1]+1 level.current.startY=starts[2]
            editor.selectedID=nil
        else
            level.current.set(plotX,plotY,ID)
        end
    end
end

function editor:fillTiles(ID, x1, y1, x2, y2)
    local differenceX = x2 - x1
    local differenceY = y2 - y1
    if differenceX < 0 then differenceX = -1 else differenceX = 1 end
    if differenceY < 0 then differenceY = -1 else differenceY = 1 end
    for i = x1, x2, differenceX do
        for i2 = y1, y2, differenceY do
            editor:placeTile(ID, i, i2)
end end end

function editor:determineSelectBox(x1,y1,w1,h1,x2,y2,w2,h2)
    local x local y local w local h
    if y1<=y2 then y=y1 else y=y2 end
    if x1<=x2 then x=x1 else x=x2 end
    if x1+w1<x2+w2 then w=(x2+w2)-x else w=(x1+w1)-x end
    if y1+h1<y2+h2 then h=(y2+h2)-y else h=(y1+h1)-y end
    return {x,y,w,h}
end

function editor:statusBox(gc,logic)
    drawGUIBox(gc,298,-2,20,21)
    drawTile(gc,editor.selectedID,nil,nil,"ICON",plot2theme(editor.highlightedTile[1],true),{301,1})
    if logic then
        editor.highlightedArea="status"
        local groupName="NOTHING SELECTED!"
        if editor.selectedID then
            groupName=objAPI:type2name(editor.selectedID,1)
        end
        gui.TEXT=groupName
    end
end

function editor:tilebar(gc,logic)
    drawGUIBox(gc,55,-2,208,21)
    drawGUIBox(gc,27,-2,21,21)
    gc:drawImage(texs.group_setpipe,30,1)
    for i=1,11 do
        gc:drawLine(57+(i*17),1-1,57+(i*17),16) --box dividers
    end
    for i=1,12 do
        if editor.tilebarTiles[i]~=nil then
            gc:drawImage(texs[editor.groupIndex[editor.tilebarTiles[i]][2]],245-(i-1)*17,1)
    end end
    timer2rainbow(gc,framesPassed+200,10)
    gc:setPen("thin","dashed")
    if logic=="pipes" then
        editor.highlightedArea="pipes"
        gui.TEXT="MANAGE WARPS"
        gc:drawRect(30,1,15,15)
    elseif logic then --perform tilebar logic
        local pos=pixel2snapgrid(editor.mouseTile.x+10,editor.mouseTile.y,17,17,true) --this all is a lot less elegant than the group selector, but i really dont care
        editor.highlightedArea="tilebar"
        editor.highlightedTile={math.floor((255-pos[1])/17)+1,1}
        gc:drawRect(262-(editor.highlightedTile[1]*17),1,15,15)
        local groupID=editor.tilebarTiles[editor.highlightedTile[1]] local groupName
        if groupID~=nil then
            groupName=editor.groupIndex[groupID][1]
        end
        if groupName then gui.TEXT=groupName end
    end
end

function editor:interface(gc)
    local eraserActive=true local eyedropperActive=true trailActive=true local playActive=true local tilebarActive=true local statusActive=true local minimOffset=0 local tilebarLogic local statusLogic
    local function insideCircle(pX,pY,cX,cY,cR)
        return ((pX-(cX+(cR/2)))^2 + (pY-(cY+(cR/2)))^2) < ((cR/2)^2)
    end
    if editor.minimised then playActive=false eyedropperActive=false eraserActive=false trailActive=false tilebarActive=false minimOffset=-12
    elseif editor.select~=false or string.sub(editor.selectedID,1,4)=="warp" then --which icons should be drawn/be able to be clicked
        eyedropperActive=false
        playActive=false
        tilebarActive=false
        if editor.select2==false or string.sub(editor.selectedID,1,4)=="warp" then
            eraserActive=false
            trailActive=false
            if not editor.platformSelect then
                statusActive=false
    end end end
    if editor.showTrail then
        for i=#mario.trail,1,-3 do --parse list backwards and skip three frames, so that they are a reasonable distance apart and overlap such that the most recent is on top
            gc:drawImage(texs[mario.trail[i][1]],mario.trail[i][2]-editor.cameraOffset,mario.trail[i][3])
    end end
    if eraserActive then gc:drawImage(texs.button_eraser,297,191) end --draw if active
    if trailActive then gc:drawImage(texs.button_trail,275,191) end --draw if active
    if eyedropperActive then gc:drawImage(texs.button_eyedropper,253,191) end --draw if active
    gc:drawImage(texs.button_minimiserope,-2,-10+minimOffset)
    timer2rainbow(gc,framesPassed+200,10)
    gc:setPen("thin","dashed") --V determine if mouse is hovering over any buttons
    if gui.PROMPT or editor.levelList or (editor.displayedGroup --[[and editor.displayedGroup["rows"] ]]) then
        editor.highlightedArea=false
        gui:detectPos(0,8)
    elseif insideCircle(mouse.x,mouse.y,296,190,22) and eraserActive then
        if editor.select2 then editor:drawGridCursor(gc) gc:setPen("thin","dashed") end --eraser
        gc:drawArc(297,191,20,20,0,360)
        editor.highlightedArea="eraser"
        gui.TEXT="ERASER: DEL"
    elseif insideCircle(mouse.x,mouse.y,274,190,22) and trailActive then
        gc:drawArc(275,191,20,20,0,360)
        editor.highlightedArea="trail"
        gui.TEXT="SHOW/HIDE TRAIL: (-)"
    elseif insideCircle(mouse.x,mouse.y,252,190,22) and eyedropperActive then --eyedropper
        gc:drawArc(253,191,20,20,0,360)
        editor.highlightedArea="eyedropper"
        gui.TEXT="EYEDROPPER: ="
    elseif checkCollision(mouse.x,mouse.y,1,1,4,178,40,30) and playActive then --play button
        editor.highlightedArea="play"
        gui.TEXT="PLAY LEVEL: ENTER"
    elseif checkCollision(mouse.x,mouse.y,1,1,4,0,16,20+(minimOffset*0.8)) then --minimise rope
        editor.highlightedArea="minimise"
        gui.TEXT="MINIMISE ROPE: ^"
    elseif checkCollision(mouse.x,mouse.y,1,1,298,0,18,18) and statusActive then --status box
        statusLogic=true
    elseif checkCollision(mouse.x,mouse.y,1,1,59,0,204,18) and tilebarActive then --tilebar
        tilebarLogic=true
    elseif checkCollision(mouse.x,mouse.y,1,1,31,0,17,18) and tilebarActive then --tilebar
        tilebarLogic="pipes"
    elseif mouse.y>12 then
        editor:drawGridCursor(gc)
        editor.highlightedArea="grid"
        if not editor.minimised and editor.enableShowCoords then
            local xy=pixel2plot(mouse.x,mouse.y-8,nil,true)
            local txt={"("..tostring(xy[1])..","..tostring(xy[2])..")"}
            if editor.enableSMBUtility then table.insert(txt,"["..tostring(xy[1]-1)..":"..tostring(13-xy[2]).."]") end
            gui.TEXT=txt gui.TEXToffset=(mouse.y>=170) and -50 or 0
        end
    else
        editor.highlightedArea=false
    end
    if editor.displayedGroup~=false and (not gui.PROMPT) then
        editor:handleGroup(gc,editor.displayedGroup)
    end
    gc:setColorRGB(255,0,0)
    gc:setPen("medium","smooth")
    if editor.showTrail and trailActive then
        gc:drawArc(274,190,22,22,0,360)
    end
    if editor.eraseMode and eraserActive then --draw circle over icon to show it is currently in use
        gc:drawArc(296,190,22,22,0,360)
    elseif editor.eyedropperMode and eyedropperActive then
        gc:drawArc(252,190,22,22,0,360)
    end -- V draw button prompts
    if playActive then
        if editor.playMode then gc:drawImage(texs.button_play2,1,168)
        else                    gc:drawImage(texs.button_play1,6,178)
        end                     gc:drawImage(texs.prompt_enter,28,203)
    end
    gc:drawImage(texs.prompt_power,16,20+minimOffset)
    if editor.notification then
        editor.notification[2]=editor.notification[2] and editor.notification[2]+1 or 1
        editor.notification[3]=editor.notification[3] and (editor.notification[3]+(editor.notification[2]<12 and 3 or editor.notification[2]>32 and -3 or 0)) or 0
        drawFont(gc,editor.notification[1],159,editor.notification[3],"centre",nil,"rgb")
        if editor.notification[2]==44 then editor.notification=nil end
    end
    if tilebarActive then editor:tilebar(gc,tilebarLogic) end
    if statusActive then editor:statusBox(gc,statusLogic) end
    if eraserActive then gc:drawImage(texs.prompt_del,306,203) end
    if trailActive then gc:drawImage(texs.prompt_dash,287,203) end
    if eyedropperActive then gc:drawImage(texs.prompt_equals,268,204) end
    if editor.levelList then
        gui:detectPos(0,8)
        gui:levelList(gc,{0,0,0,0},"levelListLocal",editor.levellist)
end end

function editor:handleGroup(gc,data)
    drawGUIBox(gc,97,57,123,97,data[1])
    local scroll=0
    if editor.displayedGroup["scroll"] then
        scroll=editor.displayedGroup["scroll"]
        local x,y,h=-40,18,-55 --these values now specify position/height offset from original (in level list)
        drawGUIBox(gc,x+263,y+39,15,152+h)
        gc:drawImage(texs.levelList_scrollPiece,x+267,y+58+((editor.displayedGroup["scroll"])*((106+h)/(editor.displayedGroup["rows"]-5)))) -- 91 slots, 106 px (to scroll)
        gc:setColorRGB(108,108,108)     gc:drawRect(x+265,y+54,11,2)            gc:drawRect(x+265,y+174+h,11,2) --grey
        gc:setColorRGB(255,255,255)     gc:drawLine(x+264,y+55,x+265+12,y+55)   gc:drawLine(x+264,y+175+h,x+265+12,y+175+h) --white lines (divide)
    end
    for i=0,4 do
        for i2=1,7 do
            local ID=data[((i+scroll)*7)+i2+2]
            if ID then drawTile(gc,ID,nil,nil,"ICON",false,{100+((i2-1)*17), 68+(i*17),99}) end
    end end
    gc:setColorRGB(108,108,108) --light grey inner box border
    for i=1,6 do --vertical dividers
        gc:drawLine(99+(i*17),68-1,99+(i*17),151+1)
    end
    for i=1,4 do --horizontal
        gc:drawLine(100-1,67+(i*17),217+1,67+(i*17))
    end timer2rainbow(gc,framesPassed+200,10)
    gc:setPen("thin","dashed")
    local pos=pixel2snapgrid(editor.mouseTile.x+2,editor.mouseTile.y-9,17,17,true)
    local IDdesc=""
    if (pos[1]>=102 and pos[1]<=204) and (pos[2]>=59 and pos[2]<=127) then
        editor.highlightedTile={((pos[1]-85)/17),((pos[2]-42)/17)}
        editor.highlightedArea="group"
        local ID=data[editor.highlightedTile[1]+2+(editor.highlightedTile[2]-1+scroll)*7]
        if ID~=nil then IDdesc=objAPI:type2name(ID,0) end
    else
        editor.highlightedArea=false
    end
    gc:drawRect((editor.highlightedTile[1]*17)+83,(editor.highlightedTile[2]*17)+51,15,15)
    gui.TEXT=IDdesc
end

function editor:drawGridCursor(gc)
    local pos=pixel2snapgrid(editor.mouseTile.x,editor.mouseTile.y-8,editor.selectionSize[1],editor.selectionSize[2])
    local box
    if editor.select==false then
        gc:setPen("thin","dotted")
        box={pos[1],pos[2],editor.selectionSize[1]-1,editor.selectionSize[2]-1}
    else
        local posSelect=grid2pixel(editor.select[1],editor.select[2],editor.selectionSize[1],editor.selectionSize[2],true)
        local posSelect2
        if editor.select2==false then
            gc:setPen("thin","dashed")
            posSelect2={pos[1],pos[2]}
        else
            gc:setPen("thin","smooth")
            posSelect2=grid2pixel(editor.select2[1],editor.select2[2],editor.selectionSize[1],editor.selectionSize[2],true)
        end
        box=editor:determineSelectBox(posSelect[1],posSelect[2],editor.selectionSize[1]-1,editor.selectionSize[2]-1,posSelect2[1],posSelect2[2],editor.selectionSize[1]-1,editor.selectionSize[2]-1)
    end
    if (box[2]+box[4])>203 then box[4]=203-box[2] end

    if string.sub(editor.selectedID,1,4)=="warp" then
        gc:setPen("thin","dashed")
        local config=editor.selectedID:split("_")
        local ID,action,option=config[2],config[3],config[4]
        if action=="2" or action=="4" then --place entrance/exit
            if option=="1" then --left
                gc:drawRect(box[1],box[2]-8,14,31) --PIPE FACING LEFT
                gc:drawLine(box[1]+15,box[2]-7,box[1]+15+17,box[2]-7)
                gc:drawLine(box[1]+15,box[2]+22,box[1]+15+17,box[2]+22)
            elseif option=="2" then --up
                gc:drawRect(box[1],box[2]+8,31,14) --PIPE FACING UP 
                gc:drawLine(box[1]+2,box[2]+23,box[1]+2,box[2]+23+17)
                gc:drawLine(box[1]+30,box[2]+23,box[1]+30,box[2]+23+17)
            elseif option=="3" then --right
                gc:drawRect(box[1]+1,box[2]-8,14,31) --PIPE FACING RIGHT
                gc:drawLine(box[1]+15-31,box[2]-7,box[1]+15+17-31,box[2]-7)
                gc:drawLine(box[1]+15-31,box[2]+22,box[1]+15+17-31,box[2]+22)
            elseif option=="4" then --teleport
                gc:drawRect(box[1],box[2]+8,box[3],box[4])
        end end
    else gc:drawRect(box[1],box[2]+8,box[3],box[4])
    end
    gc:setPen("thin","smooth")
    editor.highlightedTile=pixel2grid(editor.mouseTile.x,editor.mouseTile.y-8,editor.selectionSize[1],editor.selectionSize[2])
end

function editor:logic()
    cursor.show()
    if editor.eraseMode or editor.eyedropperMode or editor.playMode then
        editor.selectionSize={16,16}
    elseif editor.selectedID~=nil and (string.sub(editor.selectedID,1,5)=="theme" or string.sub(editor.selectedID,1,6)=="scroll") then
        editor.selectionSize={16,208}
    else
        editor.selectionSize={16,16}
    end
    if mouse.y<12 then editor.mouseTile.y=12 else editor.mouseTile.y=mouse.y end
    editor.mouseTile.x=mouse.x
    if editor.highlightedArea=="grid" then
        if editor.select~=false then --selection in progress
            if editor.select2~=false then --selection is finalised
                local posSelect=grid2pixel(editor.select[1],editor.select[2],editor.selectionSize[1],editor.selectionSize[2],true)
                local posSelect2=grid2pixel(editor.select2[1],editor.select2[2],editor.selectionSize[1],editor.selectionSize[2],true)
                local box=editor:determineSelectBox(posSelect[1],posSelect[2],editor.selectionSize[1]-1,editor.selectionSize[2]-1,posSelect2[1],posSelect2[2],editor.selectionSize[1]-1,editor.selectionSize[2]-1)
                if checkCollision(box[1],box[2]+8,box[3],box[4],editor.mouseTile.x,editor.mouseTile.y,1,1) then 
                    if editor.eraseMode==true then cursor.set("clear")
                    else cursor.set("pencil") end
                else cursor.set("unavailable")
                end
            else --selection is being made
                cursor.set("hand closed")
                if editor.mouseTile.x<=8 then
                    editor.cameraOffset=editor.cameraOffset-7
                elseif editor.mouseTile.x>=310 then
                    editor.cameraOffset=editor.cameraOffset+7
                end
            end
        elseif editor.platformSelect then cursor.set("animate")
            local x=editor.platformSelect[1] local y=editor.platformSelect[2]
            if editor.platformSelect[3]~=true then
                local length=editor.highlightedTile[1]-x+1
                if length>0 then
                    level.current.set(x,y,"platform_"..tostring(length)..string.sub(editor.selectedID,11,#editor.selectedID))
                end
            else
                local ID=level.current.get(x,y)
                local config=(string.sub(ID,10,#ID)):split("~")
                local distance
                if config[3]=="lx" then
                    distance=tostring(editor.highlightedTile[1]-x)*16
                else
                    distance=tostring(editor.highlightedTile[2]-y)*16
                end
                level.current.set(x,y,"platform_"..config[1].."~"..config[2].."~"..config[3].."~"..distance)
            end
        elseif editor.eraseMode==true then cursor.set("clear")
        elseif editor.eyedropperMode==true then cursor.set("crosshair")
        elseif editor.playMode==true then cursor.set("dotted arrow")
        else cursor.set("default")
        end
    elseif editor.highlightedArea=="group" or editor.highlightedArea=="tilebar" or editor.highlightedArea=="pipes" or editor.highlightedArea=="play" or editor.highlightedArea=="eraser" or editor.highlightedArea=="trail" or editor.highlightedArea=="eyedropper" or editor.highlightedArea=="minimise" then
        cursor.set("hand pointer")
    elseif editor.highlightedArea=="status" then
        cursor.set("show")
    else cursor.set("default")
    end
    if editor.playTimer~=false then
        editor.playTimer=editor.playTimer-1
        editor.playMode=false
        if editor.playTimer<=0 then
            editor:charIn("play")
        end
    end
    if editor.cameraOffset<0 then editor.cameraOffset=0 end
    if editor.cameraOffset>((level.current.END-20)*16) then editor.cameraOffset=((level.current.END-20)*16)+2 end
    if editor.enableAutoSave then
        if not editor.lastAutoSave then editor.lastAutoSave = 0 end
        if (framesPassed - editor.lastAutoSave) > 1000 then
            editor.lastAutoSave = framesPassed
            if editor.file then gui:click("ll_save_"..editor.file.."_levelListLocal")
            else editor.notification={"CANNOT AUTO-SAVE, SLOT NOT SET!"}
            end
        elseif (framesPassed - editor.lastAutoSave) == 800 then
            editor.notification={"AUTO-SAVING SOON!"}
        end
    end
end

function editor:generate(LEVELSTRING)
    print("Generating level from string...")
    gui:clear()
    level.perm=LEVELSTRING
    editor.LOAD=0 editor.file=false
    editor.cameraOffset=0 editor.notification=false
    editor.select=false
    editor.select2=false
    editor.platformSelect=false
    editor.eraseMode=false
    editor.eyedropperMode=false
    editor.playMode=false
    editor.minimised=false
    editor.mouseTile={}
    editor.mouseTile.x=0
    editor.mouseTile.y=0
    editor.highlightedArea=false
    editor.playTimer=false
    editor.enableAutoSave=var.recall("enableAutoSave") == "true"
    editor:setDisplayedGroup(false)
end

function toolpaletteSelection(group,option) --has to be a global function, because toolpalette reasons...
    if group=="Editor Settings" then
        if string.sub(option,-9)=="Auto-Save" then
            editor.enableAutoSave=not editor.enableAutoSave var.store("enableAutoSave",editor.enableAutoSave and "true" or "false")
        elseif string.sub(option,-17)=="Show Co-ordinates" then
            editor.enableShowCoords=not editor.enableShowCoords
        elseif string.sub(option,-19)=="SMB Utility Co-ords" then
            editor.enableSMBUtility=not editor.enableSMBUtility
        end
    elseif group=="Modifiers" then
        local modifier={"disableBackScrolling","allowBidirectionalSpawning","enableGlobalEntities","enableShellBouncing","enableCoinOnKill","enablePowerUpBouncing","showCeilingBlock"} --possible modifiers, values that are nil when disabled and true when enabled
        for i=1,#modifier do
            if string.sub(option,#option-#modifier[i]+1,#option)==modifier[i] then
                modifier=string.sub(option,#option-#modifier[i]+1,#option)
                break
        end end
        if type(modifier)~="table" then --one has been located
            if level.current[modifier]==nil then level.current[modifier]=true
            else level.current[modifier]=nil
        end end
    elseif group=="Autoscroll" then
        if string.sub(option,12,12)~="" then
            level.current.autoScroll=string.sub(option,12,12)
        else level.current.autoScroll=nil
        end
    elseif group=="▶Automove" then
        if string.sub(option,-13)=="Walking Speed" then
            level.current.autoMove="w"
        elseif string.sub(option,-13)=="Running Speed" then
            level.current.autoMove="r"
        else level.current.autoMove=nil
        end
    elseif group=="⇥Length" then
        if string.sub(option,1,14)=="Current Length" then
            gui:createPrompt("SET LEVEL LENGTH",{"TYPE THE VALUE TO SET","THE LEVEL LENGTH TO!","(CURRENT: "..tostring(level.current.END)..")"},4,"length",false)
        else
            level.current.END=level.current.END+tonumber(option)
            if level.current.END<=20 then level.current.END=20 end
            level.current=copyLevel(level.current)
        end
    elseif group=="Time" then
        if string.sub(option,1,18)=="Current Time Limit" then
            gui:createPrompt("SET TIME LIMIT",{"TYPE THE VALUE TO SET","THE TIME LIMIT TO!","(CURRENT: "..tostring(level.current.TIME)..")"},3,"time",false)
        else
            level.current.TIME=level.current.TIME+tonumber(option)
            if level.current.TIME<=5 then level.current.TIME=5
            elseif level.current.TIME>=999 then level.current.TIME=999
        end end
    elseif group=="File" then
        if string.sub(option,1,4)=="Name" then
            gui:createPrompt("ENTER COURSE NAME",{"TYPE BELOW TO SET A","NEW COURSE NAME TO BE","ASSOCIATED WITH YOUR","LEVEL AND PRESS ENTER.","ACCEPTED CHARACTERS:","A-Z 0-9 !?/-'().,"},19,"coursename",false) 
        elseif option=="New" then
            gui:createPrompt("CLEAR LEVEL",{"REALLY CLEAR?","UNSAVED LEVEL DATA WILL", "BE DELETED!"},{{"CONFIRM","create"},{"CANCEL","close"}},true,false)
        elseif option:startsWith("Open") then gui:click("editor_open")
        elseif option:startsWith("Save As") then gui:click("editor_saveas")
        elseif option:startsWith("Save") then gui:click("editor_save")
        elseif option:startsWith("Close File") then gui:click("editor_close")
        elseif option:startsWith("Copy to Clipboard") then
            clipboard.addText(level2string(level.current))
            gui:createPrompt("DONE!",{"LEVEL COPIED","TO CLIPBOARD!"},{{"OK","close"}},nil,nil,false)
        elseif option:startsWith("Load from Clipboard") then
            local PASTE=clipboard.getText() or "err"
            if string.sub(PASTE,1,1)=="<" then --very crude for now
                editor:generate(PASTE)
                gui:createPrompt("DONE!",{"LEVEL IMPORTED","FROM CLIPBOARD!"},{{"OK","close"}},nil,nil,false)
            else
                gui:createPrompt("ERROR!",{"LEVEL IMPORTING","FAILED! CHECK TO","SEE IF THE LEVEL","CODE IS VALID."},{{"OK","close"}})
            end
        end
    elseif group=="Game Speed" then
        local speeds={
            ["0.25x"]={1,0,0,0},
            ["0.5x"]={1,0},
            ["0.75x"]={1,1,1,0},
            ["1x"]={1},
            ["1.25x"]={2,1,1,1},
            ["1.5x"]={2,2,1,1},
            ["1.75x"]={2,2,2,1},
            ["2x"]={2,2,2,2}
        } gameSpeed=speeds[option]
    end
    if editor.active then editor:updateToolpalette() end
end

function editor:updateToolpalette(init)
    local eAS="[   ]" if editor.enableAutoSave==true                 then eAS="[✓]" end
    local eSC="[   ]" if editor.enableShowCoords==true               then eSC="[✓]" end
    local sUC="[   ]" if editor.enableSMBUtility==true               then sUC="[✓]" end

    local dBS="[   ]" if level.current.disableBackScrolling==true        then dBS="[✓]" end
    local aBS="[   ]" if level.current.allowBidirectionalSpawning==true  then aBS="[✓]" end
    local eGE="[   ]" if level.current.enableGlobalEntities==true        then eGE="[✓]" end
    local eSB="[   ]" if level.current.enableShellBouncing==true         then eSB="[✓]" end
    local eCK="[   ]" if level.current.enableCoinOnKill==true            then eCK="[✓]" end
    local ePB="[   ]" if level.current.enablePowerUpBouncing==true       then ePB="[✓]" end
    local sCB="[   ]" if level.current.showCeilingBlock==true            then sCB="[✓]" end

    local aSc={"[   ]","[   ]","[   ]","[   ]","[   ]","[   ]"} -- aSc: autoScroll
    if      level.current.autoScroll==nil   then aSc[1]="[✓]"
    elseif  level.current.autoScroll=="1"   then aSc[2]="[✓]"
    elseif  level.current.autoScroll=="2"   then aSc[3]="[✓]"
    elseif  level.current.autoScroll=="3"   then aSc[4]="[✓]"
    elseif  level.current.autoScroll=="4"   then aSc[5]="[✓]"
    elseif  level.current.autoScroll=="5"   then aSc[6]="[✓]"
    end

    local aMv={"[   ]","[   ]","[   ]"} -- aMv: autoMove
    if      level.current.autoMove==nil then aMv[1]="[✓]"
    elseif  level.current.autoMove=="w" then aMv[2]="[✓]"
    elseif  level.current.autoMove=="r" then aMv[3]="[✓]"
    end

    local menu = {
        {"File",
            {"Name: "..string.upper(level.current.courseName).." (N)", toolpaletteSelection},
            "-",
            {"New", toolpaletteSelection},
            {"Open (O)", toolpaletteSelection},
            {"Save (S)", toolpaletteSelection},
            {"Save As", toolpaletteSelection},
            {"Close File", toolpaletteSelection},
            "-",
            {"Copy to Clipboard (C)", toolpaletteSelection},
            {"Load from Clipboard", toolpaletteSelection},
            "-",
            {(editor.file and "File: Slot "..editor.file or "No File Open!"), toolpaletteSelection},
        },
        {"Editor Settings",
            {eAS.."Auto-Save", toolpaletteSelection},
            {eSC.."Show Co-ordinates", toolpaletteSelection},
            {sUC.."SMB Utility Co-ords", toolpaletteSelection},
            -- "-", -- Section divider
        },
        {"Modifiers",
            {dBS.."disableBackScrolling", toolpaletteSelection},
            {aBS.."allowBidirectionalSpawning", toolpaletteSelection},
            {eGE.."enableGlobalEntities", toolpaletteSelection},
            {eSB.."enableShellBouncing", toolpaletteSelection},
            {eCK.."enableCoinOnKill", toolpaletteSelection},
            {ePB.."enablePowerUpBouncing", toolpaletteSelection},
            {sCB.."showCeilingBlock", toolpaletteSelection},
            -- "-", -- Section divider
        },
        {"Autoscroll",
            {aSc[1].."OFF", toolpaletteSelection},
            {aSc[2].."Speed 1: Slow", toolpaletteSelection},
            {aSc[3].."Speed 2: Koopa", toolpaletteSelection},
            {aSc[4].."Speed 3: Bullet Bill", toolpaletteSelection},
            {aSc[5].."Speed 4: Shell", toolpaletteSelection},
            {aSc[6].."Speed 5: Sprint", toolpaletteSelection},
        },
        {"▶Automove",
            {aMv[1].."OFF", toolpaletteSelection},
            {aMv[2].."Walking Speed", toolpaletteSelection},
            {aMv[3].."Running Speed", toolpaletteSelection},
        },
        {"⇥Length",
            {"Current Length: "..level.current.END.." (L)", toolpaletteSelection},
            "-",
            {"+5", toolpaletteSelection},
            {"+10", toolpaletteSelection},
            {"+50", toolpaletteSelection},
            {"+100", toolpaletteSelection},
            {"+200", toolpaletteSelection},
            "-",
            {"-5", toolpaletteSelection},
            {"-10", toolpaletteSelection},
            {"-50", toolpaletteSelection},
            {"-100", toolpaletteSelection},
            {"-200", toolpaletteSelection},
        },
        {"Time",
            {"Current Time Limit: "..level.current.TIME.." (T)", toolpaletteSelection},
            "-",
            {"+5", toolpaletteSelection},
            {"+10", toolpaletteSelection},
            {"+50", toolpaletteSelection},
            {"+100", toolpaletteSelection},
            {"+200", toolpaletteSelection},
            "-",
            {"-5", toolpaletteSelection},
            {"-10", toolpaletteSelection},
            {"-50", toolpaletteSelection},
            {"-100", toolpaletteSelection},
            {"-200", toolpaletteSelection},
        }
    } 
    toolpalette.register(menu)
    if init~=true then
        if not editor.enableShowCoords then
            toolpalette.enable("Editor Settings",(editor.enableSMBUtility and "[✓]" or "[   ]").."SMB Utility Co-ords",false)
        end
        if level.current.TIME<=10 then
            toolpalette.enable("Time","-5",false)
            toolpalette.enable("Time","-10",false)
            toolpalette.enable("Time","-50",false)
            toolpalette.enable("Time","-100",false)
            toolpalette.enable("Time","-200",false)
        elseif level.current.TIME>=999 then
            toolpalette.enable("Time","+5",false)
            toolpalette.enable("Time","+10",false)
            toolpalette.enable("Time","+50",false)
            toolpalette.enable("Time","+100",false)
            toolpalette.enable("Time","+200",false)
        end
        if level.current.END<=20 then
            toolpalette.enable("⇥Length","-5",false)
            toolpalette.enable("⇥Length","-10",false)
            toolpalette.enable("⇥Length","-50",false)
            toolpalette.enable("⇥Length","-100",false)
            toolpalette.enable("⇥Length","-200",false)
        end
        if not editor.file then toolpalette.enable("File","Close File",false) end
        toolpalette.enable("File",(editor.file and "File: Slot "..editor.file or "No File Open!"),false)
    end
end

function editor:paint(gc) --permanent logic loop
    if not playStage.active then
        if editor.LOAD>1 then
            if not gui.PROMPT and not editor.levelList then editor:logic() end
            editor:drawBackground(gc)
            editor:drawTerrain(gc)
            editor:interface(gc)
        else --loading screen
            gc:setColorRGB(0,0,0)
            gc:fillRect(0,0,screenWidth,screenHeight)
            if editor.LOAD==1 then
                level.current=string2level(level.perm)
            end
            drawFont(gc,"LOADING LEVEL FOR EDITING...",nil,nil,"centre",0)
            editor.LOAD=editor.LOAD+1
        end
        __PC.allowedHeldKeys = {}
    end
end