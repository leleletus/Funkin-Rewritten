-- Stage: "philly" (Week 3 - Pico) — puerto 1:1 de states/stages/Philly.hx
--
-- NOTA: el efecto "Philly Glow" (PhillyGlowGradient/PhillyGlowParticle,
-- usado en Blammed) todavía no está portado -- requiere un sistema de
-- partículas propio que no existe en FNF Rewritten. Lo demás (fondos,
-- tren, ventanas parpadeantes) sí está 1:1.

local M = {}

local psychStages = require("charts.psych.stages")

local sky, city, window, behindTrain, street, train
local trainSound

-- Philly.hx: phillyLightsColors (ARGB Flixel -> RGB normalizado 0-1)
local WINDOW_COLORS = {
    {49/255, 162/255, 253/255},  -- 0xFF31A2FD
    {49/255, 253/255, 140/255},  -- 0xFF31FD8C
    {251/255, 51/255, 245/255},  -- 0xFFFB33F5
    {253/255, 69/255, 49/255},   -- 0xFFFD4531
    {251/255, 166/255, 51/255},  -- 0xFFFBA633
}
local curLight = 0
local windowColor = {1, 1, 1}
local windowAlpha = 0

-- PhillyTrain.hx (estado del tren, en coordenadas Psych top-left + medio ancho)
-- train.png es 4096x512 -- TRAIN_HALF_W/H son su mitad exacta (conversión
-- Psych top-left -> Rewritten centro, sin trim al ser una imagen estática).
local TRAIN_HALF_W, TRAIN_HALF_H = 2048, 256
local TRAIN_PSYCH_Y = 360  -- PhillyTrain(2000, 360) en Philly.hx
local trainPsychX
local trainMoving, trainFinishing, trainStarted = false, false, false
local trainFrameTiming = 0
local trainCars = 8
local trainCooldown = 0

local lastBeatNum

local function setTrainX(psychX)
    trainPsychX = psychX
    if train then
        train.x = psychX + TRAIN_HALF_W
        train.y = TRAIN_PSYCH_Y + TRAIN_HALF_H
    end
end

local function trainStart()
    trainMoving = true
    if trainSound and not trainSound:isPlaying() then
        trainSound:play()
    end
end

local function trainRestart()
    if girlfriend then girlfriend:animate("hairFall", false) end
    setTrainX(1280 + 200)  -- FlxG.width + 200, en coords Psych (1280x720)
    trainMoving = false
    trainCars = 8
    trainFinishing = false
    trainStarted = false
end

function M.load()
    -- Philly.hx create() -- posiciones Psych (top-left) -> Rewritten ya
    -- convertidas (centro del bbox); todas estas imágenes son estáticas (sin
    -- atlas), igual que graphics.newImage ya calcula con width/2.
    sky         = graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/sky")))
    city        = graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/city")))
    window      = graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/window")))
    behindTrain = graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/behindTrain")))
    street      = graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/street")))
    train       = graphics.newImage(love.graphics.newImage(graphics.imagePath("week3/train")))

    sky.x, sky.y = 765, 478  -- Psych (-100,0), sin escala

    -- city.setGraphicSize(width*0.85) -- escala uniforme 0.85
    city.sizeX, city.sizeY = 0.85, 0.85
    city.x, city.y = 725, 406  -- Psych (-10,0) + escala 0.85

    -- window = misma posición y escala que city
    window.sizeX, window.sizeY = 0.85, 0.85
    window.x, window.y = 725, 406
    window.visible = true

    behindTrain.x, behindTrain.y = 825, 528  -- Psych (-40,50), sf=(1,1) -- sin parallax

    street.x, street.y = 825, 528  -- Psych (-40,50), sf=(1,1)

    trainSound = love.audio.newSource("sounds/week3/train.ogg", "static")

    curLight = 0
    windowColor = {1, 1, 1}
    windowAlpha = 0
    lastBeatNum = -1

    trainMoving, trainFinishing, trainStarted = false, false, false
    trainFrameTiming = 0
    trainCars = 8
    trainCooldown = 0
    setTrainX(2000)  -- PhillyTrain(2000, 360), Psych

    psychStages.apply("philly")
