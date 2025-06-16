versText="0.0.1"

--ui
cursor=image.new(_R.IMG.cursor2)
block1=image.new(_R.IMG.block1)
mario=image.new(_R.IMG.mario1)

level={}
mousePos={}
marioVelocity={}

storTime=0
fps=0
delta=0
frames=0
detectTime=0
level["itr"]=0
mousePos["x"]=90
mousePos["y"]=90

arrowUp=0
arrowDown=0
arrowLeft=0
arrowRight=0

cameraOffset=0
marioPos={16,20}
marioVelocity["x"]=0
marioVelocity["y"]=0

arrowLeftStor=0
arrowRightStor=0
arrowUpStor=0
arrowDownStor=0

--Functions--

function fillRoundRect(myGC,x,y,wd,ht,radius)  -- wd = width and ht = height -- renders badly when transparency (alpha) is not at maximum >< will re-code later
    if radius > ht/2 then radius = ht/2 end -- avoid drawing cool but unexpected shapes. This will draw a circle (max radius)
    myGC:fillPolygon({(x-wd/2),(y-ht/2+radius), (x+wd/2),(y-ht/2+radius), (x+wd/2),(y+ht/2-radius), (x-wd/2),(y+ht/2-radius), (x-wd/2),(y-ht/2+radius)})
    myGC:fillPolygon({(x-wd/2-radius+1),(y-ht/2), (x+wd/2-radius+1),(y-ht/2), (x+wd/2-radius+1),(y+ht/2), (x-wd/2+radius),(y+ht/2), (x-wd/2+radius),(y-ht/2)})
    x = x-wd/2  -- let the center of the square be the origin (x coord)
    y = y-ht/2 -- same
    myGC:fillArc(x + wd - (radius*2), y + ht - (radius*2), radius*2, radius*2, 1, -91);
    myGC:fillArc(x + wd - (radius*2), y, radius*2, radius*2,-2,91);
    myGC:fillArc(x, y, radius*2, radius*2, 85, 95);
    myGC:fillArc(x, y + ht - (radius*2), radius*2, radius*2, 180, 95);
end

function clearWindow(gc)
    --gc:begin()    -- la ya une utilite, mais tout ton repere est reporte de 28px vers le haut
    -- ok, on verra.
    gc:setColorRGB(255, 255, 255)
    gc:fillRect(0, 0, platform.window:width(), platform.window:height())
end

function test(arg)
	return arg and 1 or 0
end

function screenRefresh()
	return platform.window:invalidate()
end

function pww()
	return platform.window:width()
end

function pwh()
	return platform.window:height()
end

function drawPoint(myGC,vx, y)
	myGC:fillRect(x, y, 1, 1)
end

function drawCenteredString(myGC,str)
	myGC:drawString(str, (pww() - myGC:getStringWidth(str)) / 2, pwh() / 2, "middle")
end
                         
function drawXCenteredString(myGC,str,y)
	myGC:drawString(str, (pww() - myGC:getStringWidth(str)) / 2, y, "top")
end

function inRange(i, min, max)
    return i and (i >= min and i <= max)
end

function inRect(p, r)    --p=point={x,y}, r=rectangle={x,y,w,h}
    return (inRange(p[1],r[1],r[1]+r[3]) and inRange(p[2],r[2],r[2]+r[4]))
end

-- Collision detection function; --credit to Love2D
-- Returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

--------------------------
---------EVENTS-----------
--------------------------

function on.timer()
    platform.window:invalidate()
end

function on.charIn(chr)
    cameraOffset=math.random(-300,300)
end

function on.escapeKey()
    reset()
end

function on.arrowRight()
    arrowRight=arrowRight+1
end

function on.arrowLeft()
    arrowLeft=arrowLeft+1
end

function on.arrowUp()
    arrowUp=arrowUp+1
end

function on.arrowDown()
    arrowDown=arrowDown+1
end

function on.mouseMove(x,y)
    mousePos["x"]=x
    mousePos["y"]=y
--    print(mousePos["x"].." "..mousePos["y"])
end

---------------------------------------------------------------------------------

function resetKey()
    if arrowUp>arrowUpStor then arrowUp=1 else arrowUp=0 end
    if arrowDown>arrowDownStor then arrowDown=1 else arrowDown=0 end
    if arrowLeft>arrowLeftStor then arrowLeft=1 else arrowLeft=0 end
    if arrowRight>arrowRightStor then arrowRight=1 else arrowRight=0 end
    arrowLeftStor=arrowLeft
    arrowRightStor=arrowRight
    arrowUpStor=arrowUp
    arrowDownStor=arrowDown
end

function reset()
    randomise()
    cameraOffset=0
    marioPos={16,20}
    marioVelocity["x"]=0
    marioVelocity["y"]=0
