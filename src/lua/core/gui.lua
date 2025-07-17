function drawGUIBox(gc,x,y,w,h,header,text,ignoreLeft) --dont recommend making awfully small boxes
    gc:setPen("thin","smooth") -- i never quite know how to describe these.. vv
    gc:setColorRGB(0,0,0) --outer black border
    gc:drawRect(ignoreLeft and x+2 or x,y,ignoreLeft and w-2 or w,h)
    gc:setColorRGB(255,255,255) --white filling
    gc:fillRect(ignoreLeft and x+2 or x+1,y+1,ignoreLeft and w-2 or w-1,h-1)
    gc:setColorRGB(27,27,27) --dark grey inner box filling
    gc:fillRect(x+3,y+1+(header and 10 or 2),w-5,h-(3+(header and 10 or 2)))
    if header then drawFont(gc,header,x+w/2,y+1,"centre",0,true) end
    gc:setColorRGB(108,108,108) --light grey inner box border
    gc:drawRect(x+2,y+(header and 10 or 2),w-4,h-(2+(header and 10 or 2)))
    if text then
        for i=1,#text do
            drawFont(gc,text[i],x+w/2,y+12+(i-1)*9,"centre",0)
    end end
end

gui=class()

function gui:init()
    gui:clear() gui.levelLists={} gui.levelListBLs={}
end

function gui:escapeKey()
    if gui.PROMPT and not gui.PROMPT[8] then
        gui:clearPrompt()
        __PC.SOUND:sfx("menuback")
end end

function gui:enterKey()
    if gui.PROMPT and type(gui.PROMPT[7])=="string" and #gui.input>0 then
        local action=gui.PROMPT[7] local input=gui.input
        gui:clearPrompt() gui.input=input
        gui:click(action)
end end

