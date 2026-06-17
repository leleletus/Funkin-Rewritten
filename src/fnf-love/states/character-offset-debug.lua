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
Character Offset Debug — editor visual de offsets para personajes Psych
Engine (characters/*.json), réplica de CharacterEditorState.hx de Psych.

Controles en el navegador:
  ↑/↓ o rueda : mover selección
  Enter       : cargar personaje
  Escape      : volver al menú de depuración

Controles en edición:
  Q/E              : animación anterior/siguiente
  Flechas          : mover el offset de la animación actual (Shift = paso 10,
                     mantener pulsado repite tras 0.6s)
  Espacio          : repetir la animación actual
  Ctrl+R           : resetear el offset actual a (0, 0)
  Ctrl+C / Ctrl+V  : copiar / pegar offset
  Ctrl+Z           : deshacer el último reset/paste
  F1               : mostrar/ocultar ayuda
  F2               : guardar characters/<id>.json
  Rueda            : zoom
  Escape           : volver al navegador
]]

local state = {}
local graphics, input, json, character, animnames

local CHAR_DIR = "characters"

-- Navegador
local browser = {
	entries = {},
	selection = 1,
}

local mode = "browser" -- "browser" | "editing"

-- Edición
local charId
local sprite
local def
local rawText
local animList -- {psychName=, internal=, loop=}
local editedOffsets -- [internal] = {x=, y=}
local originalOffsets -- [internal] = {x=, y=}
local curAnim = 1
local zoom = 1
local showHelp = false
local copiedOffset = {0, 0}
local undoOffset = nil

local holdTime = 0
local holdElapsed = 0

local saveMessage = ""
local saveMessageTimer = 0

local HELP_LINES = {
	"=== AYUDA ===",
	"",
	"Q / E             - Animacion anterior/siguiente",
	"Flechas           - Mover offset (Shift = paso 10, mantener repite)",
	"Espacio           - Repetir animacion actual",
	"Ctrl + R          - Resetear offset actual a (0, 0)",
	"Ctrl + C / Ctrl + V - Copiar / pegar offset",
	"Ctrl + Z          - Deshacer ultimo reset/paste",
	"F2                - Guardar characters/<id>.json",
	"Rueda del mouse   - Zoom",
	"Escape            - Volver al navegador",
	"",
	"F1 o Escape para cerrar esta ayuda",
}

local function updateBrowserEntries()
	browser.entries = {}

	for _, item in ipairs(love.filesystem.getDirectoryItems(CHAR_DIR)) do
		local id = item:match("^(.+)%.json$")
		if id then table.insert(browser.entries, id) end
	end

	table.sort(browser.entries)

	if browser.selection > #browser.entries then browser.selection = #browser.entries end
	if browser.selection < 1 then browser.selection = 1 end
end

local function isPlayerName(id)
	return id == "bf" or id:match("^bf%-") ~= nil
end

-- Recalcula sprite.offsetX/Y para que el offset EDITADO de la animación
-- actual se vea en pantalla sin tocar character.lua/graphics.lua (ver plan):
-- anim.offsetX ya tiene horneado rawOriginal + bias, así que sumando
-- (edited - original) el resultado equivale a rawEdited + bias.
local function applyOffset()
	local anim = animList[curAnim]
	if not anim then return end

	local edited = editedOffsets[anim.internal]
	local original = originalOffsets[anim.internal]

	sprite.offsetX = edited.x - original.x
	sprite.offsetY = edited.y - original.y
end

local function switchAnim(index)
	curAnim = ((index - 1) % #animList) + 1

	local anim = animList[curAnim]
	sprite:animate(anim.internal, anim.loop or false)
	applyOffset()
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

	local ok2, loadedSprite = pcall(character.load, jsonPath, isPlayerName(id))
	if not ok2 or not loadedSprite then
		print("WARN: no se pudo cargar el personaje '" .. jsonPath .. "': " .. tostring(loadedSprite))
		return false
	end

	charId = id
	def = decoded
	rawText = raw
	sprite = loadedSprite
	sprite.x, sprite.y = 0, 0

	animList = {}
	editedOffsets = {}
	originalOffsets = {}

	local anims = sprite:getAnims()

	for _, animDef in ipairs(def.animations or {}) do
		local internal = animnames.toInternal(animDef.anim)

		if anims[internal] then
			local offsets = animDef.offsets or {0, 0}

			table.insert(animList, {
				psychName = animDef.anim,
				internal = internal,
				loop = animDef.loop,
			})

			editedOffsets[internal] = {x = offsets[1] or 0, y = offsets[2] or 0}
			originalOffsets[internal] = {x = offsets[1] or 0, y = offsets[2] or 0}
		end
	end

	curAnim = 1
	if #animList > 0 then switchAnim(1) end

	zoom = 1
	showHelp = false
	copiedOffset = {0, 0}
	undoOffset = nil
	holdTime, holdElapsed = 0, 0
	saveMessage, saveMessageTimer = "", 0

	return true
end

-- Reemplaza únicamente los dos números de cada "offsets": [x, y] del JSON
-- original, en el mismo orden en que aparecen def.animations[] (preserva
-- formato/orden/indentación del resto del archivo).
local function saveCharacter()
	local i = 0

	local newText = rawText:gsub('("offsets"%s*:%s*%[%s*)(%-?%d+)(%s*,%s*)(%-?%d+)(%s*%])',
		function(pre, n1, mid, n2, post)
			i = i + 1

			local animDef = def.animations[i]
			local off = animDef and editedOffsets[animnames.toInternal(animDef.anim)]

			if not off then return pre .. n1 .. mid .. n2 .. post end

			return pre .. tostring(math.floor(off.x)) .. mid .. tostring(math.floor(off.y)) .. post
		end)

	love.filesystem.createDirectory(CHAR_DIR)

	local filename = CHAR_DIR .. "/" .. charId .. ".json"
	local ok, writeErr = love.filesystem.write(filename, newText)

	if ok then
		saveMessage = "Guardado en " .. love.filesystem.getSaveDirectory() .. "/" .. filename
		print("[CHARACTER-OFFSET-DEBUG] " .. saveMessage)
	else
		saveMessage = "Error al guardar: " .. tostring(writeErr)
		print("[CHARACTER-OFFSET-DEBUG] " .. saveMessage)
	end

	saveMessageTimer = 4
end

local function ctrlDown()
	return love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
end

local function shiftDown()
	return love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
end

function state:enter()
	graphics = require("modules.graphics")
	input = require("input")
	json = require("lib.json")
	character = require("charts.psych.character")
	animnames = require("charts.psych.animnames")

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

local function updateEditing(dt)
	sprite:update(dt)

	if input:pressed("f1") then showHelp = not showHelp end

	if showHelp then
		if input:pressed("back") then showHelp = false end
		return
	end

	if #animList > 1 then
		if input:pressed("prevAnim") then
			switchAnim(curAnim - 1)
		elseif input:pressed("nextAnim") then
			switchAnim(curAnim + 1)
		end
	end

	if input:pressed("space") then
		local anim = animList[curAnim]
		sprite:animate(anim.internal, anim.loop or false)
		applyOffset()
	end

	local anim = animList[curAnim]
	local off = editedOffsets[anim.internal]
	local step = shiftDown() and 10 or 1
	local changed = false

	-- Tap inicial (igual que moveKeysP en Psych)
	if input:pressed("left") then off.x = off.x + step; changed = true end
	if input:pressed("right") then off.x = off.x - step; changed = true end
	if input:pressed("up") then off.y = off.y + step; changed = true end
	if input:pressed("down") then off.y = off.y - step; changed = true end

	-- Repetición al mantener pulsado (holdingArrowsTime/holdingArrowsElapsed)
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

	if changed then applyOffset() end

	if input:pressed("save") then saveCharacter() end

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
		zoom = zoom + y * 0.1
		if zoom < 0.1 then zoom = 0.1 end
		if zoom > 5 then zoom = 5 end
	end
end

local function drawBrowser()
	love.graphics.setColor(1, 1, 0)
	love.graphics.print("=== CHARACTER OFFSET DEBUG ===", 10, 10)
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

local function drawEditing()
	love.graphics.push()
		love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
		love.graphics.scale(zoom)
		sprite:draw()
	love.graphics.pop()

	love.graphics.setColor(1, 1, 0)
	love.graphics.print("=== CHARACTER OFFSET DEBUG ===", 10, 10)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Personaje: " .. charId .. ".json", 10, 30)

	local anim = animList[curAnim]
	local off = editedOffsets[anim.internal]

	love.graphics.print("Animacion: " .. anim.psychName .. " (" .. anim.internal .. ")"
		.. (anim.loop and "  [loop]" or "") .. "  (Q/E)", 10, 50)
	love.graphics.print("Offset X: " .. off.x .. "   Offset Y: " .. off.y, 10, 70)
	love.graphics.print("Zoom: " .. string.format("%.1f", zoom) .. " (rueda)", 10, 90)

	-- Lista de animaciones, resaltando la actual (animsTxt de Psych)
	for i, a in ipairs(animList) do
		local o = editedOffsets[a.internal]
		local y = 120 + (i - 1) * 16

		if i == curAnim then
			love.graphics.setColor(1, 1, 0)
		else
			love.graphics.setColor(1, 1, 1)
		end

		love.graphics.print(a.psychName .. ": " .. o.x .. ", " .. o.y, 20, y)
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Flechas: mover offset (Shift = paso 10)   Espacio: repetir   F1: ayuda   F2: guardar   Escape: volver",
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
			love.graphics.print(line, 40, 40 + (i - 1) * 20)
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
