--[[
Chart Editor for Friday Night Funkin' Rewritten
- DOWNSCROLL
- Dos columnas de carriles: oponente (izquierda) y jugador (derecha)
- Sprites de flechas del juego (solo normales, las holds se representan con barras)
- Personajes: tankman a la izquierda (espejado), boyfriend a la derecha
- Animación de strums al golpear (confirm)
]]

local state = {}
local graphics, audio, input, Timer

-- Variables globales necesarias para los sprites
images = nil

-- Constantes
local LANE_WIDTH = 90                     -- más separación entre strums
local ENEMY_START_X = 260                  -- inicio de carriles del oponente
local PLAYER_START_X = 660                 -- inicio de carriles del jugador
local LANE_COUNT = 4
local EVENT_LANE_X = (ENEMY_START_X + LANE_WIDTH * LANE_COUNT + PLAYER_START_X) / 2 - LANE_WIDTH / 2
local SECTION_BEATS = 16
local LANE_Y_TOP = 100
local LANE_HEIGHT = 500
local HITLINE_Y = LANE_Y_TOP + LANE_HEIGHT - 50
local PIXELS_PER_MS = 0.5
local NOTE_HEIGHT = 20
local MUSTHIT_BALL_Y = HITLINE_Y - 60   -- Por encima de la línea de golpe
local MUSTHIT_ENEMY_X = ENEMY_START_X + 2 * LANE_WIDTH   -- Centro de los carriles enemigos
local MUSTHIT_PLAYER_X = PLAYER_START_X + 2 * LANE_WIDTH -- Centro de los carriles del jugador

-- Colores para las notas (solo usado para holds)
local NOTE_COLORS = {
    {1, 0.6, 0.8}, -- rosado (left)
    {0.5, 0.8, 1}, -- celeste claro (down)
    {0, 1, 0},     -- verde (up)
    {1, 0, 0}      -- rojo (right)
}

-- Estado del editor
local editorMode = "browsing"
local fileList = {}
local selectedFile = 1
local visibleItems = 20
local listScroll = 0

-- Datos del chart
local chart
local sections
local currentChartPath
local currentSectionIndex = 1
local currentBpm = 160  -- BPM por defecto

-- Reproducción
local musicTime = 0
local playing = false
local scrollOffset = 0
local selectedNote = nil
local selectedEvent = nil
local selectedNotes = {}  -- tabla de notas seleccionadas (referencias a allNotes)
local wheelDelta = 0

-- Audio
local inst, voices

-- Sprites de personajes
local enemy, boyfriend

-- Sprites de flechas
local arrowSprites = {}
local enemyArrows = {}
local playerArrows = {}

-- Notas: se guardan en listas planas
local allNotes = {}  -- cada nota: {sprite, time, length, noteType, x, side, sectionIdx, noteData}
local activeNoteAnimations = {}

-- Notificación en pantalla
local notification = {text = "", timer = 0}

-- Para beats y animaciones (como en weeks.lua)
local spriteTimers = {enemy = 0, boyfriend = 0}
local enemyTimer = nil  -- para el caso especial de Tankman
local lastBeat = -1

local function clearSelection()
    selectedNotes = {}
end

local function pauseMenuMusic()
    if _G.music then
        _G.music:pause()
    end
end

local function resumeMenuMusic()
    if _G.music then
        _G.music:play()
    end
end

-- Función para obtener el lado según mustHit y noteType
local function getNoteSide(mustHit, noteType)
    if mustHit then
        if noteType < 4 then return "player" else return "enemy" end
    else
        if noteType < 4 then return "enemy" else return "player" end
    end
end

-- Función para obtener el color de una nota según su tipo
local function getNoteColor(noteType)
    local idx = (noteType % 4) + 1
    return NOTE_COLORS[idx]
end

-- Reconstruir la lista de notas a partir de las secciones
local function rebuildNotes()
    allNotes = {}
    for si, section in ipairs(sections) do
        local mustHit = section.mustHitSection
        for _, noteData in ipairs(section.sectionNotes) do
            local noteTime = noteData.noteTime
            local noteType = noteData.noteType
            local noteLength = noteData.noteLength or 0
            local lane = (noteType % 4) + 1
            local side = getNoteSide(mustHit, noteType)

            local x
            if side == "enemy" then
                x = ENEMY_START_X + (lane-1) * LANE_WIDTH + LANE_WIDTH/2
            else
                x = PLAYER_START_X + (lane-1) * LANE_WIDTH + LANE_WIDTH/2
            end

            -- Crear sprite para la cabeza de la nota (siempre)
            local sprite = nil
            if arrowSprites[lane] then
                sprite = arrowSprites[lane]()
                sprite.x = x
                sprite.sizeX, sprite.sizeY = 0.5, 0.5
                sprite:animate("on", false)  -- la cabeza siempre usa "on"
            end

            table.insert(allNotes, {
                sprite = sprite,
                time = noteTime,
                length = noteLength,
                noteType = noteType,
                x = x,
                lane = lane,
                side = side,
                section = si,
                noteData = noteData,
                altNote = noteData.altNote or false
            })
        end
    end
    table.sort(allNotes, function(a,b) return a.time < b.time end)
    clearSelection()
end

local function setSelectedNotesAlt(value)
    for _, note in ipairs(selectedNotes) do
        local si = note.section
        for idx, nd in ipairs(sections[si].sectionNotes) do
            if nd.noteTime == note.time and nd.noteType == note.noteType then
                nd.altNote = value
                break
            end
        end
    end
    rebuildNotes()
    notification.text = "Notas cambiadas a: " .. value
    notification.timer = 2
