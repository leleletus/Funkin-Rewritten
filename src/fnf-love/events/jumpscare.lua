-- events/jumpscare.lua
local graphics = graphics
local audio = audio
local Timer = Timer

-- 1. Importar el generador de estática (asegúrate de que la ruta sea correcta)
local createStatic = require("sprites.daSTAT") 

local jumpscareSprites = {}  
local staticSprite = nil -- Variable para guardar la estática activa

local function triggerJumpscare()
    -- --- LÓGICA DEL JUMPSCARE ORIGINAL ---
    local simplejumpImg = love.graphics.newImage(graphics.imagePath("simplejump"))
    local simplejump = graphics.newImage(simplejumpImg)
    local screenWidth, screenHeight = 1280, 720

    simplejump.sizeX = screenWidth / simplejumpImg:getWidth()
    simplejump.sizeY = screenHeight / simplejumpImg:getHeight()
    simplejump.x = screenWidth / 2
    simplejump.y = screenHeight / 2
    simplejump.alpha = 1  

    table.insert(jumpscareSprites, simplejump)

    -- --- 2. LÓGICA DE LA ESTÁTICA (daSTAT) ---
    staticSprite = createStatic() -- Creamos el sprite animado
    -- Escalamos la estática para que cubra la pantalla
    staticSprite.sizeX = screenWidth / 402 -- 402 es el ancho en tu daSTAT.lua
    staticSprite.sizeY = screenHeight / 299 -- 299 es el alto en tu daSTAT.lua
    staticSprite.x = screenWidth / 2
    staticSprite.y = screenHeight / 2

    -- Agitar la cámara
    if cam then
        local originalX, originalY = cam.x, cam.y
        local intensity = 20
        local shakeTimer = Timer.every(0.02, function()
            if not cam then Timer.cancel(shakeTimer) return end
            cam.x = originalX + love.math.random(-intensity, intensity)
            cam.y = originalY + love.math.random(-intensity, intensity)
        end)
        Timer.after(0.6, function()
            Timer.cancel(shakeTimer)
            if cam then cam.x, cam.y = originalX, originalY end
        end)
    end

    audio.playSound(love.audio.newSource("sounds/sppok.ogg", "static"))

    -- 3. Limpieza de ambos elementos
    Timer.after(0.25, function()
        simplejump.alpha = 0
    end)
    
    Timer.after(0.35, function()
        jumpscareSprites = {}
        staticSprite = nil -- Eliminamos la referencia de la estática
    end)
end

-- 4. Función Update para que la animación de la estática avance
local function update(dt)
    if staticSprite and staticSprite.update then
        staticSprite:update(dt)
    end
end

local function draw()
    -- Dibujar Jumpscare
    for _, s in ipairs(jumpscareSprites) do
        love.graphics.setColor(1, 1, 1, s.alpha or 1)
        s:draw()
    end

    -- 5. Dibujar Estática por encima con transparencia 0.3
    if staticSprite then
        love.graphics.setColor(1, 1, 1, 0.3) -- Aplicamos el 30% de opacidad
        staticSprite:draw()
    end

    love.graphics.setColor(1, 1, 1, 1)  -- Restaurar color normal
end

return {
    trigger = triggerJumpscare,
    update = update, -- No olvides exportar el update
    draw = draw
}