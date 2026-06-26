--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten

Copyright (C) 2021  HTV04

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

--[[
Editor de charts en formato Psych Engine (data/<carpeta>/<archivo>.json),
con paridad funcional con ChartingState.hx: carriles de notas, los 6 tipos de
nota incorporados + custom_notetypes/*.txt, catálogo de eventos, gestión de
secciones (mustHitSection/gfSection/altAnim/changeBPM/sectionBeats), metadatos
de personajes/stage/bpm/speed con vista previa en vivo, audio, selección,
portapapeles, deshacer/rehacer, cuantización/zoom y guardado directo del JSON.
]]

local json = require("lib.json")
local notetypes = require("charts.psych.notetypes")
local psychCharacters = require("charts.psych.characters")
local psychStages = require("charts.psych.stages")
local UI = require("modules.ui")

local state = {}

-- ============================================================
-- Constantes de layout (heredadas del editor anterior)
-- ============================================================
-- Mismas proporciones que ChartingState.hx: GRID_SIZE=40 por carril/paso.
-- El espaciado vertical depende del PASO (sectionBeats+bpm), no de ms, así
-- que 1 paso siempre mide STEP_PIXELS*zoom en pantalla.
local LANE_WIDTH = 40   -- = GRID_SIZE de Psych Engine
local ENEMY_START_X = 260
local PLAYER_START_X = 460  -- ENEMY_START_X + 4*40 (enemy) + 40 (event)
local LANE_COUNT = 4
local EVENT_LANE_X = (ENEMY_START_X + LANE_WIDTH * LANE_COUNT + PLAYER_START_X) / 2 - LANE_WIDTH / 2
local LANE_Y_TOP = 80
local LANE_HEIGHT = 580
-- Centro del área de carriles: la strumline está fija aquí como en Psych
-- (timeLine con scrollFactor.set()); las notas futuras están DEBAJO.
local STRUMLINE_Y = LANE_Y_TOP + LANE_HEIGHT / 2  -- = 370
-- Píxeles por paso de dieciseisavo a zoom 1x -- igual que GRID_SIZE de
-- ChartingState.hx de Psych Engine.
local STEP_PIXELS = 40
local MUSTHIT_ENEMY_X = ENEMY_START_X + 2 * LANE_WIDTH
local MUSTHIT_PLAYER_X = PLAYER_START_X + 2 * LANE_WIDTH
-- Panel de info (HUD) a la derecha de la grilla del jugador
local HUD_X = PLAYER_START_X + LANE_WIDTH * LANE_COUNT + 20  -- ≈ 640

-- Iconos de personaje encima de los carriles (estilo Psych Engine)
local ICON_SIZE = 54
local ICON_Y = math.floor((LANE_Y_TOP - ICON_SIZE) / 2)  -- = 13

local NOTE_COLORS = {
	{1, 0.6, 0.8}, -- left
	{0.5, 0.8, 1}, -- down
	{0, 1, 0},     -- up
	{1, 0, 0}      -- right
}

local QUANTIZATIONS = {4, 8, 12, 16, 24, 32, 48, 64, 96, 192}
local ZOOM_LEVELS = {0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4, 6, 8, 12, 16, 24}
local DEFAULT_QUANT_INDEX = 4 -- 16
local DEFAULT_ZOOM_INDEX = 4  -- 1.0x: paso=40px = altura de nota → sin aplastamiento

-- 6 tipos de nota incorporados de Psych Engine
local BUILTIN_NOTE_TYPES = {"", "Alt Animation", "Hey!", "Hurt Note", "GF Sing", "No Animation"}

-- Catálogo de eventos (calcado de defaultEvents de ChartingState.hx + handlers
-- de charts/psych/events.lua). "implemented" solo afecta al texto de ayuda.
local EVENT_CATALOG = {
	{name = "Hey!", desc = "BF hace 'hey' y GF anima 'cheer'", implemented = true},
	{name = "Set GF Speed", desc = "v1=cada cuántos beats baila GF", implemented = true},
	{name = "Add Camera Zoom", desc = "v1=zoom extra temporal de cámara", implemented = true},
	{name = "Play Animation", desc = "v1=animación, v2=personaje (bf/gf/dad)", implemented = true},
	{name = "Camera Follow Pos", desc = "v1=x, v2=y: mueve la cámara ahí", implemented = true},
	{name = "Alt Idle Animation", desc = "v1=personaje: alterna idle/idle alt", implemented = true},
	{name = "Screen Shake", desc = "v1=duración, v2=intensidad", implemented = true},
	{name = "Change Character", desc = "v1=slot(boyfriend/girlfriend/dad), v2=personaje", implemented = true},
	{name = "Change Scroll Speed", desc = "v1=nueva velocidad de scroll", implemented = true},
	{name = "Set Property", desc = "v1=propiedad (health/score/cam.x/...), v2=valor", implemented = true},
	{name = "Play Sound", desc = "v1=sounds/<v1>.ogg, v2=volumen", implemented = true},
	{name = "Dadbattle Spotlight", desc = "v1=0/1/2/3: foco+niebla (Week 1)", implemented = true},
	{name = "Philly Glow", desc = "Brillo de luces de Philly (no implementado)", implemented = false},
	{name = "Kill Henchmen", desc = "Elimina henchmen de fondo (no implementado)", implemented = false},
	{name = "BG Freaks Expression", desc = "Expresión de bailarinas de fondo (no implementado)", implemented = false},
	{name = "Trigger BG Ghouls", desc = "Activa fantasmas de fondo (no implementado)", implemented = false},
	{name = "Hide HUD", desc = "Oculta la interfaz de juego (no implementado)", implemented = false},
}

-- Personajes/stages disponibles para ciclar (registro de charts/psych/* +
-- escaneo en vivo de characters/, Fase 2 de la refactorización de
-- ergonomía de modding: un characters/<id>.json sin entrada en REGISTRY ya
-- es jugable, así que también debe poder elegirse acá -- mismo patrón ya
-- usado por states/character-offset-debug.lua para su propio browser).
local CHARACTER_NAMES = {}
local characterNameSet = {}
for name in pairs(psychCharacters.REGISTRY) do
	table.insert(CHARACTER_NAMES, name)
	characterNameSet[name] = true
end
for _, item in ipairs(love.filesystem.getDirectoryItems("characters")) do
	local id = item:match("^(.+)%.json$")
	if id and not characterNameSet[id] then
		table.insert(CHARACTER_NAMES, id)
		characterNameSet[id] = true
	end
end
table.sort(CHARACTER_NAMES)

local STAGE_NAMES = {}
for name in pairs(psychStages.STAGES) do table.insert(STAGE_NAMES, name) end
table.sort(STAGE_NAMES)

-- Mapa "nombre base de canción" -> week portado, para "test play" (Enter)
local TESTPLAY_MAP = {
	bopeebo = {module = "weeks.week1", songNum = 1},
	fresh = {module = "weeks.week1", songNum = 2},
	["dad-battle"] = {module = "weeks.week1", songNum = 3},
}

local DIFFICULTY_SUFFIXES = {"%-easy$", "%-normal$", "%-hard$", "%-erect$", "%-nightmare$"}

local UNDO_LIMIT = 50

-- ============================================================
-- Estado del editor
-- ============================================================

local mode = "browser" -- "browser" | "editor"
local showHelp = false

-- Navegador de archivos (data/**/*.json)
local fileList = {}
local selectedFile = 1
local listScroll = 0
local VISIBLE_ITEMS = 24

-- Datos del chart cargado
local rawDecoded   -- tabla raíz decodificada del JSON
local song         -- = rawDecoded.song or rawDecoded
local currentPath  -- "data/bopeebo/bopeebo.json"
local currentRelPath -- "bopeebo/bopeebo" (sin "data/" ni ".json")
local sectionTimes -- sectionTimes[i] = tiempo de inicio (ms) de song.notes[i]
local sectionBpms  -- sectionBpms[i] = bpm activo durante song.notes[i]
local sectionSteps -- sectionSteps[i] = paso de 16vo acumulado al inicio de song.notes[i]
local noteCache    -- lista plana reconstruida desde song.notes[*].sectionNotes

-- Vista / navegación
local currentSectionIndex = 1
local musicTime = 0
local quantIndex = DEFAULT_QUANT_INDEX
local zoomIndex = DEFAULT_ZOOM_INDEX

-- Tipos de nota (6 incorporados + custom_notetypes/*.txt)
local noteTypesList = {}
local currentNoteTypeIndex = 1

-- Eventos
local currentEventIndex = 1

-- Selección / portapapeles / deshacer
local selection = {notes = {}, event = nil}
local clipboard = nil
local undoStack = {}
local redoStack = {}

-- Caja de selección con arrastre (Shift + arrastrar)
local boxSelectStart = nil
local boxSelectEnd = nil

-- Arrastre de sustain (Ctrl + arrastrar sobre una nota)
local sustainDrag = nil

-- Audio
local inst, voices
local playing = false
local hitNotesProcessed = {}

-- Sprites de flechas
local arrowSprites = {} -- arrowSprites[1..4] = chunks de sprites/<dir>-arrow.lua
local enemyArrows = {}
local playerArrows = {}
local noteStampSprites = {}

-- Notificación en pantalla
local notification = {text = "", timer = 0}

-- true mientras testPlay() está cambiando a un week (Gamestate.switch llama a
-- state:leave() también en este caso, no solo al volver al menú de debug; ver
-- state:leave()).
local goingToTestPlay = false

-- Iconos de personaje cargados para el chart actual
local opponentIcon = nil  -- song.player2
local playerIcon = nil    -- song.player1

-- GUI (cajas del UI estilo Psych Engine)
local mainBox, upperBox, infoBox

-- Estado extra para el UI
local playbackRate     = 1.0
local instVolume       = 1.0
local vocalsVolume     = 1.0
local sectionClipboard = {notes = {}}
local copyLastSecOffset = 1

-- ============================================================
-- Utilidades
-- ============================================================

local function notify(text, duration)
	notification.text = text
	notification.timer = duration or 2.5
end

local function deepCopy(t)
	if type(t) ~= "table" then return t end
	local copy = {}
	for k, v in pairs(t) do
		copy[k] = deepCopy(v)
	end
	return copy
end

local function laneX(lane, isPlayerNote)
	local base = isPlayerNote and PLAYER_START_X or ENEMY_START_X
	return base + lane * LANE_WIDTH + LANE_WIDTH / 2
end

-- ============================================================
-- Modelo de datos: secciones, tiempos, snapping, caché de notas
-- ============================================================

-- Misma fórmula que charts/psych/converter.lua para sectionStartTime, pero
-- sobre el JSON crudo de Psych (sectionBeats en vez de lengthInSteps).
local function recomputeSectionTimes()
	sectionTimes = {}
	sectionBpms = {}
	sectionSteps = {}

	local globalBpm = song.bpm or 100
	local accumTime = 0
	local accumSteps = 0
	local bpmAnterior = nil

	for i, section in ipairs(song.notes) do
		local lengthInSteps = (section.sectionBeats or 4) * 4
		local sectionBpm
		if i == 1 then
			sectionBpm = section.bpm or globalBpm
		elseif section.changeBPM and section.bpm then
			sectionBpm = section.bpm
		end
		local bpmActivo = sectionBpm or bpmAnterior or globalBpm

		sectionTimes[i] = accumTime
		sectionBpms[i] = bpmActivo
		sectionSteps[i] = accumSteps

		accumTime = accumTime + (lengthInSteps / 16.0) * (240000.0 / bpmActivo)
		accumSteps = accumSteps + lengthInSteps
		bpmAnterior = bpmActivo
	end
end

local function sectionIndexForTime(t)
	for i = #sectionTimes, 1, -1 do
		if t >= sectionTimes[i] - 0.001 then return i end
	end
	return 1
end

-- Tiempo (ms) <-> paso de dieciseisavo "global" (acumulado desde el inicio de
-- la canción), usando el bpm de la sección de cada uno -- así 1 paso siempre
-- corresponde a STEP_PIXELS, sin importar el bpm de la sección.
local function timeToStep(t)
	local si = sectionIndexForTime(t)
	local stepCrochet = (240000.0 / sectionBpms[si]) / 16
	return sectionSteps[si] + (t - sectionTimes[si]) / stepCrochet
end

local function stepIndexForStep(step)
	for i = #sectionSteps, 1, -1 do
		if step >= sectionSteps[i] - 0.001 then return i end
	end
	return 1
end

local function stepToTime(step)
	local si = stepIndexForStep(step)
	local stepCrochet = (240000.0 / sectionBpms[si]) / 16
	return sectionTimes[si] + (step - sectionSteps[si]) * stepCrochet
end

-- Cuántos pasos de 16vo representa la cuantización actual (16 = 1 paso, 32 =
-- medio paso, 8 = 2 pasos, etc.)
local function quantStepCount()
	return 16 / QUANTIZATIONS[quantIndex]
end

local function snapTime(t)
	local stepInterval = quantStepCount()
	local step = timeToStep(t)
	return stepToTime(math.floor(step / stepInterval + 0.5) * stepInterval)
end

local function pixelsPerStep()
	return STEP_PIXELS * ZOOM_LEVELS[zoomIndex]
end

-- Grilla estática estilo Psych Engine: la strumline (STRUMLINE_Y) está fija en
-- pantalla y el contenido de la grilla sube a medida que musicTime avanza.
-- Notas futuras (t > musicTime) están DEBAJO de la strumline; pasadas, arriba.
-- Equivalente a worldY(t) - scrollY de ChartingState.hx traducido a LÖVE2D.
local function noteY(t)
	return STRUMLINE_Y + (timeToStep(t) - timeToStep(musicTime)) * pixelsPerStep()
end

local function timeAtY(y)
	return stepToTime(timeToStep(musicTime) + (y - STRUMLINE_Y) / pixelsPerStep())
end

-- Igual que noteY pero desplaza la nota media celda hacia abajo para que
-- quede DENTRO del espacio entre líneas de grid, no sobre la línea.
-- Equivalente a note.y + GRID_SIZE/2 de ChartingState.hx (donde note.height=GRID_SIZE).
local function noteDisplayY(t)
	return STRUMLINE_Y + (timeToStep(t) - timeToStep(musicTime)) * pixelsPerStep() + pixelsPerStep() / 2
end

-- Snapping de colocación (floor-snap): snapa al inicio de la celda en la que
-- se hizo clic, no a la línea más cercana. Así un clic en cualquier punto
-- dentro de la celda [n, n+1) coloca la nota en el paso n, que se muestra
-- centrado dentro de esa celda gracias al offset de noteDisplayY.
local function placeTimeAtY(y)
	local stepInterval = quantStepCount()
	local step = timeToStep(musicTime) + (y - STRUMLINE_Y) / pixelsPerStep()
	return stepToTime(math.floor(step / stepInterval) * stepInterval)
end

-- Reconstruye noteCache desde song.notes[*].sectionNotes. Cada entrada
-- mantiene `raw` = referencia directa al array {time, noteData, length, type}
-- para poder mutarlo/eliminarlo in-place.
local function rebuildNoteCache()
	noteCache = {}

	for si, section in ipairs(song.notes) do
		section.sectionNotes = section.sectionNotes or {}

		for ni, raw in ipairs(section.sectionNotes) do
			local t, noteData = raw[1], raw[2]
			if t and noteData and noteData >= 0 then
				-- Misma fórmula que converter.lua:mapNoteType + weeks.lua:
				-- generateNotes() combinados: el lado (player/enemy) depende
				-- únicamente de psychNoteData (0-3 = player, 4-7 = enemy), el
				-- mustHitSection de la sección NO afecta el lado de la nota,
				-- solo la bolita de "must hit"/cámara.
				local lane = noteData % 4
				local isPlayerNote = noteData < 4

				table.insert(noteCache, {
					time = t,
					lane = lane,
					isPlayerNote = isPlayerNote,
					sectionIndex = si,
					noteIndex = ni,
					typeStr = raw[4],
					raw = raw,
				})
			end
		end
	end

	table.sort(noteCache, function(a, b) return a.time < b.time end)
end

-- ============================================================
-- Deshacer / rehacer
-- ============================================================

local function pushUndo()
	table.insert(undoStack, {notes = deepCopy(song.notes), events = deepCopy(song.events)})
	if #undoStack > UNDO_LIMIT then table.remove(undoStack, 1) end
	redoStack = {}
end

local function restoreSnapshot(snap)
	song.notes = snap.notes
	song.events = snap.events
	recomputeSectionTimes()
	rebuildNoteCache()
	currentSectionIndex = math.max(1, math.min(currentSectionIndex, #song.notes))
	selection.notes = {}
	selection.event = nil
end

local function performUndo()
	if #undoStack == 0 then notify("Nada para deshacer"); return end
	table.insert(redoStack, {notes = deepCopy(song.notes), events = deepCopy(song.events)})
	restoreSnapshot(table.remove(undoStack))
	notify("Deshecho")
end

local function performRedo()
	if #redoStack == 0 then notify("Nada para rehacer"); return end
	table.insert(undoStack, {notes = deepCopy(song.notes), events = deepCopy(song.events)})
	restoreSnapshot(table.remove(redoStack))
	notify("Rehecho")
end

-- ============================================================
-- Operaciones de sección (GUI)
-- ============================================================

local function copySection()
    local sec = song.notes[currentSectionIndex]
    sectionClipboard = {notes = deepCopy(sec.sectionNotes), srcStart = sectionTimes[currentSectionIndex]}
    notify("Sección copiada")
end

local function pasteSection()
    if #sectionClipboard.notes == 0 then notify("Portapapeles de sección vacío"); return end
    pushUndo()
    local dstStart = sectionTimes[currentSectionIndex]
    local srcStart = sectionClipboard.srcStart or 0
    local sec = song.notes[currentSectionIndex]
    sec.sectionNotes = {}
    for _, raw in ipairs(sectionClipboard.notes) do
        local newRaw = deepCopy(raw)
        newRaw[1] = dstStart + (raw[1] - srcStart)
        table.insert(sec.sectionNotes, newRaw)
    end
    rebuildNoteCache()
    notify("Sección pegada")
end

local function clearSection()
    pushUndo()
    song.notes[currentSectionIndex].sectionNotes = {}
    rebuildNoteCache()
    notify("Sección limpiada")
end

local function copyLastSection()
    local srcIdx = currentSectionIndex - copyLastSecOffset
    if srcIdx < 1 then notify("No hay sección anterior a -" .. copyLastSecOffset); return end
    pushUndo()
    local src = song.notes[srcIdx]
    local dst = song.notes[currentSectionIndex]
    local diff = sectionTimes[currentSectionIndex] - sectionTimes[srcIdx]
    dst.sectionNotes = {}
    for _, raw in ipairs(src.sectionNotes) do
        local newRaw = deepCopy(raw)
        newRaw[1] = raw[1] + diff
        table.insert(dst.sectionNotes, newRaw)
    end
    rebuildNoteCache()
    notify("Copiada sección -" .. copyLastSecOffset)
end

local function swapSection()
    pushUndo()
    for _, raw in ipairs(song.notes[currentSectionIndex].sectionNotes) do
        raw[2] = raw[2] < 4 and raw[2] + 4 or raw[2] - 4
    end
    rebuildNoteCache()
    notify("Carriles intercambiados")
end

local function duetSection()
    pushUndo()
    local sec = song.notes[currentSectionIndex]
    local extra = {}
    for _, raw in ipairs(sec.sectionNotes) do
        local m = deepCopy(raw)
        m[2] = m[2] < 4 and m[2] + 4 or m[2] - 4
        table.insert(extra, m)
    end
    for _, n in ipairs(extra) do table.insert(sec.sectionNotes, n) end
    rebuildNoteCache()
    notify("Sección en dueto")
end

local function mirrorNotes()
    if #selection.notes == 0 then notify("Sin notas seleccionadas"); return end
    pushUndo()
    for _, n in ipairs(selection.notes) do
        local side = n.raw[2] >= 4 and 4 or 0
        n.raw[2] = (3 - (n.raw[2] % 4)) + side
    end
    rebuildNoteCache()
    notify("Notas espejadas")
end

local function clearAllNotes()
    pushUndo()
    for _, sec in ipairs(song.notes) do sec.sectionNotes = {} end
    rebuildNoteCache()
    selection.notes = {}
    notify("Todas las notas eliminadas")
end

local function clearAllEvents()
    pushUndo()
    song.events = {}
    selection.event = nil
    notify("Todos los eventos eliminados")
end

-- ============================================================
-- Selección / portapapeles
-- ============================================================

local function isNoteSelected(n)
	for _, sn in ipairs(selection.notes) do
		if sn.raw == n.raw then return true end
	end
	return false
end

local function toggleNoteSelection(n)
	for i, sn in ipairs(selection.notes) do
		if sn.raw == n.raw then table.remove(selection.notes, i); return end
	end
	table.insert(selection.notes, n)
end

local function selectAllInSection()
	selection.notes = {}
	selection.event = nil
	for _, n in ipairs(noteCache) do
		if n.sectionIndex == currentSectionIndex then table.insert(selection.notes, n) end
	end
	notify("Seleccionadas " .. #selection.notes .. " notas")
end

local function copySelection()
	if #selection.notes == 0 and not selection.event then
		notify("Nada seleccionado para copiar")
		return
	end

	local minTime = math.huge
	for _, n in ipairs(selection.notes) do minTime = math.min(minTime, n.raw[1]) end
	if selection.event then minTime = math.min(minTime, selection.event[1]) end

	clipboard = {refTime = minTime, notes = {}, event = nil}

	for _, n in ipairs(selection.notes) do
		table.insert(clipboard.notes, {
			offset = n.raw[1] - minTime,
			lane = n.lane,
			isPlayerNote = n.isPlayerNote,
			length = n.raw[3] or 0,
			typeStr = n.raw[4],
		})
	end

	if selection.event then
		local ev = selection.event[2][1]
		clipboard.event = {offset = selection.event[1] - minTime, name = ev[1], value1 = ev[2], value2 = ev[3]}
	end

	notify("Copiado")
end

local function deleteSelection()
	if #selection.notes == 0 and not selection.event then
		notify("Nada seleccionado para eliminar")
		return
	end

	pushUndo()

	for _, n in ipairs(selection.notes) do
		local sec = song.notes[n.sectionIndex]
		for idx, raw in ipairs(sec.sectionNotes) do
			if raw == n.raw then table.remove(sec.sectionNotes, idx); break end
		end
	end

	if selection.event then
		for idx, e in ipairs(song.events) do
			if e == selection.event then table.remove(song.events, idx); break end
		end
	end

	selection.notes = {}
	selection.event = nil
	rebuildNoteCache()
end

local function cutSelection()
	if #selection.notes == 0 and not selection.event then
		notify("Nada seleccionado para cortar")
		return
	end
	copySelection()
	deleteSelection()
end

local function pasteClipboard()
	if not clipboard then notify("Portapapeles vacío"); return end

	pushUndo()

	local target = snapTime(musicTime)
	selection.notes = {}
	selection.event = nil

	for _, c in ipairs(clipboard.notes) do
		local t = target + c.offset
		local si = sectionIndexForTime(t)
		-- Inverso de rebuildNoteCache(): isPlayerNote == (noteData < 4),
		-- lane == noteData % 4 -- no depende de mustHitSection.
		local noteData = c.isPlayerNote and c.lane or (c.lane + 4)

		local newNote = {t, noteData, c.length}
		if c.typeStr then newNote[4] = c.typeStr end

		table.insert(song.notes[si].sectionNotes, newNote)
	end

	if clipboard.event then
		local t = target + clipboard.event.offset
		table.insert(song.events, {t, {{clipboard.event.name, clipboard.event.value1, clipboard.event.value2}}})
	end

	for _, sec in ipairs(song.notes) do
		table.sort(sec.sectionNotes, function(a, b) return a[1] < b[1] end)
	end
	table.sort(song.events, function(a, b) return a[1] < b[1] end)

	rebuildNoteCache()
	notify("Pegado")
end

local loadCharacterIcon  -- forward declaration; definida en la sección de carga más abajo
local initUI             -- forward declaration; definida después de todas las funciones de edición

local function cycleCharacter(field, default, prev)
	local cur = song[field] or default
	local idx = 1
	for i, name in ipairs(CHARACTER_NAMES) do
		if name == cur then idx = i; break end
	end
	idx = ((idx - 1 + (prev and -1 or 1)) % #CHARACTER_NAMES) + 1
	song[field] = CHARACTER_NAMES[idx]
	notify(field .. " = " .. song[field])
	if field == "player1" then playerIcon = loadCharacterIcon(song.player1) end
	if field == "player2" then opponentIcon = loadCharacterIcon(song.player2) end
end

local function cycleStage(prev)
	local cur = song.stage or "stage"
	local idx = 1
	for i, name in ipairs(STAGE_NAMES) do
		if name == cur then idx = i; break end
	end
	idx = ((idx - 1 + (prev and -1 or 1)) % #STAGE_NAMES) + 1
	song.stage = STAGE_NAMES[idx]
	notify("stage = " .. song.stage)
end

-- ============================================================
-- Audio
-- ============================================================

local function stripDifficulty(name)
	for _, pat in ipairs(DIFFICULTY_SUFFIXES) do
		local base = name:gsub(pat, "")
		if base ~= name then return base end
	end
	return name
end

-- Busca music/<base>/Inst.ogg (y su Voices.ogg) -- una carpeta por canción,
-- igual que Psych Engine real (assets/.../songs/<base>/Inst.ogg), ya no por
-- semana. Si no se encuentra y "base" tiene guiones (p.ej. "dad-battle"),
-- reintenta sin ellos ("dadbattle"), ya que algunos nombres de carpeta de
-- audio no coinciden con el nombre de la canción/carpeta del chart.
local function findAudio(base)
	if not love.filesystem.getInfo("music") then return nil, nil end

	local instPath = "music/" .. base .. "/Inst.ogg"
	if love.filesystem.getInfo(instPath) then
		local voxPath = "music/" .. base .. "/Voices.ogg"
		return instPath, love.filesystem.getInfo(voxPath) and voxPath or nil
	end

	if base:find("-") then
		return findAudio((base:gsub("-", "")))
	end

	return nil, nil
end

local function stopPlayback()
	if inst then inst:stop() end
	if voices then voices:stop() end
	playing = false
end

local function loadAudio()
	stopPlayback()
	inst, voices = nil, nil

	local fileName = currentRelPath:match("([^/]+)$") or currentRelPath
	local base = stripDifficulty(fileName)
	local instPath, voxPath = findAudio(base)

	if instPath then
		inst = love.audio.newSource(instPath, "stream")
		if voxPath then voices = love.audio.newSource(voxPath, "stream") end
	else
		notify("No se encontró audio para '" .. base .. "'", 3)
	end
end

local function togglePlayback()
	if not inst then notify("No hay audio cargado"); return end

	if playing then
		inst:pause()
		if voices then voices:pause() end
		playing = false
	else
		inst:seek(musicTime / 1000)
		if voices then voices:seek(musicTime / 1000) end
		inst:play()
		if voices then voices:play() end
		playing = true
		hitNotesProcessed = {}
	end
end

-- ============================================================
-- Carga / guardado del chart
-- ============================================================

loadCharacterIcon = function(charName)
	if not charName or charName == "" then return nil end
	local path = "images/png/icons/icon-" .. charName .. ".png"
	if not love.filesystem.getInfo(path) then return nil end
	local ok, img = pcall(love.graphics.newImage, path)
	if not ok then return nil end
	local w, h = img:getDimensions()
	local faceW = math.floor(w / 2)
	local quad = love.graphics.newQuad(0, 0, faceW, h, w, h)
	return {image = img, quad = quad, faceW = faceW, faceH = h}
end

local function loadArrowSprites()
	images = {notes = love.graphics.newImage(graphics.imagePath("notes"))}

	arrowSprites = {
		love.filesystem.load("sprites/left-arrow.lua"),
		love.filesystem.load("sprites/down-arrow.lua"),
		love.filesystem.load("sprites/up-arrow.lua"),
		love.filesystem.load("sprites/right-arrow.lua"),
	}

	enemyArrows = {}
	playerArrows = {}
	noteStampSprites = {}

	for i = 1, 4 do
		enemyArrows[i] = arrowSprites[i]()
		playerArrows[i] = arrowSprites[i]()
		noteStampSprites[i] = arrowSprites[i]()

		enemyArrows[i].x = ENEMY_START_X + (i - 1) * LANE_WIDTH + LANE_WIDTH / 2
		playerArrows[i].x = PLAYER_START_X + (i - 1) * LANE_WIDTH + LANE_WIDTH / 2
		enemyArrows[i].y = STRUMLINE_Y
		playerArrows[i].y = STRUMLINE_Y

		-- 40/154 ≈ 0.26: nota/flecha cabe exactamente en un carril de 40px (= GRID_SIZE de Psych)
		enemyArrows[i].sizeX, enemyArrows[i].sizeY = 0.26, 0.26
		playerArrows[i].sizeX, playerArrows[i].sizeY = 0.26, 0.26
		noteStampSprites[i].sizeX, noteStampSprites[i].sizeY = 0.26, 0.26

		enemyArrows[i]:animate("off", false)
		playerArrows[i]:animate("off", false)
		noteStampSprites[i]:animate("on", false)
	end
end

local function refreshNoteTypesList()
	noteTypesList = {}
	for _, t in ipairs(BUILTIN_NOTE_TYPES) do table.insert(noteTypesList, t) end
	for _, name in ipairs(notetypes.list()) do table.insert(noteTypesList, name) end
	currentNoteTypeIndex = 1
end

local function scanChartFiles()
	fileList = {}

	local function scan(dir)
		for _, item in ipairs(love.filesystem.getDirectoryItems(dir)) do
			local path = dir .. "/" .. item
			local info = love.filesystem.getInfo(path)
			if info then
				if info.type == "directory" then
					scan(path)
				elseif info.type == "file" and item:match("%.json$") then
					table.insert(fileList, path:sub(#"data/" + 1, -(#".json" + 1)))
				end
			end
		end
	end

	if love.filesystem.getInfo("data") then scan("data") end

	table.sort(fileList)
	selectedFile = math.min(selectedFile, math.max(1, #fileList))
	listScroll = 0
end

local function loadChart(relPath)
	local fullPath = "data/" .. relPath .. ".json"
	local raw = love.filesystem.read(fullPath)
	if not raw then notify("No se pudo leer " .. fullPath, 3); return end

	local ok, decoded = pcall(json.decode, raw)
	if not ok or type(decoded) ~= "table" then
		notify("JSON inválido en " .. fullPath, 3)
		return
	end

	rawDecoded = decoded
	-- BUG real (formato "psych_v1_convert" de Psych Engine nuevo): "song"
	-- ahí es el STRING del título, no una tabla anidada -- tratarlo como
	-- wrapper sin chequear el tipo hacía que `song` terminara siendo ese
	-- string, y `song.notes` explotaba. Ver charts/psych/loader.lua:
	-- unwrapSongData() (mismo fix, mismo bug).
	song = (type(rawDecoded.song) == "table" and rawDecoded.song) or rawDecoded
	song.notes = song.notes or {}
	song.events = song.events or {}
	for _, sec in ipairs(song.notes) do
		sec.sectionNotes = sec.sectionNotes or {}
	end

	-- json.decode convierte "null" en nil, así que claves con valor null en
	-- el chart (común en gfVersion/stage de charts viejos) directamente no
	-- existen en `song` -- aplicar los mismos valores por defecto que ya usa
	-- json.decode convierte "null" en nil (clave ausente); aplicar defaults
	-- para que el HUD no muestre "nil" en gfVersion/stage.
	song.player1 = song.player1 or "bf"
	song.player2 = song.player2 or "dad"
	song.gfVersion = song.gfVersion or "gf"
	song.stage = song.stage or "stage"

	opponentIcon = loadCharacterIcon(song.player2)
	playerIcon = loadCharacterIcon(song.player1)

	currentPath = fullPath
	currentRelPath = relPath
	currentSectionIndex = 1
	musicTime = 0
	selection.notes = {}
	selection.event = nil
	undoStack = {}
	redoStack = {}
	clipboard = nil
	hitNotesProcessed = {}

	recomputeSectionTimes()
	rebuildNoteCache()
	refreshNoteTypesList()
	loadAudio()

	mode = "editor"
	notify("Chart cargado: " .. relPath, 3)

	initUI()
end

local function saveChart()
	if not currentPath then notify("No hay chart cargado"); return end

	local ok, str = pcall(json.encode, rawDecoded)
	if not ok then
		notify("Error al codificar JSON: " .. tostring(str), 4)
		return
	end

	if love.filesystem.getInfo(currentPath) then
		love.filesystem.write(currentPath .. ".bkp", love.filesystem.read(currentPath))
	end

	local written = love.filesystem.write(currentPath, str)
	if written then
		notify("Guardado: " .. currentPath, 2.5)
	else
		notify("Error al guardar " .. currentPath, 3)
	end
end

local function testPlay()
	if not currentRelPath then return end

	local file = currentRelPath:match("^.+/(.+)$") or currentRelPath

	-- Separar sufijo de dificultad (p.ej. "bopeebo-hard" -> "bopeebo"+"-hard")
	-- usando DIFFICULTY_SUFFIXES, NO un patrón genérico "-letras": nombres de
	-- canción como "dad-battle" tienen guiones que no son sufijos de dificultad.
	local base, suffix = file, ""
	for _, pat in ipairs(DIFFICULTY_SUFFIXES) do
		local stripped = file:gsub(pat, "")
		if stripped ~= file then
			base = stripped
			suffix = file:sub(#stripped + 1)
			break
		end
	end

	local entry = TESTPLAY_MAP[base]
	if not entry then
		notify("'" .. base .. "' no está portado a ningún week todavía", 3)
		return
	end

	saveChart()
	stopPlayback()

	-- Pasar el song en memoria al week vía global para que los cambios del
	-- editor se usen directamente sin depender del round-trip a disco.
	_G.chartEditorPreviewSong = rawDecoded
	_G.chartEditorReturn = true

	goingToTestPlay = true
	Gamestate.switch(require(entry.module), entry.songNum, suffix, false, base)
end

-- ============================================================
-- Edición de secciones
-- ============================================================

local function setSection(idx)
	currentSectionIndex = math.max(1, math.min(idx, #song.notes))
	musicTime = sectionTimes[currentSectionIndex] or 0
end

local function changeSection(delta)
	setSection(currentSectionIndex + delta)
end

local function scrubByStep(dir)
	musicTime = math.max(0, stepToTime(timeToStep(musicTime) + dir * quantStepCount()))
	currentSectionIndex = sectionIndexForTime(musicTime)
end

local function toggleMustHit()
	pushUndo()
	local sec = song.notes[currentSectionIndex]
	sec.mustHitSection = not (sec.mustHitSection or false)
	rebuildNoteCache()
end

local function toggleGfSection()
	pushUndo()
	local sec = song.notes[currentSectionIndex]
	sec.gfSection = not (sec.gfSection or false)
end

local function toggleAltAnim()
	pushUndo()
	local sec = song.notes[currentSectionIndex]
	sec.altAnim = not (sec.altAnim or false)
end

local function toggleChangeBpm()
	if currentSectionIndex == 1 then
		notify("La sección 1 siempre define el BPM inicial (usa -/=)")
		return
	end

	pushUndo()
	local sec = song.notes[currentSectionIndex]
	sec.changeBPM = not (sec.changeBPM or false)
	if sec.changeBPM and not sec.bpm then
		sec.bpm = sectionBpms[currentSectionIndex - 1] or song.bpm or 100
	end
	recomputeSectionTimes()
end

local function adjustSectionBeats(delta)
	pushUndo()
	local sec = song.notes[currentSectionIndex]
	sec.sectionBeats = math.max(1, (sec.sectionBeats or 4) + delta)
	recomputeSectionTimes()
end

local function adjustBpm(delta)
	local sec = song.notes[currentSectionIndex]

	if currentSectionIndex == 1 then
		pushUndo()
		song.bpm = math.max(1, (song.bpm or 100) + delta)
		sec.bpm = song.bpm
		recomputeSectionTimes()
	elseif sec.changeBPM then
		pushUndo()
		sec.bpm = math.max(1, (sec.bpm or 100) + delta)
		recomputeSectionTimes()
	else
		notify("Activa 'changeBPM' (B) para cambiar el BPM de esta sección")
	end
end

local function adjustSpeed(delta)
	pushUndo()
	song.speed = math.max(0.1, math.floor(((song.speed or 1) + delta) * 100 + 0.5) / 100)
end

local function insertSection()
	pushUndo()
	local cur = song.notes[currentSectionIndex]
	local newSec = {mustHitSection = not (cur.mustHitSection or false), sectionNotes = {}}
	if cur.sectionBeats then newSec.sectionBeats = cur.sectionBeats end

	table.insert(song.notes, currentSectionIndex + 1, newSec)
	currentSectionIndex = currentSectionIndex + 1
	recomputeSectionTimes()
	rebuildNoteCache()
	musicTime = sectionTimes[currentSectionIndex]
	notify("Sección insertada")
end

local function duplicateSection()
	pushUndo()
	local newSec = deepCopy(song.notes[currentSectionIndex])

	table.insert(song.notes, currentSectionIndex + 1, newSec)
	currentSectionIndex = currentSectionIndex + 1
	recomputeSectionTimes()
	rebuildNoteCache()
	musicTime = sectionTimes[currentSectionIndex]
	notify("Sección duplicada")
end

local function deleteCurrentSection()
	if #song.notes <= 1 then notify("No se puede eliminar la última sección"); return end

	pushUndo()
	table.remove(song.notes, currentSectionIndex)
	if currentSectionIndex > #song.notes then currentSectionIndex = #song.notes end
	recomputeSectionTimes()
	rebuildNoteCache()
	musicTime = sectionTimes[currentSectionIndex]
	notify("Sección eliminada")
end

-- ============================================================
-- Tipos de nota
-- ============================================================

local function cycleNoteType(dir)
	currentNoteTypeIndex = ((currentNoteTypeIndex - 1 + dir) % #noteTypesList) + 1
	local t = noteTypesList[currentNoteTypeIndex]
	notify("Tipo de nota: " .. (t == "" and "(normal)" or t))
end

local function applyNoteTypeToSelection()
	if #selection.notes == 0 then notify("Sin notas seleccionadas"); return end

	pushUndo()
	local t = noteTypesList[currentNoteTypeIndex]
	for _, n in ipairs(selection.notes) do
		if t == "" then
			n.raw[4] = nil
		else
			n.raw[4] = t
		end
	end
	rebuildNoteCache()
	notify("Tipo aplicado a " .. #selection.notes .. " notas")
end

-- ============================================================
-- Eventos: catálogo, colocación, edición de valores
-- ============================================================

local function cycleEventCatalog(dir)
	currentEventIndex = ((currentEventIndex - 1 + dir) % #EVENT_CATALOG) + 1
	notify("Evento: " .. EVENT_CATALOG[currentEventIndex].name)
end


-- ============================================================
-- Búsqueda de notas/eventos bajo el cursor
-- ============================================================

local function findNoteAt(mx, my)
	for _, n in ipairs(noteCache) do
		local x = laneX(n.lane, n.isPlayerNote)
		local y = noteDisplayY(n.time)
		if y >= LANE_Y_TOP - 25 and y <= LANE_Y_TOP + LANE_HEIGHT + 25
			and math.abs(mx - x) <= LANE_WIDTH / 2 and math.abs(my - y) <= 18 then
			return n
		end
	end
	return nil
end

local function findEventAt(mx, my)
	local x = EVENT_LANE_X + LANE_WIDTH / 2
	if math.abs(mx - x) > LANE_WIDTH / 2 then return nil end

	for _, entry in ipairs(song.events) do
		local y = noteDisplayY(entry[1])
		if math.abs(y - my) <= 14 then return entry end
	end
	return nil
end

-- ============================================================
-- GUI estilo Psych Engine
-- ============================================================

initUI = function()
    UI.reset()

    local charItems = {}
    for _, name in ipairs(CHARACTER_NAMES) do
        table.insert(charItems, {name, name})
    end
    local stageItems = {}
    for _, name in ipairs(STAGE_NAMES) do
        table.insert(stageItems, {name, name})
    end
    local eventItems = {}
    for i, ev in ipairs(EVENT_CATALOG) do
        table.insert(eventItems, {ev.name, i})
    end

    -- Tab Song
    local tabSong = {
        UI.Input("Song name:", function() return song.song or "" end,
            function(v) song.song = v end),
        UI.Sep(),
        UI.Stepper("BPM:", function() return song.bpm or 100 end,
            function(v) song.bpm = math.max(1, v); recomputeSectionTimes() end,
            1, 999, 1, 0),
        UI.Stepper("Speed:", function() return song.speed or 1 end,
            function(v) song.speed = math.max(0.1, v) end,
            0.1, 10, 0.1, 2),
        UI.Sep(),
        UI.Dropdown("Player 1:", function() return song.player1 end,
            function(v) song.player1 = v; playerIcon = loadCharacterIcon(v) end, charItems),
        UI.Dropdown("Player 2:", function() return song.player2 end,
            function(v) song.player2 = v; opponentIcon = loadCharacterIcon(v) end, charItems),
        UI.Dropdown("GF Version:", function() return song.gfVersion end,
            function(v) song.gfVersion = v end, charItems),
        UI.Dropdown("Stage:", function() return song.stage end,
            function(v) song.stage = v end, stageItems),
        UI.Sep(),
        UI.Checkbox("Allow Vocals",
            function() return song.needsVoices ~= false end,
            function(v) song.needsVoices = v end),
        UI.Button("Reload Audio", function()
            loadAudio()
            if inst   then inst:setVolume(instVolume) end
            if voices then voices:setVolume(vocalsVolume) end
            notify("Audio recargado")
        end),
    }

    -- Tab Section
    local tabSection = {
        UI.Checkbox("Must Hit Section",
            function() return (song.notes[currentSectionIndex] or {}).mustHitSection or false end,
            function(v)
                pushUndo()
                song.notes[currentSectionIndex].mustHitSection = v
                rebuildNoteCache()
            end),
        UI.Checkbox("GF Section",
            function() return (song.notes[currentSectionIndex] or {}).gfSection or false end,
            function(v) pushUndo(); song.notes[currentSectionIndex].gfSection = v end),
        UI.Checkbox("Alt Animation",
            function() return (song.notes[currentSectionIndex] or {}).altAnim or false end,
            function(v) pushUndo(); song.notes[currentSectionIndex].altAnim = v end),
        UI.Sep(),
        UI.Checkbox("Change BPM",
            function() return (song.notes[currentSectionIndex] or {}).changeBPM or false end,
            function() toggleChangeBpm() end),
        UI.Stepper("Section BPM:",
            function()
                local sec = song.notes[currentSectionIndex] or {}
                return sec.bpm or sectionBpms[currentSectionIndex] or song.bpm or 100
            end,
            function(v)
                local sec = song.notes[currentSectionIndex] or {}
                if sec.changeBPM then
                    pushUndo(); sec.bpm = math.max(1, v); recomputeSectionTimes()
                else
                    notify("Activa 'Change BPM' primero")
                end
            end, 1, 999, 1, 0),
        UI.Stepper("Beats/Section:",
            function() return (song.notes[currentSectionIndex] or {}).sectionBeats or 4 end,
            function(v)
                local cur = (song.notes[currentSectionIndex] or {}).sectionBeats or 4
                adjustSectionBeats(v - cur)
            end, 1, 16, 1, 0),
        UI.Sep(),
        UI.Button("Copy Section",      function() copySection() end),
        UI.Button("Paste Section",     function() pasteSection() end),
        UI.Button("Clear Section",     function() clearSection() end),
        UI.Sep(),
        UI.Stepper("Copy Offset:",
            function() return copyLastSecOffset end,
            function(v) copyLastSecOffset = math.max(1, math.floor(v + 0.5)) end,
            1, 100, 1, 0),
        UI.Button("Copy Last Section", function() copyLastSection() end),
        UI.Sep(),
        UI.Button("Swap Section",  function() swapSection() end),
        UI.Button("Duet Section",  function() duetSection() end),
        UI.Button("Mirror Notes",  function() mirrorNotes() end),
    }

    -- Tab Note
    local tabNote = {
        UI.Label(function()
            if #selection.notes == 0 then return "No note selected" end
            local n = selection.notes[1]
            return string.format("@ %.0f ms  lane %d  %s",
                n.raw[1], n.lane, n.isPlayerNote and "(player)" or "(enemy)")
        end),
        UI.Sep(),
        UI.Stepper("Sustain Length (ms):",
            function() return #selection.notes > 0 and (selection.notes[1].raw[3] or 0) or 0 end,
            function(v)
                if #selection.notes > 0 then
                    pushUndo(); selection.notes[1].raw[3] = math.max(0, v)
                end
            end, 0, 100000, 1, 0),
        UI.Stepper("Strum Time (ms):",
            function() return #selection.notes > 0 and selection.notes[1].raw[1] or 0 end,
            function(v)
                if #selection.notes > 0 then
                    pushUndo(); selection.notes[1].raw[1] = math.max(0, v)
                    rebuildNoteCache()
                end
            end, 0, 9999999, 1, 0),
        UI.Sep(),
        UI.Dropdown("Note Type:",
            function() return noteTypesList[currentNoteTypeIndex] or "" end,
            function(v)
                for i, t in ipairs(noteTypesList) do
                    if t == v then currentNoteTypeIndex = i; break end
                end
            end,
            (function()
                local items = {}
                for _, t in ipairs(noteTypesList) do
                    table.insert(items, {t == "" and "(normal)" or t, t})
                end
                return items
            end)()),
        UI.Button("Apply Type to Selection", function() applyNoteTypeToSelection() end),
    }

    -- Tab Events
    local tabEvents = {
        UI.Dropdown("Event Type:",
            function() return currentEventIndex end,
            function(v) currentEventIndex = v; notify("Evento: " .. EVENT_CATALOG[v].name) end,
            eventItems),
        UI.Label(function() return EVENT_CATALOG[currentEventIndex].desc end, {height = 24}),
        UI.Sep(),
        UI.Label("Selected event values:"),
        UI.Input("Value 1:",
            function()
                if selection.event then return tostring(selection.event[2][1][2] or "") end
                return ""
            end,
            function(v) if selection.event then pushUndo(); selection.event[2][1][2] = v end end),
        UI.Input("Value 2:",
            function()
                if selection.event then return tostring(selection.event[2][1][3] or "") end
                return ""
            end,
            function(v) if selection.event then pushUndo(); selection.event[2][1][3] = v end end),
        UI.Sep(),
        UI.Button("< Prev Event", function()
            if #song.events == 0 then return end
            if not selection.event then selection.event = song.events[#song.events]; return end
            for i, e in ipairs(song.events) do
                if e == selection.event then
                    if i > 1 then selection.event = song.events[i-1] end; return
                end
            end
        end),
        UI.Button("> Next Event", function()
            if #song.events == 0 then return end
            if not selection.event then selection.event = song.events[1]; return end
            for i, e in ipairs(song.events) do
                if e == selection.event then
                    if i < #song.events then selection.event = song.events[i+1] end; return
                end
            end
        end),
    }

    -- Tab Charting
    local tabCharting = {
        UI.Slider("Playback Rate:",
            function() return playbackRate end,
            function(v)
                playbackRate = math.max(0.1, math.min(5.0, v))
                if inst   then inst:setPitch(playbackRate) end
                if voices then voices:setPitch(playbackRate) end
            end, 0.1, 5.0, 2),
        UI.Sep(),
        UI.Stepper("Inst Volume:",
            function() return instVolume end,
            function(v)
                instVolume = math.max(0, math.min(1, v))
                if inst then inst:setVolume(instVolume) end
            end, 0, 1, 0.1, 1),
        UI.Stepper("Vocals Volume:",
            function() return vocalsVolume end,
            function(v)
                vocalsVolume = math.max(0, math.min(1, v))
                if voices then voices:setVolume(vocalsVolume) end
            end, 0, 1, 0.1, 1),
    }

    mainBox = UI.Box(642, 5, 632, 710, {
        title    = "Chart Editor",
        tabs     = {"Song", "Section", "Note", "Events", "Charting", "View"},
        contents = {tabSong, tabSection, tabNote, tabEvents, tabCharting,
                    {UI.Label("View options coming soon.")}},
    })

    -- upperBox: File / Edit (minimizado por defecto)
    local tabFile = {
        UI.Button("Save  (Ctrl+S)",     function() saveChart() end),
        UI.Button("Reload Chart",       function()
            if currentRelPath then loadChart(currentRelPath) end
        end),
        UI.Button("Test Play  (Enter)", function() testPlay() end),
        UI.Sep(),
        UI.Button("Exit to Browser",    function()
            stopPlayback(); scanChartFiles(); mode = "browser"
        end),
    }
    local tabEdit = {
        UI.Button("Undo  (Ctrl+Z)",       function() performUndo() end),
        UI.Button("Redo  (Ctrl+Y)",       function() performRedo() end),
        UI.Button("Select All  (Ctrl+A)", function() selectAllInSection() end),
        UI.Sep(),
        UI.Button("Clear All Notes",  function() clearAllNotes()  end, {style = "red"}),
        UI.Button("Clear All Events", function() clearAllEvents() end, {style = "red"}),
    }
    upperBox = UI.Box(5, 5, 252, 220, {
        title     = "File / Edit",
        tabs      = {"File", "Edit"},
        contents  = {tabFile, tabEdit},
        minimized = true,
    })

    -- infoBox: info en tiempo real (sin arrastre)
    infoBox = UI.Box(5, 580, 252, 130, {
        title     = "Info",
        draggable = false,
        infoLines = function()
            if not song then return {"No chart loaded"} end
            local bpmSec = sectionBpms[currentSectionIndex] or song.bpm or 100
            return {
                string.format("Time:    %.0f ms", musicTime),
                string.format("Section: %d / %d", currentSectionIndex, #song.notes),
                string.format("Beat:    %.2f", timeToStep(musicTime) / 4),
                string.format("Step:    %.0f", timeToStep(musicTime)),
                string.format("BPM:     %d   Speed: %.2f", bpmSec, song.speed or 1),
                string.format("Snap:    1/%d   Zoom: %.2gx",
                    QUANTIZATIONS[quantIndex], ZOOM_LEVELS[zoomIndex]),
                string.format("Sel:     %d note%s%s",
                    #selection.notes,
                    #selection.notes == 1 and "" or "s",
                    selection.event and " + event" or ""),
            }
        end,
    })

    UI.registerBox(infoBox)
    UI.registerBox(upperBox)
    UI.registerBox(mainBox)
end

-- ============================================================
-- Callbacks de LÖVE
-- ============================================================

function state:enter()
	graphics = graphics or require("modules.graphics")
	Timer = Timer or require("lib.timer")

	UI.init()
	loadArrowSprites()
	refreshNoteTypesList()

	if goingToTestPlay then
		-- Regreso desde test-play: el song en memoria sigue siendo el más
		-- reciente (no se tocó), así que solo reanudar el modo editor.
		goingToTestPlay = false
		_G.chartEditorReturn = nil
		hitNotesProcessed = {}
		mode = "editor"
	else
		scanChartFiles()
		mode = "browser"
	end

	showHelp = false
	graphics.fadeIn(0.5)

	if _G.music then _G.music:pause() end
end

function state:textinput(text)
	if mode ~= "editor" then return end
	UI.textinput(text)
end

function state:leave()
	stopPlayback()
	if _G.music and not goingToTestPlay then _G.music:play() end
end

function state:wheelmoved(_, y)
	if mode ~= "editor" then return end
	if UI.wheelmoved(0, y) then return end
	if playing then return end

	local steps = (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) and 1 or 4
	scrubByStep(y > 0 and -steps or steps)
end

function state:mousepressed(x, y, button)
	if mode ~= "editor" then return end
	if showHelp then showHelp = false; return end
	if UI.mousepressed(x, y, button) then return end

	-- Bolita de mustHitSection: ahora está fija encima del icono del personaje
	local ballX0 = song.notes[currentSectionIndex].mustHitSection and MUSTHIT_PLAYER_X or MUSTHIT_ENEMY_X
	local ballY0 = ICON_Y + ICON_SIZE / 2
	if button == 1 and math.abs(x - ballX0) <= ICON_SIZE / 2 and math.abs(y - ballY0) <= ICON_SIZE / 2 then
		toggleMustHit()
		return
	end

	local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
	local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")

	-- Carril de eventos
	if x >= EVENT_LANE_X and x <= EVENT_LANE_X + LANE_WIDTH and y >= LANE_Y_TOP and y <= LANE_Y_TOP + LANE_HEIGHT then
		local ev = findEventAt(x, y)

		if button == 1 then
			if ev then
				selection.notes = {}
				selection.event = ev
			elseif not ctrl then
				pushUndo()
				local t = shift and timeAtY(y) or placeTimeAtY(y)
				local newEntry = {t, {{EVENT_CATALOG[currentEventIndex].name, "", ""}}}
				table.insert(song.events, newEntry)
				table.sort(song.events, function(a, b) return a[1] < b[1] end)
				selection.notes = {}
				selection.event = newEntry
			end
		elseif button == 2 and ev then
			pushUndo()
			for idx, e in ipairs(song.events) do
				if e == ev then table.remove(song.events, idx); break end
			end
			if selection.event == ev then selection.event = nil end
		end

		return
	end

	-- Carriles de notas
	local lane, isPlayerNote
	if x >= ENEMY_START_X and x < ENEMY_START_X + LANE_WIDTH * LANE_COUNT and y >= LANE_Y_TOP and y <= LANE_Y_TOP + LANE_HEIGHT then
		lane, isPlayerNote = math.floor((x - ENEMY_START_X) / LANE_WIDTH), false
	elseif x >= PLAYER_START_X and x < PLAYER_START_X + LANE_WIDTH * LANE_COUNT and y >= LANE_Y_TOP and y <= LANE_Y_TOP + LANE_HEIGHT then
		lane, isPlayerNote = math.floor((x - PLAYER_START_X) / LANE_WIDTH), true
	end

	if not lane then return end

	local n = findNoteAt(x, y)

	if button == 1 then
		if n then
			if ctrl then
				pushUndo()
				sustainDrag = n
			elseif shift then
				toggleNoteSelection(n)
				selection.event = nil
			else
				selection.notes = {n}
				selection.event = nil
			end
		elseif ctrl then
			-- Ctrl+arrastre en área vacía = selección rectangular
			boxSelectStart = {x = x, y = y}
			boxSelectEnd = {x = x, y = y}
		else
			pushUndo()
			-- Shift = colocación libre (sin snapping); sin Shift = floor-snapped a la celda
			local t = shift and timeAtY(y) or placeTimeAtY(y)
			local si = sectionIndexForTime(t)
			-- Inverso de rebuildNoteCache(): isPlayerNote == (noteData < 4),
			-- lane == noteData % 4 -- no depende de mustHitSection.
			local noteData = isPlayerNote and lane or (lane + 4)

			local newNote = {t, noteData, 0}
			local typeStr = noteTypesList[currentNoteTypeIndex]
			if typeStr ~= "" then newNote[4] = typeStr end

			table.insert(song.notes[si].sectionNotes, newNote)
			table.sort(song.notes[si].sectionNotes, function(a, b) return a[1] < b[1] end)
			rebuildNoteCache()

			selection.event = nil
			selection.notes = {}
			for _, nn in ipairs(noteCache) do
				if nn.raw == newNote then table.insert(selection.notes, nn); break end
			end
		end
	elseif button == 2 and n then
		pushUndo()
		local sec = song.notes[n.sectionIndex]
		for idx, raw in ipairs(sec.sectionNotes) do
			if raw == n.raw then table.remove(sec.sectionNotes, idx); break end
		end
		rebuildNoteCache()
		selection.notes = {}
	end
end

function state:mousemoved(x, y)
	if mode ~= "editor" then return end
	if UI.mousemoved(x, y) then return end

	if sustainDrag then
		local t = snapTime(timeAtY(y))
		sustainDrag.raw[3] = math.max(0, t - sustainDrag.raw[1])
	elseif boxSelectStart then
		boxSelectEnd = {x = x, y = y}
	end
end

function state:mousereleased(x, y, btn)
	UI.mousereleased(x, y, btn)
	if mode ~= "editor" then return end

	if sustainDrag then
		sustainDrag = nil
		rebuildNoteCache()
	end

	if boxSelectStart and boxSelectEnd then
		local x1, x2 = math.min(boxSelectStart.x, boxSelectEnd.x), math.max(boxSelectStart.x, boxSelectEnd.x)
		local y1, y2 = math.min(boxSelectStart.y, boxSelectEnd.y), math.max(boxSelectStart.y, boxSelectEnd.y)

		for _, n in ipairs(noteCache) do
			local nx, ny = laneX(n.lane, n.isPlayerNote), noteDisplayY(n.time)
			if nx >= x1 and nx <= x2 and ny >= y1 and ny <= y2 and not isNoteSelected(n) then
				table.insert(selection.notes, n)
			end
		end
	end

	boxSelectStart = nil
	boxSelectEnd = nil
end

function state:keypressed(key)
	if mode == "browser" then
		if key == "up" then
			selectedFile = selectedFile - 1
			if selectedFile < 1 then selectedFile = #fileList end
		elseif key == "down" then
			selectedFile = selectedFile + 1
			if selectedFile > #fileList then selectedFile = 1 end
		elseif key == "return" and #fileList > 0 then
			loadChart(fileList[selectedFile])
		elseif key == "escape" then
			Gamestate.switch(require("states.debug-menu"))
		end

		if selectedFile < listScroll + 1 then listScroll = selectedFile - 1
		elseif selectedFile > listScroll + VISIBLE_ITEMS then listScroll = selectedFile - VISIBLE_ITEMS end
		listScroll = math.max(0, math.min(listScroll, math.max(0, #fileList - VISIBLE_ITEMS)))

		return
	end

	-- mode == "editor"

	if showHelp then
		if key == "f1" or key == "escape" then showHelp = false end
		return
	end

	if UI.keypressed(key) then return end

	if key == "f1" then showHelp = true; return end

	if key == "escape" then
		stopPlayback()
		scanChartFiles()
		mode = "browser"
		return
	end

	local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
	local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")

	if ctrl then
		if key == "s" then saveChart(); return
		elseif key == "c" then copySelection(); return
		elseif key == "x" then cutSelection(); return
		elseif key == "v" then pasteClipboard(); return
		elseif key == "a" then selectAllInSection(); return
		elseif key == "z" then
			if shift then performRedo() else performUndo() end
			return
		elseif key == "y" then performRedo(); return
		elseif key == "backspace" then deleteCurrentSection(); return
		end
	end

	if key == "space" then togglePlayback(); return end
	if key == "return" then testPlay(); return end
	if key == "delete" or key == "backspace" then deleteSelection(); return end

	-- Navegación de secciones
	if key == "a" then changeSection(shift and -4 or -1); return end
	if key == "d" then changeSection(shift and 4 or 1); return end
	if key == "home" then setSection(1); return end
	if key == "end" then setSection(#song.notes); return end

	-- Cuantización / zoom / scrub fino
	if key == "left" then quantIndex = math.max(1, quantIndex - 1); notify("Cuantización: 1/" .. QUANTIZATIONS[quantIndex]); return end
	if key == "right" then quantIndex = math.min(#QUANTIZATIONS, quantIndex + 1); notify("Cuantización: 1/" .. QUANTIZATIONS[quantIndex]); return end
	if key == "z" then zoomIndex = math.max(1, zoomIndex - 1); notify("Zoom: " .. ZOOM_LEVELS[zoomIndex] .. "x"); return end
	if key == "x" then zoomIndex = math.min(#ZOOM_LEVELS, zoomIndex + 1); notify("Zoom: " .. ZOOM_LEVELS[zoomIndex] .. "x"); return end
	if key == "up" then scrubByStep(-1); return end
	if key == "down" then scrubByStep(1); return end

	-- Tipos de nota
	if key == "q" then cycleNoteType(-1); return end
	if key == "e" then cycleNoteType(1); return end
	if key == "r" then applyNoteTypeToSelection(); return end

	-- Propiedades de sección
	if key == "m" then toggleMustHit(); return end
	if key == "g" then toggleGfSection(); return end
	if key == "v" then toggleAltAnim(); return end
	if key == "b" then toggleChangeBpm(); return end
	if key == "[" then adjustSectionBeats(-1); return end
	if key == "]" then adjustSectionBeats(1); return end
	if key == "-" then adjustBpm(shift and -10 or -1); return end
	if key == "=" then adjustBpm(shift and 10 or 1); return end
	if key == "," then adjustSpeed(-0.1); return end
	if key == "." then adjustSpeed(0.1); return end

	if key == "n" then
		if shift then duplicateSection() else insertSection() end
		return
	end

	-- Eventos
	if key == "tab" then cycleEventCatalog(shift and -1 or 1); return end

	-- Personajes / stage
	if key == "f2" then cycleCharacter("player1", "bf", shift); return end
	if key == "f3" then cycleCharacter("player2", "dad", shift); return end
	if key == "f4" then cycleCharacter("gfVersion", "gf", shift); return end
	if key == "f6" then cycleStage(shift); return end
end

function state:update(dt)
	if graphics.isFading() then return end

	if notification.timer > 0 then notification.timer = notification.timer - dt end

	if mode ~= "editor" then return end

	if playing and inst then
		local newTime = inst:tell("seconds") * 1000

		for _, n in ipairs(noteCache) do
			if n.time >= musicTime and n.time < newTime and not hitNotesProcessed[n.raw] then
				hitNotesProcessed[n.raw] = true
				local arrows = n.isPlayerNote and playerArrows or enemyArrows
				local a = arrows[n.lane + 1]
				a:animate("confirm", false)
				Timer.after(0.15, function() a:animate("off", false) end)
			end
		end

		musicTime = newTime
		currentSectionIndex = sectionIndexForTime(musicTime)

		if not inst:isPlaying() then playing = false end
	end
end

-- ============================================================
-- Dibujado
-- ============================================================

local function drawBrowser()
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("EDITOR DE CHARTS - selecciona un archivo en data/", 50, 40)

	if #fileList == 0 then
		love.graphics.setColor(1, 0.3, 0.3)
		love.graphics.print("No se encontraron archivos .json en data/", 70, 90)
	else
		local from = listScroll + 1
		local to = math.min(from + VISIBLE_ITEMS - 1, #fileList)

		for i = from, to do
			local y = 80 + (i - from) * 24
			if i == selectedFile then
				love.graphics.setColor(1, 1, 0)
				love.graphics.print("> " .. fileList[i], 60, y)
			else
				love.graphics.setColor(0.8, 0.8, 0.8)
				love.graphics.print(fileList[i], 60, y)
			end
		end
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Arriba/Abajo: navegar | Enter: abrir | Escape: volver al menú de debug", 50, graphics.getHeight() - 40)
end

local function drawGrid()
	local conductorStep = timeToStep(musicTime)
	local pps = pixelsPerStep()
	local halfH = LANE_HEIGHT / 2
	local minStep = conductorStep - halfH / pps
	local maxStep = conductorStep + halfH / pps

	for si = 1, #song.notes do
		local s0 = sectionSteps[si]
		local s1 = sectionSteps[si + 1]
		        or (s0 + (song.notes[si].sectionBeats or 4) * 4)
		if s1 < minStep or s0 > maxStep then goto nextSec end

		-- Línea de límite de sección (inicio)
		local boundY = STRUMLINE_Y + (s0 - conductorStep) * pps
		if boundY >= LANE_Y_TOP and boundY <= LANE_Y_TOP + LANE_HEIGHT then
			love.graphics.setColor(1, 1, 1, 0.9)
			love.graphics.setLineWidth(2)
			love.graphics.line(ENEMY_START_X, boundY, ENEMY_START_X + LANE_WIDTH * LANE_COUNT, boundY)
			love.graphics.line(PLAYER_START_X, boundY, PLAYER_START_X + LANE_WIDTH * LANE_COUNT, boundY)
			love.graphics.line(EVENT_LANE_X, boundY, EVENT_LANE_X + LANE_WIDTH, boundY)
			love.graphics.setLineWidth(1)
			love.graphics.setColor(1, 1, 0)
			love.graphics.print(tostring(si), ENEMY_START_X - 30, boundY - 8)
		end

		-- Líneas de beat/step dentro de la sección (granularidad de 1 step = 16vo)
		local firstStep = math.ceil(math.max(s0 + 0.001, minStep))
		local step = firstStep
		while step < s1 and step <= maxStep do
			local y = STRUMLINE_Y + (step - conductorStep) * pps
			if y >= LANE_Y_TOP and y <= LANE_Y_TOP + LANE_HEIGHT then
				local isBeat = math.abs((step - s0) % 4) < 0.001
				love.graphics.setColor(1, 1, 1, isBeat and 0.35 or 0.12)
				love.graphics.line(ENEMY_START_X, y, ENEMY_START_X + LANE_WIDTH * LANE_COUNT, y)
				love.graphics.line(PLAYER_START_X, y, PLAYER_START_X + LANE_WIDTH * LANE_COUNT, y)
				love.graphics.line(EVENT_LANE_X, y, EVENT_LANE_X + LANE_WIDTH, y)
			end
			step = step + 1
		end
		::nextSec::
	end

	love.graphics.setLineWidth(1)
	love.graphics.setColor(1, 1, 1)
end

local function drawNotes()
	for _, n in ipairs(noteCache) do
		local y = noteDisplayY(n.time)
		if y >= LANE_Y_TOP - 30 and y <= LANE_Y_TOP + LANE_HEIGHT + 30 then
			local x = laneX(n.lane, n.isPlayerNote)
			local len = n.raw[3] or 0

			local secAlpha = (n.sectionIndex == currentSectionIndex) and 1.0 or 0.4

			if len > 0 then
				local endY = noteDisplayY(n.time + len)
				local color = NOTE_COLORS[n.lane + 1]
				love.graphics.setColor(color[1], color[2], color[3], 0.45 * secAlpha)
				-- sustain se extiende hacia abajo (notas futuras están más abajo)
				love.graphics.rectangle("fill", x - 10, y, 20, endY - y)
				love.graphics.setColor(1, 1, 1)
			end

			local stamp = noteStampSprites[n.lane + 1]
			stamp.x, stamp.y = x, y
			love.graphics.setColor(1, 1, 1, (n.isPlayerNote and 1 or 0.8) * secAlpha)
			stamp:draw()
			love.graphics.setColor(1, 1, 1)

			if isNoteSelected(n) then
				love.graphics.setColor(1, 1, 0)
				love.graphics.rectangle("line", x - 21, y - 21, 42, 42)
				love.graphics.setColor(1, 1, 1)
			end

			-- BUG real (Too Slow): algunos charts (too-slow-hard.json) usan 0
			-- como "sin tipo" en vez de "" o ausente -- 0 es truthy en Lua y
			-- 0~="" también es true, así que la condición vieja pasaba para
			-- un NÚMERO y :sub() explotaba ("attempt to index a number").
			if n.typeStr and type(n.typeStr) == "string" and n.typeStr ~= "" then
				love.graphics.setColor(0, 0, 0)
				love.graphics.print(n.typeStr:sub(1, 1), x - 4, y - 30)
				love.graphics.setColor(1, 1, 1)
			end
		end
	end
end

local function drawEvents()
	for _, entry in ipairs(song.events) do
		local y = noteDisplayY(entry[1])
		if y >= LANE_Y_TOP - 15 and y <= LANE_Y_TOP + LANE_HEIGHT + 15 then
			local x = EVENT_LANE_X + LANE_WIDTH / 2
			local ev = entry[2] and entry[2][1]

			love.graphics.setColor(1, 0.5, 0)
			love.graphics.polygon("fill", x, y - 10, x + 10, y, x, y + 10, x - 10, y)

			if selection.event == entry then
				love.graphics.setColor(1, 1, 0)
				love.graphics.rectangle("line", x - 14, y - 14, 28, 28)
			end

			love.graphics.setColor(1, 1, 1)
			love.graphics.print((ev and ev[1] or "?"):sub(1, 1), x - 4, y - 6)
		end
	end
end

local function drawPlayhead()
	local y = STRUMLINE_Y  -- fijo en pantalla, igual que timeLine de Psych
	love.graphics.setColor(1, 1, 1, 0.95)
	love.graphics.setLineWidth(3)
	love.graphics.line(ENEMY_START_X, y, ENEMY_START_X + LANE_WIDTH * LANE_COUNT, y)
	love.graphics.line(PLAYER_START_X, y, PLAYER_START_X + LANE_WIDTH * LANE_COUNT, y)
	love.graphics.line(EVENT_LANE_X, y, EVENT_LANE_X + LANE_WIDTH, y)
	love.graphics.setLineWidth(1)
	love.graphics.setColor(1, 1, 1)
	for i = 1, 4 do
		enemyArrows[i]:draw()
		playerArrows[i]:draw()
	end
end

local function drawLanesBackground()
	local conductorStep = timeToStep(musicTime)
	local pps = pixelsPerStep()

	-- Fondo negro base
	love.graphics.setColor(0.1, 0.1, 0.1)
	love.graphics.rectangle("fill", ENEMY_START_X, LANE_Y_TOP, LANE_WIDTH * LANE_COUNT, LANE_HEIGHT)
	love.graphics.rectangle("fill", PLAYER_START_X, LANE_Y_TOP, LANE_WIDTH * LANE_COUNT, LANE_HEIGHT)
	love.graphics.rectangle("fill", EVENT_LANE_X, LANE_Y_TOP, LANE_WIDTH, LANE_HEIGHT)

	-- Fondos de sección alternados (sección actual más brillante que adyacentes)
	for si = 1, #song.notes do
		local s0 = sectionSteps[si]
		local s1 = sectionSteps[si + 1]
		        or (s0 + (song.notes[si].sectionBeats or 4) * 4)
		local yTop = STRUMLINE_Y + (s0 - conductorStep) * pps
		local yBot = STRUMLINE_Y + (s1 - conductorStep) * pps
		if yBot < LANE_Y_TOP or yTop > LANE_Y_TOP + LANE_HEIGHT then goto cont end

		local drawTop = math.max(yTop, LANE_Y_TOP)
		local drawBot = math.min(yBot, LANE_Y_TOP + LANE_HEIGHT)
		local isCurrent = (si == currentSectionIndex)
		local even = (si % 2 == 0)
		local alpha = isCurrent and (even and 0.55 or 0.45) or (even and 0.35 or 0.25)

		love.graphics.setColor(0.25, 0.25, 0.25, alpha)
		love.graphics.rectangle("fill", ENEMY_START_X, drawTop, LANE_WIDTH * LANE_COUNT, drawBot - drawTop)
		love.graphics.rectangle("fill", PLAYER_START_X, drawTop, LANE_WIDTH * LANE_COUNT, drawBot - drawTop)
		love.graphics.setColor(0.25, 0.15, 0.25, alpha)
		love.graphics.rectangle("fill", EVENT_LANE_X, drawTop, LANE_WIDTH, drawBot - drawTop)
		::cont::
	end

	-- Separadores verticales de carriles
	love.graphics.setColor(0.5, 0.5, 0.5)
	for i = 0, LANE_COUNT do
		love.graphics.line(ENEMY_START_X + i * LANE_WIDTH, LANE_Y_TOP, ENEMY_START_X + i * LANE_WIDTH, LANE_Y_TOP + LANE_HEIGHT)
		love.graphics.line(PLAYER_START_X + i * LANE_WIDTH, LANE_Y_TOP, PLAYER_START_X + i * LANE_WIDTH, LANE_Y_TOP + LANE_HEIGHT)
	end
	love.graphics.line(EVENT_LANE_X, LANE_Y_TOP, EVENT_LANE_X, LANE_Y_TOP + LANE_HEIGHT)
	love.graphics.line(EVENT_LANE_X + LANE_WIDTH, LANE_Y_TOP, EVENT_LANE_X + LANE_WIDTH, LANE_Y_TOP + LANE_HEIGHT)

	love.graphics.setColor(1, 1, 1)
end

-- Dibuja los iconos de personaje (estilo Psych Engine: icono del oponente encima
-- del carril izquierdo, icono del jugador encima del carril derecho).
local function drawCharacterIcons()
	love.graphics.setColor(1, 1, 1)
	if opponentIcon then
		local scale = ICON_SIZE / opponentIcon.faceH
		love.graphics.draw(opponentIcon.image, opponentIcon.quad,
			MUSTHIT_ENEMY_X - ICON_SIZE / 2, ICON_Y, 0, scale, scale)
	end
	if playerIcon then
		local scale = ICON_SIZE / playerIcon.faceH
		love.graphics.draw(playerIcon.image, playerIcon.quad,
			MUSTHIT_PLAYER_X - ICON_SIZE / 2, ICON_Y, 0, scale, scale)
	end
	love.graphics.setColor(1, 1, 1)
end

-- Bolita verde SOBRE el icono del personaje activo (mustHitSection), indicando
-- a qué lado apunta la cámara. El clic en el icono también alterna mustHit.
local function drawMustHitBall()
	local sec = song.notes[currentSectionIndex]
	local ballX = sec.mustHitSection and MUSTHIT_PLAYER_X or MUSTHIT_ENEMY_X
	local ballY = ICON_Y + ICON_SIZE / 2

	love.graphics.setColor(0, 1, 0, 0.7)
	love.graphics.circle("fill", ballX, ballY, 16)
	love.graphics.setColor(0, 0, 0)
	love.graphics.circle("line", ballX, ballY, 16)
	love.graphics.setColor(1, 1, 1)
end

local function drawBoxSelect()
	if not (boxSelectStart and boxSelectEnd) then return end

	local x1, x2 = math.min(boxSelectStart.x, boxSelectEnd.x), math.max(boxSelectStart.x, boxSelectEnd.x)
	local y1, y2 = math.min(boxSelectStart.y, boxSelectEnd.y), math.max(boxSelectStart.y, boxSelectEnd.y)

	love.graphics.setColor(1, 1, 0, 0.15)
	love.graphics.rectangle("fill", x1, y1, x2 - x1, y2 - y1)
	love.graphics.setColor(1, 1, 0, 0.8)
	love.graphics.rectangle("line", x1, y1, x2 - x1, y2 - y1)
	love.graphics.setColor(1, 1, 1)
end

local function drawTopBar()
	love.graphics.setColor(0, 0, 0, 0.6)
	love.graphics.rectangle("fill", 0, 0, graphics.getWidth(), LANE_Y_TOP - 2)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(
		string.format("S%d/%d  %.0fms  %s",
			currentSectionIndex, #song.notes, musicTime,
			currentRelPath or ""),
		20, 8, 0, 0.85, 0.85)
end

local function drawNotification()
	if notification.timer > 0 then
		love.graphics.setColor(1, 1, 0, math.min(1, notification.timer))
		love.graphics.print(notification.text, ENEMY_START_X, graphics.getHeight() - 22)
	end
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("F1: ayuda", graphics.getWidth() - 90, graphics.getHeight() - 22)
end

local HELP_LINES = {
	"=== AYUDA - EDITOR DE CHARTS (estilo Psych Engine) ===",
	"",
	"Clic izq en carril: colocar nota (snapped)  |  Shift+Clic: colocar libre (sin snap)  |  Clic der: borrar",
	"Shift+Clic en nota: añadir a selección  |  Ctrl+arrastrar vacío: selección rectangular  |  Ctrl+nota: sustain",
	"Clic en bola verde: alternar mustHitSection de la sección actual",
	"Clic en carril de eventos: colocar/seleccionar evento | Clic der: borrar evento",
	"7 (durante testeo): volver al editor conservando cambios",
	"",
	"A / D: sección anterior/siguiente (Shift = saltar 4)   Home/End: primera/última sección",
	"Flecha Arriba/Abajo: avanzar/retroceder un paso de cuantización (scrub)",
	"Rueda del ratón: scrub (Shift = paso fino)",
	"Izquierda/Derecha: cambiar cuantización   Z/X: alejar/acercar zoom",
	"",
	"Q / E: ciclar tipo de nota actual   R: aplicar tipo actual a la selección",
	"Tab (Shift+Tab): ciclar catálogo de eventos   (editar valores en el panel Events →)",
	"",
	"M: mustHitSection   G: gfSection   V: altAnim   B: changeBPM",
	"[ / ]: sectionBeats -/+   - / =: BPM -/+ (Shift = x10)   , / .: speed -/+",
	"N: insertar sección   Shift+N: duplicar sección   Ctrl+Backspace: eliminar sección",
	"",
	"F2/F3/F4 (Shift = sentido inverso): ciclar player1/player2/gfVersion",
	"F6 (Shift = sentido inverso): ciclar stage",
	"",
	"Ctrl+C/X/V: copiar/cortar/pegar   Ctrl+A: seleccionar todo en la sección",
	"Ctrl+Z / Ctrl+Shift+Z (o Ctrl+Y): deshacer/rehacer   Delete/Backspace: borrar selección",
	"",
	"Espacio: reproducir/pausar audio   Enter: probar canción in-game (guarda primero)",
	"Ctrl+S: guardar JSON   Escape: volver al navegador de archivos",
	"F1: cerrar esta ayuda",
}

local function drawHelp()
	love.graphics.setColor(0, 0, 0, 0.85)
	love.graphics.rectangle("fill", 0, 0, graphics.getWidth(), graphics.getHeight())

	love.graphics.setColor(1, 1, 1)
	for i, l in ipairs(HELP_LINES) do
		love.graphics.print(l, 40, 30 + (i - 1) * 22)
	end
end

local function drawEditor()
	drawLanesBackground()
	drawGrid()
	drawEvents()
	drawNotes()
	drawPlayhead()
	drawBoxSelect()
	drawTopBar()
	-- Iconos y bolita sobre la barra superior (igual que antes)
	drawCharacterIcons()
	drawMustHitBall()
	drawNotification()
	UI.draw()

	if showHelp then drawHelp() end
end

function state:draw()
	if mode == "browser" then
		drawBrowser()
	else
		drawEditor()
	end
end

return state
