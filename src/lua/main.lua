-- local ok, err = pcall(function()

    function __loadGame__()
        require("nsmm")
        require("courseworld.courses")
    end

    require("love2d.setup")
-- end)
-- if not ok then print("nSMM err:", err) end