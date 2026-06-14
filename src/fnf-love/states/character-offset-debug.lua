--[[
Character Offset Debug con Navegador de Archivos
Permite cargar cualquier sprite de la carpeta sprites/ y ajustar sus offsets.

Controles en navegador:
  ↑/↓ : mover selección
  Rueda : navegar
  Enter : entrar en carpeta / cargar sprite
  Escape : retroceder carpeta (o salir al menú en la raíz)

Controles en edición:
  Q/E : cambiar animación
  Flechas : ajustar offset (Shift + flecha = paso 10)
  P : alternar filtro de píxel (nearest/linear)
  R : volver al navegador
  F3 : generar archivo completo del sprite en consola
  Escape : volver al menú de depuración
]]

local state = {}
local graphics, input, Timer

-- Ruta base para buscar sprites
local BASE_PATH = "sprites"

-- Estado del navegador
local browser = {
    path = "",            -- ruta relativa a BASE_PATH (vacío = BASE_PATH)
    entries = {},         -- lista de nombres de archivos/carpetas
    selection = 1,
    mode = "browser"      -- "browser" o "editing"
}

-- Variables para el sprite en edición
local currentSprite = nil
local currentSpritePath = ""
local currentAnimList = {}
local currentAnimIndex = 1
local currentAnim = ""
local offsetX, offsetY = 0, 0
local zoom = 1
local pixelFilter = false   -- false = linear, true = nearest

-- Almacenar la estructura original para generar el archivo completo
local originalFrames = nil
local originalAnims = nil

-- Función para serializar una tabla a string Lua (para generar el archivo)
local function serialize(t, indent)
    indent = indent or ""
    local str = "{\n"
    for k, v in pairs(t) do
        str = str .. indent .. "    "
        if type(k) == "string" then
            if k:match("[^a-zA-Z0-9_]") then
                str = str .. "[\"" .. k .. "\"] = "
            else
                str = str .. k .. " = "
            end
        else
            str = str .. "[" .. tostring(k) .. "] = "
        end
        if type(v) == "table" then
            str = str .. serialize(v, indent .. "    ")
        elseif type(v) == "string" then
            str = str .. "\"" .. v .. "\""
        elseif type(v) == "number" then
            str = str .. tostring(v)
        elseif type(v) == "boolean" then
            str = str .. tostring(v)
        else
            str = str .. "nil"
        end
        str = str .. ",\n"
    end
    str = str .. indent .. "}"
    return str
end

-- Generar el código completo del sprite con los offsets actuales
local function generateSpriteCode()
    if not currentSprite then return end

    -- Obtener la ruta de la imagen (suponiendo que el sprite tiene un campo .image)
    local imagePath = ""
    if currentSprite.image then
        -- Intentar extraer la ruta de la imagen (puede ser un objeto Image)
        -- Esto depende de cómo se almacena; asumimos que graphics.imagePath devuelve la ruta usada
        -- Podríamos necesitar almacenar el nombre original al cargar.
        -- Por simplicidad, lo dejamos como un comentario.
        imagePath = "ruta/a/la/imagen"  -- Se reemplazará manualmente
    end

    local frameData = originalFrames or {}
    local animData = originalAnims or {}

    -- Construir la tabla de frames
    local framesString = serialize(frameData)

    -- Construir la tabla de animaciones con los offsets actualizados
    local animsString = "{\n"
    for _, name in ipairs(currentAnimList) do
        local anim = currentSprite.anims[name]
        animsString = animsString .. string.format('    ["%s"] = {start = %d, stop = %d, speed = %d, offsetX = %d, offsetY = %d},\n',
            name, anim.start or 0, anim.stop or 0, anim.speed or 24, anim.offsetX or 0, anim.offsetY or 0)
    end
    animsString = animsString .. "}"

    -- Generar el código completo
    local code = [[
-- Archivo generado automáticamente por Character Offset Debug
local img = love.graphics.newImage(graphics.imagePath("]] .. imagePath .. [["))
img:setFilter("]] .. (pixelFilter and "nearest" or "linear") .. [[", "]] .. (pixelFilter and "nearest" or "linear") .. [[")
return graphics.newSprite(
    img,
    ]] .. framesString .. [[,
    ]] .. animsString .. [[,
    "]] .. (currentSprite.defaultAnim or "idle") .. [[",
    true
)
]]
    return code
end

-- Función para actualizar la lista de entradas del directorio actual
local function updateBrowserEntries()
    local fullPath = BASE_PATH
    if browser.path ~= "" then
        fullPath = BASE_PATH .. "/" .. browser.path
    end
    local items = love.filesystem.getDirectoryItems(fullPath)
    browser.entries = {}
    for _, item in ipairs(items) do
        local info = love.filesystem.getInfo(fullPath .. "/" .. item)
        if info.type == "directory" then
            table.insert(browser.entries, { name = item, isDir = true })
        elseif item:match("%.lua$") then
            table.insert(browser.entries, { name = item, isDir = false })
        end
    end
    table.sort(browser.entries, function(a, b)
        if a.isDir and not b.isDir then return true end
        if not a.isDir and b.isDir then return false end
        return a.name < b.name
    end)
    browser.selection = 1
