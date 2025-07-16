local SOUND = {}

SOUND.bgms = {
    overworld = {
        loopstart = 2.374
    }, overworldhurry = {
        loopstart = 4.407
    }, die = {
        dontloop = true
    }, levelclear = {
        dontloop = true
    },

    
    -- }, underground = {
    --     loopstart = 0
    -- }, castle = {
    --     loopstart = 0
    -- }, underwater = {
    --     loopstart = 0
    -- }, menu = {
    --     loopstart = 0
    -- }, editor = {
    --     loopstart = 0
}

function SOUND:sfx(name)
    local sfx = love.audio.newSource("sound/sfx_"..name..".wav", "static")
    sfx:play()
end

function SOUND:bgm(name, speed)
    SOUND:stopBGM()

    local src = love.audio.newSource("sound/bgm_"..name..".ogg", "stream")
    local config = self.bgms[name] or {loopstart = 0}

    src:setLooping((config.loopstart == 0 and not config.dontloop))
    src:play()
    self.currentBGM = {
        src = src,
        config = config
    }
end

function SOUND:stopBGM()
    if self.currentBGM and self.currentBGM.src then
        self.currentBGM.src:stop()
        self.currentBGM = nil
    end
end

function SOUND:update(dt) --hooked from love.update(dt)
    local bgm = self.currentBGM
    if bgm and (not bgm.src:isPlaying()) and (not bgm.config.dontloop) then
        bgm.src:seek(bgm.config.loopstart or 0)
        bgm.src:play()
    end
end

__PC.SOUND = SOUND