-- events/sserafimEnding.lua
local graphics = graphics
local audio = audio
local Timer = Timer

local activeOverlays = {}  -- Lista de overlays activos

local function reset()
    activeOverlays = {}
end

local function trigger(imagePath, soundPath, duration)
    -- Cargar la imagen
    local img = love.graphics.newImage(graphics.imagePath(imagePath))
    local overlay = graphics.newImage(img)

    -- REEMPLAZO: Fijar las dimensiones a la resolución virtual (1280x720)
    -- en lugar de usar love.graphics.getDimensions()
    local screenWidth = 1280
    local screenHeight = 720

    -- Escalar para cubrir toda la pantalla virtual
    overlay.sizeX = screenWidth / img:getWidth()
    overlay.sizeY = screenHeight / img:getHeight()
    
    -- Centrar en la pantalla virtual
    overlay.x = screenWidth / 2
    overlay.y = screenHeight / 2
    overlay.alpha = 1  -- Opaco

    -- Agregar a la lista
    table.insert(activeOverlays, overlay)

    -- Reproducir sonido
    local sound = love.audio.newSource("sounds/" .. soundPath, "static")
    audio.playSound(sound)

    -- Ocultar y eliminar después del tiempo indicado (por defecto 15s)
    local showTime = duration or 15
    Timer.after(showTime, function()
        overlay.alpha = 0
    end)
    Timer.after(showTime + 0.1, function()
        -- Eliminar este overlay específico de la lista
        for i, o in ipairs(activeOverlays) do
            if o == overlay then
                table.remove(activeOverlays, i)
                break
            end
        end
    end)
end

local function draw()
    for _, overlay in ipairs(activeOverlays) do
        love.graphics.setColor(1, 1, 1, overlay.alpha or 1)
        overlay:draw()
    end
    love.graphics.setColor(1, 1, 1, 1)  -- Restaurar
end

return {
    trigger = trigger,
    draw = draw,
    reset = reset
}