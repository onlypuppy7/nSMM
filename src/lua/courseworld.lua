-- (c) onlypuppy7/chalex0 2025
--This code has been indented in places where it may not look necessary, this is in order to be able to collapse entire code categories in IDEs such as VSCode. Indents do not affect syntax in Lua :>

-- EDITING=true

--------------------------
---------CONFIG-----------
--------------------------
    fileName="nSMMCourseWorld" --no special characters or spaces
    courseWorldVersion=5 --set this!
    courseWorldDate="2024-12-24" -- ctrl+shift+I, then remove time (or just YYYY-MM-DD)

    require("meta")

    dataPos=1 framesPassed=0
    levelListD="" cloudLength=18
    mouse={} mouse.x=0 mouse.y=0
    
    require("core.font")

--------------------------
----------EVENTS----------
--------------------------

    function on.arrowUp() gui.levelListDisplay.scroll=gui.levelListDisplay.scroll>1 and gui.levelListDisplay.scroll-1 or gui.levelListDisplay.scroll end
    function on.arrowDown() gui.levelListDisplay.scroll=gui.levelListDisplay.scroll<92 and gui.levelListDisplay.scroll+1 or gui.levelListDisplay.scroll end
    function on.mouseMove(x,y) mouse.x,mouse.y=x,y end
    function on.mouseDown(x,y) gui:click() end

