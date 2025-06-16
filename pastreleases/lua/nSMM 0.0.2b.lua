versText="0.0.2"



--ui
cursor=image.new(_R.IMG.cursor2)
text_Ground=image.new(_R.IMG.ground)
Rsmall_idle=image.new(_R.IMG.Rsmall_idle)
Rsmall_walk1=image.new(_R.IMG.Rsmall_walk1)
Rsmall_jump=image.new(_R.IMG.Rsmall_jump)
Rsmall_drift=image.new(_R.IMG.Rsmall_drift)

level={}
mousePos={}
blockIndex={}

mario=class()
addBlock=class()

frameStor=0
storTime=0
fps=0
delta=0
framesPassed=0
detectTime=0
level["itr"]=0
mousePos.x=90
mousePos.y=90

arrowUp=0
arrowDown=0
arrowLeft=0
arrowRight=0

arrowUpInput=0
arrowDownInput=0
arrowLeftInput=0
arrowRightInput=0

arrowUpDelay=0
arrowDownDelay=0
arrowLeftDelay=0
arrowRightDelay=0

cameraOffset=0
mario.status=0

arrowLeftStor=0
arrowRightStor=0
arrowUpStor=0
arrowDownStor=0

-----------------------------------------------------------
-------------------------CLASSES---------------------------
-----------------------------------------------------------
function addBlock:init(id,name,solid,textureID) --textureID can also be a list, eg {1,1,1,1,2,3} for an animation sequence
    print(id,name,solid)
    self.id=id
    blockIndex[self.id]={["solid"]=solid,["name"]=name,["texture"]=textureID}
    --set default
    if blockIndex[self.id]["invisible"]== nil then      blockIndex[self.id]["invisible"]=false end    --doesnt render
    if blockIndex[self.id]["jumpThrough"]== nil then    blockIndex[self.id]["jumpThrough"]=false end  --semisolid
    if blockIndex[self.id]["containing"]== nil then     blockIndex[self.id]["containing"]=false end   --contains coins, powerup, vine or star
    if blockIndex[self.id]["bumpable"]== nil then       blockIndex[self.id]["bumpable"]=false end     --ie moves when hit (bricks, question marks)
    if blockIndex[self.id]["inFront"]== nil then       blockIndex[self.id]["inFront"]=false end       --drawn after mario and objects, useful for pipes and castle black void
end

function addBlock:attribute(property,val) --invisible, jumpThrough, containing, bumpable,
    blockIndex[self.id][property]=val
    print(blockIndex[self.id][property],blockIndex[self.id]["solid"])
end

-----------------------------------------------------------
-------------------------INDEX-----------------------------
-----------------------------------------------------------

--addBlock(id,name,solid,textureID)

addBlock(0,"Air",false,nil):attribute("invisible",true)
addBlock(1,"Ground",true,text_Ground)


-----------------------------------------------------------
--------------------GENERAL-FUNCTIONS----------------------
-----------------------------------------------------------

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
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2) -- Returns true if two boxes overlap, false if they don't;
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
    if chr=="1" then
        mario.pos.y=212-65
    elseif chr=="2" then
        mario.velocity.y=400
    elseif chr=="4" then
        arrowLeftInput=arrowLeftInput+1
    elseif chr=="6" then
        arrowRightInput=arrowRightInput+1
    elseif chr=="5" or chr==" " then
        arrowUpInput=arrowUpInput+1
    else reset()
    end
end

function on.escapeKey()
    generate()
    mario.resetPos()
end

function on.arrowRight()
    arrowRightInput=arrowRightInput+1
end

function on.arrowLeft()
    arrowLeftInput=arrowLeftInput+1
end

function on.arrowUp()
    arrowUpInput=arrowUpInput+1
end

function on.arrowDown()
    arrowDownInput=arrowDownInput+1
end

function on.mouseMove(x,y)
    mousePos.x=x
    mousePos.y=y
--    print(mousePos.x.." "..mousePos.y)
end

---------------------------------------------------------------------------------

