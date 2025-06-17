notFinal=true
--[[
    RELEASE CHECKLIST: 1.4.0a
        # versText
        # versNum
        - rename editor
        - clear data
        - check changelog date
        - remove checklist
]]

versText="1.4.0a"
versNum=56
platform.apilevel = '2.2'
debug=false
despook=0

-- (c) onlypuppy7/chalex0 2025
--This code has been indented in places where it may not look necessary, this is in order to be able to collapse entire code categories in IDEs such as VSCode. Indents do not affect syntax in Lua :>

--reminder for myself:
--collapsing all code in VSCode shortcut: Ctrl+K Ctrl+0
--expanding all code in VSCode shortcut: Ctrl+K Ctrl+J

--------------------------
-----TEXTURE LIBRARY------
--------------------------

    texs={}

    require("data.textures-all")

--------------------------
----INITIALISING VARS-----
--------------------------

    require("core.init")
    extendStandard()
    initialiseVARS()

--------------------------
----GENERAL FUNCTIONS-----
--------------------------

    -- Collision detection function; --credit to Love2D
    function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2) -- Returns true if two boxes overlap, false if they don't;
        return x1 < x2+w2 and
            x2 < x1+w1 and
            y1 < y2+h2 and
            y2 < y1+h1
    end

    function drawSlantedRect(gc,xyw) --this is literally only for the OP7 logo at startup...
        gc:drawLine(xyw[1],xyw[2]+xyw[3],xyw[1]+xyw[3],xyw[2]) --you thought i'd explain this??
        gc:drawLine(xyw[1]+xyw[3],xyw[2],xyw[1]+2*xyw[3],xyw[2]+xyw[3])
        gc:drawLine(xyw[1]+2*xyw[3],xyw[2]+xyw[3],xyw[1]+xyw[3],xyw[2]+2*xyw[3])
        gc:drawLine(xyw[1]+xyw[3],xyw[2]+2*xyw[3],xyw[1],xyw[2]+xyw[3])
    end

    function pol2binary(num) --returns 0 if negative, 1 if positive
        if num==0 then return 0
        else return ((num/math.abs(num))+1)/2
    end end

    function sign(num) --returns -1 if negative, 1 if positive
        if num==0 then return 1
        else return (num/math.abs(num))
    end end

    function timer2rainbow(gc, hue, speed)
        local saturation=0.7 local lightness=0.5
        local chroma = (1 - math.abs(2 * lightness - 1)) * saturation
        local h = ((hue*speed)%360)/60
        local x =(1 - math.abs(h % 2 - 1)) * chroma
        local r, g, b = 0, 0, 0
        if h < 1 then     r,g,b=chroma,x,0
        elseif h < 2 then r,g,b=x,chroma,0
        elseif h < 3 then r,g,b=0,chroma,x
        elseif h < 4 then r,g,b=0,x,chroma
        elseif h < 5 then r,g,b=x,0,chroma
        else r,g,b=chroma,0,x
        end
        local m = lightness - chroma/2
        gc:setColorRGB((r+m)*255,(g+m)*255,(b+m)*255)
    end

    function addZeros(input, length)
        return tostring(input):padStart(length, '0')
    end
    
    function toBinary(num,bits)
        bits = bits or math.max(1, select(2, math.frexp(num)))
        local t = {}    
        for b = bits, 1, -1 do
            t[b] = math.fmod(num, 2)
            num = math.floor((num - t[b]) / 2)
        end return table.concat(t)
    end

    require("core.imagehelpers")

--------------------------
---------EVENTS-----------
--------------------------

    require("core.events")

---------------------------
-----PROGRAM FUNCTIONS-----
---------------------------

    require("core.plotmath")

    --[[function pixel2exactPixel(x,y) --useless or something idk
        local v={pixel2plot(xPos-playStage.cameraOffset,yPos+(1))[1],pixel2plot(xPos-playStage.cameraOffset,yPos+(1))[2]}
        v = plot2pixel(v[1],v[2],true)[2]+16
        return {v[1],v[2]-12}
    end]]

    require("core.levelserialise")

    require("core.font")

    function switchTimer(state)
        if state==nil then --fallback, doubt however that it is (or ever will be) used :p
            switchTimer(not timerState)
        else
            if state==true and not timerState==true then --full speed
                timer.stop() timerState=state
                timer.start(0.04)
            elseif state==false and not timerState==false then --safe sleep mode
                timer.stop() timerState=state
                timer.start(0.15) --from my testing, this is slow enough to where the page doesnt freeze when turning off
            end
    end end

    function sTimer(time)  return playStage.framesPassed+time  end --set timer vars
    function cTimer(timer) return timer-playStage.framesPassed end --calculate timer
    function gTimer(timer) return (cTimer(timer)<0)            end --goal timer..? cant think of what to name it

    require("core.datastorage")