--------------------------
-----TEXTURE LIBRARY------
--------------------------

    function loadTextures()
        texs.Cloud=image.new("\016\000\000\000\016\000\000\000\000\000\000\000 \000\000\000\016\000\001\000\000\000\000\000\000\000\000\128\000\128\000\128\000\128\000\128\000\128\000\128\000\128\000\128\000\128\000\000\000\000\000\000\000\000\000\000\000\128\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\000\128\000\000\000\000\000\000\000\128\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\000\128\000\000\000\000\000\128\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\000\128\000\000\000\000\000\128\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\000\128\000\000\000\128\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\000\128\000\128\255\255\255\255\255\255\255\255\255\255\000\128\255\255\255\255\000\128\255\255\255\255\255\255\255\255\255\255\000\128\000\128\255\255\255\255\255\255\255\255\255\255\000\128\255\255\255\255\000\128\255\255\255\255\255\255\255\255\255\255\000\128\000\128\255\255\255\255\255\255\255\255\255\255\000\128\255\255\255\255\000\128\255\255\255\255\255\255\255\255\255\255\000\128\000\128\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\000\128\000\128\255\255\000\128\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\000\128\255\255\000\128\000\000\000\128\255\255\255\255\255\255\000\128\255\255\255\255\255\255\255\255\000\128\255\255\255\255\255\255\000\128\000\000\000\000\000\128\255\255\255\255\255\255\255\255\000\128\000\128\000\128\000\128\255\255\255\255\255\255\255\255\000\128\000\000\000\000\000\128\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\000\128\000\000\000\000\000\000\000\128\255\255\255\255\255\255\255\255\000\128\000\128\255\255\255\255\255\255\255\255\000\128\000\000\000\000\000\000\000\000\000\000\000\128\000\128\000\128\000\128\000\000\000\000\000\128\000\128\000\128\000\128\000\000\000\000\000\000")
        texs.Fence=image.new("\016\000\000\000\016\000\000\000\000\000\000\000 \000\000\000\016\000\001\000\000\000\000\000\000\000\000\0008\255 \2058\2558\2558\255 \205 \205\000\128\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0008\255 \2058\2558\255 \205 \205 \205\000\128\000\000\000\000\000\000\000\000 \205 \2058\2558\2558\255 \2058\2558\255 \205 \205 \205\000\1288\2558\2558\2558\255 \205 \205 \205 \2058\255 \2058\2558\255 \205 \205 \205\000\128 \205 \205 \205 \205\000\128\000\128\000\128\000\1288\255 \2058\2558\255 \205 \205 \205\000\128\000\128\000\128\000\128\000\128\000\000\000\000\000\000\000\0008\255 \2058\2558\255 \205 \205 \205\000\128\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0008\255 \2058\2558\255 \205 \205 \205\000\128\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0008\255 \2058\255 \2058\255 \205 \205\000\128\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0008\255 \2058\255 \2058\255 \205 \205\000\128\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0008\255 \2058\255 \2058\255 \205 \205\000\128\000\000\000\000\000\000\000\000 \205 \2058\2558\2558\255 \2058\255 \2058\255 \205 \205\000\1288\2558\2558\2558\255 \205 \205 \205 \2058\255 \2058\255 \2058\255 \205 \205\000\128 \205 \205 \205 \205\000\128\000\128\000\128\000\1288\255 \2058\2558\2558\255 \205 \205\000\128\000\128\000\128\000\128\000\128\000\000\000\000\000\000\000\0008\255 \2058\2558\2558\255 \205 \205\000\128\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0008\255 \2058\2558\2558\255 \205 \205\000\128\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0008\255 \2058\2558\2558\255 \205 \205\000\128\000\000\000\000\000\000\000\000")
        texs.levelList_G=image.new("\004\000\000\000\004\000\000\000\000\000\000\000\008\000\000\000\016\000\001\000\255\127\237\207\237\207\237O\237\207\237\207\237\207\237\207\237\207\237\207\237\207\237\207\237O\237\207\237\207\237O")
        texs.levelList_O=image.new("\004\000\000\000\004\000\000\000\000\000\000\000\008\000\000\000\016\000\001\000\255\127$\255$\255$\127$\255$\255$\255$\255$\255$\255$\255$\255$\127$\255$\255$\127")
        texs.levelList_R=image.new("\004\000\000\000\004\000\000\000\000\000\000\000\008\000\000\000\016\000\001\000\255\127\198\252\198\252\255\127\198\252\198\252\198\252\198\252\198\252\198\252\198\252\198\252\198|\198\252\198\252\198|")
        texs.levelList_length=image.new("\004\000\000\000\004\000\000\000\000\000\000\000\008\000\000\000\016\000\001\000\031\178\031\178@\134\031\178\255\255@\134`\199\031\178\031\178\255\255`\199\031\178\031\178\031\178`\199\031\178")
        texs.levelList_scrollUp=image.new("\009\000\000\000\010\000\000\000\000\000\000\000\018\000\000\000\016\000\001\000c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140\255\255\255\255c\140c\140c\140c\140c\140c\140\255\255\255\255\255\255\255\255c\140c\140c\140c\140c\140\255\255\255\255\255\255\255\255c\140c\140c\140c\140\255\255\255\255\255\255\255\255\255\255\255\255c\140c\140c\140\255\255\255\255\255\255\255\255\255\255\255\255c\140c\140\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255c\140\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255c\140\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255")
        texs.levelList_scrollDown=image.new("\009\000\000\000\010\000\000\000\000\000\000\000\018\000\000\000\016\000\001\000c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140c\140\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255c\140\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255c\140\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255c\140c\140\255\255\255\255\255\255\255\255\255\255\255\255c\140c\140c\140\255\255\255\255\255\255\255\255\255\255\255\255c\140c\140c\140c\140\255\255\255\255\255\255\255\255c\140c\140c\140c\140c\140\255\255\255\255\255\255\255\255c\140c\140c\140c\140c\140c\140\255\255\255\255c\140c\140c\140")
        texs.levelList_scrollPiece=image.new("\008\000\000\000\009\000\000\000\000\000\000\000\016\000\000\000\016\000\001\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\173\181\173\181\173\181\173\181\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\173\181\173\181\173\181\173\181\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\173\181\173\181\173\181\173\181\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255")
        
        loadFont()
    end

--------------------------
------DATA FUNCTIONS------
--------------------------

    require("core.extendstandard")

    require("core.datastorage")

    require("core.levelserialise")

    require("core.misc")

    function addLevel(levelString)
        string2ext("levelList"..dataPos,levelString)
        levelListD=levelListD..dataPos.."-"
        dataPos=dataPos+1
    end