end

function M.update(dt)
    -- Philly.hx update(): la ventana se apaga gradualmente entre flashes
    if bpm and bpm > 0 then
        windowAlpha = math.max(0, windowAlpha - (60000 / bpm / 1000) * dt * 1.5)
    end

    -- Tren: avanza a 24fps fijos mientras se mueve
    if trainMoving then
        trainFrameTiming = trainFrameTiming + dt
        if trainFrameTiming >= 1 / 24 then
            if trainSound and trainSound:tell() * 1000 >= 4700 then
                -- hairBlow es loop: basta dispararla una vez (no hace falta
                -- re-asegurarla cada frame). Lo que sí hacía falta es que el
                -- baile normal por beat no la interrumpa mientras sigue
                -- activa -- ese guard ya está en states/weeks.lua.
                if not trainStarted and girlfriend then
                    girlfriend:animate("hairBlow", false)
                end
                trainStarted = true
            end

            if trainStarted then
                local nx = trainPsychX - 400
                if nx < -2000 and not trainFinishing then
                    nx = -1150
                    trainCars = trainCars - 1
                    if trainCars <= 0 then trainFinishing = true end
                end
                setTrainX(nx)

                if trainPsychX < -4000 and trainFinishing then
                    trainRestart()
                end
            end

            trainFrameTiming = 0
        end
    end

    -- Beat hit: tren (chance de arrancar) + ventana (cambia de color cada 4 beats)
    if bpm and absMusicTime then
        -- musicTime (con signo), no absMusicTime -- ver nota en limo/stage.lua.
        local curBeat = math.floor(musicTime * bpm / 60000)
        if curBeat > (lastBeatNum or -1) then
            lastBeatNum = curBeat

            if not trainMoving then trainCooldown = trainCooldown + 1 end
            if curBeat % 8 == 4 and love.math.random() < 0.30 and not trainMoving and trainCooldown > 8 then
                trainCooldown = love.math.random(-4, 0)
                trainStart()
            end

            if curBeat % 4 == 0 then
                local newLight = love.math.random(1, #WINDOW_COLORS)
                if newLight == curLight then
                    newLight = (newLight % #WINDOW_COLORS) + 1
                end
                curLight = newLight
                windowColor = WINDOW_COLORS[curLight]
                windowAlpha = 1
            end
        end
    end
end

function M.draw()
    -- Sky scrollFactor 0.1
    graphics.pushParallax(0.1)
        sky:draw()
    love.graphics.pop()

    -- City + window scrollFactor 0.3
    graphics.pushParallax(0.3)
        city:draw()
        love.graphics.setColor(windowColor[1], windowColor[2], windowColor[3], windowAlpha)
        window:draw()
        love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()

    -- behindTrain + tren + calle: scrollFactor 1, DETRÁS de los personajes
    -- (la calle es el suelo donde están parados, no debe cubrirlos)
    graphics.pushParallax(1)
        behindTrain:draw()
        -- Philly.hx: el tren se agrega siempre (no condicionalmente) -- al no
        -- estar moviéndose queda fuera de pantalla por posición (x=2000
        -- Psych), no por una bandera de visibilidad explícita.
        train:draw()
        street:draw()
    love.graphics.pop()

    -- Personajes
    graphics.pushParallax(1)
        if girlfriend then girlfriend:draw() end
        if enemy      then enemy:draw()      end
        if boyfriend  then boyfriend:draw()  end
        weeks:drawRating()
    love.graphics.pop()
end

function M.leave()
    sky = nil; city = nil; window = nil; behindTrain = nil; street = nil; train = nil
    trainSound = nil
end

return M
