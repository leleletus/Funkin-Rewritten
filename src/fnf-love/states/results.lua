local diffToFile = {
    ["easy"] = "difEasy",
    ["normal"] = "difNormal",
    ["hard"] = "difHard",
    ["erect"] = "difErect",
    ["nightmare"] = "difNightmare"
}

local bfFiles = {
    ["LOSS"]      = "sprites/resultsScreen/RESULTS_BOYFRIEND_LOSS_RANK_final.lua",
    ["GOOD"]      = "sprites/resultsScreen/resultBoyfriendGOOD.lua",
    ["GREAT"]     = "sprites/resultsScreen/RESULTS BOYFRIEND GREAT RANK final.lua",
    ["EXCELLENT"] = "sprites/resultsScreen/RESULTS BOYFRIEND EXCELLENT RANK final v2.lua",
    ["PERFECT"]   = "sprites/resultsScreen/RESULTS BOYFRIEND PERFECT RANK final.lua",
}

local gfFiles = {
    ["LOSS"]      = nil,
    ["GOOD"]      = "sprites/resultsScreen/resultGirlfriendGOOD.lua",
    ["GREAT"]     = "sprites/resultsScreen/RESULTS GIRLFRIEND GREAT RANK final.lua",
    ["EXCELLENT"] = "sprites/resultsScreen/RESULTS BOYFRIEND EXCELLENT RANK final v2 faces.lua",
    ["PERFECT"]   = "sprites/resultsScreen/RESULTS BOYFRIEND PERFECT RANK final heart.lua",
}

-- Posición/escala de los sprites por variación.
--   x, y, scale   = posición del LOOP (posición final en pantalla).
--   introX, introY = posición de ENTRADA si difiere de x/y (solo GREAT y PERFECT la necesitan).
--   EXCELLENT tiene además facesX/facesY/facesScale para la animación "Símbolo".
local spriteConfig = {
    ["LOSS"] = {
        bf = { x = 928, y = 206, scale = 1, intro = "start", loop = "idle" }
    },
    ["GOOD"] = {
        bf = { x = 1000, y = 265, scale = 1, intro = "intro", loop = "idle" },
        gf = { x = 810,  y = 500, scale = 1, intro = "intro", loop = "idle" }
    },
    ["GREAT"] = {
        bf = { x = 1013, y = 259, scale = 0.95, intro = "bf jumping", loop = "bf jump loop" },
        gf = { x = 771, y = 267, scale = 1, intro = "gf jumping", loop = "gf jump loop" }
    },
    ["EXCELLENT"] = {
        bf = { x = 956, y = 248, scale = 0.95, intro = "start", loop = "idle" },
        gf = { x = 916, y = 512, scale = 0.95, loop = "idle" }
    },
    ["PERFECT"] = {
        bf     = { x = 938, y = 283, scale = 1, intro = "start", loop = "idle" },
        gf = { x = 746, y = 374, scale = 0.95, intro = "start", loop = "idle" }
    }
}

-- Configuración de sonido de conteo por variación (pitch y velocidad de tick)
local variationTickSettings = {
    LOSS      = { pitch = 0.75, interval = 0.13 },
    GOOD      = { pitch = 1.0,  interval = 0.10 },
    GREAT     = { pitch = 1.2,  interval = 0.08 },
    EXCELLENT = { pitch = 1.4,  interval = 0.065 },
    PERFECT   = { pitch = 1.65, interval = 0.05 },
}

-- Música por variación
local variationToMusic = {
    ["LOSS"]      = "music/results/resultsSHIT.ogg",  -- archivo en repo sigue siendo SHIT
    ["GOOD"]      = "music/results/resultsNORMAL.ogg",
    ["GREAT"]     = "music/results/resultsNORMAL.ogg",
    ["EXCELLENT"] = "shared/music/resultsEXCELLENT/resultsEXCELLENT.ogg",
    ["PERFECT"]   = "music/results/resultsPERFECT.ogg",
}

-- Umbrales de variación:
--   PERFECT   : full combo de Sicks (0 misses, 0 bad, 0 shit, 0 good)
--   EXCELLENT : precisión >= 90%
--   GREAT     : precisión >= 80%
--   GOOD      : precisión >= 60%
--   LOSS      : precisión <  60%
local function determineVariation(scores)
    local totalNotes = scores.sickCount + scores.goodCount + scores.badCount + scores.shitCount + scores.missedCount
    if totalNotes == 0 then return "GOOD" end

    local weightedScore = (scores.sickCount * 100) + (scores.goodCount * 70) + (scores.badCount * 35)
    local accuracy = weightedScore / (totalNotes * 100)

    if scores.missedCount == 0 and scores.badCount == 0 and scores.shitCount == 0 and scores.goodCount == 0 then
        return "PERFECT"
    elseif accuracy >= 0.9 then
        return "EXCELLENT"
    elseif accuracy >= 0.8 then
        return "GREAT"
    elseif accuracy >= 0.6 then
        return "GOOD"
    else
        return "LOSS"
    end