--------------------------
-------GUI FUNCTIONS------
--------------------------

    require("core.gui")
    
    function gui:clear()
        gui.buttonList={}
        gui.levelListBLs={} gui.levelLists={}
        gui.highlightedButton=false
    end

    function gui:levelList(gc,hook,LIST,TYPE)
        if not gui[LIST] then gui[LIST]={} end
        local x,y=hook[1]-(hook[3] or 0),(hook[4] or 0)+hook[2]
        if _G["loaded"..LIST]==nil then _G["loaded"..LIST]=ext2string(LIST,"loaded") and true or false end
        if (x>-320 and x<320) and (y>-218 and y<218) then
            if (gui[LIST].loaded or 0)>0 then
                local function drawRow(gc,x,y,number,courseData)
                    drawGUIBox(gc,x,y,22,19)
                    drawGUIBox(gc,x+20,y,209,19,nil,nil,true)
                    drawFont(gc,tostring(addZeros(number,2)),x+4,y+6)
                    drawFont(gc,courseData[1],x+49,y+4)
                    if courseData[2] then --level exists
                        --compatibility icon
                        local icon=(courseData[2]==versNum and "G" or courseData[2]<versNum and "O" or "R")
                        gc:drawImage(texs["levelList_"..icon],x+49,y+12)
                        drawFont2(gc,courseData[3],x+54,y+12)
                        --length icon
                        local length=tostring(courseData[5])
                        gc:drawImage(texs.levelList_length,x+106,y+12)
                        drawFont2(gc,length,x+111,y+12)
                        --author
                        drawFont2(gc,courseData[4],x+202,y+12,"right")
                    end
                end
                for i=1,8 do local lvl=gui[LIST][i+gui[LIST].scroll-1] or {"NO DATA",false}
                    drawRow(gc,x+31,y+20+i*19,i+gui[LIST].scroll-1,lvl)
                end
                drawGUIBox(gc,x+263,y+39,15,152)
                gc:drawImage(texs.levelList_scrollPiece,x+267,y+58+((gui[LIST].scroll-1)*(106/91))) -- 91 slots, 106 px (to scroll)
                gc:setColorRGB(108,108,108)     gc:drawRect(x+265,y+54,11,2)            gc:drawRect(x+265,y+174,11,2)
                gc:setColorRGB(255,255,255)     gc:drawLine(x+264,y+55,x+265+12,y+55)   gc:drawLine(x+264,y+175,x+265+12,y+175)
                -- gc:fillRect(x+267,y+61,8,9)
            else drawFont(gc,"LOADING...",x+122,y+102) 
            end
            gui:initLevelList(hook,LIST,TYPE)
    end end

    function gui:initLevelList(hook,LIST,TYPE)
        if gui[LIST].loaded==nil then
            local scroll=gui[LIST].scroll or 1
            gui:createLookupTable(LIST)
            gui[LIST].scroll=scroll gui[LIST].loaded=1
            gui[LIST].x=hook[1] gui[LIST].y=hook[2]
            gui["buttonList"..LIST]={}
            table.insert(gui.levelLists,LIST)
            table.insert(gui.levelListBLs,"buttonList"..LIST)
        elseif gui[LIST].loaded==1 then
            gui:newButton("levelList_scrollUp",{"levelList_scrollUp",10,12},hook[1]+266,hook[2]+42+8,"scrollU"..LIST)
            gui:newButton("levelList_scrollDown",{"levelList_scrollDown",10,12},hook[1]+266,hook[2]+177+8,"scrollD"..LIST)
            gui[LIST].loaded=2
    end end

    function gui:retrieveLevel(LIST,location) return _G["levelList"..location] end
    function gui:retrieveLookupString(LIST) return levelListD end

    function gui:detectPos(offsetX,offsetY,x,y) -- what this does is take the mouse pos and tries to match it to being within the boundary of a button. if it succeeds then it changes the mouse pointer and sets the highlightedButton var to the ID of the button
        x=x or mouse.x y=y or mouse.y
        gui.highlightedButton=false
        local buttonLists={"buttonList"}
        for i2=1,#buttonLists do
            local offX=buttonLists[i2]=="buttonListPrompt" and 0 or offsetX local offY=buttonLists[i2]=="buttonListPrompt" and 8 or offsetY
            for i=1,#gui[buttonLists[i2]] do
                if checkCollision(x,y,1,1,gui[buttonLists[i2]][i].ix-offX,gui[buttonLists[i2]][i].iy+offY-8,gui[buttonLists[i2]][i].w,gui[buttonLists[i2]][i].h) then
                    gui.highlightedButton={i,buttonLists[i2]} cursor.set("hand pointer") return
        end end end
        cursor.set("default")
    end

    function gui:click(action) -- actions relating to buttons and prompts go here. also some small tasks too.
        if gui.highlightedButton or action then
            local action=action or gui[gui.highlightedButton[2]][gui.highlightedButton[1]]["action"]
            if string.sub(action,1,6)=="scroll" then
                if string.sub(action,7,7)=="U" then on.arrowUp()
                elseif string.sub(action,7,7)=="D" then on.arrowDown() end
            end cursor.set("default")
    end end

