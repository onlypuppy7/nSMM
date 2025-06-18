function initialiseVARS()
    defaultCourse="<50-v5-5~3-!-500>,1*7,*2B,1*7,*283"
    username=var.recall("author") or ""
    screenWidth=platform.window:width() screenHeight=platform.window:height()
    cursor.set("default")
    timerState=false gameSpeed={1}
    mouse={
        x=0,
        y=0,
    }
    level={
        current={},
        perm="",
    }
    framesPassed=1
    blockSelectionTEMP=1
    blockSelectionListTEMP={0,1,2,3,4,5,6,7,8,9,10,20,21,22,23,24,28,29,30,31,32,33,34,35,36,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,99,100,101,102,103,104,"mushroom","mushroom1up","fireflower","Pfireflower","star","goomba","koopa_G","koopa_R","shell_G","shell_R","bullet_L","bullet_R","blaster_L","blaster_R","blaster_LR","fireball_L","fireball_R","piranhaplant_1","piranhaplant_2","piranhaplant_3","piranhaplant_4","platform_3~1~lx~64","platform_3~1~ly~64","platform_3~1~al","platform_3~1~ar","platform_3~1~au","platform_3~1~ad","platform_3~1~fu","platform_3~1~fd","platform_3~1~fl","platform_3~1~fr","platform_3~2~ru","platform_3~2~rd"}
    hitProgressionKoopa={500, 800, 1000, 2000, 4000, 5000, 8000}
    hitProgressionMario={100, 200, 400, 500, 800, 1000, 2000, 4000, 5000, 8000} --credit mariowiki :>
    debugBoxes={}
    blockIndex={}
    typeIndex={
        goomb = {"objGoomba",        "inner"},
        koopa = {"objKoopa",         "inner"},
        Pkoop = {"objKoopaPara",     "inner"},
        shell = {"objShell",         "inner"},
        bulle = {"objBulletBill",    "inner"},
        flame = {"objBowserFlame",   "inner"},
        blast = {"objBlaster",       "inner"},
        piran = {"objPiranhaPlant",  "background"},
        bowse = {"objBowser",        "inner"},
        platf = {"objPlatform",      "outer"},
        firef = {"objPowerUp",       "inner"},
        mushr = {"objPowerUp",       "inner"},
        Pfire = {"objPowerUp",       "inner"},
        star  = {"objPowerUp",       "inner"},
        coin  = {"objCoinAnim",      "outer"},
        multi = {"objMultiCoinBlock","background"}, 
        brick = {"objBrickParticle", "particle"}, 
        score = {"objScoreParticle", "particle"}, 
        fireb = {"objFireball",      "particle"},
        flagp = {"objFlagpole",      "background"},
        magic = {"objMagicOrb",      "inner"},
        sprin = {"objSpring",        "inner"},
        event = {"objEvent",         "inner"},
    }
    nameIndex={ --this is mainly cope for not having an entity index like the block index
        ["goomba"] =         "Goomba",
        ["koopa_G"] =        "Koopa Troopa (Green)",
        ["koopa_R"] =        "Koopa Troopa (Red)",
        ["koopa_B"] =        "Buzzy Beetle",
        ["Pkoopa_G"] =       "Koopa Paratroopa (Jumping)",
        ["Pkoopa_R_V"] =     "Koopa Paratroopa (Vertical)",
        ["Pkoopa_R_H"] =     "Koopa Paratroopa (Horizontal)",
        ["Pkoopa_R_HV"] =    "Koopa Paratroopa (Horizontal, Wavering)",
        ["Pkoopa_R"] =       "Koopa Paratroopa (Stationary)",
        ["shell_G"] =        "Shell (Green)",
        ["shell_R"] =        "Shell (Red)",
        ["shell_G_-4"] =     "Shell (Green) (Slow Left)",
        ["shell_G_4"] =      "Shell (Green) (Slow Right)",
        ["shell_R_-6"] =     "Shell (Red) (Fast Left)",
        ["shell_R_6"] =      "Shell (Red) (Fast Right)",
        ["shell_B"] =        "Shell (Buzzy Beetle)",
        ["bullet_L"] =       "Bullet (L)",
        ["bullet_R"] =       "Bullet (R)",
        ["blaster_L"] =      "Bullet Blaster (L)",
        ["blaster_R"] =      "Bullet Blaster (R)",
        ["blaster_LR"] =     "Bullet Blaster (LR)",
        ["flame_L"] =        "Bowser's Flame (L)",
        ["flame_R"] =        "Bowser's Flame (R)",
        ["mushroom"] =       "Mushroom",
        ["mushroom1up"] =    "1-up Mushroom",
        ["star"] =           "Star",
        ["fireflower"] =     "Fireflower",
        ["Pfireflower"] =    "Fireflower (Progressive)",
        ["piranhaplant_1"] = "Piranha Plant (North)",
        ["piranhaplant_2"] = "Piranha Plant (East)",
        ["piranhaplant_3"] = "Piranha Plant (South)",
        ["piranhaplant_4"] = "Piranha Plant (West)",
        ["theme0"]         = "Overworld Theme",
        ["theme1"]         = "Underground Theme",
        ["theme2"]         = "Night Theme",
        ["theme3"]         = "Castle Theme",
        ["mario"]          = "Set Start Pos",
        ["scrollStopL"]    = "Add Scroll Stop (L)",
        ["scrollStopR"]    = "Add Scroll Stop (R)",
        ["scrollStopC"]    = "Remove Scroll Stop",
        ["newwarp"]        = "Create New Warp",
        ["warp_ID_2_1"]    = "West Facing Pipe Entrance",
        ["warp_ID_2_2"]    = "North Facing Pipe Entrance",
        ["warp_ID_2_3"]    = "East Facing Pipe Entrance",
        ["warp_ID_4_1"]    = "West Facing Pipe Exit",
        ["warp_ID_4_2"]    = "North Facing Pipe Exit",
        ["warp_ID_4_3"]    = "East Facing Pipe Exit",
        ["warp_ID_4_4"]    = "Teleport Exit",
        ["warp_ID_1"]      = "Edit Entrance Type",
        ["warp_ID_3"]      = "Edit Exit Type",
        ["warp_ID_6"]      = "Delete Pipe",
        ["warp_ID_7"]      = "View Entrance Pipe Position",
        ["warp_ID_8"]      = "View Exit Pipe Position",
        ["au"]             = "(Trigger - North)",
        ["ad"]             = "(Trigger - South)",
        ["ar"]             = "(Trigger - East)",
        ["al"]             = "(Trigger - West)",
        ["fu"]             = "(Falling - North)",
        ["fd"]             = "(Falling - South)",
        ["fr"]             = "(Falling - East)",
        ["fl"]             = "(Falling - West)",
        ["lx"]             = "(Looping - X)",
        ["ly"]             = "(Looping - Y)",
        ["ru"]             = "(Repeating - North)",
        ["rd"]             = "(Repeating - South)",
        ["flagpole"]       = "Flagpole",
        ["magicorb_a1_m1"] = "? Orb (Animation, Movement)",
        ["magicorb_a1_m0"] = "? Orb (Animation, Stationary)",
        ["magicorb_a0_m1"] = "? Orb (No Animation, Movement)",
        ["magicorb_a0_m0"] = "? Orb (No Animation, Stationary)",
        ["spring_O"]       = "Spring (Regular)",
        ["spring_L"]       = "Spring (Big)",
        ["spring_S"]       = "Spring (Small)",
        ["bowser"]         = "Bowser",
    }

    if platform.hw()==7 then
        studentSoftware=true flashingDelay=1
    else studentSoftware=false flashingDelay=2
    end

    titleSplashes={
        "Made in lua!",
        "Made by onlypuppy7!",
        "Join the discord!",
        "This is splash text!",
        "Thanks for playing!",
        "Drink it all.",
        "Try pressing menu in the editor!",
        "Try pressing D now!",
        "Suggest features in the discord!",
        "Check the changelog!",
        "This game started as duplicated mice!",
        "v1.3.0a added bowser!",
        "v1.0.0a added springs!",
        "v1.0.0a added course world!",
        "v0.9.1a added editor co-ords!",
        "v0.9.0a added saving levels!",
        "v0.8.3a added more semisolids!",
        "v0.8.0a added the titlescreen!",
        "v0.7.4a added stage settings!",
        "v0.6.3a added platforms!",
        "v0.6.2a added themes!",
        "v0.5.1a added bullet bills!",
        "v0.4.0a added koopas!",
        "v0.3.0a added goombas!",
        "v0.2.0a added mushrooms!",
        "v0.1.0a was really weird!",
        "Have you tried automove?",
        "Suggest more splash texts!",
        "Submit your levels!",
        "Share your levels!",
        "Report bugs in the discord!",
        "You're using "..(studentSoftware and "an emulator!" or "hardware!"),
        "Tip: Reset before playing!",
        "Don't question the fps...",
        "This is splash text!",
        "Now you're playing with power",
        "Create, play, and share!",
        "Anti-Ninja DMCA-Protected (TM)",
        "TI-83 port coming soon in 2061!",
        "'Ndless? What is that?'",
        "Are you up to date? Check the info!",
        "Have you tried scroll stops?",
        "Have you tried warp pipes?",
        "Featured in F3 2023!",
        "New update when?"
    }

    input={
        up=0,
        down=0,
        left=0,
        right=0,
        action=0,
        stor={
            left=0,
            right=0,
            up=0,
            down=0,
            action=0
        },
    }
    
    fps = 0
    lastTime = timer.getMilliSecCounter()
    errored = false
    despook=0
end

--idk where to put this
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

initialiseVARS()