end

function randomise()
    for i=1,13 do
        for i2=0,30 do
            level["x"..i2.."y"..i]=math.random(-2,1)
        end
    end
    level["x2y12"]=0
end

function getID(searchX,searchY)
    local id=level["x"..searchX.."y"..searchY]
    --if id~=nil and id>0 then 
    if id==nil then id=9 end --ID doesnt exist (out of bounds)
    return id
    --else return 0
    --end
end

function pixel2plot(x,y) 
    local plotX=math.ceil((x+cameraOffset)/16)
    local plotY=math.ceil((212-y)/16)
    return {plotX,plotY,getID(plotX,plotY)} end --[1] x [2] y

function fixcameraOffset()
    if marioPos[1]>96 then cameraOffset=marioPos[1]-96 end
    if marioPos[1]<96 then cameraOffset=0 end
end

function handleMovement() --turns arrow inputs into velocity
    if arrowLeft==1 or arrowRight==1 then
        if math.abs(marioVelocity["x"])<12 then
            marioVelocity["x"]=marioVelocity["x"]+arrowRight*1.4
            marioVelocity["x"]=marioVelocity["x"]-arrowLeft*1.4
        else marioVelocity["x"]=math.floor(marioVelocity["x"])
        end
        if arrowLeft==1 and marioVelocity["x"]>0 then marioStatus="drift"
        elseif arrowRight==1 and marioVelocity["x"]<0 then marioStatus="drift"
        else marioStatus="run" end
    else
        marioVelocity["x"]=marioVelocity["x"]*(0.8)
    end
    if math.abs(marioVelocity["x"])<0.3 then marioVelocity["x"]=0 end
end

function moveMario() --use velocity to update position
    if marioPos[1]+marioVelocity["x"]<0 then --edge of screen LEFT
        marioPos[1]=0
    else --no edges of screen
        marioPos[1]=marioPos[1]+marioVelocity["x"]
    if pixel2plot(marioPos[1]+(marioVelocity["x"]/16)-cameraOffset,marioPos[2])[3]==1 then
        marioPos[1]=marioPos[1]-marioVelocity["x"]
        marioVelocity["x"]=marioVelocity["x"]/2
    end
    end   
end

function drawTerrain(gc)
    for i=1,13 do --rendered in rows from left to right - bottom to top
        for i2=math.ceil(cameraOffset/16),math.ceil((320+cameraOffset)/16) do --only draw what is visible on screen
            if getID(i2,i)==1 then gc:drawImage(block1, ((i2-1)*16)-cameraOffset, 212-16*(i)) end
        end
    end
end

function drawRectDotted(gc,x,y,w,h,thickness)
    if thickness==nil then thickness="thin" end
    gc:setPen("thin","dotted")
    gc:drawRect(x,y,w,h)
    gc:setPen("thin","smooth")
end

function drawRectDashed(gc,x,y,w,h,thickness)
    if thickness==nil then thickness="thin" end
    gc:setPen("thin","dashed")
    gc:drawRect(x,y,w,h)
    gc:setPen("thin","smooth")
end


timer.start(0.01)
randomise()
print(2)



function on.paint(gc)
    gc:setColorRGB(0,255,0)
    --gc:drawImage(_G["wallpaper1"], 0, 0)
    resetKey()
    handleMovement()
    moveMario()
    fixcameraOffset()
    drawTerrain(gc)
--    for i=1,20 do 
--        gc:drawImage(block1, 0+16*(i-1), 0)
--    end
    frames=frames+1
    --if marioPos[1] then print(marioPos[1]) end
    --gc:drawImage(mario,marioPos[1]-cameraOffset,marioPos[2])
    gc:drawRect(marioPos[1]-cameraOffset,marioPos[2],1,1)
    gc:drawString("FPS: "..fps.." Speed: "..delta.." Left: "..arrowLeft.." Right: "..arrowRight, 0, 0, top)
    highlightedx=pixel2plot(mousePos["x"],mousePos["y"])[1]
    highlightedy=pixel2plot(mousePos["x"],mousePos["y"])[2]
    gc:drawString("x"..highlightedx.." y"..highlightedy.." id:"..getID(highlightedx,highlightedy), 0, 15, top)
    gc:drawString("v"..versText, 0, 190, top)
    if timer.getMilliSecCounter()-storTime>1000 then
        detectTime=timer.getMilliSecCounter()-storTime
        fps=math.ceil(frames*(timer.getMilliSecCounter()-storTime)/1000)
        frames=0
        storTime=timer.getMilliSecCounter()
        delta=(math.ceil((20/fps)*100))/100
    end
    drawRectDashed(gc,mousePos["x"],mousePos["y"],1,1,thin)
end

