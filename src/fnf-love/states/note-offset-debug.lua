--[[
Offset Debug Menu - Versión con soporte Regular/Pixel (corregida totalmente)

Controles:
  - Teclas 1,2,3,4 : seleccionar dirección (left, down, up, right)
  - Tab : cambiar modo entre Normal y Hold (se muestra en pantalla)
  - P : cambiar estilo entre Regular y Pixel
  - Flechas ←/→ : ajustar offset X en el modo actual
  - Flechas ↑/↓ : ajustar offset Y en el modo actual
  - Ctrl + flechas : ajuste de 10 en 10
  - Espacio : probar splash normal en la dirección seleccionada
  - H (mantener) : probar hold splash (inicia al pulsar, loop mientras se mantiene, end al soltar)
  - F : probar animación de flecha "press"
  - F2 : mostrar valores actuales en consola
  - Escape : salir
]]

local state = {}
local graphics, input, Timer

-- Posiciones base
local ARROW_X = { -200, -70, 70, 200 }
local ARROW_Y = 0

-- Escalas según estilo
local SCALE_REG = 0.7
local SCALE_PIXEL = 6
local SPLASH_SCALE_REG = 1.5
local SPLASH_SCALE_PIXEL = 6

-- Sprites actuales
local arrows = {}
local splashes = {}
local holdSplashes = {}

-- Direcciones
local directions = { "left", "down", "up", "right" }
local selectedDir = 1

-- Offsets para cada estilo
local splashOffsetsReg = { x = {0,0,0,0}, y = {0,0,0,0} }
local holdOffsetsReg   = { x = {0,0,0,0}, y = {0,0,0,0} }
local splashOffsetsPixel = { x = {0,0,0,0}, y = {0,0,0,0} }
local holdOffsetsPixel   = { x = {0,0,0,0}, y = {0,0,0,0} }

-- Estilo actual y modo de edición
local style = "regular"
local editMode = "normal"

-- Estado de teclas para hold
local holdKeyPressed = false
local holdActive = false
local holdTimer = nil

-- Control de visibilidad de splashes (para evitar que se dibujen al cargar)
local splashVisible = {false, false, false, false}
local holdSplashVisible = {false, false, false, false}

-- Temporizadores para restaurar flechas a "off"
local arrowAnimTimer = {0, 0, 0, 0}
local ARROW_PRESS_TIME = 0.1      -- duración para "press"
local ARROW_CONFIRM_TIME = 0.15   -- duración para "confirm"

-- Función para leer offsets de un archivo de sprite
local function getOffsetsFromSpriteFile(filename, animName)
    local chunk, err = love.filesystem.load(filename)
    if not chunk then return 0, 0 end
    local ok, spriteData = pcall(chunk)
    if not ok or type(spriteData) ~= "table" then return 0, 0 end
    local anims = spriteData[3]
    if not anims or not anims[animName] then return 0, 0 end
    local anim = anims[animName]
    return anim.offsetX or 0, anim.offsetY or 0
end