function handleInput()
    local delay=3 --mess of hardcoded shit, sorry
    
    arrowLeftDelay=arrowLeftDelay-1
    arrowRightDelay=arrowRightDelay-1
    
    if arrowUpInput>arrowUpStor then arrowUp=1 else arrowUp=0 end
    if arrowDownInput>arrowDownStor then arrowDown=1 else arrowDown=0 end
    if arrowLeftInput>arrowLeftStor then arrowLeft=1 arrowLeftDelay=delay else arrowLeft=0 end
    if arrowRightInput>arrowRightStor then arrowRight=1 arrowRightDelay=delay else arrowRight=0 end
    
    arrowLeftStor=arrowLeftInput
    arrowRightStor=arrowRightInput
    arrowUpStor=arrowUpInput
    arrowDownStor=arrowDownInput
    
    if arrowLeftDelay>0 then arrowLeft=1 end
    if arrowRightDelay>0 then arrowRight=1 end
end

function reset()
    randomise()
    cameraOffset=0
    mario.resetPos()
end

function randomise()
    for i=1,13 do --y axis
        for i2=0,50 do --x axis
            level["x"..i2.."y"..i]=math.random(-2,1)
        end
    end
    level["x2y12"]=0
end

function pol2binary(num)
    return ((num/math.abs(num))+1)/2
end

function getID(searchX,searchY)
    local id=level["x"..searchX.."y"..searchY]
    --if id~=nil and id>0 then 
    if id==nil then id=-1 end --ID doesnt exist (out of bounds)
    return id
    --else return 0
    --end
end

function pixel2plot(x,y,global) --returns co-ordinate of block from a screen pixel position
    local plotX
    if global then --doesnt take camera offset into account if true
        plotX=math.ceil((x)/16)
    else -- relative to the camera (DEFAULT)
        plotX=math.ceil((x+cameraOffset)/16)
    end
    local plotY=math.ceil((212-y)/16)
    local ID=getID(plotX,plotY)
    if ID<0 then ID=0 end --for random generation
    return {plotX,plotY,ID,blockIndex[ID]["solid"]} --[1] x [2] y
end

function fixcameraOffset()
    if mario.pos.x>96 then cameraOffset=mario.pos.x-96 end
    if mario.pos.x<96 then cameraOffset=0 end
end

function handleMovement() --turns arrow inputs into velocity
--X movement
    if arrowLeft==1 or arrowRight==1 then
        if math.abs(mario.velocity.x)<5 then --max running speed 5
            if math.abs(mario.velocity.x)<2.7 then --walking under 2.7
            mario.velocity.x=mario.velocity.x+arrowRight*0.9
            mario.velocity.x=mario.velocity.x-arrowLeft*0.9
            elseif math.abs(mario.velocity.x)<5 then
            mario.velocity.x=mario.velocity.x+arrowRight*1.4
            mario.velocity.x=mario.velocity.x-arrowLeft*1.4 end
        else mario.velocity.x=math.floor(mario.velocity.x)
        end
    else
        mario.velocity.x=mario.velocity.x*(0.8)
    end
    if math.abs(mario.velocity.x)<0.4 then mario.velocity.x=0 end --movement minumum, prevents velocity of 0.00001626 for example
--Y movement [TEMP CONTROL]
    if arrowUp==1 and not gravityCheck(mario.pos.x,mario.pos.y,1) then  --up arrow pressed and on the floor (no double jumps)
        local runningBoost=0
        if math.abs(mario.velocity.x)>3 then runningBoost=math.abs(mario.velocity.x) end
        mario.velocity.y=18+runningBoost
        print(mario.velocity.y,runningBoost,mario.velocity.x)
    else mario.velocity.y=mario.velocity.y*0.745 end --slow down upwards velocity when jumping (lower is floatier)
    if not bumpCheck(mario.pos.x,mario.pos.y,-mario.velocity.y/2) then --this shit fixes it, idk why but dont touch this
        mario.velocity.y=-0.6 --not bumpCheck(mario.pos.x,mario.pos.y,-1) or 
    end
    if math.abs(mario.velocity.y)<0.6 then mario.velocity.y=0 end --movement minumum, prevents velocity of 0.00001626 for example
    moveMario()
end

function moveMario() --use velocity to update position
--X handling
    if aggregateCheckMX(mario.pos.x,mario.pos.y,mario.velocity.x) then --no walls in X direction!
        mario.pos.x=mario.pos.x+mario.velocity.x
    else --wall detected
        mario.velocity.x=mario.velocity.x/3 --slow mario down so he can go closer to wall
        if aggregateCheckMX(mario.pos.x,mario.pos.y,mario.velocity.x) then 
            mario.pos.x=mario.pos.x+mario.velocity.x
        end --prevent unsmooth stuttering near wall
    end
