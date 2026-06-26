-- Stage: "mall" / "mallEvil" (Week 5 - Red Snow) — puerto 1:1 de
-- states/stages/Mall.hx y MallEvil.hx
-- M.load(songNum): canciones 1-2 = mall normal, canción 3 = mallEvil (winter-horrorland)

local M = {}

local psychStages = require("charts.psych.stages")
local psychEvents = require("charts.psych.events")
local stagedata = require("charts.psych.stagedata")

local walls, escalator, tree, snow
local topBop, bottomBop, santa

local evilBG, evilTree, evilSnow

local isEvil = false
local lastBeatNum

local transitionTimer, transitionAlpha = nil, 0

-- Mall.hx eventCalled "Hey!": además de la reacción genérica bf/gf (igual
-- que el handler por defecto), la multitud de fondo también reacciona
-- salvo que el "Hey!" sea específicamente para boyfriend.
psychEvents.registerHandler("Hey!", function(ev)
    local who = tostring(ev.value1 or ""):lower():match("^%s*(.-)%s*$")
    local value = 2
    if who == "bf" or who == "boyfriend" or who == "0" then
        value = 0
    elseif who == "gf" or who == "girlfriend" or who == "1" then
        value = 1
    end

    if value ~= 0 and girlfriend and girlfriend.anims and girlfriend.anims["cheer"] then
        weeks:safeAnimate(girlfriend, "cheer", false, 1)
    end
    if value ~= 1 then
        weeks:safeAnimate(boyfriend, "hey", false, 3)
    end

    if value ~= 0 and bottomBop and bottomBop:getAnims()["hey"] then
        bottomBop:animate("hey", false)
    end
end)

