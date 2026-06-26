-- Stage: "school" / "schoolEvil" (Week 6 - Hating Simulator) — puerto 1:1 de
-- states/stages/School.hx y SchoolEvil.hx
-- M.load(songNum): 1-2 = school normal, 3 = schoolEvil (Thorns)
--
-- NOTA: el diálogo de Senpai/Roses (DialogueBox) todavía no está portado.
-- El resto (fondos incl. weebTrees animado, PIXEL_ZOOM real=6, BG Ghouls,
-- pre-escena de Thorns) sí está 1:1.

local M = {}

local psychStages = require("charts.psych.stages")
local psychEvents = require("charts.psych.events")
local bgsprite = require("charts.psych.bgsprite")

local sky, school, street, treesBack, bgTrees, petals, freaks
local evilSchool, bgGhouls

local isEvil = false
local lastBeatNum
-- BackgroundGirls.hx: isPissed arranca en `true` PERO el constructor llama
-- swapDanceType() una vez antes de mostrarse, dejando el estado real inicial
-- en `false` ("BG girls group" / contentas) -- "dissuaded" solo llega vía el
-- evento "BG Freaks Expression" de cada chart (p.ej. Roses lo dispara a
-- t=-5999ms, justo al iniciar la canción).
local freaksPissed = false
local freaksDanceDir = false

-- daPixelZoom real de Psych Engine (PlayState.hx) = 6, NO 6.5
local PIXEL_ZOOM = 6

-- min inclusive, max EXCLUSIVO (igual semántica que CoolUtil.numberArray de
-- Psych: numberArray(max, min) = [min..max-1]).
local function range(minV, maxV)
    local t = {}
    for i = minV, maxV - 1 do table.insert(t, i) end
    return t
end

-- BackgroundGirls.hx swapDanceType(): danceLeft/danceRight no son animaciones
-- fijas -- apuntan a índices [0..13]/[15..29] dentro de la región "BG girls
-- group" (contenta) o "BG fangirls dissuaded" (enojada) del MISMO atlas
-- weeb/bgFreaks, según el humor actual. Replicado acá como 4 animaciones
-- fijas (las 2 combinaciones de dirección x las 2 de humor) en vez de
-- reconstruir animData en caliente -- mismo resultado visual.
local function freaksAnimDefs()
    return {
        { name = "danceLeft_happy",   prefix = "BG girls group",        indices = range(0, 14) },
        { name = "danceRight_happy",  prefix = "BG girls group",        indices = range(15, 30) },
        { name = "danceLeft_pissed",  prefix = "BG fangirls dissuaded", indices = range(0, 14) },
        { name = "danceRight_pissed", prefix = "BG fangirls dissuaded", indices = range(15, 30) },
    }
end

-- BackgroundGirls.hx dance(): alterna danceDir y reproduce danceLeft/
-- danceRight según el humor actual. Llamado en cada beat (School.hx:beatHit).
local function freaksDance()
    if not freaks then return end
    freaksDanceDir = not freaksDanceDir
    local dir  = freaksDanceDir and "danceRight" or "danceLeft"
    local mood = freaksPissed and "pissed" or "happy"
    local newName = dir .. "_" .. mood
    freaks:animate(newName, false)
end

-- BackgroundGirls.hx swapDanceType(): cambia de humor y redispara dance().
local function freaksSwapDanceType()
    freaksPissed = not freaksPissed
    freaksDance()
end

-- Pre-escena de Thorns (SchoolEvil.hx schoolIntro, simplificada sin DialogueBox)
local senpaiCrazy
local thornsActive = false
local thornsPhase = "frozen"
local thornsTimer = 0
local senpaiAlpha = 0
local fadeAlpha = 0
local fadeStarted = false

local function pixelImg(path)
    local img = love.graphics.newImage(graphics.imagePath(path))
    img:setFilter("nearest", "nearest")
    return graphics.newImage(img)
end

psychEvents.registerHandler("BG Freaks Expression", function()
    freaksSwapDanceType()
end)