--Y handling
    if gravityCheck(mario.pos.x,mario.pos.y,0) and not (mario.velocity.y>0.1) then --gravity occurs!
        local tempVelocity=0
        if gravityCheck(mario.pos.x,mario.pos.y,8) then --large distance between floor
            if mario.velocity.y>-7 then -- terminal velocity: -7
                mario.velocity.y=mario.velocity.y-1.7
            else mario.velocity.y=-7 end
        else --small distance
            for i=-8,1 do
                if gravityCheck(mario.pos.x,mario.pos.y,math.abs(i)) then
                    tempVelocity=i-1
                    mario.velocity.y=0
                    break
                end
            end
        end
        mario.pos.y=mario.pos.y-mario.velocity.y-tempVelocity
    elseif mario.velocity.y>0.1 then
        mario.pos.y=mario.pos.y-mario.velocity.y
    end
end

function mario.draw(gc)
    if mario.velocity.y==0 then
        if mario.velocity.x~=0 then mario.status="walk1" end
        if arrowLeft==1 and mario.velocity.x>0 then mario.status="drift" --drift animation if arrow key is going opposite way to velocity
        elseif arrowRight==1 and mario.velocity.x<0 then mario.status="drift" end
        if mario.velocity.x==0 then mario.status="idle" end
    else mario.status="jump" end
    gc:drawImage(_G["Rsmall_"..mario.status],mario.pos.x-cameraOffset,mario.pos.y)
end

function aggregateCheckMX(xPos,yPos,xVel,powerStatus) --checks points at head, feet, left, right
    if powerStatus==nil then powerStatus=0 end
    local topLeft=moveCheckMX(xPos+3,yPos+1,xVel) --more leniency
    local topRight=moveCheckMX(xPos+13,yPos+1,xVel) --more leniency, 14 pixel search
    local bottomLeft=moveCheckMX(xPos+3,yPos+15,xVel)
    local bottomRight=moveCheckMX(xPos+13,yPos+15,xVel)
    local powerLeft
    local powerRight----------------------------------------------------------------------------------------o_ <--powerLeft/Right, big mario calculated after (and hardcoded :<)
    if powerStatus>0 then powerLeft=moveCheckMX(xPos+2,yPos-16+1,xVel) else powerLeft=true end -------------O                   (offset also needed when rendering)
    if powerStatus>0 then powerRight=moveCheckMX(xPos+15,yPos-16+1,xVel) else powerRight=true end----------@=@ <-- topLeft/Right, position always set as small mario height
    if topLeft and topRight and bottomLeft and bottomRight and powerLeft and powerRight then return true---/\  <--bottomLeft/Right
    else return false
    end
end

function moveCheckMX(xPos,yPos,xVel) --CHECKS FOR INTERFERENCE IN X AXIS returns true if nothing in the way
--X AXIS HANDLING
    --print(xPos,xVel)
    if xPos+xVel<0 then --edge of screen LEFT
        return false
    else --no edges of screen
        xPos=xPos+xVel --temp set to new pos
    end
    if pixel2plot(xPos+(xVel/16)-cameraOffset,yPos)[3]==1 then --check if new x pos in a wall
        return false
    else return true
    end
end

function moveCheckMY(xPos,yPos,yVel) --CHECKS FOR INTERFERENCE IN Y AXIS returns true if nothing in the way
--Y AXIS HANDLING
    if pixel2plot(xPos-cameraOffset,yPos+(yVel/16))[4] then --check if new y pos in a wall
        return false
    else return true
    end
end

function gravityCheck(xPos,yPos,yVel) --CHECKS IF STANDING ON BLOCK returns true if gravity applies
    local bottomLeft = moveCheckMY(xPos+3,yPos+16,16*yVel)
    local bottomRight = moveCheckMY(xPos+13,yPos+16,16*yVel)
    if bottomLeft and bottomRight then
        return true
    else return false
    end
end