end

-- Cargar sprites de flechas
local function loadArrowSprites()
    images = {
        notes = love.graphics.newImage(graphics.imagePath("notes"))
    }
    local left = love.filesystem.load("sprites/left-arrow.lua")
    local down = love.filesystem.load("sprites/down-arrow.lua")
    local up = love.filesystem.load("sprites/up-arrow.lua")
    local right = love.filesystem.load("sprites/right-arrow.lua")
    arrowSprites = {left, down, up, right}

    for i = 1, 4 do
        enemyArrows[i] = arrowSprites[i]()
        playerArrows[i] = arrowSprites[i]()

        enemyArrows[i].x = ENEMY_START_X + (i-1) * LANE_WIDTH + LANE_WIDTH/2
        playerArrows[i].x = PLAYER_START_X + (i-1) * LANE_WIDTH + LANE_WIDTH/2
        enemyArrows[i].y = HITLINE_Y
        playerArrows[i].y = HITLINE_Y

        enemyArrows[i].sizeX, enemyArrows[i].sizeY = 0.5, 0.5
        playerArrows[i].sizeX, playerArrows[i].sizeY = 0.5, 0.5

        enemyArrows[i]:animate("off", false)
        playerArrows[i]:animate("off", false)
    end
end

-- Cargar personajes (tankman a la izquierda, boyfriend a la derecha)
local function loadCharacters()
    local ok, err
    ok, err = pcall(function() enemy = love.filesystem.load("sprites/weekend1/darnell.lua")() end)
    if not ok then
        print("Tankman no cargado: " .. tostring(err))
        enemy = nil
    else
        enemy.sizeX, enemy.sizeY = 0.5, 0.5
        enemy.x, enemy.y = -500, -50
        enemy.isTankman = true  -- para el caso especial "down alt"
        if enemy.anims and enemy.anims["idle"] then
            enemy:animate("idle", false)
        end
    end

    ok, err = pcall(function() boyfriend = love.filesystem.load("sprites/weekend1/Pico_FNF_assetss.lua")() end)
    if not ok then
        print("Boyfriend no cargado: " .. tostring(err))
        boyfriend = nil
    else
        boyfriend.sizeX, boyfriend.sizeY = 0.5, 0.5
        boyfriend.x, boyfriend.y = 500, 0
        if boyfriend.anims and boyfriend.anims["idle"] then
            boyfriend:animate("idle", false)
        end
    end
end

-- Escanear archivos .lua en charts/
local function scanLuaFiles()
    fileList = {}
    if love.filesystem.getInfo("charts") then
        local function scan(dir, prefix)
            prefix = prefix or ""
            for _, item in ipairs(love.filesystem.getDirectoryItems(dir)) do
                local path = dir .. "/" .. item
                local info = love.filesystem.getInfo(path)
                if info then
                    if info.type == "directory" then
                        scan(path, prefix .. item .. "/")
                    elseif info.type == "file" and item:match("%.lua$") then
                        local fullPath = (prefix .. item):gsub("%.lua$", "")
                        table.insert(fileList, fullPath)
                    end
                end
            end
        end
        scan("charts", "")
    end
    table.sort(fileList)
    selectedFile = 1
    listScroll = 0
end