-- SchoolEvil.hx: bgGhouls SOLO tiene una animación ("BG freaks glitch
-- instance"), sin loop. El evento la fuerza a reiniciar desde el frame 1 y
-- la hace visible; un finishCallback la oculta de nuevo al terminar -- no es
-- un baile por beat alternante (a diferencia de freaks), es un flash de
-- "glitch" de un solo disparo.
psychEvents.registerHandler("Trigger BG Ghouls", function()
    if bgGhouls then
        bgGhouls.visible = true
        bgGhouls:animate("BG freaks glitch instance", false, function()
            bgGhouls.visible = false
        end)
    end
end)

function M.load(songNum)
    isEvil = (songNum == 3)

    if isEvil then
        -- SchoolEvil.hx: `bg.scale.set(daPixelZoom,daPixelZoom)` SIN llamar
        -- updateHitbox() después -- a diferencia de los fondos de School.hx
        -- (que sí lo hacen), esto deja x/y ancladas al top-left SIN escalar
        -- en Flixel (el sprite solo se dibuja más grande desde ese punto, no
        -- se recentra). originScale=1 replica eso -- sin esto, evilSchool
        -- quedaba centrado ~1500px fuera de cualquier posición de cámara
        -- razonable, dejando el stage de Thorns completamente negro.
        -- scrollFactor real también es (0.8, 0.9) -- asimétrico, no (0.9,0.9).
        evilSchool = bgsprite.new("week6/animatedEvilSchool", 400, 200, {"background 2"}, true, PIXEL_ZOOM, 1)
        evilSchool:getSheet():setFilter("nearest", "nearest")

        bgGhouls = love.filesystem.load("sprites/week6/bgGhouls.lua")()
        bgGhouls.sizeX, bgGhouls.sizeY = PIXEL_ZOOM, PIXEL_ZOOM
        bgGhouls.x, bgGhouls.y = 1250, 478  -- Psych (-100,190), sf=(0.9,0.9)
        bgGhouls.visible = false
    else
        sky       = pixelImg("week6/weebSky")
        school    = pixelImg("week6/weebSchool")
        street    = pixelImg("week6/weebStreet")
        treesBack = pixelImg("week6/weebTreesBack")

        sky.sizeX,       sky.sizeY       = PIXEL_ZOOM, PIXEL_ZOOM
        school.sizeX,    school.sizeY    = PIXEL_ZOOM, PIXEL_ZOOM
        street.sizeX,    street.sizeY    = PIXEL_ZOOM, PIXEL_ZOOM
        treesBack.sizeX, treesBack.sizeY = PIXEL_ZOOM * 0.8, PIXEL_ZOOM * 0.8

        sky.x,    sky.y    = 930, 480  -- Psych (0,0), sf=(0.1,0.1)
        school.x, school.y = 730, 480  -- Psych (-200,0), sf=(0.6,0.9)
        street.x, street.y = 730, 480  -- Psych (-200,0), sf=(0.95,0.95)
        treesBack.x, treesBack.y = 714, 514  -- Psych (-30,130), sf=(0.9,0.9)

        -- School.hx bgTrees: capa animada de árboles de fondo (weeb/weebTrees,
        -- atlas formato "packer" -- ver charts/psych/atlas.lua). Psych:
        -- pos=(-580,-800), sf=(0.85,0.85), escala=(widShit*1.4)/512=5.1015625
        bgTrees = bgsprite.new("week6/weebTrees", -580, -800, {"trees_"}, true, 5.1015625)
        bgTrees:getSheet():setFilter("nearest", "nearest")

        petals = love.filesystem.load("sprites/week6/petals.lua")()
        petals.sizeX, petals.sizeY = PIXEL_ZOOM, PIXEL_ZOOM
        petals.x, petals.y = 730, 440  -- Psych (-200,-40), sf=(0.85,0.85)
        petals:animate("PETALS ALL", true)

        -- School.hx: bgGirls = new BackgroundGirls(-100, 190); sf=(0.9,0.9)
        freaks = bgsprite.new("week6/bgFreaks", -100, 190, freaksAnimDefs(), false, PIXEL_ZOOM)
        freaks:getSheet():setFilter("nearest", "nearest")
        freaks:animate("danceLeft_happy", false)
    end

    M.resetSongState()

    psychStages.apply(isEvil and "schoolEvil" or "school")
end

-- lastBeatNum (y el humor/dirección de las freaks) son estado POR CANCIÓN,
-- no por stage -- en Real Psych esto se resetea solo porque curBeat/Conductor
-- arrancan de cero con cada canción nueva. M.load() (que reconstruye sky/
-- school/etc, costoso) solo se llama de nuevo para Thorns (song==3) -- en la
-- transición Senpai->Roses (misma stage "school", sin reload) lastBeatNum se
-- quedaba con el valor final de Senpai, así que en Roses la condición
-- "curBeat > lastBeatNum" no se volvía a cumplir hasta que el conteo de beats
-- de Roses superara al de Senpai (a veces nunca, a veces muy tarde) -- de ahí
-- las freaks quedándose tiesas de forma intermitente. week6.lua debe llamar
-- a esto SIEMPRE al iniciar cada canción, no solo cuando se reconstruye el
-- stage completo.
function M.resetSongState()
    lastBeatNum = -1
    freaksPissed = false
    freaksDanceDir = false
end

-- SchoolEvil.hx schoolIntro(): pantalla roja -> senpai explota -> fundido a
-- blanco -> arranca la canción. Simplificado sin DialogueBox.
--
-- M.update() SOLO marca thornsActive=false al terminar -- no llama a ningún
-- callback desde dentro de su propia pila de llamadas. Es quien llama a
-- M.update() (week6.lua) el que debe detectar la transición true->false en
-- SU PROPIO update() y reaccionar desde ahí (ver M.isThornsIntroActive()).
-- Antes M.update() llamaba un callback (self:load(), que a su vez llama
-- weeks:initUI()) desde dentro de su propio update(), anidado dentro del
-- update() de week6.lua -- una pila síncrona profunda y frágil.
function M.startThornsIntro()
    thornsActive = true
    thornsPhase  = "frozen"
    thornsTimer  = 0
    senpaiAlpha  = 0
    fadeAlpha    = 0
    fadeStarted  = false

    senpaiCrazy = love.filesystem.load("sprites/week6/senpaiCrazy.lua")()
    senpaiCrazy.sizeX, senpaiCrazy.sizeY = PIXEL_ZOOM, PIXEL_ZOOM
    senpaiCrazy.x, senpaiCrazy.y = -50 * PIXEL_ZOOM, 0
    senpaiCrazy:animate("idle", false)

    cam.x, cam.y = 90 * PIXEL_ZOOM, -5 * PIXEL_ZOOM
    cam.sizeX, cam.sizeY = 0.8, 0.8
end

function M.isThornsIntroActive()
    return thornsActive
end

function M.update(dt)
    if thornsActive then
        thornsTimer = thornsTimer + dt

        if thornsPhase == "frozen" then
            senpaiAlpha = math.min(thornsTimer / 2, 1)
            if thornsTimer >= 2 then
                thornsPhase = "crazy"
                thornsTimer = 0
                senpaiAlpha = 1
                audio.playSound(love.audio.newSource("sounds/week6/Senpai_Dies.ogg", "static"))
            end
        elseif thornsPhase == "crazy" then
            if senpaiCrazy then senpaiCrazy:update(dt) end
            if not fadeStarted and thornsTimer >= 4 then
                fadeStarted = true
                fadeAlpha = 0
            end
            if fadeStarted then
                fadeAlpha = fadeAlpha + dt / 1.15
                if fadeAlpha >= 1 then
                    fadeAlpha = 1
                    thornsPhase = "white"
                    thornsTimer = 0
                end
            end
        elseif thornsPhase == "white" then
            if thornsTimer >= 4 then
                thornsActive = false
            end
        end
        return
    end

    if not isEvil then
        if petals  then petals:update(dt)  end
        if bgTrees then bgTrees:update(dt) end
        if freaks  then freaks:update(dt)  end
    else
        -- Mismo bug que freaks tenía antes: animate() se llama pero sin
        -- update() el contador de frame nunca avanza, así que el fondo
        -- evil quedaba congelado en su primer frame.
        if evilSchool then evilSchool:update(dt) end
        if bgGhouls   then bgGhouls:update(dt)   end
    end

    if bpm and absMusicTime then
        -- musicTime (con signo), NO absMusicTime: durante el countdown
        -- musicTime arranca negativo (-(240/bpm)*1000) y cuenta hacia 0;
        -- abs() de eso cuenta HACIA ATRÁS (de varios beats a 0) en vez de
        -- avanzar, inflando lastBeatNum antes de que la canción real empiece
        -- y retrasando (de forma variable, según el bpm) el primer beatHit
        -- real hasta que el conteo real "alcance" ese valor fantasma -- esto
        -- es la causa real de las freaks quedándose tiesas un rato variable
        -- al empezar cada canción (no el estado entre canciones).
        local curBeat = math.floor(musicTime * bpm / 60000)
        if curBeat > (lastBeatNum or -1) then
            lastBeatNum = curBeat
            -- School.hx beatHit(): bgGirls.dance() en cada beat
            freaksDance()
        end
    end
end

function M.draw()
    if thornsActive then
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", 0, 0, graphics.getWidth(), graphics.getHeight())
        love.graphics.setColor(1, 1, 1)

        local w, h = graphics.getWidth() / 2, graphics.getHeight() / 2
        love.graphics.push()
            love.graphics.translate(w, h)
            love.graphics.scale(cam.sizeX, cam.sizeY)
            love.graphics.translate(cam.x, cam.y)
            love.graphics.setColor(1, 1, 1, senpaiAlpha)
            if senpaiCrazy then senpaiCrazy:draw() end
            love.graphics.setColor(1, 1, 1)
        love.graphics.pop()

        if fadeStarted and fadeAlpha > 0 then
            love.graphics.setColor(1, 1, 1, fadeAlpha)
            love.graphics.rectangle("fill", 0, 0, graphics.getWidth(), graphics.getHeight())
            love.graphics.setColor(1, 1, 1)
        end
        return
    end

    if isEvil then
        -- SchoolEvil.hx: scrollFactor real de evilSchool es (0.8, 0.9),
        -- asimétrico -- no se puede compartir el mismo pushParallax(0.9) que
        -- el resto.
        graphics.pushParallax(0.8, 0.9)
            if evilSchool then evilSchool:draw() end
        love.graphics.pop()
        graphics.pushParallax(0.9)
            if bgGhouls and bgGhouls.visible then bgGhouls:draw() end
        love.graphics.pop()
    else
        -- School.hx:20-73 orden real de add(): sky, school, street,
        -- fgTrees/treesBack, bgTrees (animado), treeLeaves/petals,
        -- bgGirls/freaks. Cada capa tiene su PROPIO scrollFactor (no todas
        -- comparten 0.9) -- antes todo el grupo se dibujaba bajo un único
        -- pushParallax(0.9), lo que hacía que sky/school/street/etc se
        -- movieran todos a la MISMA velocidad relativa entre sí, sin la
        -- separación de profundidad real (sky=0.1 casi estático, school=0.6
        -- notablemente más lento que el resto, etc.) -- por eso el parallax
        -- no se notaba.
        graphics.pushParallax(0.1, 0.1)
            sky:draw()
        love.graphics.pop()
        graphics.pushParallax(0.6, 0.90)
            school:draw()
        love.graphics.pop()
        graphics.pushParallax(0.95, 0.95)
            street:draw()
        love.graphics.pop()
        graphics.pushParallax(0.9, 0.9)
            treesBack:draw()
        love.graphics.pop()
        if bgTrees then
            graphics.pushParallax(0.85, 0.85)
                bgTrees:draw()
            love.graphics.pop()
        end
        if petals then
            graphics.pushParallax(0.85, 0.85)
                petals:draw()
            love.graphics.pop()
        end
        if freaks then
            graphics.pushParallax(0.9, 0.9)
                freaks:draw()
            love.graphics.pop()
        end
    end

    graphics.pushParallax(1)
        if girlfriend then girlfriend:draw() end
        if enemy      then enemy:draw()      end
        if boyfriend  then boyfriend:draw()  end
        weeks:drawRating()
    love.graphics.pop()
end

function M.leave()
    sky = nil; school = nil; street = nil; treesBack = nil; bgTrees = nil
    petals = nil; freaks = nil
    evilSchool = nil; bgGhouls = nil
    senpaiCrazy = nil
    thornsActive = false
end

return M