end

local diffName, songName, scores, scoreData, artist
_resultsCache = {}
local resultsVariation = "GOOD"

local resultsGF, resultsBF, soundSystem
local gfPerfectShown = false
local letterOrder = "AaBbCcDdEeFfGgHhiIJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789:1234567890"
local resultsFont = {quads={}, img=nil}

local topBarBlack, resultsAnim, ratingsPopin, scorePopin
local textTween
local badgeDelayTimer
local curDiff

local thePosEverX = 0
local thePosEverY = {0}

-- Estado: 0 = contando precisión, 1 = resultados visibles
local screenState     = 0
local accuracyTimer   = 0
local accuracyDuration = 2.5
local currentAccuracy = 0
local targetAccuracy  = 0
local bgScrollY       = 0

-- Fuentes VCR para UI del results
local bigFont       = nil   -- VCR grande para "CLEAR / XX%" (Fase 0)
local bgVariFont    = nil   -- VCR mediano para patrón de fondo y borde derecho
local clearTitleFont = nil  -- VCR pequeño para CLEAR entre badge y nombre (Fase 1)

-- Control del texto CLEAR/XX% grande (Fase 0)
local clearState = { visible = true, alpha = 1.0 }

-- Control del badge de dificultad + nombre + CLEAR en título (Fase 1)
local badgeActive    = false   -- true cuando el badge ya puede entrar
local showClearTitle = false   -- true cuando se muestra CLEAR pequeño en el título

-- Punto de loop de la música GOOD (segundos); la intro toca una vez,
-- luego el audio hace loop desde este punto. Ajustar si no coincide con el audio.
local GOOD_MUSIC_LOOP_START = 12 / 24.0  -- ~0.5 s ≈ 12 frames × 24 fps
local musicLoopActive = false   -- true después de que la intro de GOOD termina

local displayScore = 0     -- score animado durante Fase 0 (0 → score final)
local tickSound    = nil   -- fuente de sonido select.ogg para el contador
local tickTimer    = nil   -- Timer.every handle
local confirmPlayed      = false  -- si ya se disparó el sonido confirm
local confirmSource      = nil    -- fuente de confirm.ogg
local clearFadeTriggered = false  -- si ya se inició el tween de CLEAR
local badgeReadyToSlide  = false  -- true cuando CLEAR desaparece → badge empieza a deslizarse

local function printResultsFont(x, y, text, scale)
    local text = text or "UNDEFINED"
    text = text:gsub("[^" .. letterOrder .. " ]", "")
    for i = 1, #text do
        local char = text:sub(i, i)
        local index = letterOrder:find(char)
        if index then
            love.graphics.draw(resultsFont.img, resultsFont.quads[index], x + (i - 1) * 37 * scale, y, 0, scale, scale)
        end
    end
end

local scoreNumbers = {
    sprites  = {},
    score    = 0,
    visible  = false,
    animateNumbers = function(self)
        local paddedStr = string.format("%010d", self.score)
        for i = 1, #paddedStr do
            if paddedStr:sub(i, i) == "0" then
                paddedStr = paddedStr:sub(1, i - 1) .. "_" .. paddedStr:sub(i + 1)
            else
                break
            end
        end
        for i = 1, #paddedStr do
            local char = paddedStr:sub(i, i)
            if char == "_" then
                self.sprites[i]:animate("DISABLED", false)
            else
                self.sprites[i].visible = true
                self.sprites[i]:animate(char, false)
            end
        end
    end
}
local tallies = {}
local resultsMusic