--------------------------
------LEVEL LIBRARY-------
--------------------------

function loadLevels()
    require("courseworld.courses")
    for i=1,#COURSEWORLDCOURSES do
        addLevel(COURSEWORLDCOURSES[i])
    end
    COURSEWORLDCOURSES={}
end

--------------------------
------FRAME FUNCTIONS-----
--------------------------
function on.paint(gc)
    framesPassed=framesPassed+1
    if framesPassed==1 then
        loadTextures() loadLevels()
        gc:setColorRGB(0,0,0) gc:fillRect(0,0,320,212)
        if EDITING then
            string2ext("loaded",courseWorldVersion..courseWorldDate)
            -- print(ext2string(fileName,"levelList1"))
            -- print(levelList1)
            string2ext("levelListD",string.sub(levelListD,1,(#levelListD)-1))
            print("levelListD",string.sub(levelListD,1,(#levelListD)-1))
        end
        isLoaded=ext2string(fileName,"loaded") gui:clear()
        print("Course World Version: "..courseWorldVersion)
        print("Date: "..courseWorldDate)
        print("Levels: "..(dataPos-1))
    else
        gc:setColorRGB(97,133,248) gc:fillRect(0,0,320,212)
        for i=0,cloudLength-1 do gc:drawImage(texs.Cloud,160-(8*cloudLength)+(i*16),190) end
        for i=0,cloudLength-1 do gc:drawImage(texs.Fence,160-(8*cloudLength)+(i*16),174) end --easier than importing all that level code!!
        drawFont(gc,"COURSE WORLD FOR NSMM",nil,5,"centre",nil,{0,0,0})
        if (framesPassed%40)>20 then
            drawFont(gc,"VERSION "..courseWorldVersion,316,202,"right",nil,{0,0,0})
        else
            drawFont(gc,"MODIFIED "..courseWorldDate,316,202,"right",nil,{0,0,0})
        end
        drawFont(gc,"FOR NSMM V"..versText,3,202,nil,nil,{0,0,0})
        if not (isLoaded==(courseWorldVersion..courseWorldDate)) then drawFont(gc,"NOT READY, LOOK IN PAGE 2.1!",nil,16,"centre",nil,{200,0,0})
        else drawFont(gc,"READY!",nil,16,"centre",nil,{0,150,20}) end
        gui:levelList(gc,{0,-10},"levelListDisplay")
        gui:drawButtons(gc,0,0,"buttonList")
        gui:detectPos(0,0)
    end
end

timer.start(0.2)
function on.timer()
    platform.window:invalidate() --refreshes screen
end