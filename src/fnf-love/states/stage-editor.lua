-- stage-editor.lua
local state = {}
local graphics, input, Timer

-- Variables del editor
local layers = {}
local selectedLayer = 1
local camera = {x = 0, y = 0, zoom = 1}
local dragging = false          -- arrastre de cámara (botón derecho)
local dragStartX, dragStartY
local camStartX, camStartY

-- Arrastre de capa (botón izquierdo)
local draggingLayer = false
local layerDragStartX, layerDragStartY
local layerStartX, layerStartY

-- Marcas
local marks = {
    {name = "BF",    x = 0, y = 0, color = {0,1,0}},
    {name = "GF",    x = 0, y = 0, color = {1,0,1}},
    {name = "Enemy", x = 0, y = 0, color = {1,0,0}},
}
local selectedMark = nil
local editingMarkName = false

-- Modos
local mode = "layers"  -- "layers" o "marks"

-- ──────────────────────────────────────────────
-- BROWSER CON SISTEMA DE CARPETAS
-- ──────────────────────────────────────────────
-- browserMode: false | "resource" | "loadStage"
local browserMode = false

local browser = {
    -- Para modo "resource" (imágenes y sprites)
    -- Navegamos dos raíces: images/ y sprites/
    -- Usaremos un sistema unificado con tipo explícito de raíz
    root      = "",    -- raíz actual: "images" o "sprites" (solo para resource)
    path      = "",    -- sub-ruta relativa a la raíz (vacío = raíz)
    entries   = {},    -- {name, isDir, fullPath, type} 
    selection = 1,
}

-- Raíces disponibles para el modo "resource"
local ROOTS = {
    { label = "images/",  root = "images",  ftype = "image"  },
    { label = "sprites/", root = "sprites", ftype = "sprite" },
}
local rootSelectorActive = false   -- true cuando el usuario elige la raíz primero
local rootSelection = 1

-- Notificación
local notification = {text = "", timer = 0}

-- ──────────────────────────────────────────────
-- UTILIDADES DE TEXTO
-- ──────────────────────────────────────────────
-- Trunca un string para que quepa en maxWidth píxeles usando la fuente activa.
-- Si es más corto se devuelve tal cual; si es más largo se añade "…" al inicio.
local function truncateLeft(str, maxWidth)
    local font = love.graphics.getFont()
    if font:getWidth(str) <= maxWidth then return str end
    local ellipsis = "..."
    -- Recorta desde la izquierda hasta que quepa
    local s = str
    while #s > 0 and font:getWidth(ellipsis .. s) > maxWidth do
        s = s:sub(2)
    end
    return ellipsis .. s
end

-- ──────────────────────────────────────────────
-- FUNCIONES DEL BROWSER
-- ──────────────────────────────────────────────

-- Devuelve la ruta completa del directorio actual según la raíz y sub-ruta
local function browserFullPath()
    if browserMode == "loadStage" then
        return "stages"
    end
    -- resource
    local root = browser.root
    if browser.path ~= "" then
        return root .. "/" .. browser.path
    end
    return root
end

-- Rellena browser.entries con el contenido del directorio actual
local function updateBrowserEntries()
    browser.entries = {}
    browser.selection = 1

    if browserMode == "loadStage" then
        local dir = "stages"
        if love.filesystem.getInfo(dir) then
            for _, item in ipairs(love.filesystem.getDirectoryItems(dir)) do
                local info = love.filesystem.getInfo(dir .. "/" .. item)
                if info then
                    if info.type == "directory" then
                        table.insert(browser.entries, {name = item, isDir = true})
                    elseif item:match("%.lua$") then
                        local name = item:gsub("%.lua$", "")
                        table.insert(browser.entries, {name = name, isDir = false})
                    end
                end
            end
        end
        table.sort(browser.entries, function(a,b)
            if a.isDir ~= b.isDir then return a.isDir end
            return a.name < b.name
        end)
        return
    end

    -- resource: imágenes o sprites
    local fullDir = browserFullPath()
    local ftype = (browser.root == "sprites") and "sprite" or "image"
    local ext   = (browser.root == "sprites") and "%.lua$" or "%.png$"
    local extAlt = (browser.root == "images")  and "%.jpg$" or nil

    if love.filesystem.getInfo(fullDir) then
        for _, item in ipairs(love.filesystem.getDirectoryItems(fullDir)) do
            local itemPath = fullDir .. "/" .. item
            local info = love.filesystem.getInfo(itemPath)
            if info then
                if info.type == "directory" then
                    table.insert(browser.entries, {name = item, isDir = true, ftype = ftype})
                elseif item:match(ext) or (extAlt and item:match(extAlt)) then
                    local name = item:gsub("%.[^.]*$", "")
                    -- Ruta relativa a la raíz (sin extensión)
                    local relPath = (browser.path ~= "") and (browser.path .. "/" .. name) or name
                    table.insert(browser.entries, {
                        name     = item,
                        isDir    = false,
                        ftype    = ftype,
                        relPath  = relPath,
                    })
                end
            end
        end
    end

    table.sort(browser.entries, function(a,b)
        if a.isDir ~= b.isDir then return a.isDir end
        return a.name < b.name
    end)