-- Cargar sprites según el estilo
local function loadStyleSprites(style)
    arrows = {}
    splashes = {}
    holdSplashes = {}

    -- Resetear visibilidad y temporizadores
    for i = 1,4 do
        splashVisible[i] = false
        holdSplashVisible[i] = false
        arrowAnimTimer[i] = 0
    end

    local isPixel = (style == "pixel")
    local folder = isPixel and "pixel/" or ""
    local scale = isPixel and SCALE_PIXEL or SCALE_REG
    local splashScale = isPixel and SPLASH_SCALE_PIXEL or SPLASH_SCALE_REG

    if not images then images = {} end

    if isPixel then
        images.notes = love.graphics.newImage(graphics.imagePath("pixel/notes"))
        images.notes:setFilter("nearest", "nearest")
        images.noteSplashes = love.graphics.newImage(graphics.imagePath("pixel/pixelNoteSplash"))
        images.noteSplashes:setFilter("nearest", "nearest")
        images.noteHoldCover = love.graphics.newImage(graphics.imagePath("pixel/pixelNoteHoldCover"))
        images.noteHoldCover:setFilter("nearest", "nearest")
    else
        images.notes = love.graphics.newImage(graphics.imagePath("notes"))
        images.noteSplashes = love.graphics.newImage(graphics.imagePath("noteSplashes"))
    end

    -- Cargar flechas
    local arrowFiles = {
        love.filesystem.load("sprites/"..folder.."left-arrow.lua"),
        love.filesystem.load("sprites/"..folder.."down-arrow.lua"),
        love.filesystem.load("sprites/"..folder.."up-arrow.lua"),
        love.filesystem.load("sprites/"..folder.."right-arrow.lua")
    }
    for i = 1,4 do
        local sprite = arrowFiles[i]()
        sprite.x = ARROW_X[i]
        sprite.y = ARROW_Y
        sprite.sizeX, sprite.sizeY = scale, scale
        sprite:animate("off", false)
        arrows[i] = sprite
    end

    -- Cargar splashes normales
    local splashFiles = {
        "sprites/"..folder.."splash-left.lua",
        "sprites/"..folder.."splash-down.lua",
        "sprites/"..folder.."splash-up.lua",
        "sprites/"..folder.."splash-right.lua"
    }
    for i = 1,4 do
        local file = splashFiles[i]
        local ox, oy
        if isPixel then
            ox, oy = splashOffsetsPixel.x[i], splashOffsetsPixel.y[i]
        else
            ox, oy = splashOffsetsReg.x[i], splashOffsetsReg.y[i]
        end
        if ox == 0 and oy == 0 then
            ox, oy = getOffsetsFromSpriteFile(file, "splash")
            if isPixel then
                splashOffsetsPixel.x[i] = ox
                splashOffsetsPixel.y[i] = oy
            else
                splashOffsetsReg.x[i] = ox
                splashOffsetsReg.y[i] = oy
            end
        end
        local sprite = love.filesystem.load(file)()
        sprite.x = ARROW_X[i]
        sprite.y = ARROW_Y
        sprite.sizeX, sprite.sizeY = splashScale, splashScale
        sprite.offsetX = ox
        sprite.offsetY = oy
        -- Aseguramos que no se reproduzca automáticamente (solo por si acaso)
        sprite:animate("splash", false)
        splashes[i] = sprite
    end

    -- Cargar hold splashes
    local holdFiles = {
        "sprites/"..folder.."HoldSplash-left.lua",
        "sprites/"..folder.."HoldSplash-down.lua",
        "sprites/"..folder.."HoldSplash-up.lua",
        "sprites/"..folder.."HoldSplash-right.lua"
    }
    for i = 1,4 do
        local file = holdFiles[i]
        local ox, oy
        if isPixel then
            ox, oy = holdOffsetsPixel.x[i], holdOffsetsPixel.y[i]
        else
            ox, oy = holdOffsetsReg.x[i], holdOffsetsReg.y[i]
        end
        if ox == 0 and oy == 0 then
            ox, oy = getOffsetsFromSpriteFile(file, "loop")
            if isPixel then
                holdOffsetsPixel.x[i] = ox
                holdOffsetsPixel.y[i] = oy
            else
                holdOffsetsReg.x[i] = ox
                holdOffsetsReg.y[i] = oy
            end
        end
        local sprite = love.filesystem.load(file)()
        sprite.x = ARROW_X[i]
        sprite.y = ARROW_Y
        sprite.sizeX, sprite.sizeY = splashScale, splashScale
        sprite.offsetX = ox
        sprite.offsetY = oy
        -- No iniciar automáticamente
        sprite:animate("start", false)
        holdSplashes[i] = sprite
    end
end

