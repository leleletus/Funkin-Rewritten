-- Stage: "AngelIsland" (mod Too Slow / Sonic.exe) -- puerto del script de
-- modchart Lua de Psych Engine real (stages/AngelIsland/stage.lua, API
-- onCreate/makeLuaSprite/addLuaSprite/setProperty/doTweenX/runTimer) a la
-- API nativa de FNF Rewritten (M.load/M.update/M.draw/M.leave, igual que
-- stages/military/stage.lua). Esa API de Psych no existe en este motor --
-- este archivo reemplaza el original entero, manteniendo el mismo layout
-- visual/temporizado donde se pudo verificar.

local M = {}

local psychStages = require("charts.psych.stages")
local bgsprite = require("charts.psych.bgsprite")
local events = require("charts.psych.events")
local graphics = require("modules.graphics")
local spoopyscare = require("events.spoopyscare")
local jumpscare = require("events.jumpscare")
local screenStatic = require("sprites.screenstatic")

local sky, hills, floor1, floor2, frontgrass, egghead, tail, knuckle, tailspike, redFade

-- Intro: réplica del chillador.lua viejo (fondo negro + círculo/texto "Too
-- Slow" deslizándose desde afuera de pantalla, con un delay inicial, una
-- pausa sostenida, y un fade-out final) -- NO arranca con la cuenta atrás
-- normal (3-2-1-GO con beeps): weeks/too-slow.lua salta directo a
-- musicTime=0 + inst:play()/voices:play(), y esto es solo una superposición
-- visual sobre la canción que ya empezó, igual que el viejo.
local introBlack, introCircle, introText
local introTimer1, introTimer2, introTimer3

-- "TooSlowFlashinShit" (events.json real): en el chillador.lua viejo, el
-- efecto de "estática" de TV (screenstatic.lua) era ALEATORIO (cada 2-15s,
-- scheduleNextStatic); acá es un evento FIJO del chart (events.json), así
-- que se dispara siempre en el mismo punto de la canción en vez de al azar
-- -- mismo gráfico/sonido (screenSTATIC + simplejumpsound.ogg), solo que
-- estable en vez de aleatorio. Registrado una sola vez al nivel del módulo
-- (no dentro de M.load(), que corre de nuevo en cada intento/retry).
local staticSprite = screenStatic()
staticSprite.alpha = 0
-- BUG real: nunca se fijaba la posición -- graphics.newSprite() arranca en
-- (0,0) por defecto, así que el centro del sprite quedaba en la esquina
-- superior izquierda de la pantalla en vez de cubrirla entera (el sprite
-- ES del tamaño exacto de la pantalla, 1280x720, pero CENTRO-anclado --
-- sin esto, 3/4 de la imagen caían fuera de la vista).
staticSprite.x, staticSprite.y = 640, 360
local staticSound = love.audio.newSource("sounds/simplejumpsound.ogg", "static")

events.registerHandler("TooSlowFlashinShit", function(ev)
    staticSprite.alpha = 0.4
    staticSprite:animate("screenSTATIC", true)
    staticSound:stop()
    staticSound:play()
    Timer.after(0.25, function()
        staticSprite.alpha = 0
    end)
end)

-- "sonicspook" (events.json real): mini-jumpscare. Reusa events/
-- spoopyscare.lua (sonicJUMPSCARE.png, ya cargado y enganchado a
-- weeks.lua:update()/draw() -- ver "Spoopy Scare" en cameraEvents) para el
-- gráfico, más sounds/sppok.ogg como sonido propio de este evento (aparte
-- de los 2 sonidos que spoopyscare.trigger() ya reproduce por su cuenta).
local sonicSpookSound = love.audio.newSource("sounds/sppok.ogg", "static")

events.registerHandler("sonicspook", function(ev)
    spoopyscare.trigger()
    sonicSpookSound:stop()
    sonicSpookSound:play()
end)