end

-- Abre el browser en el modo dado
local function openBrowser(modeStr)
    browserMode = modeStr
    browser.path = ""
    browser.selection = 1

    if modeStr == "resource" then
        -- Primero mostrar selector de raíz
        rootSelectorActive = true
        rootSelection = 1
    else
        rootSelectorActive = false
        updateBrowserEntries()
    end
end

-- Sube un nivel en el browser
local function browserGoUp()
    local slash = browser.path:find("/[^/]*$")
    if slash then
        browser.path = browser.path:sub(1, slash - 1)
    else
        browser.path = ""
    end
    updateBrowserEntries()
end

-- ──────────────────────────────────────────────
-- CARGA DE ASSETS
-- ──────────────────────────────────────────────
local function loadLayerAsset(layer)
    -- Siempre limpiar ambos campos antes de cargar
    layer.image  = nil
    layer.sprite = nil

    if layer.type == "image" and layer.path ~= "" then
        local imgPath = graphics.imagePath(layer.path)
        if imgPath and love.filesystem.getInfo(imgPath) then
            local ok, img = pcall(love.graphics.newImage, imgPath)
            if ok and img then
                layer.image = graphics.newImage(img)
            else
                notification.text  = "Error cargando imagen: " .. layer.path
                notification.timer = 3
            end
        else
            -- Intentar buscar directamente en images/ con extensiones comunes
            local found = false
            for _, ext in ipairs({".png", ".jpg", ".jpeg"}) do
                local tryPath = "images/" .. layer.path .. ext
                if love.filesystem.getInfo(tryPath) then
                    local ok, img = pcall(love.graphics.newImage, tryPath)
                    if ok and img then
                        layer.image = graphics.newImage(img)
                        found = true
                        break
                    end
                end
            end
            if not found then
                notification.text  = "Imagen no encontrada: " .. layer.path
                notification.timer = 3
            end
        end
    elseif layer.type == "sprite" and layer.path ~= "" then
        local spritePath = "sprites/" .. layer.path .. ".lua"
        if love.filesystem.getInfo(spritePath) then
            local ok, sprite = pcall(love.filesystem.load, spritePath)
            if ok then
                local ok2, spriteObj = pcall(sprite)
                if ok2 and spriteObj then
                    layer.sprite = spriteObj
                    if layer.sprite.anims then
                        local animName = next(layer.sprite.anims)
                        if animName then layer.sprite:animate(animName, true) end
                    end
                else
                    notification.text  = "Error ejecutando sprite: " .. layer.path
                    notification.timer = 3
                end
            else
                notification.text  = "Error cargando sprite: " .. layer.path
                notification.timer = 3
            end
        else
            notification.text  = "Sprite no encontrado: " .. layer.path
            notification.timer = 3
        end
    end
end

-- ──────────────────────────────────────────────
-- CAPAS
-- ──────────────────────────────────────────────
local function addLayer()
    table.insert(layers, {
        type    = "image",
        path    = "",
        x = 0, y = 0,
        scrollX = 1, scrollY = 1,
        scaleX  = 1, scaleY  = 1,
        visible = true
    })
    selectedLayer = #layers
    notification.text  = "Capa añadida"
    notification.timer = 1
end

local function drawLayer(layer)
    if not layer.visible then return end
    local obj = layer.image or layer.sprite
    if not obj then return end
    local scrollX = layer.scrollX or 1
    local scrollY = layer.scrollY or 1
    love.graphics.push()
        love.graphics.translate(graphics.getWidth()/2, graphics.getHeight()/2)
        love.graphics.scale(camera.zoom, camera.zoom)
        love.graphics.translate(-graphics.getWidth()/2 + camera.x * scrollX, -graphics.getHeight()/2 + camera.y * scrollY)
        obj.x = layer.x
        obj.y = layer.y
        if layer.scaleX then obj.sizeX, obj.sizeY = layer.scaleX, layer.scaleY end
        obj:draw()
    love.graphics.pop()
end