-- Actualizar offsets en los sprites actuales
local function updateOffsets()
    local isPixel = (style == "pixel")
    for i = 1,4 do
        if splashes[i] then
            if isPixel then
                splashes[i].offsetX = splashOffsetsPixel.x[i]
                splashes[i].offsetY = splashOffsetsPixel.y[i]
            else
                splashes[i].offsetX = splashOffsetsReg.x[i]
                splashes[i].offsetY = splashOffsetsReg.y[i]
            end
        end
        if holdSplashes[i] then
            if isPixel then
                holdSplashes[i].offsetX = holdOffsetsPixel.x[i]
                holdSplashes[i].offsetY = holdOffsetsPixel.y[i]
            else
                holdSplashes[i].offsetX = holdOffsetsReg.x[i]
                holdSplashes[i].offsetY = holdOffsetsReg.y[i]
            end
        end
    end
end

-- Iniciar hold splash
local function startHoldSplash()
    if holdActive then return end
    holdActive = true
    holdSplashVisible[selectedDir] = true
    local hs = holdSplashes[selectedDir]
    hs:animate("start", false)
    holdTimer = Timer.after(1/24, function()
        if holdActive then
            hs:animate("loop", true)
        end
    end)
end

-- Finalizar hold splash
local function endHoldSplash()
    if not holdActive then return end
    holdActive = false
    if holdTimer then Timer.cancel(holdTimer) end
    holdSplashes[selectedDir]:animate("end", false)
    -- La visibilidad se desactivará cuando termine la animación "end"
end

-- Probar press de flecha
local function pressArrow()
    arrows[selectedDir]:animate("press", false)
    arrowAnimTimer[selectedDir] = ARROW_PRESS_TIME
end

-- Probar splash normal + confirm de flecha
local function pressSplash()
    if style == "pixel" then
        arrows[selectedDir]:animate("press", false)
    else
        arrows[selectedDir]:animate("confirm", false)
    end
    arrowAnimTimer[selectedDir] = ARROW_CONFIRM_TIME
    splashVisible[selectedDir] = true
    splashes[selectedDir]:animate("splash", false)
end

function state:enter(prev)
    graphics = require("modules.graphics")
    input = require("input")
    Timer = require("lib.timer")

    style = "regular"
    loadStyleSprites(style)
    selectedDir = 1
    editMode = "normal"
    holdKeyPressed = false
    holdActive = false
    holdTimer = nil

    graphics.fadeIn(0.3)
end