-- "SonicJumpscare" (charts/chillador/too-slow-hard.lua viejo, cameraEvents):
-- reusa events/jumpscare.lua tal cual (ya estaba escrito y casi enganchado
-- del todo a weeks.lua -- solo le faltaba jumpscare.update(dt), agregado
-- ahora). En el chart viejo este evento vivía en "section.events"
-- (cameraEvents, formato nativo de Rewritten) -- como events.json usa el
-- formato Psych de toda la vida, se reextrajo y se agregó como evento
-- incrustado más (ver data/too-slow/events.json), disparado igual por
-- charts/psych/events.lua.
events.registerHandler("SonicJumpscare", function(ev)
    print("[AngelIsland] SonicJumpscare disparado @ " .. tostring(musicTime))
    local ok, err = pcall(jumpscare.trigger)
    if not ok then print("[AngelIsland] jumpscare.trigger() ERROR: " .. tostring(err)) end
end)

-- "HighlightOn"/"HighlightOff": solo apaga/prende el HUD (fade de
-- guiAlphaObj) -- ya NO toca la cámara para nada (a pedido; antes enfocaba
-- la cámara en target ("enemy"/"boyfriend") igual que el viejo
-- cameraEvents, pero competía con el auto-cam y causaba bamboleo). El
-- segundo argumento (ev.value1, "target") ya no se usa, queda solo por
-- compatibilidad con el chart.
events.registerHandler("HighlightOn", function(ev)
    print("[AngelIsland] HighlightOn disparado @ " .. tostring(musicTime) .. " target=" .. tostring(ev.value1))
    local ok, err = pcall(function() weeks:setHighlight(true, ev.value1) end)
    if not ok then print("[AngelIsland] setHighlight(true) ERROR: " .. tostring(err)) end
end)

events.registerHandler("HighlightOff", function(ev)
    print("[AngelIsland] HighlightOff disparado @ " .. tostring(musicTime))
    local ok, err = pcall(function() weeks:setHighlight(false) end)
    if not ok then print("[AngelIsland] setHighlight(false) ERROR: " .. tostring(err)) end
end)

-- "TooSlowShakeFlash": el shake+flash puntual de chillador.lua viejo
-- (musicTime>=84538, un único momento dramático -- distinto del parpadeo
-- breve y repetido de "TooSlowFlashinShit"). Flash: pantalla roja completa
-- que decae LENTO (4s), separado del decaimiento rápido de redFade/
-- TooSlowFlashinShit -- se actualiza en M.update() porque necesita
-- decaer cuadro a cuadro junto con el draw.
--
-- Shake: reescrito para usar Timer.every(0.02,...) -- el mismo patrón que
-- events/jumpscare.lua (ya probado, "tal cual andaba antes") -- en vez de
-- la actualización cuadro a cuadro de la primera versión, que el usuario
-- reportó como "rara" (la tasa de actualización dependía del framerate en
-- vez de un intervalo fijo, dando un temblor más errático que el
-- original).
local flashAlpha = 0

events.registerHandler("TooSlowShakeFlash", function(ev)
    print("[AngelIsland] TooSlowShakeFlash disparado @ " .. tostring(musicTime))
    flashAlpha = 1

    -- BUG real (ronda anterior): apagar el auto-cam con _G.disableAutoCam
    -- mientras el shake escribía cam.x/y directo, y reactivarlo después,
    -- causaba un bamboleo feo al soltar -- el seguimiento automático (que
    -- se recrea cada frame en states/weeks.lua) tenía que "alcanzar" desde
    -- la posición congelada del shake hasta el objetivo real, que para
    -- entonces ya se había movido. Ahora el shake es un offset PURAMENTE
    -- visual (graphics.setShakeOffset, sumado en pushParallax sin tocar
    -- cam.x/y) -- el auto-cam sigue corriendo de fondo sin interrupción,
    -- nunca hay nada que "alcanzar" al soltar.
    local intensity = 10
    local shakeTimerHandle = Timer.every(0.02, function()
        graphics.setShakeOffset(
            love.math.random(-intensity, intensity),
            love.math.random(-intensity, intensity)
        )
    end)
    Timer.after(0.3, function()
        Timer.cancel(shakeTimerHandle)
        graphics.setShakeOffset(0, 0)
    end)
end)

