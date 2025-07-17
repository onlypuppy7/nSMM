

function gui:click(action) -- actions relating to buttons and prompts go here. also some small tasks too.
    if gui.highlightedButton or action then
        action=action or gui[gui.highlightedButton[2]][gui.highlightedButton[1]]["action"]
        print("gui:click",action)

        local sound = "menuselect"

        switchTimer(true) --switch timer back on; pay attention to this, all the buttons benefit due to performing some kind of change but future ones may not
        if string.sub(action,1,1)=="m" then --screen moving time
            local v=(string.sub(action,2,#action)):split(",")
            titleScreen:moveScreens(v[1],v[2])
            sound="mapbeep"
        elseif action=="create" then
            editor:generate(defaultCourse)
            editor.active=true editor.file=false
            playStage.active=false
            titleScreen.active=false
        elseif action=="editor_new" then
            gui:click("create") editor.file=false editor:updateToolpalette()
        elseif action=="editor_open" then editor.levelList="open"
        elseif action=="editor_save" then
            if editor.file then gui:click("ll_save_"..editor.file.."_levelListLocal")
            else gui:click("editor_saveas")
            end
        elseif action=="editor_saveas" then editor.levelList="save"
        elseif action=="editor_close" and editor.file then editor.notification={"CLOSED SLOT "..editor.file.."!"}
            editor.file=false editor:updateToolpalette()
        elseif action=="coursename" then
            level.current.courseName=gui.input or "my course"
            editor:updateToolpalette()
        elseif action=="time" and gui.input:isInteger() then
            toolpaletteSelection("Time",tonumber(gui.input)-level.current.TIME)
        elseif action=="length" and gui.input:isInteger() then
            toolpaletteSelection("⇥Length",tonumber(gui.input)-level.current.END)
        elseif action=="author" then
            var.store("author",gui.input) username=gui.input
        elseif string.sub(action,1,2)=="ll" then
            local action=action:split("_")
            action[3]=tonumber(action[3])
            if     action[2]=="play"   then
                playStage:generate(gui:retrieveLevel(action[4],action[3]),true)
                playStage.active=true titleScreen.active=false editor.file=(action[4]=="levelListLocal") and action[3] or nil
            elseif action[2]=="edit"   then
                editor:generate(gui:retrieveLevel(action[4],action[3]))
                editor.active=true playStage.active=false titleScreen.active=false
                if (action[4]=="levelListLocal") then
                    editor.file=action[3] editor.notification={"OPENED FROM SLOT "..action[3].."!"}
                end
            elseif action[2]=="copy"   then
                clipboard.addText(gui:retrieveLevel(action[4],action[3]))
                gui:createPrompt("DONE!",{"LEVEL COPIED","TO CLIPBOARD!"},{{"OK","close"}},nil,nil,false)
                sound="correct"
            elseif action[2]=="delete" then
                action[2]="deleteconfirm"
                gui:createPrompt("DELETE LEVEL",{"REALLY DELETE?","LEVEL DATA WILL", "BE DELETED!"},{{"CONFIRM",table.concat(action,"_")},{"CANCEL","close"}},true,false)
                sound="incorrect"
            elseif action[2]=="deleteconfirm" then
                gui:writeLevel(action[3],action[4],false)
                gui:clearPrompt() gui:refreshLevelList()
                sound="correct"
            elseif action[2]=="paste"  then
                local PASTE=clipboard.getText() or "err"
                if string.sub(PASTE,1,1)=="<" then --very crude for now
                    gui:writeLevel(action[3],action[4],PASTE)
                    gui:createPrompt("DONE!",{"LEVEL IMPORTED","FROM CLIPBOARD!"},{{"OK","close"}},nil,nil,false)
                    sound="correct"
                else
                    gui:createPrompt("ERROR!",{"LEVEL IMPORTING","FAILED! CHECK TO","SEE IF THE LEVEL","CODE IS VALID."},{{"OK","close"}})
                    sound="incorrect"
                end gui:refreshLevelList()
            --IN EDITOR--
            elseif action[2]=="new"    then
                gui:click("create") editor.levelList=false editor.file=(action[4]=="levelListLocal") and action[3] or nil --editor:updateToolpalette()
            elseif action[2]=="open"   then
                action[2]="openconfirm"
                if gui[action[4]][action[3]] then
                    gui:createPrompt("WARNING!",{"CURRENT UNSAVED DATA WILL","BE LOST!"},{{"CONFIRM",table.concat(action,"_")},{"CANCEL","close"}},true,nil,false)
                end
            elseif action[2]=="openconfirmsave" then
            elseif action[2]=="openconfirm" then
                gui:clear() editor.levelList=false
                editor:generate(gui:retrieveLevel(action[4],action[3]) or defaultCourse)
                if (action[4]=="levelListLocal") then
                    editor.file=action[3] editor.notification={"OPENED FROM SLOT "..action[3].."!"}
                end editor:updateToolpalette()
            elseif action[2]=="save"   then
                action[2]="saveconfirm"
                if gui[action[4]][action[3]] and tonumber(action[3])~=tonumber(editor.file) then
                    gui:createPrompt("WARNING!",{"DATA ALREADY PRESENT IN","SLOT "..tostring(action[3]).."! CONTINUING WILL","OVERWRITE THIS LEVEL."},{{"CONFIRM",table.concat(action,"_")},{"CANCEL","close"}},true,nil,false)
                else gui:click(table.concat(action,"_"))
                end
            elseif action[2]=="saveconfirm" then
                gui:writeLevel(action[3],action[4],level2string(level.current)) gui:clear() editor.levelList=false
                editor.file=(action[4]=="levelListLocal") and action[3] or nil editor.notification={"SAVED TO SLOT "..action[3].."!"} editor:updateToolpalette()
            elseif action[2]=="close" then
                gui:clear() editor.levelList=false
            end
            -------------
        elseif string.sub(action,1,6)=="scroll" then local scroll=gui[string.sub(action,8,#action)].scroll
            if string.sub(action,7,7)=="U" and scroll>1 then
                gui[string.sub(action,8,#action)].scroll=scroll-1
            elseif string.sub(action,7,7)=="D" and scroll<92 then gui[string.sub(action,8,#action)].scroll=scroll+1 end
            gui:refreshLevelList()
            sound="menumove"
        elseif string.sub(action,1,7)=="gscroll" then local scroll=editor.displayedGroup["scroll"]
            if string.sub(action,8,8)=="U" then editor.displayedGroup["scroll"]=editor.displayedGroup["scroll"]-1
            elseif string.sub(action,8,8)=="D" then editor.displayedGroup["scroll"]=editor.displayedGroup["scroll"]+1 end
            if editor.displayedGroup["scroll"]<0 then editor.displayedGroup["scroll"]=0
            elseif editor.displayedGroup["scroll"]>(editor.displayedGroup["rows"]-5) then editor.displayedGroup["scroll"]=(editor.displayedGroup["rows"]-5) end
            sound="menumove"
        elseif action=="initimport" then
            gui:click("importdataconfirm")
            if username=="" then --failed
                gui:createPrompt("WELCOME!",{"VALID RESTORE DATA WAS NOT FOUND","IN YOUR CLIPBOARD. EITHER CLICK","'EXPORT DATA' IN YOUR PREVIOUS VERSION","OR, IF YOU HAVE A PRE 1.3.0A VERSION,","USE THE NSMM LEGACY DATA EXTRACTOR","TO CONTINUE USING YOUR DATA."},{{"IMPORT","initimport"},{"NEW DATA","initnew"}},true,true)
            end
            sound="yoshiegg"
        elseif action=="initnew" then
            gui:createPrompt("WELCOME!",{"YOU DO NOT HAVE AN AUTHOR NAME","SET. TYPE IN THE NAME YOU WOULD","LIKE TO BE ASSOCIATED WITH","YOUR LEVELS AND PRESS ENTER!"},12,"author",true)
            sound="incorrect"
        elseif action=="exportdata" then
            local vars,STRING=var.list(),"Γ"
            for i=1,#vars do
                STRING=STRING..vars[i].."Γ"..var.recall(vars[i]).."Γ"
            end clipboard.addText(STRING)
            gui:createPrompt("COMPLETE",{"SAVED DATA TO CLIPBOARD,","READY FOR IMPORTING!"},{{"OK","close"}},true,false)
            sound="correct"
        elseif action=="importdata" then
            gui:createPrompt("IMPORT DATA",{"REALLY IMPORT?","ALL SAVED LEVEL DATA", "WILL BE LOST!"},{{"DELETE","importdataconfirm"},{"BACK","close"}},true,false)
            sound="incorrect"
        elseif action=="importdataconfirm" then
            local STRING=clipboard.getText()
            if type(STRING)=="string" and string.sub(STRING,1,2)=="Γ" then --probably legit?
                gui:click("clearlevelsconfirm")
                STRING=STRING:split("Γ")
                for i=1,#STRING,2 do
                    local varName,content=STRING[i],STRING[i+1]
                    var.store(varName,content)
                    if varName=="author" then username=content end
                end
                gui:clearPrompt() titleScreen:init()
                gui:createPrompt("SUCCESS!",{"SAVE DATA RESTORED","FROM CLIPBOARD."},{{"OK","close"}},true,false)
            else
                gui:createPrompt("ERROR",{"SAVE DATA NOT FOUND","IN CLIPBOARD."},{{"OK","close"}},true,false)
            end
            sound="correct"
        elseif action=="clearlevels" then
            gui:createPrompt("CLEAR LEVELS",{"REALLY DELETE?","ALL SAVED LEVEL DATA", "WILL BE LOST!"},{{"DELETE","clearlevelsconfirm"},{"BACK","close"}},true,false)
            sound="incorrect"
        elseif action=="clearlevelsconfirm" then
            for i=1,99 do gui:writeLevel(i,"levelListLocal") end del("levelListLocalD")
            gui:createPrompt("DONE!",{"LEVEL DATA CLEARED!","IF YOU WOULD LIKE TO RESTORE", "THEN REOPEN WITHOUT SAVING.","OTHERWISE SAVE TO","CONFIRM CHANGES."},{{"OK","close"}},true,false)
            sound="correct"
        elseif action=="debuginfo" then
            gui:createPrompt("INFO ABOUT DEBUG MODE",{"DEBUG MODE ACTIVATES SOME EXTRA","KEYBINDS AND ON-SCREEN INFORMATION.", "HOWEVER THE EXTRA SHORTCUTS ARE","NOT TESTED AND MAY CRASH OR CAUSE"," UNINTENDED BEHAVIOUR! PLEASE DON'T","REPORT BUGS WHILE IN DEBUG MODE :)"},{{"OK","close"}},true,false)
        elseif action=="clearall" then
            gui:createPrompt("CLEAR ALL DATA",{"ALL SAVED DATA SUCH AS", "AUTHOR NAME AND SAVED","LEVELS WILL BE LOST!"},{{"DELETE","clearall2"},{"BACK","close"}},true,false)
            sound="incorrect"
        elseif action=="clearall2" then
            gui:createPrompt("REALLY DELETE?",{"CLICK DELETE TO CONFIRM.", "IF YOU WANT TO RESTORE","AFTER DELETING, THEN REOPEN","THE DOCUMENT WITHOUT SAVING!"},{{"DELETE","clearallconfirm"},{"BACK","close"}},true,false)
            sound="incorrect"
        elseif action=="clearallconfirm" then
            local vars=var.list()
            for i=1,#vars do del(vars[i]) end username=""
            gui:clearPrompt() titleScreen:init()
            sound="correct"
        elseif string.sub(action,1,7)=="delwarp" then
            table.remove(level.current.pipeData,tonumber(action:split("_")[2]))
            editor:setDisplayedGroup(false) gui:clearPrompt()
        elseif action=="enterauthor" then
            gui:createPrompt("ENTER NEW AUTHOR",{"TYPE BELOW TO SET A","NEW AUTHOR NAME TO BE","ASSOCIATED WITH YOUR","LEVELS AND PRESS ENTER"},12,"author",false)
        elseif action=="close" or action=="unpause" then
            gui:clearPrompt()
            if editor.displayedGroup then editor:setDisplayedGroup(editor.displayedGroup) end
            sound = false
            if action=="unpause" then sound="pause" end
        elseif action=="play_retry" then
            mario:kill() gui:clearPrompt()
        elseif action=="play_edit" then
            playStage:charIn("edit")
            sound="redcoin2"
        elseif action=="quit" then
            if editor.active and editor.file then gui:createPrompt("QUIT",{"REALLY QUIT?","UNSAVED LEVEL DATA", "WILL BE LOST!"},{{"SAVE AND QUIT","quitconfirmsave"},{"QUIT WITHOUT SAVING","quitconfirm"},{"BACK","close"}},false,false,nil,nil,174)
            else gui:createPrompt("QUIT",{"REALLY QUIT?","UNSAVED LEVEL DATA", "WILL BE LOST!"},{{"QUIT","quitconfirm"},{"BACK","close"}},true,false)
            end
            sound="incorrect"
        elseif action=="quitconfirmsave" then
            gui:click("ll_save_"..editor.file.."_levelListLocal") gui:click("quitconfirm")
        elseif string.sub(action,1,11)=="quitconfirm" then
            titleScreen:reset()
            titleScreen.active=true
            playStage.active=false
            editor.file=false
            sound=nil
        elseif action=="recoveryes" then
            editor:generate(recoveredLevelString)
            editor.active=true
            titleScreen.active=false
            del("recoveredLevel")
            sound="redcoin2"
        end
        gui.highlightedButton=false
        cursor.set("default")

        __PC.SOUND:sfx(sound)
    end
end