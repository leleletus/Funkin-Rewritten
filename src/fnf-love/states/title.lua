-- states/title.lua
local atlasText = require("modules.atlas_text")
local titleTextModule = require("sprites.menu.title-text")
local Conductor = require("modules.conductor")
local conductor = Conductor.new(102)

local logo, gf, titleText, ngSpr
local credGroup = {}
local textGroup = {}
local blackScreen

local initialized = false
local skippedIntro = false
local transitioning = false
local lastBeat = 0
local curWacky = {}
local danceLeft = false
local logoAlt = false

-- Variables de visibilidad para los elementos de la pantalla de título
local logoVisible = false
local gfVisible = false
local titleVisible = false

local cam = { sizeX = 0.9, sizeY = 0.9 }

local confirmSound
local musicVolumeTween
local transitionTimer

-- FlxG.camera.flash(WHITE, duration) real -- Rewritten no tiene un
-- "camera flash" genérico (graphics.fadeIn/fadeOut son fundidos a NEGRO,
-- algo completamente distinto) -- mismo patrón ya usado en
-- stages/AngelIsland/stage.lua (flashAlpha local, decae con dt/duration,
-- dibujado como rectángulo blanco encima de todo).
local flashAlpha = 0
local flashDuration = 1

local function triggerFlash(duration)
    flashAlpha = 1
    flashDuration = duration or 1
end

-- newgrounds_logo / _classic / _animated -- ngSpr.loadGraphic real elige
-- al azar entre las 3 variantes cada vez que se entra a la pantalla de
-- título (FlxG.random.bool(1) -- 1% clásica; si no, FlxG.random.bool(30)
-- -- 30% de el 99% restante -- animada; si no, la normal).
local ngAnimImg, ngAnimQuads
local ngAnimFrame = 0
local ngAnimTimer = 0

local function createCenteredText(y, text, style)
    local textObj = atlasText.new(0, y, text, style)
    local maxX = 0
    for _, letter in ipairs(textObj.letters) do
        local right = letter.x + (letter.width or 0)
        if right > maxX then maxX = right end
    end
    -- REEMPLAZO: Usar 1280 en lugar de love.graphics.getWidth()
    local offsetX = (1280 - maxX) / 2
    for _, letter in ipairs(textObj.letters) do
        letter.x = letter.x + offsetX
    end
    return textObj
end

local function getIntroTextShit()
    local fullText = love.filesystem.read("data/introText.txt")
    if not fullText then return {{"ERROR", "NO FILE"}} end
    local lines = {}
    for line in fullText:gmatch("[^\r\n]+") do
        if line ~= "" then
            local parts = {}
            for part in line:gmatch("[^%-%-]+") do
                table.insert(parts, part)
            end
            table.insert(lines, parts)
        end
    end
    return lines
end

local function createCoolText(textArray)
    textGroup = {}
    for i, txt in ipairs(textArray) do
        local money = createCenteredText(200 + (i-1)*60, txt, "bold")
        table.insert(textGroup, money)
    end
end