--------------------------
-------BLOCK INDEX--------
--------------------------
addBlock=class()

    function addBlock:init(id,name,solid,textureID) --textureID can also be a list, eg {1,1,1,1,2,3} for an animation sequence
        --print(id,name,solid,#textureID)
        lastAdded=id
        blockIndex[lastAdded]={["solid"]=solid,["name"]=name,["texture"]=textureID}
        --set default
        local props = blockIndex[lastAdded]

        if props["semisolid"]== nil then      props["semisolid"]=false end      --semisolid (mario must be above the top eg mushrooms): in arrangement NESW (north,east,south,west) where a 1 represents that it is solid on that side and 0 means the side is passable
        if props["containing"]== nil then     props["containing"]=false end     --contains coins, powerup, vine or star
        if props["icon"]== nil then           props["icon"]=false end           --an icon to draw in the editor, string or table defining the offset of the icon, eg {"Coin",0,0}
        if props["bumpable"]== nil then       props["bumpable"]={false} end     --ie moves when hit (bricks, question marks), second arg for texture to display during animation (if true uses first frame), third arg for what to replace it with once animation finished
        if props["breakable"]== nil then      props["breakable"]=false end      --creates brick particles and disappears if super or fire mario
        if props["entityonly"]== nil then     props["entityonly"]=false end     --only entities can pass through
        if props["marioonly"]== nil then      props["marioonly"]=false end      --only mario can pass through
        if props["coin"]== nil then           props["coin"]=false end           --it is a coin, that is all
        if props["invisiblock"]== nil then    props["invisiblock"]=false end    --can still be bumped, but passed through from other angles
        if props["theme"]== nil then          props["theme"]={nil} end          --changes appearance based on the theme it is in
        if props["editor"]== nil then         props["editor"]=false end         --changes appearance in editor to the id
        if props["damage"]== nil then         props["damage"]=false end         --hurts mario (spikes)
        if props["kill"]== nil then           props["kill"]=false end           --kills mario (lava)
        if props["ceiling"]== nil then        props["ceiling"]=false end        --cannot be jumped over when on y=13
        if props["eventswitch"]== nil then    props["eventswitch"]={false} end  --switch block with another when event conditions are met. args: 1. the event name, 2. the event state, 3. the new block ID
        if props["pushV"]== nil then          props["pushV"]=0 end              --will push things in the X direction when stood on, eg conveyor belts
        if props["animSpeed"]== nil then      props["animSpeed"]=4 end          --animation speed, default is 4 frames per animation frame
    end

    function addBlock:attribute(property,val) --eg semisolid, containing, bumpable,
        blockIndex[lastAdded][property]=val
    end

    function addBlock:addThemeTexture(themeNo,texture)
        blockIndex[lastAdded]["theme"][themeNo]=texture
    end

    --addBlock(id,name,solid,textureID)
    addBlock(1337,"Air (Editor)",false,{nil}) -- Batprime11: 1337 B)
        addBlock:addThemeTexture(0,{"Air0"})
        addBlock:addThemeTexture(1,{"Air1"})
        addBlock:addThemeTexture(2,{"Air1"})
        addBlock:addThemeTexture(3,{"Air1"})
    addBlock(1338,"Invisible Block (Editor)",false,{nil})
        addBlock:addThemeTexture(0,{"InvisibleBlock0"})
        addBlock:addThemeTexture(1,{"InvisibleBlock1"})
        addBlock:addThemeTexture(2,{"InvisibleBlock1"})
        addBlock:addThemeTexture(3,{"InvisibleBlock1"})
        addBlock:addThemeTexture(99,{"InvisibleBlock1"})
    addBlock(1339,"Barrier (Editor)",false,{"Barrier"})

    addBlock(0,"Air",false,{nil})
        addBlock:attribute("editor",1337)
    addBlock(1,"Ground",true,{"Ground"})
        addBlock:addThemeTexture(1,{"GroundUnderground"})
        addBlock:addThemeTexture(3,{"GroundCastle"})
        addBlock:attribute("ceiling",true)
    addBlock(2,"Mystery Box (Coin)",true,{"MysteryBox0","MysteryBox0","MysteryBox0","MysteryBox1","MysteryBox2","MysteryBox1"})
        addBlock:addThemeTexture(1,{"MysteryBox0Underground","MysteryBox0Underground","MysteryBox0Underground","MysteryBox1Underground","MysteryBox2Underground","MysteryBox1Underground"})
        addBlock:addThemeTexture(3,{"MysteryBox0Castle","MysteryBox0Castle","MysteryBox0Castle","MysteryBox1Castle","MysteryBox2Castle","MysteryBox1Castle"})
        addBlock:attribute("containing","coin")
        addBlock:attribute("icon","icon_coin")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
    addBlock(3,"Brick",true,{"Brick"})
        addBlock:addThemeTexture(1,{"BrickUnderground"})
        addBlock:addThemeTexture(3,{"BrickCastle"})
        addBlock:attribute("breakable",true)
        addBlock:attribute("bumpable",{true,"Brick",3})
    addBlock(4,"Coin",false,{"Coin1","Coin1","Coin1","Coin2","Coin3","Coin2"})
        addBlock:attribute("coin",true)
    addBlock(5,"Empty Block",true,{"EmptyBlock"})
        addBlock:addThemeTexture(1,{"EmptyBlockUnderground"})
        addBlock:addThemeTexture(3,{"EmptyBlockCastle"})
    addBlock(6,"Bridge",false,{"Bridge"})
        addBlock:attribute("semisolid","1000")
    addBlock(7,"Entity Only Block",false,{"EntityOnly2","EntityOnly2","EntityOnly2","EntityOnly1","EntityOnly1","EntityOnly1"})
        addBlock:attribute("entityonly",true)
    addBlock(8,"Mario Only Block",true,{"MarioOnly2","MarioOnly2","MarioOnly2","MarioOnly1","MarioOnly1","MarioOnly1"})
        addBlock:attribute("marioonly",true)
    addBlock(9,"Hard Block",true,{"HardBlock"})
        addBlock:addThemeTexture(1,{"HardBlockUnderground"})
        addBlock:addThemeTexture(3,{"HardBlockCastle"})
        addBlock:attribute("ceiling",true)
    addBlock(10,"Invisible Block (Coin)",false,{nil})
        addBlock:attribute("invisiblock",true)
        addBlock:attribute("containing","coin")
        addBlock:attribute("icon","icon_coin")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
        addBlock:attribute("editor",1338)
    addBlock(11,"Cloud Block",false,{"Cloud"})
        addBlock:attribute("semisolid","1000")
    addBlock(12,"Green Mushroom (L)",false,{"MushG1"})
        addBlock:attribute("semisolid","1000")
    addBlock(13,"Green Mushroom (M)",false,{"MushG2"})
        addBlock:attribute("semisolid","1000")
    addBlock(14,"Green Mushroom (R)",false,{"MushG3"})
        addBlock:attribute("semisolid","1000")
    addBlock(15,"Red Mushroom (L)",false,{"MushR1"})
        addBlock:attribute("semisolid","1000")
    addBlock(16,"Red Mushroom (M)",false,{"MushR2"})
        addBlock:attribute("semisolid","1000")
    addBlock(17,"Red Mushroom (R)",false,{"MushR3"})
        addBlock:attribute("semisolid","1000")
    addBlock(18,"Mushroom Stem (Top)",false,{"MushTop"})
    addBlock(19,"Mushroom Stem",false,{"MushStem"})

    addBlock(20,"Mystery Box (Mushroom)",true,{"MysteryBox0","MysteryBox0","MysteryBox0","MysteryBox1","MysteryBox2","MysteryBox1"})
        addBlock:addThemeTexture(1,{"MysteryBox0Underground","MysteryBox0Underground","MysteryBox0Underground","MysteryBox1Underground","MysteryBox2Underground","MysteryBox1Underground"})
        addBlock:addThemeTexture(3,{"MysteryBox0Castle","MysteryBox0Castle","MysteryBox0Castle","MysteryBox1Castle","MysteryBox2Castle","MysteryBox1Castle"})
        addBlock:attribute("containing","mushroom")
        addBlock:attribute("icon","icon_mushroom")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
    addBlock(21,"Mystery Box (Fireflower)",true,{"MysteryBox0","MysteryBox0","MysteryBox0","MysteryBox1","MysteryBox2","MysteryBox1"})
        addBlock:addThemeTexture(1,{"MysteryBox0Underground","MysteryBox0Underground","MysteryBox0Underground","MysteryBox1Underground","MysteryBox2Underground","MysteryBox1Underground"})
        addBlock:addThemeTexture(3,{"MysteryBox0Castle","MysteryBox0Castle","MysteryBox0Castle","MysteryBox1Castle","MysteryBox2Castle","MysteryBox1Castle"})
        addBlock:attribute("containing","fireflower")
        addBlock:attribute("icon","icon_fireflower")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
    addBlock(22,"Mystery Box (Progressive)",true,{"MysteryBox0","MysteryBox0","MysteryBox0","MysteryBox1","MysteryBox2","MysteryBox1"})
        addBlock:addThemeTexture(1,{"MysteryBox0Underground","MysteryBox0Underground","MysteryBox0Underground","MysteryBox1Underground","MysteryBox2Underground","MysteryBox1Underground"})
        addBlock:addThemeTexture(3,{"MysteryBox0Castle","MysteryBox0Castle","MysteryBox0Castle","MysteryBox1Castle","MysteryBox2Castle","MysteryBox1Castle"})
        addBlock:attribute("containing","Pfireflower")
        addBlock:attribute("icon","icon_Pfireflower")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
    addBlock(23,"Mystery Box (Star)",true,{"MysteryBox0","MysteryBox0","MysteryBox0","MysteryBox1","MysteryBox2","MysteryBox1"})
        addBlock:addThemeTexture(1,{"MysteryBox0Underground","MysteryBox0Underground","MysteryBox0Underground","MysteryBox1Underground","MysteryBox2Underground","MysteryBox1Underground"})
        addBlock:addThemeTexture(3,{"MysteryBox0Castle","MysteryBox0Castle","MysteryBox0Castle","MysteryBox1Castle","MysteryBox2Castle","MysteryBox1Castle"})
        addBlock:attribute("containing","star")
        addBlock:attribute("icon","icon_star")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
    addBlock(24,"Mystery Box (1-Up)",true,{"MysteryBox0","MysteryBox0","MysteryBox0","MysteryBox1","MysteryBox2","MysteryBox1"})
        addBlock:addThemeTexture(1,{"MysteryBox0Underground","MysteryBox0Underground","MysteryBox0Underground","MysteryBox1Underground","MysteryBox2Underground","MysteryBox1Underground"})
        addBlock:addThemeTexture(3,{"MysteryBox0Castle","MysteryBox0Castle","MysteryBox0Castle","MysteryBox1Castle","MysteryBox2Castle","MysteryBox1Castle"})
        addBlock:attribute("containing","mushroom1up")
        addBlock:attribute("icon","icon_mushroom1up")  --now the theme texture method is seeming a bit dated
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
    addBlock(25,"Mystery Box (Multi-Coin)",true,{"MysteryBox0","MysteryBox0","MysteryBox0","MysteryBox1","MysteryBox2","MysteryBox1"})
        addBlock:addThemeTexture(1,{"MysteryBox0Underground","MysteryBox0Underground","MysteryBox0Underground","MysteryBox1Underground","MysteryBox2Underground","MysteryBox1Underground"})
        addBlock:addThemeTexture(3,{"MysteryBox0Castle","MysteryBox0Castle","MysteryBox0Castle","MysteryBox1Castle","MysteryBox2Castle","MysteryBox1Castle"})
        addBlock:attribute("containing","multicoin_2")
        addBlock:attribute("icon","icon_multicoin")
        addBlock:attribute("bumpable",{true,"MysteryBox0",26})
    addBlock(26,"Mystery Box (Infinite-Coin)",true,{"MysteryBox0","MysteryBox0","MysteryBox0","MysteryBox1","MysteryBox2","MysteryBox1"})
        addBlock:addThemeTexture(1,{"MysteryBox0Underground","MysteryBox0Underground","MysteryBox0Underground","MysteryBox1Underground","MysteryBox2Underground","MysteryBox1Underground"})
        addBlock:addThemeTexture(3,{"MysteryBox0Castle","MysteryBox0Castle","MysteryBox0Castle","MysteryBox1Castle","MysteryBox2Castle","MysteryBox1Castle"})
        addBlock:attribute("containing","coin")
        addBlock:attribute("icon","icon_coin")
        addBlock:attribute("bumpable",{true,"MysteryBox0",26})

    addBlock(28,"Blaster Body",true,{"BlasterBody"})
    addBlock(29,"Blaster Top",true,{"BlasterTop"})

    addBlock(30,"Brick (Coin)",true,{"Brick"})
        addBlock:addThemeTexture(1,{"BrickUnderground"})
        addBlock:addThemeTexture(3,{"BrickCastle"})
        addBlock:attribute("containing","coin")
        addBlock:attribute("icon","icon_coin")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
    addBlock(31,"Brick (Mushroom)",true,{"Brick"})
        addBlock:addThemeTexture(1,{"BrickUnderground"})
        addBlock:addThemeTexture(3,{"BrickCastle"})
        addBlock:attribute("containing","mushroom")
        addBlock:attribute("icon","icon_mushroom")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
    addBlock(32,"Brick (Fireflower)",true,{"Brick"})
        addBlock:addThemeTexture(1,{"BrickUnderground"})
        addBlock:addThemeTexture(3,{"BrickCastle"})
        addBlock:attribute("containing","fireflower")
        addBlock:attribute("icon","icon_fireflower")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
    addBlock(33,"Brick (Progressive)",true,{"Brick"})
        addBlock:addThemeTexture(1,{"BrickUnderground"})
        addBlock:addThemeTexture(3,{"BrickCastle"})
        addBlock:attribute("containing","Pfireflower")
        addBlock:attribute("icon","icon_Pfireflower")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
    addBlock(34,"Brick (Star)",true,{"Brick"})
        addBlock:addThemeTexture(1,{"BrickUnderground"})
        addBlock:addThemeTexture(3,{"BrickCastle"})
        addBlock:attribute("containing","star")
        addBlock:attribute("icon","icon_star")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
    addBlock(35,"Brick (1-Up)",true,{"Brick"})
        addBlock:addThemeTexture(1,{"BrickUnderground"})
        addBlock:addThemeTexture(3,{"BrickCastle"})
        addBlock:attribute("containing","mushroom1up")
        addBlock:attribute("icon","icon_mushroom1up")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
    addBlock(36,"Brick (Multi-Coin)",true,{"Brick"})
        addBlock:addThemeTexture(1,{"BrickUnderground"})
        addBlock:addThemeTexture(3,{"BrickCastle"})
        addBlock:attribute("containing","multicoin_30")
        addBlock:attribute("icon","icon_multicoin")
        addBlock:attribute("bumpable",{true,"Brick",39})
    addBlock(39,"Brick (Infinite-Coin)",true,{"Brick"})
        addBlock:addThemeTexture(1,{"BrickUnderground"})
        addBlock:addThemeTexture(3,{"BrickCastle"})
        addBlock:attribute("containing","coin")
        addBlock:attribute("icon","icon_coin")
        addBlock:attribute("bumpable",{true,"Brick",39})

    addBlock(40,"Pipe Top - North (L)",true,{"Pipe_Top_NL"})
    addBlock(41,"Pipe Top - North (R)",true,{"Pipe_Top_NR"})
    addBlock(42,"Pipe Top - South (L)",true,{"Pipe_Top_SL"})
    addBlock(43,"Pipe Top - South (R)",true,{"Pipe_Top_SR"})
    addBlock(44,"Pipe Top - East (L)",true,{"Pipe_Top_EL"})
    addBlock(45,"Pipe Top - East (R)",true,{"Pipe_Top_ER"}) 
    addBlock(46,"Pipe Top - West (L)",true,{"Pipe_Top_WL"}) 
    addBlock(47,"Pipe Top - West (R)",true,{"Pipe_Top_WR"}) 
    addBlock(48,"Pipe Body - Vertical (L)",true,{"Pipe_Body_VertL"}) 
    addBlock(49,"Pipe Body - Vertical (R)",true,{"Pipe_Body_VertR"}) 
    addBlock(50,"Pipe Body - Horizontal (L)",true,{"Pipe_Body_HoriL"})
    addBlock(51,"Pipe Body - Horizontal (R)",true,{"Pipe_Body_HoriR"})
    addBlock(52,"Pipe Connector - North (L)",true,{"Pipe_Connector_NL"})
    addBlock(53,"Pipe Connector - North (R)",true,{"Pipe_Connector_NR"})
    addBlock(54,"Pipe Connector - South (L)",true,{"Pipe_Connector_SL"})
    addBlock(55,"Pipe Connector - South (R)",true,{"Pipe_Connector_SR"})
    addBlock(56,"Pipe Connector - East (L)",true,{"Pipe_Connector_EL"})
    addBlock(57,"Pipe Connector - East (R)",true,{"Pipe_Connector_ER"})
    addBlock(58,"Pipe Connector - West (L)",true,{"Pipe_Connector_WL"})
    addBlock(59,"Pipe Connector - West (R)",true,{"Pipe_Connector_WR"})

    addBlock(60,"Semisolid (L)",false,{"Leaves1"})
        addBlock:attribute("semisolid","1000")
    addBlock(61,"Semisolid (M)",false,{"Leaves2"})
        addBlock:attribute("semisolid","1000")
    addBlock(62,"Semisolid (R)",false,{"Leaves3"})
        addBlock:attribute("semisolid","1000")
    addBlock(63,"Semisolid BG",false,{"SemiSolidBG"})
    --decorations part 1
    addBlock(65,"Hill - 1",false,{"Hill1"})
    addBlock(66,"Hill - 2",false,{"Hill2"})
    addBlock(67,"Hill - 3",false,{"Hill3"})
    addBlock(68,"Hill - 4",false,{"Hill4"})
    addBlock(69,"Hill - 5",false,{"Hill5"})
    addBlock(70,"Hill - 6",false,{"Hill6"})
    addBlock(71,"Cloud - 1",false,{"Cloud1"})
    addBlock(72,"Cloud - 2",false,{"Cloud2"})
    addBlock(73,"Cloud - 3",false,{"Cloud3"})
    addBlock(74,"Cloud - 4",false,{"Cloud4"})
    addBlock(75,"Cloud - 5",false,{"Cloud5"})
    addBlock(76,"Cloud - 6",false,{"Cloud6"})
    addBlock(77,"Bush - 1",false,{"Bush1"})
    addBlock(78,"Bush - 2",false,{"Bush2"})
    addBlock(79,"Bush - 3",false,{"Bush3"})
    addBlock(80,"Castle - 1",false,{"Castle1"})
    addBlock(81,"Castle - 2",false,{"Castle2"})
    addBlock(82,"Castle - 3",false,{"Castle3"})
    addBlock(83,"Castle - 4",false,{"Castle4"})
    addBlock(84,"Castle - 5",false,{"Castle5"})
    addBlock(85,"Castle - 6",false,{"Castle6"})
    addBlock(86,"Castle - 7",false,{"Castle7"})
    addBlock(87,"Fence",false,{"Fence"})
    addBlock(88,"Bridge Railing",false,{"BridgeRailing"})
    addBlock(89,"Arrow (Right)",false,{"arrow_E"})
    addBlock(90,"Arrow (Left)",false,{"arrow_W"})
    addBlock(91,"Arrow (Down)",false,{"arrow_S"})
    addBlock(92,"Arrow (Up)",false,{"arrow_N"})
    addBlock(93,"Arrow Sign (Right)",false,{"arrowSign_E"})
    addBlock(94,"Arrow Sign (Left)",false,{"arrowSign_W"})
    addBlock(95,"Arrow Sign (Down)",false,{"arrowSign_S"})
    addBlock(96,"Arrow Sign (Up)",false,{"arrowSign_N"})
    addBlock(97,"Toad (Top)",false,{"Toad_1"})
    addBlock(98,"Toad (Bottom)",false,{"Toad_2"})

    addBlock(99,"Barrier",true,{nil})
        addBlock:attribute("editor",1339)

    addBlock(100,"Invisible Block (Mushroom)",false,{nil})
        addBlock:attribute("invisiblock",true)
        addBlock:attribute("containing","mushroom")
        addBlock:attribute("icon","icon_mushroom")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
        addBlock:attribute("editor",1338)
    addBlock(101,"Invisible Block (Fireflower)",false,{nil})
        addBlock:attribute("invisiblock",true)
        addBlock:attribute("containing","fireflower")
        addBlock:attribute("icon","icon_fireflower")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
        addBlock:attribute("editor",1338)
    addBlock(102,"Invisible Block (Progressive)",false,{nil})
        addBlock:attribute("invisiblock",true)
        addBlock:attribute("containing","Pfireflower")
        addBlock:attribute("icon","icon_Pfireflower")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
        addBlock:attribute("editor",1338)
    addBlock(103,"Invisible Block (Star)",false,{nil})
        addBlock:attribute("invisiblock",true)
        addBlock:attribute("containing","star")
        addBlock:attribute("icon","icon_star")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
        addBlock:attribute("editor",1338)
    addBlock(104,"Invisible Block (1-Up)",false,{nil})
        addBlock:attribute("invisiblock",true)
        addBlock:attribute("containing","mushroom1up")
        addBlock:attribute("icon","icon_mushroom1up")
        addBlock:attribute("bumpable",{true,"EmptyBlock",5})
        addBlock:attribute("editor",1338)
    addBlock(105,"One-Way Gate (Left)",false,{"OneWay_W_1","OneWay_W_2","OneWay_W_3"})
        addBlock:attribute("semisolid","0001") --NES[W] (north east south west)
    addBlock(106,"One-Way Gate (Right)",false,{"OneWay_E_1","OneWay_E_2","OneWay_E_3"})
        addBlock:attribute("semisolid","0100") --N[E]SW
    addBlock(107,"One-Way Gate (Up)",false,{"OneWay_N_1","OneWay_N_2","OneWay_N_3"})
        addBlock:attribute("semisolid","1000") --[N]ESW
    addBlock(108,"One-Way Gate (Down)",false,{"OneWay_S_1","OneWay_S_2","OneWay_S_3"})
        addBlock:attribute("semisolid","0010") --NE[S]W
    addBlock(109,"Lava (Surface)",false,{"Lava_1","Lava_2","Lava_3","Lava_4"})
        addBlock:attribute("kill",true)
    addBlock(110,"Lava",false,{"Lava_0"})
        addBlock:attribute("kill",true)
    addBlock(111,"Spike Trap",true,{"Spikes_1","Spikes_1","Spikes_1","Spikes_1","Spikes_1","Spikes_2","Spikes_2"})
        addBlock:attribute("damage",true)
    addBlock(112,"Invisible Block (Multi-Coin)",false,{nil})
        addBlock:attribute("invisiblock",true)
        addBlock:attribute("containing","multicoin_2")
        addBlock:attribute("icon","icon_multicoin")
        addBlock:attribute("bumpable",{true,"MysteryBox0",26})
        addBlock:attribute("editor",1338)
    --decorations part 2
    addBlock(113,"Princess Toadstool (Top)",false,{"Peach_1"})
    addBlock(114,"Princess Toadstool (Bottom)",false,{"Peach_2"})
    addBlock(115,"Skeleton (Underground) - 1",false,{"SkeletonUnd_1"})
    addBlock(116,"Skeleton (Underground) - 2",false,{"SkeletonUnd_2"})
    addBlock(117,"Skeleton (Underground) - 3",false,{"SkeletonUnd_3"})
    addBlock(118,"Short Tree (Stem)",false,{"ShortTree_Stem"})
    addBlock(119,"Short Tree (Top)",false,{"ShortTree_1"})
    addBlock(120,"Short Tree (Bottom)",false,{"ShortTree_2"})
    addBlock(121,"Short Bush",false,{"ShortBush"})
    addBlock(122,"Small Mushrooms (Underground)",false,{"MushroomsUnd"})
    addBlock(123,"Fences (Castle) - 1",false,{"FencesCast_1"})
    addBlock(124,"Fences (Castle) - 2",false,{"FencesCast_2"})
    addBlock(125,"Fences (Castle) - 3",false,{"FencesCast_3"})
    addBlock(126,"Post (Castle)",false,{"PostCast"})
    addBlock(127,"Bowser Statue (Stem)",false,{"BowserStatue_1"})
    addBlock(128,"Bowser Statue (Bottom)",false,{"BowserStatue_2"})
    addBlock(129,"Bowser Statue (Top)",false,{"BowserStatue_3"})
    addBlock(130,"Night Stars - 1",false,{"Stars_1","Stars_1","Stars_1","Stars_2","Stars_2","Stars_2"})
    addBlock(131,"Night Stars - 2",false,{"Stars_2","Stars_2","Stars_2","Stars_1","Stars_1","Stars_1"})
    addBlock(132,"Night Stars - 3",false,{"Stars_3","Stars_3","Stars_3","Stars_4","Stars_4","Stars_4"})
    addBlock(133,"Night Stars - 4",false,{"Stars_4","Stars_4","Stars_4","Stars_3","Stars_3","Stars_3"})

    addBlock(150,"On/Off Switch",true,{"OnSwitch_1","OnSwitch_1","OnSwitch_1","OnSwitch_2","OnSwitch_2","OnSwitch_2"})
        addBlock:attribute("bumpable",{true,"OnSwitch_1",15000})
        addBlock:attribute("eventswitch",{"onoff","false",15000})
        addBlock:attribute("containing","event_onoff_false")
    addBlock(15000,"Off Switch",true,{"OffSwitch_1","OffSwitch_1","OffSwitch_1","OffSwitch_2","OffSwitch_2","OffSwitch_2"})
        addBlock:attribute("bumpable",{true,"OffSwitch_1",150})
        addBlock:attribute("eventswitch",{"onoff","true",150})
        addBlock:attribute("containing","event_onoff_true")
    addBlock(152,"On Block",true,{"OnBlock_1"})
        addBlock:attribute("eventswitch",{"onoff","false",15200})
    addBlock(15200,"On Block (Inactive)",false,{"OnBlock_2"}) --big number bc it wont be in level strings
        addBlock:attribute("eventswitch",{"onoff","true",152})
    addBlock(153,"Off Block",false,{"OffBlock_2"})
        addBlock:attribute("eventswitch",{"onoff","false",15300})
    addBlock(15300,"Off Block (Active)",true,{"OffBlock_1"})
        addBlock:attribute("eventswitch",{"onoff","true",153})

        --al, ar, a2, a1 (l, r (slow, false))
    addBlock(154,"Conveyor Belt - 1 (Left, Slow)",true,{"Conveyor_L_1","Conveyor_L_2","Conveyor_L_3","Conveyor_L_4"})
        addBlock:attribute("pushV",-1)
        addBlock:attribute("icon","icon_al") 
    addBlock(155,"Conveyor Belt - 2 (Left, Slow)",true,{"Conveyor_M_1","Conveyor_M_2","Conveyor_M_3","Conveyor_M_4"})
        addBlock:attribute("pushV",-1)
        addBlock:attribute("icon","icon_al") 
    addBlock(156,"Conveyor Belt - 3 (Left, Slow)",true,{"Conveyor_R_1","Conveyor_R_2","Conveyor_R_3","Conveyor_R_4"})
        addBlock:attribute("pushV",-1)
        addBlock:attribute("icon","icon_al") 
    addBlock(157,"Conveyor Belt - 1 (Right, Slow)",true,{"Conveyor_L_4","Conveyor_L_3","Conveyor_L_2","Conveyor_L_1"})
        addBlock:attribute("pushV",1)
        addBlock:attribute("icon","icon_ar") 
    addBlock(158,"Conveyor Belt - 2 (Right, Slow)",true,{"Conveyor_M_4","Conveyor_M_3","Conveyor_M_2","Conveyor_M_1"})
        addBlock:attribute("pushV",1)
        addBlock:attribute("icon","icon_ar") 
    addBlock(159,"Conveyor Belt - 3 (Right, Slow)",true,{"Conveyor_R_4","Conveyor_R_3","Conveyor_R_2","Conveyor_R_1"})
        addBlock:attribute("pushV",1)
        addBlock:attribute("icon","icon_ar") 
    addBlock(160,"Conveyor Belt - 1 (Left, Fast)",true,{"Conveyor_L_1","Conveyor_L_2","Conveyor_L_3","Conveyor_L_4"})
        addBlock:attribute("pushV",-3)
        addBlock:attribute("icon","icon_a2") 
        addBlock:attribute("animSpeed",2) 
    addBlock(161,"Conveyor Belt - 2 (Left, Fast)",true,{"Conveyor_M_1","Conveyor_M_2","Conveyor_M_3","Conveyor_M_4"})
        addBlock:attribute("pushV",-3)
        addBlock:attribute("icon","icon_a2")
        addBlock:attribute("animSpeed",2)
    addBlock(162,"Conveyor Belt - 3 (Left, Fast)",true,{"Conveyor_R_1","Conveyor_R_2","Conveyor_R_3","Conveyor_R_4"})
        addBlock:attribute("pushV",-3)
        addBlock:attribute("icon","icon_a2")
        addBlock:attribute("animSpeed",2) 
    addBlock(163,"Conveyor Belt - 1 (Right, Fast)",true,{"Conveyor_L_4","Conveyor_L_3","Conveyor_L_2","Conveyor_L_1"})
        addBlock:attribute("pushV",3)
        addBlock:attribute("icon","icon_a1") 
        addBlock:attribute("animSpeed",2) 
    addBlock(164,"Conveyor Belt - 2 (Right, Fast)",true,{"Conveyor_M_4","Conveyor_M_3","Conveyor_M_2","Conveyor_M_1"})
        addBlock:attribute("pushV",3)
        addBlock:attribute("icon","icon_a1") 
        addBlock:attribute("animSpeed",2) 
    addBlock(165,"Conveyor Belt - 3 (Right, Fast)",true,{"Conveyor_R_4","Conveyor_R_3","Conveyor_R_2","Conveyor_R_1"})
        addBlock:attribute("pushV",3)
        addBlock:attribute("icon","icon_a1") 
        addBlock:attribute("animSpeed",2) 

