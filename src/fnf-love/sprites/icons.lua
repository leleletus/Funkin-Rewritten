--[[----------------------------------------------------------------------------
  FASE 3 de la refactorización de ergonomía de modding (ver memoria del
  proyecto "modding-ergonomics-refactor"). Antes, esta tabla exigía
  marcar cada ícono como pixel=true/minipixel=true y el código asumía
  EXACTAMENTE 150x150/32x32/16x16 -- assert() que crasheaba el juego
  entero si un PNG medía cualquier otra cosa. Ahora el tamaño de cada
  frame (y el factor de escala de la barra de vida) se calcula DIRECTO
  de las dimensiones reales del PNG cargado (igual que Psych Engine real,
  HealthIcon.hx:26-48 -- sin lista ni assert de tamaños fijos).

  Esta tabla sigue existiendo SOLO para los íconos cuyo nombre de
  animación no es derivable del nombre del archivo (alias reales, ej.
  "icon-mom" -> "mommy mearest") -- agregar uno nuevo aquí sigue siendo
  opcional, nunca obligatorio: un ícono COMPLETAMENTE nuevo (ej.
  "healthicon":"miPersonaje" en un characters/<id>.json, sin ninguna
  entrada acá) funciona solo con soltar
  images/png/icons/icon-miPersonaje.png en disco -- ver M.animate() más
  abajo, que es quien debe usarse en vez de sprite:animate() directo
  para animar un ícono de barra de vida.
------------------------------------------------------------------------------]]

local characters = {
    { normal = "boyfriend",          losing = "boyfriend losing",          file = "icon-bf" },
    { normal = "skid and pump",      losing = "skid and pump losing",      file = "icon-spooky" },
    { normal = "pico",                losing = "pico losing",               file = "icon-pico" },
    { normal = "mommy mearest",       losing = "mommy mearest losing",      file = "icon-mom" },
    { normal = "tankman",             losing = "tankman losing",            file = "icon-tankman" },
    { normal = "unknown",             losing = "unknown losing",            file = "icon-face" },
    { normal = "daddy dearest",       losing = "daddy dearest losing",      file = "icon-dad" },
    { normal = "boyfriend (old)",     losing = "boyfriend losing (old)",    file = "icon-bf-old" },
    { normal = "girlfriend",          losing = nil,                         file = "icon-gf" },
    { normal = "dearest duo",         losing = "dearest duo losing",        file = "icon-parents" },
    { normal = "monster",             losing = "monster losing",            file = "icon-monster" },

    { normal = "boyfriend (pixel)",   losing = "boyfriend (pixel) losing",  file = "icon-bf-pixel" },
    { normal = "senpai",              losing = "senpai losing",             file = "icon-senpai" },
    { normal = "senpai-angry",        losing = "senpai-angry losing",       file = "icon-senpai-angry" },
    { normal = "spirit",               losing = "spirit losing",             file = "icon-spirit" },

    { normal = "darnell",              losing = "darnell losing",           file = "icon-darnell" },
    { normal = "kazuha",               losing = "kazuha losing",            file = "icon-kazuha" },
    { normal = "chaewon",              losing = "chaewon losing",           file = "icon-chaewon" },
    { normal = "eunchae",              losing = "eunchae losing",           file = "icon-eunchae" },
    { normal = "sakura",               losing = "sakura losing",            file = "icon-sakura" },
    { normal = "yunjin",               losing = "yunjin losing",            file = "icon-yunjin" },
    { normal = "face",                 losing = nil,                         file = "icon-face" },
    { normal = "sonic",                losing = "sonic losing",             file = "icon-sonic" },
    { normal = "sonic2",                losing = "sonic2 losing",             file = "icon-sonic2" },
    { normal = "sonic2poop",            losing = "sonic2poop losing",         file = "icon-sonic2Poop" },
    { normal = "sanic",                losing = "sanic losing",             file = "icon-sanic" },
    { normal = "majin",                losing = "majin losing",             file = "icon-majin" },

    { normal = "crappyonic",           losing = "crappyonic losing",         file = "icon-crappyonic" },
    { normal = "crappyfriend",         losing = "crappyfriend losing",       file = "icon-crappyfriend" },
}

-- Talla de referencia "normal" -- la barra de vida está tuneada para
-- mostrar los íconos a este tamaño visual; getScaleFactor() calcula
-- cuánto hay que escalar un frame de altura distinta para que se vea
-- igual de grande en pantalla (antes: 9.375/4.6875/1 hardcodeado, que
-- son exactamente 150/16 y 150/32 -- la constante real siempre fue 150).
local REFERENCE_SIZE = 150

-- animName -> altura real (en pixeles) del frame ya horneado, poblada en
-- buildCombinedIconSprite() y por M.animate() para íconos standalone.
local iconFrameHeights = {}

local basePath = "images/png/icons/"

