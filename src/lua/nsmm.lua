--[[
    RELEASE CHECKLIST: 2.0.0a
        # versText
        # versNum
        - rename editor
        - clear data
        - check changelog date
        - remove checklist
]]

require("meta")

-- (c) onlypuppy7/chalex0 2025

--------------------------
-----TEXTURE LIBRARY------
--------------------------

    texs={}

    require("data.textures-etc")
    require("data.textures-font")

--------------------------
----INITIALISING VARS-----
--------------------------

    require("core.init")
    require("core.extendstandard")

--------------------------
----GENERAL FUNCTIONS-----
--------------------------

    require("core.misc")
    require("core.drawinghelpers")
    require("core.imagehelpers")

--------------------------
---------EVENTS-----------
--------------------------

    require("core.events")

---------------------------
-----PROGRAM FUNCTIONS-----
---------------------------

    require("core.plotmath")
    require("core.levelserialise")
    require("core.font")
    require("core.datastorage")

--------------------------
-------BLOCK INDEX--------
--------------------------

    require("data.blocks")

---------------------------
---PROFILER+OPTIMISATION---
---------------------------

    require("core.profiler")

---------------------------
---------ENTITIES---------
---------------------------

    require("entities.all")

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
--DEBUG SCREEN FUNCTIONS--
--------------------------

    require("modes.debugscreen")

--------------------------
-------GUI FUNCTIONS------
--------------------------

    require("core.gui")
    require("core.gui-click")

--------------------------
-------CRASH SCREEN-------
--------------------------

    require("core.recovery")

--------------------------
------FRAME FUNCTIONS-----
--------------------------

    require("core.renderloop")

--------------------------
---------START-UP---------
--------------------------

    switchTimer(true)
    print("Running!",versText,"start memory:",collectgarbage("count"),"kb")