local function addMoreText(text)
    local coolText = createCenteredText(200 + #textGroup*60, text, "bold")
    table.insert(textGroup, coolText)
end

local function deleteCoolText()
    textGroup = {}
end

local function skipIntro()
    if skippedIntro then return end
    skippedIntro = true
    
    -- 1. Limpiamos los grupos de texto de la intro
    credGroup = {}
    textGroup = {}
    
    -- 2. CORRECCIÓN: Forzamos que el logo de Newgrounds se oculte
    if ngSpr then 
        ngSpr.visible = false 
    end
    
    -- 3. Mostramos los elementos reales de la pantalla de título
    logoVisible = true
    gfVisible = true
    titleVisible = true

    -- BUG corregido: esto era un fundido a NEGRO (setFade(1)+fadeIn(0.5),
    -- que además no hacía nada visible -- ya estaba en 1) en vez del
    -- destello BLANCO real (FlxG.camera.flash(WHITE, ...)) que pasa al
    -- terminar/saltar los créditos.
    triggerFlash(1)
end

local movingToMenu = false
local function moveToMainMenu()
    -- Guarda contra el doble disparo: el timer de 2s y el "spam enter"
    -- (que lo cancela y llama directo) podrían en teoría solaparse.
    if movingToMenu then return end
    movingToMenu = true

    graphics.fadeOut(0.5, function()
        Gamestate.switch(require("states.menu"))
    end)
end

local function onBeatHit(beat)
    if not skippedIntro then
        if beat > lastBeat then
            for i = lastBeat+1, beat do
                if i == 1 then
                    createCoolText({"The", "Funkin Crew Inc"})
                elseif i == 3 then
                    addMoreText("presents")
                elseif i == 4 then
                    deleteCoolText()
                elseif i == 5 then
                    createCoolText({"In association", "with"})
                elseif i == 7 then
                    addMoreText("newgrounds")
                    if ngSpr then ngSpr.visible = true end
                elseif i == 8 then
                    deleteCoolText()
                    if ngSpr then ngSpr.visible = false end
                elseif i == 9 then
                    createCoolText({curWacky[1] or ""})
                elseif i == 11 then
                    addMoreText(curWacky[2] or "")
                elseif i == 12 then
                    deleteCoolText()
                elseif i == 13 then
                    addMoreText("Friday")
                elseif i == 14 then
                    if curWacky[1] == "trending" then
                        addMoreText("Nigth")
                    else
                        addMoreText("Night")
                    end
                elseif i == 15 then
                    addMoreText("Funkin")
                elseif i == 16 then
                    skipIntro()
                end
            end
            lastBeat = beat
        end
    end

    if logo and logoVisible then
        logoAlt = not logoAlt
        if logoAlt then
            logo:animate("bump", false)
        else
            logo:animate("bumpAlt", false)
        end
    end
    if gf and gfVisible then
        if danceLeft then
            gf:animate("danceRight", false)
        else
            gf:animate("danceLeft", false)
        end
        danceLeft = not danceLeft
    end
    
end

return {
    enter = function(self, previous)
        flashAlpha = 0

        local introLines = getIntroTextShit()
        curWacky = introLines[love.math.random(#introLines)]

        -- Cargar sprites
        logo = love.filesystem.load("sprites/menu/logoBumpin.lua")()
        gf = love.filesystem.load("sprites/menu/girlfriend-title.lua")()

        -- Posiciones originales aproximadas
        logo.x, logo.y = -350, -125
        gf.x, gf.y = 300, 50

        -- BUG corregido: esto era un texto renderizado por fuente
        -- ("PRESS ENTER" con atlas_text) -- TitleState.hx real usa el
        -- atlas ANIMADO "title-screen-text" (createTextureAtlas), con
        -- una pose "Idle" en bucle y una animación "Confirm" al
        -- presionar. title-text.lua espera el CENTRO deseado en pantalla
        -- (no la posición real de FunkinSprite -- ver el comentario ahí
        -- sobre por qué este atlas en particular necesita ese ajuste).
        titleText = titleTextModule.new(1280 / 2, 720 * 0.8)

        -- Logo Newgrounds -- 3 variantes posibles, igual que el real:
        -- FlxG.random.bool(1) (1%) clásica; si no, FlxG.random.bool(30)
        -- (30% del 99% restante) animada (2 frames, 4fps); si no, la
        -- normal.
        ngAnimImg = nil; ngAnimQuads = nil; ngAnimFrame = 0; ngAnimTimer = 0
        local ngScale = 1
        local ngExtraY = 0
        local ngImagePath

        if love.math.random() < 0.01 then
            ngImagePath = "images/png/menu/newgrounds_logo_classic.png"
        elseif love.math.random() < 0.30 then
            ngImagePath = "images/png/menu/newgrounds_logo_animated.png"
            ngScale = 0.55
            ngExtraY = 25
        else
            ngImagePath = "images/png/menu/newgrounds_logo.png"
            ngScale = 0.8
        end

        local ngSprImage = love.graphics.newImage(ngImagePath)
        local ngW, ngH = ngSprImage:getWidth(), ngSprImage:getHeight()

        if ngImagePath:find("animated") then
            -- loadGraphic(path, true, 600) real -- 2 frames de 600px de
            -- ancho cada uno, en una sola fila.
            ngAnimImg = ngSprImage
            local frameW = 600
            ngAnimQuads = {
                love.graphics.newQuad(0, 0, frameW, ngH, ngW, ngH),
                love.graphics.newQuad(frameW, 0, frameW, ngH, ngW, ngH),
            }
            ngW = frameW
        end

        ngSpr = {
            image = ngSprImage,
            scale = ngScale,
            x = (1280 - ngW * ngScale) / 2,
            y = 720 * 0.52 + ngExtraY,
            visible = false
        }

        -- Registrar callback de beats
        conductor:addBeatHitCallback(onBeatHit)

        -- Música
        -- BUG corregido: arrancaba directo a volumen completo --
        -- playMenuMusic() real: startingVolume=0.0 +
        -- music.fadeIn(4.0, 0.0, 1.0) (4 SEGUNDOS, no instantáneo).
        if not _G.music or not _G.music:isPlaying() then
            music = love.audio.newSource("music/menu/menu.ogg", "stream")
            music:setLooping(true)
            music:setVolume(0)
            music:play()
            _G.music = music   -- compartir globalmente

            musicVolumeTween = { v = 0 }
            Timer.tween(4, musicVolumeTween, { v = 1 }, "linear", function()
                musicVolumeTween = nil
            end)
        else
            music = _G.music   -- Usar la música que ya venía del menú
        end

        -- Sonido de confirmación
        confirmSound = love.audio.newSource("sounds/menu/confirm.ogg", "static")

        -- FlxG.mouse.visible = false real -- mismo criterio, restaurado
        -- en leave() para no afectar otras pantallas.
        love.mouse.setVisible(false)

        -- Inicialmente ocultamos logo, gf y título
        logoVisible = false
        gfVisible = false
        titleVisible = false
        transitioning = false -- Asegurarnos de que no se quede pegado el estado de transición
        movingToMenu = false
        transitionTimer = nil

        -- 2. CORRECCIÓN DE LA PANTALLA NEGRA:
        if not initialized then
            -- Primera vez: dejamos que la intro ocurra
            Timer.after(1, function() end)
            initialized = true
            graphics.setFade(0)
            graphics.fadeIn(0.5)
        else
            -- Ya se vio la intro en esta sesión: la saltamos directamente
            skippedIntro = false -- Reseteamos temporalmente para que skipIntro() haga su trabajo
            skipIntro()
        end
    end,

    update = function(self, dt)
        conductor:update(dt, music:tell() * 1000)

        -- fadeIn(4.0, 0.0, 1.0) real -- música arranca en silencio y
        -- sube a volumen completo en 4s.
        if musicVolumeTween then
            music:setVolume(musicVolumeTween.v)
        elseif initialized and music:getVolume() < 0.8 then
            -- "if((FlxG.sound.music?.volume??1.0) < 0.8 && initialized)
            -- music.volume += 0.5*elapsed" real -- red de seguridad para
            -- cuando el volumen quedó bajo por algún otro motivo (pausa,
            -- etc.) -- sube de a poco de vuelta, no de golpe.
            music:setVolume(math.min(1, music:getVolume() + 0.5 * dt))
        end

        if flashAlpha > 0 then
            flashAlpha = math.max(0, flashAlpha - dt / flashDuration)
        end

        if ngAnimQuads then
            ngAnimTimer = ngAnimTimer + dt
            if ngAnimTimer >= 1 / 4 then -- animation.add('idle',[0,1],4) real
                ngAnimTimer = 0
                ngAnimFrame = (ngAnimFrame == 0) and 1 or 0
            end
        end

        if logo then logo:update(dt) end
        if gf then gf:update(dt) end

        for _, t in ipairs(textGroup) do t:update(dt) end
        if titleText and titleVisible then titleText:update(dt) end

        if not graphics.isFading() then
            if input:pressed("confirm") then
                if transitioning and skippedIntro then
                    -- "Spam Enter" real: si ya está transicionando,
                    -- saltar la espera de 2s y pasar de una.
                    if transitionTimer then
                        Timer.cancel(transitionTimer)
                        transitionTimer = nil
                    end
                    moveToMainMenu()
                elseif not transitioning and skippedIntro then
                    -- titleText.animation.play('press') real -- la
                    -- animación de confirmación del atlas, en vez de
                    -- quedarse en su pose "Idle" hasta que cambia de
                    -- estado.
                    if titleText then titleText:playConfirm() end
                    if confirmSound then confirmSound:play() end
                    -- BUG corregido: esto fundía a negro de una (0.5s) en
                    -- vez del destello blanco + 2 SEGUNDOS mostrando la
                    -- animación "Confirm" antes de cambiar de estado
                    -- (FlxG.camera.flash(WHITE,1) + new
                    -- FlxTimer().start(2, moveToMainMenu) real).
                    triggerFlash(1)
                    transitioning = true
                    transitionTimer = Timer.after(2, function()
                        transitionTimer = nil
                        moveToMainMenu()
                    end)
                elseif not skippedIntro then
                    skipIntro()
                end
            end

            if input:pressed("back") then
                love.event.quit()
            end
        end
    end,

    draw = function(self)
        love.graphics.clear(0, 0, 0)

        -- Aplicar transformación de cámara para logo, GF y Newgrounds
        love.graphics.push()
            -- REEMPLAZO: Usar 1280 y 720 para centrar la cámara virtual
            love.graphics.translate(1280 / 2, 720 / 2)
            love.graphics.scale(cam.sizeX, cam.sizeY)

            if logo and logoVisible then logo:draw() end
            if gf and gfVisible then gf:draw() end

            -- Logo de Newgrounds (convertir coordenadas usando la base virtual)
            if ngSpr and ngSpr.visible then
                -- REEMPLAZO: Usar 1280 y 720
                local ngRelX = ngSpr.x - 1280 / 2
                local ngRelY = ngSpr.y - 720 / 2
                love.graphics.setColor(1, 1, 1)
                if ngAnimQuads then
                    love.graphics.draw(ngAnimImg, ngAnimQuads[ngAnimFrame + 1], ngRelX, ngRelY, 0, ngSpr.scale, ngSpr.scale)
                else
                    love.graphics.draw(ngSpr.image, ngRelX, ngRelY, 0, ngSpr.scale, ngSpr.scale)
                end
            end
        love.graphics.pop()

        -- Dibujar título "PRESS ENTER" sin transformación (coordenadas absolutas)
        if titleText and titleVisible then titleText:draw() end

        -- Dibujar textos de la intro (también en coordenadas absolutas)
        for _, t in ipairs(textGroup) do
            t:draw()
        end

        -- FlxG.camera.flash(WHITE, ...) real -- rectángulo blanco encima
        -- de todo, decayendo (ver triggerFlash()/update()).
        if flashAlpha > 0 then
            love.graphics.setColor(1, 1, 1, flashAlpha)
            love.graphics.rectangle("fill", 0, 0, 1280, 720)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end,

    leave = function(self)
        --music:stop()
        love.mouse.setVisible(true)
        Timer.clear()
    end
}