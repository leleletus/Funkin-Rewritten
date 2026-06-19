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
Character Editor — réplica de states/editors/CharacterEditorState.hx de Psych
Engine: no solo offsets, sino TODO lo que el editor real de Psych permite
editar para un characters/<id>.json (animaciones, escala, posición, posición
de cámara con cruz blanca arrastrable, flip, antialiasing, colores de barra
de vida, imagen/icono/vocals, etc.)

Controles (navegador):
  ↑/↓ o rueda : mover selección
  Enter       : cargar personaje
  Escape      : volver al menú de depuración

Controles (edición, todos los paneles):
  Tab              : cambiar de panel (Offsets / Cámara / Personaje / Animaciones)
  J/K/L/I          : mover la vista del editor (cámara del editor, no la del juego)
  E/Q              : zoom in/out de la vista del editor
  R (sin Ctrl)     : resetear zoom de la vista a 1x
  T                : cargar plantilla (igual que "Load Template" de Psych)
  F1               : mostrar/ocultar ayuda
  F2               : guardar characters/<id>.json
  Mantener Shift   : mover 4x más rápido (vista/offsets), Ctrl: 4x más lento
  Escape           : volver al navegador

Panel Offsets (por animación, "offsets" del JSON):
  W/S              : animación anterior/siguiente
  Flechas          : mover el offset (Shift = paso 10, mantener repite)
  Click derecho+arrastrar : mover el offset con el mouse
  Espacio          : repetir animación   A/D: avanzar/retroceder un frame
  Ctrl+R/C/V/Z     : resetear/copiar/pegar/deshacer offset

Panel Cámara (camera_position + cruz blanca = a dónde apunta la cámara real):
  Flechas          : mover camera_position (Shift = paso 10)
  Click izquierdo+arrastrar sobre la cruz : moverla con el mouse

Panel Personaje (propiedades generales):
  ↑/↓              : elegir campo     ←/→ : ajustar (num/bool)    Enter: editar texto

Panel Animaciones (alta/baja/edición de animationsArray):
  W/S              : elegir animación   ↑/↓ (en edición): elegir campo
  N                : nueva animación    Delete: borrar la seleccionada
  Enter            : editar el campo seleccionado (texto) / alternar (loop)
]]

local state = {}
local graphics, input, json, character, animnames, lovesize

local CHAR_DIR = "characters"
local SCRATCH_PATH = CHAR_DIR .. "/_editor_scratch.json"

-- Navegador
local browser = {
	entries = {},
	selection = 1,
}

local mode = "browser" -- "browser" | "editing"
local panel = "offset" -- "offset" | "camera" | "character" | "animlist"

-- Edición
local charId
local sprite
local def
local isPlayer = false
local animList -- {psychName=, internal=, loop=, fps=, name=, indicesText=, defIndex=}
local editedOffsets -- [internal] = {x=, y=}
local originalOffsets -- [internal] = {x=, y=}
local curAnim = 1

local camView = {x = 0, y = 0, zoom = 1}
local showHelp = false
local copiedOffset = {0, 0}
local undoOffset = nil

local holdTime = 0
local holdElapsed = 0
local frameHoldTime = 0
local frameHoldElapsed = 0

local saveMessage = ""
local saveMessageTimer = 0

local charFieldIndex = 1
local animFieldIndex = 1
local animlistSelection = 1 -- índice DIRECTO en def.animations (ver nota en rebuildAnimList)

-- Edición de texto genérica (campos string de cualquier panel)
local textEdit = nil -- {buffer=, onConfirm=function(value)}

-- Arrastre con mouse
local draggingCross = false
local draggingOffset = false

local HELP_LINES = {
	"=== AYUDA ===",
	"",
	"GENERAL",
	"Tab - Cambiar de panel (Offsets/Camara/Personaje/Animaciones)",
	"J/K/L/I - Mover vista del editor      E/Q - Zoom vista      R - Reset zoom vista",
	"T - Cargar plantilla       F2 - Guardar       Shift - 4x rapido  Ctrl - 4x lento",
	"",
	"PANEL OFFSETS",
	"W/S - Animacion anterior/siguiente     Espacio - Repetir animacion",
	"Flechas / Click derecho+arrastrar - Mover offset (Shift = paso 10)",
	"A/D - Avanzar/retroceder un frame",
	"Ctrl+R/C/V/Z - Resetear/Copiar/Pegar/Deshacer offset",
	"",
	"PANEL CAMARA",
	"Flechas - Mover camera_position      Click izquierdo+arrastrar la cruz blanca",
	"",
	"PANEL PERSONAJE",
	"Arriba/Abajo - Elegir campo     Izquierda/Derecha - Ajustar     Enter - Editar texto",
	"",
	"PANEL ANIMACIONES",
	"W/S - Elegir animacion     N - Nueva     Delete - Borrar",
	"Enter - Editar campo seleccionado (Arriba/Abajo elige campo)",
	"",
	"F1 o Escape para cerrar esta ayuda",
}

local function updateBrowserEntries()
	browser.entries = {}

	for _, item in ipairs(love.filesystem.getDirectoryItems(CHAR_DIR)) do
		local id = item:match("^(.+)%.json$")
		if id and id ~= "_editor_scratch" then table.insert(browser.entries, id) end
	end

	table.sort(browser.entries)

	if browser.selection > #browser.entries then browser.selection = #browser.entries end
	if browser.selection < 1 then browser.selection = 1 end
