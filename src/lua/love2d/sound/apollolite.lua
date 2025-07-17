local SOUND = {}

SOUND.bgms = {
    overworld = {
        loopstart = 2.374
    }, overworldhurry = {
        loopstart = 2.374 / 1.5
    }, die = {
        dontloop = true
    }, levelclear = {
        dontloop = true
    }, night = {
        loopstart = 2.374
    }, nighthurry = {
        loopstart = 2.374 / 1.5
    }, hurry = {
        dontloop = true, isHurry = true
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

SOUND._sfxCache = {}

function SOUND:sfx(name)
    print("playing sfx:", name)
    if not name then return end

    local sfx

    if not self._sfxCache[name] then
        self._sfxCache[name] = love.audio.newSource("sound/sfx_"..name..".wav", "static")
    end

    if __PC.noCloneSFX then
        sfx = self._sfxCache[name]
    else
        sfx = self._sfxCache[name]:clone()
    end

    love.audio.stop(sfx)

    if not sfx:isPlaying() then
        sfx:play()
    end
end

function SOUND:bgm(name)
    if not __PC.supportsBGM then return end

    print("playing bgm:", name)
    SOUND:stopBGM()

    if name then
        local src = love.audio.newSource("sound/bgm_"..name.."."..__PC.bgmFormat, "stream")
        local config = self.bgms[name] or {loopstart = 0}

        src:setLooping((config.loopstart == 0 and not config.dontloop))
        src:play()
        self.currentBGM = {
            src = src,
            config = config
        }
    end
end

function SOUND:pauseBGM(state)
    if not __PC.supportsBGM then return end
    if not __PC.supportsPausing then return end
    
    if self.currentBGM and self.currentBGM.src then
        if state then
            if not self.currentBGM.paused then
                print("pausing bgm")
                love.audio.pause(self.currentBGM.src)
                -- self.currentBGM.src:pause()
                self.currentBGM.paused = true
            end
        else
            if self.currentBGM.paused then
                print("unpausing bgm")
                self.currentBGM.src:play()
                self.currentBGM.paused = false
            end
        end
    end
end

function SOUND:stopBGM()
    if not __PC.supportsBGM then return end

    if self.currentBGM and self.currentBGM.src then
        love.audio.stop(self.currentBGM.src)
        -- self.currentBGM.src:stop()
        -- self.currentBGM.src:setVolume(0)
        self.currentBGM = nil
    end
end

function SOUND:update(dt)
    if not __PC.supportsBGM then return end

    local bgm = self.currentBGM
    if bgm and (not bgm.src:isPlaying()) then
        if (not bgm.config.dontloop) and (not bgm.paused) then
            bgm.src:seek(bgm.config.loopstart or 0)
            bgm.src:play()
        end
        if bgm.config.isHurry and playStage then playStage.playedHurry = true end
    end
end

__PC.SOUND = SOUND