function state:update(dt)
    -- Actualizar sprites
    for i = 1,4 do
        if arrows[i] then arrows[i]:update(dt) end
        if splashes[i] then splashes[i]:update(dt) end
        if holdSplashes[i] then holdSplashes[i]:update(dt) end
    end

    -- Gestionar temporizadores de flechas
    for i = 1,4 do
        if arrowAnimTimer[i] > 0 then
            arrowAnimTimer[i] = arrowAnimTimer[i] - dt
            if arrowAnimTimer[i] <= 0 then
                arrows[i]:animate("off", false)
            end
        end
    end

    -- Ocultar splashes normales cuando terminen su animación
    for i = 1,4 do
        if splashVisible[i] and splashes[i] and not splashes[i]:isAnimated() then
            splashVisible[i] = false
        end
        if holdSplashVisible[i] and holdSplashes[i] and not holdSplashes[i]:isAnimated() then
            holdSplashVisible[i] = false
        end
    end

    -- Selección de dirección
    if input:pressed("num1") then selectedDir = 1 end
    if input:pressed("num2") then selectedDir = 2 end
    if input:pressed("num3") then selectedDir = 3 end
    if input:pressed("num4") then selectedDir = 4 end

    -- Cambiar modo con Tab
    if input:pressed("tab") then
        editMode = (editMode == "normal") and "hold" or "normal"
    end

    -- Cambiar estilo con P
    if input:pressed("p") then
        style = (style == "regular") and "pixel" or "regular"
        loadStyleSprites(style)
        if holdActive then endHoldSplash() end
    end

    -- Ajuste de offsets
    local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
    local step = ctrl and 10 or 1
    local isPixel = (style == "pixel")

    if input:pressed("left") then
        if editMode == "normal" then
            if isPixel then
                splashOffsetsPixel.x[selectedDir] = splashOffsetsPixel.x[selectedDir] - step
            else
                splashOffsetsReg.x[selectedDir] = splashOffsetsReg.x[selectedDir] - step
            end
        else
            if isPixel then
                holdOffsetsPixel.x[selectedDir] = holdOffsetsPixel.x[selectedDir] - step
            else
                holdOffsetsReg.x[selectedDir] = holdOffsetsReg.x[selectedDir] - step
            end
        end
        updateOffsets()
    end
    if input:pressed("right") then
        if editMode == "normal" then
            if isPixel then
                splashOffsetsPixel.x[selectedDir] = splashOffsetsPixel.x[selectedDir] + step
            else
                splashOffsetsReg.x[selectedDir] = splashOffsetsReg.x[selectedDir] + step
            end
        else
            if isPixel then
                holdOffsetsPixel.x[selectedDir] = holdOffsetsPixel.x[selectedDir] + step
            else
                holdOffsetsReg.x[selectedDir] = holdOffsetsReg.x[selectedDir] + step
            end
        end
        updateOffsets()
    end
    if input:pressed("up") then
        if editMode == "normal" then
            if isPixel then
                splashOffsetsPixel.y[selectedDir] = splashOffsetsPixel.y[selectedDir] - step
            else
                splashOffsetsReg.y[selectedDir] = splashOffsetsReg.y[selectedDir] - step
            end
        else
            if isPixel then
                holdOffsetsPixel.y[selectedDir] = holdOffsetsPixel.y[selectedDir] - step
            else
                holdOffsetsReg.y[selectedDir] = holdOffsetsReg.y[selectedDir] - step
            end
        end
        updateOffsets()
    end
    if input:pressed("down") then
        if editMode == "normal" then
            if isPixel then
                splashOffsetsPixel.y[selectedDir] = splashOffsetsPixel.y[selectedDir] + step
            else
                splashOffsetsReg.y[selectedDir] = splashOffsetsReg.y[selectedDir] + step
            end
        else
            if isPixel then
                holdOffsetsPixel.y[selectedDir] = holdOffsetsPixel.y[selectedDir] + step
            else
                holdOffsetsReg.y[selectedDir] = holdOffsetsReg.y[selectedDir] + step
            end
        end
        updateOffsets()
    end

    -- Prueba de splash normal
    if input:pressed("space") then
        pressSplash()
    end

    -- Prueba de hold
    if input:pressed("h") then
        holdKeyPressed = true
        holdTimer = Timer.after(0.2, function()
            if holdKeyPressed then startHoldSplash() end
        end)
    end
    if input:released("h") then
        holdKeyPressed = false
        if holdTimer then Timer.cancel(holdTimer); holdTimer = nil end
        if holdActive then endHoldSplash() end
    end

    -- Prueba de press de flecha
    if input:pressed("f") then
        pressArrow()
    end

    -- Mostrar valores en consola
    if input:pressed("save") then
        print("=== OFFSETS ACTUALES ("..style:upper()..") ===")
        for i = 1,4 do
            local sx, sy, hx, hy
            if isPixel then
                sx, sy = splashOffsetsPixel.x[i], splashOffsetsPixel.y[i]
                hx, hy = holdOffsetsPixel.x[i], holdOffsetsPixel.y[i]
            else
                sx, sy = splashOffsetsReg.x[i], splashOffsetsReg.y[i]
                hx, hy = holdOffsetsReg.x[i], holdOffsetsReg.y[i]
            end
            print(string.format("%s: splashX=%d splashY=%d  holdX=%d holdY=%d",
                directions[i], sx, sy, hx, hy))
        end
    end

    -- Salir
    if input:pressed("back") then
        if holdActive then endHoldSplash() end
        graphics.fadeOut(0.3, function()
            Gamestate.switch(require("states.debug-menu"))
        end)
    end
