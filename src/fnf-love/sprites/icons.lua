local characters = {
    -- Normales (150x150)
    { normal = "boyfriend",          losing = "boyfriend losing",          file = "icon-bf",      pixel = false },
    { normal = "skid and pump",      losing = "skid and pump losing",      file = "icon-spooky",  pixel = false },
    { normal = "pico",                losing = "pico losing",               file = "icon-pico",    pixel = false },
    { normal = "mommy mearest",       losing = "mommy mearest losing",      file = "icon-mom",     pixel = false },
    { normal = "tankman",             losing = "tankman losing",            file = "icon-tankman", pixel = false },
    { normal = "unknown",             losing = "unknown losing",            file = "icon-face",    pixel = false },
    { normal = "daddy dearest",       losing = "daddy dearest losing",      file = "icon-dad",     pixel = false },
    { normal = "boyfriend (old)",     losing = "boyfriend losing (old)",    file = "icon-bf-old",  pixel = false },
    { normal = "girlfriend",          losing = nil,                         file = "icon-gf",      pixel = false },
    { normal = "dearest duo",         losing = "dearest duo losing",        file = "icon-parents", pixel = false },
    { normal = "monster",             losing = "monster losing",            file = "icon-monster", pixel = false },
    
    -- Pixel (32x32)
    { normal = "boyfriend (pixel)",   losing = "boyfriend (pixel) losing",  file = "icon-bf-pixel", pixel = true },
    { normal = "senpai",              losing = "senpai losing",             file = "icon-senpai",   pixel = true },
    { normal = "senpai-angry",        losing = "senpai-angry losing",       file = "icon-senpai-angry",   pixel = true },
    { normal = "spirit",               losing = "spirit losing",             file = "icon-spirit",   pixel = true },
    
    -- Más normales
    { normal = "yunjin",               losing = "yunjin losing",             file = "icon-yunjin",   pixel = false },
    { normal = "sakura",                losing = "sakura losing",             file = "icon-sakura",   pixel = false },
    { normal = "chaewon",               losing = "chaewon losing",            file = "icon-chaewon",  pixel = false },
    { normal = "eunchae",               losing = "eunchae losing",            file = "icon-eunchae",  pixel = false },
    { normal = "kazuha",                losing = "kazuha losing",             file = "icon-kazuha",   pixel = false },
    { normal = "darnell",              losing = "darnell losing",           file = "icon-darnell", pixel = false },
    { normal = "sonic",                losing = "sonic losing",             file = "icon-sonic",   pixel = false },
    { normal = "sonic2",                losing = "sonic2 losing",             file = "icon-sonic2",   pixel = false },
    { normal = "sonic2poop",            losing = "sonic2poop losing",         file = "icon-sonic2Poop",   pixel = false },
    { normal = "sanic",                losing = "sanic losing",             file = "icon-sanic",   pixel = false },
    { normal = "majin",                losing = "majin losing",             file = "icon-majin",   pixel = false },

    
    -- MINIPIXEL (16x16)
    { normal = "crappyonic",           losing = "crappyonic losing",         file = "icon-crappyonic",   minipixel = true },
    { normal = "crappyfriend",         losing = "crappyfriend losing",       file = "icon-crappyfriend", minipixel = true },
}

-- Función que construye el sprite combinado (igual que antes, pero usando la tabla characters)
local function buildCombinedIconSprite()
    local basePath = "images/png/icons/"

    local frames = {}
    local animations = {}
    local frameIndex = 1
    local currentX = 0
    local maxHeight = 150

    -- Calcular ancho total
    local totalWidth = 0
    for _, char in ipairs(characters) do
        local frameW = 150
        if char.minipixel then
            frameW = 16
        elseif char.pixel then
            frameW = 32
        end
        local numFrames = (char.losing and 2 or 1)
        totalWidth = totalWidth + frameW * numFrames
    end

    local combinedData = love.image.newImageData(totalWidth, maxHeight)

    -- Pegar frames
    for _, char in ipairs(characters) do
        local path = basePath .. char.file .. ".png"
        local imgData = love.image.newImageData(path)
        local imgWidth, imgHeight = imgData:getWidth(), imgData:getHeight()

        local frameW, frameH = 150, 150
        if char.minipixel then
            frameW, frameH = 16, 16
        elseif char.pixel then
            frameW, frameH = 32, 32
        end

        -- Validaciones (opcional, pero útil)
        if char.minipixel then
            assert(imgWidth == frameW or imgWidth == frameW * 2, "Mini Pixel icon " .. char.file .. " tiene ancho inesperado: " .. imgWidth)
            assert(imgHeight == frameH, "Mini Pixel icon " .. char.file .. " tiene alto inesperado: " .. imgHeight)
        elseif char.pixel then
            assert(imgWidth == frameW or imgWidth == frameW * 2, "Pixel icon " .. char.file .. " tiene ancho inesperado: " .. imgWidth)
            assert(imgHeight == frameH, "Pixel icon " .. char.file .. " tiene alto inesperado: " .. imgHeight)
        else
            assert(imgWidth == frameW or imgWidth == frameW * 2, "Normal icon " .. char.file .. " tiene ancho inesperado: " .. imgWidth)
            assert(imgHeight == frameH, "Normal icon " .. char.file .. " tiene alto inesperado: " .. imgHeight)
        end

        if char.losing then
            -- Frame normal
            frames[frameIndex] = { x = currentX, y = 0, width = frameW, height = frameH, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0 }
            animations[char.normal] = { start = frameIndex, stop = frameIndex, speed = 0, offsetX = 0, offsetY = 0 }
            combinedData:paste(imgData, currentX, 0, 0, 0, frameW, frameH)
            currentX = currentX + frameW
            frameIndex = frameIndex + 1

            -- Frame perdiendo
            frames[frameIndex] = { x = currentX, y = 0, width = frameW, height = frameH, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0 }
            animations[char.losing] = { start = frameIndex, stop = frameIndex, speed = 0, offsetX = 0, offsetY = 0 }
            combinedData:paste(imgData, currentX, 0, frameW, 0, frameW, frameH)
            currentX = currentX + frameW
            frameIndex = frameIndex + 1
        else
            -- Solo un frame
            frames[frameIndex] = { x = currentX, y = 0, width = frameW, height = frameH, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0 }
            animations[char.normal] = { start = frameIndex, stop = frameIndex, speed = 0, offsetX = 0, offsetY = 0 }
            combinedData:paste(imgData, currentX, 0, 0, 0, frameW, frameH)
            currentX = currentX + frameW
            frameIndex = frameIndex + 1
        end
    end

    local sheetImage = love.graphics.newImage(combinedData)
    sheetImage:setFilter("nearest", "nearest")

    return graphics.newSprite(sheetImage, frames, animations, "boyfriend", false)
end

-- Función que devuelve el factor de escala según el nombre del personaje
local function getScaleFactor(animName)
    local baseName = animName:gsub(" losing$", "")  -- quitar sufijo " losing"
    for _, char in ipairs(characters) do
        if char.normal == baseName or char.losing == baseName then
            if char.minipixel then
                return 9.375   -- 150/16
            elseif char.pixel then
                return 4.6875  -- 150/32
            else
                return 1
            end
        end
    end
    return 1  -- por defecto
end

-- Exportamos ambas funciones
return {
    create = buildCombinedIconSprite,
    getScaleFactor = getScaleFactor
}