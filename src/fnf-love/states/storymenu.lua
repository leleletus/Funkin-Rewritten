--[[----------------------------------------------------------------------------
... (licencia) ...
------------------------------------------------------------------------------]]

local highscores = require("highscores")

local storymenu = {}
local wmd = require("modules.weekMetadata")

-- Filtrar solo las semanas que aparecen en Story Mode
local storyWeeks = {}
for _, week in ipairs(wmd.weeks) do
    if not week.hideStoryMode then
        table.insert(storyWeeks, week)
    end
end

-- Importar módulos necesarios
local Conductor = require("modules.conductor")
local conductor

local function copyWeekState(original)
    local copy = {}
    for k, v in pairs(original) do
        copy[k] = v
    end
    return copy
end

-- Cargar recursos comunes como sprites (para poder usar :draw() y x,y)
local function loadImageSprite(path)
    local fullPath = graphics.imagePath(path)
    if love.filesystem.getInfo(fullPath) then
        return graphics.newImage(love.graphics.newImage(fullPath))
    end
    return nil
end

-- Dificultades: sprites
local difficultySprites = {
    easy = loadImageSprite("storymenu/difficulties/easy"),
    normal = loadImageSprite("storymenu/difficulties/normal"),
    hard = loadImageSprite("storymenu/difficulties/hard")
}

-- Sufijos para las dificultades
local difficultySuffixes = {
    easy = "-easy",
    normal = "",
    hard = "-hard"
}

-- Cargar los estados de las semanas (weekData)
local weekModules = {}
for i, week in ipairs(storyWeeks) do
    weekModules[i] = "weeks." .. week.id
end

-- Variables de estado
local currentWeekIndex = 1
local currentDifficulty = "normal"
local difficulties = {"easy", "normal", "hard"}
local trackListText = ""
local scoreText = ""
local funnyText =""
local highScore = 0
local exiting = false
local selected = false
local danceLeft = false  -- Para alternar el baile de GF
local bfConfirming = false -- FIX: para evitar que BF sea interrumpido durante confirmación

-- Sonidos
local selectSound = love.audio.newSource("sounds/menu/select.ogg", "static")
local confirmSound = love.audio.newSource("sounds/menu/confirm.ogg", "static")

-- Variables para el stage
local stageLayers = {}
local enemyLayer = nil
local titleLayer = nil
local difficultyLayer = nil
local leftArrowLayer = nil
local rightArrowLayer = nil
local bfLayer = nil
local gfLayer = nil

-- Función para cargar un sprite de prop
local function loadPropSprite(propName)
    if not propName then return nil end
    local success, sprite = pcall(require, "sprites.storymenu.props." .. propName)
    if success then
        if sprite.anims and sprite.anims["idle"] then
            sprite:animate("idle", true) -- true para loop? Depende del sprite. Normalmente idle es loop.
        end
        return sprite
    else
        print("No se pudo cargar el prop: " .. propName)
        return nil
    end
end

-- Función para cargar un sprite de imagen (título)
local function loadTitleSprite(titleName)
    titleName = titleName or "tutorial"
    return loadImageSprite("storymenu/titles/" .. titleName)
end

-- Actualizar elementos específicos de la semana (título, prop y funnyText)
local function updateWeekDisplay()
    local week = storyWeeks[currentWeekIndex]

    -- Actualizar título
    if titleLayer then
        titleLayer.obj = loadTitleSprite(week.title or week.id)
    end

    -- Actualizar prop del enemigo
    if enemyLayer then
        local propName = week.prop
        if propName then
            enemyLayer.obj = loadPropSprite(propName)
            if enemyLayer.obj then
                enemyLayer.obj.sizeX = (enemyLayer.obj.sizeX or 1) * enemyLayer.scaleX
                enemyLayer.obj.sizeY = (enemyLayer.obj.sizeY or 1) * enemyLayer.scaleY
            end
            enemyLayer.visible = true
        else
            enemyLayer.obj = nil
            enemyLayer.visible = false
        end
    end

    -- Actualizar el texto de la esquina superior derecha
    funnyText = week.funnyText or ""
end

-- Actualizar la interfaz al cambiar de dificultad / semana
local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function refresh()
    local week = storyWeeks[currentWeekIndex]

    -- Construir texto de la lista de canciones (SIN dibujar aquí)
    local lines = {}
    table.insert(lines, "TRACKS")
    for _, song in ipairs(week.songs) do
        table.insert(lines, song[1])  -- songs[i] es array: [name, character, color, fileName]
    end
    -- Unir con saltos y eliminar espacios extra al inicio/fin
    trackListText = trim(table.concat(lines, "\n"))

    -- Actualizar puntuación
    highScore = highscores.getStoryScore(week.id, currentDifficulty)
    scoreText = "HIGH SCORE: " .. highScore

    -- Actualizar imagen de dificultad
    if difficultyLayer then
        difficultyLayer.obj = difficultySprites[currentDifficulty]
    end