function M.load()
    sky        = graphics.newImage(love.graphics.newImage(graphics.imagePath("Angel-Island/EXE_SKY")))
    hills      = graphics.newImage(love.graphics.newImage(graphics.imagePath("Angel-Island/EXE_HILLS")))
    floor2     = graphics.newImage(love.graphics.newImage(graphics.imagePath("Angel-Island/EXE_FLOOR2")))
    floor1     = graphics.newImage(love.graphics.newImage(graphics.imagePath("Angel-Island/EXE_FLOOR1")))
    knuckle    = graphics.newImage(love.graphics.newImage(graphics.imagePath("Angel-Island/exe_KNUCKLE")))
    egghead    = graphics.newImage(love.graphics.newImage(graphics.imagePath("Angel-Island/EXE_EGGMAN")))
    tail       = graphics.newImage(love.graphics.newImage(graphics.imagePath("Angel-Island/EXE_TAIL")))
    frontgrass = graphics.newImage(love.graphics.newImage(graphics.imagePath("Angel-Island/exe_frontgrass")))
    redFade    = graphics.newImage(love.graphics.newImage(graphics.imagePath("Angel-Island/exe_redfade")))

    -- Posiciones Psych reales (makeLuaSprite, top-left) -> centro
    -- (graphics.newImage es centro-anclado, igual que el resto del motor --
    -- ver modules/graphics.lua:newImage()/draw()). Todas las imágenes son
    -- 1920x1080 salvo exe_KNUCKLE (1351x1080).
    sky.x,        sky.y        = -300 + 1920/2, 0    + 1080/2
    hills.x,      hills.y      = -300 + 1920/2, 0    + 1080/2
    floor2.x,     floor2.y     = -300 + 1920/2, -100 + 1080/2
    floor1.x,     floor1.y     = -300 + 1920/2, -100 + 1080/2
    knuckle.x,    knuckle.y    = 200  + 1351/2, -200 + 1080/2
    egghead.x,    egghead.y    = -215 + 1920/2, -150 + 1080/2
    tail.x,       tail.y       = -400 + 1920/2, -150 + 1080/2
    frontgrass.x, frontgrass.y = -300 + 1920/2, -100 + 1080/2
    -- redFade se dibuja en espacio de pantalla (M.drawHUD(), sin paralaje) --
    -- tiene que centrarse en el centro REAL de pantalla (lovesize.set(1280,
    -- 720) en main.lua), no en el centro de sus propios 1920x1080 nativos
    -- (960,540 quedaría desplazado ~320px a la derecha y ~180px abajo del
    -- centro real). Con esto, la imagen (más grande que la pantalla) cubre
    -- de sobra los 1280x720 con margen en los 4 bordes.
    redFade.x, redFade.y = graphics.getWidth() / 2, graphics.getHeight() / 2
    flashAlpha = 0
    _G.disableAutoCam = false
    staticSprite.alpha = 0

    -- Tails Spike Animated: único decorado con atlas propio (loop continuo,
    -- igual que addAnimationByPrefix(...,'Tails_pike',...,12,true) real).
    tailspike = bgsprite.new("Angel-Island/Exe_TailsSpikeAnimated", -100, -100,
        { "Tails Spike Animated instance 1" }, true, 1.2)

    -- Personajes (posición/zoom): igual que stages/military/stage.lua, la
    -- posición real de boyfriend/girlfriend/enemy la define
    -- stages/data/AngelIsland.json, aplicada acá -- characters.lua ya debe
    -- haber cargado "sonicexe" en el slot enemy antes de este punto
    -- (orden real: loadStage() corre ANTES de initUI()/applyChartMeta(), así
    -- que esta primera llamada solo fija el zoom -- la posición real de
    -- sonicexe se reaplica sola cuando applyChartMeta() vuelve a llamar
    -- psychStages.apply() con meta.stage, igual que para cualquier otro
    -- personaje -- ver el fix general de este mismo problema en
    -- states/weeks.lua:applyChartMeta()).
    psychStages.apply("AngelIsland")
