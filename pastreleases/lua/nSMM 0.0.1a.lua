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
cameraPan=0
level["itr"]=0
marioPos={16,20}
mousePos["x"]=0
mousePos["y"]=0

arrowUp=0
arrowDown=0
arrowLeft=0
arrowRight=0

marioVelocity["x"]=0
marioVelocity["y"]=0

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
    keyReset()
end

function on.charIn(chr)
    cameraPan=math.random(-300,300)
end

function on.escapeKey()
    randomise()
    cameraPan=0
end

function on.arrowRight()
    arrowRight=1
end

function on.arrowLeft()
    arrowLeft=1
end

function on.arrowUp()
    arrowUp=1
end

function on.arrowDown()
    arrowDown=1
end

function on.mouseMove(x,y)
    mousePos["x"]=x
    mousePos["y"]=y
    print(mousePos["x"].." "..mousePos["y"])
end

---------------------------------------------------------------------------------

function keyReset()
    arrowUp=0
    arrowDown=0
    arrowLeft=0
    arrowRight=0
end

function randomise()
    for i=1,13 do
        for i2=0,30 do
            level["x"..i.."y"..i2]=math.random(-1,1)
        end
    end
end

function getID(x,y) return level["x"..x.."y"..y] end
function pixel2plot(x,y) return {math.ceil((x)/16),math.ceil((4+212-y)/16)} end

function fixCameraPan()
    if marioPos[1]>96 then cameraPan=marioPos[1]-96 end
end

function handleMovement()
    if arrowLeft==1 or arrowRight==1 then
        if math.abs(marioVelocity["x"])<10 then
            marioVelocity["x"]=marioVelocity["x"]+arrowRight*0.8
            marioVelocity["x"]=marioVelocity["x"]-arrowLeft*0.8
        end
    else
        marioVelocity["x"]=marioVelocity["x"]*0.8
    end
end

function moveMario()
    marioPos[1]=marioPos[1]+marioVelocity["x"]
end

timer.start(0.01)
randomise()
print(2)



function on.paint(gc)
    --gc:drawImage(_G["wallpaper1"], 0, 0)
    handleMovement()
    moveMario()
    fixCameraPan()
    for i=1,13 do
        for i2=0,30 do
            if getID(i,i2)==1 then gc:drawImage(block1, ((i2-1)*16)-cameraPan, 212-16*(i)) end
        end
    end
--    for i=1,20 do 
--        gc:drawImage(block1, 0+16*(i-1), 0)
--    end
    frames=frames+1
    gc:drawString("FPS: "..fps.." Speed: "..delta.."x"..pixel2plot(mousePos["x"]-cameraPan,mousePos["y"])[1].."y"..pixel2plot(mousePos["x"]-cameraPan,mousePos["y"])[2], 0, 0, top)
    if timer.getMilliSecCounter()-storTime>1000 then
        detectTime=timer.getMilliSecCounter()-storTime
        fps=math.ceil(frames*(timer.getMilliSecCounter()-storTime)/1000)
        frames=0
        storTime=timer.getMilliSecCounter()
        delta=(math.ceil((60/fps)*100))/100
    end
    gc:drawImage(mario,marioPos[1]-cameraPan,marioPos[2])
end