end

function state:draw()
    love.graphics.push()
        love.graphics.translate(graphics.getWidth()/2, graphics.getHeight()/2)

        -- Dibujar flechas
        for i = 1,4 do
            arrows[i]:draw()
        end

        -- Dibujar splashes normales solo si están visibles
        for i = 1,4 do
            if splashVisible[i] then
                splashes[i]:draw()
            end
        end

        -- Dibujar hold splashes solo si están visibles
        for i = 1,4 do
            if holdSplashVisible[i] then
                holdSplashes[i]:draw()
            end
        end

        -- Mostrar valores de offset
        love.graphics.setColor(1, 1, 1, 0.8)
        local isPixel = (style == "pixel")
        for i = 1,4 do
            local x = ARROW_X[i]
            local y = ARROW_Y + 80
            local sx, sy, hx, hy
            if isPixel then
                sx, sy = splashOffsetsPixel.x[i], splashOffsetsPixel.y[i]
                hx, hy = holdOffsetsPixel.x[i], holdOffsetsPixel.y[i]
            else
                sx, sy = splashOffsetsReg.x[i], splashOffsetsReg.y[i]
                hx, hy = holdOffsetsReg.x[i], holdOffsetsReg.y[i]
            end
            love.graphics.setColor(0, 1, 0, 0.8)
            love.graphics.print(string.format("N: %d,%d", sx, sy), x - 50, y)
            love.graphics.setColor(1, 1, 0, 0.8)
            love.graphics.print(string.format("H: %d,%d", hx, hy), x - 50, y + 20)
        end

        -- Panel de información
        love.graphics.setColor(1, 1, 1)
        local infoX = -graphics.getWidth()/2 + 20
        local infoY = -graphics.getHeight()/2 + 20
        love.graphics.print("=== OFFSET DEBUG (Regular/Pixel) ===", infoX, infoY)
        love.graphics.print("Selección: "..directions[selectedDir].." (tecla "..selectedDir..")", infoX, infoY + 20)
        love.graphics.print("Estilo: "..style:upper().." (P para cambiar)", infoX, infoY + 40)
        love.graphics.print("Modo: "..editMode:upper().." (Tab para cambiar)", infoX, infoY + 60)
        love.graphics.print("Flechas: ajustar offset en modo actual", infoX, infoY + 80)
        love.graphics.print("Ctrl + flechas: paso 10", infoX, infoY + 100)
        love.graphics.print("Espacio: probar splash normal", infoX, infoY + 120)
        love.graphics.print("H (mantener): probar hold splash", infoX, infoY + 140)
        love.graphics.print("F: probar press de flecha", infoX, infoY + 160)
        love.graphics.print("F2: mostrar en consola  |  Escape: salir", infoX, infoY + 180)

        -- Valores del seleccionado
        local csx, csy, chx, chy
        if isPixel then
            csx, csy = splashOffsetsPixel.x[selectedDir], splashOffsetsPixel.y[selectedDir]
            chx, chy = holdOffsetsPixel.x[selectedDir], holdOffsetsPixel.y[selectedDir]
        else
            csx, csy = splashOffsetsReg.x[selectedDir], splashOffsetsReg.y[selectedDir]
            chx, chy = holdOffsetsReg.x[selectedDir], holdOffsetsReg.y[selectedDir]
        end
        love.graphics.setColor(0, 1, 0)
        love.graphics.print(string.format("Splash %s: X=%d Y=%d", directions[selectedDir], csx, csy), infoX, infoY + 210)
        love.graphics.setColor(1, 1, 0)
        love.graphics.print(string.format("Hold   %s: X=%d Y=%d", directions[selectedDir], chx, chy), infoX, infoY + 230)

    love.graphics.pop()
end

function state:leave()
    Timer.clear()
end

return state