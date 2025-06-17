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

function plot2ID(searchX,searchY,EDITOR) --returns ID when given *CO-ORDINATES*
    local ID=level.current.get(searchX,searchY)
    if not EDITOR then
        if ID and blockIndex[ID] and blockIndex[ID].eventswitch and blockIndex[ID].eventswitch[1]~=false then
            if playStage.events[blockIndex[ID].eventswitch[1]] == blockIndex[ID].eventswitch[2] then
                ID=blockIndex[ID].eventswitch[3]
            end
        end
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
    local POS=pixel2plot(x,y,Global)
    plot2place(ID,POS[1],POS[2])
end

function plot2place(ID,x,y)
    level.current.set(x,y,ID)
end

function plot2theme(x,EDITOR)
    return level.current.t[x]
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