-- Cargar chart seleccionado
local function loadSelectedChart()
    local relativePath = fileList[selectedFile]
    if not relativePath then return end

    local fullPath = "charts/" .. relativePath .. ".lua"
    local chunk, err = love.filesystem.load(fullPath)
    if not chunk then print("Error carga: "..err) return end
    local ok, loaded = pcall(chunk)
    if not ok then print("Error ejecución: "..loaded) return end
    chart = loaded
    sections = {}

    -- Detectar estructura
    local notesTable
    if chart.song and chart.song.notes then
        notesTable = chart.song.notes
    else
        notesTable = chart
    end

    if type(notesTable) == "table" then
        for i, section in ipairs(notesTable) do
            table.insert(sections, section)
        end
    end

    -- Calcular tiempos de inicio de sección con BPM variable
    local accumulatedTime = 0
    local lastBpm = 160 -- valor por defecto
    -- Intentar obtener BPM inicial desde la primera sección o campo global
    if chart.bpm then
        lastBpm = chart.bpm
    elseif #sections > 0 and sections[1].bpm then
        lastBpm = sections[1].bpm
    end
    for i, section in ipairs(sections) do
        -- Si la sección tiene su propio BPM, actualizar
        if section.bpm then
            lastBpm = section.bpm
        else
            -- Si no tiene, asignarle el último BPM conocido (para referencia futura)
            section.bpm = lastBpm
        end
        section.startTime = accumulatedTime
        local beatLength = 60000 / lastBpm
        local sectionLength = SECTION_BEATS * beatLength
        accumulatedTime = accumulatedTime + sectionLength
    end
    -- Actualizar currentBpm al BPM de la primera sección (o el último conocido)
    currentBpm = lastBpm

    currentChartPath = fullPath
    currentSectionIndex = 1
    editorMode = "editing"
    musicTime = 0
    playing = false
    selectedNote = nil
    lastBeat = -1

    rebuildNotes()

    -- Cargar audio
    local parts = {}
    for part in relativePath:gmatch("[^/]+") do table.insert(parts, part) end
    local semana = parts[#parts-1] or ""
    local cancion = parts[#parts]:gsub("%-[^%-]*$", "")
    local instPath = string.format("music/%s/%s-inst.ogg", semana, cancion)
    local voicesPath = string.format("music/%s/%s-voices.ogg", semana, cancion)
    if love.filesystem.getInfo(instPath) then
        inst = love.audio.newSource(instPath, "stream")
    else
        inst = nil
    end
    if love.filesystem.getInfo(voicesPath) then
        voices = love.audio.newSource(voicesPath, "stream")
    else
        voices = nil
    end
    notification.text = "Chart cargado: " .. relativePath
    notification.timer = 3
end

function state:wheelmoved(x, y)
    if editorMode == "editing" then
        musicTime = musicTime - y * 1200
        if musicTime < 0 then musicTime = 0 end
    end
end

-- Serializar una tabla (maneja ciclos y tipos no estándar)
local function serialize(t, indent, visited)
    visited = visited or {}
    if visited[t] then
        return "{} --[[circular]]"
    end
    visited[t] = true
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
            str = str .. serialize(v, indent .. "    ", visited)
        elseif type(v) == "string" then
            str = str .. "\"" .. v:gsub("\"", "\\\"") .. "\""
        elseif type(v) == "number" or type(v) == "boolean" then
            str = str .. tostring(v)
        else
            -- Funciones, threads, userdata → los omitimos (nil)
            str = str .. "nil --[[unsupported]]"
        end
        str = str .. ",\n"
    end
    str = str .. indent .. "}"
    return str
end

-- Guardar chart
local function saveChart()
    if not currentChartPath then
        notification.text = "No hay chart cargado"
        notification.timer = 2
        return
    end
    -- Crear copia de seguridad
    if love.filesystem.getInfo(currentChartPath) then
        love.filesystem.write(currentChartPath..".backup", love.filesystem.read(currentChartPath))
    end
    -- Serializar con protección de errores
    local ok, chartStr = pcall(function()
        return "return "..serialize(chart, "", {})
    end)
    if not ok then
        notification.text = "Error al serializar: " .. tostring(chartStr)
        notification.timer = 3
        return
    end
    -- Intentar guardar en el directorio de guardado
    local saveDir = "saved_charts"
    if not love.filesystem.getInfo(saveDir) then
        love.filesystem.createDirectory(saveDir)
    end

    -- Extraer solo el nombre del archivo (ej. "ugh-hard.lua")
    local filename = currentChartPath:match("([^/\\]+)%.lua$") or "chart"
    local savePath = saveDir .. "/" .. filename

    local written, bytes = love.filesystem.write(savePath, chartStr)
    if written then
        notification.text = "Guardado en: " .. savePath
        notification.timer = 3
    else
        notification.text = "Error al guardar (incluso en save dir)"
        notification.timer = 2
    end
end

-- Añadir nota
local function addNote(lane, time, side, forceAlt, altNote)
    altNote = altNote or false
    local section = sections[currentSectionIndex]
    local mustHit = section.mustHitSection
    local baseType = lane - 1

    local isAlt
    if side == "enemy" then
        isAlt = mustHit
    else
        isAlt = not mustHit
    end
    if forceAlt then
        isAlt = not isAlt
    end
    local noteType = isAlt and (baseType + 4) or baseType

    table.insert(section.sectionNotes, {
        noteTime = time,
        noteType = noteType,
        noteLength = 0,
        altNote = altNote
    })
    table.sort(section.sectionNotes, function(a,b) return a.noteTime < b.noteTime end)
    rebuildNotes()
end

local function addEvent(time, eventType)
    if not sections[currentSectionIndex].events then
        sections[currentSectionIndex].events = {}
    end
    local event = {
        time = time,
        type = eventType,
    }
    if eventType == "HighlightOn" then
        event.target = "enemy" -- valor por defecto
    elseif eventType == "cameraFocus" then
        event.target = "boyfriend"
        event.zoom = 1.0
    end
    table.insert(sections[currentSectionIndex].events, event)
    table.sort(sections[currentSectionIndex].events, function(a,b) return a.time < b.time end)
    notification.text = "Evento añadido: " .. event.type
    notification.timer = 2
end

-- Posición Y (downscroll)
local function noteY(noteTime)
    return HITLINE_Y - (noteTime - musicTime) * PIXELS_PER_MS
end

-- Alternar reproducción
local function togglePlayback()
    if not inst or not voices then
        notification.text = "No hay audio"
        notification.timer = 2
        return
    end
    if playing then
        inst:pause(); voices:pause(); playing = false
    else
        -- Reposicionar al tiempo actual del editor
        inst:seek(musicTime / 1000)
        voices:seek(musicTime / 1000)
        inst:play(); voices:play(); playing = true
    end
end

-- Detener reproducción
local function stopPlayback()
    if inst then inst:stop() end
    if voices then voices:stop() end
    playing = false; musicTime = 0
end

-- safeAnimate: replica el comportamiento de weeks.lua
local function safeAnimate(sprite, animName, loopAnim, timerKey)
    -- Forzar reinicio: cambiar a "idle" brevemente (si existe) para que la siguiente animación se reinicie
    if sprite.anims and sprite.anims["idle"] then
        sprite:animate("idle", false)
    end
    sprite:animate(animName, loopAnim)

    -- Caso especial: Tankman con "down alt"
    if sprite.isTankman and animName == "down alt" then
        local animDef = sprite.anims[animName]
        if animDef then
            local duration = (animDef.stop - animDef.start + 1) / animDef.speed
            if enemyTimer then Timer.cancel(enemyTimer) end
            enemyTimer = Timer.after(duration, function()
                if enemy and enemy:getAnimName() == "down alt" then
                    enemy:animate("idle", false)
                end
            end)
            spriteTimers[timerKey] = 999999
        else
            spriteTimers[timerKey] = 14
        end
    elseif sprite.isSonicEXE and animName == "left alt" then
        local animDef = sprite.anims[animName]
        if animDef then
            local duration = (animDef.stop - animDef.start + 1) / animDef.speed
            if enemyTimer then Timer.cancel(enemyTimer) end
            enemyTimer = Timer.after(duration, function()
                if enemy and enemy:getAnimName() == "left alt" then
                    enemy:animate("idle", false)
                end
            end)
            spriteTimers[timerKey] = 999999
        else
            spriteTimers[timerKey] = 14
        end
    elseif sprite.isSonicYCR and animName == "up alt" then
        local animDef = sprite.anims[animName]
        if animDef then
            local duration = (animDef.stop - animDef.start + 1) / animDef.speed
            if enemyTimer then Timer.cancel(enemyTimer) end
            enemyTimer = Timer.after(duration, function()
                if enemy and enemy:getAnimName() == "up alt" then
                    enemy:animate("idle", false)
                end
            end)
            spriteTimers[timerKey] = 999999
        else
            spriteTimers[timerKey] = 14
        end
    else
        spriteTimers[timerKey] = 14
    end
end

-- Auto-hit (animaciones de personajes y strums) usando safeAnimate
local function updateAutoHits(dt)
    if not playing then return end
    if inst and inst:isPlaying() then
        musicTime = inst:tell("seconds") * 1000
    end

    -- Actualizar sección actual basada en el tiempo
    if #sections > 0 then
        local newSection = 1
        for i, section in ipairs(sections) do
            if musicTime >= section.startTime then
                newSection = i
            else
                break
            end
        end
        if newSection ~= currentSectionIndex then
            currentSectionIndex = newSection
            if sections[currentSectionIndex].bpm then
                currentBpm = sections[currentSectionIndex].bpm
            end
        end
    end

    local animNames = {"left","down","up","right"}
    
    -- Primero, marcar las notas que ya no están en rango para limpiarlas
    local notesToRemove = {}
    for note, _ in pairs(activeNoteAnimations) do
        if note.time < musicTime - 60 or note.time > musicTime + 60 then
            table.insert(notesToRemove, note)
        end
    end
    for _, note in ipairs(notesToRemove) do
        activeNoteAnimations[note] = nil
    end

    -- Procesar las notas que están en el rango
    for _, note in ipairs(allNotes) do
        if note.time <= musicTime + 50 and note.time >= musicTime - 50 then
            local isEnemy = (note.side == "enemy")
            local lane = note.lane
            local baseAnim = animNames[note.noteType % 4 + 1]
            
            -- Determinar qué animación usar
            local animToPlay
            if activeNoteAnimations[note] then
                -- Ya decidida previamente
                animToPlay = activeNoteAnimations[note]
            else
                -- Primera vez que vemos esta nota en el rango, decidir
                if sections[note.section] and sections[note.section].altAnim then
                    animToPlay = baseAnim .. " alt"
                else
                    if note.altNote == "random" and not isEnemy then
                        if love.math.random() < 0.5 then
                            animToPlay = baseAnim .. " alt"
                        else
                            animToPlay = baseAnim .. " bf"
                        end
                    elseif note.altNote then
                        animToPlay = baseAnim .. " alt"
                    else
                        animToPlay = baseAnim
                    end
                end
                -- Guardar la decisión
                activeNoteAnimations[note] = animToPlay
            end

            if isEnemy then
                if enemy then
                    safeAnimate(enemy, animToPlay, false, "enemy")
                end
                enemyArrows[lane]:animate("confirm", false)
                Timer.after(0.25, function() enemyArrows[lane]:animate("off", false) end)
            else
                if boyfriend then
                    safeAnimate(boyfriend, animToPlay, false, "boyfriend")
                end
                playerArrows[lane]:animate("confirm", false)
                Timer.after(0.25, function() playerArrows[lane]:animate("off", false) end)
            end
        end
    end
end

-- Atajos de teclado
local function handleEditingShortcuts()
    if input:pressed("space") then togglePlayback()
    elseif input:pressed("s") then saveChart()
    elseif input:pressed("j") then
        addEvent(musicTime, "SonicJumpscare")    
    elseif input:pressed("p") then
        addEvent(musicTime, "Spoopy Scare")
    elseif input:pressed("h") then
        if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
            addEvent(musicTime, "HighlightOff")
        else
            addEvent(musicTime, "HighlightOn")
        end
    elseif input:pressed("num1") then setSelectedNotesAlt("yujin")
    elseif input:pressed("num2") then setSelectedNotesAlt("kazuha")
    elseif input:pressed("num3") then setSelectedNotesAlt("eunchae")
    elseif input:pressed("num4") then setSelectedNotesAlt("chaewon")
    elseif input:pressed("num5") then setSelectedNotesAlt("all")
    elseif input:pressed("num6") then setSelectedNotesAlt("yujin_gf")
    elseif input:pressed("num8") then setSelectedNotesAlt("eunchae_gf")
    elseif input:pressed("num9") then setSelectedNotesAlt("chaewon_gf")
    elseif input:pressed("t") then  -- T para cambiar target
        if selectedEvent then
            -- Cambiar cíclicamente entre los targets disponibles
            local targets = {"boyfriend", "enemy", "girlfriend", "yunjin", "chaewon", "eunchae", "kazuha","yunjin_gf", "eunchae_gf", "chaewon_gf", "all"}
            local current = selectedEvent.event.target
            local idx = 1
            for i, t in ipairs(targets) do
                if t == current then idx = i; break end
            end
            idx = idx % #targets + 1
            selectedEvent.event.target = targets[idx]
            notification.text = "Evento target: " .. targets[idx]
            notification.timer = 2
        end
    elseif input:pressed("z") then  -- Z para cambiar zoom (incrementar)
        if selectedEvent then
            selectedEvent.event.zoom = math.min(2, (selectedEvent.event.zoom or 1) + 0.1)
            notification.text = "Zoom: " .. string.format("%.1f", selectedEvent.event.zoom)
            notification.timer = 2
        end
    elseif input:pressed("x") then  -- X para cambiar zoom (decrementar)
        if selectedEvent then
            selectedEvent.event.zoom = math.max(0.5, (selectedEvent.event.zoom or 1) - 0.1)
            notification.text = "Zoom: " .. string.format("%.1f", selectedEvent.event.zoom)
            notification.timer = 2
        end    
    elseif input:pressed("r") then  -- R para random
        if #selectedNotes > 0 then
            for _, note in ipairs(selectedNotes) do
                local si = note.section
                for idx, nd in ipairs(sections[si].sectionNotes) do
                    if nd.noteTime == note.time and nd.noteType == note.noteType then
                        nd.altNote = "random"
                        break
                    end
                end
            end
            rebuildNotes()
            notification.text = "Notas marcadas como random"
            notification.timer = 2
        end
    elseif input:pressed("a") then  -- A para alt normal
        if #selectedNotes > 0 then
            for _, note in ipairs(selectedNotes) do
                local si = note.section
                for idx, nd in ipairs(sections[si].sectionNotes) do
                    if nd.noteTime == note.time and nd.noteType == note.noteType then
                        nd.altNote = true
                        break
                    end
                end
            end
            rebuildNotes()
            notification.text = "Notas marcadas como alt"
            notification.timer = 2
        end
    elseif input:pressed("n") then  -- N para normal
        if #selectedNotes > 0 then
            for _, note in ipairs(selectedNotes) do
                local si = note.section
                for idx, nd in ipairs(sections[si].sectionNotes) do
                    if nd.noteTime == note.time and nd.noteType == note.noteType then
                        nd.altNote = false
                        break
                    end
                end
            end
            rebuildNotes()
            notification.text = "Notas marcadas como normal"
            notification.timer = 2
        end
    elseif input:pressed("g") then  -- G para Pico Shoot
        if #selectedNotes > 0 then
            for _, note in ipairs(selectedNotes) do
                local si = note.section
                for idx, nd in ipairs(sections[si].sectionNotes) do
                    if nd.noteTime == note.time and nd.noteType == note.noteType then
                        nd.altNote = "picoShoot"
                        break
                    end
                end
            end
            rebuildNotes()
            notification.text = "Notas marcadas como Pico Shoot"
            notification.timer = 2
        end
    elseif input:pressed("l") then
        stopPlayback()
        resumeMenuMusic()
        editorMode = "browsing"
        scanLuaFiles()
    elseif input:pressed("delete") and selectedNote then
        local si = selectedNote.section
        local ni = selectedNote.note
        table.remove(sections[si].sectionNotes, ni)
        selectedNote = nil
        rebuildNotes()
    elseif input:pressed("m") then
        if sections and currentSectionIndex then
            sections[currentSectionIndex].mustHitSection = not sections[currentSectionIndex].mustHitSection
            rebuildNotes()
        end
    end
end

-- Inicialización
function state:enter(prev)
    graphics = require("modules.graphics")
    audio = require("modules.audio")
    input = require("input")
    Timer = require("lib.timer")
    scanLuaFiles()
    editorMode = "browsing"
    loadArrowSprites()
    loadCharacters()
    wheelDelta = 0
    graphics.fadeIn(0.5)
    pauseMenuMusic()
end

local function getEventAt(mx, my)
    if mx < EVENT_LANE_X or mx > EVENT_LANE_X + LANE_WIDTH then return nil end
    for si, section in ipairs(sections) do
        if section.events then
            for ei, event in ipairs(section.events) do
                local y = noteY(event.time)
                if math.abs(y - my) < 15 then
                    return {section = si, index = ei, event = event}
                end
            end
        end
    end
    return nil
end

function state:mousepressed(x, y, button, istouch, presses)
    if editorMode ~= "editing" then return end

    -- Detectar clic en la bolita de mustHit
    if y >= MUSTHIT_BALL_Y - 20 and y <= MUSTHIT_BALL_Y + 20 then
        local ballX = sections[currentSectionIndex].mustHitSection and MUSTHIT_PLAYER_X or MUSTHIT_ENEMY_X
        if math.abs(x - ballX) <= 20 then
            sections[currentSectionIndex].mustHitSection = not sections[currentSectionIndex].mustHitSection
            rebuildNotes()
            return  -- Importante: salir para no añadir una nota accidentalmente
        end
    end

    local lane, side = nil, nil
    if x >= ENEMY_START_X and x <= ENEMY_START_X + LANE_WIDTH * LANE_COUNT then
        side = "enemy"
        lane = math.floor((x - ENEMY_START_X) / LANE_WIDTH) + 1
    elseif x >= PLAYER_START_X and x <= PLAYER_START_X + LANE_WIDTH * LANE_COUNT then
        side = "player"
        lane = math.floor((x - PLAYER_START_X) / LANE_WIDTH) + 1
    elseif x >= EVENT_LANE_X and x <= EVENT_LANE_X + LANE_WIDTH then
        side = "event"
        lane = 1
    end

    if not lane or lane < 1 or lane > 4 or y < LANE_Y_TOP or y > LANE_Y_TOP + LANE_HEIGHT then
        return
    end

    local time = musicTime - (y - HITLINE_Y) / PIXELS_PER_MS

    if button == 1 then -- left click
        if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
            -- Shift+click: seleccionar nota o evento
            local closestNote = nil
            local closestDist = 20
            for _, note in ipairs(allNotes) do
                local ny = noteY(note.time)
                if math.abs(ny - y) < closestDist and math.abs(note.x - x) < LANE_WIDTH / 2 then
                    closestDist = math.abs(ny - y)
                    closestNote = note
                end
            end
            if closestNote then
                -- Alternar selección
                local found = false
                for i, sn in ipairs(selectedNotes) do
                    if sn == closestNote then
                        table.remove(selectedNotes, i)
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(selectedNotes, closestNote)
                end
                selectedEvent = nil
            else
                -- Buscar evento cercano
                local clickedEvent = getEventAt(x, y)
                if clickedEvent then
                    if selectedEvent and selectedEvent.section == clickedEvent.section and selectedEvent.index == clickedEvent.index then
                        selectedEvent = nil
                    else
                        selectedEvent = clickedEvent
                    end
                    clearSelection()
                else
                    clearSelection()
                    selectedEvent = nil
                end
            end
        else
            -- Click normal: añadir nota o evento
            if side == "event" then
                addEvent(time, "cameraFocus")
            else
                local forceAlt = love.keyboard.isDown("a") or love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")
                local altNote = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
                addNote(lane, time, side, forceAlt, altNote)
            end
        end
    elseif button == 2 then -- right click
        if #selectedNotes > 0 then
            -- Eliminar todas las seleccionadas
            for _, note in ipairs(selectedNotes) do
                local si = note.section
                for idx, nd in ipairs(sections[si].sectionNotes) do
                    if nd.noteTime == note.time and nd.noteType == note.noteType then
                        table.remove(sections[si].sectionNotes, idx)
                        break
                    end
                end
            end
            clearSelection()
            rebuildNotes()
        else
            local clickedEvent = getEventAt(x, y)
            if clickedEvent then
                table.remove(sections[clickedEvent.section].events, clickedEvent.index)
                selectedEvent = nil
                notification.text = "Evento eliminado"
                notification.timer = 2
            else
                -- Eliminar una sola nota
                for _, note in ipairs(allNotes) do
                    local ny = noteY(note.time)
                    if math.abs(ny - y) < 10 and math.abs(note.x - x) < LANE_WIDTH / 2 then
                        local si = note.section
                        for idx, nd in ipairs(sections[si].sectionNotes) do
                            if nd.noteTime == note.time and nd.noteType == note.noteType then
                                table.remove(sections[si].sectionNotes, idx)
                                rebuildNotes()
                                break
                            end
                        end
                        break
                    end
                end
            end
        end
    end
end

function state:update(dt)
    if graphics.isFading() then return end

    -- Actualizar notificación
    if notification.timer > 0 then
        notification.timer = notification.timer - dt
    end

    if editorMode == "browsing" then
        local old = selectedFile
        if input:pressed("up") then
            selectedFile = selectedFile - 1
            if selectedFile < 1 then selectedFile = #fileList end
        elseif input:pressed("down") then
            selectedFile = selectedFile + 1
            if selectedFile > #fileList then selectedFile = 1 end
        end
        if selectedFile ~= old then
            if selectedFile < listScroll + 1 then listScroll = selectedFile - 1
            elseif selectedFile > listScroll + visibleItems then listScroll = selectedFile - visibleItems end
            listScroll = math.max(0, math.min(listScroll, #fileList - visibleItems))
        end
        if input:pressed("confirm") and #fileList > 0 then loadSelectedChart()
        elseif input:pressed("back") then Gamestate.switch(require("states.debug-menu")) end
    else
        handleEditingShortcuts()
        if enemy then enemy:update(dt) end
        if boyfriend then boyfriend:update(dt) end
        updateAutoHits(dt)

        -- Decrementar timers de sprites
        for key, _ in pairs(spriteTimers) do
            if spriteTimers[key] > 0 then
                spriteTimers[key] = spriteTimers[key] - 1
            end
        end

        -- Detectar beat y activar idle si el timer está en 0
        if currentBpm then
            local beat = math.floor(musicTime / (60000 / currentBpm))
            if beat ~= lastBeat then
                lastBeat = beat
                if enemy and spriteTimers.enemy == 0 then
                    safeAnimate(enemy, "idle", false, "enemy")
                end
                if boyfriend and spriteTimers.boyfriend == 0 then
                    safeAnimate(boyfriend, "idle", false, "boyfriend")
                end
            end
        end

        if input:pressed("left") then
            currentSectionIndex = math.max(1, currentSectionIndex - 1)
            musicTime = sections[currentSectionIndex].startTime or 0
            if sections[currentSectionIndex].bpm then
                currentBpm = sections[currentSectionIndex].bpm
            end
        elseif input:pressed("right") then
            currentSectionIndex = math.min(#sections, currentSectionIndex + 1)
            musicTime = sections[currentSectionIndex].startTime or 0
            if sections[currentSectionIndex].bpm then
                currentBpm = sections[currentSectionIndex].bpm
            end
        end
    end
end

function state:draw()
    love.graphics.setColor(0.2,0.2,0.2)
    love.graphics.rectangle("fill", 0,0, graphics.getWidth(), graphics.getHeight())

    if editorMode == "browsing" then
        love.graphics.setColor(1,1,1)
        love.graphics.print("SELECCIONA UN CHART:", 50, 50)
        if #fileList == 0 then
            love.graphics.setColor(1,0,0)
            love.graphics.print("No charts en 'charts/'.", 70, 100)
            love.graphics.setColor(1,1,1)
            love.graphics.print("Escape para volver.", 70, 130)
        else
            local start = listScroll + 1
            local finish = math.min(start + visibleItems - 1, #fileList)
            for i = start, finish do
                local y = 70 + (i-start)*25
                if i == selectedFile then
                    love.graphics.setColor(1,1,0)
                else
                    love.graphics.setColor(1,1,1)
                end
                love.graphics.print(fileList[i], 70, y)
            end
            if #fileList > visibleItems then
                love.graphics.print(string.format("%d-%d de %d", start, finish, #fileList), 70, 70+visibleItems*25+10)
            end
        end
        love.graphics.print("Flechas: navegar | Enter: cargar | Escape: volver", 50, graphics.getHeight()-50)
        if selectedEvent then
            love.graphics.setColor(1, 1, 0)
            love.graphics.print("Evento seleccionado: " .. selectedEvent.event.type .. " | Target: " .. selectedEvent.event.target .. " | Zoom: " .. string.format("%.1f", selectedEvent.event.zoom), 10, 110)
            love.graphics.setColor(1, 1, 1)
        end
    else
        -- Fondo de carriles
        love.graphics.setColor(0.3,0.3,0.3)
        love.graphics.rectangle("fill", ENEMY_START_X, LANE_Y_TOP, LANE_WIDTH*LANE_COUNT, LANE_HEIGHT)
        love.graphics.rectangle("fill", PLAYER_START_X, LANE_Y_TOP, LANE_WIDTH*LANE_COUNT, LANE_HEIGHT)
        -- Event lane background
        love.graphics.setColor(0.3,0.2,0.3)
        love.graphics.rectangle("fill", EVENT_LANE_X, LANE_Y_TOP, LANE_WIDTH, LANE_HEIGHT)
        -- Hit line
        love.graphics.setColor(1,1,0)
        love.graphics.line(EVENT_LANE_X, HITLINE_Y, EVENT_LANE_X+LANE_WIDTH, HITLINE_Y)
        -- Vertical borders
        love.graphics.setColor(0.5,0.5,0.5)
        love.graphics.line(EVENT_LANE_X, LANE_Y_TOP, EVENT_LANE_X, LANE_Y_TOP+LANE_HEIGHT)
        love.graphics.line(EVENT_LANE_X+LANE_WIDTH, LANE_Y_TOP, EVENT_LANE_X+LANE_WIDTH, LANE_Y_TOP+LANE_HEIGHT)

        -- Líneas divisorias
        love.graphics.setColor(0.5,0.5,0.5)
        for i=0, LANE_COUNT do
            love.graphics.line(ENEMY_START_X + i*LANE_WIDTH, LANE_Y_TOP, ENEMY_START_X + i*LANE_WIDTH, LANE_Y_TOP+LANE_HEIGHT)
            love.graphics.line(PLAYER_START_X + i*LANE_WIDTH, LANE_Y_TOP, PLAYER_START_X + i*LANE_WIDTH, LANE_Y_TOP+LANE_HEIGHT)
        end

        -- Línea de golpe
        love.graphics.setColor(1,1,0)
        love.graphics.line(ENEMY_START_X, HITLINE_Y, ENEMY_START_X+LANE_WIDTH*LANE_COUNT, HITLINE_Y)
        love.graphics.line(PLAYER_START_X, HITLINE_Y, PLAYER_START_X+LANE_WIDTH*LANE_COUNT, HITLINE_Y)

        -- Bolita indicadora de mustHitSection
        local ballX = sections[currentSectionIndex].mustHitSection and MUSTHIT_PLAYER_X or MUSTHIT_ENEMY_X
        love.graphics.setColor(0, 1, 0)  -- verde
        love.graphics.circle("fill", ballX, MUSTHIT_BALL_Y, 15)
        
        -- Detectar si el ratón está encima para el borde (opcional)
        local mouseX, mouseY = love.mouse.getPosition()
        local dx = mouseX - ballX
        local dy = mouseY - MUSTHIT_BALL_Y
        if dx*dx + dy*dy <= 20*20 then  -- si el ratón está cerca
            love.graphics.setColor(1, 1, 0)  -- amarillo
            love.graphics.setLineWidth(3)
            love.graphics.circle("line", ballX, MUSTHIT_BALL_Y, 18)
            love.graphics.setLineWidth(1)
        end
        
        love.graphics.setColor(1, 1, 1)  -- restaurar color

        -- Carriles estáticos
        love.graphics.setColor(1,1,1)
        for i=1,4 do
            enemyArrows[i]:draw()
            playerArrows[i]:draw()
        end

        -- Notas
        love.graphics.setColor(1,1,1)
        for _, note in ipairs(allNotes) do
            local y = noteY(note.time)
            if note.sprite and y >= LANE_Y_TOP and y <= LANE_Y_TOP+LANE_HEIGHT then
                note.sprite.y = y
                note.sprite:draw()
                local isSelected = false
                for _, sn in ipairs(selectedNotes) do
                    if sn == note then
                        isSelected = true
                        break
                    end
                end
                if isSelected then
                    love.graphics.setColor(1, 0, 0)  -- rojo
                    love.graphics.rectangle("line", note.x - 20, y - 20, 40, 40)
                    love.graphics.setColor(1, 1, 1)
                end
                if (sections[note.section] and sections[note.section].altAnim) or note.altNote then
                    local text
                    if note.altNote == "picoShoot" then
                        text = "PS"
                    elseif note.altNote == "random" then
                        text = "RANDOM"
                    elseif type(note.altNote) == "string" then
                        if note.altNote == "yujin" then text = "Y"
                        elseif note.altNote == "kazuha" then text = "K"
                        elseif note.altNote == "eunchae" then text = "E"
                        elseif note.altNote == "chaewon" then text = "C"
                        elseif note.altNote == "all" then text = "ALL"
                        elseif note.altNote == "yujin_gf" then text = "Y+G"
                        elseif note.altNote == "eunchae_gf" then text = "E+G"
                        elseif note.altNote == "chaewon_gf" then text = "C+G"
                        else text = "?"
                        end
                    else
                        text = "ALT"
                    end
                    love.graphics.print(text, note.x - 15, y - 10)
                end
            end
            if note.length > 0 then
                local startY = noteY(note.time)
                local endY = noteY(note.time + note.length)
                if endY < startY then
                    startY, endY = endY, startY
                end
                if endY >= LANE_Y_TOP and startY <= LANE_Y_TOP+LANE_HEIGHT then
                    local clipStart = math.max(startY, LANE_Y_TOP)
                    local clipEnd = math.min(endY, LANE_Y_TOP+LANE_HEIGHT)
                    local color = getNoteColor(note.noteType)
                    love.graphics.setColor(color[1], color[2], color[3], 0.4)
                    love.graphics.rectangle("fill", note.x - 15, clipStart, 30, clipEnd - clipStart)
                    love.graphics.setColor(1,1,1)
                end
            end
        end

        -- Draw events
        love.graphics.setColor(1,0.5,0) -- naranja base
        for si, section in ipairs(sections) do
            if section.events then
                for _, event in ipairs(section.events) do
                    local y = noteY(event.time)
                    if y >= LANE_Y_TOP and y <= LANE_Y_TOP+LANE_HEIGHT then
                        local x = EVENT_LANE_X + LANE_WIDTH/2
                        love.graphics.polygon("fill", x, y-10, x+10, y, x, y+10, x-10, y)
                        love.graphics.setColor(1,1,1)
                        -- Mostrar letra según tipo
                        local letter = "C"
                        if event.type == "SonicJumpscare" then
                            letter = "J"
                            love.graphics.setColor(1,0,0) -- rojo
                        elseif event.type == "Spoopy Scare" then
                            letter = "P"
                            love.graphics.setColor(0,1,0) -- verde
                        elseif event.type == "HighlightOn" then
                            letter = "H"
                            love.graphics.setColor(1,1,0) -- amarillo
                        elseif event.type == "HighlightOff" then
                            letter = "H"
                            love.graphics.setColor(0.5,0.5,0.5) -- gris
                        end
                        love.graphics.print(letter, x-5, y-5)
                        love.graphics.setColor(1,0.5,0) -- restaurar color para el siguiente
                    end
                end
            end
        end
        love.graphics.setColor(1,1,1)

        -- Personajes
        love.graphics.push()
            love.graphics.translate(graphics.getWidth()/2, graphics.getHeight()/2)
            if enemy then
                enemy:draw()
            end
            if boyfriend then
                boyfriend:draw()
            end
        love.graphics.pop()

        -- Interfaz
        love.graphics.setColor(1,1,1)
        love.graphics.print("Editor - "..(currentChartPath or "sin archivo"), 10,10)
        love.graphics.print("Sección: "..currentSectionIndex.."/"..#sections, 10,30)
        love.graphics.print("mustHit: "..tostring(sections[currentSectionIndex].mustHitSection), 10,50)
        love.graphics.print("Tiempo: "..math.floor(musicTime).." ms", 10,70)
        love.graphics.print("[Espacio] Play/Pause  [S] Guardar  [L] Cambiar  [Supr] Eliminar", 10, graphics.getHeight()-80)
        love.graphics.print("Click izq: añadir (A+alt) | Click der: eliminar | Rueda: tiempo", 10, graphics.getHeight()-60)
        love.graphics.print("Shift+Click: seleccionar | R: random | A: alt | N: normal | G: Pico Shoot", 10, graphics.getHeight()-100)
        love.graphics.print("Flechas: sección | M: mustHit", 10, graphics.getHeight()-40)
        if playing then
            love.graphics.setColor(0,1,0)
            love.graphics.print("REPRODUCIENDO", graphics.getWidth()-200, 10)
        end

        -- Notificación
        if notification.timer > 0 then
            love.graphics.setColor(1, 1, 0, math.min(1, notification.timer))
            love.graphics.print(notification.text, graphics.getWidth()/2 - 50, graphics.getHeight()/2)
            love.graphics.setColor(1, 1, 1)
        end
    end
end

function state:leave()
    resumeMenuMusic()
    stopPlayback()
end

return state