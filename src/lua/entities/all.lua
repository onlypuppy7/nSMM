typeIndex={
    goomb = {"objGoomba",        "inner"},
    koopa = {"objKoopa",         "inner"},
    Pkoop = {"objKoopaPara",     "inner"},
    shell = {"objShell",         "inner"},
    bulle = {"objBulletBill",    "inner"},
    flame = {"objBowserFlame",   "outer"},
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
    switc = {"objSwitch",        "inner"},
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
    ["spring_R"]       = "Spring (Big)",
    ["spring_B"]       = "Spring (Small)",
    ["bowser"]         = "Bowser",
    ["switch_p"]         = "P-Switch",
}

require("entities.objapi")

require("entities.enemies")
require("entities.mario")
require("entities.objects")
require("entities.obtainables")
require("entities.particles")