end

-- Replica predictCharacterIsNotPlayer de Psych (CharacterEditorState.hx),
-- usado solo como palpito inicial al cargar -- el usuario puede corregirlo
-- con el checkbox "Playable Character" del panel Personaje.
local function predictIsPlayer(name)
	local notPlayer = (name ~= "bf" and not name:match("^bf%-") and not name:match("%-player$") and not name:match("%-playable$") and not name:match("%-dead$"))
		or name:match("%-opponent$") ~= nil or name:match("^gf%-") ~= nil or name:match("%-gf$") ~= nil or name == "gf"
	return not notPlayer
end

-------------------------------------------------------------------------------
-- JSON: impresión legible (indentada) para el guardado final -- a diferencia
-- del archivo scratch (json.encode compacto, invisible para el usuario), el
-- archivo que el usuario realmente edita debe quedar legible como el resto
-- de characters/*.json del proyecto.
-------------------------------------------------------------------------------

local function isArray(t)
	if type(t) ~= "table" then return false end
	local n = 0
	for _ in pairs(t) do n = n + 1 end
	return n == 0 or t[n] ~= nil
end

local function encodeScalar(v)
	if type(v) == "string" then
		return json.encode(v)
	elseif type(v) == "boolean" then
		return tostring(v)
	elseif v == nil then
		return "null"
	else
		return tostring(v)
	end
end

local function prettyEncode(value, indent)
	indent = indent or 0
	local pad = string.rep("\t", indent)
	local padIn = string.rep("\t", indent + 1)

	if type(value) ~= "table" then
		return encodeScalar(value)
	end

	if isArray(value) then
		if #value == 0 then return "[]" end

		local allScalar = true
		for _, v in ipairs(value) do
			if type(v) == "table" then allScalar = false break end
		end

		if allScalar then
			local parts = {}
			for _, v in ipairs(value) do table.insert(parts, encodeScalar(v)) end
			return "[" .. table.concat(parts, ", ") .. "]"
		end

		local lines = {"["}
		for i, v in ipairs(value) do
			local sep = (i < #value) and "," or ""
			table.insert(lines, padIn .. prettyEncode(v, indent + 1) .. sep)
		end
		table.insert(lines, pad .. "]")
		return table.concat(lines, "\n")
	end

	-- objeto: orden estable (claves conocidas primero, en un orden fijo, luego el resto)
	local KNOWN_ORDER = {
		"animations", "image", "scale", "sing_duration", "healthicon",
		"position", "camera_position", "flip_x", "no_antialiasing",
		"healthbar_colors", "vocals_file", "_editor_isPlayer",
		"anim", "name", "fps", "loop", "indices", "offsets",
	}
	local seen = {}
	local keys = {}
	for _, k in ipairs(KNOWN_ORDER) do
		if value[k] ~= nil then table.insert(keys, k); seen[k] = true end
	end
	for k in pairs(value) do
		if not seen[k] then table.insert(keys, k) end
	end

	if #keys == 0 then return "{}" end

	local lines = {"{"}
	for i, k in ipairs(keys) do
		local sep = (i < #keys) and "," or ""
		table.insert(lines, padIn .. json.encode(tostring(k)) .. ": " .. prettyEncode(value[k], indent + 1) .. sep)
	end
	table.insert(lines, pad .. "}")
	return table.concat(lines, "\n")
end

-------------------------------------------------------------------------------
-- Plantilla ("Load Template" de Psych)
-------------------------------------------------------------------------------

local function newAnim(anim, name)
	return {anim = anim, name = name, fps = 24, loop = false, indices = {}, offsets = {0, 0}}
end

local function templateDef()
	return {
		animations = {
			newAnim("idle", "BF idle dance"),
			newAnim("singLEFT", "BF NOTE LEFT0"),
			newAnim("singDOWN", "BF NOTE DOWN0"),
			newAnim("singUP", "BF NOTE UP0"),
			newAnim("singRIGHT", "BF NOTE RIGHT0"),
		},
		no_antialiasing = false,
		flip_x = false,
		healthicon = "face",
		image = "characters/BOYFRIEND",
		sing_duration = 4,
		scale = 1,
		healthbar_colors = {161, 161, 161},
		camera_position = {0, 0},
		position = {0, 0},
		vocals_file = nil,
	}
end

-------------------------------------------------------------------------------
-- Indices: "0-13,15-29" <-> {0,1,...,13,15,...,29} (igual que el campo
-- "ADVANCED - Animation Indices" de CharacterEditorState.hx)
-------------------------------------------------------------------------------

local function parseIndices(text)
	local result = {}
	if not text or text:match("^%s*$") then return result end

	for piece in text:gmatch("[^,]+") do
		piece = piece:match("^%s*(.-)%s*$")
		local a, b = piece:match("^(%-?%d+)%-(%-?%d+)$")
		if a then
			a, b = tonumber(a), tonumber(b)
			if b < a then b = a end
			for i = a, b do table.insert(result, i) end
		else
			local n = tonumber(piece)
			if n then table.insert(result, n) end
		end
	end

	return result
end

local function formatIndices(indices)
	if not indices or #indices == 0 then return "" end
	local parts = {}
	for _, n in ipairs(indices) do table.insert(parts, tostring(n)) end
	return table.concat(parts, ",")
end

-------------------------------------------------------------------------------
-- Normaliza def para que TODOS los campos que el editor toca existan siempre
-- (varios characters/*.json reales omiten campos opcionales).
-------------------------------------------------------------------------------

local function normalizeDef(d)
	d.position = d.position or {0, 0}
	d.camera_position = d.camera_position or {0, 0}
	d.healthbar_colors = d.healthbar_colors or {161, 161, 161}
	d.scale = d.scale or 1
	if d.sing_duration == nil then d.sing_duration = 4 end
	d.image = d.image or ""
	d.healthicon = d.healthicon or "face"
	d.vocals_file = d.vocals_file or ""
	if d.flip_x == nil then d.flip_x = false end
	if d.no_antialiasing == nil then d.no_antialiasing = false end
	d.animations = d.animations or {}

	for _, a in ipairs(d.animations) do
		a.offsets = a.offsets or {0, 0}
		a.indices = a.indices or {}
		a.fps = a.fps or 24
		if a.loop == nil then a.loop = false end
	end

	return d
end

-------------------------------------------------------------------------------
-- Reconstruye animList/editedOffsets/originalOffsets desde def.animations +
-- sprite:getAnims() actuales (llamado tras cargar y tras cada rebuildSprite()).
-------------------------------------------------------------------------------

-- animList SOLO incluye animaciones que YA resolvieron a frames reales en el
-- atlas (anims[internal] existe) -- es lo que necesita el panel Offsets
-- (no tiene sentido editar el offset de algo que no se dibuja). El panel
-- Animaciones, en cambio, recorre def.animations DIRECTO (animlistSelection,
-- ver más abajo) para poder crear/editar entradas TODAVÍA sin frames
-- válidos (p.ej. una recién creada con "Name/Prefix" vacío).
local function rebuildAnimList()
	animList = {}
	editedOffsets = {}
	originalOffsets = {}

	local anims = sprite:getAnims()

	for i, animDef in ipairs(def.animations) do
		local internal = animnames.toInternal(animDef.anim)

		if anims[internal] then
			local offsets = animDef.offsets or {0, 0}

			table.insert(animList, {
				psychName = animDef.anim,
				internal = internal,
				loop = animDef.loop,
				defIndex = i,
			})

			editedOffsets[internal] = {x = offsets[1] or 0, y = offsets[2] or 0}
			originalOffsets[internal] = {x = offsets[1] or 0, y = offsets[2] or 0}
		end
	end
end

local function applyOffset()
	local anim = animList[curAnim]
	if not anim then return end

	local edited = editedOffsets[anim.internal]
	local original = originalOffsets[anim.internal]

	sprite.offsetX = edited.x - original.x
	sprite.offsetY = edited.y - original.y
end

-- Escribe el offset editado de vuelta en def.animations[i] (mantiene a `def`
-- siempre como fuente de verdad completa, lista para serializar en
-- cualquier momento -- ya sea para rebuildSprite() o para el guardado final).
local function syncOffsetToDef(animIndex)
	local anim = animList[animIndex]
	if not anim or not anim.defIndex then return end

	local off = editedOffsets[anim.internal]
	def.animations[anim.defIndex].offsets = {math.floor(off.x), math.floor(off.y)}
end

local function switchAnim(index)
	curAnim = ((index - 1) % #animList) + 1

	local anim = animList[curAnim]
	sprite:animate(anim.internal, anim.loop or false)
	applyOffset()
end

-- Reconstruye el sprite desde `def` (con todas las ediciones acumuladas)
-- escribiéndolo a un archivo scratch y reusando charts/psych/character.lua
-- al 100% -- así no hay que reimplementar el armado de frames/animaciones a
-- mano cada vez que cambia escala/imagen/flip/animaciones.
local function rebuildSprite()
	love.filesystem.createDirectory(CHAR_DIR)
	local ok1 = love.filesystem.write(SCRATCH_PATH, json.encode(def))
	if not ok1 then
		print("WARN: no se pudo escribir el scratch del editor de personajes")
		return false
	end

	local lastInternal = animList and animList[curAnim] and animList[curAnim].internal

	local ok2, loadedSprite = pcall(character.load, SCRATCH_PATH, isPlayer)
	if not ok2 or not loadedSprite then
		print("WARN: rebuildSprite fallo: " .. tostring(loadedSprite))
		return false
	end

	sprite = loadedSprite
	sprite.x, sprite.y = 0, 0

	rebuildAnimList()

	local newIndex = 1
	for i, a in ipairs(animList) do
		if a.internal == lastInternal then newIndex = i; break end
	end
	curAnim = newIndex

	if #animList > 0 then switchAnim(curAnim) end

	return true
end

local function loadCharacter(id)
	local jsonPath = CHAR_DIR .. "/" .. id .. ".json"

	local raw, err = love.filesystem.read(jsonPath)
	if not raw then
		print("WARN: no se pudo leer '" .. jsonPath .. "': " .. tostring(err))
		return false
	end

	local ok, decoded = pcall(json.decode, raw)
	if not ok then
		print("WARN: no se pudo decodificar '" .. jsonPath .. "': " .. tostring(decoded))
		return false
	end

	charId = id
	def = normalizeDef(decoded)
	isPlayer = predictIsPlayer(id)

	local ok2, loadedSprite = pcall(character.load, jsonPath, isPlayer)
	if not ok2 or not loadedSprite then
		print("WARN: no se pudo cargar el personaje '" .. jsonPath .. "': " .. tostring(loadedSprite))
		return false
	end

	sprite = loadedSprite
	sprite.x, sprite.y = 0, 0

	rebuildAnimList()

	curAnim = 1
	if #animList > 0 then switchAnim(1) end

	camView.x, camView.y, camView.zoom = 0, 0, 1
	showHelp = false
	copiedOffset = {0, 0}
	undoOffset = nil
	holdTime, holdElapsed = 0, 0
	frameHoldTime, frameHoldElapsed = 0, 0
	saveMessage, saveMessageTimer = "", 0
	panel = "offset"
	charFieldIndex = 1
	animFieldIndex = 1
	animlistSelection = 1
	textEdit = nil

	return true
end

local function saveCharacter()
	-- def.animations ya tiene los offsets sincronizados (syncOffsetToDef se
	-- llama en cada cambio), así que alcanza con serializar `def` completo.
	def._editor_isPlayer = isPlayer

	local data = prettyEncode(def)

	love.filesystem.createDirectory(CHAR_DIR)
	local filename = CHAR_DIR .. "/" .. charId .. ".json"
	local ok, writeErr = love.filesystem.write(filename, data)

	if ok then
		saveMessage = "Guardado en " .. love.filesystem.getSaveDirectory() .. "/" .. filename
		print("[CHARACTER-EDITOR] " .. saveMessage)
	else
		saveMessage = "Error al guardar: " .. tostring(writeErr)
		print("[CHARACTER-EDITOR] " .. saveMessage)
	end

	saveMessageTimer = 4
end

local function loadTemplate()
	def = normalizeDef(templateDef())
	rebuildSprite()
end

local function ctrlDown()
	return love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
end

local function shiftDown()
	return love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
end

-------------------------------------------------------------------------------
-- Puntero de cámara (cruz blanca) -- replica updatePointerPos() de
-- CharacterEditorState.hx, usando la MISMA fórmula validada en
-- states/weeks.lua (bfCamTarget/enemyCamTarget): camera_position se divide
-- por la escala del personaje, necesario para personajes "pixel" (scale
-- != 1) -- ver charts/psych/character.lua y la corrección de esta sesión.
-------------------------------------------------------------------------------

local function cameraPointerPos()
	local scaleX = math.abs(sprite.sizeX or 1)
	local scaleY = math.abs(sprite.sizeY or 1)
	local cx, cy = def.camera_position[1] or 0, def.camera_position[2] or 0

	if isPlayer then
		return sprite.x - 100 - cx / scaleX, sprite.y - 100 + cy / scaleY
	else
		return sprite.x + 150 + cx / scaleX, sprite.y - 100 + cy / scaleY
	end
end

-------------------------------------------------------------------------------
-- Listas de campos (paneles Personaje / Animaciones) -- genéricas para poder
-- recorrerlas con Arriba/Abajo y editarlas con Izquierda/Derecha/Enter sin
-- repetir código por campo.
-------------------------------------------------------------------------------

local function characterFields()
	return {
		{label = "Playable Character (isPlayer)", type = "bool",
			get = function() return isPlayer end,
			set = function(v) isPlayer = v; rebuildSprite() end},
		{label = "Scale", type = "num", step = 0.1, min = 0.05, max = 10,
			get = function() return def.scale end,
			set = function(v) def.scale = v; rebuildSprite() end},
		{label = "Position X", type = "num", step = 10,
			get = function() return def.position[1] end,
			set = function(v) def.position[1] = v end},
		{label = "Position Y", type = "num", step = 10,
			get = function() return def.position[2] end,
			set = function(v) def.position[2] = v end},
		{label = "Flip X (json flip_x)", type = "bool",
			get = function() return def.flip_x end,
			set = function(v) def.flip_x = v; rebuildSprite() end},
		{label = "No Antialiasing", type = "bool",
			get = function() return def.no_antialiasing end,
			set = function(v) def.no_antialiasing = v; rebuildSprite() end},
		{label = "Sing Duration", type = "num", step = 0.1, min = 0, max = 999,
			get = function() return def.sing_duration end,
			set = function(v) def.sing_duration = v end},
		{label = "Health Color R", type = "num", step = 5, min = 0, max = 255,
			get = function() return def.healthbar_colors[1] end,
			set = function(v) def.healthbar_colors[1] = v end},
		{label = "Health Color G", type = "num", step = 5, min = 0, max = 255,
			get = function() return def.healthbar_colors[2] end,
			set = function(v) def.healthbar_colors[2] = v end},
		{label = "Health Color B", type = "num", step = 5, min = 0, max = 255,
			get = function() return def.healthbar_colors[3] end,
			set = function(v) def.healthbar_colors[3] = v end},
		{label = "Image file", type = "str",
			get = function() return def.image end,
			set = function(v) def.image = v; rebuildSprite() end},
		{label = "Health icon name", type = "str",
			get = function() return def.healthicon end,
			set = function(v) def.healthicon = v end},
		{label = "Vocals file postfix", type = "str",
			get = function() return def.vocals_file end,
			set = function(v) def.vocals_file = v end},
	}
end

-- Panel Animaciones: opera DIRECTO sobre def.animations[animlistSelection],
-- no sobre animList -- así una entrada recién creada (o con "Name/Prefix"
-- que todavía no matchea ningún frame del atlas) sigue siendo editable en
-- vez de desaparecer de la lista hasta que matchee algo.
local function animFields()
	local entry = def.animations[animlistSelection]
	if not entry then return {} end

	return {
		{label = "Anim key (Psych 'anim')", type = "str",
			get = function() return entry.anim end,
			set = function(v) entry.anim = v; rebuildSprite() end},
		{label = "Name/Prefix ('name')", type = "str",
			get = function() return entry.name end,
			set = function(v) entry.name = v; rebuildSprite() end},
		{label = "FPS", type = "num", step = 1, min = 0, max = 240,
			get = function() return entry.fps end,
			set = function(v) entry.fps = v; rebuildSprite() end},
		{label = "Loop", type = "bool",
			get = function() return entry.loop end,
			set = function(v) entry.loop = v; rebuildSprite() end},
		{label = "Indices (ej. 0-13,15-29)", type = "str",
			get = function() return formatIndices(entry.indices) end,
			set = function(v) entry.indices = parseIndices(v); rebuildSprite() end},
	}
end

-- En el frame donde se cierra una edición de texto (Enter/Escape via
-- state:keypressed), input:pressed("confirm")/("back") sobre la MISMA tecla
-- todavía aparece "pressed" para el sistema de polling (baton procesa su
-- propio borde independientemente del callback de LÖVE) -- sin esto, cerrar
-- un campo con Enter reabriría el mismo campo (o Escape volvería al
-- navegador) en el acto. Se consume saltando un frame de updateEditing().
local justClosedTextEdit = false

local function startTextEdit(field)
	textEdit = {buffer = tostring(field.get() or ""), field = field}
end

local function confirmTextEdit()
	if not textEdit then return end
	textEdit.field.set(textEdit.buffer)
	textEdit = nil
	justClosedTextEdit = true
end

local function cancelTextEdit()
	textEdit = nil
	justClosedTextEdit = true
end

function state:enter()
	graphics = require("modules.graphics")
	input = require("input")
	json = require("lib.json")
	character = require("charts.psych.character")
	animnames = require("charts.psych.animnames")
	lovesize = require("lib.lovesize")

	mode = "browser"
	updateBrowserEntries()

	graphics.fadeIn(0.3)
end

local function updateBrowser()
	if #browser.entries > 0 then
		if input:pressed("up") then
			browser.selection = browser.selection - 1
			if browser.selection < 1 then browser.selection = #browser.entries end
		elseif input:pressed("down") then
			browser.selection = browser.selection + 1
			if browser.selection > #browser.entries then browser.selection = 1 end
		elseif input:pressed("confirm") then
			if loadCharacter(browser.entries[browser.selection]) then
				mode = "editing"
			end
		end
	end

	if input:pressed("back") then
		graphics.fadeOut(0.3, function()
			Gamestate.switch(require("states.debug-menu"))
		end)
	end
end

local PANELS = {"offset", "camera", "character", "animlist"}

local function cyclePanel()
	for i, p in ipairs(PANELS) do
		if p == panel then
			panel = PANELS[(i % #PANELS) + 1]
			return
		end
	end
	panel = PANELS[1]
end

local function updateEditorView(dt)
	local shiftMult = shiftDown() and 4 or 1
	local ctrlMult = ctrlDown() and 0.25 or 1

	if love.keyboard.isDown("j") then camView.x = camView.x - dt * 500 * shiftMult * ctrlMult end
	if love.keyboard.isDown("l") then camView.x = camView.x + dt * 500 * shiftMult * ctrlMult end
	if love.keyboard.isDown("k") then camView.y = camView.y + dt * 500 * shiftMult * ctrlMult end
	if love.keyboard.isDown("i") then camView.y = camView.y - dt * 500 * shiftMult * ctrlMult end

	if input:pressed("r") and not ctrlDown() then
		camView.zoom = 1
	elseif love.keyboard.isDown("e") and camView.zoom < 3 then
		camView.zoom = math.min(3, camView.zoom + dt * camView.zoom * shiftMult * ctrlMult)
	elseif love.keyboard.isDown("q") and camView.zoom > 0.1 then
		camView.zoom = math.max(0.1, camView.zoom - dt * camView.zoom * shiftMult * ctrlMult)
	end
end

local function updateOffsetPanel(dt)
	if #animList > 1 then
		if input:pressed("w") then switchAnim(curAnim - 1) end
		if input:pressed("s") then switchAnim(curAnim + 1) end
	end

	if input:pressed("space") then
		local anim = animList[curAnim]
		if anim then
			sprite:animate(anim.internal, anim.loop or false)
			applyOffset()
		end
	end

	local anim = animList[curAnim]
	if not anim then return end

	local off = editedOffsets[anim.internal]
	local step = shiftDown() and 10 or 1
	local changed = false

	if input:pressed("left") then off.x = off.x + step; changed = true end
	if input:pressed("right") then off.x = off.x - step; changed = true end
	if input:pressed("up") then off.y = off.y + step; changed = true end
	if input:pressed("down") then off.y = off.y - step; changed = true end

	if input:down("left") or input:down("right") or input:down("up") or input:down("down") then
		holdTime = holdTime + dt

		if holdTime > 0.6 then
			holdElapsed = holdElapsed + dt

			while holdElapsed > (1 / 60) do
				if input:down("left") then off.x = off.x + step; changed = true end
				if input:down("right") then off.x = off.x - step; changed = true end
				if input:down("up") then off.y = off.y + step; changed = true end
				if input:down("down") then off.y = off.y - step; changed = true end

				holdElapsed = holdElapsed - (1 / 60)
			end
		end
	else
		holdTime, holdElapsed = 0, 0
	end

	if ctrlDown() then
		if input:pressed("r") then
			undoOffset = {x = off.x, y = off.y}
			off.x, off.y = 0, 0
			changed = true
		elseif input:pressed("c") then
			copiedOffset = {off.x, off.y}
		elseif input:pressed("v") then
			undoOffset = {x = off.x, y = off.y}
			off.x, off.y = copiedOffset[1], copiedOffset[2]
			changed = true
		elseif input:pressed("z") and undoOffset then
			off.x, off.y = undoOffset.x, undoOffset.y
			undoOffset = nil
			changed = true
		end
	end

	if changed then
		applyOffset()
		syncOffsetToDef(curAnim)
	end

	-- Avance de frame manual (A/D)
	if input:down("a") or input:down("d") then
		frameHoldTime = frameHoldTime + dt
		if frameHoldTime > 0.5 then frameHoldElapsed = frameHoldElapsed + dt end
	else
		frameHoldTime = 0
	end

	if input:pressed("a") or input:pressed("d") or frameHoldTime > 0.5 then
		if frameHoldTime <= 0.5 or frameHoldElapsed > 0.1 then
			local isLeft = input:down("a")
			local count = sprite:getFrameCount()
			if count > 0 then
				local f = sprite:getCurrentFrame() + (isLeft and -1 or 1)
				f = ((f - 1) % count) + 1
				sprite:setFrame(f)
			end
			frameHoldElapsed = frameHoldElapsed - 0.1
		end
	end
end

local function updateCameraPanel(dt)
	local step = shiftDown() and 10 or 1
	local changed = false

	if input:pressed("left") then def.camera_position[1] = def.camera_position[1] - step; changed = true end
	if input:pressed("right") then def.camera_position[1] = def.camera_position[1] + step; changed = true end
	if input:pressed("up") then def.camera_position[2] = def.camera_position[2] - step; changed = true end
	if input:pressed("down") then def.camera_position[2] = def.camera_position[2] + step; changed = true end
end

local function adjustField(field, dir)
	if field.type == "bool" then
		field.set(not field.get())
	elseif field.type == "num" then
		local v = field.get() + dir * (field.step or 1)
		if field.min and v < field.min then v = field.min end
		if field.max and v > field.max then v = field.max end
		field.set(v)
	end
end

local function updateCharacterPanel()
	local fields = characterFields()
	if #fields == 0 then return end

	if input:pressed("up") then charFieldIndex = ((charFieldIndex - 2) % #fields) + 1 end
	if input:pressed("down") then charFieldIndex = (charFieldIndex % #fields) + 1 end

	local field = fields[charFieldIndex]
	if not field then return end

	if field.type == "str" then
		if input:pressed("confirm") then startTextEdit(field) end
	else
		if input:pressed("left") then adjustField(field, -1) end
		if input:pressed("right") then adjustField(field, 1) end
	end
end

local function updateAnimlistPanel()
	local total = #def.animations

	if input:pressed("n") then
		table.insert(def.animations, newAnim("newAnim", ""))
		animlistSelection = #def.animations
		animFieldIndex = 1
		rebuildSprite()
		return
	end

	if total > 1 then
		if input:pressed("w") then animlistSelection = ((animlistSelection - 2) % total) + 1; animFieldIndex = 1 end
		if input:pressed("s") then animlistSelection = (animlistSelection % total) + 1; animFieldIndex = 1 end
	end

	if input:pressed("delete") and def.animations[animlistSelection] then
		table.remove(def.animations, animlistSelection)
		if animlistSelection > #def.animations then animlistSelection = #def.animations end
		if animlistSelection < 1 then animlistSelection = 1 end
		animFieldIndex = 1
		rebuildSprite()
		return
	end

	local fields = animFields()
	if #fields == 0 then return end

	if input:pressed("up") then animFieldIndex = ((animFieldIndex - 2) % #fields) + 1 end
	if input:pressed("down") then animFieldIndex = (animFieldIndex % #fields) + 1 end

	local field = fields[animFieldIndex]
	if not field then return end

	if field.type == "str" then
		if input:pressed("confirm") then startTextEdit(field) end
	else
		if input:pressed("left") then adjustField(field, -1) end
		if input:pressed("right") then adjustField(field, 1) end
		if field.type == "bool" and input:pressed("confirm") then adjustField(field, 1) end
	end
end

local function updateEditing(dt)
	sprite:update(dt)

	if textEdit then
		-- backspace/return/escape se manejan en state:keypressed
		return
	end

	if justClosedTextEdit then
		justClosedTextEdit = false
		return
	end

	if input:pressed("f1") then showHelp = not showHelp end

	if showHelp then
		if input:pressed("back") then showHelp = false end
		return
	end

	updateEditorView(dt)

	if input:pressed("tab") then cyclePanel() end
	if input:pressed("t") then loadTemplate() end
	if input:pressed("save") then saveCharacter() end

	if panel == "offset" then
		updateOffsetPanel(dt)
	elseif panel == "camera" then
		updateCameraPanel(dt)
	elseif panel == "character" then
		updateCharacterPanel()
	elseif panel == "animlist" then
		updateAnimlistPanel()
	end

	if input:pressed("back") then
		mode = "browser"
		updateBrowserEntries()
	end
end

function state:update(dt)
	if saveMessageTimer > 0 then saveMessageTimer = saveMessageTimer - dt end

	if mode == "browser" then
		updateBrowser()
	else
		updateEditing(dt)
	end
end

function state:keypressed(key)
	if mode ~= "editing" or not textEdit then return end

	if key == "backspace" then
		textEdit.buffer = textEdit.buffer:sub(1, -2)
	elseif key == "return" or key == "kpenter" then
		confirmTextEdit()
	elseif key == "escape" then
		cancelTextEdit()
	end
end

function state:textinput(text)
	if mode == "editing" and textEdit then
		textEdit.buffer = textEdit.buffer .. text
	end
end

-- Convierte un punto de pantalla (coords love.mouse crudas) al espacio de
-- mundo del sprite, invirtiendo la transformación usada en drawEditing().
local function screenToWorld(sx, sy)
	local gx, gy = lovesize.pos(sx, sy)
	local wx = (gx - graphics.getWidth() / 2 - camView.x) / camView.zoom
	local wy = (gy - graphics.getHeight() / 2 - camView.y) / camView.zoom
	return wx, wy
end

function state:mousepressed(x, y, button)
	if mode ~= "editing" or textEdit or showHelp then return end

	if button == 1 then
		-- La cruz se puede arrastrar sin importar el panel activo (ver nota
		-- en drawEditing) -- click izquierdo nunca se usa para otra cosa.
		local px, py = cameraPointerPos()
		local wx, wy = screenToWorld(x, y)
		if math.abs(wx - px) < 25 / camView.zoom and math.abs(wy - py) < 25 / camView.zoom then
			draggingCross = true
		end
	elseif button == 2 and panel == "offset" then
		draggingOffset = true
	end
end

function state:mousemoved(x, y, dx, dy)
	if mode ~= "editing" then return end

	if draggingCross or draggingOffset then
		local gx0, gy0 = lovesize.pos(x - dx, y - dy)
		local gx1, gy1 = lovesize.pos(x, y)
		local worldDX = (gx1 - gx0) / camView.zoom
		local worldDY = (gy1 - gy0) / camView.zoom

		if draggingCross then
			local scaleX = math.abs(sprite.sizeX or 1)
			local scaleY = math.abs(sprite.sizeY or 1)
			-- Invierte cameraPointerPos(): según la rama, el coeficiente de
			-- camera_position[1] es +1/scaleX (enemigo) o -1/scaleX (player).
			local coefX = isPlayer and -1 or 1
			def.camera_position[1] = def.camera_position[1] + worldDX * scaleX * coefX
			def.camera_position[2] = def.camera_position[2] + worldDY * scaleY
		elseif draggingOffset then
			local anim = animList[curAnim]
			if anim then
				local off = editedOffsets[anim.internal]
				-- Igual que Psych (deltaScreenX/Y crudos, sin compensar zoom
				-- de la vista del editor -- el offset es en píxeles "crudos"
				-- del personaje, no del mundo de la vista).
				off.x = off.x - dx
				off.y = off.y - dy
				applyOffset()
				syncOffsetToDef(curAnim)
			end
		end
	end
end

function state:mousereleased(x, y, button)
	if button == 1 then draggingCross = false end
	if button == 2 then draggingOffset = false end
end

function state:wheelmoved(x, y)
	if mode == "browser" then
		if y > 0 then
			browser.selection = browser.selection - 1
		elseif y < 0 then
			browser.selection = browser.selection + 1
		end

		if browser.selection < 1 then browser.selection = #browser.entries end
		if browser.selection > #browser.entries then browser.selection = 1 end
	else
		camView.zoom = camView.zoom + y * 0.1
		if camView.zoom < 0.1 then camView.zoom = 0.1 end
		if camView.zoom > 5 then camView.zoom = 5 end
	end
end

local function drawBrowser()
	love.graphics.setColor(1, 1, 0)
	love.graphics.print("=== CHARACTER EDITOR ===", 10, 10)
	love.graphics.print("Carpeta: " .. CHAR_DIR, 10, 30)
	love.graphics.setColor(1, 1, 1)

	for i, id in ipairs(browser.entries) do
		local y = 60 + (i - 1) * 20

		if i == browser.selection then
			love.graphics.setColor(1, 1, 0)
		else
			love.graphics.setColor(1, 1, 1)
		end

		love.graphics.print(id .. ".json", 20, y)
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.print("↑/↓/rueda: mover   Enter: editar   Escape: volver al menu", 10, graphics.getHeight() - 30)
end

local function drawFieldList(fields, selectedIndex, x, y)
	for i, f in ipairs(fields) do
		local fy = y + (i - 1) * 22

		if i == selectedIndex then
			love.graphics.setColor(1, 1, 0)
		else
			love.graphics.setColor(1, 1, 1)
		end

		local valueStr
		if textEdit and textEdit.field == f then
			valueStr = textEdit.buffer .. "_"
		elseif f.type == "bool" then
			valueStr = f.get() and "Si" or "No"
		else
			valueStr = tostring(f.get())
		end

		love.graphics.print(f.label .. ": " .. valueStr, x, fy)
	end
end

local function drawCross(px, py)
	love.graphics.push()
		love.graphics.translate(graphics.getWidth() / 2 + camView.x, graphics.getHeight() / 2 + camView.y)
		love.graphics.scale(camView.zoom)
		love.graphics.translate(px, py)
		love.graphics.setColor(1, 1, 1)
		love.graphics.setLineWidth(2 / camView.zoom)
		local s = 20 / camView.zoom
		love.graphics.line(-s, 0, s, 0)
		love.graphics.line(0, -s, 0, s)
		love.graphics.setLineWidth(1)
	love.graphics.pop()
end

local function drawEditing()
	love.graphics.push()
		love.graphics.translate(graphics.getWidth() / 2 + camView.x, graphics.getHeight() / 2 + camView.y)
		love.graphics.scale(camView.zoom)
		love.graphics.setColor(1, 1, 1)
		sprite:draw()
	love.graphics.pop()

	-- La cruz SIEMPRE se ve (igual que Psych: cameraFollowPointer es un
	-- elemento fijo de la escena, no algo atado a qué pestaña de UI está
	-- abierta). Antes solo se dibujaba en panel=="camera", por eso no se veía.
	do
		local px, py = cameraPointerPos()
		drawCross(px, py)
	end

	love.graphics.setColor(1, 1, 0)
	love.graphics.print("=== CHARACTER EDITOR ===  [" .. panel:upper() .. "]  (Tab cambia panel)", 10, 10)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Personaje: " .. charId .. ".json   isPlayer: " .. tostring(isPlayer)
		.. "   Vista: zoom " .. string.format("%.2f", camView.zoom), 10, 30)

	if panel == "offset" then
		local anim = animList[curAnim]
		if anim then
			local off = editedOffsets[anim.internal]
			love.graphics.print("Animacion: " .. anim.psychName .. " (" .. anim.internal .. ")"
				.. (anim.loop and "  [loop]" or "") .. "  (W/S)", 10, 55)
			love.graphics.print("Offset X: " .. off.x .. "   Offset Y: " .. off.y, 10, 75)
			love.graphics.print("Frame: " .. sprite:getCurrentFrame() .. " / " .. sprite:getFrameCount(), 10, 95)
		end

		for i, a in ipairs(animList) do
			local o = editedOffsets[a.internal]
			local y = 130 + (i - 1) * 16
			if i == curAnim then
				love.graphics.setColor(1, 1, 0)
			else
				love.graphics.setColor(1, 1, 1)
			end
			love.graphics.print(a.psychName .. ": " .. o.x .. ", " .. o.y, 20, y)
		end
		love.graphics.setColor(1, 1, 1)

	elseif panel == "camera" then
		local px, py = cameraPointerPos()
		love.graphics.print("camera_position: " .. def.camera_position[1] .. ", " .. def.camera_position[2]
			.. "   (Flechas para mover, Shift = paso 10)", 10, 55)
		love.graphics.print("Cruz blanca = a donde apunta la camara real del juego (igual formula que states/weeks.lua)", 10, 75)
		love.graphics.print("Posicion del puntero (mundo): " .. string.format("%.1f, %.1f", px, py), 10, 95)
		love.graphics.print("Click izquierdo sobre la cruz y arrastra para moverla", 10, 115)

	elseif panel == "character" then
		drawFieldList(characterFields(), charFieldIndex, 10, 55)

	elseif panel == "animlist" then
		local noFrames = def.animations[animlistSelection] and not sprite:getAnims()[animnames.toInternal(def.animations[animlistSelection].anim)]
		love.graphics.print("N: nueva animacion   Delete: borrar   W/S: elegir animacion (" .. animlistSelection .. "/" .. #def.animations .. ")", 10, 55)
		if noFrames then
			love.graphics.setColor(1, 0.4, 0.4)
			love.graphics.print("(sin frames validos en el atlas todavia -- revisa 'anim'/'Name-Prefix')", 10, 75)
			love.graphics.setColor(1, 1, 1)
		end
		drawFieldList(animFields(), animFieldIndex, 10, 95)
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.print("F1: ayuda   F2: guardar   T: plantilla   Escape: volver",
		10, graphics.getHeight() - 30)

	if saveMessageTimer > 0 then
		love.graphics.setColor(0, 1, 0)
		love.graphics.print(saveMessage, 10, graphics.getHeight() - 50)
		love.graphics.setColor(1, 1, 1)
	end

	if showHelp then
		love.graphics.setColor(0, 0, 0, 0.75)
		love.graphics.rectangle("fill", 0, 0, graphics.getWidth(), graphics.getHeight())

		love.graphics.setColor(1, 1, 1)
		for i, line in ipairs(HELP_LINES) do
			love.graphics.print(line, 40, 30 + (i - 1) * 20)
		end
	end
end

function state:draw()
	love.graphics.clear(0.2, 0.2, 0.2)

	if mode == "browser" then
		drawBrowser()
	else
		drawEditing()
	end
end

function state:leave()
end

return state