--------------------------
--------OBJECT API--------
--------------------------
objAPI=class() --categories are only roughly representative
    --DEFAULT VALUES
    objAPI.dead=false objAPI.px=0 objAPI.py=0
    objAPI.spring=false objAPI.interactSpring=true
    --OBJECT/PLATFORM MANAGEMENT
        function objAPI:getObjectCount(passedEntityLists) --returns the number of objects in a given level
            local entityLists=passedEntityLists or entityLists
            local count=0
            for k in pairs(entityLists) do
                count=count+#entityLists[k]
            end
            return count
        end

        function objAPI:createObj(TYPE,posX,posY,despawnable,arg1,arg2)
            --todo, rename objectID to objectID because class makes no sense here
            local objectID=TYPE..objAPI:getObjectCount()+1+framesPassed.."r"..math.random(0,200) --assign random ID
            local classTYPE local LEVEL
            classTYPE,LEVEL=objAPI:type2class(TYPE)
            local levelObject=entityLists[LEVEL]
            if classTYPE~=false then
                allEntities[objectID]=entityClasses[classTYPE]()  --despawnable also triggers block animation (sometimes) [edit idfk why i made this comment here]
                table.insert(levelObject,objectID)
                allEntities[objectID]:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
            end return objectID
        end

        function objAPI:initObject(objectID,TYPE,LEVEL,hitBox,xywh,vx,vy) --facilitates bringing an object into existence!
            self.objectID=objectID
            self.TYPE=TYPE
            self.LEVEL=LEVEL or "inner"
            self.hitBox=hitBox
            self.x=xywh[1] self.y=xywh[2] self.w=xywh[3] or 16 self.h=xywh[4] or 16 self.vy=vy or 0
            self.vx=(vx~=true) and vx or ((mario.x>self.x) and 2 or -2)
        end
    
        function objAPI:destroy(objectName,LEVEL) --add to cleanup waitlist
            table.insert(cleanupListDestroy,{objectName,LEVEL})
        end
    
        function objAPI:transferLayer(objectName,LEVEL,newLEVEL) --add to cleanup waitlist
            table.insert(cleanupListTransfer,{objectName,LEVEL,newLEVEL})
        end
    
        function objAPI:sendToFront(objectName,LEVEL) --removes from layer and reinserts at the top
            table.insert(cleanupListTransfer,{objectName,LEVEL,LEVEL})
        end
    
        function objAPI:addHitBox(objectID,x,y,w,h,TYPE)
            table.insert(hitBoxList,{objectID,x,y,w,h,TYPE})
        end
    
        function objAPI:addPlatform(objectID,x,y,w,xVel,yVel)
            local yOffset=0
            if math.abs(yVel)>1 then
                yOffset=(math.floor(y-4)%2)
            end
            table.insert(playStage.platformListAdd,{objectID,x,y-yOffset,w,xVel,yVel})
        end
    
        function objAPI:updatePlatforms()
            playStage.platformList={}
            for i=1,#playStage.platformListAdd do
                table.insert(playStage.platformList,{unpack(playStage.platformListAdd[i])})
            end
            playStage.platformListAdd={}
        end
    
        function objAPI:cleanup() --these huge functions relating to every object are very fun :>
            for iH=1,#hitBoxList do --hitBox aggressor array: {objectID,x,y,w,h,type} // hitBox passive array: {w,h,willBeKilled,destroyFireball,xOffset,yOffset}
                for k in pairs(entityLists) do --do all entity lists
                    local focusedList=entityLists[k]
                    for i=1,#focusedList do --for all entities within the list
                        local entity=allEntities[focusedList[i]]

                        if entity.hitBox then --if entity can be hit
                            local victomHitBox=entity.hitBox
                            local aggressorHitBox=hitBoxList[iH]
                            victomHitBox[5],victomHitBox[6]=victomHitBox[5] or 0,victomHitBox[6] or 0
                            -- local pos={entity.x,entity.y} -- V if there is a collision V

                            if aggressorHitBox[1]~=entity.objectID and (checkCollision(aggressorHitBox[2],aggressorHitBox[3],aggressorHitBox[4],aggressorHitBox[5],entity.x+2+victomHitBox[5],entity.y+2+victomHitBox[6],victomHitBox[1]-4,victomHitBox[2]-4)) then
                                if entity.dead~=true then
                                    local hitVictim=allEntities[aggressorHitBox[1]]

                                    print("HIT",aggressorHitBox[1],entity.objectID,victomHitBox[1],victomHitBox[2],victomHitBox[3],victomHitBox[4],aggressorHitBox[2],aggressorHitBox[3],aggressorHitBox[4],aggressorHitBox[5],aggressorHitBox[6])
                                    
                                    if aggressorHitBox[6]=="shell" and victomHitBox[3]==true then
                                        hitVictim:handleShellPoints()
                                        if entity.destroyShell then hitVictim:hit() end
                                    elseif aggressorHitBox[6]=="fireball" and victomHitBox[4]==true then
                                        hitVictim:handleFireballHit()
                                    elseif aggressorHitBox[6]=="mario" and not entity.disableStarPoints then
                                        objAPI:addStats("points","200",mario.x,mario.y-16)
                                    end
                                end
                                entity:hit(aggressorHitBox[6]) --react to hit (death/jump/other)
            end end end end end --important for hitbox to go first so that new queued requests don't get cleared
            for i=1,#cleanupListDestroy do --remove entity from list and clear all stored vars
                local objectName,LEVEL=unpack(cleanupListDestroy[i])
                -- print(objectName,LEVEL)
                local levelObject=entityLists[LEVEL]
                for i2=1,#levelObject do
                    if levelObject[i2]==objectName then
                        table.remove(levelObject,i2)
                        allEntities[objectName]={}
                        break
            end end end
            for i=1,#cleanupListTransfer do
                local LEVEL=cleanupListTransfer[i][2]
                local newLEVEL=cleanupListTransfer[i][3]
                local objectName=cleanupListTransfer[i][1]
                local levelObject=entityLists[LEVEL]
                local newLevelObject=entityLists[newLEVEL]
                for i2=1,#levelObject do
                    if levelObject[i2]==objectName then
                        table.remove(levelObject,i2)
                        table.insert(newLevelObject,objectName)
                        break
            end end end

            cleanupListDestroy={}
            cleanupListTransfer={}
            hitBoxList={}
        end

        function objAPI:getBlockStandingOn() --returns the block that the entity is standing on, if any
            local rightX=self.x+self.w
            local bottomY=self.y+self.h

            local blockLeft=pixel2block(self.x,bottomY,true)
            local blockRight=pixel2block(rightX,bottomY,true)

            blockLeft=(blockLeft and self:checkForWall(self.x,bottomY)) and blockLeft or false
            blockRight=(blockRight and self:checkForWall(rightX,bottomY)) and blockRight or false

            -- print("blockLeft",blockLeft,blockRight)

            local pushVLeft=blockLeft and blockLeft.pushV or 0

            local block

            if blockLeft and blockRight then
                --go in the center of the block
                local blockCenter=pixel2block(self.x+(self.w/2),bottomY,true)
                block=blockCenter or false
            else 
                block=blockLeft or blockRight
            end

            return block
        end
        
        function objAPI:setNewPushV()
            local px,py=0,0
            if not self.spring then --a somewhat embarrasing solution...
                local platformVel=objAPI:platformCheck(self.x,self.y)
                if platformVel then
                    px,py=platformVel[1],platformVel[2]
                end
            end
            local blockStandingOn=self:getBlockStandingOn()
            if blockStandingOn and blockStandingOn.pushV then
                px=px+blockStandingOn.pushV
            end
            self.px=px
            self.py=py
        end

        function objAPI:addStats(type,value,x,y,fromFlagpole)
            if type=="points" then
                if x~=nil and y~=nil then objAPI:createObj("score",x,y,nil,value) end --particle
                playStage.SCORE=playStage.SCORE+value
            elseif type=="coins" then
                playStage.coinCount=playStage.coinCount+value
                if playStage.coinCount>99 then
                    playStage.coinCount=playStage.coinCount%100
                    objAPI:addStats("1up",1,mario.x,mario.y)
                end
            elseif type=="1up" and x~=nil and y~=nil then
                objAPI:createObj("score",x,y,nil,"1up")
            end
        end

    --OBJECT ANIMATION
        function objAPI:animateDeathFlyOffscreen()
            self.x=self.x+self.vx
            if self.vy<-0.5 then --rising
                self.vy=(self.vy+0.25)*0.75 --most of these values do not have much meaning, just tuned to what feels right :>
            elseif (self.vy<0 and self.vy>-0.5) or self.vy>0 then --begin/is falling
                self.vy=self.vy>6 and 6 or (math.abs(self.vy)+0.5)*1.18
            end
            self.y=self.y+self.vy
            if self.y<0 then
                objAPI:destroy(self.objectID,self.LEVEL)
            end
        end --NEW code approved

    --OBJECT MOVEMENT
        function objAPI:checkForWall(x,y,isMario) -- return true if point is in wall
            local isMario=isMario or (self.objectID=="mario")
            return (pixel2solid(x,y,true) and not (isMario and pixel2anything("marioonly",x,y,true))) or (isMario and pixel2anything("entityonly",x,y,true)) --check if x pos in a wall
        end --NEW code approved

        function objAPI:multiWallCheck(v,notRelative) -- returns true if any point in wall
            local results,r={},not notRelative and {self.x,self.y} or {0,0}
            for i=1,#v do
                results[i]=self:checkForWall(v[i][1]+r[1],v[i][2]+r[2])
            end return table.checkForValue(results,true)
        end --NEW code approved

        function objAPI:calculateAccelerationY(strength,terminalV)
            if not self.spring then --a somewhat embarrasing solution...
                strength=strength or 1
                local terminalV,dec,acc=terminalV or -6,0.7*strength,1.2*strength
                if self.vy>0 then --ascending
                    self.vy=(self.vy>0.5) and self.vy*dec or -0.08
                elseif self.vy<0 then --descending
                    self.vy=(self.vy*acc<terminalV) and terminalV or self.vy*acc
        end end end --NEW code approved

        function objAPI:aggregateCheckX(V,platformCalc) --to move in the x direction
            if not self.spring then --a somewhat embarrasing solution...
                local function rndPos(X,V)
                    if V<0 then return (math.floor(X/16))*16
                    else return (math.ceil(X/16))*16 end
                end
                local function checkX(X,Y,V,checkSemisolid)
                    local result={rndPos(X,V),true}
                    if self:checkForWall(X+V,Y) then --wallX becomes true if there is a wall
                    elseif checkSemisolid and V<0 and pixel2semisolid(2,X+V,Y,true) then --going left
                        local semisolidPos=rndPos(X+V,0) --yea
                        if not (((X+V)<=semisolidPos) and (X>=semisolidPos)) then result={X+V,false} end
                    elseif checkSemisolid and V>0 and pixel2semisolid(4,X+V,Y,true) then --going right
                        local semisolidPos=rndPos(X,V)
                        if not (((X+V)>=semisolidPos) and (X<=semisolidPos)) then result={X+V,false} end
                    else result={X+V,false} end return unpack(result)
                end
                local X,Y,W,H,V,isMario,LEFT,RIGHT,POWER = self.x,self.y,self.w or 16,self.h or 16,V or self.vx,self.objectID=="mario" and true or false,(V<0),(V>0)
                local powerLeft,powerRight,wall5,wall6,finalPos
                local topLeft,wall1     =checkX(X+2,Y+3,V,LEFT)
                local topRight,wall2    =checkX(X+W-3,Y+3,V,RIGHT)
                local bottomLeft,wall3  =checkX(X+2,Y+H-1,V,LEFT)
                local bottomRight,wall4 =checkX(X+W-3,Y+H-1,V,RIGHT)
                local valuesX={topLeft-2,topRight-W+3,bottomLeft-2,bottomRight-W+3}
                if isMario and mario.power>0 and not mario.crouch then
                    powerLeft,wall5     =checkX(X+2,Y-15,V,LEFT)
                    powerRight,wall6    =checkX(X+W-3,Y-15,V,RIGHT)
                    table.insert(valuesX,powerLeft-2) table.insert(valuesX,powerRight-W+3) 
                end
                if V<0 then finalPos=math.max(unpack(valuesX))
                else        finalPos=math.min(unpack(valuesX)) end
                if wall1 or wall2 or wall3 or wall4 or wall5 or wall6 then --contact with wall made
                    local justify=((wall1 or wall3 or wall5) and input.left==1) and "L" or ((wall2 or wall4 or wall6) and input.right==1) and "R" or false
                    self:checkFor(justify)
                    if isMario and self.vy==0 then mario:pipeCheck() end
                    if self.canHitSide and self.vx~=0 then
                        local testPos=finalPos+(V>0 and W-3 or 0)+pol2binary(V)*8 local offsetY={1,H-1}
                        for i=1,#offsetY do
                            if pixel2bumpable(testPos,self.y+offsetY[i],true) then
                                local v=pixel2plot(testPos,self.y+offsetY[i],true)
                                objAPI:handleBumpedBlock(v[1],v[2],true)
                    end end end
                    if self.isFireball then self:handleFireballHit() end
                    if not platformCalc then
                        if isMario and math.round(X,1)==math.round(finalPos,1) then self.vx=0 --print(X,V,self.vx,finalPos)
                        elseif self.turnAround then self.vx=-self.vx
                end end end
                self.x=finalPos
        end end --NEW code approved

        function objAPI:gravityCheck(yVel,platformCalc,jumpCalc) --made to work with velocity values that are reasonable, ie up is negative, down is positive
            if not self.spring then --a somewhat embarrasing solution...
                local function rndPos(Y,V) return (math.floor((Y+V)/16)*16)+4 end --this likely won't work so well with downwards velocities below -15, take note
                local function checkY(isMario,X,Y,V,platformCalc)
                    local pos={Y+V} --list of possible positions to fall to
                    if not platformCalc then
                        for i=1,#playStage.platformList do
                            local platform=playStage.platformList[i]

                            local pX=platform[2] local pY=platform[3] local pW=platform[4] local pV=-platform[6]
                            if X>=pX and X<=pX+pW then --object is in x axis radius of platform, therefore possibility of landing
                                if ((Y<=pY) and (not ((pos[1])<pY) or not ((pos[1])<(pY+pV)))) then --if above platform and not (wont land on it)
                                    table.insert(pos,pY) pos[1]=pY
                    end end end end
                    if (pixel2solid(X,pos[1],true) and not (isMario and pixel2anything("marioonly",X,pos[1],true))) then
                        table.insert(pos,rndPos(Y,V)) -- ↳ if block is solid
                    elseif (isMario and pixel2anything("entityonly",X,pos[1],true)) then
                        table.insert(pos,rndPos(Y,V)) -- ↳ if 1. it is mario 2. if it's entityonly then it is solid for him. necessary as entityonly blocks do not have the general 'solid' parameter
                    elseif pixel2semisolid(1,X,pos[1],true) then
                        local semisolidPos=rndPos(Y,V)
                        if ((Y+V)>=semisolidPos) and (Y<=semisolidPos) then table.insert(pos,semisolidPos) end --MUCH better than my last """solution"""
                    end
                    local finalPos=math.min(unpack(pos)) local onFloor=(#pos)~=1
                    return finalPos, onFloor
                end
                local X,Y,W,H,V,isMario=self.x,math.floor(self.y),self.w or 16,self.h or 16,math.floor(yVel) or -math.ceil(self.vy),self.objectID=="mario" and true or false
                local LEFT, floorL=checkY(isMario,self.x+3,Y+H,V,platformCalc)
                local RIGHT,floorR=checkY(isMario,self.x+W-3,Y+H,V,platformCalc)
                if W>16 then --prevent falling into a block for wide entities. **only works for 32 in this case**
                    local RIGHT2,floorR2=checkY(isMario,self.x+16-3,Y+H,V,platformCalc)
                    if RIGHT2<RIGHT then
                        RIGHT,floorR=RIGHT2,floorR2
                end end
                local finalPos=math.min(LEFT-H,RIGHT-H) --PAY ATTENTION!! the height offset must ALWAYS be considered
                if jumpCalc then
                    if self.y==finalPos then return true end
                    return false
                end
                if not platformCalc or self.vy==0 then
                    if floorL or floorR then
                        if self.doesBounce then self.vy=(type(self.doesBounce)=='number' and self.doesBounce) or 17
                        -- elseif self.isBouncy and self.vy<0 then
                        --     self.vy=-((self.lastBounce or self.vy))
                        --     self.lastBounce=-(self.vy)+3.5
                        --     if self.vy<0.9 then self.lastBounce=nil self.vy=0 end
                        else self.vy=0 end
                        if isMario then mario.hitCount=0 end
                    else self.vy=math.max(self.vy-1.4,-7)
                end end
                if self.noFall and self.vy==0 and not platformCalc then
                    if (floorL and not floorR) or (floorR and not floorL) then
                        self.vx=-self.vx
                    end
                end
                self.y=finalPos
        end end --NEW code approved

        function objAPI:bumpCheck(V,crouchCalc) --made to work with velocity values that are reasonable, ie up is negative, down is positive
            if not self.spring then --a somewhat embarrasing solution...
                local function checkY(isMario,X,Y,V)
                local function rndPos(X) return (math.ceil((X-4)/16)*16)+4 end
                    for i=(math.floor((Y-4)/16)*16)+3,(Y+V-15),-16 do
                        i=(i<(Y+V)) and (Y+V) or i
                        if (pixel2solid(X,i,true) and not (isMario and pixel2anything("marioonly",X,i,true))) then
                            return rndPos(i),{X,i} -- ↳ if block is solid
                        elseif isMario and pixel2anything("entityonly",X,i,true) then
                            return rndPos(i),{X,i} -- ↳ if 1. it is mario 2. if it's entityonly then it is solid for him. necessary as entityonly blocks do not have the general 'solid' parameter
                        elseif isMario and pixel2anything("invisiblock",X,i,true) then
                            return rndPos(i),{X,i}
                        elseif pixel2semisolid(3,X,i,true) then
                            local semisolidPos=rndPos(i)
                            if ((Y+V)<=semisolidPos) and (Y>=semisolidPos) then return rndPos(i),{X,i} end
                    end end return Y+V,false
                end
                local X,Y,W,H,V,isMario = self.x,self.y,self.w or 16,self.h or 16,V or self.vy,self.objectID=="mario" and true or false
                local offsetY=(isMario and mario.power>0 and not mario.crouch) and -15 or 0
                local topLeft,topLeftB=checkY(isMario,X+3,Y+offsetY,V)
                local topRight,topRightB=checkY(isMario,X+W-3,Y+offsetY,V)
                if crouchCalc and mario.crouch then return not not (topLeftB or topRightB) end --table to boolean :p
                if topLeftB or topRightB then
                    self.vy=-0.61
                    if self.isFireball then self:handleFireballHit() self.y=self.y-4 return end
                    if self.canHit or isMario then
                        if type(topLeftB)=="boolean" then topLeftB=topRightB end
                        if type(topRightB)=="boolean" then topRightB=topLeftB end
                        topLeftB[2],topRightB[2]=math.max(topLeftB[2],topRightB[2]),math.max(topLeftB[2],topRightB[2])
                        local bumps={topLeftB,topRightB}
                        for i=1,#bumps do
                            if bumps[i] and pixel2bumpable(bumps[i][1],bumps[i][2],true) then
                                objAPI:handleBumpedBlock(unpack(pixel2plot(bumps[i][1],bumps[i][2],true)))
                end end end end
                self.y=math.max(topLeft-offsetY,topRight-offsetY)
        end end --NEW code approved

        function objAPI:platformCheck(x,y,optionalLength) --checks if standing on a platform and then returns xVel/yVel if applicable
            y=math.floor(y)
            local distance=15-2
            if optionalLength then distance=optionalLength-2 end
            for i=1,#playStage.platformList do 
                local platform=playStage.platformList[i]
                local pX=platform[2] local pY=platform[3] local pW=platform[4]

                if ((x+2>=pX and x+2<=pX+pW) or (x+distance>=pX and x+distance<=pX+pW)) and y+16==pY then --object is in x axis radius of platform, and is on same y level
                    return {tonumber(platform[5]),tonumber(platform[6])}
                end
            end
            return {0,0}
        end --TODO rewrite needed ##############

    --OBJECT BEHAVIOUR
        function objAPI:checkStuckInWall()
            if self:checkForWall(self.x+8,self.y+8) and not self.dead then --stuck in a block
                objAPI:destroy(self.objectID,self.LEVEL)
            end
        end --NEW code approved

        function objAPI:checkMarioCollision(onStomp,noKill,bodge) bodge=bodge or 0 --bodge is a temporary fix for the fact that bowser's xy center is not the same as his visual appearance and so he can't be hit, very hacky, very bad, very sad, very mad
            if not (mario.starTimer>playStage.framesPassed) or self.allowStarCollision then --hitting mario is possible
                local marioSize=(mario.power==0 or mario.crouch) and 0 or 16
                if onStomp and checkCollision(mario.x+1,mario.y-marioSize+1,14,14+marioSize,self.x+1,self.y,self.hitBox[1]-1,1) and (mario.vy<0 or mario.py<0 or self.py>0 or self.vy>0) then --hit on head
                    if not noKill then
                        mario.vtempY=15
                        mario:handleStomp()
                        self.dead=true -- !! may not always apply
                    end
                    if onStomp[1]=="stomp" then
                        self.status=onStomp[2]
                        self.deathAnimTimer=playStage.framesPassed+10
                        objAPI:sendToFront(self.objectID,self.LEVEL)
                    elseif onStomp[1]=="dropkill" then
                        self.vy=0.5
                    elseif onStomp[1]=="powerup" then self:use()
                    elseif onStomp[1]=="shell" then
                        self.hitTimer=playStage.framesPassed+8 --avoid instakill after kicking shell or double hits
                        local shakeCondition=self.koopaTimer and (self.koopaTimer-45<playStage.framesPassed)
                        if self.vx==0 and not shakeCondition then --NOT shaking (about to turn into koopa)
                            self.koopaTimer=false
                            if level.current.enableShellBouncing==true then mario.vtempY=8 end
                            objAPI:addStats("points",400,self.x,self.y)
                            self.vx=(self.x>mario.x) and 4 or -4
                        else self.vx=0 --shaking or moving, outcome is the same either way
                            self.koopaTimer=playStage.framesPassed+200
                            mario.vtempY=15
                            mario:handleStomp() --repeated code! aaah!
                        end
                    elseif onStomp[1]=="transform" then
                        local vx,newID=self.vx,objAPI:createObj(onStomp[2],self.x,self.y,nil,onStomp[3],onStomp[4])
                        objAPI:destroy(self.objectID,self.LEVEL) self.status=onStomp[5]
                        if string.sub(self.TYPE,1,5)=="Pkoop" then allEntities[newID].vx=sign(vx)*2 end 
                    end
                    if level.current.enableCoinOnKill then objAPI:createObj("coin",self.x,self.y-16,true) end
                elseif checkCollision(mario.x+1,mario.y-marioSize+1,14,14+marioSize,self.x+4,self.y+3+bodge,self.hitBox[1]-8,self.hitBox[2]-4) then --hit mario (side)
                    if onStomp[1]=="shell" and self.vx==0 then
                        self.hitTimer=playStage.framesPassed+8 --avoid instakill after kicking shell or double hits
                        self.koopaTimer=false self.hitCount=0
                        objAPI:addStats("points",400,self.x,self.y)
                        self.vx=(self.x>mario.x) and 6 or -6
                    elseif onStomp[1]=="powerup" then self:use()
                    elseif onStomp[1]=="clear" then
                        if not mario.clear then mario:clearedLevel(onStomp[2]) playStage.wait=true end
                        self.dead=true
                    else mario:powerDownMario() end
                end
                --table.insert(debugBoxes,{mario.x+1,mario.y-marioSize+1,14,14+marioSize})
                --table.insert(debugBoxes,{self.x+4,self.y+3+bodge,self.hitBox[1]-8,self.hitBox[2]-4})
            end
        end --NEW code approved

        function objAPI:handleHitDefault(circumstance,newStatus,newTYPE) --works for most enemies
            self.vy=-11 self.dead=true self.status=newStatus self.TYPE=newTYPE or self.TYPE
            if level.current.enableCoinOnKill then objAPI:createObj("coin",self.x,self.y-16,true) end
            if circumstance=="fireball" or circumstance=="block" then
                objAPI:addStats("points","100",self.x,self.y)
            end
            if circumstance=="mario" or circumstance=="fireball" then
                self.vx=(mario.x<self.x) and 2 or -2
            end objAPI:transferLayer(self.objectID,self.LEVEL,"particle")
            self.LEVEL="particle"
        end --NEW code approved

        function objAPI:handleBumpedBlock(xLOC,yLOC,shell)
            local ID=plot2ID(xLOC,yLOC)
            local pixelXY=plot2pixel(xLOC,yLOC,false)
            if blockIndex[ID].containing~=nil and blockIndex[ID].containing~=false then --if there is something in the block
                objAPI:createObj(blockIndex[ID].containing,pixelXY[1],pixelXY[2],true) --(TYPE,posX,posY,fromBlock) objAPI:createObj(blockID,(i2-1)*16,212-16*(i),0)
            end
            if blockIndex[ID].breakable==false or (mario.power==0 and not shell) then --create bumped block if unable to be destroyed
                local texture = blockIndex[ID].bumpable[2]
                if texture == true then texture = blockIndex[ID].texture[1] end
                objBumpedBlock:create(xLOC,yLOC,texture,blockIndex[ID].bumpable[3],false)
            else --smash the block
                playStage.SCORE=playStage.SCORE+50
                plot2place(0,xLOC,yLOC)
                objBrickParticleGlobalAnimIndex=0
                objAPI:createObj("brick_piece",pixelXY[1],pixelXY[2],false,-3,7.5) --top left
                objAPI:createObj("brick_piece",pixelXY[1]+8,pixelXY[2],false,3,7.5) --top right
                objAPI:createObj("brick_piece",pixelXY[1]+8,pixelXY[2]+8,false,3,2.5) --bottom right
                objAPI:createObj("brick_piece",pixelXY[1],pixelXY[2]+8,false,-3,2.5) --bottom left
                objAPI:addHitBox(nil,pixelXY[1]+1,pixelXY[2]-16,14,16,"block")
            end
            --CRASH on below line: line 2174 attempt to index field '?' (a nil value)
            if yLOC<=12 and blockIndex[plot2ID(xLOC,yLOC+1)].coin==true then --if there is a coin above the bumped block
                plot2place(0,xLOC,yLOC+1)
                objAPI:createObj("coin",pixelXY[1],pixelXY[2]-16,true)
            end
        end --TODO rewrite needed ##############

        function objAPI:checkFor(CHECK) --cannot be inside aggregatecheckx as has to display changes immediately, otherwise will be a frame late in some instances
            local X,Y,W,H,isMario,O=self.x,self.y,self.w or 16,self.h or 16,self.objectID=="mario",self.vy==0 and 0 or -1
            local function doCheck(x,y,isTop,side)
                if self.canCollectCoins and pixel2anything("coin",x,y,true) then
                    objAPI:addStats("coins",1) pixel2place(0,x,y,true) objAPI:addStats("points",200)
                end
                if isMario then 
                    if pixel2anything("damage",x,y,true) and (not (mario.starTimer>playStage.framesPassed)) then
                        if ((self:gravityCheck(self.vy,true,true) and not isTop) or mario.vy==-0.61 or mario.vx~=0) then --inputs are so that if mario jumps on the pixel that the spike is, it will not hurt him unless he is walking/jumping into it.
                            mario:powerDownMario()
                    end end
                    if pixel2anything("kill",x,y,true) and (isTop or mario.vy<0) then --use isTop for when descending, so that mario sinks into lava slightly when in contact, rather than dying instantly on the surface. may look jank i guess but who cares that deeply about a calculator game anyway?
                        mario:kill()
            end end end
            doCheck(X+2,Y+O,true,"L") doCheck(X+W-2,Y+O,true,"R") doCheck(X+4,Y+H,false,"L") doCheck(X+W-4,Y+H,false,"R")
            if isMario and mario.power>0 and (crouchCalc or not mario.crouch) then doCheck(X+2,Y-16+O,true) doCheck(X+W-3,Y-16+O,true) end
        end --NEW code approved

    --OTHER
        function objAPI:type2class(TYPE)
            if typeIndex[string.sub(TYPE,1,5)]~=nil then
                return typeIndex[string.sub(TYPE,1,5)][1],typeIndex[string.sub(TYPE,1,5)][2]
            else return false,false
            end
        end
        
        function objAPI:type2name(TYPE,statusBox) --statusBox: 0=false, 1=true
            local name=""
            if type(TYPE)=='number' then
                if blockIndex[TYPE]~=nil then
                    name=blockIndex[TYPE]["name"]
                end
            elseif string.sub(TYPE,1,4)=="warp" then
                local config=TYPE:split("_")
                local ID,action,option=config[2],config[3],config[4]
                if action=="edit" then name="EDIT WARP "..ID
                elseif option then name=nameIndex["warp_ID_"..action.."_"..option]
                else name=nameIndex["warp_ID_"..action]
                end
            elseif string.sub(TYPE,1,8)~="platform" then
                if nameIndex[TYPE]~=nil then name=nameIndex[TYPE] end
            else
                name={} --eg: platform_3~1~lx~64
                local config=(string.sub(TYPE,10,#TYPE)):split("~")
                if nameIndex[config[3]]~=nil then name[1]="Platform "..nameIndex[config[3]] end
                if statusBox==1 then 
                    name[2]="Length: "..config[1]
                    if string.sub(config[3],1,1)=="l" then name[3]="Distance: "..math.floor(config[4]/16) end
                end
            end return name
        end

---------------------------
---PROFILER+OPTIMISATION---
---------------------------

    Profiler = {}
    Profiler.__index = Profiler

    function Profiler.new()
        local self = setmetatable({}, Profiler)
        self:reset()
        return self
    end

    function Profiler:dealWithStoppingPrevious()
        if self.current then
            self:stop(self.current, true)
            self.current = nil  -- reset current label after stopping
        end
    end

    function Profiler:start(label, stopThisNext, category)
        if not studentSoftware then return end

        self:dealWithStoppingPrevious()

        category = category or "uncategorized"

        if not self.data[category] then
            self.data[category] = {}
        end

        if not self.data[category][label] then
            self.data[category][label] = { total = 0, count = 0, start = 0 }
        end
        self.data[category][label].start = timer.getMilliSecCounter()

        if stopThisNext then
            self.current = { label = label, category = category }
        end
    end

    function Profiler:stop(label, fromDealWithStoppingPrevious)
        if not studentSoftware then return end

        if not fromDealWithStoppingPrevious then
            self:dealWithStoppingPrevious()
        end

        -- find the label in the current or any category
        local entry
        if self.current and self.current.label == label then
            local cat = self.current.category
            entry = self.data[cat][label]
        else
            -- fallback: search categories for label (slow path)
            for cat, catData in pairs(self.data) do
                if catData[label] then
                    entry = catData[label]
                    break
                end
            end
        end
        if not entry then return end -- label not found

        local duration = timer.getMilliSecCounter() - entry.start
        entry.total = entry.total + duration
        entry.count = entry.count + 1
        entry.start = 0
    end

    function Profiler:report()
        if not studentSoftware then return end

        local timeTaken = timer.getMilliSecCounter() - self.lastTime
        print("=== PROFILER REPORT ===", collectgarbage("count"), "kb", timeTaken, "ms")

        for category, catData in pairs(self.data) do
            --add up all calls and total time for the category
            local totalCalls = 0
            local totalTime = 0
            for label, stat in pairs(catData) do
                totalCalls = totalCalls + stat.count
                totalTime = totalTime + stat.total
            end
            print("### Category:", category, "Total Calls:", totalCalls, "Total Time:", totalTime, "ms")
            for label, stat in pairs(catData) do
                local avg = stat.total / math.max(stat.count, 1)
                print(string.format("  %s: %d calls, total = %d ms, avg = %.2f ms",
                    label, stat.count, stat.total, avg))
            end
        end

        self:reset()
    end

    function Profiler:reset()
        self.data = {}
        self.current = nil
        self.lastTime = timer.getMilliSecCounter()
    end

    function Profiler:wrap(label, func, category)
        if not studentSoftware then return func end

        category = category or "wrapped"
        return function(...)
            self:start(label, false, category)
            local result = {func(...)}
            self:stop(label)
            -- if label == "string.match" then --crash to show debugger
            --     error("Debugging call")
            -- end
            return unpack(result)
        end
    end

    Profiler = Profiler.new()

    local function hookFunctions(libName, lib)
        local function hook(v, funcName)
            print("Hooking function: " .. funcName)
            local category = type(lib) == "table" and libName or "hooked"

            return Profiler:wrap(funcName, v, category)
        end

        if type(lib) == "table" then
            for k, v in pairs(lib) do
                local funcName = libName .. "." .. k
                if type(v) == "function" then
                    lib[k] = hook(v, funcName)
                elseif type(v) == "table" then
                    hookFunctions(libName .. "." .. k, v) -- recursive hook for nested tables
                end
            end
        elseif type(lib) == "function" then -- if the library is a function, we can wrap it directly
            lib = hook(lib, libName)
        end
    end

    if studentSoftware then
        hookFunctions("string", string)
        hookFunctions("table", table)
        hookFunctions("math", math)

        -- hookFunctions("unpack", unpack)
        hookFunctions("collectgarbage", collectgarbage)
        hookFunctions("print", print)
        hookFunctions("error", error)
        hookFunctions("type", type)
        hookFunctions("pairs", pairs)
        hookFunctions("ipairs", ipairs)
        hookFunctions("next", next)
        hookFunctions("tostring", tostring)
        hookFunctions("tonumber", tonumber)
        hookFunctions("assert", assert)
        hookFunctions("require", require)
        hookFunctions("pcall", pcall)
        hookFunctions("xpcall", xpcall)
    end

    function destroyObject(obj, setTo)
        setTo=setTo or nil
        --iterate over the object and set all its fields to nil
        if type(obj) == "table" then
            for k in pairs(obj) do
                local value = obj[k]
                if type(value) == "table" then
                    destroyObject(value)
                else
                    obj[k] = nil
                end
            end
        end
        return setTo or nil --return nil or the value to set the object to
    end

---------------------------
---MARIO CLASS FUNCTIONS---
---------------------------
mario=class(objAPI)

    function mario:init()
        mario.trail={}
        self.objectID="mario" self.canCollectCoins=true
        mario:resetPos()
    end

    function mario:resetPos() --default config
        mario.powerUp=false
        mario.powerDown=false
        mario.clear=false
        mario.dead=false
        mario.powerAnimTimer=0
        mario.dir="R"
        mario.crouch=false
        mario.x=level.current.startX mario.y=level.current.startY
        mario.w=16 mario.h=16
        mario.vx=0 mario.vy=0
        mario.status="idle"
        mario.power=0 mario.skipAnim=false
        playStage.wait=false
        mario.iFrames=-1
        mario.hitCount=0
        mario.starAnim=false
        mario.actionAnimTimer=0
        mario.starTimer=0 mario.interactSpring=true
        mario.jumpAnim=0 mario.spring=false mario.pipe=false
    end

    function mario:logic() --direction is seperate as its still needed during pause
        mario.starAnim=false
        if not playStage.wait and not mario.powerUp and not mario.powerDown then
            if not mario.spring and not mario.clear or mario.clear==true or mario.clear=="count" then
                mario:calculateInput()
                mario:calculateMove()
        end end
        mario:calculateAnim()
    end

    function mario:calculateInput() --turns inputs into velocity (or crouch/fireball)
        local topSpeed=7
        if level.current.autoMove=="w" then topSpeed=3.5 end
    --X movement
        if mario.power~=0 and (input.down==1) and mario.vy==0 then
            mario.crouch=true mario.actionAnimTimer=0
        elseif mario.power~=0 and mario.vy==0 and self:bumpCheck(-1,true) then
            mario.crouch=true mario.actionAnimTimer=0
        elseif mario.vy==0 or mario.power==0 then mario.crouch=false end
        if input.down==1 and mario.vy==0 then mario:pipeCheck() end
        if mario.crouch then mario.vx=mario.vx*(0.93) end
        if mario.crouch and mario.vy==0 and (pixel2solid(mario.x+2-playStage.cameraOffset,mario.y-8) or pixel2solid(mario.x+13-playStage.cameraOffset,mario.y-8)) then
            if mario.jumpAnim>-7 and math.abs(mario.vx)<1 then
                if input.right==1 and (mario.vx>0 or mario.jumpAnim>-1) then mario.vx=input.right
                elseif input.left==1 and (mario.vx<0 or mario.jumpAnim>-1) then mario.vx=-input.left end
            end
        elseif (input.left==1 or input.right==1) and (not mario.crouch or mario.vy~=0) then
            if ((input.left==1 and mario.vx>0.5) or (input.right==1 and mario.vx<-0.5)) and mario.vy==0 then mario.vx=mario.vx*0.9 --drifting slower
            else --not drifting
            --max running speed 7
                if math.abs(mario.vx)<2.0 then --walking under 2.0
                    mario.vx=mario.vx+input.right*(math.random(3,5)/10)
                    mario.vx=mario.vx-input.left*(math.random(3,5)/10)
                elseif math.abs(mario.vx)<4.5 then
                    mario.vx=mario.vx+input.right*0.3
                    mario.vx=mario.vx-input.left*0.3
                elseif math.abs(mario.vx)<=topSpeed and mario.vy==0 then
                    mario.vx=mario.vx+input.right*0.12
                    mario.vx=mario.vx-input.left*0.12
                elseif math.abs(mario.vx)<=topSpeed and mario.vy~=0 and ((input.right==1 and mario.vx<-0.5) or (input.left==1 and mario.vx>0.5)) then
                    mario.vx=mario.vx+input.right*0.6
                    mario.vx=mario.vx-input.left*0.6 end end
        elseif not mario.crouch then -- not holding inputs
            if mario.vy==0 then mario.vx=mario.vx*(0.8) -- on ground
            else mario.vx=mario.vx*(0.95) end -- in air
        end
        if mario.vx>=topSpeed then mario.vx=topSpeed elseif mario.vx<=-topSpeed then mario.vx=-topSpeed end 
        if math.abs(mario.vx)<0.1 then mario.vx=0 end --movement minumum, prevents velocity of 0.00001626 for example
    --Y movement
        if input.up==1 and self.vy==0 and self:gravityCheck(0,true,true) and not playStage.disableJumping then  --up arrow pressed and on the floor (no double jumps)
            local runningBoost=(math.abs(mario.vx)>3) and math.abs(mario.vx) or 0
            mario.jumpAnim=(mario.jumpAnim<=0) and 3 or mario.jumpAnim
            self.vy=18+runningBoost--for a maximum of 25, jump ~5.5 blocks. without boost is 4 blocks (idle)
        else mario.vy=(mario.vy>0) and mario.vy*0.745 or mario.vy end --slow down upwards velocity when jumping (lower is floatier)
        mario.vy=(math.abs(mario.vy)<0.6) and 0 or mario.vy --movement minumum, prevents velocity of 0.00001626 for example
    --SPECIAL ACTIONS
        if input.action==1 and mario.power==2 and not mario.crouch then
            local fireballCount=0
            for _, particleName in ipairs(entityLists.particle) do
                if string.match(particleName, "fireball") then
                    fireballCount = fireballCount + 1
                end
            end
            if fireballCount<2 then
                mario.actionAnimTimer=2
                if mario.dir=="L" then objAPI:createObj("fireball_L",mario.x,mario.y)
                else objAPI:createObj("fireball_R",mario.x+8,mario.y)
    end end end end

    function mario:calculateMove() --use velocity to update position
        if mario.vtempY ~= nil then
            mario.vy=mario.vtempY
            mario.vtempY=nil
        end
        mario.vx=math.round(mario.vx,2)
        mario.vy=math.round(mario.vy,2)
    --X handling
        self:aggregateCheckX(mario.px,true) --check & confirm platform's velocity
        self:aggregateCheckX(mario.vx) --check & confirm mario's velocity
        if (mario.x<0) or (((mario.x)<playStage.cameraOffset-2) and (level.current.autoScroll or level.current.disableBackScrolling)) then --left side
            mario.x=playStage.cameraOffset-2 if mario.vx<0 then mario.vx=0 end
            if self:multiWallCheck({{13,1},{13,15}}) then mario:kill() end
            if (mario.power>0 and not mario.crouch) and self:multiWallCheck({{13,-13} or nil}) then mario:kill() end
        elseif (mario.x>(playStage.levelWidth-13)) or (((mario.x)-playStage.cameraOffset>305) and (level.current.autoScroll)) then --right side
            mario.x=305+math.ceil(playStage.cameraOffset) if mario.vx>0 then mario.vx=0 end
            if self:multiWallCheck({{2,1},{2,15},(mario.power>0) and {2,-13} or nil}) then mario:kill() end
            if (mario.power>0 and not mario.crouch) and self:multiWallCheck({{2,-13} or nil}) then mario:kill() end
        end
    --Y handling
        if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py) end
        if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy) end
    --OTHER (death plane)
        self:checkFor()
        if mario.y>216 then mario:kill() end
        mario:setNewPushV()
    end

    function mario:calculateAnim(calculateAnimForce) --handles mario's visuals (walk cycles, animations etc)
        if (not mario.powerUp and not mario.powerDown and not playStage.wait and not mario.clear and not mario.dead) or calculateAnimForce or mario.pipe then --normal gameplay
            mario.powerAnim=mario.power
            if not mario.crouch then
                if mario.vy==0 then
                    if mario.vx~=0 then
                        local velocity2cycle=0
                        if (math.abs(mario.vx))>6.5 then velocity2cycle = 1.2 elseif (math.abs(mario.vx))>4.5 then velocity2cycle = 0.6 elseif (math.abs(mario.vx))>2 then velocity2cycle = 0.3 else velocity2cycle = 0.2 end
                        mario.status="walk"..math.floor((velocity2cycle*mario.framesPassed)%3)+1 end
                    if input.left==1 and mario.vx>0 then mario.status="drift" input.right=0 --drift animation if arrow key is going opposite way to velocity
                    elseif input.right==1 and mario.vx<0 then mario.status="drift" input.left=0 end
                    if mario.vx==0 then mario.status="idle" end
                    else mario.status="jump"
                end
            else mario.status="crouch"
            end
            if mario.actionAnimTimer>0 then
                mario.actionAnimTimer=mario.actionAnimTimer-1
                mario.status="fire"
            end
        elseif mario.powerUp and playStage.wait then --powering UP in progress
            if mario.power==1 then --growing to big mario
                if playStage.framesPassedBlock-12<mario.powerAnimTimer then 
                    local animOption=(math.ceil((playStage.framesPassedBlock/2)))%2
                    if animOption==1 then mario.powerAnim=1 mario.status="grow" else mario.powerAnim=0 mario.status="idle" end
                else
                    local animOption=(math.ceil((playStage.framesPassedBlock/2)))%3
                    if animOption==0 then mario.powerAnim=0 mario.status="idle" elseif animOption==1 then mario.powerAnim=1 mario.status="grow" else mario.powerAnim=1 mario.status="idle" end
                end
            elseif mario.power==2 then --growing to fire mario
                local animOption=(math.ceil((playStage.framesPassedBlock/2)))%4
                mario.powerAnim=2
                mario.starAnim=2
            end
            if playStage.framesPassedBlock-24>mario.powerAnimTimer then --end animation
                mario.powerUp=false
                playStage.wait=false
                mario.starAnim=false
            end
        elseif mario.powerDown and playStage.wait then --powering DOWN in progress
            if mario.power==0 then
                local animOption=(math.ceil((playStage.framesPassedBlock/(flashingDelay*2))))%2
                if playStage.framesPassedBlock-12<mario.powerAnimTimer then --powering down to small mario
                    if animOption==1 then mario.powerAnim=mario.power+1 mario.status=mario.animCache else mario.powerAnim=mario.power+1 mario.status="invisible" end --flash
                else --down to big
                    mario.animCache=mario.animCache=="crouch" and "walk1" or mario.animCache
                    if animOption==1 then mario.status=mario.animCache else mario.status="invisible" end --flash
                    mario.powerAnim=mario.power
                end
            elseif mario.power==1 then --powering down to big mario
                local animOption=(math.ceil((playStage.framesPassedBlock/3)))%2
                if animOption==1 then
                    mario.powerAnim=1
                else
                    mario.powerAnim=2
                end
            end
            if playStage.framesPassedBlock-24>mario.powerAnimTimer then --end power down anim
                mario.powerDown=false
                playStage.wait=false
                mario.iFrames=playStage.framesPassed+40
            end
        elseif mario.clear then --mario cleared animation
            if type(mario.clear)=="table" then --mario turned around on flagpole
                if mario.clear[1]<=playStage.framesPassed then
                    mario.clear=true mario.clearedTimer=true
                    mario.dir="R"
                end
            elseif mario.clear=="count" then --mario disappeared/stop walking
                if (playStage.TIME-7)>=7 then
                    playStage.SCORE=playStage.SCORE+350
                    playStage.TIME=playStage.TIME-7
                elseif playStage.TIME>0 then
                    playStage.SCORE=playStage.SCORE+50*playStage.TIME
                    playStage.TIME=0 playStage.clearedTimer=playStage.framesPassed+25
                elseif playStage.clearedTimer<=playStage.framesPassed then
                    playStage:completeStage("goal")
                end
            elseif mario.clear==true then --mario walking from flagpole
                if not playStage.wait then mario:calculateAnim(true) end
                if mario.clearedTimer==true then
                    if mario.vy==0 then
                        mario.clearedTimer=playStage.framesPassed+31
                        level.current.autoMove="w"
                        if mario.skipAnim then mario:kill()
                        else mario.dir="R" end
                    end
                elseif mario.clearedTimer<=playStage.framesPassed then mario:kill()
                end
                if pixel2ID(mario.x,mario.y+8,true)==85 or pixel2ID(mario.x,mario.y+8,true)==86 then --castle door tiles
                    mario:kill() mario.y=300 --hide him
                end
            elseif (mario.y+4)<mario.clear then mario.y=mario.y+4  --mario sliding down flagpole
                mario.status="climb"..math.floor((0.5*playStage.framesPassed)%2)+1
            else mario.y=mario.clear --mario at bottom of flagpole
                mario.status="climb2"
            end
        elseif mario.dead then --mario death animation
            mario.powerAnim=0
            if mario.vdeath<-0.5 and (playStage.framesPassedBlock>mario.deathAnimTimer+12) then
                mario.y=mario.y+mario.vdeath
                mario.vdeath=(mario.vdeath+0.2)*0.8
            elseif (mario.vdeath<0 and mario.vdeath>-0.5) or mario.vdeath>0 then
                mario.vdeath=(math.abs(mario.vdeath)+0.3)*1.09
                mario.y=mario.y+mario.vdeath
            end
            if mario.y>220 then
                if not mario.respawnTime then
                    mario.respawnTime=playStage.framesPassedBlock+18
                end
                if playStage.framesPassedBlock>mario.respawnTime then playStage:completeStage("dead")
        end end end
        if mario.pipe then
            local pipeActions={ --{x/y, speed, set vx to (anim purposes), move x from pipeX, move y from pipeY}
                {"x",1.5,5,3,0,"L"}, --left
                {"y",1.5,0,8,0.5,"R"}, --up
                {"x",-1.5,-5,-1,0,"R"}, --right
                {"x",0,0,0,0,"R"} --teleport (exit)
            }
            local function limit(num,lim) if num>lim then num=lim end return num end
            local TYPE=level.current.pipeData[mario.pipe[1]][mario.pipe[2]][3]
            pipeActions=pipeActions[TYPE]
            mario.pipe[5]=mario.pipe[5]+1 --timer
            local pipeTime=mario.pipe[5]
            
            if pipeTime<=11 then --init enter pipe, small zoom
                mario[pipeActions[1]]=mario[pipeActions[1]]+pipeActions[2]
                mario.vx=pipeActions[3]
                mario.pipe[6]=limit(mario.pipe[6]+1,6) --transition timer
            elseif pipeTime<=26 then --complete zoom and show black
                mario.pipe[6]=mario.pipe[6]+0.35 --transition timer
            elseif pipeTime==27 then --swap initial entr/exit with opposite
                mario.pipe[2]=mario.pipe[3] --could have just done 3-value here tbh, too late. cant be bothered
            elseif pipeTime==28 then --perform any mid-transition calculation
                mario.pipe[6]=7.5
                local pipeX,pipeY=(level.current.pipeData[mario.pipe[1]][mario.pipe[2]][1]-1)*16,212-16*level.current.pipeData[mario.pipe[1]][mario.pipe[2]][2]
                -- print(pipeX,pipeY,"|",TYPE)
                mario.vx=0 mario.vy=0
                mario.dir=pipeActions[6]
                mario:teleport(pipeX+pipeActions[4],pipeY+pipeActions[5])
                for i=1,#level.current.loadedObjects do
                    plot2place(unpack(level.current.loadedObjects[i]))
                end
                level.current.loadedObjects={}
                playStage:clearEntities()
                -- mario[pipeActions[1]]=mario[pipeActions[1]]+pipeActions[2]*11
            elseif pipeTime<=39 then --zoom small out again
                mario[pipeActions[1]]=mario[pipeActions[1]]-pipeActions[2]
                if pipeTime<=32 then
                    mario.pipe[6]=-limit(-(mario.pipe[6]-0.35),-6) --transition timer
                elseif pipeTime>=35 then
                    mario.pipe[6]=mario.pipe[6]-1.25 --transition timer
                end
                if pipeTime==39 then --return game to playing state
                    mario.pipe=false playStage.wait=false
                    playStage.transition2=false
                end
            end
            playStage.transition2=mario.pipe and {mario.x-playStage.cameraOffset+8,mario.y+8,mario.pipe[6]*4} or false
        end
        if (mario.starTimer>playStage.framesPassed) then --handle star anim and hitbox
            if not playStage.wait then
                if (mario.starTimer-70>playStage.framesPassed) then
                    mario.starAnim=2
                elseif (mario.starTimer-15>playStage.framesPassed) then
                    mario.starAnim=5 --slow down anim
                end
            end
            local h=(mario.power>0) and 16 or 0 --mario height
            objAPI:addHitBox("mario",mario.x,mario.y-h,16,16+h,"mario")
        end
        if not playStage.wait and not mario.clear and not mario.powerUp and not mario.powerDown and (mario.jumpAnim>0 or (not (mario.crouch and (pixel2ID(mario.x+2-playStage.cameraOffset,mario.y-8)==1 or pixel2ID(mario.x+13-playStage.cameraOffset,mario.y-8)==1)) and not self:aggregateCheckX(0,true,true))) and mario.vy==0 then --on ground, not jumping
            if input.right==1 then mario.dir="R"
            elseif input.left==1 then mario.dir="L" end
        end
    end

    function mario:clearedLevel(xy)
        if type(xy)=="table" then --sliding anim and such
            mario.clear=xy[1] mario.status="climb1"
            mario.x=xy[2]
        else
            mario.clear=true mario.clearedTimer=true mario.skipAnim=xy
        end mario.vx=0 mario.vy=-0.1
    end

    function mario:powerUpMario(optionalPower,forced)
        if not mario.dead and not mario.clear and not mario.powerDown then
            local proceed=true
            if optionalPower~=nil and (forced==true or optionalPower>mario.power) then
                mario.power=optionalPower
            elseif optionalPower==nil and mario.power<2 then mario.power=mario.power+1
            else proceed=false end --there is nothing to power to
            if proceed then
                playStage.wait=true
                mario.powerUp=true
                mario.powerDown=false
                mario.powerAnimTimer=playStage.framesPassedBlock
                mario:calculateAnim(true)
            end
        end
    end

    function mario:powerDownMario(optionalPower)
        if mario.power>0 and not mario.dead and not mario.clear and not mario.powerDown and not mario.powerUp and not (mario.iFrames>playStage.framesPassed) then
            mario.power=mario.power-1
            playStage.wait=true
            mario.powerDown=true mario.powerUp=false mario.iFrames=-1
            mario.powerAnimTimer=playStage.framesPassedBlock
            mario.animCache= mario.status=="invisible" and mario.animCache or mario.status --cant be invisible during it
        elseif not mario.dead and not mario.clear and not (mario.iFrames>playStage.framesPassed) and not mario.powerDown and mario.power==0 then
            mario.kill()
        end
    end

    function mario:powerStarMario(optionalLength)
        if optionalLength==nil then
            mario.starTimer=playStage.framesPassed+200
        else
            mario.starTimer=playStage.framesPassed+optionalLength
        end
    end

    function mario:kill()
        if mario.clear then
            level.current.autoMove=nil mario.clear="count"
            if mario.vy==0 then mario.status="idle" self.vx=0
                if not mario.skipAnim then mario.dir="L" end
            end
        else
            mario.vdeath=-11
            mario.respawnTime=false
            mario.status="death"
            playStage.wait=true
            mario.powerDown=false
            mario.powerUp=false
            mario.dead=true
            mario.power=0 mario.powerAnim=0
            mario.jumpAnim=0
            mario.deathAnimTimer=playStage.framesPassedBlock
    end end

    function mario:teleport(x,y)
        local searchL,searchR,wait,offset=mario.x,mario.x,playStage.wait,0.001
        mario.x,mario.y=x,y
        playStage.cameraOffset=mario.x-151
        playStage.cameraBias=30
        playStage.wait=false
        for i=#level.current.scrollStopL,1,-1 do
            if ((mario.x+8)>level.current.scrollStopL[i]) then
                searchL=(level.current.scrollStopL[i]+122)-mario.x
                -- if searchL>159 then searchL=x end
                break
        end end
        for i=1,#level.current.scrollStopR do
            if ((mario.x+8)<level.current.scrollStopR[i]) then
                searchR=((8/7)*mario.x)-(1318/7)
                break
        end end
        if searchL<searchR then searchR=-searchL offset=-offset end
        mario.x=x-searchR
        playStage:scrollCamera(0.995) print(playStage.cameraOffset,playStage.cameraTargetOffset)
        mario.x,mario.y=x,y
        playStage:scrollCamera(0.995) print(playStage.cameraOffset,playStage.cameraTargetOffset)
        playStage.wait=wait
    end

    function mario:pipeCheck() --print("000000000000")
        if (not (playStage.wait or mario.dead or mario.powerDown or mario.powerUp or mario.clear)) and (mario.vy==0 and (input.down or mario.vx==0)) then --this is starting to become a mess, lol. perhaps more hindsight would be better......
            local success=false --print(self:gravityCheck(self.vy,true,true))
            local function rndPos(v,n) n=n or 16 return math.floor((v+(n/2))/n)*n end
            for pipeID=1,#level.current.pipeData do --cycle thru all pipes
                local pipe=level.current.pipeData[pipeID] --less typing
                for i=1,2 do --entrance, exit
                    local TYPE=pipe[i][3]
                    local x,y=(pipe[i][1]-1)*16,212-16*(pipe[i][2])
                    local mX,mY=rndPos(mario.x),rndPos(mario.y)+4 --mario x, mario y.. this is surely not too cryptic?
                    -- print("entrance, exit",pipeID,"pipeID,x,y,TYPE,mario.x,mario.y",pipeID,x,y,TYPE,mario.x,mario.y)
                    if input.down and TYPE==2 and self:gravityCheck(self.vy,true,true) then --pipe ID 2 (pipe facing up)
                        if ((rndPos(mario.x-8,8)==x) and ((mY+16)==y)) then --yeah you gotta stand in the middle 16 pixels of the 32 on the pipe top
                            success=true mario.vx=0
                        end
                    elseif input.stor.right>=4 and mario.dir=="R" and TYPE==1 and self:gravityCheck(self.vy,true,true) then --pipe ID 1 (pipe facing left) [assumes bumped into wall]
                        if (((mX+16)==x) and (mY==y)) then --same x and y (plus or minus 8 px)
                            success=true
                        end
                    elseif input.stor.left>=4 and mario.dir=="L" and TYPE==3 and self:gravityCheck(self.vy,true,true) then --pipe ID 3 (pipe facing right) [assumes bumped into wall]
                        if ((mX==(x+16)) and (mY==y)) then --same x and y (plus or minus 8 px)
                            success=true
                        end
                    end
                    if success==true then
                        -- print(pipeID,"|",x,y,"|",TYPE,"|",mario.x,mario.y,"|",mX,mY)
                        mario.pipe={pipeID,i,3-i,"enter",0,0} --pipeID, initial entr/exit, depart entr/exit, state, timer, transition timer
                        playStage.wait=true
                        success=false
                    end
                end
            end
        end
    end

    function mario:draw(gc)
        local drawOffset=0
        local star=""
        if mario.powerAnim~=0 then drawOffset=16 end
        if mario.jumpAnim>-7 then 
            if mario.jumpAnim>1 then --literally just so that he makes contact with the floor if jump is held. i know, animating a fake jump that isnt even happening
                if not mario.crouch then mario.status="jump" end
                drawOffset=drawOffset+2
            end
            mario.jumpAnim=mario.jumpAnim-1 
        end
        if mario.starAnim~=false then
            local animOption=(math.ceil((playStage.framesPassedBlock/mario.starAnim)))%4
            if animOption~=3 then
                if mario.powerAnim>0 then
                    mario.powerAnim=2
                else
                    mario.powerAnim=0
                end
                star="star"..animOption
            end
        end
        if mario.iFrames>playStage.framesPassed and not playStage.wait and not mario.powerUp and not mario.powerDown then --currently under influence of iframes
            local animOption=(math.ceil((playStage.framesPassed/flashingDelay)))%2
            if animOption==1 then mario.animCache=mario.status mario.status="invisible" end
        end
        local status=mario.dir..((star=="" or mario.powerAnim<=1) and mario.powerAnim or "1")..mario.status..star
        if playStage.EDITOR and not playStage.wait and not mario.powerUp and not mario.powerDown and mario.status~="invisible" then
            table.insert(mario.trail,1,{status,mario.x,mario.y-drawOffset+8})
            mario.trail[41]=nil --prevent list from becoming too long, if you increase this then the trail gets longer...
        end
        if mario.status~="invisible" then
            gc:drawImage(texs[status],mario.x-playStage.cameraOffset,mario.y-drawOffset+8) --draw... mario.
        end
    end

    function mario:handleStomp()
        mario.hitCount=mario.hitCount+1
        if mario.hitCount~=0 then
            if mario.hitCount<#hitProgressionMario+1 then
                objAPI:addStats("points",hitProgressionMario[mario.hitCount],mario.x,mario.y-16)
            else --1up
                objAPI:addStats("1up",1,mario.x,mario.y-16)
            end
        end
    end


--[[||||||||||||||||||||||||
-----[----=======----]------
-----[-===OBJECTS===-]------
-----[----=======----]------
||||||||||||||||||||||||||]]

--------------------------
------ORB FUNCTIONS------- NEW drawing format
--------------------------
objMagicOrb=class(objAPI)

    function objMagicOrb:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"inner",{16,16,false,false},{posX,posY},0,0)
        self.status=1 self.GLOBAL=true self.animTimer=0 self.isBouncy=true self.allowStarCollision=true
        local v=self.TYPE:split("_")
        self.animType=(v[2]=="a0") self.moveType=(v[3]=="m1") --i think the animtype is reversed, just roll with it tbh
        self.interactSpring=self.moveType self.disableStarPoints=true
    end

    function objMagicOrb:logic() --handle both movement and animation
        if not self.dead then
            self:checkMarioCollision({"clear",self.animType},true)
            if self.moveType then
                self:aggregateCheckX(self.px,true)
                self:aggregateCheckX(self.vx)
                self:calculateAccelerationY()
                if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py) end
                if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy)      end
                self:setNewPushV() self:checkFor()
    end end end

    function objMagicOrb:hit()
    end

    function objMagicOrb:draw(gc,x,y,TYPE,isEditor,isIcon)
        if not isEditor then
            local texture=self.dead and "poof_" or "magicorb_"
            if self.dead then
                if not gui.PROMPT then
                    self.animTimer=self.animTimer+1
                    self.status=((math.ceil((self.animTimer/5)))%5)+1
                    if self.animTimer>=20 then objAPI:destroy(self.objectID,self.LEVEL) playStage.wait=false end
                end
            else
                self.status=((math.ceil((playStage.framesPassed/4)))%4)+1
                if self.status==4 then self.status=2 end
            end
            if self.status~=5 then gc:drawImage(texs[texture..self.status],x,y) end
        else
            local v,status=TYPE:split("_"),((math.ceil((framesPassed/(8*flashingDelay))))%2)+1
            v=(status==1) and v[2] or v[3]
            gc:drawImage(texs.magicorb_1,x,y)
            gc:drawImage(texs["icon_"..v],x,y)
        end
    end