end

-- Cambiar de semana
local function changeWeek(delta)
    local newIndex = currentWeekIndex + delta
    if newIndex < 1 then newIndex = #storyWeeks end
    if newIndex > #storyWeeks then newIndex = 1 end
    if newIndex ~= currentWeekIndex then
        currentWeekIndex = newIndex
        audio.playSound(selectSound)
        updateWeekDisplay()  -- FIX: actualizar título y prop solo al cambiar semana
        refresh()            -- actualizar lista y puntuación (la dificultad no cambia)
    end
end

-- Cambiar dificultad
local function changeDifficulty(delta)
    local currentIdx = 1
    for i, d in ipairs(difficulties) do
        if d == currentDifficulty then
            currentIdx = i
            break
        end
    end
    local newIdx = currentIdx + delta
    if newIdx < 1 then newIdx = #difficulties end
    if newIdx > #difficulties then newIdx = 1 end
    if newIdx ~= currentIdx then
        currentDifficulty = difficulties[newIdx]
        audio.playSound(selectSound)
        refresh()  -- FIX: solo actualizar puntuación y dificultad, no el prop
    end
end

local function selectWeek()
    if selected then return end
    selected = true

    -- Obtener el nombre de la primera canción de la semana
    -- songs[i] es array: [name, character, color, fileName]
    local firstSongName = storyWeeks[currentWeekIndex].songs[1][1]

    -- Guardar datos de la semana
    _G.storyMode = true
    _G.currentWeekId = storyWeeks[currentWeekIndex].id
    _G.currentDifficulty = currentDifficulty
    _G.currentSongName = firstSongName
    _G.weekSongs = {}
    for _, s in ipairs(storyWeeks[currentWeekIndex].songs) do
        table.insert(_G.weekSongs, s[1])
    end
    _G.weekTotalScore = 0
    _G.currentSongIndex = 1

    audio.playSound(confirmSound)

    local function proceedToGame()
        -- Usar el nuevo sistema de carga
        local wl = require("modules.weekLoader")
        local songAppend = difficultySuffixes[currentDifficulty]
        wl.startFromMenu(storyWeeks[currentWeekIndex].id, 1, songAppend, true, firstSongName)
    end

    -- Si BF tiene animación "confirm", esperar un poco y evitar que el beat lo interrumpa
    if bfLayer and bfLayer.obj and bfLayer.obj.anims and bfLayer.obj.anims["confirm"] then
        bfConfirming = true  -- FIX: activar bandera para evitar que el beat cambie la animación
        bfLayer.obj:animate("confirm", false)
        Timer.after(0.4, function()
            bfConfirming = false  -- opcional, pero ya no importa
            proceedToGame()
        end)
    else
        proceedToGame()
    end
end

-- Volver al menú principal
local function goBack()
    if exiting or selected then return end
    exiting = true
    audio.playSound(selectSound)
    graphics.fadeOut(0.5, function()
        Gamestate.switch(require("states.menu"))
    end)
end

