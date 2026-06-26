-- Stage: "limo" (Week 4 - Mommy Must Murder) — puerto 1:1 de states/stages/Limo.hx
--
-- NOTA: la secuencia de gore "Kill Henchmen" (poste metálico, sangre,
-- cuerpos de henchmen) todavía no está portada -- requiere varios sprites
-- y un sistema de partículas que no existen aún en FNF Rewritten. El resto
-- (fondo, limo, bailarines, auto que pasa) sí está 1:1. El evento se
-- registra como no-op para no generar warnings si algún chart lo dispara.

local M = {}

local psychStages = require("charts.psych.stages")
local psychEvents = require("charts.psych.events")

local sunset, bgLimo, limo
local dancers = {}
local danceDir = false

local fastCar, fastCarSounds
local fastCarPsychX, fastCarVelocity
local fastCarCanDrive = true
local fastCarTimer

local lastBeatNum

psychEvents.registerHandler("Kill Henchmen", function() end)

local function resetFastCar()
    fastCarPsychX = -12600
    fastCarVelocity = 0
    if fastCar then
        fastCar.x = fastCarPsychX + 640
        fastCar.y = love.math.random(140, 250) + 360
    end
    fastCarCanDrive = true
end

local function fastCarDrive()
    audio.playSound(fastCarSounds[love.math.random(2)])
    fastCarVelocity = love.math.random(30600, 39600)
    fastCarCanDrive = false
    if fastCarTimer then Timer.cancel(fastCarTimer) end
    fastCarTimer = Timer.after(2, function()
        resetFastCar()
        fastCarTimer = nil
    end)
end

function M.load()
    sunset = graphics.newImage(love.graphics.newImage(graphics.imagePath("week4/sunset")))
    sunset.x, sunset.y = 864, 607  -- Psych (-120,-50), sf=(0.1,0.1)

    bgLimo = love.filesystem.load("sprites/week4/bg-limo.lua")()
    bgLimo.x, bgLimo.y = 940, 667  -- Psych (-150,480), sf=(0.4,0.4)
    bgLimo:animate("background limo pink", true)

    limo = love.filesystem.load("sprites/week4/limo.lua")()
    limo.x, limo.y = 904, 873  -- Psych (-120,550), sf=(1,1)
    limo:animate("Limo stage", true)

    -- Limo.hx: 5 bailarines, espaciados 370px, x = 370*i + 320 + bgLimo.x(Psych=-150)
    dancers = {}
    local dancerXs = {428, 798, 1168, 1538, 1908}  -- ya convertidas
    for i = 1, 5 do
        local dancer = love.filesystem.load("sprites/week4/limo-dancer.lua")()
        dancer.x, dancer.y = dancerXs[i], 270  -- Psych y = bgLimo.y(480) - 400 = 80
        dancer:animate("danceLeft", false)
        dancers[i] = dancer
    end
    danceDir = false

    fastCar = graphics.newImage(love.graphics.newImage(graphics.imagePath("week4/fast-car")))
    fastCarSounds = {
        love.audio.newSource("sounds/week4/carPass0.ogg", "static"),
        love.audio.newSource("sounds/week4/carPass1.ogg", "static"),
    }
    resetFastCar()

    lastBeatNum = -1

    psychStages.apply("limo")
end

function M.update(dt)
    if bgLimo     then bgLimo:update(dt)     end
    if limo       then limo:update(dt)       end
    for _, dancer in ipairs(dancers) do dancer:update(dt) end

    -- Limo.hx fastCarDrive(): avanza a fastCarVelocity px/s, se resetea tras 2s (Timer)
    if not fastCarCanDrive and fastCar then
        fastCarPsychX = fastCarPsychX + fastCarVelocity * dt
        fastCar.x = fastCarPsychX + 640
    end

    if bpm and absMusicTime then
        -- musicTime (con signo), NO absMusicTime: durante el countdown
        -- musicTime arranca negativo y cuenta hacia 0 -- abs() de eso cuenta
        -- HACIA ATRÁS (de varios beats a 0), inflando lastBeatNum antes de
        -- que la canción real empiece, y retrasando el primer beatHit real
        -- hasta que el conteo real "alcance" ese valor fantasma.
        local curBeat = math.floor(musicTime * bpm / 60000)
        if curBeat > (lastBeatNum or -1) then
            lastBeatNum = curBeat

            danceDir = not danceDir
            local anim = danceDir and "danceRight" or "danceLeft"
            for _, dancer in ipairs(dancers) do
                dancer:animate(anim, false)
            end

            if love.math.random() < 0.10 and fastCarCanDrive then
                fastCarDrive()
            end
        end
    end
end

function M.draw()
    -- Sunset scrollFactor 0.1
    graphics.pushParallax(0.1)
        sunset:draw()
    love.graphics.pop()

    -- bgLimo + bailarines scrollFactor 0.4
    graphics.pushParallax(0.4)
        bgLimo:draw()
        for _, dancer in ipairs(dancers) do dancer:draw() end
    love.graphics.pop()

    -- Auto que pasa: scrollFactor 1, detrás de GF (addBehindGF en Limo.hx)
    graphics.pushParallax(1)
        if fastCar then fastCar:draw() end
        if girlfriend then girlfriend:draw() end
        limo:draw()
        if enemy     then enemy:draw()      end
        if boyfriend then boyfriend:draw()  end
        weeks:drawRating()
    love.graphics.pop()
end

function M.leave()
    if fastCarTimer then Timer.cancel(fastCarTimer); fastCarTimer = nil end
    sunset = nil; bgLimo = nil; limo = nil; dancers = {}
    fastCar = nil; fastCarSounds = nil
end

return M