function gui:charIn(chr)
    if ((chr:isAlphaNumeric() or chr==" " or chr=="." or chr=="!" or chr=="/" or chr=="?" or chr=="," or chr=="'" or chr=="(" or chr==")" or chr=="-") and not (#chr > 1)) and gui.PROMPT.inputLength and gui.PROMPT.inputLength>#gui.input then
        gui.input=gui.input..chr
    end
end
function gui:backspaceKey()
    if #gui.input>0 then
        gui.input=string.sub(gui.input,1,#gui.input-1)
    end
end

function gui:clear()
    gui.buttonList={}
    if gui.levelLists then for i=1,#gui.levelLists do gui[gui.levelLists[i]].loaded=nil end end
    if gui.levelListBLs then for i=1,#gui.levelListBLs do gui[gui.levelListBLs[i]]=nil end end
    -- gui.buttonListlevelListLocal=nil
    gui.levelListBLs={} --gui.levelLists={}
    gui.highlightedButton=false
    gui.levelListDisplay={}
    gui:clearPrompt()
end

function gui:paint(gc)
    if (not titleScreen.active) and (editor.active or playStage.active) then
        gui:drawButtons(gc,0,8,"buttonList")
        if editor.levelList then gui:drawButtons(gc,0,8,"buttonListlevelListLocal") end --huge bodge, huge cringe
    elseif titleScreen.active then
        local offset={titleScreen.cameraOffsetX,titleScreen.cameraOffsetY-8}
        gui:levelList(gc,{640,0,offset[1],offset[2]},"levelListLocal","titlescreen")
        gui:levelList(gc,{320,-224,offset[1],offset[2]},"nSMMCourseWorld","titlescreen")
        for i=1,#gui.levelListBLs do
            gui:drawButtons(gc,offset[1],titleScreen.cameraOffsetY,gui.levelListBLs[i])
        end
        -- gui:drawButtons(gc,offset[1],offset[2],"buttonList")
        gui:drawButtons(gc,offset[1],titleScreen.cameraOffsetY,"buttonList")
    end
    gui:drawMisc(gc)
    gui:drawButtons(gc,0,8,"buttonListPrompt")
end

function gui:scroll(dir)
    for i=1,#gui.levelLists do
        local levelList,cameraOffsetX,cameraOffsetY=gui[gui.levelLists[i]],titleScreen.active and titleScreen.cameraOffsetX or 0,titleScreen.active and -(titleScreen.cameraOffsetY-8) or 0
        if cameraOffsetX==levelList.x and cameraOffsetY==levelList.y then
            gui:click("scroll"..dir..gui.levelLists[i])
end end end

function gui:levelList(gc,hook,LIST,TYPE)
    if not gui[LIST] then gui[LIST]={} end
    local x,y=hook[1]-(hook[3] or 0),(hook[4] or 0)+hook[2]
    if (x>-320 and x<320) and (y>-218 and y<218) then
        if (gui[LIST].loaded or 0)>=1 then --dont change this stupid value
            if LIST~="levelListLocal" and not _G["loaded"..LIST] then
                drawFont(gc,"NOT FOUND!",x+120,y+82)
                drawFont(gc,"PLACE THE FILE NSMMCOURSEWORLD",x+40,y+92)
                drawFont(gc,"INTO THE MYLIB FOLDER AND",x+60,y+102)
                drawFont(gc,"PRESS DOC, THEN 6. FOR",x+56,y+112)
                drawFont(gc,"MORE INFORMATION, LOOK IN 2.2",x+44,y+122)
            else
                local function drawRow(gc,x,y,number,courseData)
                    drawGUIBox(gc,x,y,22,19)
                    drawGUIBox(gc,x+20,y,209,19,nil,nil,true)
                    drawFont(gc,addZeros(number,2),x+4,y+6)
                    drawFont(gc,courseData[1],x+49,y+4)
                    if courseData[2] then --level exists
                        --compatibility icon
                        local icon=(courseData[2]==versNum and "G" or courseData[2]<versNum and "O" or "R")
                        gc:drawImage(texs["levelList_"..icon],x+49,y+12)
                        if (mouse.x>=(x+49-1) and mouse.x<=(x+49+5)) and (mouse.y>=(y+12-1) and mouse.y<=(y+12+5)) then
                            gui.TEXT=(icon=="G") and "COMPATIBLE - UP TO DATE" or (icon=="O") and "PROBABLY COMPATIBLE - OUT OF DATE" or "LIKELY NOT COMPATIBLE - FOR NEWER NSMM"
                        end
                        drawFont2(gc,courseData[3],x+54,y+12)
                        --length icon
                        local length=tostring(courseData[5])
                        gc:drawImage(texs.levelList_length,x+106,y+12)
                        if (mouse.x>=(x+106-1) and mouse.x<=(x+106+5)) and (mouse.y>=(y+12-1) and mouse.y<=(y+12+5)) then
                            gui.TEXT="LEVEL LENGTH: "..length
                        end
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
                gc:setColorRGB(108,108,108)     gc:drawRect(x+265,y+54,11,2)            gc:drawRect(x+265,y+174,11,2) --grey
                gc:setColorRGB(255,255,255)     gc:drawLine(x+264,y+55,x+265+12,y+55)   gc:drawLine(x+264,y+175,x+265+12,y+175) --white lines (divide)
                -- gc:fillRect(x+267,y+61,8,9)
            end
        else drawFont(gc,"LOADING...",x+122,y+102) 
        end
        if x==0 and y==0 and gui[LIST].loaded~=3 then
            if gui[LIST].loaded~=2 then gui:initLevelList(hook,LIST,TYPE)
                gui[LIST].loaded=(gui[LIST].loaded or 0)+1
            elseif gui[LIST].loaded==2 then gui:refreshLevelList() --shit! just to "fix" course world... easier than actually fixing it
                gui[LIST].loaded=3
            end
end end end

function gui:initLevelList(hook,LIST,TYPE)
    if LIST~="levelListLocal" and _G["loaded"..LIST]==nil then _G["loaded"..LIST]=ext2string(LIST,"loaded") and true or (not not COURSEWORLDCOURSES) end
    if LIST=="levelListLocal" or _G["loaded"..LIST] then
        if gui[LIST].loaded==nil and not (LIST~="levelListLocal" and gui[LIST].directory) then --this logic is now needlessly complicated due to a problem 
            local scroll=gui[LIST].scroll or 1
            gui:createLookupTable(LIST)
            gui[LIST].scroll=scroll
            gui[LIST].x=hook[1] gui[LIST].y=hook[2]
            gui["buttonList"..LIST]={} local present=false
            for i=1,#gui.levelLists do if gui.levelLists[i]==LIST then present=true break end end
            if not present then table.insert(gui.levelLists,LIST) end
        elseif gui[LIST].loaded==1 then local present=false
            for i=1,#gui.levelListBLs do if gui.levelListBLs[i]=="buttonList"..LIST then present=true break end end
            if not present then table.insert(gui.levelListBLs,"buttonList"..LIST) end
            gui:newButton("levelList_scrollUp",{"levelList_scrollUp",10,12},hook[1]+266,hook[2]+42,"scrollU"..LIST)
            gui:newButton("levelList_scrollDown",{"levelList_scrollDown",10,12},hook[1]+266,hook[2]+177,"scrollD"..LIST)
            if editor.active and (not titleScreen.active) then gui:newButton("~ CANCEL",true,159,198,"ll_close") end
            gui:refreshLevelList()
        end
    end
end

function gui:refreshLevelList()
    local function refreshList(hook,LIST,buttonLIST,TYPE)
        local function refreshRow(x,y,number,courseData,buttonLIST,TYPE)
            if not TYPE or TYPE=="titlescreen" then
                if LIST=="nSMMCourseWorld" then
                    if courseData then
                        gui:newButton("levelList_play",{"levelList_play",12,12},x+24,y-4,"ll_play_"..number.."_"..LIST,buttonLIST)
                        gui:newButton("levelList_copy",{"levelList_copy",10,12},x+24+190,y-4,"ll_copy_"..number.."_"..LIST,buttonLIST)
                    end
                elseif courseData then
                    gui:newButton("levelList_play",{"levelList_play",12,12},x+24,y-4,"ll_play_"..number.."_"..LIST,buttonLIST)
                    gui:newButton("levelList_edit",{"levelList_edit",10,10},x+24+13,y-3,"ll_edit_"..number.."_"..LIST,buttonLIST)
                    gui:newButton("levelList_copy",{"levelList_copy",10,12},x+24+178,y-4,"ll_copy_"..number.."_"..LIST,buttonLIST)
                    gui:newButton("levelList_delete",{"levelList_delete",13,12},x+24+189,y-4,"ll_delete_"..number.."_"..LIST,buttonLIST)
                else
                    gui:newButton("levelList_paste",{"levelList_paste",12,12},x+24+178,y-4,"ll_paste_"..number.."_"..LIST,buttonLIST)
                    gui:newButton("levelList_edit",{"levelList_edit",10,10},x+24+190,y-3,"ll_new_"..number.."_"..LIST,buttonLIST)
                end
            elseif TYPE=="save" then
                gui:newButton("levelList_save",{"levelList_save",12,12},x+24+190,y-4,"ll_save_"..number.."_"..LIST,buttonLIST)
            elseif TYPE=="open" then
                if courseData then gui:newButton("levelList_open",{"levelList_open",12,10},x+24+190,y-3,"ll_open_"..number.."_"..LIST,buttonLIST)
                else gui:newButton("levelList_new",{"levelList_new",10,12},x+24+191,y-4,"ll_new_"..number.."_"..LIST,buttonLIST) end
            end
        end TYPE=editor.levelList or TYPE
        for i=1,8 do local lvl=gui[LIST][i+gui[LIST].scroll-1] and true or false
            refreshRow(hook[1]+31,(hook[2]+20+i*19)+(not editor.active and 8 or 0),addZeros(i+gui[LIST].scroll-1,2),lvl,buttonLIST,TYPE)
        end
    end
    for i=1,#gui.levelLists do
        local levelList,cameraOffsetX,cameraOffsetY=gui[gui.levelLists[i]],titleScreen.active and titleScreen.cameraOffsetX or 0,titleScreen.active and -(titleScreen.cameraOffsetY-8) or 0
        if cameraOffsetX==levelList.x and cameraOffsetY==levelList.y then
            gui["buttonList"..gui.levelLists[i]]={}
            refreshList({levelList.x,levelList.y+(editor.active and 8 or 0)},gui.levelLists[i],"buttonList"..gui.levelLists[i],"titlescreen")
    end end
end

function gui:writeLevel(location,LIST,levelString)
    if levelString then var.store("levelListLocal"..location,levelString)
    else del("levelListLocal"..location) end
    gui:modifyLookupString(location,not not levelString,LIST)
    if gui[LIST] then 
        if levelString then gui[LIST][location]=string2level(levelString,nil,nil,1)
        else gui[LIST][location]=nil end
    end
end

function gui:retrieveLevel(LIST,location)
    if LIST=="levelListLocal" then return var.recall(LIST..location)
    elseif LIST=="nSMMCourseWorld" and COURSEWORLDCOURSES then
        print(location, COURSEWORLDCOURSES[location])
        return COURSEWORLDCOURSES[location]
    else return ext2string(LIST,"levelList"..location)
    end
end

function gui:writeLookupString(LIST,lookupString) var.store(LIST.."D",lookupString) end

function gui:retrieveLookupString(LIST)
    if LIST=="levelListLocal" then return var.recall(LIST.."D")
    else return ext2string(LIST,"levelListD")
    end
end

function gui:createLookupTable(LIST) --if only the var library wasnt so restrictive...
    gui[LIST]={}
    local courseworldavailable = LIST=="nSMMCourseWorld" and COURSEWORLDCOURSES
    print("gui:createLookupTable",LIST,courseworldavailable)
    if courseworldavailable then
        gui[LIST].directory="dummydata"
    else
        gui[LIST].directory=gui:retrieveLookupString(LIST)
    end
    local lvls=courseworldavailable and COURSEWORLDCOURSES or (gui[LIST].directory and gui[LIST].directory:split("-")) or {}
    for i=1,#lvls do
        local iter = courseworldavailable and i or tonumber(lvls[i])
        gui[LIST][tonumber(iter)]=string2level(gui:retrieveLevel(LIST,iter),nil,nil,1)
    end
end

function gui:modifyLookupString(location,ADDorDEL,LIST) --ADDorDEL -> true=add, false=del
    local lvls=gui:retrieveLookupString(LIST)
    lvls=lvls and lvls:split("-") or {}
    for i, v in ipairs(lvls) do
        if tonumber(v)==location then
            if ADDorDEL then return --adding, but already present; no point to continue
            else table.remove(lvls,i) end --removing, and found; list still needs updating
    end end
    if ADDorDEL then table.insert(lvls,tostring(location)) end
    gui:writeLookupString(LIST,table.concat(lvls, "-"))
end

function gui:createPrompt(header,text,buttons,horizontalButtons,disableExit,x,y,w,h) -- eg -->  gui:createPrompt("PAUSE",{"Select Option"},{{"continue",close},{"quit","quit"}},false)
    gui:clearPrompt() switchTimer(false) -- NOTE: set 'buttons' to an int for a text box
    local buttonW={-1} local headerW=22+#header*8 local textW={0} local text=text or {}
    local isInt=type(buttons)=="number" or (type(buttons)==string and buttons:isInteger()) --check if buttons is an integer or a table with an integer
    if not isInt then
        for i=1,#buttons do
            if horizontalButtons then
                buttonW[1]=buttonW[1]+14+#buttons[i][1]*8
            else
                buttonW[i]=10+#buttons[i][1]
        end end
    else buttonW[1]=12+buttons*8 end
    if not w and text then
        for i=1,#text do textW[i]=12+#text[i]*8 end
    end
    w=w or (math.max(headerW or 0,math.max(unpack(textW)),math.max(unpack(buttonW))))
    h=h or 17+#(text)*9+(not isInt and ((horizontalButtons and #buttons>0 and 17) or (#buttons*17)) or 17) --if h is not specified. there are some stupid bodges here
    x=x or (158-math.floor(w/2))
    y=y or (106-math.floor(h/2))
    gui.PROMPT={x,y,w,h,header,{unpack(text)},horizontalButtons,disableExit}
    local offsetX=horizontalButtons and (x+3+(w/2)-(buttonW[1]/2)) or x+3 local offsetY=horizontalButtons and 0 or -2
    if not isInt then
        for i=1,#buttons do
            if horizontalButtons then
                gui:newButton(buttons[i][1],true,offsetX+((10+#buttons[i][1]*8)/2),y+(#text*9)+20,buttons[i][2],"buttonListPrompt") offsetX=offsetX+12+#buttons[i][1]*8
            else
                gui:newButton(buttons[i][1],true,x+(w/2),y+(#text*9)+20+offsetY,buttons[i][2],"buttonListPrompt") offsetY=offsetY+17
            end
        end
    else
        gui.PROMPT.inputLength=buttons
        -- __PC.showKeyboard()
    end
    if not disableExit then gui:newButton("button_close",{"button_close",7,7,0,0},x+w-8,y+2,"close","buttonListPrompt") end

    __PC.SOUND:pauseBGM(true)
end

function gui:clearPrompt()
    gui.PROMPT=false
    gui.buttonListPrompt={}
    switchTimer(true)
    gui.input=""

    __PC.SOUND:pauseBGM(false)
end

function gui:detectPos(offsetX,offsetY,x,y) -- what this does is take the mouse pos and tries to match it to being within the boundary of a button. if it succeeds then it changes the mouse pointer and sets the highlightedButton var to the ID of the button
    x=x or mouse.x y=y or mouse.y
    gui.highlightedButton=false
    local buttonLists=gui.PROMPT and {"buttonListPrompt"} or {"buttonListPrompt","buttonList",unpack(gui.levelListBLs)}
    for i2=1,#buttonLists do
        local offX=buttonLists[i2]=="buttonListPrompt" and 0 or offsetX local offY=buttonLists[i2]=="buttonListPrompt" and 8 or offsetY
        for i=1,#gui[buttonLists[i2]] do
            if checkCollision(x,y,1,1,gui[buttonLists[i2]][i].ix-offX,gui[buttonLists[i2]][i].iy+offY-8,gui[buttonLists[i2]][i].w,gui[buttonLists[i2]][i].h) then
                gui.highlightedButton={i,buttonLists[i2]} cursor.set("hand pointer") return
    end end end
    if not editor.displayedGroup then cursor.set("default") end
end

function gui:drawButtons(gc,offsetX,offsetY,buttonList)
    offsetX=offsetX or 0 offsetY=offsetY or 0
    for i=#gui[buttonList],1,-1 do
        if gui[buttonList][i].TYPE=="img" then
            if not gui.highlightedButton or gui.highlightedButton[1]~=i or gui.highlightedButton[2]~=buttonList then
                gc:drawImage(texs[gui[buttonList][i].data[1]],gui[buttonList][i].ix-offsetX,gui[buttonList][i].iy+offsetY-8) --not highlighted
            else
                gc:drawImage(texs[gui[buttonList][i].data[2][1]],gui[buttonList][i].ix-offsetX+gui[buttonList][i].data[2][2],gui[buttonList][i].iy+offsetY+gui[buttonList][i].data[2][3]-8) --highlighted
            end
        elseif gui[buttonList][i].TYPE=="txtbutton" then
            local x,y,w=gui[buttonList][i].ix-offsetX+6,gui[buttonList][i].iy+offsetY-3,(#gui[buttonList][i].data[1]*8)-2
            gc:setColorRGB(0,0,0)      --outline 3: black
            gc:drawRect(x,y-5,w+1,16)
            gc:setColorRGB(255,255,255)--outline 2: white
            gc:drawRect(x,y-4,w+1,14)
            gc:setColorRGB(108,108,108)--outline 1: light grey
            gc:drawRect(x,y-3,w+1,12)
            gc:setColorRGB(27,27,27)   --internal dark grey
            gc:fillRect(x,y-2,w+2,11)
            gc:drawImage(texs.titlescreen_buttonL,x-5,y-4)
            gc:drawImage(texs.titlescreen_buttonR,x+w+2,y-4)
            drawFont(gc,gui[buttonList][i].data[1],x,y)
        elseif gui[buttonList][i].TYPE=="txtbox" then
            local x,y,w,h=gui[buttonList][i].ix-offsetX,gui[buttonList][i].iy+offsetY-8,(#gui[buttonList][i].data[1]*8*gui[buttonList][i].data[2])+8,(7*gui[buttonList][i].data[2])+8
            drawGUIBox(gc,x-4,y-4,w,h)
            drawFont(gc,gui[buttonList][i].data[1],x,y,nil,nil,nil,gui[buttonList][i].data[2])
end end end

function gui:drawMisc(gc)
    if gui.PROMPT then
        drawGUIBox(gc,gui.PROMPT[1],gui.PROMPT[2],gui.PROMPT[3],gui.PROMPT[4],gui.PROMPT[5],gui.PROMPT[6])
        if gui.PROMPT.inputLength then
            local offsetX=gui.PROMPT[1]+((gui.PROMPT[3]-8-gui.PROMPT.inputLength*8)/2) local offsetY=gui.PROMPT[2]+gui.PROMPT[4]-17
            drawGUIBox(gc,offsetX,offsetY,8+gui.PROMPT.inputLength*8,14)
            drawFont(gc,gui.input,4+offsetX,4+offsetY)
            if framesPassed%(flashingDelay*4)>=flashingDelay*2 then --blinking indicator
                gc:setColorRGB(255,255,255)
                gc:fillRect(4+offsetX+#gui.input*8,4+offsetY,2,7)
    end end end
    if gui.TEXT then gui.TEXToffset=gui.TEXToffset or 0
        gui.TEXT=type(gui.TEXT)=="string" and {gui.TEXT} or gui.TEXT
        for i=1,#gui.TEXT do
            drawFont(gc,gui.TEXT[i], nil, 206-(i*10)+gui.TEXToffset,"centre",0,true)
    end end
    gui.TEXT={} gui.TEXToffset=0
end

function gui:newButton(param1,param2,x,y,action,buttonList) -- guide: ("asdf",{"asdf_frame2",w,h,offsetX,offsetY},...) <- an image button, when highlighted displays image in param2 ; ("asdf",true,...) <- makes a text button ; ("asdf",false,...) <- this is not actually a button, just a text box
    local button={} local w=0 local h=0 local buttonList=buttonList or "buttonList"
    if type(param2)=="table" then   button.TYPE="img"          -- it's an image button
        w=param2[2] or 0 h=param2[3] or 0
        param2={param2[1],param2[4] or 0,param2[5] or 0}
    elseif param2==true then        button.TYPE="txtbutton"    -- it's a text button
        w=10+(#param1*8) h=17 x=x-(w/2) y=y-5
    else                            button.TYPE="txtbox"       -- it's a text box
        local w=(#param1*8*param2)+8 x=x-((w)/2)
    end
    button.data={param1,param2} button.ix=x button.iy=y button.w=w button.h=h button.action=action
    table.insert(gui[buttonList],button)
end