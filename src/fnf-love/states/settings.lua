-- states/settings.lua (menú de opciones) con scroll, overlay, fondo dinámico y checkboxes
local settings = require("settings")
local ini = require("ini")
local atlasText = require("modules.atlas_text")
local checkboxThingie = require("sprites.checkboxThingie")  -- ahora es una función constructora

-- Cargar sonidos
local selectSound = love.audio.newSource("sounds/menu/select.ogg", "static")

-- Duración de la animación de selección del checkbox (11 frames a 24 fps)
local SELECT_ANIM_DURATION = 11/24

-- Variables de estado
local selection = 1
-- Función para construir la lista de opciones según la plataforma
local function getOptionsList()
    local list = {
        {name = "Volume", value = settings.volume, type = "range", min = 0, max = 1, step = 0.1},
        {name = "Downscroll", value = settings.downscroll, type = "boolean"},
        {name = "Ghost Tapping", value = settings.ghostTapping, type = "boolean"}
    }

    -- Si NO estamos en Nintendo Switch, añadimos las opciones de teclado y ventana
    if love.system.getOS() ~= "NX" then
        table.insert(list, {name = "DFJK (use DFJK keys)", value = settings.dfjk, type = "boolean"})
        table.insert(list, {name = "Fullscreen", value = love.window.getFullscreen(), type = "boolean"})
    end

    -- Añadimos las opciones restantes para ambas plataformas
    table.insert(list, {name = "Show Debug", value = settings.showDebug, type = "choice", choices = {false, "fps", "detailed"}})
    table.insert(list, {name = "Timebar Mode", value = settings.timebarMode, type = "choice", choices = {"elapsed", "remaining", "songname", "none"}})

    return list
end

local options = getOptionsList()

local titleText, backgroundImage
local optionTexts = {}      -- textos de las opciones (sin el valor)
local checkboxes = {}       -- sprites de checkbox para opciones booleanas

-- Variables para el scroll
local listTop, itemHeight, visibleCount, scrollOffset, currentShift

-- Variables para el color dinámico del fondo
local currentColor = {1, 1, 1}
local targetColor = {1, 1, 1}
local colorLerpSpeed = 0.02
local colorChangeTimer = 0
local colorChangeInterval = 5

-- Recalcular bounding box de un objeto atlasText
local function recalcBbox(textObj)
    local minX, maxX = math.huge, -math.huge
    local minY, maxY = math.huge, -math.huge
    for _, letter in ipairs(textObj.letters) do
        local right = letter.x + (letter.width or 0)
        local bottom = letter.y + (letter.height or 24)
        if letter.x < minX then minX = letter.x end
        if right > maxX then maxX = right end
        if letter.y < minY then minY = letter.y end
        if bottom > maxY then maxY = bottom end
    end
    textObj.bbox = {x = minX, y = minY, w = maxX - minX, h = maxY - minY}
end

-- Crear texto centrado con atlasText (solo el nombre de la opción)
local function createCenteredText(y, text, style)
    local textObj = atlasText.new(0, y, text, style)
    local maxX = 0
    local minX = math.huge
    for _, letter in ipairs(textObj.letters) do
        local right = letter.x + (letter.width or 0)
        if right > maxX then maxX = right end
        if letter.x < minX then minX = letter.x end
    end
    -- REEMPLAZO: Usar 1280 en lugar de love.graphics.getWidth()
    local offsetX = (1280 - maxX) / 2
    for _, letter in ipairs(textObj.letters) do
        letter.x = letter.x + offsetX
    end
    recalcBbox(textObj)
    return textObj
end

-- Actualizar el checkbox de una opción booleana (sin animación instantánea)
local function updateCheckboxState(index, value)
    local cb = checkboxes[index]
    if cb then
        if value then
            cb:animate("Check Box Selected Static", false)  -- estado ON
        else
            cb:animate("Check Box unselected", false)       -- estado OFF
        end
    end
end