-- ──────────────────────────────────────────────
-- GRID / MARCAS
-- ──────────────────────────────────────────────
local function drawGrid()
    local w, h = graphics.getWidth(), graphics.getHeight()
    local step = 50
    love.graphics.setColor(0.4, 0.4, 0.4, 0.3)
    love.graphics.setLineWidth(1)
    love.graphics.push()
        love.graphics.translate(w/2, h/2)
        love.graphics.scale(camera.zoom, camera.zoom)
        love.graphics.translate(-w/2 + camera.x, -h/2 + camera.y)
        for x = -w, w, step do love.graphics.line(x, -h, x, h) end
        for y = -h, h, step do love.graphics.line(-w, y, w, y) end
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.line(-w, 0, w, 0)
        love.graphics.line(0, -h, 0, h)
    love.graphics.pop()
    love.graphics.setColor(1,1,1)
end

local function drawMarks()
    love.graphics.push()
        love.graphics.translate(graphics.getWidth()/2, graphics.getHeight()/2)
        love.graphics.scale(camera.zoom, camera.zoom)
        love.graphics.translate(-graphics.getWidth()/2 + camera.x, -graphics.getHeight()/2 + camera.y)
        for i, mark in ipairs(marks) do
            love.graphics.setColor(mark.color[1], mark.color[2], mark.color[3], 1)
            love.graphics.circle("fill", mark.x, mark.y, 10)
            love.graphics.setColor(1,1,1)
            love.graphics.print(mark.name, mark.x + 15, mark.y - 10)
        end
        if selectedMark then
            local m = marks[selectedMark]
            love.graphics.setColor(1,1,0)
            love.graphics.circle("line", m.x, m.y, 15)
        end
    love.graphics.pop()
end

-- ──────────────────────────────────────────────
-- GUARDAR / CARGAR STAGE
-- ──────────────────────────────────────────────
local function serialize(t, indent)
    indent = indent or ""
    local nextIndent = indent .. "    "

    -- Detectar si es una tabla secuencial (array)
    local isArray = true
    local maxN = 0
    for k, _ in pairs(t) do
        if type(k) == "number" and k == math.floor(k) and k >= 1 then
            if k > maxN then maxN = k end
        else
            isArray = false
            break
        end
    end
    -- Verificar que no hay huecos
    if isArray and maxN > 0 then
        for i = 1, maxN do
            if t[i] == nil then isArray = false; break end
        end
    end
    if maxN == 0 then isArray = false end

    local str = "{\n"

    if isArray then
        -- Serializar como array ordenado (sin claves explícitas)
        for i = 1, maxN do
            local v = t[i]
            str = str .. nextIndent
            if     type(v) == "table"   then str = str .. serialize(v, nextIndent)
            elseif type(v) == "string"  then str = str .. "\"" .. v .. "\""
            elseif type(v) == "number"  then str = str .. tostring(v)
            elseif type(v) == "boolean" then str = str .. tostring(v)
            else                             str = str .. "nil"
            end
            str = str .. ",\n"
        end
    else
        -- Serializar como diccionario
        -- Primero recopilar claves string ordenadas
        local keys = {}
        for k, _ in pairs(t) do
            table.insert(keys, k)
        end
        table.sort(keys, function(a, b)
            if type(a) == type(b) then return tostring(a) < tostring(b) end
            return type(a) < type(b)
        end)

        for _, k in ipairs(keys) do
            local v = t[k]
            str = str .. nextIndent
            if type(k) == "string" then
                str = str .. (k:match("[^a-zA-Z0-9_]") and ("[\"" .. k .. "\"] = ") or (k .. " = "))
            else
                str = str .. "[" .. tostring(k) .. "] = "
            end
            if     type(v) == "table"   then str = str .. serialize(v, nextIndent)
            elseif type(v) == "string"  then str = str .. "\"" .. v .. "\""
            elseif type(v) == "number"  then str = str .. tostring(v)
            elseif type(v) == "boolean" then str = str .. tostring(v)
            else                             str = str .. "nil"
            end
            str = str .. ",\n"
        end
    end

    return str .. indent .. "}"
end

