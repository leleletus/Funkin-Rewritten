-- Semana mod: "Too Slow" (Sonic.exe / Angel Island). Una sola canción con
-- varias dificultades (easy/normal/hard).
local stage = require("stages.AngelIsland.stage")
local modchart = require("modules.psychmodchart")

local difficulty

-- Cutscene de intro (videos/tooslowcutscene1.ogv) -- mismo patrón que
-- weeks/weekend1.lua (self.cutscene/self.cutscenePlaying), pero usando
-- Video:isPlaying() en vez de una duración fija en segundos (no hay forma
-- de confirmar la duración exacta del archivo acá, y :isPlaying() es
-- exacto sin necesidad de adivinarla).
local cutscene, cutscenePlaying = nil, false

-- Réplica de chillador.lua viejo: arranca la canción DIRECTO, sin la cuenta
-- atrás normal de 3-2-1-GO con beeps (weeks:setupCountdown() real) -- la
-- música empieza ya mismo y el "intro" de stage.lua es pura superposición
-- visual sobre ella. Solo el tramo final de setupCountdown() (el que
-- realmente arranca música/musicTime) replicado a mano, sin los Timer.
-- after/tween de la cuenta atrás ni los beeps.
local function startSongDirectly()
    lastReportedPlaytime = 0
    musicThres = 0
    musicPos = 0
    countingDown = false
    musicTime = 0
    previousFrameTime = love.timer.getTime() * 1000
    if inst then inst:play() end
    if voices then voices:play() end
    weeks.songLength = inst and (inst:getDuration() * 1000) or 0

    stage.onSongStart()
end

local function stopCutscene()
    cutscenePlaying = false
    if cutscene then
        if cutscene.stop then cutscene:stop()
        elseif cutscene.pause then cutscene:pause() end
        cutscene = nil
    end
end

return {
    enter = function(self, from, songNum, songAppend, isStoryMode, songName)
        weeks.enter(self, songNum, songAppend, isStoryMode, songName)
        self:loadStage(songNum, songAppend)
        self:load()
    end,

    load = function(self)
        weeks:load()

        inst   = love.audio.newSource("music/too-slow/Inst.ogg",   "stream")
        voices = love.audio.newSource("music/too-slow/Voices.ogg", "stream")

        self:initUI()

        -- data/too-slow/modchart.lua: API de modcharts Lua de Psych real
        -- (setActorX/setActorY/tweenCameraZoom/curStep/songPos/downscroll
        -- como globales) -- ver modules/psychmodchart.lua para el shim de
        -- compatibilidad completo. Cargar DESPUÉS de initUI() (necesita que
        -- los strums ya existan/estén posicionados para tomar el snapshot
        -- de defaultStrumNX/Y en modchart.setup()).
        if modchart.load("data/too-slow/modchart.lua") then
            modchart.setup()
        end

        local cutsceneFile = "videos/tooslowcutscene1.ogv"
        if love.filesystem.getInfo(cutsceneFile) then
            cutscene = love.graphics.newVideo(cutsceneFile)
            cutscene:play()
            cutscenePlaying = true
        else
            startSongDirectly()
        end
    end,

    initUI = function(self)
        weeks:initUI()

        weeks:loadChart("data/too-slow/too-slow" .. difficulty)
    end,

    update = function(self, dt)
        if cutscenePlaying then
            if not graphics.isFading() then
                if input:pressed("confirm") then
                    stopCutscene()
                    startSongDirectly()
                    return
                elseif input:pressed("gameBack") then
                    stopCutscene()
                    if inst then inst:stop() end
                    if voices then voices:stop() end
                    status.setLoading(true)
                    graphics.fadeOut(0.5, function()
                        Gamestate.switch(menu)
                        status.setLoading(false)
                    end)
                    return
                end
            end

            if cutscene and not cutscene:isPlaying() then
                stopCutscene()
                startSongDirectly()
            end
            return
        end

        weeks:update(dt)
        stage.update(dt)
        modchart.update(dt)

        weeks:updateUI(dt)
    end,

    draw = function(self)
        if cutscenePlaying and cutscene then
            love.graphics.push()
            love.graphics.origin()
            local vw, vh = love.graphics.getDimensions()
            local sw, sh = cutscene:getWidth(), cutscene:getHeight()
            love.graphics.draw(cutscene, 0, 0, 0, vw / sw, vh / sh)
            love.graphics.pop()
            return
        end

        stage.draw()
        weeks:drawUI()
        stage.drawHUD()
    end,

    loadStage = function(self, songNum, songAppend)
        difficulty = songAppend
        stage.load()
    end,

    leave = function(self)
        stopCutscene()
        modchart.unload()
        stage.leave()
        weeks:leave()
    end,
}