end

-- Llamado por weeks/too-slow.lua justo cuando arranca la canción de forma
-- directa (SIN la cuenta atrás normal de 3-2-1-GO con beeps -- ver
-- weeks/too-slow.lua, réplica del chillador.lua viejo: la música ya está
-- sonando, esto es pura superposición visual encima).
--
-- Timing exacto del viejo (chillador.lua:startIntro/introPhase 0->4):
--   Timer.after(1) -> [arranca el slide]
--     Timer.tween(1, text/circle, {x=centro}, "out-quad") -> [al llegar]
--       Timer.after(2) -> [fin de la pausa sostenida]
--         Timer.tween(1.5, black+text+circle, {alpha=0}, "linear")
-- Total: 1 + 1 + 2 + 1.5 = 5.5s desde que arranca la canción hasta que
-- desaparece todo. Las posiciones de entrada/salida (640±900) se quedan
-- igual que la versión anterior de este archivo -- son específicas de
-- estos assets (CircleTooSlow.png/TextTooSlow.png, lienzo completo de
-- 1280x720 con el gráfico real ya posicionado adentro), el viejo usaba
-- imágenes recortadas de otro tamaño que no existen en este proyecto.
function M.onSongStart()
    if not introBlack then
        introBlack  = graphics.newImage(love.graphics.newImage(graphics.imagePath("titular/BLACK")))
        introCircle = graphics.newImage(love.graphics.newImage(graphics.imagePath("titular/CircleTooSlow")))
        introText   = graphics.newImage(love.graphics.newImage(graphics.imagePath("titular/TextTooSlow")))
    end

    introBlack.visible, introCircle.visible, introText.visible = true, true, true
    introBlack.alpha, introCircle.alpha, introText.alpha = 1, 1, 1
    introBlack.x, introBlack.y = 640, 360
    introCircle.x, introCircle.y = 640 + 900, 360
    introText.x,   introText.y   = 640 - 900, 360

    if introTimer1 then Timer.cancel(introTimer1) end
    if introTimer2 then Timer.cancel(introTimer2) end
    if introTimer3 then Timer.cancel(introTimer3) end

    introTimer1 = Timer.after(1, function()
        introTimer2 = Timer.tween(1, introCircle, { x = 640 - 100 }, "out-quad")
        Timer.tween(1, introText, { x = 640 + 100 }, "out-quad", function()
            introTimer3 = Timer.after(2, function()
                Timer.tween(1.5, introBlack,  { alpha = 0 }, "linear")
                Timer.tween(1.5, introCircle, { alpha = 0 }, "linear")
                Timer.tween(1.5, introText,   { alpha = 0 }, "linear", function()
                    introBlack.visible, introCircle.visible, introText.visible = false, false, false
                end)
            end)
        end)
    end)
end

-- Diagnóstico temporal: imprime cada ~0.5s el alpha real de flashAlpha y
-- del HUD (guiAlphaObj.value, vía weeks:getGuiAlphaObj()) -- para saber si
-- el flash/highlight realmente cambian de valor o si algo los está
-- pisando cuadro a cuadro sin que se note leyendo el código.
local debugPrintTimer = 0