--------------------------
----FLAGPOLE FUNCTIONS---- NEW drawing format(ish)
--------------------------
objFlagpole=class(objAPI)

    function objFlagpole:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"background",nil,{posX,posY},0,0)
        self.despawnable=false self.my=0 self.interactSpring=false self.disableStarPoints=true
        local v=pixel2plot(self.x,self.y,true) plot2place(9,(v[1]+1),v[2]) --set hard block base
    end

    function objFlagpole:logic()
    end
    
    function objFlagpole:draw(gc,x,y,TYPE,isEditor,isIcon) --logic in draw so that it always runs...
        if isIcon then gc:drawImage(texs.flag,x,y)
        else
            gc:setColorRGB(121,202,16)
            gc:drawLine(x+7,y,x+7,y-1-(9*16))
            gc:drawLine(x+8,y,x+8,y-1-(9*16))
            gc:drawImage(texs.flagpole_top,x+4,y-8-(9*16))
            if not isEditor then
                if not gui.PROMPT then
                    if self.my==0 then
                        if not mario.clear then
                            local marioSize=(mario.power==0 or mario.crouch) and 0 or 16
                            if checkCollision(mario.x+1,mario.y-marioSize+1,14,14+marioSize,self.x+5,self.y-152,4,152) then --hit mario (side)
                                mario:clearedLevel({self.y-16,self.x-5})
                                self.my=4 mario.dir="R"
                                local height=self.y-(mario.y+16)
                                if     height>=128 then height="1up"
                                elseif height>=82  then height="2000"
                                elseif height>=58  then height="800"
                                elseif height>=18  then height="400"
                                else                    height="100" end
                                objAPI:addStats(height~="1up" and "points" or "1up",tonumber(height))
                                self.points=height
                        end end
                    else
                        if self.my<122 then self.my=self.my+4 --flag going down anim
                        elseif type(mario.clear)=="number" then --initiate walk-off
                            mario.clear={playStage.framesPassed+10} mario.dir="L" mario.x=mario.x+11
                end end end
                gc:drawImage(texs.flag,x-8,self.y+self.my+9-(9*16))
                if self.points then gc:drawImage(texs["score_"..self.points],x+11,self.y-self.my) end
            else
                gc:drawImage(texs.flag,x-8,y+1-(9*16))
                gc:drawImage(texs.HardBlock,x,y)
    end end end
