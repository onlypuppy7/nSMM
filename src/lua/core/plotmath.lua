function plot2key(x, y)
    local height = 14 * 3 --i doubt this will ever be variable but just in case, i guess

    -- if titleScreen.active then --technically this would be a better way to go about this
    --     -- y = y + height
    --     height = height * 4
    -- end

    return ((x - 1) * height) + y
end

function key2plot(key)
    local height = 14 * 3 --i doubt this will ever be variable but just in case, i guess

    local x = math.floor((key - 1) / height) + 1
    local y = ((key - 1) % height) + 1
    return {x, y}
end

function ID2eventID(ID)
    local eventswitch=blockIndex[ID] and blockIndex[ID].eventswitch
    if ID and blockIndex[ID] and eventswitch and eventswitch[1]~=false then
        if playStage:evaluateEventCondition(eventswitch) then
            ID=eventswitch[3]
        end
    end

    return ID
end

function plot2ID(searchX,searchY,EDITOR) --returns ID when given *CO-ORDINATES*
    local ID=level.current.get(searchX,searchY)
    if not EDITOR then
        ID=ID2eventID(ID)
    end return ID or -1 --ID doesnt exist (likely out of bounds)
end

function pixel2plot(x,y,Global,EDITOR) --returns co-ordinate of block from a screen pixel position
    local plotX
    if Global==true then --doesnt take camera offset into account if true
        plotX=math.ceil((x)/16)
    else -- relative to the camera (DEFAULT)
        if EDITOR~=true then
            plotX=math.ceil((x+playStage.cameraOffset)/16)
        else
            plotX=math.ceil((x+editor.cameraOffset)/16)
        end
    end
    return {plotX,math.ceil((212-y)/16)}
end

function plot2pixel(plotX,plotY,Global) --
    local plotX,x=plotX-1
    if Global==true then
        local offset = editor.active and editor.cameraOffset or playStage.cameraOffset or 0
        x=plotX*16-offset
    else x=(plotX*16)
    end return {x,212-(plotY*16)}
end

function pixel2ID(x,y,Global,EDITOR) --function to remove redundant args, returns ID of pixel on screen
    local plots=pixel2plot(x,y,Global,EDITOR)
    local ID=plot2ID(plots[1],plots[2],EDITOR)
    if type(ID)=='number' then --for random generation (deprecated)
        if ID<0 then ID=0 end
    end return ID
end

function pixel2block(x,y,Global,EDITOR) --returns block table from pixel position
    local ID=pixel2ID(x,y,Global,EDITOR)
    if type(ID)=='number' then
        if ID<0 then ID=0 end
        return blockIndex[ID]
    end return nil --ID doesnt exist (likely out of bounds)
end

function block2anything(checkFor,block) 
    if not block then return nil end --if block doesnt exist, return nil
    return block[checkFor] --if checkFor exists, return it
end

function pixel2anything(checkFor,x,y,Global)
    local block=pixel2block(x,y,Global)
    return block2anything(checkFor,block)
end

function pixel2solid(x,y,Global) --semi useless function to remove redundant args, returns state of solid
    if (y<4) and pixel2anything("ceiling",x,12,Global) then return true end --screen top block if ground/hard block is there
    return pixel2anything("solid",x,y,Global)
end

function pixel2bumpable(x,y,Global) --semi useless function to remove redundant args, returns state of bumpable
    return pixel2anything("bumpable",x,y,Global)[1]
end

function pixel2semisolid(NESW,x,y,Global)
    local result=pixel2anything("semisolid",x,y,Global)
    if not result then return false else return string.sub(result,NESW,NESW)=="1" end
end

function pixel2place(ID,x,y,Global)
    local plot=pixel2plot(x,y,Global)
    plot2place(ID,plot[1],plot[2])
end

function plot2place(ID,plotX,plotY)
    level.current.set(plotX,plotY,ID)
end

function plot2theme(plotX,EDITOR)
    return level.current.t[plotX]
end