function M.update(dt)
    -- Flash rojo lento de "TooSlowShakeFlash" (4s, igual que chillador.lua
    -- viejo) -- separado del parpadeo de "TooSlowFlashinShit" (que ahora es
    -- la estática de TV, no este flash).
    if flashAlpha > 0 then
        flashAlpha = math.max(0, flashAlpha - dt / 4)
    end

    staticSprite:update(dt)

    debugPrintTimer = debugPrintTimer + dt
    if debugPrintTimer >= 0.5 then
        debugPrintTimer = 0
        local guiVal = weeks and weeks:getGuiAlphaObj() and weeks:getGuiAlphaObj().value
        if flashAlpha > 0 or (guiVal and guiVal < 0.99) then
            print(("[AngelIsland] t=%.1f flashAlpha=%.2f guiAlpha=%s disableAutoCam=%s"):format(
                musicTime or -1, flashAlpha, tostring(guiVal), tostring(_G.disableAutoCam)))
        end
    end
end

function M.draw()
    graphics.pushParallax(0.75)
        sky:draw()
    love.graphics.pop()

    graphics.pushParallax(0.9)
        hills:draw()
    love.graphics.pop()

    -- Resto del fondo: scrollFactor 1 (default real de Flixel, Psych no lo
    -- pisa para estos -- igual que el suelo/personajes).
    graphics.pushParallax(1)
        floor2:draw()
        floor1:draw()
        tailspike:draw()
        knuckle:draw()
        egghead:draw()
        tail:draw()
        if girlfriend then girlfriend:draw() end
        if enemy then enemy:draw() end
        if boyfriend then boyfriend:draw() end
        frontgrass:draw()
    love.graphics.pop()
end

function M.drawHUD()
    -- Espacio de pantalla fijo (igual que setObjectCamera(...,'other') real
    -- -- sin paralaje/zoom de cámara), encima de los personajes.
    if flashAlpha > 0 then
        graphics.setColor(1, 1, 1, flashAlpha)
        redFade:draw()
        graphics.setColor(1, 1, 1, 1)
    end

    -- Estática de TV de "TooSlowFlashinShit" -- por encima de todo lo
    -- demás (mismo orden que jumpscare.lua: el dibujo va siempre al final,
    -- como una superposición de pantalla completa).
    if staticSprite.alpha > 0 then
        graphics.setColor(1, 1, 1, staticSprite.alpha)
        staticSprite:draw()
        graphics.setColor(1, 1, 1, 1)
    end

    -- graphics.newImage() no maneja alpha por su cuenta (su :draw() llama
    -- love.graphics.draw() directo, sin setColor) -- hay que envolverlo a
    -- mano para que el fade-out del Timer.tween sobre ".alpha" se vea.
    if introBlack and introBlack.visible then
        graphics.setColor(1, 1, 1, introBlack.alpha or 1)
        introBlack:draw()
    end
    if introCircle and introCircle.visible then
        graphics.setColor(1, 1, 1, introCircle.alpha or 1)
        introCircle:draw()
    end
    if introText and introText.visible then
        graphics.setColor(1, 1, 1, introText.alpha or 1)
        introText:draw()
    end
    graphics.setColor(1, 1, 1, 1)

    -- jumpscare.lua ("SonicJumpscare"): tiene su propio draw() de pantalla
    -- completa (simplejump.png + estática daSTAT), igual de fijo.
    jumpscare.draw()
end

function M.leave()
    sky = nil; hills = nil; floor1 = nil; floor2 = nil; frontgrass = nil
    egghead = nil; tail = nil; knuckle = nil; tailspike = nil; redFade = nil
    introBlack = nil; introCircle = nil; introText = nil
    if introTimer1 then Timer.cancel(introTimer1); introTimer1 = nil end
    if introTimer2 then Timer.cancel(introTimer2); introTimer2 = nil end
    if introTimer3 then Timer.cancel(introTimer3); introTimer3 = nil end
    _G.disableAutoCam = false
    flashAlpha = 0
    staticSprite.alpha = 0
end

return M