--------------------------
----PLATFORM FUNCTIONS---- NEW drawing format(N/A)
--------------------------
objPlatform=class(objAPI)

    function objPlatform:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)  --platform_length~vel~MODE~distance eg, platform_3~2~lx~64
        local config=(string.sub(TYPE,10,#TYPE)):split("~")
        self.length,self.speed,self.ox,self.oy=config[1],config[2],0,0
        self:initObject(objectID,config[3],"outer",nil,{posX,posY},0,0)
        if self.TYPE=="lx" or self.TYPE=="ly" then --loops back and forth on the x/y axis
            self.distance=tonumber(config[4])
            if self.distance<0 then self.distance=math.abs(self.distance) self.speed=-self.speed end
            self.distanceTracker=self.distance
        elseif self.TYPE=="ru" or self.TYPE=="rd" then self.distanceTracker=0 end --repeats going up/down
        self.sort,self.mode=string.sub(self.TYPE,#self.TYPE,#self.TYPE),string.sub(self.TYPE,1,1)
        self.speed=(self.sort=="l" or self.sort=="d") and -math.abs(self.speed) or (self.sort=="r" or self.sort=="u") and math.abs(self.speed) or self.speed
        self.active=not (self.mode=="a" or self.mode=="f")
        self.despawnable=false self.interactSpring=false self.disableStarPoints=true
        self.GLOBAL=true --always drawn and logic applying, to reduce pop in
    end

    function objPlatform:logic() --handle both movement and animation
        if ((self.y<=-16) or( self.y>=204) or (self.x<=-(self.length*16)) or (self.x>=16*level.current.END)) and self.mode~="r" then objAPI:destroy(self.objectID,self.LEVEL) return end --despawn if needed
        self.x,self.y=self.x+self.vx,self.y-self.vy --move
        self.ox,self.oy=self.vx,self.vy
    --CHECK IF MARIO COLLIDED
        if not self.active then
            local pX,pY,marioSize=self.x,self.y+self.vy,(mario.power==0 or mario.crouch) and 0 or 16
            local pW,mX,mY=self.length*16,math.floor(mario.x+mario.px),math.floor(mario.y-mario.py)
            if ((mX+2>=pX and mX+2<=pX+pW) or (mX+13>=pX and mX+13<=pX+pW)) and mY+16==pY and mario.vy==0 then --mario is on platform
                self.active=true
        end end
    --PLATFORM MOVEMENT PATTERNS, UPDATE PLATFORM
        if self.mode=="l" then --LOOPING PLATFORMS
            if self.distanceTracker<0 then --loop back
                self.distanceTracker=self.distance self.speed=-self.speed self["v"..self.sort]=0
            else self.distanceTracker=self.distanceTracker-math.abs(self.speed)
                self["v"..self.sort]=self.speed
            end
        else
            local dir=(self.sort=="l" or self.sort=="r") and "x" or "y"
            if self.mode=="a" or self.mode=="f" then --ONE DIRECTION PLATFORMS
                if self.active then self.active=(self.mode=="f") and false or self.active
                    self["v"..dir]=self.speed
                else self["v"..dir]=0 end
            elseif self.mode=="r" then --REPEATING PLATFORMS
                self["v"..dir]=self.speed
                if self.y<=-18 and self.sort=="u" then      self.y=206
                elseif self.y>=206 and self.sort=="d" then  self.y=-18 end
        end end
        objAPI:addPlatform(self.objectID,self.x,self.y,self.length*16,self.vx,self.vy) --update the platform
    end

    function objPlatform:draw(gc,x,y,TYPE,isEditor,isIcon)
        if not isEditor then
            for i=1,self.length do
                gc:drawImage(texs["platform"],x+(i-1)*16,y+self.oy)
            end
        else
            local params=(string.sub(TYPE,10,#TYPE)):split("~")
            local length,mode=params[1],params[3]
            length=isIcon and 1 or length
            for i=1,length do
                gc:drawImage(texs["platform"],x+(i-1)*16,y)
            end
            gc:drawImage(texs["icon_"..mode],x,y)--texs.icon_ru
            local plot=pixel2plot(x-editor.cameraOffset+16,y-8,true,true)
            local plotMouse=pixel2plot(mouse.x+editor.cameraOffset,mouse.y-8,true)
            if (editor.platformSelect and editor.platformSelect[3]==true and (plot[1]==editor.platformSelect[1] and plot[2]==editor.platformSelect[2])) or ((not (editor.platformSelect or editor.displayedGroup)) and plot[1]==plotMouse[1] and plot[2]==plotMouse[2]) then
                timer2rainbow(gc,framesPassed+200,10) gc:setPen("thin","dashed")
                local distance=tonumber(params[4])
                if mode=="lx" then
                    gc:drawRect(x+distance,y,length*16,8)
                    gc:drawLine(x,y+4,x+distance,y+4)
                elseif mode=="ly" then
                    gc:drawRect(x,y-distance,length*16,8)
                    local offset=(distance<0) and {8,0} or {0,8}
                    gc:drawLine(x+length*8,y+offset[1],x+length*8,y-distance+offset[2])
    end end end end
--------------------------
-----GOOMBA FUNCTIONS----- OLD drawing format#################################################################
--------------------------
objGoomba=class(objAPI)

    function objGoomba:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2) --eg ("goomba77215",64,64,"goomba")
        self:initObject(objectID,TYPE,"inner",{16,16,true,true},{posX,posY},true,0)
        self.status=1 self.despawnable=false --for now, unless pipe spawning added
        self.turnAround=true
    end

    function objGoomba:logic() --handle both movement and animation
        self:checkStuckInWall()
        if not self.dead then
    --ANIMATION, MARIO COLLISION, X AXIS, Y AXIS + PLATFORMS
            self.status=((math.ceil((playStage.framesPassed/4)))%2)+1
            self:checkMarioCollision({"stomp",3})
            self:aggregateCheckX(self.px,true)
            self:aggregateCheckX(self.vx)
            self:calculateAccelerationY()
            if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py)      end
            if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy)      end
            self:setNewPushV() self:checkFor()
        elseif self.status==4 then self:animateDeathFlyOffscreen() --fireball/flower
        elseif self.status==3 and (self.deathAnimTimer<playStage.framesPassed) then --stomped
            objAPI:destroy(self.objectID,self.LEVEL)
        end
    end
    
    function objGoomba:hit(circumstance)
        if not self.dead then self:handleHitDefault(circumstance,4) end
    end

    function objGoomba:draw(gc,x,y,TYPE,isEditor,isIcon)
        gc:drawImage(texs[TYPE..(self.status or "1")],x,y)
    end

--------------------------
--PIRANHA PLANT FUNCTIONS- NEW drawing format
--------------------------
objPiranhaPlant=class(objAPI)

    function objPiranhaPlant:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2) --eg ("piranhaplant_1r2923",64,64,"piranhaplant_1",true)
        self:initObject(objectID,TYPE,"background",nil,{posX,posY},0,0)
        self.status=1 self.despawnable=false self.interactSpring=false
        self.moveTimer=50 --how far into the rising thing it is
        self.riseTimer=5 --frames to wait before rising
        local  TYPE=string.sub(self.TYPE,14,14) -- 1=up ↑ , 2=right → , 3=down ↓ , 4=left ←
        if     TYPE=="1" then self.move={"x",1,"y",-1}                  --up
        elseif TYPE=="2" then self.move={"y",1,"x",1}   self:moveY(-16) --right
        elseif TYPE=="3" then self.move={"x",-1,"y",1}  self:moveY(-16) --down
        elseif TYPE=="4" then self.move={"y",-1,"x",-1}                 --left
        end self:moveX(8) self:moveY(-10) self:determineHitbox()
    end

    function objPiranhaPlant:moveX(amount) self[self.move[1]]=self[self.move[1]]+self.move[2]*amount end --moves on the x axis, relative to the direction the plant is facing
    function objPiranhaPlant:moveY(amount) self[self.move[3]]=self[self.move[3]]+self.move[4]*amount end

    function objPiranhaPlant:determineHitbox()
        local  TYPE=string.sub(self.TYPE,14,14) --hardcoding is quicker, easier and more efficient than doing some cool code... i think
        if     TYPE=="1" then self.hitBoxSTOR={16,20,true,true,0,14} --up
        elseif TYPE=="2" then self.hitBoxSTOR={20,16,true,true,-4,0} --right
        elseif TYPE=="3" then self.hitBoxSTOR={16,20,true,true,0,-3} --down
        elseif TYPE=="4" then self.hitBoxSTOR={20,16,true,true,14,0} --left
        end self.hitBox=self.hitBoxSTOR
    end

    function objPiranhaPlant:logic() --handle both movement and animation
        if not self.dead then
    --CHECK IF MARIO COLLIDED
            if not (mario.starTimer>playStage.framesPassed) then
                local marioSize=(mario.power==0 or mario.crouch) and 0 or 16
                if checkCollision(mario.x+1,mario.y-marioSize+1,14,14+marioSize,self.x+2+self.hitBoxSTOR[5],self.y+2+self.hitBoxSTOR[6],self.hitBoxSTOR[1]-4,self.hitBoxSTOR[2]-4) then --hit mario (side)
                    mario:powerDownMario()
            end end
    --X/Y AXIS
            self.moveTimer=self.moveTimer+1
            if     self.moveTimer<=12 then self:moveY(2)
            elseif self.moveTimer<=36 then --stay put
            elseif self.moveTimer<=48 then self:moveY(-2)
            else self.hitBox=false self.riseTimer=self.riseTimer-1
                if (math.abs(mario.x-self.x))>=35 then
                    if self.riseTimer<=0 then
                        self.moveTimer=0 self.riseTimer=32 self.hitBox=self.hitBoxSTOR
            end end end
        else self:animateDeathFlyOffscreen()
    end end

    function objPiranhaPlant:hit(circumstance)
        if not self.dead then self:handleHitDefault(circumstance,1,"piranhaplant_3") end
    end

    function objPiranhaPlant:draw(gc,x,y,TYPE,isEditor,isIcon)
        if isEditor then
            if isIcon then
                local offsets={
                    {0,-11},{-4,0},{0,-5},{-11,0}
                }
                offsets=offsets[tonumber(string.sub(TYPE,14,14))]
                gc:drawImage(texs[TYPE.."_1"],x+offsets[1],y+offsets[2])
            else
                if TYPE=="piranhaplant_2" then x=x-16 end
                if TYPE=="piranhaplant_3" then y=y-16 end
                gc:drawImage(texs[TYPE.."_1"],x,y)
            end
        else
            self.status=((math.ceil((playStage.framesPassed/4)))%2)+1
            gc:drawImage(texs[TYPE.."_"..self.status],x,y)
        end
    end


--------------------------
---BULLET BILL FUNCTIONS-- NEW drawing format(N/A)
--------------------------
objBulletBill=class(objAPI)

    function objBulletBill:setup(objectID,posX,posY,TYPE,despawnable,fromBlaster,arg2) --eg ("bullet_L8173831",64,64,"bullet_L",true)
        self:initObject(objectID,TYPE,fromBlaster and "inner" or "outer",{16,16,false,true},{posX,posY},true,0)
        self.status=1 self.despawnable=true self.interactSpring=false self.disableStarPoints=true
        self.vx=(self.TYPE=="bullet_L") and -3 or 3
        self.timer=fromBlaster and sTimer(5) or false
        if not fromBlaster then objAPI:transferLayer(self.objectID,"inner","outer") end
    end

    function objBulletBill:logic() --handle both movement and animation
        if not self.dead then
    --MARIO COLLISION, X AXIS
            self:checkMarioCollision({"dropkill"})
            self.x=self.x+self.vx
        else self:animateDeathFlyOffscreen()
        end
    --LAYER STUFF
        if self.timer and gTimer(self.timer) then
            objAPI:transferLayer(self.objectID,self.LEVEL,"outer")
            self.LEVEL="outer"
            self.timer=false
        end
    end

    function objBulletBill:hit(circumstance) --doesnt use standard function as not much needed
        if circumstance=="mario" then self.dead=true self.vy=0.5 end
    end

    function objBulletBill:draw(gc,x,y,TYPE,isEditor,isIcon)
        gc:drawImage(texs[TYPE],x,y)
    end


--------------------------
-----BLASTER FUNCTIONS---- NEW drawing format(N/A)
--------------------------
objBlaster=class(objAPI)

    function objBlaster:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2) --possible types: blaster_L blaster_R blaster_LR
        self:initObject(objectID,TYPE,"inner",nil,{posX,posY},true,0)
        self.despawnable=false self.timer=sTimer(30) self.interactSpring=false self.disableStarPoints=true
        local v=pixel2plot(self.x,self.y,true) plot2place(99,(v[1]+1),v[2]) --make block solid
    end

    function objBlaster:logic()
        if gTimer(self.timer) then
            if (math.abs(mario.x-self.x))>=48 then --mario distance
                if mario.x<self.x and (self.TYPE=="blaster_L" or self.TYPE=="blaster_LR") and pixel2solid(self.x-8,self.y+8,true)==false then --shoot left
                    objAPI:createObj("bullet_L",self.x,self.y,nil,true)
                    objAPI:sendToFront(self.objectID,self.LEVEL)
                    self.timer=sTimer(60)
                elseif mario.x>self.x and (self.TYPE=="blaster_R" or self.TYPE=="blaster_LR") and pixel2solid(self.x+20,self.y+8,true)==false then --shoot right
                    self.timer=sTimer(60)
                    objAPI:createObj("bullet_R",self.x,self.y,nil,true)
                    objAPI:sendToFront(self.objectID,self.LEVEL)
    end end end end

    function objBlaster:draw(gc,x,y,TYPE,isEditor,isIcon)
        gc:drawImage(texs.blaster,x,y)
        if isEditor then
            local icon=(TYPE=="blaster_L") and "al" or TYPE=="blaster_R" and "ar" or "lx"
            gc:drawImage(texs["icon_"..icon],x,y)
    end end