end

-- Función para cargar un sprite desde un archivo .lua y guardar sus datos originales
local function loadSpriteFromFile(filePath)
    local ok, chunk = pcall(love.filesystem.load, filePath)
    if not ok then
        print("Error al cargar " .. filePath .. ": " .. tostring(chunk))
        return nil
    end
    local ok2, sprite = pcall(chunk)
    if not ok2 or type(sprite) ~= "table" then
        print("Error al instanciar sprite desde " .. filePath .. ": " .. tostring(sprite))
        return nil
    end

    -- Intentar extraer las estructuras originales
    -- Se asume que el sprite tiene .frames (lista de tablas con x,y,w,h,offsetX,etc.) y .anims
    if sprite.frames then
        originalFrames = sprite.frames
    else
        -- Si no, intentar obtener de alguna otra forma (ej. .quads + .frameData)
        originalFrames = {}
        print("Advertencia: no se pudo obtener la lista de frames original")
    end

    if sprite.anims then
        originalAnims = {}
        for name, anim in pairs(sprite.anims) do
            originalAnims[name] = {
                start = anim.start,
                stop = anim.stop,
                speed = anim.speed,
                offsetX = anim.offsetX or 0,
                offsetY = anim.offsetY or 0
            }
        end
    end

    -- Posición y escala por defecto
    sprite.x = 0
    sprite.y = 0
    sprite.sizeX, sprite.sizeY = 0.7, 0.7
    return sprite
end

-- Función para cambiar al modo edición con un sprite
local function enterEditMode(sprite, path)
    currentSprite = sprite
    currentSpritePath = path

    -- Obtener lista de animaciones
    currentAnimList = {}
    if sprite.anims then
        for name, _ in pairs(sprite.anims) do
            table.insert(currentAnimList, name)
        end
        table.sort(currentAnimList)
    end

    if #currentAnimList > 0 then
        currentAnimIndex = 1
        currentAnim = currentAnimList[1]
        sprite:animate(currentAnim, false)
        local anim = sprite.anims[currentAnim]
        offsetX = anim.offsetX or 0
        offsetY = anim.offsetY or 0
    else
        currentAnim = ""
        offsetX, offsetY = 0, 0
    end

    browser.mode = "editing"
end

-- Función para volver al navegador
local function returnToBrowser()
    browser.mode = "browser"
    currentSprite = nil
    updateBrowserEntries()
end

function state:enter()
    graphics = require("modules.graphics")
    input = require("input")
    Timer = require("lib.timer")

    browser.path = ""
    browser.mode = "browser"
    updateBrowserEntries()

    graphics.fadeIn(0.3)
end

function state:update(dt)
    if browser.mode == "browser" then
        if #browser.entries > 0 then
            if input:pressed("up") then
                browser.selection = browser.selection - 1
                if browser.selection < 1 then
                    browser.selection = #browser.entries
                end
            elseif input:pressed("down") then
                browser.selection = browser.selection + 1
                if browser.selection > #browser.entries then
                    browser.selection = 1
                end
            elseif input:pressed("confirm") then
                local selected = browser.entries[browser.selection]
                local fullPath = BASE_PATH
                if browser.path ~= "" then
                    fullPath = fullPath .. "/" .. browser.path
                end
                fullPath = fullPath .. "/" .. selected.name

                if selected.isDir then
                    if browser.path == "" then
                        browser.path = selected.name
                    else
                        browser.path = browser.path .. "/" .. selected.name
                    end
                    updateBrowserEntries()
                else
                    local sprite = loadSpriteFromFile(fullPath)
                    if sprite then
                        enterEditMode(sprite, fullPath)
                    else
                        print("No se pudo cargar el sprite")
                    end
                end
            end
        end

        if input:pressed("back") then
            if browser.path == "" then
                graphics.fadeOut(0.3, function()
                    Gamestate.switch(require("states.debug-menu"))
                end)
            else
                local lastSlash = browser.path:find("/[^/]*$")
                if lastSlash then
                    browser.path = browser.path:sub(1, lastSlash - 1)
                else
                    browser.path = ""
                end
                updateBrowserEntries()
            end
        end

    elseif browser.mode == "editing" and currentSprite then
        currentSprite:update(dt)

        if input:pressed("prevAnim") then
            currentAnimIndex = currentAnimIndex - 1
            if currentAnimIndex < 1 then
                currentAnimIndex = #currentAnimList
            end
            currentAnim = currentAnimList[currentAnimIndex]
            currentSprite:animate(currentAnim, false)
            local anim = currentSprite.anims[currentAnim]
            offsetX = anim.offsetX or 0
            offsetY = anim.offsetY or 0
        elseif input:pressed("nextAnim") then
            currentAnimIndex = currentAnimIndex + 1
            if currentAnimIndex > #currentAnimList then
                currentAnimIndex = 1
            end
            currentAnim = currentAnimList[currentAnimIndex]
            currentSprite:animate(currentAnim, false)
            local anim = currentSprite.anims[currentAnim]
            offsetX = anim.offsetX or 0
            offsetY = anim.offsetY or 0
        end

        local step = 1
        if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
            step = 10
        end

        if input:pressed("up") then
            offsetY = offsetY - step
            currentSprite.anims[currentAnim].offsetY = offsetY
        elseif input:pressed("down") then
            offsetY = offsetY + step
            currentSprite.anims[currentAnim].offsetY = offsetY
        elseif input:pressed("left") then
            offsetX = offsetX - step
            currentSprite.anims[currentAnim].offsetX = offsetX
        elseif input:pressed("right") then
            offsetX = offsetX + step
            currentSprite.anims[currentAnim].offsetX = offsetX
        end

        -- Tecla P: alternar filtro de píxel
        if input:pressed("p") then
            pixelFilter = not pixelFilter
            local filter = pixelFilter and "nearest" or "linear"
            if currentSprite.image then
                currentSprite.image:setFilter(filter, filter)
            end
        end

        if input:pressed("r") then
            returnToBrowser()
        end

        -- F3: generar archivo completo en consola
        if input:pressed("f3") then
            local code = generateSpriteCode()
            print("=== ARCHIVO COMPLETO GENERADO ===")
            print(code)
        end

        if input:pressed("back") then
            graphics.fadeOut(0.3, function()
                Gamestate.switch(require("states.debug-menu"))
            end)
        end
    end
