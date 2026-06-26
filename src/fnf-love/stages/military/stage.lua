-- Stage: "military" (Week 7 - Tankman) — puerto 1:1 de states/stages/Tank.hx
--
-- Las 3 cutscenes de introducción de Story Mode (ughIntro/gunsIntro/
-- stressIntro) SÍ están portadas (ver M.startCutscene más abajo) usando
-- modules/animate_atlas.lua, un reproductor de "Adobe Animate Texture
-- Atlas" escrito para esto (Psych real usa FlxAnimate para tankman/pico en
-- estas 3 cutscenes específicamente -- es el único lugar de todo el juego
-- que usa ese formato en vez de sprite-sheets simples).

local M = {}

local psychStages = require("charts.psych.stages")
local atlas = require("charts.psych.atlas")
local json = require("lib.json")
local animateAtlas = require("modules.animate_atlas")

local sky, clouds, mountains, buildings, ruins, ground
local smokeLeft, smokeRight, tankWatchtower, tankRolling
local foregroundSprites = {}  -- { {sprite=, sfX=, sfY=}, ... }

local cloudsPsychX, cloudsPsychY, cloudsVel
local tankAngle, tankSpeed

local killedTankmen = {}
local picoQueue = {}
local picoIndex = 1
local currentLoopTimer

local songNum = 1
local lastBeatNum

-- ── Cutscenes de intro (Tank.hx: ughIntro/gunsIntro/stressIntro) ───────────
local cutsceneActive = false
local cutsceneTimers = {}      -- todos los Timer.after/tween en curso, para poder cancelar al hacer skip
local cutsceneOnComplete = nil
local cutsceneSkipFn = nil     -- limpieza específica de la cutscene actual antes de saltar
local cutsceneSounds = {}      -- FlxSound.list equivalente, para poder detenerlos todos al hacer skip

-- ── Skip con dial circular (CutsceneHandler.hx real) ───────────────────────
-- Psych NO salta con una sola pulsación: hay que MANTENER "accept" (Enter/
-- botón A, "confirm" acá) durante 1s completo, con un dial circular que se
-- va llenando como feedback (FlxPieDial, esquina inferior derecha). Soltar
-- antes de completarlo lo hace decaer rápido (no instantáneo) en vez de
-- resetear a 0 de golpe.
local SKIP_TIME_TO_SKIP = 1
local cutsceneHoldingTime = 0   -- holdingTime real
local cutsceneElapsedTime = 0   -- cutsceneTime real (desde que arrancó ESTA cutscene)
local SKIP_DIAL_RADIUS = 20     -- FlxPieDial(0,0,40,...) -- 40 de diámetro

-- Reloj de beat independiente, SOLO para cuando la cutscene está activa:
-- musicTime/bpm/absMusicTime quedan congelados por _G.cutscenePause (así
-- nadie pierde notas mientras dura la cutscene), así que el chequeo de
-- beat de más abajo ("if bpm and absMusicTime...") nunca dispara durante
-- ese rato -- de ahí que nada bailara al ritmo (torre, tanques de fondo,
-- bf/gf/enemy). Este acumulador usa dt real en su lugar.
local cutsceneBeatAccum = 0
-- Cuenta beats reales transcurridos durante la cutscene -- se usa para que
-- la torre/tanques de fondo bailen cada 2 beats (decisión explícita, ver
-- comentario en M.update() donde se usa). weeks:triggerDanceBeat() (bf/gf/
-- enemy) tiene su PROPIO contador interno y filtra por personaje sola --
-- se llama una vez por beat, sin ningún divisor acá.
local cutsceneBeatCount = 0

-- ── Cámara de cutscene: réplica de camFollow + FlxG.camera.follow(LOCKON) ──
-- Psych NUNCA tween-ea la posición de la cámara directo (eso sí lo hace
-- para el ZOOM, ver FlxTween.tween(FlxG.camera,{zoom=...}) en cada
-- cutscene) -- en su lugar, camFollow es un punto que se reposiciona
-- (instantáneo, o con su propio FlxTween en stress) y la cámara real lo
-- PERSIGUE cuadro a cuadro con un lerp exponencial:
--   FlxG.camera.followLerp = 0.04 * cameraSpeed (PlayState.hx línea 1676)
-- Antes, este archivo tweenaba cam.x/y directo a bfCamTarget()/
-- enemyCamTarget() -- esas dos funciones son la fórmula de "a quién mira
-- la cámara durante el gameplay normal" (mustHitSection), una fórmula
-- TOTALMENTE distinta de los offsets fijos que usa Tank.hx en las
-- cutscenes (dad.x+280, gf.x+150, etc.) -- de ahí el bug "apunta a bf
-- cuando debería apuntar a gf": no había ningún gf de por medio, apuntaba
-- a quien sea que bfCamTarget()/enemyCamTarget() devolvieran en ese
-- momento según mustHitSection, ajeno a la cutscene.
--
-- camFollow vive en la MISMA convención que Tank.hx (Flixel top-left,
-- character.x + offset fijo) -- la conversión a cam.x/y usa la fórmula ya
-- establecida en weeks.lua (bfCamTarget/enemyCamTarget): cam = -camFollow
-- + CONST (CONST_X=0, CONST_Y=-25).
local camFollow = { x = 0, y = 0 }
local cutsceneCameraSpeed = 1   -- game.cameraSpeed real (default 1, 12 en el snap final de stress)
-- dad (enemy) en convención top-left de Flixel, fijado una vez en
-- prepareCutscene() y reusado por ughIntro/stressIntro (dad no se mueve
-- durante la cutscene, solo anima en el lugar).
local cutsceneDadTopLeftX, cutsceneDadTopLeftY = 0, 0

local function camFollowToCam(fx, fy)
    return -fx, -fy - 25
end

-- FlxG.camera.snapToTarget(): la cámara salta INSTANTÁNEO a donde está
-- camFollow ahora mismo, sin lerp.
local function cutsceneCamSnap()
    cam.x, cam.y = camFollowToCam(camFollow.x, camFollow.y)
end

-- Llamado cada frame mientras la cutscene está activa (ver M.update).
-- Repite el lerp exponencial de Flixel de forma independiente del
-- framerate: con followLerp=L por frame a 60fps fijos (el framerate de
-- referencia de Flixel/Psych), la fracción del camino que queda sin
-- recorrer tras 1 segundo real es (1-L)^60 -- eso equivale a un
-- decaimiento continuo exp(-k*t) con k = -60*ln(1-L) (mismo patrón que
-- camZoomBump/beatPulse, unas líneas más abajo en weeks.lua).
local function updateCutsceneCamFollow(dt)
    local targetX, targetY = camFollowToCam(camFollow.x, camFollow.y)
    local followLerp = 0.04 * cutsceneCameraSpeed
    if followLerp >= 1 then
        cam.x, cam.y = targetX, targetY
        return
    end
    local k = -60 * math.log(1 - followLerp)
    local decay = math.exp(-k * dt)
    cam.x = targetX + (cam.x - targetX) * decay
    cam.y = targetY + (cam.y - targetY) * decay
end

local tankmanCutscene, picoCutscene, boyfriendCutscene  -- instancias de animate_atlas / sprite congelado