--------------------------
------EVENT FUNCTIONS----- NEW drawing format(N/A)
--------------------------
objEvent=class(objAPI)

    function objEvent:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2) --possible types: blaster_L blaster_R blaster_LR
        self:initObject(objectID,TYPE,"inner",nil,{posX,posY},true,0)
        local eventDetails=TYPE:split("_")
        playStage.events[eventDetails[2]]=eventDetails[3]
        objAPI:destroy(objectID,"inner")
    end

    function objEvent:logic()
    end

    function objEvent:draw(gc,x,y,TYPE,isEditor,isIcon)
    end

--------------------------
------KOOPA FUNCTIONS----- OLD drawing format#################################################################
--------------------------
objKoopa=class(objAPI)

    function objKoopa:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"inner",{16,16,true,true},{posX,posY},self.vx or true,0)
        self.status=1 self.despawnable=false --for now, unless pipe spawning added
        self.turnAround=true
        self.noFall=(self.TYPE=="koopa_R")
    end

    function objKoopa:logic() --handle both movement and animation
        -- self:checkStuckInWall()
        if not self.dead then
    --ANIMATION, MARIO COLLISION, X AXIS, Y AXIS + PLATFORMS
            self.status=((math.ceil((playStage.framesPassed/4)))%2)+1
            self:checkMarioCollision({"transform","shell"..string.sub(self.TYPE,6,8),0,true,4})
            self:aggregateCheckX(self.px,true)
            self:aggregateCheckX(self.vx)
            self:calculateAccelerationY()
            if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py)      end
            if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy)      end
            self:setNewPushV() self:checkFor()
        elseif self.status==3 then self:animateDeathFlyOffscreen() --fireball/flower
        end
    end

    function objKoopa:hit(circumstance)
        if not self.dead then
            if not (self.TYPE=="koopa_B" and circumstance=="fireball") then
                self:handleHitDefault(circumstance,3)
    end end end

    function objKoopa:draw(gc,x,y,TYPE,isEditor,isIcon)
        local offset=(TYPE=="koopa_B") and 0 or -16
        if isEditor then
            if isIcon and offset==-16 then
                gc:drawImage(texs["L_"..TYPE.."_2"],x,y-11)
            else
                gc:drawImage(texs["L_"..TYPE.."_2"],x,y+offset)
            end
        else
            if not (self.status==4 and self.dead) then
                local facing=(self.vx<0) and "L_" or "R_"
                gc:drawImage(texs[facing..TYPE.."_"..self.status],x,y+offset) --eg "L_koopa_G_1"
    end end end