function pixel2theme(x,Global)
    return level.current.t[pixel2plot(x,150,Global)[1]]
end

function pixel2grid(x,y,w,h,Global) --editor only(?)
    local plotX
    if Global==true then --doesnt take camera offset into account if true
        plotX=math.ceil((x)/w)
    else -- relative to the camera (DEFAULT)
        local offset = editor.active and editor.cameraOffset or playStage.cameraOffset or 0
        plotX=math.ceil((x+offset)/w)
    end
    local plotY=math.ceil((212-y)/h)
    return {plotX,plotY}
end

function grid2pixel(plotX,plotY,w,h,Global) --editor only(?)
    local plotX,x=plotX-1
    if Global==true then
        local offset = editor.active and editor.cameraOffset or playStage.cameraOffset or 0
        x=plotX*w-offset
    else x=(plotX*w)
    end return {x,212-(plotY*h)}
end

function pixel2snapgrid(x,y,w,h,SELECTOR) --editor only(?)
    local v=pixel2grid(x,y,w,h,SELECTOR)
    if SELECTOR==nil then SELECTOR=false end
    v=grid2pixel(v[1],v[2],w,h,not SELECTOR)
    return {v[1],v[2]}
end

function ID2block(ID)
    if blockIndex[ID] then
        return blockIndex[ID]
    else
        return nil
    end
end