function bumpCheck(xPos,yPos,yVel,powerStatus) --CHECKS IF ABOUT TO COLLIDE WITH BLOCK returns true if bump applies
    if powerStatus==nil then powerStatus=0 end
    local topLeft = moveCheckMY(xPos+5,yPos,16*yVel) --easier to make tight jumps (has to be same as gravityCheck or can climb walls) 
    local topRight = moveCheckMY(xPos+11,yPos,16*yVel)
    local powerLeft
    local powerRight
    if powerStatus>0 then powerLeft=moveCheckMY(xPos+5,yPos-11,16*yVel) powerRight=moveCheckMY(xPos+13,yPos-15,16*yVel)
    else powerLeft=true powerRight=true end
    if topLeft and topRight and powerLeft and powerRight then
        return true
    else return false
    end
end

function drawTerrain(gc)
    for i=1,13 do --rendered in rows from left to right - bottom to top
        for i2=math.ceil(cameraOffset/16),math.ceil((320+cameraOffset)/16) do --only draw what is visible on screen
            local blockID=getID(i2,i)
            if blockID<0 then blockID=0 end
            if blockIndex[blockID]["invisible"]==false then gc:drawImage(blockIndex[blockID]["texture"], ((i2-1)*16)-cameraOffset, 212-16*(i)) end
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

function generate()
    cameraOffset=0
    for i=1,13 do --y axis
        for i2=0,50 do --x axis
            level["x"..i2.."y"..i]=0
        end
    end
    for i=1,2 do --y axis
        for i2=0,50 do --x axis
            level["x"..i2.."y"..i]=1
        end
    end
    for i=3,4 do --y axis
        for i2=5,6 do --x axis
            level["x"..i2.."y"..i]=1
        end
    end
    for i=3,5 do --y axis
        for i2=10,11 do --x axis
            level["x"..i2.."y"..i]=1
        end
    end
    for i=3,6 do --y axis
        for i2=15,16 do --x axis
            level["x"..i2.."y"..i]=1
        end
    end
    for i=3,7 do --y axis
        for i2=20,21 do --x axis
            level["x"..i2.."y"..i]=1
        end
    end
    for i=4,4 do --y axis
        for i2=1,2 do --x axis
            level["x"..i2.."y"..i]=1
        end
    end
    for i=7,7 do --y axis
        for i2=1,2 do --x axis
            level["x"..i2.."y"..i]=1
        end
    end
    level["x2y12"]=0
end

timer.start(0.01)
generate()
print("Running!",versText)

function mario:init()
    mario.velocity={}
    mario.pos={}
    self.resetPos()
end

function mario:resetPos()
    mario.pos.x=16 mario.pos.y=20
    mario.velocity.x=0 mario.velocity.y=0
end

mario=mario()

function on.paint(gc)
    gc:setColorRGB(97, 133, 248)
    gc:fillRect(0,0,320,218)
    gc:setColorRGB(0,255,0)
    --gc:drawImage(_G["wallpaper1"], 0, 0)
    handleInput()
    handleMovement()
    fixcameraOffset()
    drawTerrain(gc)
--    for i=1,20 do 
--        gc:drawImage(block1, 0+16*(i-1), 0)
--    end
    framesPassed=framesPassed+1
    frameStor=frameStor+1
    --if mario.pos.x then print(mario.pos.x) end
    mario.draw(gc)
    --gc:drawRect(mario.pos.x-cameraOffset,mario.pos.y,16,16)
    gc:drawString("FPS: "..fps.." Speed: "..delta.." Dir: "..pol2binary(mario.velocity.x).." dly: "..arrowRightDelay.." velY: "..mario.velocity.y, 0, 0, top)
    highlightedx=pixel2plot(mousePos.x,mousePos.y)[1]
    highlightedy=pixel2plot(mousePos.x,mousePos.y)[2]
    gc:drawString("x"..highlightedx.." y"..highlightedy.." id:"..getID(highlightedx,highlightedy), 0, 15, top)
    gc:drawString("v"..versText, 0, 190, top)
    if timer.getMilliSecCounter()-storTime>1000 then
        detectTime=timer.getMilliSecCounter()-storTime
        fps=math.ceil(frameStor*(timer.getMilliSecCounter()-storTime)/1000)
        frameStor=0
        storTime=timer.getMilliSecCounter()
        delta=(math.ceil((20/fps)*100))/100
    end
    drawRectDashed(gc,mousePos.x,mousePos.y,1,1,thin)
    while True do end
end