function M.load(songNum)
    isEvil = (songNum == 3)

    if isEvil then
        evilBG   = graphics.newImage(love.graphics.newImage(graphics.imagePath("week5/evilBG")))
        evilBG.sizeX, evilBG.sizeY = 0.8, 0.8
        evilBG.x, evilBG.y = 650, 145  -- Psych (-400,-500), sf=(0.2,0.2)

        evilTree = graphics.newImage(love.graphics.newImage(graphics.imagePath("week5/evilTree")))
        evilTree.x, evilTree.y = 609, 254  -- Psych (300,-300), sf=(0.2,0.2)

        evilSnow = graphics.newImage(love.graphics.newImage(graphics.imagePath("week5/evilSnow")))
        evilSnow.x, evilSnow.y = 1112, 831  -- Psych (-200,700), sf=(1,1)
    else
        walls = graphics.newImage(love.graphics.newImage(graphics.imagePath("week5/bgWalls")))
        walls.sizeX, walls.sizeY = 0.8, 0.8
        walls.x, walls.y = 507, 210  -- Psych (-1000,-500), sf=(0.2,0.2)

        escalator = graphics.newImage(love.graphics.newImage(graphics.imagePath("week5/bgEscalator")))
        escalator.sizeX, escalator.sizeY = 0.9, 0.9
        escalator.x, escalator.y = 476, 199  -- Psych (-1100,-600), sf=(0.3,0.3)

        tree = graphics.newImage(love.graphics.newImage(graphics.imagePath("week5/christmasTree")))
        tree.x, tree.y = 701, 259  -- Psych (370,-250), sf=(0.4,0.4)

        snow = graphics.newImage(love.graphics.newImage(graphics.imagePath("week5/fgSnow")))
        snow.x, snow.y = 892, 826  -- Psych (-600,700), sf=(1,1)

        -- Posición y escala ya resueltas adentro de cada archivo (ahora
        -- usan charts/psych/bgsprite.lua con las coordenadas reales de
        -- Mall.hx/MallCrowd.hx -- ver comentarios en sprites/week5/*.lua).
        topBop    = love.filesystem.load("sprites/week5/top-bop.lua")()
        bottomBop = love.filesystem.load("sprites/week5/bottom-bop.lua")()
        santa     = love.filesystem.load("sprites/week5/santa.lua")()
    end

    lastBeatNum = -1

    psychStages.apply(isEvil and "mallEvil" or "mall")
end

-- MallEvil.hx winterHorrorlandCutscene(): zoom a 1.5 enfocando un punto fijo
-- (FlxPoint(400,-2050), deliberadamente "raro" en Psych -- es el punto de la
-- transición dramática, no un bug), fundido a negro de 0.7s, espera 0.8s,
-- luego zoom de vuelta a defaultZoom en 2.5s y recién ahí dispara onComplete
-- (arranca el countdown). Antes esto solo hacía el fundido a negro sin mover
-- la cámara -- por eso "solo sonaba el sonido".
function M.startEvilTransition(onComplete)
    transitionAlpha = 1
    audio.playSound(love.audio.newSource("sounds/week5/lights-on.ogg", "static"))

    if transitionTimer then Timer.cancel(transitionTimer); transitionTimer = nil end

    -- MallEvil.hx pone inCutscene=true para que el seguimiento normal de
    -- cámara (moveCameraSection) no compita con esta animación -- en
    -- Rewritten el equivalente es _G.disableAutoCam (ver states/weeks.lua,
    -- ~línea 1671), que existía pero nunca se activaba acá: el tween de
    -- seguimiento normal (1.25s, cada frame) sobreescribía cam.x/y antes de
    -- que el foco fijo durara los 2.5s esperados.
    _G.disableAutoCam = true

    -- focusOn(400,-2050) en términos de cam.x/y (cam = -camFollow + CONST,
    -- CONST_X=0, CONST_Y=-25, igual fórmula que states/weeks.lua):
    cam.x, cam.y = -400, 2050 - 25
    cam.sizeX, cam.sizeY = 1.5, 1.5

    local mallEvilZoom = (stagedata.load("mallEvil") or {}).defaultZoom or 1.05

    transitionTimer = Timer.after(0.8, function()
        transitionTimer = nil
        transitionTimer = Timer.tween(2.5, cam, {sizeX = mallEvilZoom, sizeY = mallEvilZoom}, "in-out-quad", function()
            transitionTimer = nil
            _G.disableAutoCam = false
            if onComplete then onComplete() end
        end)
    end)
end

function M.update(dt)
    if not isEvil then
        if topBop    then topBop:update(dt)    end
        if bottomBop then bottomBop:update(dt) end
        if santa     then santa:update(dt)     end
    end

    if transitionAlpha > 0 then
        transitionAlpha = math.max(0, transitionAlpha - dt / 0.7)
    end

    if not isEvil and bpm and absMusicTime then
        -- musicTime (con signo), no absMusicTime -- ver nota en limo/stage.lua.
        local curBeat = math.floor(musicTime * bpm / 60000)
        if curBeat > (lastBeatNum or -1) then
            lastBeatNum = curBeat
            -- Nombres reales de Mall.hx/MallCrowd.hx (ya no el "anim"
            -- genérico de los sprites viejos hardcodeados) -- igual que
            -- dance() en BGSprite.hx: no reinterrumpir "hey" si está sonando.
            if topBop then topBop:animate("Upper Crowd Bob", false) end
            if bottomBop and (bottomBop:getAnimName() ~= "hey" or not bottomBop:isAnimated()) then
                bottomBop:animate("Bottom Level Boppers Idle", false)
            end
            if santa then santa:animate("santa idle in fear", false) end
        end
    end
end

function M.draw()
    local w, h = graphics.getWidth() / 2, graphics.getHeight() / 2

    if isEvil then
        graphics.pushParallax(0.2)
            evilBG:draw()
            evilTree:draw()
        love.graphics.pop()

        -- evilSnow (sf=1) va DETRÁS de los personajes, es nieve en el suelo
        graphics.pushParallax(1)
            evilSnow:draw()
        love.graphics.pop()

        graphics.pushParallax(1)
            if girlfriend then girlfriend:draw() end
            if enemy      then enemy:draw()      end
            if boyfriend  then boyfriend:draw()  end
            weeks:drawRating()
        love.graphics.pop()
    else
        graphics.pushParallax(0.2)
            walls:draw()
        love.graphics.pop()
        graphics.pushParallax(0.33)
            if topBop then topBop:draw() end
        love.graphics.pop()
        graphics.pushParallax(0.3)
            escalator:draw()
        love.graphics.pop()
        graphics.pushParallax(0.4)
            tree:draw()
        love.graphics.pop()
        graphics.pushParallax(0.9)
            if bottomBop then bottomBop:draw() end
        love.graphics.pop()

        -- snow (sf=1) va DETRÁS de los personajes, es nieve en el suelo
        graphics.pushParallax(1)
            snow:draw()
        love.graphics.pop()

        graphics.pushParallax(1)
            if girlfriend then girlfriend:draw() end
            if santa then santa:draw() end
            if enemy     then enemy:draw()      end
            if boyfriend then boyfriend:draw()  end
            weeks:drawRating()
        love.graphics.pop()
    end

    if transitionAlpha > 0 then
        love.graphics.setColor(0, 0, 0, transitionAlpha)
        love.graphics.rectangle("fill", 0, 0, graphics.getWidth(), graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function M.leave()
    if transitionTimer then Timer.cancel(transitionTimer); transitionTimer = nil end
    _G.disableAutoCam = false
    walls = nil; escalator = nil; tree = nil; snow = nil
    topBop = nil; bottomBop = nil; santa = nil
    evilBG = nil; evilTree = nil; evilSnow = nil
end

return M