local function saveStage()
    if #layers == 0 then
        notification.text  = "No hay capas"
        notification.timer = 2
        return
    end
    local name      = "stage_" .. os.time()
    local stageData = { layers = {}, marks = {} }

    -- Copiar marks limpiamente (solo datos serializables)
    for _, m in ipairs(marks) do
        table.insert(stageData.marks, {
            name  = m.name or "Mark",
            x     = m.x or 0,
            y     = m.y or 0,
            color = {m.color[1] or 1, m.color[2] or 1, m.color[3] or 0},
        })
    end

    for _, l in ipairs(layers) do
        table.insert(stageData.layers, {
            type    = l.type    or "image",
            path    = l.path    or "",
            x       = l.x       or 0,
            y       = l.y       or 0,
            scrollX = l.scrollX or 1,  scrollY = l.scrollY or 1,
            scaleX  = l.scaleX  or 1,  scaleY  = l.scaleY  or 1,
            visible = (l.visible ~= false),
        })
    end

    -- Forzar creación de stages/ en el save directory
    local dirOk = love.filesystem.createDirectory("stages")
    print("[STAGE-EDITOR] createDirectory('stages'): " .. tostring(dirOk))

    local filename = "stages/" .. name .. ".lua"
    local ok, serialized = pcall(serialize, stageData)
    if not ok then
        notification.text  = "Error al serializar: " .. tostring(serialized)
        notification.timer = 3
        return
    end

    local content = "return " .. serialized
    print("[STAGE-EDITOR] Guardando en: " .. filename)
    print("[STAGE-EDITOR] Save directory: " .. tostring(love.filesystem.getSaveDirectory()))
    print("[STAGE-EDITOR] Content length: " .. #content)
    local success, writeErr = love.filesystem.write(filename, content)
    if success then
        print("[STAGE-EDITOR] Guardado OK: " .. filename)
        notification.text  = "Guardado en " .. filename
        notification.timer = 3
    else
        print("[STAGE-EDITOR] ERROR al guardar: " .. tostring(writeErr))
        print("[STAGE-EDITOR] Contenido (primeros 200 chars): " .. content:sub(1, 200))
        notification.text  = "Error al guardar: " .. tostring(writeErr)
        notification.timer = 5
    end
end

local function loadStage(name)
    local chunk, err = love.filesystem.load("stages/" .. name .. ".lua")
    if not chunk then
        notification.text  = "Error al cargar: " .. tostring(err)
        notification.timer = 3
        return false
    end
    local ok, loadedStage = pcall(chunk)
    if ok and loadedStage then
        layers = {}
        if loadedStage.layers then
            for _, ld in ipairs(loadedStage.layers) do
                local nl = {
                    type    = ld.type,
                    path    = ld.path    or "",
                    x       = ld.x,      y       = ld.y,
                    scrollX = ld.scrollX, scrollY = ld.scrollY,
                    scaleX  = ld.scaleX,  scaleY  = ld.scaleY,
                    visible = ld.visible,
                }
                loadLayerAsset(nl)
                table.insert(layers, nl)
            end
        end
        marks = loadedStage.marks or {
            {name="BF",x=0,y=0,color={0,1,0}},
            {name="GF",x=0,y=0,color={1,0,1}},
            {name="Enemy",x=0,y=0,color={1,0,0}},
        }
        selectedLayer = 1
        selectedMark  = nil
        camera = {x=0,y=0,zoom=1}
        notification.text  = "Stage cargado: " .. name
        notification.timer = 2
        return true
    else
        notification.text  = "Error al cargar: " .. tostring(loadedStage)
        notification.timer = 3
        return false
    end
end

-- ──────────────────────────────────────────────
-- ENTER
-- ──────────────────────────────────────────────
function state:enter(prev)
    graphics = require("modules.graphics")
    input    = require("input")
    Timer    = require("lib.timer")

    layers      = {}
    addLayer()
    selectedLayer = 1
    camera        = {x=0, y=0, zoom=1}
    mode          = "layers"
    browserMode   = false
    dragging      = false
    draggingLayer = false
    notification  = {text="", timer=0}
    marks = {
        {name="BF",    x=0, y=0, color={0,1,0}},
        {name="GF",    x=0, y=0, color={1,0,1}},
        {name="Enemy", x=0, y=0, color={1,0,0}},
    }
    selectedMark = nil
    graphics.fadeIn(0.5)
end

-- ──────────────────────────────────────────────
-- UPDATE
-- ──────────────────────────────────────────────
function state:update(dt)
    if notification.timer > 0 then notification.timer = notification.timer - dt end

    if browserMode then
        -- ── Selector de raíz (solo en modo resource) ──
        if rootSelectorActive then
            if input:pressed("up") then
                rootSelection = rootSelection - 1
                if rootSelection < 1 then rootSelection = #ROOTS end
            elseif input:pressed("down") then
                rootSelection = rootSelection + 1
                if rootSelection > #ROOTS then rootSelection = 1 end
            elseif input:pressed("confirm") then
                local r = ROOTS[rootSelection]
                browser.root = r.root
                browser.path = ""
                rootSelectorActive = false
                updateBrowserEntries()
            elseif input:pressed("back") then
                browserMode = false
                rootSelectorActive = false
            end
            return
        end

        -- ── Navegación dentro del browser ──
        local n = #browser.entries
        if n > 0 then
            -- Paso normal vs rápido (Shift)
            local step = 1
            if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
                step = 5
            end

            if input:pressed("up") then
                browser.selection = browser.selection - step
                if browser.selection < 1 then browser.selection = n end
            elseif input:pressed("down") then
                browser.selection = browser.selection + step
                if browser.selection > n then browser.selection = n end
            elseif input:pressed("pageup") then
                browser.selection = math.max(1, browser.selection - 10)
            elseif input:pressed("pagedown") then
                browser.selection = math.min(n, browser.selection + 10)
            elseif input:pressed("confirm") then
                local sel = browser.entries[browser.selection]
                if sel.isDir then
                    -- Entrar en carpeta
                    browser.path = (browser.path ~= "") and (browser.path .. "/" .. sel.name) or sel.name
                    updateBrowserEntries()
                else
                    -- Seleccionar archivo
                    if browserMode == "resource" then
                        local layer  = layers[selectedLayer]
                        -- Limpiar asset anterior antes de asignar nuevo
                        layer.image  = nil
                        layer.sprite = nil
                        layer.type   = sel.ftype
                        layer.path   = sel.relPath
                        loadLayerAsset(layer)
                        if layer.image or layer.sprite then
                            notification.text  = "Asignado: " .. sel.relPath
                        else
                            notification.text  = "Asignado (sin preview): " .. sel.relPath
                        end
                        notification.timer = 2
                        browserMode = false
                    elseif browserMode == "loadStage" then
                        -- sub-ruta dentro de stages (el nombre ya tiene la ruta relativa)
                        local stageName = (browser.path ~= "")
                            and (browser.path .. "/" .. sel.name)
                            or sel.name
                        loadStage(stageName)
                        browserMode = false
                    end
                end
            end
        end

        -- Escape / back: subir carpeta o salir del browser
        if input:pressed("back") then
            if browser.path ~= "" then
                browserGoUp()
            else
                browserMode = false
            end
        end

    else
        -- ── Modo edición normal ──
        local moveStep = 10
        if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then moveStep = 50 end

        if input:pressed("up")    then camera.y = camera.y - moveStep end
        if input:pressed("down")  then camera.y = camera.y + moveStep end
        if input:pressed("left")  then camera.x = camera.x - moveStep end
        if input:pressed("right") then camera.x = camera.x + moveStep end

        if input:pressed("tab") then
            mode = (mode == "layers") and "marks" or "layers"
            notification.text  = "Modo: " .. mode
            notification.timer = 1
        end

        if mode == "layers" then
            if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
                if input:pressed("up")    then layers[selectedLayer].y = layers[selectedLayer].y - 1 end
                if input:pressed("down")  then layers[selectedLayer].y = layers[selectedLayer].y + 1 end
                if input:pressed("left")  then layers[selectedLayer].x = layers[selectedLayer].x - 1 end
                if input:pressed("right") then layers[selectedLayer].x = layers[selectedLayer].x + 1 end
            end

            if input:pressed("pageup") then
                if selectedLayer > 1 then
                    layers[selectedLayer], layers[selectedLayer-1] = layers[selectedLayer-1], layers[selectedLayer]
                    selectedLayer = selectedLayer - 1
                    notification.text = "Capa subida"; notification.timer = 1
                end
            elseif input:pressed("pagedown") then
                if selectedLayer < #layers then
                    layers[selectedLayer], layers[selectedLayer+1] = layers[selectedLayer+1], layers[selectedLayer]
                    selectedLayer = selectedLayer + 1
                    notification.text = "Capa bajada"; notification.timer = 1
                end
            end

            if input:pressed("a") then addLayer() end
            if input:pressed("delete") and #layers > 0 then
                table.remove(layers, selectedLayer)
                if selectedLayer > #layers then selectedLayer = #layers end
                if #layers == 0 then addLayer() end
                notification.text = "Capa eliminada"; notification.timer = 1
            end
            if input:pressed("q") then selectedLayer = math.max(1, selectedLayer - 1) end
            if input:pressed("e") then selectedLayer = math.min(#layers, selectedLayer + 1) end
            if input:pressed("t") then
                local l = layers[selectedLayer]
                l.type = (l.type == "image") and "sprite" or "image"
                l.path = ""; l.image = nil; l.sprite = nil
                notification.text = "Tipo: " .. l.type; notification.timer = 1
            end
            if input:pressed("v") then
                layers[selectedLayer].visible = not layers[selectedLayer].visible
            end
            if input:pressed("plus") then
                local l = layers[selectedLayer]
                l.scaleX = (l.scaleX or 1) + 0.1
                l.scaleY = (l.scaleY or 1) + 0.1
                local obj = l.image or l.sprite
                if obj then obj.sizeX, obj.sizeY = l.scaleX, l.scaleY end
                notification.text = "Escala: " .. string.format("%.2f", l.scaleX); notification.timer = 1
            elseif input:pressed("minus") then
                local l = layers[selectedLayer]
                l.scaleX = math.max(0.1, (l.scaleX or 1) - 0.1)
                l.scaleY = math.max(0.1, (l.scaleY or 1) - 0.1)
                local obj = l.image or l.sprite
                if obj then obj.sizeX, obj.sizeY = l.scaleX, l.scaleY end
                notification.text = "Escala: " .. string.format("%.2f", l.scaleX); notification.timer = 1
            end

        elseif mode == "marks" then
            if input:pressed("q") then
                selectedMark = selectedMark and math.max(1, selectedMark - 1) or 1
            elseif input:pressed("e") then
                selectedMark = selectedMark and math.min(#marks, selectedMark + 1) or 1
            end
            if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
                if selectedMark then
                    if input:pressed("up")    then marks[selectedMark].y = marks[selectedMark].y - 1 end
                    if input:pressed("down")  then marks[selectedMark].y = marks[selectedMark].y + 1 end
                    if input:pressed("left")  then marks[selectedMark].x = marks[selectedMark].x - 1 end
                    if input:pressed("right") then marks[selectedMark].x = marks[selectedMark].x + 1 end
                end
            end
            if input:pressed("a") then
                table.insert(marks, {name="Mark"..(#marks+1), x=camera.x, y=camera.y, color={1,1,0}})
                selectedMark = #marks
                notification.text = "Marca añadida"; notification.timer = 1
            end
            if input:pressed("delete") and selectedMark then
                if selectedMark > 3 then
                    table.remove(marks, selectedMark)
                    if selectedMark > #marks then selectedMark = #marks end
                    if selectedMark < 1 then selectedMark = nil end
                    notification.text = "Marca eliminada"; notification.timer = 1
                else
                    notification.text = "No se puede eliminar marca de personaje"; notification.timer = 1
                end
            end
            if input:pressed("n") and selectedMark then
                marks[selectedMark].name = marks[selectedMark].name .. "*"
            end
        end

        -- Acciones globales
        if input:pressed("s") then saveStage() end
        if input:pressed("l") then openBrowser("loadStage") end
        if input:pressed("r") then openBrowser("resource") end
    end
end

-- ──────────────────────────────────────────────
-- RUEDA DEL MOUSE
-- ──────────────────────────────────────────────
function state:wheelmoved(x, y)
    if browserMode then
        if rootSelectorActive then return end
        local step = (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) and 5 or 1
        browser.selection = browser.selection - (y > 0 and step or -step)
        local n = #browser.entries
        if browser.selection < 1 then browser.selection = n end
        if browser.selection > n then browser.selection = 1 end
    else
        camera.zoom = math.max(0.1, math.min(5, camera.zoom + y * 0.1))
    end
end

-- ──────────────────────────────────────────────
-- MOUSE
-- ──────────────────────────────────────────────
function state:mousepressed(x, y, button)
    if browserMode then return end
    if button == 2 then
        dragging = true
        dragStartX, dragStartY = x, y
        camStartX,  camStartY  = camera.x, camera.y
    elseif button == 1 then
        if mode == "marks" then
            local mx = (x - graphics.getWidth()/2)  / camera.zoom + graphics.getWidth()/2  - camera.x
            local my = (y - graphics.getHeight()/2) / camera.zoom + graphics.getHeight()/2 - camera.y
            local minDist, newSel = 20, nil
            for i, mark in ipairs(marks) do
                local d = math.sqrt((mark.x-mx)^2 + (mark.y-my)^2)
                if d < minDist then minDist = d; newSel = i end
            end
            selectedMark = newSel
        elseif mode == "layers" and not love.keyboard.isDown("lctrl") then
            draggingLayer = true
            layerDragStartX, layerDragStartY = x, y
            local l = layers[selectedLayer]
            layerStartX, layerStartY = l.x, l.y
        end
    end
end

function state:mousereleased(x, y, button)
    if button == 2 then dragging      = false end
    if button == 1 then draggingLayer = false end
end

function state:mousemoved(x, y, dx, dy)
    if dragging then
        camera.x = camStartX + (dragStartX - x) / camera.zoom
        camera.y = camStartY + (dragStartY - y) / camera.zoom
    elseif draggingLayer then
        layers[selectedLayer].x = layerStartX + (x - layerDragStartX) / camera.zoom
        layers[selectedLayer].y = layerStartY + (y - layerDragStartY) / camera.zoom
    end
end

-- ──────────────────────────────────────────────
-- DRAW
-- ──────────────────────────────────────────────
function state:draw()
    love.graphics.clear(0.2, 0.2, 0.2)

    if browserMode then
        local W, H = graphics.getWidth(), graphics.getHeight()

        -- ── Selector de raíz ──
        if rootSelectorActive then
            love.graphics.setColor(1,1,0)
            love.graphics.print("SELECCIONAR TIPO DE RECURSO", 50, 30)
            for i, r in ipairs(ROOTS) do
                if i == rootSelection then
                    love.graphics.setColor(1,1,0)
                    love.graphics.rectangle("fill", 48, 65 + i*28 - 2, 220, 22)
                    love.graphics.setColor(0,0,0)
                else
                    love.graphics.setColor(1,1,1)
                end
                love.graphics.print(r.label, 55, 65 + i*28)
            end
            love.graphics.setColor(1,1,1)
            love.graphics.print("↑/↓: elegir  Enter: confirmar  Escape: cancelar", 50, H-40)
            return
        end

        -- ── Cabecera ──
        local title = browserMode == "loadStage" and "CARGAR STAGE" or "SELECCIONAR RECURSO"
        local rootLabel = browserMode == "resource" and (" [" .. browser.root .. "]") or ""
        local pathLabel = browser.path ~= "" and ("  /  " .. browser.path) or ""
        love.graphics.setColor(1,1,0)
        love.graphics.print(title .. rootLabel, 10, 8)
        love.graphics.setColor(0.8, 0.8, 1)
        love.graphics.print("Ruta: " .. browserFullPath() .. pathLabel, 10, 26)

        -- Indicador de carpeta superior (si no estamos en la raíz)
        local listTop = 50
        if browser.path ~= "" then
            love.graphics.setColor(0.6, 0.6, 1)
            love.graphics.print("  ../  (Escape para subir)", 20, listTop)
            listTop = listTop + 20
        end

        -- ── Lista de entradas ──
        if #browser.entries == 0 then
            love.graphics.setColor(1, 0.4, 0.4)
            love.graphics.print("(carpeta vacía)", 30, listTop + 10)
        else
            local rowH    = 22
            local visible = math.floor((H - listTop - 50) / rowH)
            local n       = #browser.entries
            local start   = math.max(1, browser.selection - math.floor(visible/2))
            local stop    = math.min(n, start + visible - 1)
            start         = math.max(1, stop - visible + 1)

            for i = start, stop do
                local entry = browser.entries[i]
                local yy    = listTop + (i - start) * rowH
                local isSelected = (i == browser.selection)

                -- Fondo de selección
                if isSelected then
                    love.graphics.setColor(0.2, 0.4, 0.8, 0.7)
                    love.graphics.rectangle("fill", 10, yy - 1, W - 20, rowH)
                end

                -- Color del texto
                if isSelected then
                    love.graphics.setColor(1, 1, 1)
                elseif entry.isDir then
                    love.graphics.setColor(1, 0.8, 0.2)   -- carpetas: naranja
                else
                    love.graphics.setColor(0.9, 0.9, 0.9) -- archivos: blanco suave
                end

                local label = entry.isDir and (" 📁 " .. entry.name .. "/") or ("   " .. entry.name)
                love.graphics.print(label, 15, yy + 2)

                -- Contador (X / total) en el lado derecho para la selección actual
                if isSelected then
                    love.graphics.setColor(0.7, 0.7, 0.7)
                    local counter = i .. " / " .. n
                    love.graphics.print(counter, W - 70, yy + 2)
                end
            end

            -- Scrollbar indicativo
            if n > visible then
                local sbH    = H - listTop - 50
                local ratio  = visible / n
                local pos    = (browser.selection - 1) / (n - 1)
                local barH   = math.max(20, sbH * ratio)
                local barY   = listTop + pos * (sbH - barH)
                love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
                love.graphics.rectangle("fill", W - 8, listTop, 6, sbH)
                love.graphics.setColor(0.8, 0.8, 1, 0.8)
                love.graphics.rectangle("fill", W - 8, barY, 6, barH)
            end
        end

        -- ── Ayuda en el pie ──
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.print("↑/↓: mover  Shift+↑/↓: x5  PgUp/Dn: x10  Rueda: scroll  Enter: abrir  Escape: atrás/salir", 10, H - 28)

    else
        -- ── Vista normal ──
        drawGrid()
        for i, layer in ipairs(layers) do drawLayer(layer) end
        drawMarks()

        -- Rectángulo de selección
        if mode == "layers" and #layers > 0 then
            local l   = layers[selectedLayer]
            local obj = l.image or l.sprite
            if obj then
                love.graphics.push()
                    love.graphics.translate(graphics.getWidth()/2, graphics.getHeight()/2)
                    love.graphics.scale(camera.zoom, camera.zoom)
                    love.graphics.translate(-graphics.getWidth()/2 + camera.x, -graphics.getHeight()/2 + camera.y)
                    love.graphics.setColor(1,1,0); love.graphics.setLineWidth(2)
                    local w, h = 100, 100
                    if l.image and l.image.texture then
                        w = l.image.texture:getWidth()  * (l.scaleX or 1)
                        h = l.image.texture:getHeight() * (l.scaleY or 1)
                    end
                    love.graphics.rectangle("line", l.x - w/2, l.y - h/2, w, h)
                love.graphics.pop()
            end
        end

        -- ── Panel de propiedades ──
        local panelX = graphics.getWidth() - 320
        local panelW = 320
        love.graphics.setColor(0,0,0,0.75)
        love.graphics.rectangle("fill", panelX, 0, panelW, graphics.getHeight())
        love.graphics.setColor(1,1,1)

        local px = panelX + 10   -- margen interno izquierdo
        local maxTextW = panelW - 20  -- ancho máximo para textos

        love.graphics.print("PROPIEDADES — " .. mode .. " (Tab)", px, 10)

        if mode == "layers" and #layers > 0 then
            local l = layers[selectedLayer]
            local y = 38

            love.graphics.setColor(1,1,1)
            love.graphics.print("Capa: " .. selectedLayer .. "/" .. #layers, px, y); y = y + 20
            love.graphics.print("Tipo: " .. l.type .. " (T)", px, y); y = y + 20

            -- ── NOMBRE DE ARCHIVO: siempre visible ──
            local pathDisplay = l.path ~= "" and l.path or "(sin archivo)"
            local truncated   = truncateLeft(pathDisplay, maxTextW - 6)
            love.graphics.setColor(1, 1, 0.4)   -- amarillo suave para destacarlo
            love.graphics.print("Archivo:", px, y); y = y + 18
            love.graphics.setColor(0.9, 0.9, 1)
            love.graphics.print(truncated, px + 6, y); y = y + 18
            love.graphics.setColor(0.6, 0.8, 1)
            love.graphics.print("  [R] cambiar recurso", px, y); y = y + 20

            love.graphics.setColor(1,1,1)
            love.graphics.print("Pos X: " .. math.floor(l.x) .. "  Y: " .. math.floor(l.y), px, y); y = y + 20
            love.graphics.print("  (Ctrl+flechas / arrastrar)", px, y); y = y + 20
            love.graphics.print("Scroll X: " .. (l.scrollX or 1), px, y); y = y + 20
            love.graphics.print("Scroll Y: " .. (l.scrollY or 1), px, y); y = y + 20
            love.graphics.print("Scale X: "  .. string.format("%.2f", l.scaleX or 1), px, y); y = y + 20
            love.graphics.print("Scale Y: "  .. string.format("%.2f", l.scaleY or 1), px, y); y = y + 20
            love.graphics.print("Visible: " .. tostring(l.visible) .. " (V)", px, y); y = y + 20
            love.graphics.print("Orden: PgUp subir, PgDn bajar", px, y); y = y + 20

        elseif mode == "marks" then
            local y = 38
            love.graphics.print("Marcas:", px, y); y = y + 20
            for i, mark in ipairs(marks) do
                local line = i .. ": " .. mark.name .. " (" .. math.floor(mark.x) .. "," .. math.floor(mark.y) .. ")"
                love.graphics.setColor(i == selectedMark and {1,1,0} or {1,1,1})
                love.graphics.print(line, px, y); y = y + 16
            end
            love.graphics.setColor(1,1,1)
            love.graphics.print("Q/E: seleccionar", px, y); y = y + 20
            love.graphics.print("Ctrl+flechas: mover", px, y); y = y + 20
            love.graphics.print("A: nueva | N: renombrar", px, y); y = y + 20
            love.graphics.print("Supr: eliminar (*)", px, y)
        end

        -- ── Ayuda general ──
        local helpY = graphics.getHeight() - 100
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.print("A: capa | Supr: eliminar | S: guardar | L: cargar", 10, helpY); helpY = helpY + 18
        love.graphics.print("R: recurso (carpetas) | Tab: modo | PgUp/Dn: orden", 10, helpY); helpY = helpY + 18
        love.graphics.print("Flechas: cámara (Shift x5) | Ctrl+flechas: mover capa", 10, helpY); helpY = helpY + 18
        love.graphics.print("Click der: arrastrar cam | Rueda: zoom", 10, helpY)

        -- ── Notificación ──
        if notification.timer > 0 then
            love.graphics.setColor(1, 1, 0, math.min(1, notification.timer))
            love.graphics.print(notification.text, graphics.getWidth()/2 - 150, graphics.getHeight()/2 - 10)
        end
    end
end

function state:leave() end

return state