-- pico-speaker.json: nombres internos reales (NO el campo "name" descriptivo
-- del atlas, p.ej. "Pico shoot 3" -- ese es solo el prefijo de frames).
local PICO_SHOOT_VARIANTS = {
    [0] = {"shoot3", "shoot4"},
    [3] = {"shoot1", "shoot2"},
}
local PICO_LOOP_VARIANTS = {
    [0] = {"shoot3-loop", "shoot4-loop"},
    [3] = {"shoot1-loop", "shoot2-loop"},
}

-- ── TankmenBG.hx real (tankmen muertos corriendo hacia Pico en Stress) ──────
-- Atlas real tankmanKilled1 (prefijos "tankman running" y "John Shot 1"/"2"),
-- cacheado una sola vez.
local tankmanImage, tankmanFrames

local function framesByPrefix(frames, prefix)
    local result = {}
    for _, f in ipairs(frames) do
        if f.name and f.name:sub(1, #prefix) == prefix then table.insert(result, f) end
    end
    return result
end

local function loadTankmanAtlas()
    if tankmanFrames then return end
    local pngPath = graphics.imagePath("week7/tankmanKilled1")
    tankmanImage  = love.graphics.newImage(pngPath)
    -- El atlas vive junto al .png fuente, nunca como variante .dds (ver
    -- charts/psych/character.lua para la explicación completa de este bug).
    tankmanFrames = atlas.loadSparrow("images/png/week7/tankmanKilled1.xml")
end

-- TankmenBG.hx new(x,y,facingRight): construye un sprite fresco con "run"
-- (loop) y "shot" (sin loop, variante 1 o 2 al azar, fija para esta
-- instancia -- Psych la fija una vez en el constructor y la reusa al
-- reciclar). scale 0.8, flipX = goingRight.
local function newTankman(goingRight)
    loadTankmanAtlas()

    local frameData, animData = {}, {}

    local function addAnim(name, frames)
        local start = #frameData + 1
        for _, f in ipairs(frames) do
            table.insert(frameData, {
                x = f.x, y = f.y, width = f.width, height = f.height,
                offsetX = f.frameX, offsetY = f.frameY,
                offsetWidth = f.frameWidth, offsetHeight = f.frameHeight,
            })
        end
        animData[name] = { start = start, stop = #frameData, speed = 24, offsetX = 0, offsetY = 0 }
    end

    addAnim("run", framesByPrefix(tankmanFrames, "tankman running"))
    addAnim("shot", framesByPrefix(tankmanFrames, "John Shot " .. love.math.random(1, 2)))

    local sprite = graphics.newSprite(tankmanImage, frameData, animData, "run", true)
    sprite.sizeX = goingRight and -0.8 or 0.8  -- flipX = goingRight
    sprite.sizeY = 0.8

    -- Tank.hx createPost(): resetShit(500, 200 + random.int(50,100), ...) --
    -- "y" se fija UNA vez (a diferencia de "x", que update() recalcula cada
    -- frame) y nunca cambia. Conversión Psych top-left -> Rewritten centro
    -- vía getOrigin() (frame "run" inicial), escalada por sizeY=0.8 -- sin
    -- esto el tankman quedaba en y=0 (el default), cerca del borde superior.
    local ox, oy = sprite:getOrigin()
    sprite.y = (200 + love.math.random(50, 100)) + oy * 0.8

    -- TankmenBG.hx campos propios
    sprite.goingRight   = goingRight
    sprite.endingOffset = 50 + love.math.random() * 150          -- random.float(50,200)
    sprite.tankSpeed     = 0.6 + love.math.random() * 0.4         -- random.float(0.6,1)
    sprite.strumTime     = 0
    sprite.shotTriggered = false

    return sprite
end

-- TankmenBG.hx update(): posición recalculada cada frame en función del
-- tiempo transcurrido desde strumTime (NO velocidad por dt) -- por eso el
-- tankman existe desde el arranque de la canción pero solo se ve cuando su
-- strumTime se acerca. Visibilidad por rango de pantalla real (-0.5*w a
-- 1.2*w). Al pasar strumTime, dispara "shot" (con el empujón de posición que
-- Psych aplica solo si goingRight). Devuelve true cuando ya puede eliminarse
-- (anim "shot" terminada).
local SCREEN_W = 1280
local function updateTankman(k, musicTimeMs)
    if k:getAnimName() == "run" then
        local speed = (musicTimeMs - k.strumTime) * k.tankSpeed
        if k.goingRight then
            k.x = (0.02 * SCREEN_W - k.endingOffset) + speed
        else
            k.x = (0.74 * SCREEN_W + k.endingOffset) - speed
        end
    elseif k:isAnimFinished() then
        return true
    end

    k.visible = (k.x > -0.5 * SCREEN_W and k.x < 1.2 * SCREEN_W)

    if not k.shotTriggered and musicTimeMs > k.strumTime then
        k.shotTriggered = true
        k:animate("shot", false)
        if k.goingRight then
            -- TankmenBG.hx: offset.x=300, offset.y=200 (ajuste visual solo
            -- al ir hacia la derecha), escalado por sizeY=0.8 del sprite.
            k.x = k.x + 300 * 0.8
            k.y = k.y + 200 * 0.8
        end
    end

    return false
end

-- Character.hx loadMappedAnims(): carga TODAS las notas de TODAS las
-- secciones de data/stress/picospeaker.json (chart dedicado solo para
-- coreografiar esto, no es el chart real de la canción) en una lista plana
-- ordenada por strumTime.
local function loadPicospeakerNotes()
    local raw = love.filesystem.read("data/stress/picospeaker.json")
    if not raw then return {} end

    local ok, data = pcall(json.decode, raw)
    if not ok or not data or not data.notes then return {} end

    local notes = {}
    for _, section in ipairs(data.notes) do
        for _, n in ipairs(section.sectionNotes or {}) do
            table.insert(notes, { time = n[1], dir = n[2] })
        end
    end

    table.sort(notes, function(a, b) return a.time < b.time end)

    return notes
end

local function updatePicoQueue(musicTimeMs)
    while picoIndex <= #picoQueue do
        local ev = picoQueue[picoIndex]
        if musicTimeMs < ev.t then break end

        local dir = ev.dir
        local variantsShoot = PICO_SHOOT_VARIANTS[dir] or PICO_SHOOT_VARIANTS[3]
        local variantsLoop  = PICO_LOOP_VARIANTS[dir]  or PICO_LOOP_VARIANTS[3]
        local idx       = math.random(1, 2)
        local shootAnim = variantsShoot[idx]
        local loopAnim  = variantsLoop[idx]

        if currentLoopTimer then Timer.cancel(currentLoopTimer); currentLoopTimer = nil end

        if girlfriend then girlfriend:animate(shootAnim, false) end

        if girlfriend and girlfriend.anims and girlfriend.anims[shootAnim] then
            local a      = girlfriend.anims[shootAnim]
            local frames = a.stop - a.start + 1
            local dur    = frames / (a.speed or 24)
            currentLoopTimer = Timer.after(dur, function()
                if girlfriend then girlfriend:animate(loopAnim, true) end
                currentLoopTimer = nil
            end)
        elseif girlfriend then
            girlfriend:animate(loopAnim, true)
        end

        picoIndex = picoIndex + 1
    end
end

-- ============================================================================
-- CUTSCENES DE INTRODUCCIÓN (Tank.hx: prepareCutscene/ughIntro/gunsIntro/
-- stressIntro), portadas 1:1 en cuanto a timing/audio/cámara. Diferencias
-- de adaptación, explicadas donde aparecen:
--   - camFollow SÍ existe acá (la tabla `camFollow` declarada más arriba,
--     junto a updateCutsceneCamFollow/cutsceneCamSnap/camFollowToCam) --
--     réplica del punto que la cámara real persigue cuadro a cuadro con un
--     lerp exponencial (FlxG.camera.followLerp = 0.04*cameraSpeed), NO un
--     tween directo de cam.x/y. La primera versión de este archivo SÍ
--     tweenaba cam.x/y directo (y, peor, lo apuntaba a bfCamTarget()/
--     enemyCamTarget() -- la fórmula de "a quién mira la cámara durante el
--     gameplay normal", nada que ver con los offsets fijos de Tank.hx) --
--     de ahí el bug reportado de "apunta a bf cuando debería apuntar a gf".
--   - Skip: portado 1:1 -- mantener "confirm" (equivalente a "accept" de
--     Psych) durante 1s completo, con el dial circular relleno como
--     feedback (ver drawSkipDial/cutsceneHoldingTime). Soltar antes de
--     completarlo decae con un lerp, no resetea a 0 de golpe -- igual que
--     CutsceneHandler.hx real.
--   - FlxAnimate (tankman/pico) -> modules/animate_atlas.lua, escrito para
--     esto -- ver ese archivo para el detalle del formato.
-- ============================================================================

local function addCutsceneTimer(handle)
    table.insert(cutsceneTimers, handle)
    return handle
end

local function clearCutsceneTimers()
    for _, h in ipairs(cutsceneTimers) do
        if h then Timer.cancel(h) end
    end
    cutsceneTimers = {}
end

local function stopCutsceneSounds()
    for _, snd in ipairs(cutsceneSounds) do
        if snd then snd:stop() end
    end
    cutsceneSounds = {}
end

-- Tank.hx prepareCutscene(): oculta HUD + enemy (dadGroup.alpha), crea el
-- tankman de la cutscene DETRÁS del enemy real, enfoca la cámara en él.
local function prepareCutscene()
    cutsceneActive = true
    _G.disableAutoCam = true
    -- Congela TODA la simulación de gameplay (notas, musicTime, hit/miss --
    -- ver guardia agregada en states/weeks.lua:update()) -- sin esto el
    -- chart "arranca solo" en segundo plano (musicTime avanza con el
    -- reloj real aunque countingDown sea false) y bf puede morir por notas
    -- falladas que ni deberían existir todavía.
    _G.cutscenePause = true
    cutsceneBeatAccum = 0
    cutsceneBeatCount = 0
    cutsceneHoldingTime = 0
    cutsceneElapsedTime = 0
    weeks:getGuiAlphaObj().value = 0
    if enemy then enemy.alpha = 0.00001 end

    tankmanCutscene = animateAtlas.newInstance(animateAtlas.load("images/png/week7/cutscenes/tankman"))
    -- Tank.hx: tankman.x = dad.x+419 (Flixel, dad.x = TOP-LEFT del
    -- bounding box). enemy.x acá es el CENTRO (convención de todo este
    -- motor) -- hay que restar el offset de getOrigin() para volver al
    -- equivalente top-left antes de sumar el offset real de Psych, igual
    -- que hace newTankman() más arriba en este mismo archivo para
    -- TankmenBG. Sin esto, tankman aparecía mucho más abajo/desplazado de
    -- lo que debía (el offset +225 se sumaba sobre el CENTRO, no el
    -- top-left, así que terminaba como medio alto del personaje más abajo).
    local enemyOx, enemyOy = 0, 0
    if enemy then enemyOx, enemyOy = enemy:getOrigin() end
    cutsceneDadTopLeftX = (enemy and enemy.x or 0) - enemyOx
    cutsceneDadTopLeftY = (enemy and enemy.y or 0) - enemyOy
    tankmanCutscene.x = cutsceneDadTopLeftX + 419
    tankmanCutscene.y = cutsceneDadTopLeftY + 225

    -- Psych: camFollow.setPosition(dad.x+280, dad.y+170) -- sin snap
    -- explícito acá (el real tampoco lo hace): la cámara se desliza desde
    -- donde estaba en el gameplay normal hacia este punto, vía el lerp de
    -- updateCutsceneCamFollow() (ver M.update).
    cutsceneCameraSpeed = 1
    camFollow.x = cutsceneDadTopLeftX + 280
    camFollow.y = cutsceneDadTopLeftY + 170
end

-- Tank.hx cutsceneHandler.finishCallback: restaura todo y dispara
-- startCountdown() (acá, el onComplete que pasó week7.lua).
local function finishCutscene()
    if not cutsceneActive then return end
    cutsceneActive = false

    clearCutsceneTimers()
    _G.disableAutoCam = false
    _G.cutscenePause = false
    weeks:getGuiAlphaObj().value = 1
    if enemy then enemy.alpha = 1 end
    if girlfriend then girlfriend.alpha = 1 end
    if boyfriend then boyfriend.alpha = 1 end
    if boyfriendCutscene then boyfriendCutscene.visible = false end
    if picoCutscene then picoCutscene.visible = false end

    -- Tank.hx finishCallback REAL: "gf.animation.finishCallback = null;
    -- gf.dance();" -- corta el ciclo de "sad" (cryLoop, ver gunsIntro) que
    -- se re-dispara a sí mismo, y la fuerza a bailar de nuevo. Sin esto,
    -- "sad" (loop=false + callback) quedaba repitiéndose para siempre
    -- después de que la cutscene termina -- y antes, con loop=true
    -- directo, era PEOR: ni esto la salvaba, porque isAnimated() nunca
    -- daba false (ver nota en triggerDanceBeat/isDanceOrIdle, weeks.lua).
    if girlfriend then girlfriend:animate("danceLeft", false) end

    local cb = cutsceneOnComplete
    cutsceneOnComplete = nil
    cutsceneSkipFn = nil
    if cb then cb() end
end

-- Skip (simplificado, ver cabecera): cancela todo, deja todo visible/normal
-- y pasa directo a finishCutscene().
local function skipCutscene()
    if not cutsceneActive then return end
    stopCutsceneSounds()
    if cutsceneSkipFn then cutsceneSkipFn() end
    finishCutscene()
end

-- Tank.hx: el finishCallback REAL (compartido por las 3 cutscenes, fijado
-- una sola vez en prepareCutscene()) hace fade de música + tween de zoom
-- de vuelta a defaultCamZoom, y SOLO AHÍ llama a startCountdown() -- nunca
-- llama a finishCutscene() antes de que el tween de zoom termine.
--
-- Mi primera versión llamaba a finishCutscene() (que pone
-- _G.disableAutoCam=false) AL MISMO TIEMPO que arrancaba el tween de zoom
-- -- la cámara automática (ya reactivada) y mi propio tween competían por
-- cam.sizeX/Y cuadro a cuadro durante toda la duración del tween, lo cual
-- se veía exactamente como lo describiste: brusco y con peleas visuales.
-- Solución: NO reactivar disableAutoCam (ni nada más de finishCutscene)
-- hasta que el tween de zoom termine de verdad.
--
-- music: la fuente de audio.lua de fondo a la que hacerle fade (nil si la
-- cutscene no tiene música de fondo, como Stress).
local function finishCutsceneWithFade(music)
    -- Conductor.crochet/1000*4.5 real, crochet=60000/bpm (ms) -> en
    -- segundos: (60000/bpm)/1000*4.5 = (60/bpm)*4.5.
    local fadeTime = math.max(0.3, (60 / (bpm or 100)) * 4.5)
    if music then
        addCutsceneTimer(Timer.tween(fadeTime, music, {Volume = 0}, "linear", function()
            music:stop()
        end))
    end
    addCutsceneTimer(Timer.tween(fadeTime, cam, {sizeX = camScale.x, sizeY = camScale.y}, "in-out-quad", finishCutscene))
end

local function ughIntro(onComplete)
    cutsceneOnComplete = onComplete
    prepareCutscene()

    local wellWellWell = love.audio.newSource("sounds/week7/wellWellWell.ogg", "static")
    local killYouSnd    = love.audio.newSource("sounds/week7/killYou.ogg", "static")
    local bfBeepSnd      = love.audio.newSource("sounds/week7/bfBeep.ogg", "static")
    cutsceneSounds = { wellWellWell, killYouSnd, bfBeepSnd }

    local music = love.audio.newSource("music/week7/DISTORTO.ogg", "stream")
    music:play()
    table.insert(cutsceneSounds, music)

    tankmanCutscene:playSymbol("TANK TALK 1 P1", false)
    cam.sizeX = camScale.x * 1.2
    cam.sizeY = camScale.y * 1.2

    addCutsceneTimer(Timer.after(0.1, function()
        audio.playSound(wellWellWell)
    end))

    -- Mover cámara hacia boyfriend: Psych hace "camFollow.x+=750;
    -- camFollow.y+=100;" -- un reposicionamiento INSTANTÁNEO del punto que
    -- la cámara persigue, SIN tween de posición propio (el deslizamiento
    -- suave que se ve viene solo del lerp de updateCutsceneCamFollow).
    addCutsceneTimer(Timer.after(3, function()
        camFollow.x = camFollow.x + 750
        camFollow.y = camFollow.y + 100
    end))

    addCutsceneTimer(Timer.after(4.5, function()
        -- "singUP" es el nombre PSYCH -- charts/psych/animnames.lua lo
        -- traduce a "up" al construir el sprite (toInternal: "singUP" ->
        -- "up"), así que la key real en boyfriend.anims es "up", no
        -- "singUP" literal. Por eso el WARN decía "no existe en sprite":
        -- no era timing ni que muriera, era el nombre.
        if boyfriend then boyfriend:animate("up", false) end
        audio.playSound(bfBeepSnd)
    end))

    -- Volver la cámara a tankman + "killYou" (camFollow.x-=750, y-=100 real)
    addCutsceneTimer(Timer.after(6, function()
        camFollow.x = camFollow.x - 750
        camFollow.y = camFollow.y - 100
        tankmanCutscene:playSymbol("TANK TALK 1 P2", false)
        audio.playSound(killYouSnd)
    end))

    cutsceneSkipFn = function()
        music:stop()
    end

    addCutsceneTimer(Timer.after(12, function()
        finishCutsceneWithFade(music)
    end))
end

local function gunsIntro(onComplete)
    cutsceneOnComplete = onComplete
    prepareCutscene()

    local tightBars = love.audio.newSource("sounds/week7/tankSong2.ogg", "static")
    local music = love.audio.newSource("music/week7/DISTORTO.ogg", "stream")
    cutsceneSounds = { tightBars, music }

    tankmanCutscene:playSymbol("TANK TALK 2", false)

    music:play()
    audio.playSound(tightBars)

    addCutsceneTimer(Timer.tween(4, cam, {sizeX = camScale.x * 1.2, sizeY = camScale.y * 1.2}, "in-out-quad"))
    addCutsceneTimer(Timer.after(4, function()
        addCutsceneTimer(Timer.tween(0.5, cam, {sizeX = camScale.x * 1.2 * 1.2, sizeY = camScale.y * 1.2 * 1.2}, "in-out-quad"))
    end))
    addCutsceneTimer(Timer.after(4.5, function()
        addCutsceneTimer(Timer.tween(1, cam, {sizeX = camScale.x * 1.2, sizeY = camScale.y * 1.2}, "in-out-quad"))
    end))

    -- Tank.hx real: gf.playAnim('sad', true) -- el "true" ahí es FORCE (Flixel
    -- animation.play(Name,Force,...)), NO loop. "sad" es una animación de
    -- una sola pasada; Psych la repite con un finishCallback que se
    -- re-dispara a sí mismo cada vez que termina:
    --   gf.animation.finishCallback = function(name) gf.playAnim('sad', true); end
    -- Usar loop=true (como hacía esto antes) reproduce el mismo VISUAL pero
    -- de una forma que nuestro motor no puede "cortar" después -- una vez
    -- en loop=true, sigue así para siempre, ignorando cualquier protección
    -- de animación (isAnimated() nunca se vuelve false). Por eso se
    -- replica el mecanismo real (loop=false + callback que se re-llama),
    -- así finishCutscene() puede cortarlo de verdad llamando a
    -- :animate(otra cosa) sin pasarle callback (pisa el pendiente).
    addCutsceneTimer(Timer.after(4, function()
        local function cryLoop()
            if girlfriend then girlfriend:animate("sad", false, cryLoop) end
        end
        cryLoop()
    end))

    cutsceneSkipFn = function()
        music:stop()
    end

    addCutsceneTimer(Timer.after(11.5, function()
        finishCutsceneWithFade(music)
    end))
end

-- Tank.hx zoomBack(): camFollow.setPosition(630,425) (punto FIJO del
-- stage, no relativo a ningún personaje) + snapToTarget() (instantáneo,
-- sin lerp) + zoom=0.8 + cameraSpeed=1 (resetea cualquier cameraSpeed=12
-- que haya quedado del snap de boyfriend más abajo).
--
-- Nota: el real tiene un bug confirmado leyendo Tank.hx -- "var
-- calledTimes:Int = 0;" está declarada DENTRO de la función, así que se
-- reinicia a 0 en cada llamada; "calledTimes++" la deja en 1, y el
-- "if(calledTimes>1)" que debería revertir el foregroundSprites.y+=100 de
-- stressIntro NUNCA se cumple. El desplazamiento de los sprites de
-- primer plano queda PERMANENTE el resto de la canción en el juego real
-- -- se replica tal cual (ver stressIntro, no hay reversión a propósito).
local function stressZoomBack()
    camFollow.x, camFollow.y = 630, 425
    cutsceneCamSnap()
    cam.sizeX, cam.sizeY = 0.8, 0.8
    cutsceneCameraSpeed = 1
end

local function stressIntro(onComplete)
    cutsceneOnComplete = onComplete
    prepareCutscene()

    -- M.load() ya puso "shoot1-loop" en girlfriend, PERO eso fue ANTES de
    -- que week7.lua corra initUI()->applyChartMeta(), que recarga a
    -- girlfriend como "pico-speaker" desde cero (psychCharacters.loadInto)
    -- y la deja en su PRIMERA animación declarada en el JSON ("shoot1",
    -- sin loop) -- pisando el loop sin que se note porque acá abajo la
    -- ocultamos con alpha. Por eso aparecía "congelada" recién al
    -- revelarla al final: nunca estuvo en loop, estaba en una animación de
    -- una sola pasada ya terminada. Re-disparado acá, después de que el
    -- pisado ya pasó.
    if girlfriend then girlfriend:animate("shoot1-loop", true) end

    if girlfriend then girlfriend.alpha = 0.00001 end
    if boyfriend  then boyfriend.alpha  = 0.00001 end

    -- Psych: camFollow.setPosition(dad.x+400, dad.y+170) -- pisa el
    -- dad.x+280 que dejó prepareCutscene() (Stress arranca más alejado de
    -- tankman que Ugh/Guns).
    camFollow.x = cutsceneDadTopLeftX + 400
    camFollow.y = cutsceneDadTopLeftY + 170

    addCutsceneTimer(Timer.tween(1, cam, {sizeX = 0.9 * 1.2, sizeY = 0.9 * 1.2}, "in-out-quad"))

    -- Psych: foregroundSprites.forEach(spr.y += 100) -- sin reversión (ver
    -- nota completa del bug real en stressZoomBack): el desplazamiento
    -- queda permanente el resto de la canción, igual que en Psych Engine.
    for _, def in ipairs(foregroundSprites) do
        if def.sprite then def.sprite.y = def.sprite.y + 100 end
    end

    local cutsceneSnd = love.audio.newSource("sounds/week7/stressCutscene.ogg", "static")
    cutsceneSounds = { cutsceneSnd }

    picoCutscene = animateAtlas.newInstance(animateAtlas.load("images/png/week7/cutscenes/picoAppears"))
    -- Misma conversión centro->top-left que tankmanCutscene (ver
    -- prepareCutscene) para X: gf.x es centro acá, top-left en Psych.
    --
    -- Y: el atlas Adobe Animate tiene su propio punto de registro interno
    -- (de Animate, no tiene relación matemática verificable con
    -- getOrigin()/Sparrow XML que usa el sprite normal de gameplay) -- no
    -- hay fórmula derivable, así que esto es un offset puramente empírico,
    -- calibrado por feedback visual directo. Antes de que characters.lua
    -- corrigiera la posición base de pico-speaker (yCorrection), "= gf.y
    -- directo" coincidía aproximadamente por casualidad con la posición
    -- (entonces incorrecta) de gf.y; ahora que gf.y ya está bien, hace
    -- falta este offset fijo aparte. Calibración iterativa por feedback:
    -- +220 ("muy arriba") -> se pasó de largo ("muy abajo") -> 120 ("un
    -- poco más abajo de lo debido") -> restar "poco, ~30-60px" -> 75.
    local picoYOffset = 61
    local gfOx = 0
    if girlfriend then gfOx = girlfriend:getOrigin() end
    picoCutscene.x = (girlfriend and girlfriend.x or 0) - gfOx + 150
    picoCutscene.y = (girlfriend and girlfriend.y or 0) + picoYOffset
    picoCutscene:playSymbol("GF Dancing at Gunpoint", true)

    -- boyfriendCutscene: copia congelada de BF en su pose idle (Tank.hx usa
    -- un FlxSprite nuevo con BOYFRIEND.xml congelado en el último frame de
    -- "idle" -- acá reusamos el loader normal de bf y fijamos el frame).
    local ok, spr = pcall(function() return love.filesystem.load("sprites/boyfriend.lua")() end)
    if ok and spr then
        boyfriendCutscene = spr
        boyfriendCutscene.x = (boyfriend and boyfriend.x or 0) + 5
        boyfriendCutscene.y = (boyfriend and boyfriend.y or 0) + 20
        boyfriendCutscene:animate("idle", false)
        boyfriendCutscene:setFrame(boyfriendCutscene:getFrameCount())
    end

    tankmanCutscene:playSymbol("TANK TALK 3 P1 UNCUT", false)
    audio.playSound(cutsceneSnd)

    -- Ciclo de animación de pico (picoStressCycle real): cuando termina
    -- "dieBitch" pasa a "picoAppears"; cuando termina ESA, pasa a
    -- "picoEnd"; cuando ESA termina, listo (gf vuelve, pico se esconde).
    picoCutscene:onComplete(function(inst)
        local name = inst:getCurrentSymbolName()
        if name == "GF Time to Die sequence" or name == "dieBitch" then
            inst:playSymbol("Pico Saves them sequence", false)
            if boyfriend then boyfriend.alpha = 1 end
            if boyfriendCutscene then boyfriendCutscene.visible = false end
            if boyfriend then boyfriend:animate("bfCatch", false) end
        elseif name == "Pico Saves them sequence" or name == "picoAppears" then
            inst:playSymbol("Pico Dual Wield on Speaker idle", false)
        elseif name == "Pico Dual Wield on Speaker idle" or name == "picoEnd" then
            if girlfriend then girlfriend.alpha = 1 end
            inst.visible = false
        end
    end)

    -- Psych: FlxTween.tween(camFollow, {x:650,y:300}, 1, sineOut) -- ESTO
    -- sí tween-ea camFollow mismo (punto FIJO del stage, no relativo a
    -- ningún personaje) -- la cámara real lo persigue por encima con su
    -- propio lerp (doble suavizado, igual que el real).
    addCutsceneTimer(Timer.after(15.2, function()
        addCutsceneTimer(Timer.tween(1, camFollow, {x = 650, y = 300}, "out-sine"))
        addCutsceneTimer(Timer.tween(2.25, cam, {sizeX = 0.9 * 1.2 * 1.2, sizeY = 0.9 * 1.2 * 1.2}, "in-out-quad"))
        picoCutscene:playSymbol("GF Time to Die sequence", false)
    end))

    addCutsceneTimer(Timer.after(17.5, stressZoomBack))

    addCutsceneTimer(Timer.after(19.5, function()
        tankmanCutscene:playSymbol("TANK TALK 3 P2 UNCUT", false)
    end))

    -- Psych: camFollow.setPosition(dad.x+500, dad.y+170) -- instantáneo,
    -- SIN snapToTarget() (la cámara se desliza vía el lerp normal, no
    -- salta).
    addCutsceneTimer(Timer.after(20, function()
        camFollow.x = cutsceneDadTopLeftX + 500
        camFollow.y = cutsceneDadTopLeftY + 170
    end))

    -- Psych: camFollow.setPosition(boyfriend.x+280, boyfriend.y+200) +
    -- snapToTarget() (instantáneo) + cameraSpeed=12 (la cámara queda mucho
    -- más "pegada" a camFollow para lo que sigue, hasta que zoomBack() la
    -- resetea a 1). boyfriend.x acá es CENTRO (convención de este motor) --
    -- misma conversión a top-left que dad en prepareCutscene.
    addCutsceneTimer(Timer.after(31.2, function()
        -- "singUPmiss" -> "miss up" (ver nota igual en ughIntro).
        if boyfriend then boyfriend:animate("miss up", false) end
        local bfOx, bfOy = 0, 0
        if boyfriend then bfOx, bfOy = boyfriend:getOrigin() end
        local bfTopLeftX = (boyfriend and boyfriend.x or 0) - bfOx
        local bfTopLeftY = (boyfriend and boyfriend.y or 0) - bfOy
        camFollow.x = bfTopLeftX + 280
        camFollow.y = bfTopLeftY + 200
        cutsceneCamSnap()
        cutsceneCameraSpeed = 12
        addCutsceneTimer(Timer.tween(0.25, cam, {sizeX = 0.9 * 1.2 * 1.2, sizeY = 0.9 * 1.2 * 1.2}, "out-elastic"))
    end))

    addCutsceneTimer(Timer.after(32.2, stressZoomBack))

    cutsceneSkipFn = function()
        if girlfriend then girlfriend.alpha = 1 end
        if boyfriend  then boyfriend.alpha  = 1 end
    end

    -- Stress no tiene música de fondo propia (solo el audio de diálogo,
    -- que ya terminó para este punto) -- por eso music=nil. El último
    -- stressZoomBack() (32.2s) ya dejó zoom=0.8 instantáneo (igual que
    -- Psych real); este fade SOLO se encarga de la transición final
    -- 0.8 -> camScale (zoom normal de gameplay) sin pelear con la cámara
    -- automática.
    addCutsceneTimer(Timer.after(35.5, function()
        finishCutsceneWithFade(nil)
    end))
end

-- Llamado desde week7.lua en vez de weeks:setupCountdown() cuando hace
-- falta mostrar la cutscene -- onComplete() es justo setupCountdown.
function M.startCutscene(song, onComplete)
    if song == 1 then
        ughIntro(onComplete)
    elseif song == 2 then
        gunsIntro(onComplete)
    elseif song == 3 then
        stressIntro(onComplete)
    else
        onComplete()
    end
end

function M.isCutsceneActive()
    return cutsceneActive
end

function M.load(song)
    songNum = song or 1

    sky       = graphics.newImage(love.graphics.newImage(graphics.imagePath("week7/tankSky")))
    clouds    = graphics.newImage(love.graphics.newImage(graphics.imagePath("week7/tankClouds")))
    mountains = graphics.newImage(love.graphics.newImage(graphics.imagePath("week7/tankMountains")))
    buildings = graphics.newImage(love.graphics.newImage(graphics.imagePath("week7/tankBuildings")))
    ruins     = graphics.newImage(love.graphics.newImage(graphics.imagePath("week7/tankRuins")))
    ground    = graphics.newImage(love.graphics.newImage(graphics.imagePath("week7/tankGround")))

    sky.x,       sky.y       = 528, 90       -- Psych (-400,-400), sf=(0,0)
    mountains.sizeX, mountains.sizeY = 1.2, 1.2
    mountains.x, mountains.y = 591, 425      -- Psych (-300,-20), sf=(0.2,0.2)
    buildings.sizeX, buildings.sizeY = 1.1, 1.1
    buildings.x, buildings.y = 678, 399      -- Psych (-200,0), sf=(0.3,0.3)
    ruins.sizeX, ruins.sizeY = 1.1, 1.1
    ruins.x,     ruins.y     = 678, 399      -- Psych (-200,0), sf=(0.35,0.35)
    ground.sizeX, ground.sizeY = 1.15, 1.15
    ground.x,    ground.y    = 684, 471      -- Psych (-420,-150), sf=(1,1)

    -- Tank.hx: clouds en posición/velocidad aleatoria, sf=(0.1,0.1)
    cloudsPsychX = love.math.random(-700, -100)
    cloudsPsychY = love.math.random(-20, 20)
    cloudsVel    = love.math.random(5, 15)
    clouds.x, clouds.y = cloudsPsychX + 1037.5, cloudsPsychY + 117.5

    smokeLeft = love.filesystem.load("sprites/week7/smokeLeft.lua")()
    smokeLeft.x, smokeLeft.y = 12, 117  -- Psych (-200,-100), sf=(0.4,0.4)
    smokeLeft:animate("SmokeBlurLeft", true)

    smokeRight = love.filesystem.load("sprites/week7/smokeRight.lua")()
    smokeRight.x, smokeRight.y = 1349, 322  -- Psych (1100,-100), sf=(0.4,0.4)
    smokeRight:animate("SmokeRight", true)

    tankWatchtower = love.filesystem.load("sprites/week7/tankWatchtower.lua")()
    tankWatchtower.x, tankWatchtower.y = 284, 388  -- Psych (100,50), sf=(0.5,0.5)
    tankWatchtower:animate("watchtower gradient color", false)

    tankRolling = love.filesystem.load("sprites/week7/tankRolling.lua")()
    tankRolling:animate("BG tank w lighting", true)
    tankAngle = love.math.random(-90, 45)
    tankSpeed = love.math.random() * 2 + 5  -- random.float(5,7)

    -- Tank.hx createPost(): foregroundSprites, cada uno con su propio
    -- scrollFactor y nombre de animación real (todos 'fg' salvo tank2,
    -- que en Psych real usa 'foreground').
    foregroundSprites = {
        {file = "sprites/week7/tank0.lua", x = -346, y = 862,  sfX = 1.7, sfY = 1.5, anim = "fg"},
        {file = "sprites/week7/tank1.lua", x = -64,  y = 802,  sfX = 2,   sfY = 0.2, anim = "fg"},
        {file = "sprites/week7/tank2.lua", x = 595,  y = 1084, sfX = 1.5, sfY = 1.5, anim = "foreground"},
        {file = "sprites/week7/tank4.lua", x = 1500, y = 1054, sfX = 1.5, sfY = 1.5, anim = "fg"},
        {file = "sprites/week7/tank5.lua", x = 1777, y = 912,  sfX = 1.5, sfY = 1.5, anim = "fg"},
        {file = "sprites/week7/tank3.lua", x = 1595, y = 1256, sfX = 3.5, sfY = 2.5, anim = "fg"},
    }
    for _, def in ipairs(foregroundSprites) do
        local ok, spr = pcall(function() return love.filesystem.load(def.file)() end)
        if ok and spr then
            spr.x, spr.y = def.x, def.y
            spr:animate(def.anim, false)
            def.sprite = spr
        end
    end

    killedTankmen = {}
    picoQueue     = {}
    picoIndex     = 1
    if currentLoopTimer then Timer.cancel(currentLoopTimer); currentLoopTimer = nil end

    if songNum == 3 then
        local ok2, picoNotes = pcall(love.filesystem.load, "charts/week7/stress-pico.lua")
        if ok2 and picoNotes then
            picoQueue = picoNotes()
        end

        -- Tank.hx createPost(): TODOS los tankmen "elegidos" se crean de una
        -- al cargar el stage (no se programan con un timer) -- cada uno
        -- existe desde el arranque pero solo se vuelve visible cuando su
        -- propio strumTime se acerca, vía la fórmula de updateTankman().
        -- 16% de probabilidad por nota, igual que FlxG.random.bool(16) real.
        for _, note in ipairs(loadPicospeakerNotes()) do
            if love.math.random() < 0.16 then
                local k = newTankman(note.dir < 2)
                k.strumTime = note.time
                table.insert(killedTankmen, k)
            end
        end

        if girlfriend then girlfriend:animate("shoot1-loop", true) end
        -- Este M.load() corre ANTES de que week7.lua haga initUI() ->
        -- applyChartMeta() -> psychCharacters.loadInto("girlfriend",
        -- "pico-speaker"), que recarga a girlfriend desde cero y pisa esto
        -- con su primera animación declarada en el JSON ("shoot1", sin
        -- loop). En modo historia stressIntro() ya lo vuelve a poner
        -- DESPUÉS de ese pisado -- esto es la misma red de seguridad para
        -- freeplay (sin cutscene de por medio), con un delay chico para
        -- asegurarse de correr después del pisado.
        Timer.after(0.05, function()
            if girlfriend then girlfriend:animate("shoot1-loop", true) end
        end)
    end

    lastBeatNum = -1

    psychStages.apply("tank")
end

function M.update(dt)
    if smokeLeft      then smokeLeft:update(dt)      end
    if smokeRight     then smokeRight:update(dt)     end
    if tankWatchtower then tankWatchtower:update(dt) end
    if tankRolling    then tankRolling:update(dt)    end
    for _, def in ipairs(foregroundSprites) do
        if def.sprite then def.sprite:update(dt) end
    end

    -- Tank.hx clouds: deriva lentamente a la derecha
    cloudsPsychX = cloudsPsychX + cloudsVel * dt
    if clouds then clouds.x = cloudsPsychX + 1037.5 end

    -- BackgroundTank.hx: órbita elíptica + rotación continua
    if tankRolling then
        tankAngle = tankAngle + tankSpeed * dt
        local rad = math.rad(tankAngle + 180)
        local psychX = 400 + 1500 * math.cos(rad)
        local psychY = 1300 + 1100 * math.sin(rad)
        tankRolling.x = psychX + 159
        tankRolling.y = psychY + 164
        tankRolling.orientation = math.rad(tankAngle - 90 + 15)
    end

    -- cutsceneActive: este bloque usa musicTime crudo (picoQueue contra
    -- musicTimeMs, posición de los tankmen vía musicTimeMs-strumTime) --
    -- durante la cutscene, musicTime queda CONGELADO (_G.cutscenePause,
    -- ver states/weeks.lua:update()) en el mismo valor por los 35.5s que
    -- dura stressIntro. Sin esta guarda, picoQueue iba consumiendo/
    -- saltándose eventos contra ese tiempo congelado (así que al arrancar
    -- la canción real ya estaban gastados -- "pico no dispara más") y la
    -- posición de cada tankman se recalculaba al MISMO valor congelado
    -- cuadro a cuadro -- visualmente plantados ("congelados") hasta que la
    -- cutscene termina y musicTime vuelve a avanzar de verdad.
    if songNum == 3 and not cutsceneActive then
        if not (countingDown or graphics.isFading()) then
            updatePicoQueue(musicTime)
        end

        for i = #killedTankmen, 1, -1 do
            local k = killedTankmen[i]
            k:update(dt)
            if updateTankman(k, musicTime) then
                table.remove(killedTankmen, i)
            end
        end
    end

    if cutsceneActive then
        -- Persigue camFollow cuadro a cuadro (ver comentario completo
        -- junto a la declaración de camFollow, arriba) -- reemplaza los
        -- tweens directos de cam.x/y que usaba antes este archivo.
        updateCutsceneCamFollow(dt)

        -- musicTime está congelado (_G.cutscenePause) -- usar dt real para
        -- seguir bailando al ritmo del bpm actual durante la cutscene.
        cutsceneBeatAccum = cutsceneBeatAccum + dt
        local beatLen = 60 / (bpm or 100)
        if cutsceneBeatAccum >= beatLen then
            cutsceneBeatAccum = cutsceneBeatAccum - beatLen
            cutsceneBeatCount = cutsceneBeatCount + 1
            -- Torre/tanques de fondo: cada 2 beats (decisión explícita: en
            -- Psych real Tank.hx los anima en cada beatHit() sin filtro,
            -- pero acá se fuerza igual a los personajes principales para
            -- que ambos queden sincronizados visualmente).
            if cutsceneBeatCount % 2 == 0 then
                if tankWatchtower then tankWatchtower:animate("watchtower gradient color", false) end
                for _, def in ipairs(foregroundSprites) do
                    if def.sprite then def.sprite:animate(def.anim, false) end
                end
            end
            -- bf/gf/enemy: weeks:triggerDanceBeat() ya filtra adentro, por
            -- personaje, según si cada uno tiene danceLeft/danceRight --
            -- se llama UNA VEZ POR BEAT, sin ningún divisor acá.
            weeks:triggerDanceBeat()
        end
    elseif bpm and absMusicTime then
        -- musicTime (con signo), no absMusicTime -- ver nota en limo/stage.lua.
        local curBeat = math.floor(musicTime * bpm / 60000)
        if curBeat > (lastBeatNum or -1) then
            lastBeatNum = curBeat
            -- Torre/tanques de fondo: cada 2 beats (misma decisión que en
            -- la cutscene, ver arriba).
            if curBeat % 2 == 0 then
                if tankWatchtower then tankWatchtower:animate("watchtower gradient color", false) end
                for _, def in ipairs(foregroundSprites) do
                    if def.sprite then def.sprite:animate(def.anim, false) end
                end
            end
        end
    end

    if cutsceneActive then
        cutsceneElapsedTime = cutsceneElapsedTime + dt

        if tankmanCutscene then tankmanCutscene:update(dt) end
        if picoCutscene then picoCutscene:update(dt) end
        if boyfriendCutscene then boyfriendCutscene:update(dt) end
        -- weeks:update(dt) está congelado por completo (_G.cutscenePause),
        -- así que el avance de frame de animación de estos 3 personajes
        -- (que normalmente pasa ahí) tampoco corre -- sin esto,
        -- triggerDanceBeat()/playAnim de la cutscene dejaban la
        -- animación arrancada pero CONGELADA en el primer frame.
        if girlfriend then girlfriend:update(dt) end
        if enemy then enemy:update(dt) end
        if boyfriend then boyfriend:update(dt) end

        -- CutsceneHandler.hx update(): mantener "accept" (confirm acá)
        -- rellena holdingTime a razón de tiempo real; soltarlo antes de
        -- completar lo hace decaer con un lerp hacia -0.1 (NO un reset
        -- instantáneo a 0) -- "elapsed*3" como ratio del lerp es el mismo
        -- patrón que camZoomBump/beatPulse en weeks.lua, solo que con k=3
        -- en vez de 3.125. _canSkip siempre es true en Tank.hx (nunca se
        -- crean estas cutscenes con canSkip=false) y solo arranca a
        -- chequear pasados los primeros 0.1s.
        if cutsceneElapsedTime > 0.1 then
            if input:down("confirm") then
                cutsceneHoldingTime = math.max(0, math.min(SKIP_TIME_TO_SKIP, cutsceneHoldingTime + dt))
            elseif cutsceneHoldingTime > 0 then
                local ratio = math.max(0, math.min(1, dt * 3))
                cutsceneHoldingTime = math.max(0, cutsceneHoldingTime + (-0.1 - cutsceneHoldingTime) * ratio)
            end
        end

        if cutsceneHoldingTime >= SKIP_TIME_TO_SKIP then
            skipCutscene()
        end
    end
end

-- CutsceneHandler.hx updateSkipAlpha(): dial blanco relleno como pie chart
-- (FlxPieDial), esquina inferior derecha, en espacio de PANTALLA fijo (sin
-- cámara/zoom -- por eso se dibuja FUERA de pushParallax, igual que
-- camHUD en Psych). amount y alpha replican las fórmulas reales:
--   amount = min(1, max(0, (holdingTime/_timeToSkip) * 1.025))
--   alpha  = remapToRange(amount, 0.025, 1, 0, 1)
-- alpha sale negativo (invisible) con holdingTime=0, así que no hace
-- falta un chequeo aparte para "no dibujar nada" -- love.graphics.setColor
-- con alpha<0 simplemente no dibuja nada visible.
local function drawSkipDial()
    local amount = math.min(1, math.max(0, (cutsceneHoldingTime / SKIP_TIME_TO_SKIP) * 1.025))
    local alpha  = (amount - 0.025) / (1 - 0.025)
    if alpha <= 0 then return end

    local w, h = graphics.getWidth(), graphics.getHeight()
    local cx = w - (SKIP_DIAL_RADIUS * 2 + 80) + SKIP_DIAL_RADIUS
    local cy = h - (SKIP_DIAL_RADIUS * 2 + 72) + SKIP_DIAL_RADIUS

    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.circle("line", cx, cy, SKIP_DIAL_RADIUS)
    if amount > 0 then
        local startAngle = -math.pi / 2
        love.graphics.arc("fill", cx, cy, SKIP_DIAL_RADIUS - 2, startAngle, startAngle + amount * 2 * math.pi)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function M.draw()
    -- Fondos lejanos
    graphics.pushParallax(0)
        sky:draw()
    love.graphics.pop()

    graphics.pushParallax(0.1)
        clouds:draw()
    love.graphics.pop()

    graphics.pushParallax(0.2)
        mountains:draw()
    love.graphics.pop()

    graphics.pushParallax(0.3)
        buildings:draw()
    love.graphics.pop()

    graphics.pushParallax(0.35)
        ruins:draw()
    love.graphics.pop()

    -- Humo + torre de vigilancia, scrollFactor 0.4-0.5
    graphics.pushParallax(0.4)
        if smokeLeft  then smokeLeft:draw()  end
        if smokeRight then smokeRight:draw() end
    love.graphics.pop()
    graphics.pushParallax(0.5)
        if tankWatchtower then tankWatchtower:draw() end
    love.graphics.pop()

    -- BackgroundTank.hx: tankRolling tiene su propio scrollFactor=(0.5,0.5),
    -- distinto del suelo/personajes (estaba mal agrupado con sf=1)
    graphics.pushParallax(0.5)
        if tankRolling then tankRolling:draw() end
    love.graphics.pop()

    -- Suelo: scrollFactor 1, DETRÁS de los personajes
    graphics.pushParallax(1)
        ground:draw()
        -- cutsceneActive: updateTankman() (la única que fija k.visible/k.x/
        -- k.y según strumTime real) está pausada durante la cutscene (ver
        -- M.update()) -- sin esto, cada tankman se dibuja en su posición
        -- y visibilidad por DEFECTO (todos visibles, todos en el mismo
        -- punto) durante toda la cutscene -- "apilados y tiesos".
        if not cutsceneActive then
            for _, k in ipairs(killedTankmen) do k:draw() end
        end
    love.graphics.pop()

    -- Personajes (+ cutscenes de intro DETRÁS de su contraparte real --
    -- addBehindGF/addBehindDad/addBehindBF de Tank.hx). graphics.lua NO lee
    -- .alpha por su cuenta (confirmado: ningún stage del juego envuelve a
    -- girlfriend/enemy/boyfriend en setColor) -- por eso, SOLO durante la
    -- cutscene, hace falta envolver el :draw() en setColor para que
    -- enemy/girlfriend/boyfriend.alpha=0.00001 (puesto en prepareCutscene)
    -- realmente se vea -- fuera de la cutscene, el comportamiento de
    -- siempre (sin tocar) sigue idéntico.
    graphics.pushParallax(1)
        if cutsceneActive and picoCutscene and picoCutscene.visible then picoCutscene:draw() end
        if girlfriend then
            if cutsceneActive then graphics.setColor(1, 1, 1, girlfriend.alpha or 1) end
            girlfriend:draw()
            if cutsceneActive then graphics.setColor(1, 1, 1) end
        end
        if cutsceneActive and tankmanCutscene then tankmanCutscene:draw() end
        if enemy then
            if cutsceneActive then graphics.setColor(1, 1, 1, enemy.alpha or 1) end
            enemy:draw()
            if cutsceneActive then graphics.setColor(1, 1, 1) end
        end
        if cutsceneActive and boyfriendCutscene and boyfriendCutscene.visible then boyfriendCutscene:draw() end
        if boyfriend then
            if cutsceneActive then graphics.setColor(1, 1, 1, boyfriend.alpha or 1) end
            boyfriend:draw()
            if cutsceneActive then graphics.setColor(1, 1, 1) end
        end
        weeks:drawRating()
    love.graphics.pop()

    -- Tanques de primer plano, cada uno con su propio scrollFactor
    for _, def in ipairs(foregroundSprites) do
        if def.sprite then
            graphics.pushParallax(def.sfX, def.sfY)
                def.sprite:draw()
            love.graphics.pop()
        end
    end

    -- Dial de skip: espacio de pantalla fijo, encima de todo lo demás
    -- (igual que camHUD real) -- el HUD normal ya está invisible durante
    -- la cutscene (weeks:getGuiAlphaObj().value=0 en prepareCutscene), así
    -- que no hay conflicto visual aunque esto se dibuje antes de
    -- weeks:drawUI() (llamada después, desde week7.lua).
    if cutsceneActive then
        drawSkipDial()
    end
end

function M.leave()
    sky = nil; clouds = nil; mountains = nil; buildings = nil
    ruins = nil; ground = nil
    smokeLeft = nil; smokeRight = nil; tankWatchtower = nil; tankRolling = nil
    for _, def in ipairs(foregroundSprites) do def.sprite = nil end
    foregroundSprites = {}

    if currentLoopTimer then Timer.cancel(currentLoopTimer); currentLoopTimer = nil end
    killedTankmen = {}
    picoQueue     = {}

    if cutsceneActive then
        clearCutsceneTimers()
        stopCutsceneSounds()
        _G.disableAutoCam = false
        _G.cutscenePause = false
        weeks:getGuiAlphaObj().value = 1
        cutsceneActive = false
        cutsceneOnComplete = nil
        cutsceneSkipFn = nil
    end
    tankmanCutscene = nil
    picoCutscene = nil
    boyfriendCutscene = nil
end

return M