-- Función que construye el sprite combinado (misma idea que antes, pero
-- el tamaño de cada frame se lee del PNG real, no de un flag pixel/minipixel).
local function buildCombinedIconSprite()
    -- Primera pasada: cargar cada PNG y calcular su tamaño de frame real.
    local loaded = {}
    local totalWidth = 0
    local maxHeight = 0

    for i, char in ipairs(characters) do
        local path = basePath .. char.file .. ".png"
        local imgData = love.image.newImageData(path)
        local imgWidth, imgHeight = imgData:getWidth(), imgData:getHeight()
        local numFrames = char.losing and 2 or 1

        -- Único chequeo que queda -- no es una lista de tamaños fijos,
        -- es una verificación estructural real: si se esperan 2 frames
        -- lado a lado (normal+losing en un solo PNG), el ancho tiene
        -- que ser divisible entre 2 sin perder píxeles.
        if numFrames == 2 then
            assert(imgWidth % 2 == 0, "icon " .. char.file .. ": ancho " .. imgWidth .. " no es divisible por 2 (se esperan 2 frames lado a lado, normal+losing)")
        end

        local frameW = imgWidth / numFrames
        local frameH = imgHeight

        loaded[i] = { imgData = imgData, frameW = frameW, frameH = frameH, numFrames = numFrames }
        totalWidth = totalWidth + frameW * numFrames
        if frameH > maxHeight then maxHeight = frameH end
    end

    local combinedData = love.image.newImageData(totalWidth, maxHeight)

    -- Segunda pasada: pegar los frames usando los tamaños ya calculados.
    local frames = {}
    local animations = {}
    local frameIndex = 1
    local currentX = 0

    for i, char in ipairs(characters) do
        local L = loaded[i]
        local frameW, frameH = L.frameW, L.frameH

        iconFrameHeights[char.normal] = frameH
        if char.losing then iconFrameHeights[char.losing] = frameH end

        if char.losing then
            frames[frameIndex] = { x = currentX, y = 0, width = frameW, height = frameH, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0 }
            animations[char.normal] = { start = frameIndex, stop = frameIndex, speed = 0, offsetX = 0, offsetY = 0 }
            combinedData:paste(L.imgData, currentX, 0, 0, 0, frameW, frameH)
            currentX = currentX + frameW
            frameIndex = frameIndex + 1

            frames[frameIndex] = { x = currentX, y = 0, width = frameW, height = frameH, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0 }
            animations[char.losing] = { start = frameIndex, stop = frameIndex, speed = 0, offsetX = 0, offsetY = 0 }
            combinedData:paste(L.imgData, currentX, 0, frameW, 0, frameW, frameH)
            currentX = currentX + frameW
            frameIndex = frameIndex + 1
        else
            frames[frameIndex] = { x = currentX, y = 0, width = frameW, height = frameH, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0 }
            animations[char.normal] = { start = frameIndex, stop = frameIndex, speed = 0, offsetX = 0, offsetY = 0 }
            combinedData:paste(L.imgData, currentX, 0, 0, 0, frameW, frameH)
            currentX = currentX + frameW
            frameIndex = frameIndex + 1
        end
    end

    local sheetImage = love.graphics.newImage(combinedData)
    sheetImage:setFilter("nearest", "nearest")

    return graphics.newSprite(sheetImage, frames, animations, "boyfriend", false)
end

-- Función que devuelve el factor de escala según el nombre del personaje.
local function getScaleFactor(animName)
    local frameH = iconFrameHeights[animName]
    if not frameH then
        frameH = iconFrameHeights[animName:gsub(" losing$", "")]
    end
    if not frameH or frameH <= 0 then return 1 end
    return REFERENCE_SIZE / frameH
end

-- M.animate(spriteObj, animName, loop, callback): usar SIEMPRE esto en vez
-- de spriteObj:animate(...) directo para animar un ícono de barra de
-- vida/menú. Si animName ya es una animación conocida (del atlas
-- combinado, o ya agregada antes como standalone a ESTE sprite), delega
-- directo. Si no, intenta autodetectar un ícono nuevo leyendo
-- images/png/icons/icon-<base>.png directo del disco -- sin ninguna
-- entrada en la tabla `characters` de este archivo. Si tampoco existe
-- ese PNG, delega igual (deja que el WARN ya existente de
-- sprite:animate() avise de un nombre realmente inválido).
local function animateIcon(spriteObj, animName, loop, callback)
    if spriteObj:getAnims()[animName] then
        spriteObj:animate(animName, loop, callback)
        return
    end

    local baseName = animName:gsub(" losing$", "")
    local path = basePath .. "icon-" .. baseName .. ".png"

    if love.filesystem.getInfo(path) then
        local image = love.graphics.newImage(path)
        image:setFilter("nearest", "nearest")
        local w, h = image:getWidth(), image:getHeight()

        if w == h * 2 then
            -- 2 frames lado a lado (normal+losing), misma convención
            -- que la tabla `characters` para los íconos ya registrados.
            spriteObj:addStandaloneAnim(baseName, image, 0, 0, h, h)
            spriteObj:addStandaloneAnim(baseName .. " losing", image, h, 0, h, h)
            iconFrameHeights[baseName] = h
            iconFrameHeights[baseName .. " losing"] = h
        else
            -- Una sola pose -- se usa igual para "normal" y "losing".
            spriteObj:addStandaloneAnim(baseName, image, 0, 0, w, h)
            spriteObj:addStandaloneAnim(baseName .. " losing", image, 0, 0, w, h)
            iconFrameHeights[baseName] = h
            iconFrameHeights[baseName .. " losing"] = h
        end
    end

    spriteObj:animate(animName, loop, callback)
end

return {
    create = buildCombinedIconSprite,
    getScaleFactor = getScaleFactor,
    animate = animateIcon,
}