-- Cargar el stage
local function loadStage()
    stageLayers = {}
    local chunk, err = love.filesystem.load("stages/storymenu.lua")
    if not chunk then
        print("Error al cargar el stage:", err)
        return
    end
    local ok, stageData = pcall(chunk)
    if not ok or not stageData then
        print("Error al ejecutar el stage:", stageData)
        return
    end

    -- Procesar cada capa
    for i, layerData in ipairs(stageData.layers) do
        local layer = {
            type = layerData.type,
            path = layerData.path,
            x = layerData.x,
            y = layerData.y,
            scrollX = layerData.scrollX or 1,
            scrollY = layerData.scrollY or 1,
            scaleX = layerData.scaleX or 1,
            scaleY = layerData.scaleY or 1,
            visible = layerData.visible,
            obj = nil
        }

        if layer.type == "image" then
            local fullPath = graphics.imagePath(layer.path)
            if love.filesystem.getInfo(fullPath) then
                layer.obj = graphics.newImage(love.graphics.newImage(fullPath))
                if layer.obj then
                    layer.obj.originX = 0.5
                    layer.obj.originY = 0.5
                    if layer.obj.setSize then
                        layer.obj:setSize(layer.scaleX, layer.scaleY)
                    else
                        layer.obj.sizeX = layer.scaleX
                        layer.obj.sizeY = layer.scaleY
                    end
                end
            else
                print("Imagen no encontrada: " .. fullPath)
            end
        elseif layer.type == "sprite" then
            local spritePath = "sprites/" .. layer.path .. ".lua"
            local ok2, spriteLoader = pcall(love.filesystem.load, spritePath)
            if ok2 then
                local ok3, spriteObj = pcall(spriteLoader)
                if ok3 and type(spriteObj) == "table" then
                    layer.obj = spriteObj
                    if layer.obj.anims then
                        -- Intentar animación "idle" primero
                        if layer.obj.anims["idle"] then
                            layer.obj:animate("idle", true) -- loop para que no se detenga
                        else
                            -- Si no, tomar la primera que encuentre
                            local animName = next(layer.obj.anims)
                            if animName then
                                layer.obj:animate(animName, true)
                            end
                        end
                    end
                    layer.obj.sizeX = (layer.obj.sizeX or 1) * layer.scaleX
                    layer.obj.sizeY = (layer.obj.sizeY or 1) * layer.scaleY
                end
            else
                print("No se pudo cargar el sprite:", layer.path)
            end
        end

        table.insert(stageLayers, layer)

        -- Guardar referencias a capas específicas
        if layer.path == "storymenu/props/Menu_BF" then
            bfLayer = layer
        elseif layer.path == "storymenu/props/Menu_GF" then
            gfLayer = layer
        elseif layer.path == "storymenu/props/Menu_Dad" then
            enemyLayer = layer
        elseif layer.path == "storymenu/titles/week1" then
            titleLayer = layer
        elseif layer.path == "storymenu/difficulties/normal" then
            difficultyLayer = layer
        elseif layer.path == "storymenu/ui/arrows" then
            if layer.x < 400 then
                leftArrowLayer = layer
            else
                rightArrowLayer = layer
            end
        end
    end

    -- Crear los sprites de las flechas manualmente
    if leftArrowLayer and leftArrowLayer.type == "sprite" then
        local arrowImage = love.graphics.newImage(graphics.imagePath("storymenu/ui/arrows"))
        local arrowFrames = {
            {x = 4, y = 4, width = 48, height = 85, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
            {x = 56, y = 4, width = 47, height = 85, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
            {x = 107, y = 4, width = 42, height = 75, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
            {x = 153, y = 4, width = 41, height = 74, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
        }
        local arrowAnims = {
            leftIdle = {start = 1, stop = 1, speed = 24, offsetX = 0, offsetY = 0},
            rightIdle = {start = 2, stop = 2, speed = 24, offsetX = 0, offsetY = 0},
            leftConfirm = {start = 3, stop = 3, speed = 24, offsetX = 0, offsetY = 0},
            rightConfirm = {start = 4, stop = 4, speed = 24, offsetX = 0, offsetY = 0}
        }
        leftArrowLayer.obj = graphics.newSprite(arrowImage, arrowFrames, arrowAnims, "leftIdle")
        rightArrowLayer.obj = graphics.newSprite(arrowImage, arrowFrames, arrowAnims, "rightIdle")

        leftArrowLayer.obj.originX = 0.5
        leftArrowLayer.obj.originY = 0.5
        rightArrowLayer.obj.originX = 0.5
        rightArrowLayer.obj.originY = 0.5

        leftArrowLayer.obj.sizeX = (leftArrowLayer.obj.sizeX or 1) * leftArrowLayer.scaleX
        leftArrowLayer.obj.sizeY = (leftArrowLayer.obj.sizeY or 1) * leftArrowLayer.scaleY
        rightArrowLayer.obj.sizeX = (rightArrowLayer.obj.sizeX or 1) * rightArrowLayer.scaleX
        rightArrowLayer.obj.sizeY = (rightArrowLayer.obj.sizeY or 1) * rightArrowLayer.scaleY
    end
end

function storymenu.resume(self)
    -- Al reanudar, recargamos los datos actualizados
    refresh()
end

-- Métodos del estado
function storymenu.enter(self, previous)
    currentWeekIndex = 1
    currentDifficulty = "normal"
    exiting = false
    selected = false
    danceLeft = false
    bfConfirming = false  -- FIX

    loadStage()
    self.scale = graphics.getHeight() / 720
    updateWeekDisplay()  -- FIX: cargar título y prop de la semana actual
    refresh()

    -- Inicializar conductor con BPM de freakyMenu (102)
    conductor = Conductor.new(102)
    local beatCounter = 0  -- Contador de beats para GF
    conductor:addBeatHitCallback(function(beat)
        beatCounter = beatCounter + 1

        -- BF: animación idle en cada beat, pero no si está confirmando
        if bfLayer and bfLayer.obj and bfLayer.obj.anims and bfLayer.obj.anims["idle"] and not bfConfirming then
            bfLayer.obj:animate("idle", false)  -- false para que se reproduzca una vez y se detenga hasta el próximo beat
        end

        -- GF: alterna cada 2 beats
        if gfLayer and gfLayer.obj and gfLayer.obj.anims then
            if beatCounter % 2 == 1 then
                if gfLayer.obj.anims["danceLeft"] then
                    gfLayer.obj:animate("danceLeft", false)
                end
            else
                if gfLayer.obj.anims["danceRight"] then
                    gfLayer.obj:animate("danceRight", false)
                end
            end
        end

        -- Enemigo: idle en cada beat, pero solo si no es spaghetti
        local currentWeek = storyWeeks[currentWeekIndex]
        if currentWeek.prop ~= "spaghetti" then  -- FIX: evitar que spaghetti se anime al beat
            if enemyLayer and enemyLayer.obj and enemyLayer.obj.anims and enemyLayer.obj.anims["idle"] then
                enemyLayer.obj:animate("idle", false)
            end
        end
    end)

    -- Asegurar que la música del menú esté sonando
    if not music or not music:isPlaying() then
        music = love.audio.newSource("music/menu/menu.ogg", "stream")
        music:setLooping(true)
        music:play()
        _G.music = music
    end

    graphics.setFade(0)
    graphics.fadeIn(0.5)
end

function storymenu.update(self, dt)
    for _, layer in ipairs(stageLayers) do
        if layer.type == "sprite" and layer.obj and layer.obj.update then
            layer.obj:update(dt)
        end
    end

    -- Actualizar conductor con el tiempo de la música (en milisegundos)
    if music and music:isPlaying() then
        conductor:update(dt, music:tell() * 1000)
    end

    if graphics.isFading() then return end
    if exiting or selected then return end

    if input:pressed("up") then
        changeWeek(-1)
    elseif input:pressed("down") then
        changeWeek(1)
    elseif input:pressed("left") then
        changeDifficulty(-1)
        if leftArrowLayer and leftArrowLayer.obj then
            leftArrowLayer.obj:animate("leftConfirm", false)
            Timer.after(0.1, function() leftArrowLayer.obj:animate("leftIdle", true) end)
        end
    elseif input:pressed("right") then
        changeDifficulty(1)
        if rightArrowLayer and rightArrowLayer.obj then
            rightArrowLayer.obj:animate("rightConfirm", false)
            Timer.after(0.1, function() rightArrowLayer.obj:animate("rightIdle", true) end)
        end
    elseif input:pressed("confirm") then
        selectWeek()
    elseif input:pressed("back") then
        goBack()
    end
end

function storymenu.draw(self)

    -- Usamos la resolución virtual base del juego (siempre 1280x720)
    local gameW = 1280
    local gameH = 720

    -- Color de fondo según la semana
    local bgColor = storyWeeks[currentWeekIndex].color
    love.graphics.clear(bgColor[1]/255, bgColor[2]/255, bgColor[3]/255, 1)

    -- === DIBUJAR EL STAGE ===
    love.graphics.push()

        love.graphics.translate(gameW / 2, gameH / 2)

        for _, layer in ipairs(stageLayers) do
            if layer.visible and layer.obj then
                -- Asignar la posición original (relativa al centro)
                layer.obj.x = layer.x
                layer.obj.y = layer.y
                layer.obj:draw()
            end
        end
    love.graphics.pop()

    -- === DIBUJAR TEXTOS UI (en coordenadas de pantalla, con porcentajes) ===
    love.graphics.setColor(1, 1, 1)

    -- Lista de canciones (calculado sobre 1280x720)
    local leftMargin = gameW * 0.05
    local boxWidth = gameW * 0.25
    local boxY = gameH * 0.7
    love.graphics.setColor(0.9, 0.33, 0.52)
    love.graphics.printf(trackListText, leftMargin, boxY, boxWidth, "left")

    -- Puntuación
    love.graphics.setColor(1, 1, 1)
    local scoreX = gameW * 0.05
    local scoreY = gameH * 0.03
    love.graphics.printf(scoreText, scoreX, scoreY, gameW * 0.3, "left")

    -- Funny texto
    local funnyX = gameW * 0.7
    local funnyY = gameH * 0.03
    love.graphics.printf(funnyText, funnyX, funnyY, gameW * 0.25, "right")
end

function storymenu.leave(self)
    stageLayers = {}
    enemyLayer = nil
    titleLayer = nil
    difficultyLayer = nil
    leftArrowLayer = nil
    rightArrowLayer = nil
    bfLayer = nil
    gfLayer = nil
    -- No detener la música a menos que sea necesario
    -- music:stop()
end

return storymenu