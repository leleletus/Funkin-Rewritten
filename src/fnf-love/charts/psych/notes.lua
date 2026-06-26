-- Loader genérico de notas/strums en formato Psych Engine real
-- (images/png/notes.png + notes.xml -- copia exacta de
-- assets/shared/images/noteSkins/NOTE_assets.png/.xml de Psych Engine).
--
-- Reemplaza las tablas de coordenadas escritas a mano que tenían
-- sprites/{down,up,left,right}-arrow.lua -- ahora los frames se leen del
-- atlas Sparrow real, igual que charts/psych/character.lua ya hace para
-- personajes. Evita errores de transcripción manual (hubo al menos uno real:
-- left-arrow.lua tenía el patrón de recorte de "confirm" invertido respecto
-- al atlas real).
--
-- Las notas en semanas pixel NO usan este módulo -- ese atlas no tiene XML
-- en Psych real tampoco (es una grilla simple), así que sprites/pixel/*-arrow.lua
-- se deja como está.

local graphics = require("modules.graphics")
local atlas = require("charts.psych.atlas")

local M = {}

local framesCache

local function loadFrames()
	if framesCache then return framesCache end

	-- notes.xml vive junto a images/png/notes.png, nunca como variante .dds
	-- -- derivarlo de graphics.imagePath("notes") rompe esto en modo
	-- compresión de hardware (devuelve notes.dds, y el gsub no hace nada
	-- sobre una ruta que no termina en .png).
	framesCache = atlas.loadSparrow("images/png/notes.xml")

	return framesCache
end

-- Busca el frame cuyo nombre es EXACTAMENTE `name` (los nombres en
-- notes.xml ya incluyen el índice de 4 dígitos, no hace falta addByPrefix).
local function findFrame(frames, name)
	for _, f in ipairs(frames) do
		if f.name == name then return f end
	end

	error("charts/psych/notes.lua: no se encontró el frame '" .. name .. "' en notes.xml")
end

local function toFrameData(f)
	return {
		x = f.x,
		y = f.y,
		width = f.width,
		height = f.height,
		offsetX = f.frameX,
		offsetY = f.frameY,
		offsetWidth = f.frameWidth,
		offsetHeight = f.frameHeight,
	}
end

-- direction: "down"/"up"/"left"/"right" (minúscula, para "<direction> confirm0000").
-- arrowName: "arrowDOWN"/"arrowUP"/"arrowLEFT"/"arrowRIGHT" (frame de la
-- flecha gris en reposo del strum).
-- color: "blue"/"green"/"purple"/"red" (nota coloreada + piezas de sustain).
function M.build(direction, arrowName, color)
	local frames = loadFrames()
	local fd = {}

	local function push(name)
		table.insert(fd, toFrameData(findFrame(frames, name)))
		return #fd
	end

	local off  = push(arrowName .. "0000")
	local on   = push(color .. "0000")
	local endF = push(color .. " hold end0000")
	local hold = push(color .. " hold piece0000")

	local confirmStart = push(direction .. " confirm0000")
	push(direction .. " confirm0001")
	push(direction .. " confirm0002")
	local confirmStop = push(direction .. " confirm0003")

	local pressStart = push(direction .. " press0000")
	push(direction .. " press0001")
	push(direction .. " press0002")
	local pressStop = push(direction .. " press0003")

	local animData = {
		["off"]     = {start = off,  stop = off,  speed = 0,  offsetX = 0, offsetY = 0},
		["on"]      = {start = on,   stop = on,   speed = 0,  offsetX = 0, offsetY = 0},
		["end"]     = {start = endF, stop = endF, speed = 0,  offsetX = 0, offsetY = 0},
		["hold"]    = {start = hold, stop = hold, speed = 0,  offsetX = 0, offsetY = 0},
		["confirm"] = {start = confirmStart, stop = confirmStop, speed = 24, offsetX = 0, offsetY = 0},
		["press"]   = {start = pressStart,   stop = pressStop,   speed = 24, offsetX = 0, offsetY = 0},
	}

	return graphics.newSprite(images.notes, fd, animData, "off", false)
end

return M