end

function state:wheelmoved(x, y)
    if browser.mode == "browser" then
        if y > 0 then
            browser.selection = browser.selection - 1
        elseif y < 0 then
            browser.selection = browser.selection + 1
        end
        if browser.selection < 1 then browser.selection = #browser.entries end
        if browser.selection > #browser.entries then browser.selection = 1 end
    elseif browser.mode == "editing" then
        zoom = zoom + y * 0.1
        if zoom < 0.1 then zoom = 0.1 end
        if zoom > 5 then zoom = 5 end
    end
end

function state:draw()
    love.graphics.clear(0.2, 0.2, 0.2)

    if browser.mode == "browser" then
        local fullPath = BASE_PATH
        if browser.path ~= "" then
            fullPath = fullPath .. "/" .. browser.path
        end
        love.graphics.setColor(1, 1, 0)
        love.graphics.print("Ruta: " .. fullPath, 10, 10)
        love.graphics.setColor(1, 1, 1)

        -- Mostrar solo una ventana de entradas
        local visible = 20  -- número de entradas visibles
        local start = math.max(1, browser.selection - math.floor(visible/2))
        local stop = math.min(#browser.entries, start + visible - 1)
        -- Ajustar start si stop llegó al final
        start = math.max(1, stop - visible + 1)

        for i = start, stop do
            local entry = browser.entries[i]
            local y = 30 + (i - start) * 20
            if i == browser.selection then
                love.graphics.setColor(1, 1, 0)
            elseif entry.isDir then
                love.graphics.setColor(1, 0, 1)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.print(entry.name .. (entry.isDir and "/" or ""), 20, y)
        end

        love.graphics.setColor(1, 1, 1)
        love.graphics.print("↑/↓/rueda: mover   Enter: abrir   Escape: atrás/salir", 10, graphics.getHeight() - 30)

    elseif browser.mode == "editing" and currentSprite then
        love.graphics.push()
            love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
            love.graphics.scale(zoom)
            currentSprite:draw()
        love.graphics.pop()

        love.graphics.setColor(1, 1, 1)
        love.graphics.print("=== CHARACTER OFFSET DEBUG ===", 10, 10)
        love.graphics.print("Archivo: " .. currentSpritePath, 10, 30)
        love.graphics.print("Animación: " .. currentAnim .. " (Q/E)", 10, 50)
        love.graphics.print("Offset X: " .. offsetX .. "  Offset Y: " .. offsetY, 10, 70)
        love.graphics.print("Flechas: ajustar | Shift + flecha: paso 10", 10, 90)
        love.graphics.print("P: alternar filtro de píxel (" .. (pixelFilter and "nearest" or "linear") .. ")", 10, 110)
        love.graphics.print("R: volver al navegador", 10, 130)
        love.graphics.print("F3: generar archivo completo en consola", 10, 150)
        love.graphics.print("Escape: salir al menú", 10, 170)
        love.graphics.print("Zoom: " .. string.format("%.1f", zoom) .. " (rueda)", 10, 190)
    end
end

function state:leave()
    -- Limpiar si es necesario
end

return state