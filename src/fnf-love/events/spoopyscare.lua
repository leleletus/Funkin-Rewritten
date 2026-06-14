-- events/spoopyscare.lua
local graphics = graphics
local audio = audio
local Timer = Timer

local sprites = {}  -- Lista de sprites activos

-- Precargar recursos (solo una vez)
local jumpscareImage = love.graphics.newImage(graphics.imagePath("sonicJUMPSCARE"))
local jumpscareSound = love.audio.newSource("sounds/jumpscare.ogg", "static")
local datOneSound = love.audio.newSource("sounds/datOneSound.ogg", "static")

-- Definición de frames con offsets (todos a cero)
local frames = {
    {x = 0, y = 0, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 1155, y = 0, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 2310, y = 0, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 3465, y = 0, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 4620, y = 0, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 5775, y = 0, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 6930, y = 0, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 0, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 1155, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 2310, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 3465, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 4620, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 5775, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 6930, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 0, y = 2912, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 1155, y = 2912, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 2310, y = 2912, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 4620, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- repetido
    {x = 5775, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 6930, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 3465, y = 2912, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 4620, y = 2912, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 5775, y = 2912, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 6930, y = 2912, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
    {x = 0, y = 4368, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
}

local animations = {
    ["sonicSPOOK"] = {start = 1, stop = 25, speed = 24, offsetX = 0, offsetY = 0}
}

-- Resolución base de referencia (ajusta según tu pantalla no maximizada)
local baseWidth = 1280   -- Cambia esto al ancho de tu ventana no maximizada
local baseHeight = 720   -- Cambia esto al alto de tu ventana no maximizada

local function trigger()
    -- Crear nuevo sprite usando la imagen precargada
    local sprite = graphics.newSprite(jumpscareImage, frames, animations, "sonicSPOOK", false)

    -- Obtener dimensiones de la pantalla actual
    local sw, sh = 1280, 720
    local frameW, frameH = 1155, 1456

    -- Escala proporcional basada en el ancho de la ventana
    -- (puedes cambiar a basada en altura si prefieres)
    local scale = sw / baseWidth
    sprite.sizeX = scale
    sprite.sizeY = scale

    -- Centrar horizontalmente
    sprite.x = sw / 2

    -- Posición vertical: base del sprite tocando el borde inferior, más offset escalado
    -- El offset 750 fue ajustado para la resolución base
    local verticalOffset = 750  -- Ajusta este valor en la resolución base
    sprite.y = sh - (frameH * scale) / 2 + verticalOffset * scale

    -- Reproducir sonidos
    jumpscareSound:play()
    datOneSound:play()

    -- Agregar a la lista
    table.insert(sprites, sprite)

    -- Eliminar después de la duración de la animación (25/24 ≈ 1.04s)
    Timer.after(1.05, function()
        for i, s in ipairs(sprites) do
            if s == sprite then
                table.remove(sprites, i)
                break
            end
        end
    end)
end

local function update(dt)
    for _, s in ipairs(sprites) do
        s:update(dt)
    end
end

local function draw()
    for _, s in ipairs(sprites) do
        love.graphics.setColor(1, 1, 1, s.alpha or 1)
        s:draw()
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return {
    trigger = trigger,
    update = update,
    draw = draw
}