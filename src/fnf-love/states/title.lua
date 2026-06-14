-- states/title.lua
local atlasText = require("modules.atlas_text")
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
    
    -- Efectos visuales
    graphics.setFade(1)
    graphics.fadeIn(0.5)
end

local function moveToMainMenu()
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
        local introLines = getIntroTextShit()
        curWacky = introLines[love.math.random(#introLines)]

        -- Cargar sprites
        logo = love.filesystem.load("sprites/menu/logoBumpin.lua")()
        gf = love.filesystem.load("sprites/menu/girlfriend-title.lua")()

        -- Posiciones originales aproximadas
        logo.x, logo.y = -350, -125
        gf.x, gf.y = 300, 50

        -- Título "PRESS ENTER" (REEMPLAZO: Usar 720)
        titleText = createCenteredText(720 * 0.8, "PRESS ENTER", "bold")

        -- Logo Newgrounds
        local ngSprImage = love.graphics.newImage("images/png/menu/newgrounds_logo.png")
        ngSpr = {
            image = ngSprImage,
            x = (1280 - ngSprImage:getWidth()) / 2,
            y = 720 * 0.52,
            visible = false
        }

        -- Registrar callback de beats
        conductor:addBeatHitCallback(onBeatHit)

        -- Música
        if not _G.music or not _G.music:isPlaying() then
            music = love.audio.newSource("music/menu/menu.ogg", "stream")
            music:setLooping(true)
            music:play()
            _G.music = music   -- compartir globalmente
        else
            music = _G.music   -- Usar la música que ya venía del menú
        end

        -- Sonido de confirmación
        confirmSound = love.audio.newSource("sounds/menu/confirm.ogg", "static")

        -- Inicialmente ocultamos logo, gf y título
        logoVisible = false
        gfVisible = false
        titleVisible = false
        transitioning = false -- Asegurarnos de que no se quede pegado el estado de transición

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

        if logo then logo:update(dt) end
        if gf then gf:update(dt) end

        for _, t in ipairs(textGroup) do t:update(dt) end
        if titleText and titleVisible then titleText:update(dt) end

        if not graphics.isFading() then
            if input:pressed("confirm") then
                if transitioning and skippedIntro then
                    moveToMainMenu()
                elseif not transitioning and skippedIntro then
                    if confirmSound then confirmSound:play() end
                    graphics.setFade(1)
                    graphics.fadeIn(0.5)
                    transitioning = true
                    moveToMainMenu()
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
                love.graphics.draw(ngSpr.image, ngRelX, ngRelY)
            end
        love.graphics.pop()

        -- Dibujar título "PRESS ENTER" sin transformación (coordenadas absolutas)
        if titleText and titleVisible then titleText:draw() end

        -- Dibujar textos de la intro (también en coordenadas absolutas)
        for _, t in ipairs(textGroup) do
            t:draw()
        end
    end,

    leave = function(self)
        --music:stop()
        Timer.clear()
    end
}