function drawTile(gc, blockID, plotX, plotY, mode, THEME, position)
    local EDITOR=mode=="editor" or mode=="ICON"
    local ICON=mode=="ICON"

    if type(blockID)=="number" then
        THEME=THEME==nil and plot2theme(plotX) or THEME

        if blockID<0 then blockID=0 end
        local block=ID2block(blockID)
        local blockToDraw=block

        if EDITOR and block.editor then
            blockToDraw=ID2block(block.editor)
        end

        local animSpeed=blockToDraw["animSpeed"] or 4 --default animation speed
        local texture=blockToDraw.theme[THEME]~=nil and blockToDraw.theme[THEME] or blockToDraw.texture

        local textureData
        local oX,oY=0,(mode=="titleScreen" and -8) or 0

        if type(texture)=="string" then
            textureData=texs[texture]
        else
            local framesPassed_=(mode=="playStage" and playStage.framesPassedBlock) or (mode=="titleScreen" and titleScreen.framesPassedBlock) or 0
            local frameForAnim=(EDITOR and 1) or (math.floor((framesPassed_/animSpeed)%#texture))+1 --(support for animations)

            local frameData=texture[frameForAnim]

            if type(frameData)=="table" then
                oX=oX+(frameData[2] or 0)
                oY=oY+(frameData[3] or 0)
                frameData=frameData[1]
            end

            textureData=texs[frameData]
        end

        if not textureData then return end

        local offsetX=(mode=="playStage" and playStage.cameraOffset) or (EDITOR and editor.cameraOffset) or (titleScreen.cameraOffsetX)
        local offsetY=(mode=="titleScreen" and titleScreen.cameraOffsetY) or 0

        local xPos
        local yPos

        if position then
            xPos=position[1]+oX
            yPos=position[2]+oY
        else
            xPos=((plotX-1)*16)-offsetX+oX
            yPos=212-16*(plotY)+8+offsetY+oY
        end

        gc:drawImage(textureData, xPos, yPos)

        if plotY==13 and block.ceiling and mode~="titleScreen" then
            if level.current.showCeilingBlock then
                gc:drawImage(textureData, xPos, yPos-16)
            elseif EDITOR then
                gc:drawImage(texs.Barrier, xPos, yPos-16)
            end
        end

        if EDITOR then
            local iconToDraw

            local icon=block.icon
            local iconX=xPos
            local iconY=yPos

            if icon then
                if type(icon)=="table" then
                    iconToDraw=icon[1]
                    iconX=icon[2] and iconX+icon[2] or iconX
                    iconY=icon[3] and iconY+icon[3] or iconY
                elseif type(icon)=="string" then
                    iconToDraw=icon
                end
            end

            if iconToDraw then
                gc:drawImage(texs[iconToDraw],iconX,iconY) --texs.icon_star
            end
        end
    elseif EDITOR then
        local TYPE=objAPI:type2class(blockID)

        -- print(gc, blockID, plotX, plotY, mode, THEME, position)

        local x,y=position[1],position[2]

        if TYPE~=false then
            if ICON then y=y-8 x=x+editor.cameraOffset end
            obj=entityClasses[TYPE]
            if ICON then gc:clipRect("set",x-editor.cameraOffset,y+8,16,16) end
            obj:draw(gc,x-editor.cameraOffset,y+8,blockID,true,ICON) --(gc,x,y,TYPE,isEditor,isIcon)
            gc:clipRect("reset")
        elseif blockID=="mario" then
            gc:drawImage(texs.icon_start,x+1,y-1)
        elseif blockID=="scrollStopL" then
            gc:drawImage(texs.icon_scrollStopL,x+2,y+2)
        elseif blockID=="scrollStopR" then
            gc:drawImage(texs.icon_scrollStopR,x+2,y+2)
        elseif blockID=="viewpipe" then
        elseif blockID=="scrollStopC" then
            gc:drawImage(texs.icon_scrollStopC,x+2,y+3)
        elseif string.sub(blockID,1,4)=="warp" then
            local config=blockID:split("_")
            local ID,action,option=config[2],config[3],config[4]
            if action=="edit" or action=="6" then
                gc:drawImage(texs.group_pipe,x,y)
                if action=="edit" then drawFont2(gc,addZeros(ID,2),x+5,y+10,nil,false,true)
                elseif action=="6" then gc:drawImage(texs.levelList_delete,x+4,y+4) end --bin icon
            elseif action=="1" or action=="3" or action=="7" or action=="8" then
                if     action=="1" or action=="7" then gc:drawImage(image.copy(texs.entrance_2,12,17),x,y-1) --pipe entrance icon
                elseif action=="3" or action=="8" then gc:drawImage(image.copy(texs.exit_2,12,17),x,y-1) end --pipe exit icon
                if action=="1" or action=="3" then  --change type icon(??)
                elseif action=="7" or action=="8" then gc:drawImage(texs.viewpipe,x+6,y+10) end --view pipe icon
            elseif action=="4" and option=="4" then
                gc:drawImage(texs.icon_start,x+1,y-1)
            elseif action=="2" or action=="4" then
                gc:drawImage(texs["warp_"..option],x,y)
            end
        else --this is for themes (derp, exploited by ElNoob0)
            gc:drawImage(texs[blockID],x,y)
        end
    end



    --     if i==13 and blockIndex[blockID]["ceiling"] and level.current.showCeilingBlock then
    --         gc:drawImage(texs[blockIndex[blockID]["theme"][THEME][frameForAnim]], ((i2-1)*16)-playStage.cameraOffset, 212-16*(i+1)+8)
    --     end --draw a block above the blocks to denote that mario cannot jump over it
    -- elseif blockIndex[blockID]["texture"][1]~=nil then --it has an animation
    --     local animSpeed=blockIndex[blockID]["animSpeed"] or 4 --default animation speed
    --     local frameForAnim=(math.floor((playStage.framesPassedBlock/animSpeed)%#blockIndex[blockID]["texture"]))+1 --(support for animations)
    --     gc:drawImage(texs[blockIndex[blockID]["texture"][frameForAnim]], ((i2-1)*16)-playStage.cameraOffset, 212-16*(i)+8)
    --     if i==13 and blockIndex[blockID]["ceiling"] and level.current.showCeilingBlock then
    --         gc:drawImage(texs[blockIndex[blockID]["texture"][frameForAnim]], ((i2-1)*16)-playStage.cameraOffset, 212-16*(i+1)+8)
    --     end --draw a block above the blocks to denote that mario cannot jump over it
    -- end --^^^ CAUTION so far no animated blocks are ceiling ones.. if they are then this will cease to work!
end