--------------------------
----PARAKOOPA FUNCTIONS--- NEW drawing format
--------------------------
objKoopaPara=class(objAPI)

    function objKoopaPara:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"inner",{16,16,true,true},{posX,posY},true,0)
        self.status=1 self.despawnable=false --for now, unless pipe spawning added
        self.turnAround=true self.doesBounce=(self.TYPE=="Pkoopa_G")
        local config=self.TYPE:split("_")
        self.facing="L_"
        if config[2]=="R" then self.interactSpring=false
            self.count=23 --half of 44, which is the total number of frames, add one for some reason (idk dont ask)
            if config[3]=="V" then      self.config={nil,2.774444}        --vertical (all values are precalculated from the calcHeight.tns tool)
            elseif config[3]=="H" then  self.config={2.774444,nil}        --horizontal
            elseif config[3]=="HV" then self.config={2.774444,2.55195,10} --horizontal and vertical (vertical loop is purposely offset)
            else                        self.config={nil,nil}             --stationary
    end end end

    function objKoopaPara:logic() --handle both movement and animation
        if not self.dead then
    --ANIMATION, MARIO COLLISION, X AXIS, Y AXIS + PLATFORMS
            self:checkMarioCollision({"transform",string.sub(self.TYPE,2,8),0,true,4})
            if self.TYPE=="Pkoopa_G" then --bouncing koopa
                self:aggregateCheckX(self.px,true)
                self:calculateAccelerationY()
                if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py) end
                self:setNewPushV() self:checkFor()
                self.facing=(self.vx>0) and "R_" or "L_"
            else --flying koopa
                local function calc(top,HV) return math.round((math.sin(((self.count-(HV and 17 or 0))*(180/(HV or 44)))/57.296))*top) end --44 is the total frames of the loop
                self.vx=(self.config[1]) and -calc(self.config[1]) or 0 --important! value here is inversed so they fly *up* when loaded
                self.vy=(self.config[2]) and calc(self.config[2],self.config[3]) or 0
                if self.config[1] then self.facing=(self.count%88)<=44 and "L_" or "R_"
                else self.facing=(mario.x>self.x) and "R_" or "L_" end
                self.count=self.count+1
            end
            self:aggregateCheckX(self.vx)
            if self.vy<=0 then self:gravityCheck(-self.vy) else self:bumpCheck(-self.vy) end
        elseif self.status==3 then self:animateDeathFlyOffscreen() --fireball/flower
        end
    end

    function objKoopaPara:hit(circumstance)
        if not self.dead then self:handleHitDefault(circumstance,3) end
    end

    function objKoopaPara:draw(gc,x,y,TYPE,isEditor,isIcon)
        if isEditor then
            if isIcon then
                gc:drawImage(texs["L_"..string.sub(TYPE,1,8).."_2"],x,y-11)
            else              gc:drawImage(texs["L_"..string.sub(TYPE,1,8).."_2"],x,y-16) end
            if string.sub(TYPE,1,8)=="Pkoopa_R" then
                local params=TYPE:split("_")
                local config,icon=params[3]
                if config=="V"      then icon="ly"
                elseif config=="H"  then icon="lx"
                elseif config=="HV" then icon="m1"
                else                     icon="m0"
                end gc:drawImage(texs["icon_"..icon],x+8,y)
            end
        else
            if not self.dead then 
                self.status=((math.ceil((playStage.framesPassed/4)))%2)+1
            end
            gc:drawImage(texs[self.facing..string.sub(TYPE,1,8).."_"..self.status],x,y-16)
    end end

--------------------------
------SHELL FUNCTIONS----- NEW drawing format(N/A)
--------------------------
objShell=class(objAPI)

    function objShell:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2) --eg ("shell_g77215",64,64,"shell_g",-4,false)
        self:initObject(objectID,string.sub(TYPE,1,7),"inner",{16,16,true,true},{posX,posY},arg1 or 0,0)
        local params=TYPE:split("_")
        self.status=1 self.despawnable=false self.vx=tonumber(params[3] or self.vx)
        self.koopaTimer=arg2 and playStage.framesPassed+200 or false
        self.fromKoopa=arg2 or false self.hitTimer=0 self.hitCount=0
        self.canHitSide=true self.turnAround=true
    end

    function objShell:logic() --handle both movement and animation
        self:checkStuckInWall()
        if not self.dead then
    --MARIO COLLISION, SHELL BOUNDARY, X AXIS, Y AXIS + PLATFORMS
            if self.hitTimer-playStage.framesPassed<=0 then self:checkMarioCollision({"shell"},true) end
            if self.vx~=0 then objAPI:addHitBox(self.objectID,self.x,self.y,16,16,"shell") self.canCollectCoins=true
            else self.canCollectCoins=false end
            self:aggregateCheckX(self.px,true)
            self:aggregateCheckX(self.vx)
            self:calculateAccelerationY()
            if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py)      end
            if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy)      end
            self:setNewPushV() self:checkFor()
    --ANIMATION
            if not self.dead then
                if self.koopaTimer==false then self.status=1
                elseif self.fromKoopa then
                    if self.koopaTimer<playStage.framesPassed then
                        objAPI:createObj("koopa"..string.sub(self.TYPE,6,8),self.x,self.y)
                        objAPI:destroy(self.objectID,self.LEVEL) self.status=0
                    elseif (self.koopaTimer-7<playStage.framesPassed) then self.status=2
                    elseif (self.koopaTimer-45<playStage.framesPassed) then
                        local animOption=((math.ceil((playStage.framesPassed)))%4)
                        self.status=(animOption==0 or animOption==2) and 1 or (animOption==1) and 4 or 5
                    else self.status=1
                    end
                else self.koopaTimer=false
            end end
        elseif self.dead then self:animateDeathFlyOffscreen() --fireball/flower
        end
    end

    function objShell:handleShellPoints()
        self.hitCount=self.hitCount+1
        if self.hitCount~=0 then
            if self.hitCount<(#hitProgressionKoopa+1) then objAPI:addStats("points",hitProgressionKoopa[self.hitCount],self.x,self.y+16)
            else objAPI:addStats("1up",1,self.x,self.y+16)
    end end end

    function objShell:hit(circumstance)
        if not self.dead then
            if not (self.TYPE=="shell_B" and circumstance=="fireball") then
                self:handleHitDefault(circumstance,3)
    end end end

    function objShell:draw(gc,x,y,TYPE,isEditor,isIcon)
        if isEditor then
            gc:drawImage(texs[string.sub(TYPE,1,7).."_1"],x,y)--"shell_R_1"
            local config=TYPE:split("_")
            local icon=tonumber(config[3])
            if     icon==-4 then icon="al"
            elseif icon==4  then icon="ar"
            elseif icon==-6 then icon="a2"
            elseif icon==6  then icon="a1"
            else icon=false end
            if icon then gc:drawImage(texs["icon_"..icon],x,y) end
        else
            if self.status~=0 then
                local offsetY=0 if not studentSoftware and (self.status==4 or self.status==5) then offsetY=-2 end
                gc:drawImage(texs[TYPE.."_"..self.status],x,y+offsetY)--"shell_R_1"
    end end end

--------------------------
-----BOWSER FUNCTIONS----- NEW drawing format
--------------------------
objBowser=class(objAPI)

    function objBowser:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2) --eg ("goomba77215",64,64,"goomba")
        self:initObject(objectID,TYPE,"inner",{32,32,true,true,0,-16},{posX,posY,32},1,0)
        self.status=1 self.despawnable=false
        self.turnAround=true self.hp=5 self.destroyShell=true
        self.jumpCountdown=-1
        self.fireCountdown=-100
        self.turnCountdown=120
        self.maxRange={posX-64,posX+64}
    end

    function objBowser:logic() --handle both movement and animation
        self:checkStuckInWall()
        if not self.dead then
            self.jumpCountdown=self.jumpCountdown-1
            self.fireCountdown=self.fireCountdown-1
            self.turnCountdown=self.turnCountdown-1
            if self.jumpCountdown<1 then
                if self.jumpCountdown==0 and self.vy==0 then
                    self.vy=12
                end
                self.jumpCountdown=math.random(20,75)
            end
            if mario.x>self.x then
                self.vx=1.5 self.fireCountdown=70
            else
                self.vx=sign(self.vx)
                if     self.x<self.maxRange[1] then self.vx=1
                elseif self.x>self.maxRange[2] then self.vx=-1
                elseif self.turnCountdown<1 and (self.x>(self.maxRange[1]+16)) and (self.x<(self.maxRange[2]-16)) then
                    self.vx=-self.vx
                    self.turnCountdown=math.random(100,280)
            end end
            if self.vy==0 then self.lastY=pixel2snapgrid(0,self.y,16,16,false)[2] end
            --table.insert(debugBoxes,{self.x-16,self.lastY,24,16})
            --table.insert(debugBoxes,{self.x-16,self.lastY-16,24,16})
            --table.insert(debugBoxes,{self.x-16,self.lastY-16-16,24,16})
    --ANIMATION, MARIO COLLISION, X AXIS, Y AXIS + PLATFORMS
            self:checkMarioCollision({false},true,-16)
            self:aggregateCheckX(self.px,true)
            if self.fireCountdown>1 then
                self:aggregateCheckX(self.vx)
            elseif self.fireCountdown<-10 then
                objAPI:createObj("flame_L",self.x-20,self.y-16,nil,self.lastY-math.random(0,2)*16)
                self.fireCountdown=math.random(10,120)
            end despook=self.turnCountdown
            self:calculateAccelerationY(1.03,-4.5)
            if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py)      end
            if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy)      end
            self:setNewPushV() self:checkFor()
            self.facing=(mario.x>self.x) and "R" or "L"
        elseif self.status==3 then self:animateDeathFlyOffscreen() --fireball/flower
        end
    end

    function objBowser:hit(circumstance)
        -- if not self.dead then self:handleHitDefault(circumstance,4) end
        if not self.dead then
            if circumstance=="fireball" or circumstance=="shell" then
                self.hp=self.hp-1
                if self.hp<=0 then self:hit("mario") end
            elseif circumstance=="mario" then
                self:handleHitDefault(circumstance,3)
            end
        end
    end

    function objBowser:draw(gc,x,y,TYPE,isEditor,isIcon)
        local offsets={
            ["L"]={{8,-8},{16,8},{0,-16}},
            ["R"]={{0,-8},{0,8},{16,-16}}
        }
        local dir,status,hp,mouth=self.facing or "L",(not isEditor) and ((math.ceil((playStage.framesPassed/4)))%2)+1 or 1,self.hp or 100 --[[big value]],(self.fireCountdown and self.fireCountdown<1) and 2 or 1
        if isIcon then
            gc:drawImage(texs["bowser_mouth_1_L"],x,y)
        else
            local facingOffset=(dir=="L") and -3 or 3
            gc:drawImage(texs["bowser_body_"..dir],x+offsets[dir][1][1]+facingOffset,y+offsets[dir][1][2])
            gc:drawImage(texs["bowser_walk_"..status.."_"..dir],x+offsets[dir][2][1]+facingOffset,y+offsets[dir][2][2])
            gc:drawImage(texs["bowser_mouth_"..mouth.."_"..dir],x+offsets[dir][3][1]+facingOffset,y+offsets[dir][3][2])
            if hp<5 and hp>0 then
                gc:setColorRGB(255,255,255)
                gc:fillRect(x+8+facingOffset,y-16,16,2)
                gc:setColorRGB(255,0,0)
                gc:fillRect(x+8+facingOffset,y-16,16*(hp/5),2)
    end end end

    -- gc:drawImage(texs["bowser_body_"..dir],EDITOR[1]-editor.cameraOffset+offsets[dir][1][1],EDITOR[2]+8+offsets[dir][1][2])
    -- gc:drawImage(texs["bowser_walk_1_"..dir],EDITOR[1]-editor.cameraOffset+offsets[dir][2][1],EDITOR[2]+8+offsets[dir][2][2])
    -- gc:drawImage(texs["bowser_mouth_1_"..dir],EDITOR[1]-editor.cameraOffset+offsets[dir][3][1],EDITOR[2]+8+offsets[dir][3][2])

--------------------------
---BOWSER FLAME FUNCTIONS-- NEW drawing format
--------------------------
objBowserFlame=class(objAPI)

    function objBowserFlame:setup(objectID,posX,posY,TYPE,despawnable,moveToY,arg2)
        self:initObject(objectID,TYPE,"inner",{16,4,false,false},{posX,math.round(posY+4)},true,0)
        self.status=1 self.despawnable=true self.interactSpring=false
        self.vx=(self.TYPE=="flame_L") and -3 or 3
        self.moveToY=moveToY and math.round(moveToY+4) or self.y
        self.disableStarPoints=true
    end

    function objBowserFlame:logic() --handle both movement and animation
        self:checkMarioCollision({"fire"},true)
        self.x=self.x+self.vx
        if self.y~=self.moveToY then
            self.y=self.y+sign(self.moveToY-self.y)
    end end

    function objBowserFlame:hit(circumstance) --no interaction
    end

    function objBowserFlame:draw(gc,x,y,TYPE,isEditor,isIcon)
        if isEditor then
            local offset=(TYPE=="flame_L") and -8 or 0
            gc:drawImage(texs[TYPE.."_1"],x+offset,y+4)
        else
            gc:drawImage(texs[TYPE.."_"..((math.ceil((playStage.framesPassed/3)))%2)+1],x,y)
        end
    end