return {
    enter = function(self, last, scoreData_)
        if music then music:stop() end

        graphics.setFade(0)
        graphics.fadeIn(0.5)

        -- Crear fuentes VCR (una sola vez)
        if not bigFont then
            bigFont = love.graphics.newFont("fonts/vcr.ttf", 96)
        end
        if not bgVariFont then
            bgVariFont = love.graphics.newFont("fonts/vcr.ttf", 56)
        end
        if not clearTitleFont then
            clearTitleFont = love.graphics.newFont("fonts/vcr.ttf", 40)
        end

        -- Estado inicial
        clearState.visible = true
        clearState.alpha   = 1.0
        badgeActive     = false
        showClearTitle  = false
        musicLoopActive = false
        screenState     = 0
        accuracyTimer    = 0
        currentAccuracy  = 0
        bgScrollY        = 0
        displayScore         = 0
        confirmPlayed        = false
        clearFadeTriggered   = false
        badgeReadyToSlide    = false
        if tickTimer then Timer.cancel(tickTimer); tickTimer = nil end
        if badgeDelayTimer then Timer.cancel(badgeDelayTimer); badgeDelayTimer = nil end
        if tickSound then tickSound:stop(); tickSound = nil end
        if confirmSource then confirmSource:stop(); confirmSource = nil end

        local scc    = scoreData_.scores
        local totalN = scc.sickCount + scc.goodCount + scc.badCount + scc.shitCount + scc.missedCount
        targetAccuracy = totalN > 0
            and ((scc.sickCount * 100 + scc.goodCount * 70 + scc.badCount * 35) / (totalN * 100))
            or 0

        resultsVariation = determineVariation(scoreData_.scores)

        -- ── Sprites de personajes ────────────────────────────────────────────────
        local bfFile = bfFiles[resultsVariation] or bfFiles["GOOD"]
        resultsBF = love.filesystem.load(bfFile)()
        resultsBF.visible = false

        local gfFile = gfFiles[resultsVariation]
        if gfFile then
            resultsGF = love.filesystem.load(gfFile)()
            resultsGF.visible = false
        else
            resultsGF = nil
        end

        local config = spriteConfig[resultsVariation] or spriteConfig["GOOD"]

        resultsBF.x = config.bf.x
        resultsBF.y = config.bf.y
        resultsBF.sizeX = config.bf.scale
        resultsBF.sizeY = config.bf.scale

        if resultsGF and config.gf then
            resultsGF.x = config.gf.x
            resultsGF.y = config.gf.y
            resultsGF.sizeX = config.gf.scale
            resultsGF.sizeY = config.gf.scale
        end

        gfPerfectShown = false

        -- ── Música ──────────────────────────────────────────────────────────────
        local musicPath = variationToMusic[resultsVariation]
        if musicPath then
            local ok, src = pcall(love.audio.newSource, musicPath, "stream")
            if ok and src then
                resultsMusic = src
                -- LOSS no loopea; el resto sí
                resultsMusic:setLooping(resultsVariation ~= "LOSS")
                resultsMusic:play()
            end
        end

        -- ── Fuente bitmap de resultados (tardling) ───────────────────────────────
        resultsFont.quads = {}
        resultsFont.img   = love.graphics.newImage(graphics.imagePath("resultsScreen/tardlingSpritesheet"))
        for x = 0, resultsFont.img:getWidth() - 49, 49 do
            table.insert(resultsFont.quads, love.graphics.newQuad(x, 0, 49, 62, resultsFont.img:getDimensions()))
        end
        for y = 62, resultsFont.img:getHeight() - 62, 62 do
            for x = 0, resultsFont.img:getWidth() - 49, 49 do
                table.insert(resultsFont.quads, love.graphics.newQuad(x, y, 49, 62, resultsFont.img:getDimensions()))
            end
        end

        -- ── Barra negra superior (topBarBlack) ───────────────────────────────────
        local topBarImg = love.graphics.newImage(graphics.imagePath("resultsScreen/topBarBlack"))
        topBarBlack = graphics.newImage(topBarImg)
        local topBarH = topBarImg:getHeight()
        local topBarW = topBarImg:getWidth()
        topBarBlack.getHeight = function() return topBarH end
        topBarBlack.getWidth  = function() return topBarW end
        topBarBlack.y = -topBarH / 2
        topBarBlack.x = topBarW  / 2
        Timer.after(0.5, function()
            Timer.tween(0.4, topBarBlack, { y = topBarBlack:getHeight() / 2 }, "out-quart")
        end)

        -- ── soundSystem y resultsAnim ─────────────────────────────────────────────
        soundSystem = love.filesystem.load("sprites/resultsScreen/soundSystem.lua")()
        soundSystem.x, soundSystem.y = 425, 300
        soundSystem:animate("idle")
        soundSystem.visible = true

        resultsAnim = love.filesystem.load("sprites/resultsScreen/resultsAnim.lua")()
        resultsAnim:animate("idle", false)
        resultsAnim.x = 1280 / 2 - resultsAnim:getFrameWidth() / 2  -- centrado (original)
        resultsAnim.y = resultsAnim:getFrameHeight() + 35             -- posición original
        resultsAnim.visible = true

        -- ── Cachear imágenes compartidas ─────────────────────────────────────────
        _resultsCache.ratingsPopin        = love.graphics.newImage(graphics.imagePath("resultsScreen/ratingsPopin"))
        _resultsCache.scorePopin          = love.graphics.newImage(graphics.imagePath("resultsScreen/scorePopin"))
        _resultsCache.tallieNumber        = love.graphics.newImage(graphics.imagePath("resultsScreen/tallieNumber"))
        _resultsCache.scoreDigitalNumbers = love.graphics.newImage(graphics.imagePath("resultsScreen/score-digital-numbers"))

        ratingsPopin = love.filesystem.load("sprites/resultsScreen/ratingsPopin.lua")()
        ratingsPopin.x, ratingsPopin.y = 110, 330   -- posición original (izquierda)
        ratingsPopin:animate("idle", false)
        ratingsPopin.visible = true

        scorePopin = love.filesystem.load("sprites/resultsScreen/scorePopin.lua")()
        scorePopin.x, scorePopin.y = 180, 590       -- posición original (izquierda)
        scorePopin:animate("idle", false)
        scorePopin.visible = true

        -- ── Badge de dificultad ───────────────────────────────────────────────────
        local curDiffImg = love.graphics.newImage(
            graphics.imagePath("resultsScreen/" .. (diffToFile[scoreData_.diff] or "difNormal"))
        )
        curDiff = graphics.newImage(curDiffImg)
        local curDiffW, curDiffH = curDiffImg:getWidth(), curDiffImg:getHeight()
        curDiff.getWidth  = function() return curDiffW end
        curDiff.getHeight = function() return curDiffH end
        -- Badge empieza fuera de pantalla hasta que el HUD esté listo
        curDiff.x   = 3000
        curDiff.y   = 160
        thePosEverX = 3000
        thePosEverY = { 160 }

        scoreData = scoreData_
        diffName  = scoreData.diff
        songName  = scoreData.song
        scores    = scoreData.scores
        artist    = scoreData.artist

        scores.totalNotes = scores.sickCount + scores.goodCount + scores.badCount + scores.shitCount + scores.missedCount

        -- ── Tallies ───────────────────────────────────────────────────────────────
        for i = 1, 7 do
            tallies[i] = {sprites={}, colour={1,1,1}, num=0, curNum=0,
                          displayedNums=1, storedX={}, flippedSprites={},
                          visibleSprites={}, visible=false}
        end

        -- Posiciones originales (lado izquierdo, panel oscuro)
        local tallyDefs = {
            { val=scores.totalNotes,  x=400, y=155, color={1,1,1} },
            { val=scores.maxCombo,    x=400, y=225, color={1,1,1} },
            { val=scores.sickCount,   x=255, y=285, color={137/255,229/255,158/255} },
            { val=scores.goodCount,   x=235, y=340, color={137/255,201/255,229/255} },
            { val=scores.badCount,    x=210, y=390, color={230/255,207/255,138/255} },
            { val=scores.shitCount,   x=235, y=440, color={230/255,140/255,138/255} },
            { val=scores.missedCount, x=265, y=500, color={198/255,138/255,230/255} },
        }

        for i, def in ipairs(tallyDefs) do
            tallies[i].num   = def.val
            tallies[i].color = def.color
            local str = tostring(def.val)
            for j = 1, #str do
                local sp = love.filesystem.load("sprites/resultsScreen/tallieNumber.lua")()
                sp:animate("0", false)
                sp.x = def.x + (j - 1) * 38
                sp.y = def.y
                table.insert(tallies[i].sprites, sp)
                tallies[i].storedX[j] = sp.x
            end
            local newSX = {}
            for j = #tallies[i].sprites, 1, -1 do
                table.insert(newSX, tallies[i].storedX[j])
            end
            tallies[i].storedX = newSX
            for j = 2, #tallies[i].sprites do
                tallies[i].sprites[j].visible = false
            end
        end

        -- Iniciar contadores de tallies desde Fase 0 (cuentan conforme sube el %%)
        for i = 1, #tallies do
            tallies[i].visible = true
            local delay = 0.15 * i
            local tweenDur = math.max(0.4, accuracyDuration - delay - 0.1)
            Timer.after(delay, function()
                Timer.tween(tweenDur, tallies[i], { curNum = tallies[i].num }, "out-quart")
            end)
        end

        -- ── Score digital ─────────────────────────────────────────────────────────
        scoreNumbers.score   = 0
        scoreNumbers.visible = true
        scoreNumbers.sprites = {}
        local paddedScoreStr = string.format("%010d", scores.score)
        for i = 1, #paddedScoreStr do
            local char = paddedScoreStr:sub(i, i)
            if tonumber(char) then
                local sp = love.filesystem.load("sprites/resultsScreen/scoreDigitalNumbers.lua")()
                sp:animate("DISABLED", false)
                sp.x = 130 + (i - 1) * (sp:getFrameWidth() + 2)
                sp.y = 670
                table.insert(scoreNumbers.sprites, sp)
            end
        end

        -- ── Sonido de conteo (tick) durante Fase 0 ───────────────────────────────
        local tickCfg = variationTickSettings[resultsVariation] or variationTickSettings.GOOD
        local ok2, src2 = pcall(love.audio.newSource, "sounds/menu/select.ogg", "static")
        if ok2 and src2 then
            tickSound = src2
            tickSound:setPitch(tickCfg.pitch)
            tickTimer = Timer.every(tickCfg.interval, function()
                if tickSound then
                    tickSound:stop()
                    tickSound:play()
                end
            end)
        end
    end,

    -- ─────────────────────────────────────────────────────────────────────────────
    update = function(self, dt)
        if resultsGF then resultsGF:update(dt) end
        resultsBF:update(dt)
        soundSystem:update(dt)
        resultsAnim:update(dt)
        ratingsPopin:update(dt)
        scorePopin:update(dt)

        -- Texto de fondo scrollea hacia arriba (lado derecho)
        bgScrollY = bgScrollY + 120 * dt


        -- ── Fase 0: contador de precisión ────────────────────────────────────────
        if screenState == 0 then
            accuracyTimer = accuracyTimer + dt
            if accuracyTimer >= accuracyDuration then
                accuracyTimer   = accuracyDuration
                currentAccuracy = targetAccuracy
                screenState     = 1

                -- Detener sonido de conteo
                if tickTimer then Timer.cancel(tickTimer); tickTimer = nil end
                if tickSound then tickSound:stop(); tickSound = nil end

                -- Fijar score en valor final
                scoreNumbers.score = scores.score
                scoreNumbers:animateNumbers()

                -- Personajes aparecen al inicio de Fase 1
                local config = spriteConfig[resultsVariation] or spriteConfig["GOOD"]

                resultsBF.visible = true

                -- Animación de BF según la variación
                if config.bf.intro and resultsBF:getAnims()[config.bf.intro] then
                    -- Posición de entrada: introX/introY si difieren de x/y (GREAT, PERFECT)
                    resultsBF.x     = config.bf.introX or config.bf.x
                    resultsBF.y     = config.bf.introY or config.bf.y
                    resultsBF.sizeX = config.bf.scale
                    resultsBF.sizeY = config.bf.scale

                    if resultsVariation == "EXCELLENT" then
                        -- EXCELLENT: start(BF) → idle(BF) → idle(GF) → idle(BF) → idle(GF) ...
                        -- El loop está dividido en 2 sprites: BF es la 1ª mitad, GF la 2ª.
                        local playBFLoop, playGFLoop
                        playBFLoop = function()
                            if not resultsBF then return end
                            resultsBF.visible = true
                            if resultsGF then resultsGF.visible = false end
                            resultsBF.x     = config.bf.x
                            resultsBF.y     = config.bf.y
                            resultsBF.sizeX = config.bf.scale
                            resultsBF.sizeY = config.bf.scale
                            resultsBF:animate(config.bf.loop, false, function()
                                playGFLoop()
                            end)
                        end
                        playGFLoop = function()
                            if not resultsGF then
                                playBFLoop()
                                return
                            end
                            resultsGF.visible = true
                            resultsBF.visible = false
                            resultsGF.x     = config.gf.x
                            resultsGF.y     = config.gf.y
                            resultsGF.sizeX = config.gf.scale
                            resultsGF.sizeY = config.gf.scale
                            resultsGF:animate(config.gf.loop, false, function()
                                playBFLoop()
                            end)
                        end
                        resultsBF:animate(config.bf.intro, false, function()
                            playBFLoop()
                        end)

                    elseif resultsVariation == "PERFECT" then
                        -- PERFECT: intro de caída → aterriza en cama (loop)
                        -- GF (corazones) aparece recién en el frame 105 de BF (ver update)
                        resultsBF:animate(config.bf.intro, false, function()
                            if not resultsBF then return end
                            resultsBF.x     = config.bf.x
                            resultsBF.y     = config.bf.y
                            resultsBF.sizeX = config.bf.scale
                            resultsBF.sizeY = config.bf.scale
                            resultsBF:animate(config.bf.loop, true)
                        end)

                    else
                        -- LOSS, GOOD, GREAT: intro una vez → loop
                        resultsBF:animate(config.bf.intro, false, function()
                            if not resultsBF then return end
                            resultsBF.x     = config.bf.x
                            resultsBF.y     = config.bf.y
                            resultsBF.sizeX = config.bf.scale
                            resultsBF.sizeY = config.bf.scale
                            resultsBF:animate(config.bf.loop, true)
                        end)
                    end
                else
                    -- Sin intro: loop directo (fallback)
                    resultsBF.x     = config.bf.x
                    resultsBF.y     = config.bf.y
                    resultsBF.sizeX = config.bf.scale
                    resultsBF.sizeY = config.bf.scale
                    resultsBF:animate(config.bf.loop, true)
                end

                -- GF: GOOD y GREAT aparecen al inicio; PERFECT espera al frame 105 de BF
                if resultsGF and resultsVariation ~= "PERFECT" and resultsVariation ~= "EXCELLENT" then
                    resultsGF.visible = true
                    if config.gf and config.gf.intro and resultsGF:getAnims()[config.gf.intro] then
                        resultsGF.x     = config.gf.introX or config.gf.x
                        resultsGF.y     = config.gf.introY or config.gf.y
                        resultsGF.sizeX = config.gf.scale
                        resultsGF.sizeY = config.gf.scale
                        resultsGF:animate(config.gf.intro, false, function()
                            if not resultsGF then return end
                            resultsGF.x     = config.gf.x
                            resultsGF.y     = config.gf.y
                            resultsGF.sizeX = config.gf.scale
                            resultsGF.sizeY = config.gf.scale
                            resultsGF:animate(config.gf.loop, true)
                        end)
                    elseif config.gf and config.gf.loop then
                        resultsGF.x     = config.gf.x
                        resultsGF.y     = config.gf.y
                        resultsGF.sizeX = config.gf.scale
                        resultsGF.sizeY = config.gf.scale
                        resultsGF:animate(config.gf.loop, true)
                    end
                end

                -- Badge activo después de breve pausa (entra con % visible; deslizamiento espera al CLEAR)
                badgeDelayTimer = Timer.after(0.6, function()
                    if not curDiff then return end
                    badgeActive    = true
                    showClearTitle = true
                    thePosEverX = 570 + curDiff:getWidth() / 2
                    thePosEverY = { 160 - 300 }
                    textTween   = nil
                end)
            else
                -- Easing: rápido al inicio, los últimos 3% notablemente más lentos
                local t = accuracyTimer / accuracyDuration
                local easedT
                if t < 0.85 then
                    easedT = (t / 0.85) * 0.97
                else
                    local subT = (t - 0.85) / 0.15
                    local eased = 1 - (1 - subT) ^ 3   -- cubic ease-out
                    easedT = 0.97 + eased * 0.03
                end
                currentAccuracy = easedT * targetAccuracy
                displayScore    = math.floor(easedT * scores.score)
                scoreNumbers.score = displayScore
                scoreNumbers:animateNumbers()

                -- Disparar confirm cuando falta el último 1%
                if not confirmPlayed then
                    local curPct = math.floor(currentAccuracy * 100)
                    local tgtPct = math.floor(targetAccuracy * 100)
                    if tgtPct > 0 and curPct >= tgtPct - 1 then
                        confirmPlayed = true
                        -- Detener tick y reproducir confirm
                        if tickTimer then Timer.cancel(tickTimer); tickTimer = nil end
                        if tickSound then tickSound:stop(); tickSound = nil end
                        local ok3, src3 = pcall(love.audio.newSource, "sounds/menu/confirm.ogg", "static")
                        if ok3 and src3 then
                            confirmSource = src3
                            confirmSource:play()
                        end
                    end
                end
            end
        end

        -- Esperar a que el confirm termine para desvanecer CLEAR (Fase 1)
        if screenState == 1 and clearState.visible and not clearFadeTriggered then
            local confirmDone = (confirmSource == nil) or (not confirmSource:isPlaying())
            if confirmDone then
                clearFadeTriggered = true
                Timer.tween(0.5, clearState, { alpha = 0 }, "out-quad", function()
                    clearState.visible = false
                    badgeReadyToSlide  = true
                end)
            end
        end

        -- ── PERFECT: mostrar GF (corazones) cuando BF llega al frame 105 ────────────
        if resultsVariation == "PERFECT" and resultsGF and not gfPerfectShown and resultsBF.visible then
            if resultsBF:getCurrentFrame() >= 105 then
                gfPerfectShown = true
                local cfg = spriteConfig["PERFECT"]
                resultsGF.visible = true
                resultsGF.x     = cfg.gf.x
                resultsGF.y     = cfg.gf.y
                resultsGF.sizeX = cfg.gf.scale
                resultsGF.sizeY = cfg.gf.scale
                resultsGF:animate(cfg.gf.intro, false, function()
                    if not resultsGF then return end
                    resultsGF:animate(cfg.gf.loop, true)
                end)
            end
        end

        -- ── Animación del badge de dificultad (solo cuando badgeActive) ─────────────
        if badgeActive then
            if thePosEverY[1] > 159 and not textTween then
                -- Posición final: solo deslizar si ya se permitió (CLEAR desapareció)
                if badgeReadyToSlide then
                    thePosEverX = thePosEverX - 500 * dt
                end
                curDiff.x = thePosEverX
                curDiff.y = thePosEverY[1]
            else
                if not textTween then
                    if curDiff then
                        curDiff.x    = 570 + curDiff:getWidth() / 2
                        curDiff.y    = 160 - 300
                        thePosEverX  = curDiff.x
                        thePosEverY  = { 160 - 300 }
                    end
                    textTween = Timer.after(0.5, function()
                        textTween = Timer.tween(1, thePosEverY, {160}, "out-quart", function()
                            textTween = Timer.after(0.25, function() textTween = nil end)
                        end)
                    end)
                end
                curDiff.y = thePosEverY[1]
            end

            if thePosEverX < -1500 then
                if curDiff then
                    thePosEverX  = 570 + curDiff:getWidth() / 2
                    curDiff.y    = 160 - 300
                end
                thePosEverY  = { 160 - 300 }
                textTween    = nil
            end
        end

        -- ── Dígitos de tallies ────────────────────────────────────────────────────
        for i = 1, #tallies do
            if tallies[i].curNum > tallies[i].num then
                tallies[i].curNum = tallies[i].num
            end
            local flipped = tostring(math.floor(tallies[i].curNum)):reverse()
            for j = 1, #flipped do
                local num = tonumber(flipped:sub(j, j))
                if num then
                    tallies[i].sprites[j]:animate(tostring(num), false)
                    if j > 1 and num > 0 and not tallies[i].sprites[j].visible then
                        tallies[i].sprites[j].visible = true
                        tallies[i].sprites[j].x = tallies[i].storedX[j-1] - 38
                        for k = 1, j-1 do
                            tallies[i].sprites[k].x = tallies[i].storedX[k]
                        end
                    end
                end
            end
        end

        for i = 1, #scoreNumbers.sprites do
            scoreNumbers.sprites[i]:update(dt)
        end

        if input:pressed("confirm") and scoreNumbers.visible and not graphics.isFading() then
            graphics.fadeOut(0.5, function()
                if resultsMusic then resultsMusic:stop() end
                if _G.storyMode then
                    Gamestate.switch(storymenu)
                else
                    Gamestate.switch(freeplay)
                end
                if music then music:play() end
            end)
        end
    end,

    -- ─────────────────────────────────────────────────────────────────────────────
    draw = function(self)
        love.graphics.push()
            -- Fondo amarillo
            graphics.setColor(255/255, 204/255, 92/255)
            love.graphics.rectangle("fill", 0, 0, 1280, 720)

            -- Patrón de fondo: variación en filas horizontales (toda la pantalla)
            if bgVariFont then
                local prevFont = love.graphics.getFont()
                love.graphics.setFont(bgVariFont)
                local bgWord = string.upper(resultsVariation) .. "   "
                local wordW  = bgVariFont:getWidth(bgWord)
                local lineH  = math.floor(bgVariFont:getHeight() * 1.45)
                local scrollX = bgScrollY % math.max(wordW, 1)

                love.graphics.push()
                    -- Leve diagonal como en el original
                    love.graphics.translate(640, 360)
                    love.graphics.rotate(-0.10)
                    love.graphics.translate(-640, -360)
                    for row = -2, math.ceil(760 / lineH) + 2 do
                        local xOff   = (row % 2 == 0) and 0 or wordW * 0.5
                        local startX = -scrollX + xOff - wordW
                        while startX < 1400 do
                            graphics.setColor(1, 1, 1, 0.14)
                            love.graphics.print(bgWord, startX, row * lineH)
                            startX = startX + wordW
                        end
                    end
                love.graphics.pop()

                -- Borde derecho: UNA sola columna vertical de la variación en blanco
                love.graphics.push()
                    love.graphics.translate(1218, 720)
                    love.graphics.rotate(-math.pi / 2)
                    local vWord  = string.upper(resultsVariation) .. "  "
                    local vWordW = bgVariFont:getWidth(vWord)
                    local vScroll = bgScrollY % math.max(vWordW, 1)
                    graphics.setColor(1, 1, 1, 0.90)
                    love.graphics.print(vWord:rep(25), vScroll - vWordW, 0)
                love.graphics.pop()

                love.graphics.setFont(prevFont)
                graphics.setColor(1, 1, 1)
            end

            -- Badge + CLEAR en título + nombre de canción (solo cuando badgeActive)
            if badgeActive then
                love.graphics.push()
                    love.graphics.translate(1280/2, 720/2)
                    love.graphics.rotate(-0.08)
                    love.graphics.translate(-1280/2, -720/2)

                    -- Porcentaje entre badge y nombre (Fase 1)
                    if showClearTitle and clearTitleFont then
                        local pFont2 = love.graphics.getFont()
                        love.graphics.setFont(clearTitleFont)
                        local pct   = math.floor(currentAccuracy * 100)
                        local ctTxt = pct .. "%"
                        -- Espacio reservado para "100%" (máximo posible)
                        local slotW = clearTitleFont:getWidth("100%") + 16
                        local ctX   = curDiff.x + curDiff:getWidth()/2 + 24
                        local ctY   = thePosEverY[1] - clearTitleFont:getHeight()/2
                        graphics.setColor(1, 1, 1, 0.95)
                        love.graphics.print(ctTxt, ctX, ctY)
                        love.graphics.setFont(pFont2)
                        graphics.setColor(1, 1, 1)
                        -- Nombre desplazado a la derecha del espacio del porcentaje
                        local displaySong = scoreData.displaySong or songName
                        local formattedStr = artist and string.format("%s by %s", displaySong, artist) or displaySong
                        printResultsFont(curDiff.x + curDiff:getWidth()/2 + slotW + 20, thePosEverY[1] - curDiff:getHeight()/2, formattedStr, 1)
                    else
                        local displaySong  = scoreData.displaySong or songName
                        local formattedStr = artist and string.format("%s by %s", displaySong, artist) or displaySong
                        printResultsFont(curDiff.x + curDiff:getWidth()/2 + 20, thePosEverY[1] - curDiff:getHeight()/2, formattedStr, 1)
                    end

                    curDiff:draw()
                love.graphics.pop()
            end

            -- ── Contador CLEAR / XX% detrás de los sprites ──────────────────────
            if bigFont and clearState.visible then
                local a     = clearState.alpha
                local pct   = math.floor(currentAccuracy * 100)
                local line1 = "CLEAR"
                local line2 = pct .. "%"
                -- Coordenadas en espacio de canvas virtual (1280×720) → escala correcta
                local pFont = love.graphics.getFont()
                love.graphics.setFont(bigFont)
                local w1 = bigFont:getWidth(line1)
                local w2 = bigFont:getWidth(line2)
                local cx = 880
                local y1, y2 = 255, 365
                local os = 5
                -- Contorno
                graphics.setColor(0.22, 0.22, 0.22, a)
                for ox = -os, os, os do
                    for oy = -os, os, os do
                        if ox ~= 0 or oy ~= 0 then
                            love.graphics.print(line1, cx - w1/2 + ox, y1 + oy)
                            love.graphics.print(line2, cx - w2/2 + ox, y2 + oy)
                        end
                    end
                end
                -- Relleno blanco
                graphics.setColor(1, 1, 1, a)
                love.graphics.print(line1, cx - w1/2, y1)
                love.graphics.print(line2, cx - w2/2, y2)
                love.graphics.setFont(pFont)
                graphics.setColor(1, 1, 1)
            end

            -- Personajes (cada uno en su propio push/pop para evitar leaks de transform)
            -- PERFECT: corazones (GF) encima de BF; el resto: GF detrás de BF
            if resultsVariation == "PERFECT" then
                love.graphics.push()
                    if resultsBF and resultsBF.visible then resultsBF:draw() end
                love.graphics.pop()
                love.graphics.push()
                    if resultsGF then resultsGF:draw() end
                love.graphics.pop()
            else
                love.graphics.push()
                    if resultsGF then resultsGF:draw() end
                love.graphics.pop()
                love.graphics.push()
                    if resultsBF and resultsBF.visible then resultsBF:draw() end
                love.graphics.pop()
            end

            -- HUD
            soundSystem:draw()
            topBarBlack:draw()
            resultsAnim:draw()
            ratingsPopin:draw()
            scorePopin:draw()

            for i = 1, #tallies do
                for j = 1, #tallies[i].sprites do
                    if not tallies[i].visible then break end
                    graphics.setColor(tallies[i].color[1], tallies[i].color[2], tallies[i].color[3])
                    tallies[i].sprites[j]:draw()
                    graphics.setColor(1, 1, 1)
                end
            end

            for i = 1, #scoreNumbers.sprites do
                if not scoreNumbers.visible then break end
                scoreNumbers.sprites[i]:draw()
            end
        love.graphics.pop()
    end,

    -- ─────────────────────────────────────────────────────────────────────────────
    leave = function(self)
        tallies              = {}
        scoreNumbers.sprites = {}
        resultsGF = nil
        resultsBF = nil
        gfPerfectShown = false
        soundSystem          = nil
        ratingsPopin         = nil
        scorePopin           = nil
        resultsAnim          = nil
        topBarBlack          = nil
        resultsFont          = {quads={}, img=nil}
        curDiff              = nil
        thePosEverX          = 0
        thePosEverY          = {0}
        if badgeDelayTimer then
            Timer.cancel(badgeDelayTimer)
            badgeDelayTimer = nil
        end
        if type(textTween) == "table" then
            Timer.cancel(textTween)
        end
        textTween            = nil
        if resultsMusic then
            resultsMusic:stop()
            resultsMusic = nil
        end
        _resultsCache  = {}
        badgeActive     = false
        showClearTitle  = false
        musicLoopActive = false
        if tickTimer then Timer.cancel(tickTimer); tickTimer = nil end
        if tickSound then tickSound:stop(); tickSound = nil end
        if confirmSource then confirmSource:stop(); confirmSource = nil end
        displayScore         = 0
        confirmPlayed        = false
        clearFadeTriggered   = false
        badgeReadyToSlide    = false
        -- bigFont, bgVariFont, clearTitleFont se conservan (solo se crean una vez)
    end
}
