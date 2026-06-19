-- Stage: "military" (Week 7 - Tankman) — puerto 1:1 de states/stages/Tank.hx
--
-- NOTA: las cutscenes de introducción de Story Mode (ughIntro/gunsIntro/
-- stressIntro) usan FlxAnimate (atlas Adobe Animate), un sistema que no
-- existe en FNF Rewritten -- no están portadas. El resto (fondos, tanques
-- de fondo/frente, tankman corriendo/muriendo en Stress) sí está 1:1.

local M = {}

local psychStages = require("charts.psych.stages")
local atlas = require("charts.psych.atlas")
local json = require("lib.json")

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
    tankmanFrames = atlas.loadSparrow(pngPath:gsub("%.png$", ".xml"))
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
    smokeLeft:animate("anim", true)

    smokeRight = love.filesystem.load("sprites/week7/smokeRight.lua")()
    smokeRight.x, smokeRight.y = 1349, 322  -- Psych (1100,-100), sf=(0.4,0.4)
    smokeRight:animate("anim", true)

    tankWatchtower = love.filesystem.load("sprites/week7/tankWatchtower.lua")()
    tankWatchtower.x, tankWatchtower.y = 284, 388  -- Psych (100,50), sf=(0.5,0.5)
    tankWatchtower:animate("anim", false)

    tankRolling = love.filesystem.load("sprites/week7/tankRolling.lua")()
    tankRolling:animate("anim", true)
    tankAngle = love.math.random(-90, 45)
    tankSpeed = love.math.random() * 2 + 5  -- random.float(5,7)

    -- Tank.hx createPost(): foregroundSprites, cada uno con su propio scrollFactor
    foregroundSprites = {
        {file = "sprites/week7/tank0.lua", x = -346, y = 862,  sfX = 1.7, sfY = 1.5},
        {file = "sprites/week7/tank1.lua", x = -64,  y = 802,  sfX = 2,   sfY = 0.2},
        {file = "sprites/week7/tank2.lua", x = 595,  y = 1084, sfX = 1.5, sfY = 1.5},
        {file = "sprites/week7/tank4.lua", x = 1500, y = 1054, sfX = 1.5, sfY = 1.5},
        {file = "sprites/week7/tank5.lua", x = 1777, y = 912,  sfX = 1.5, sfY = 1.5},
        {file = "sprites/week7/tank3.lua", x = 1595, y = 1256, sfX = 3.5, sfY = 2.5},
    }
    for _, def in ipairs(foregroundSprites) do
        local ok, spr = pcall(function() return love.filesystem.load(def.file)() end)
        if ok and spr then
            spr.x, spr.y = def.x, def.y
            spr:animate("anim", false)
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

    if songNum == 3 then
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

    if bpm and absMusicTime then
        -- musicTime (con signo), no absMusicTime -- ver nota en limo/stage.lua.
        local curBeat = math.floor(musicTime * bpm / 60000)
        if curBeat > (lastBeatNum or -1) then
            lastBeatNum = curBeat
            -- Tank.hx everyoneDance(): re-dispara la animación (sin loop) en
            -- cada beat -- en Flixel, play(name, Force=false) SÍ reinicia si
            -- la animación anterior ya terminó (no es un "play una sola vez").
            if tankWatchtower then tankWatchtower:animate("anim", false) end
            for _, def in ipairs(foregroundSprites) do
                if def.sprite then def.sprite:animate("anim", false) end
            end
        end
    end
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
        for _, k in ipairs(killedTankmen) do k:draw() end
    love.graphics.pop()

    -- Personajes
    graphics.pushParallax(1)
        if girlfriend then girlfriend:draw() end
        if enemy      then enemy:draw()      end
        if boyfriend  then boyfriend:draw()  end
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
end

return M
