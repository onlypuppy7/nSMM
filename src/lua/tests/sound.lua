-- local music
-- local loopStart = 2
-- local loopEnd = 5

-- function love.load()
--     music = love.audio.newSource("sound/bgm_menu.ogg", "stream")
--     music:setLooping(false)
--     music:play()
-- end

-- function love.update(dt)
--     if music:tell() >= loopEnd then
--         music:seek(loopStart)
--     end
-- end


-- local bgm
-- local LOOP_START = 2.374 --smb1

-- function love.load()
--     bgm = love.audio.newSource("sound/bgm_overworld.ogg", "stream")
--     bgm:setLooping(false)
--     bgm:play()
-- end

-- function love.update(dt)
--     if not bgm:isPlaying() then
--         bgm:seek(LOOP_START)
--         bgm:play()
--     end
--     print(bgm:tell())
-- end


function love.keypressed(key)
    if key == "space" then
        __PC.SOUND:sfx("jump2")
    end
end

function love.load()
    __PC.SOUND:bgm("menu")
end