--------------------------
----POWER-UP FUNCTIONS---- OLD drawing format#################################################################
--------------------------
objPowerUp=class(objAPI)

    function objPowerUp:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2) --eg ("mushroom37253",64,16,"mushroom",true)
        self:initObject(objectID,TYPE,"inner",{16,16,false,false},{posX,posY},true,0)
        if string.sub(TYPE,1,1)=="P" then
            if mario.power==0 then self.TYPE="mushroom"
            elseif mario.power>0 then self.TYPE="fireflower" end
        end self.disableStarPoints=true
        self.status=(self.TYPE=="mushroom" or self.TYPE=="mushroom1up") and "" or 1
        self.despawnable=despawnable
        if despawnable==true then self.blockTimer=playStage.framesPassed+(4-1) self.y=self.y-4
        else self.blockTimer=playStage.framesPassed end
        self.vx=(self.TYPE=="fireflower") and 0 or (level.current.allowBidirectionalSpawning==true and (mario.x<self.x)) and -2 or 2
        self.doesBounce=(self.TYPE=="star") self.turnAround=true self.allowStarCollision=true
    end

    function objPowerUp:use() objAPI:destroy(self.objectID,self.LEVEL)
        if self.TYPE=="mushroom1up" then objAPI:addStats("1up",1,self.x,self.y)
        else    if self.TYPE=="mushroom" then       mario:powerUpMario(1)
                elseif self.TYPE=="fireflower" then mario:powerUpMario(2)
                elseif self.TYPE=="star" then       mario:powerStarMario()
                end objAPI:addStats("points",1000,self.x,self.y) end
    end

    function objPowerUp:logic() --handle both movement and animation
        if self.blockTimer<playStage.framesPassed then
    --MARIO COLLISION, X AXIS, Y AXIS + PLATFORMS
            self:checkStuckInWall()
            self:checkMarioCollision({"powerup"},true)
            self:aggregateCheckX(self.px,true)
            self:aggregateCheckX(self.vx)
            self:calculateAccelerationY()
            if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py)      end
            if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy)      end
            self:setNewPushV() self:checkFor()
    --ANIMATION
        else self.y=self.y-4 --rise from block
        end
        if self.TYPE=="fireflower" or self.TYPE=="star" then
            self.status=((math.ceil((playStage.framesPassed/flashingDelay)))%4)+1
    end end

    function objPowerUp:hit(circumstance)
        if self.blockTimer<playStage.framesPassed then
            if (circumstance=="block" and self.vy<=0) or (level.current.enablePowerUpBouncing and circumstance~="block") then
                self.vy=10
    end end end

    function objPowerUp:draw(gc,x,y,TYPE,isEditor,isIcon)
        local status=self.status or (TYPE=="fireflower" or TYPE=="star") and "1" or ""
        gc:drawImage(texs[TYPE..status],x,y)
    end

--------------------------
-----SPRING FUNCTIONS----- NEW drawing format(N/A)
--------------------------
objSpring=class(objAPI)

    function objSpring:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"inner",{16,16,false,false},{posX,posY},0,0)
        self.status=1 self.GLOBAL=true self.springData={}
        if self.TYPE=="spring_O" then     self.bounceHeight=16
        elseif self.TYPE=="spring_B" then self.bounceHeight=8
        elseif self.TYPE=="spring_R" then self.bounceHeight=24
        end self.boostHeight=self.bounceHeight*1.5
        self.disableStarPoints=true
    end

    function objSpring:logic() --handle both movement and animation
        -- self.status=((math.ceil((playStage.framesPassed/4)))%3)+1
        -- self:checkMarioCollision({"clear",self.animType},true)
        local function check(entity)
            if not entity.spring and entity.interactSpring and checkCollision(entity.x+1,entity.y+1,(entity.w or 16)-2,16,self.x+1,self.y,15,1) and (entity.vy<0 or entity.py<0 or self.py>0 or self.vy>0) then
                entity.y=self.y-12 self.status=2 table.insert(self.springData,{0,entity,entity.vx,self.bounceHeight,self.boostHeight}) entity.vx=0
        end end
        local function checkLists()
            for k in pairs(entityLists) do --do all entity lists
                local focusedList=entityLists[k]
                for i=1,#focusedList do --for all entities within the list
                    local entity=allEntities[focusedList[i]]
                    check(entity)
        end end end
        checkLists() check(mario)
        for i=#self.springData,1,-1 do
            local springData=self.springData[i]
            local entity=springData[2]
            springData[1]=springData[1]+1
            if springData[1]==2        then self.status=3 entity.vy=0 entity.spring=true --fixes softlock when mario has cleared a level while bouncing on springs
            elseif springData[1]==4    then self.status=2
                entity.vy=(entity.objectID=="mario" and input.stor.up>-8) and springData[5] or springData[4]
                entity.vx=entity.objectID=="mario" and 0 or springData[3]
                entity.spring=false
            elseif springData[1]==6    then self.status=1 table.remove(self.springData,i)
            end
            if entity.spring then entity.y=(self.status==3 and self.y-7) or (self.status==2 and self.y-12) or self.y-16 end
        end
        -- for i=1,#self.removeEntities do table.remove(self.springData,self.removeEntities[i]) end
        self:aggregateCheckX(self.px,true)
        self:aggregateCheckX(self.vx)
        self:calculateAccelerationY()
        if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py) end
        if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy) end
        self:setNewPushV() self:checkFor()
    end

    function objSpring:hit(circumstance)
        if self.vy<=0 and circumstance=="block" then
            self.vy=6
    end end

    function objSpring:draw(gc,x,y,TYPE,isEditor,isIcon)
        local status=self.status or 1
        local offset=(status==2) and 4 or (status==3) and 9 or 0
        gc:drawImage(texs[TYPE.."_"..status],x,y+offset)
    end

--------------------------
----FIREBALL FUNCTIONS---- OLD drawing format#################################################################
--------------------------
objFireball=class(objAPI)

    function objFireball:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"particle",nil,{posX,posY,8,8},TYPE=="fireball_L" and -6 or 6,-0.5)
        self.timer=false self.despawnable=true self.status=((math.ceil((framesPassed/2)))%4)+1
        self.doesBounce=7 self.isFireball=true self.disableStarPoints=true self.interactSpring=false
    end

    function objFireball:handleFireballHit()
        self.dead=true self.timer=1
        self.x,self.y=self.x-4,self.y-4
        self.TYPE="fireball_A"
        self.status=1
    end

    function objFireball:logic()
        if not self.dead then
            objAPI:addHitBox(self.objectID,self.x,self.y,12,12,"fireball")
    --X AXIS, Y AXIS + PLATFORMS
            self:aggregateCheckX(self.px,true)
            self:aggregateCheckX(self.vx)
            self:calculateAccelerationY(0.85)
            if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py)      end
            if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy)      end
            self:setNewPushV() self:checkFor()
    --DEAD
        else self.timer=self.timer+1
            if self.timer>=(flashingDelay*3)+1 then objAPI:destroy(self.objectID,self.LEVEL) return
        end end
    --ANIMATION
        if not self.dead then self.status=((math.ceil((playStage.framesPassed/2)))%4)+1
        else self.status=math.ceil(self.timer/flashingDelay)
        end
    end

    function objFireball:draw(gc,x,y,TYPE,isEditor,isIcon)
        gc:drawImage(texs[self.TYPE..self.status],x,y)
    end

--------------------------
-------BUMPED BLOCK------- OLD drawing format#################################################################
--------------------------
objBumpedBlock=class(objAPI)

    function objBumpedBlock:create(blockX,blockY,TYPE,replaceWith) --sorta forgot why i made this specifically have its own create function
        local objectID="bumpedBlock"..#entityLists.outer+#entityLists.inner+1+framesPassed+math.random(1,99999) --assign random ID
        table.insert(entityLists.outer,tostring(objectID))
        allEntities[objectID]=objBumpedBlock() allEntities[objectID].initObject=objAPI.initObject allEntities[objectID]:setup(objectID,blockX,blockY,TYPE,replaceWith)
    end

    function objBumpedBlock:setup(objectID,blockX,blockY,TYPE,replaceWith) --eg (23,6,"UsedBlock",false)
        local v,texture=plot2pixel(blockX,blockY),blockIndex[replaceWith]["texture"][1]
        if blockIndex[replaceWith]["theme"][plot2theme(blockX)]~=nil then texture=blockIndex[replaceWith]["theme"][plot2theme(blockX)][1] end
        self:initObject(objectID,texture,"outer",nil,{v[1],v[2]},true,0)
        self.yA=self.y self.replaceWith={blockX,blockY,replaceWith} self.interactSpring=false
        self.animCount=0 self.despawnable=true plot2place(99,blockX,blockY) --barrier
        self.disableStarPoints=true
    end

    function objBumpedBlock:logic()
        if self.animCount<3 then
            objAPI:sendToFront(self.objectID,self.LEVEL)
            objAPI:addHitBox(nil,self.x+1,self.y-16,14,16,"block")
        end
        if self.animCount<=4 then self.animCount=self.animCount+1
            self.yA=self.y-math.round(((math.sin((self.animCount*30)/57.296))*8),0) --math..?
        else objAPI:destroy(self.objectID,self.LEVEL)
            plot2place(self.replaceWith[3],self.replaceWith[1],self.replaceWith[2])
        end
    end

    function objBumpedBlock:draw(gc,x,y,TYPE,isEditor,isIcon)
        gc:drawImage(texs[TYPE],x,self.yA+8)
    end

--------------------------
-----MULTICOIN BLOCK------ NEW drawing format(N/A)
--------------------------
objMultiCoinBlock=class(objAPI)
        
    function objMultiCoinBlock:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"background",nil,{posX,posY},true,0)
        self.despawnable=false self.GLOBAL=true self.timer=sTimer(100) self.interactSpring=false self.disableStarPoints=true
        objAPI:createObj("coin",self.x,self.y,true)
    end

    function objMultiCoinBlock:logic()
        if cTimer(self.timer)<=0 then objAPI:destroy(self.objectID,self.LEVEL)
        elseif cTimer(self.timer)==1 then --start ending the multi coin period
            local config=self.TYPE:split("_")
            if (pixel2ID(self.x+16,self.y,true)~=99) then pixel2place(tonumber(config[2]),self.x+16,self.y,true) end --get rid of the infinite coin block at all costs
            for i=1,#entityLists.outer do --now THIS is a stupid workaround to a problem i caused, finds the bumped block animation and changes what it replaces
                local objectID=entityLists.outer[i]
                if string.sub(objectID,1,11)=="bumpedBlock" and allEntities[objectID].x==self.x and allEntities[objectID].y==self.y then
                    allEntities[objectID].replaceWith[3]=tonumber(config[2])
    end end end end

    function objMultiCoinBlock:draw(gc,x,y,TYPE,isEditor,isIcon) end -- ...nothing to draw

--------------------------
-----BRICK PARTICLES------ OLD drawing format#################################################################
--------------------------
objBrickParticle=class(objAPI)


    function objBrickParticle:setup(objectID,posX,posY,TYPE,despawnable,thrustX,thrustY)
        self:initObject(objectID,TYPE,"particle",nil,{posX,posY},thrustX*0.4,math.abs(thrustY*8))
        self.THEME=(pixel2theme(self.x+1,true)==1) and "_underground" or (pixel2theme(self.x+1,true)==3) and "_castle" or ""
        self.animIndex=#entityLists.particle%4 self.delay=true self.status=((math.ceil((playStage.framesPassed/3)+self.animIndex))%4)+1
        self.xAnimTimer=playStage.framesPassed+15 self.GLOBAL=true self.interactSpring=false self.disableStarPoints=true
    end

    function objBrickParticle:logic()
    --ANIMATION (comes first in this case)
        self.status=((math.ceil((playStage.framesPassed/3)+self.animIndex))%4)+1
        if self.delay==true then self.delay=false return end --initial frame
    --X AXIS,Y AXIS
        if self.xAnimTimer>playStage.framesPassed then self.x=self.x+self.vx end
        if self.y>216 then objAPI:destroy(self.objectID,self.LEVEL) return
        else self.vy=(self.vy<0) and (self.vy-0.6) or (self.vy<0.7) and -0.5 or self.vy*0.4
        end self.y=self.y-(self.vy*0.8)
    end

    function objBrickParticle:draw(gc,x,y,TYPE,isEditor,isIcon)
        gc:drawImage(texs["brick_piece"..self.status..self.THEME],x,y)
    end
--------------------------
-----SCORE PARTICLES------ NEW drawing format(N/A)
--------------------------
objScoreParticle=class(objAPI)

    function objScoreParticle:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,arg1,"particle",nil,{posX-playStage.cameraOffset,posY+8},true,0)
        self.animLimit=sTimer(12) self.GLOBAL=true self.interactSpring=false self.disableStarPoints=true
    end

    function objScoreParticle:logic() 
        if gTimer(self.animLimit) then objAPI:destroy(self.objectID,self.LEVEL)
        else self.y=self.y-3
    end end

    function objScoreParticle:draw(gc,x,y,TYPE,isEditor,isIcon)
        gc:drawImage(texs["score_"..TYPE],self.x,self.y)
    end
    
--------------------------
--------COIN ANIM--------- OLD drawing format#################################################################
--------------------------
objCoinAnim=class(objAPI)

    function objCoinAnim:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"outer",nil,{posX,posY},true,0) self.disableStarPoints=true
        self.yA=self.y self.status=1 self.animCount=0 objAPI:addStats("coins",1) self.interactSpring=false
    end

    function objCoinAnim:logic() 
        if self.animCount<16 then self.animCount=self.animCount+1
            self.yA=self.y-(math.sin((self.animCount*9)/57.296))*64
            self.status=((math.ceil((playStage.framesPassed/3)))%4)+1
        else objAPI:destroy(self.objectID,self.LEVEL) objAPI:addStats("points",200,self.x,self.yA) end
        if self.animCount==16 then self.drawCondition=true end
    end

    function objCoinAnim:draw(gc,x,y,TYPE,isEditor,isIcon)
        if not self.drawCondition then gc:drawImage(texs["coin_"..self.status],x,self.yA+8)
    end end

--------------------------
----GAMEPLAY FUNCTIONS----
--------------------------

    require("modes.playstage")

--------------------------
-----EDITOR FUNCTIONS-----
--------------------------

    require("modes.editor")

--------------------------
--TITLE SCREEN FUNCTIONS--
--------------------------

    require("modes.titlescreen")

--------------------------
-------GUI FUNCTIONS------
--------------------------

    require("core.gui")

--------------------------
-------CRASH SCREEN-------
--------------------------

    require("core.recovery")

--------------------------
------FRAME FUNCTIONS-----
--------------------------

    function onpaint(gc)
        if framesPassed>22 then
            local runLogic=gameSpeed[1+framesPassed%(#gameSpeed)]
            if playStage.active==true then playStage:paint(gc,runLogic) end
            if editor.active==true then editor:paint(gc) end
            if titleScreen.active==true then titleScreen:paint(gc) end
            if not timerState then
                gc:drawImage(texs.safeSleep,0,92)
                if checkCollision(mouse.x,mouse.y,1,1,1,92,18,18) then gui.TEXT="Safe sleep mode active!" end
            end
            gui:paint(gc)

            if framesPassed==23 then
                recoveredLevelString=var.recall("recoveredLevel")
                if recoveredLevelString and type(recoveredLevelString)=="string" then
                    print("Recovered level data found, loading...")
                    gui:createPrompt("RECOVER LEVEL",{"A LEVEL WAS FOUND","FROM THE LAST SESSION.","DO YOU WANT TO LOAD IT?"},{{"YES","recoveryes"},{"NO","close"}},true,false)
                    -- editor:generate(recoveredLevelString)
                    -- editor.active=true
                    -- titleScreen.active=false
                end
            end
            -- if framesPassed==1000 then
            --     local err=2+"e" -- this is just to test the error handling
            -- end
        else --load stuff
            gc:fillRect(0,0,screenWidth,screenHeight)
            gc:setColorRGB(173,170,173)
            drawSlantedRect(gc,{284,187,10}) drawSlantedRect(gc,{293,187,10})
            drawFont2(gc,"O", 288, 196,"left",0)
            drawFont2(gc,"P", 297, 196,"left",0)
            drawFont2(gc,"7", 306, 196,"left",0)
            gc:setColorRGB(255,255,255)
            gc:drawRect(119,192,80,10)
            gc:fillRect(121,194,77*0.1,7)
            if framesPassed==1 then
                loadFont()
            elseif framesPassed==2 then
                gc:fillRect(121,194,77*0.16,7)
                gc:drawImage(texs.R0walk3,151,170)
                drawFont(gc,"LOADING nSMM - TILES", nil, nil,"centre",0)
                entityClasses={}
                for className,object in pairs(_G) do
                    if type(object)=="table" and string.sub(className,1,3)=="obj" then
                        entityClasses[className]=object
                    end
                end
            elseif framesPassed==3 then
                loadTextures("tile")
                gc:fillRect(121,194,77*0.32,7)
                gc:drawImage(texs.R0walk1,151,170)
                drawFont(gc,"LOADING nSMM - GUI TEXTURES", nil, nil,"centre",0)
            elseif framesPassed==4 then
                loadTextures("gui")
                gc:fillRect(121,194,77*0.48,7)
                gc:drawImage(texs.R0walk2,151,170)
                drawFont(gc,"LOADING nSMM - OBJECT TEXTURES", nil, nil,"centre",0)
            elseif framesPassed==5 then
                loadTextures("object")
                gc:fillRect(121,194,77*0.64,7)
                gc:drawImage(texs.R0walk3,151,170)
                drawFont(gc,"LOADING nSMM - MARIO TEXTURES", nil, nil,"centre",0)
            elseif framesPassed==6 then
                loadTextures("mario1")
                gc:fillRect(121,194,77*0.8,7)
                gc:drawImage(texs.R0walk1,151,170)
                drawFont(gc,"LOADING nSMM - RECOLOUR MARIO", nil, nil,"centre",0)
            elseif framesPassed==7 then
                loadTextures("mario2")
                gc:fillRect(121,194,77,7)
            else
                drawFont(gc,"DONE!", nil, nil,"centre",0)
                gc:fillRect(121,194,77,7)
                gc:drawImage(texs.R0jump,151,170)
                if framesPassed==22 then
                    gui=gui()
                    playStage=playStage()
                    editor=editor()
                    titleScreen=titleScreen()
                    titleScreen.active=true
                    editor.active=false
                    if notFinal then gui:createPrompt("NOT RELEASE VERSION",{"THIS VERSION IS CURRENTLY","IN DEVELOPMENT. IT MAY", "HAVE THE WRONG VERSION NUMBER","AND UNFINISHED FEATURES!!"},{{"OK","close"}},true,false) end
        end end end
        framesPassed=framesPassed+1 --global framecount
        
        local calculateFpsPer = 20

        if framesPassed % calculateFpsPer == 0 and studentSoftware then
            local currentTime = timer.getMilliSecCounter()
            local delta = currentTime - lastTime

            fps = math.floor(10000 / delta * calculateFpsPer) / 10

            lastTime = currentTime
            print("FPS: " .. fps)
            Profiler:report()
        end

        if framesPassed % 100 == 0 then
            collectgarbage()
            print("collectgarbage() called, memory usage: " .. collectgarbage("count") .. "kb")
        end
    end

--------------------------
---------START-UP---------
--------------------------
    switchTimer(true)
    print("Running!",versText,"start memory:",collectgarbage("count"),"kb")