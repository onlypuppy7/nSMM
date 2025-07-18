-- local ok, err = pcall(function()

    function __loadGame__()
        require("nsmm")
        require("courseworld.courses")
    end

    require("love2d.setup")

    -- __PC.scale = 2
    -- __PC.doImageSaving = true
    -- __PC.usePresavedImages = true

    -- require("tests.sound")

    -- gameSpeed={0,1}
-- end)
-- if not ok then print("nSMM err:", err) end