-- Reajustar layout al cambiar tamaño de pantalla
local function relayout()
    -- REEMPLAZO: Usar 720
    listTop = 720 * 0.347
    itemHeight = 720 * 0.111
    local bottomMargin = 100
    visibleCount = math.floor((720 - listTop - bottomMargin) / itemHeight) + 1
    visibleCount = math.min(visibleCount, #options)

    -- Limpiar tablas anteriores
    optionTexts = {}
    checkboxes = {}

    for i, opt in ipairs(options) do
        local y = listTop + (i - 1) * itemHeight + currentShift

        -- Texto: solo el nombre (sin el valor)
        local fullText = opt.name
        if opt.type == "range" then
            fullText = opt.name .. ": " .. string.format("%.1f", opt.value)
        elseif opt.type == "choice" then
            fullText = opt.name .. ": " .. tostring(opt.value)
        end
        -- Para booleanos, el texto es solo el nombre
        local textObj = createCenteredText(y, (opt.type == "boolean") and opt.name or fullText, "regular")
        optionTexts[i] = textObj

        -- Si es booleano, crear checkbox
        if opt.type == "boolean" then
            local cb = checkboxThingie()
            local bbox = textObj.bbox
            if bbox then
                cb.x = bbox.x + bbox.w + 80
                cb.y = bbox.y + bbox.h / 2 - 10
            else
                -- REEMPLAZO: Usar 1280
                cb.x = 1280 / 2 + 100
                cb.y = y
            end
            cb.originX = 0.5
            cb.originY = 0.5
            cb.sizeX = 0.7
            cb.sizeY = 0.7

            -- Forzar la animación correcta desde el inicio
            if opt.value then
                cb:animate("Check Box Selected Static", true)
            else
                cb:animate("Check Box unselected", true)
            end
            if cb.update then cb:update(0) end

            checkboxes[i] = cb
        end
    end

    if titleText then
        -- REEMPLAZO: Usar 720
        local y = 720 * 0.139
        titleText = createCenteredText(y, "Options", "bold")
    end
end

-- Cambiar el valor de una opción booleana con animación
local function setBooleanWithAnimation(index, newValue)
    local opt = options[index]
    if opt.type ~= "boolean" then return end
    opt.value = newValue

    local cb = checkboxes[index]
    if cb then
        if newValue then
            -- De OFF a ON: animación de selección
            cb:animate("Check Box selecting animation", false)
            Timer.after(SELECT_ANIM_DURATION, function()
                if checkboxes[index] == cb then
                    cb:animate("Check Box Selected Static", false)
                end
            end)
        else
            -- De ON a OFF: animación de deselección (nueva)
            cb:animate("Check Box unselecting animation", false)
            Timer.after(SELECT_ANIM_DURATION, function()
                if checkboxes[index] == cb then
                    cb:animate("Check Box unselected", false)
                end
            end)
        end
    end

    -- Actualizar la configuración global según el nombre
    if opt.name == "Downscroll" then
        settings.downscroll = newValue
    elseif opt.name == "Ghost Tapping" then
        settings.ghostTapping = newValue
    elseif opt.name == "DFJK (use DFJK keys)" then
        settings.dfjk = newValue
    elseif opt.name == "Fullscreen" then
        love.window.setFullscreen(newValue)
        relayout()  -- AHORA SÍ ESTÁ DEFINIDA
    end
end

local function saveSettings()
    local settingsIni = ini.load("settings.ini")
    ini.writeKey(settingsIni, "Audio", "volume", tostring(settings.volume))
    ini.writeKey(settingsIni, "Game", "downscroll", tostring(settings.downscroll))
    ini.writeKey(settingsIni, "Game", "ghostTapping", tostring(settings.ghostTapping))
    ini.writeKey(settingsIni, "Game", "dfjk", tostring(settings.dfjk))
    ini.writeKey(settingsIni, "Game", "timebarMode", tostring(settings.timebarMode))
    ini.writeKey(settingsIni, "Video", "fullscreen", tostring(love.window.getFullscreen()))
    ini.writeKey(settingsIni, "Advanced", "showDebug", tostring(settings.showDebug))
    ini.save(settingsIni, "settings.ini")
end

return {
    enter = function(self, previous)
        selection = 1
        scrollOffset = 1
        currentShift = 0

        -- Refrescar opciones con la configuración actual
        options = getOptionsList()

        backgroundImage = graphics.newImage(love.graphics.newImage("images/png/menuDesat.png"))
        -- REEMPLAZO: Usar 1280 y 720
        backgroundImage.x = 1280 / 2
        backgroundImage.y = 720 / 2
        backgroundImage.originX = 0.5
        backgroundImage.originY = 0.5
        backgroundImage.sizeX = 1
        backgroundImage.sizeY = 1

        -- REEMPLAZO: Usar 720
        titleText = createCenteredText(720 * 0.139, "Options", "bold")
        relayout()

        -- Inicializar colores
        currentColor = {1, 1, 1}
        targetColor = {1, 1, 1}
        colorChangeTimer = colorChangeInterval

        graphics.setFade(0)
        graphics.fadeIn(0.5)
    end,

    update = function(self, dt)
        if titleText then titleText:update(dt) end
        for _, text in ipairs(optionTexts) do
            text:update(dt)
        end
        for _, cb in pairs(checkboxes) do
            cb:update(dt)
        end

        if input:pressed("up") then
            audio.playSound(selectSound)
            selection = selection - 1
            if selection < 1 then selection = #options end
        elseif input:pressed("down") then
            audio.playSound(selectSound)
            selection = selection + 1
            if selection > #options then selection = 1 end
        elseif input:pressed("left") or input:pressed("right") then
            local opt = options[selection]
            if opt.type == "range" then
                local delta = (input:pressed("left") and -opt.step or opt.step)
                opt.value = math.min(opt.max, math.max(opt.min, opt.value + delta))
                settings.volume = opt.value
                love.audio.setVolume(settings.volume)
                -- Actualizar texto del rango
                local y = listTop + (selection - 1) * itemHeight + currentShift
                local fullText = opt.name .. ": " .. string.format("%.1f", opt.value)
                optionTexts[selection] = createCenteredText(y, fullText, "regular")
            elseif opt.type == "boolean" then
                -- Cambiar valor booleano con animación
                setBooleanWithAnimation(selection, not opt.value)
            elseif opt.type == "choice" then
                local idx
                for i, v in ipairs(opt.choices) do
                    if v == opt.value then idx = i; break end
                end
                if input:pressed("left") then
                    idx = idx - 1
                else
                    idx = idx + 1
                end
                if idx < 1 then idx = #opt.choices
                elseif idx > #opt.choices then idx = 1 end
                opt.value = opt.choices[idx]

                if opt.name == "Show Debug" then
                    settings.showDebug = opt.value
                elseif opt.name == "Timebar Mode" then
                    settings.timebarMode = opt.value
                end
                -- Actualizar texto de la opción choice
                local y = listTop + (selection - 1) * itemHeight + currentShift
                local fullText = opt.name .. ": " .. tostring(opt.value)
                optionTexts[selection] = createCenteredText(y, fullText, "regular")
            end
        elseif input:pressed("confirm") then
            saveSettings()
            if not transitionRef.value then
                local StickerTransition = require("modules.sticker_transition")
                transitionRef.value = StickerTransition.new(function() return menu end, transitionRef)
                transitionRef.value:enter()
            end
        elseif input:pressed("back") then
            if not transitionRef.value then
                local StickerTransition = require("modules.sticker_transition")
                transitionRef.value = StickerTransition.new(function() return menu end, transitionRef)
                transitionRef.value:enter()
            end
        end

        -- Scroll automático
        if #options > visibleCount then
            local oldScroll = scrollOffset
            if selection < scrollOffset then
                scrollOffset = selection
            elseif selection > scrollOffset + visibleCount - 1 then
                scrollOffset = selection - visibleCount + 1
            end
            scrollOffset = math.max(1, math.min(scrollOffset, #options - visibleCount + 1))

            if scrollOffset ~= oldScroll then
                local newShift = -(scrollOffset - 1) * itemHeight
                local delta = newShift - currentShift
                for _, textObj in ipairs(optionTexts) do
                    for _, letter in ipairs(textObj.letters) do
                        letter.y = letter.y + delta
                    end
                    recalcBbox(textObj)
                end
                -- Mover también los checkboxes
                for _, cb in pairs(checkboxes) do
                    cb.y = cb.y + delta
                end
                currentShift = newShift
            end
        end

        -- Actualizar color de fondo con lerp
        colorChangeTimer = colorChangeTimer - dt
        if colorChangeTimer <= 0 then
            colorChangeTimer = colorChangeInterval
            targetColor = {
                math.random(30, 100) / 100,
                math.random(30, 100) / 100,
                math.random(30, 100) / 100
            }
        end
        for i = 1, 3 do
            currentColor[i] = currentColor[i] + (targetColor[i] - currentColor[i]) * colorLerpSpeed
        end
    end,

    draw = function(self)
        -- Dibujar fondo con color dinámico
        graphics.setColor(currentColor[1], currentColor[2], currentColor[3])
        if backgroundImage then
            backgroundImage:draw()
        end
        graphics.setColor(1, 1, 1)

        -- Dibujar opciones con transparencia (las no seleccionadas al 50%)
        for i, textObj in ipairs(optionTexts) do
            local alpha = (i == selection) and 1 or 0.5
            graphics.setColor(1, 1, 1, alpha)

            if i == selection then
                -- Escala 1.2 para la selección
                local bbox = textObj.bbox
                if bbox then
                    local centerX = bbox.x + bbox.w / 2
                    local centerY = bbox.y + bbox.h / 2
                    love.graphics.push()
                    love.graphics.translate(centerX, centerY)
                    love.graphics.scale(1.2, 1.2)
                    love.graphics.translate(-centerX, -centerY)
                    textObj:draw()
                    love.graphics.pop()
                else
                    textObj:draw()
                end
            else
                textObj:draw()
            end
        end

        -- Dibujar checkboxes (con la misma transparencia que sus textos)
        for i, cb in pairs(checkboxes) do
            local alpha = (i == selection) and 1 or 0.5
            graphics.setColor(1, 1, 1, alpha)
            cb:draw()
        end

        -- Overlay superior semitransparente (negro)
        local overlayHeight = 150
        graphics.setColor(0, 0, 0, 0.7)
        -- REEMPLAZO: Usar 1280 para el ancho del rectángulo
        love.graphics.rectangle("fill", 0, 0, 1280, overlayHeight)

        -- Título (encima del overlay)
        graphics.setColor(1, 1, 1, 1)
        if titleText then titleText:draw() end

        -- Texto de ayuda (abajo)
        graphics.setColor(1, 1, 1, 1)
        -- REEMPLAZO: Usar 720 para la posición en Y
        love.graphics.print("Enter: save and exit | Esc: cancel", 20, 720 - 30)
    end
}