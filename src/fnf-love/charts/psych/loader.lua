-- Punto de entrada para cargar charts en formato Psych Engine (.json).
--
-- Uso desde un weekN.lua:
--   local chart, meta = psychLoader.load("charts/week1/bopeebo" .. difficulty)
--   if chart then weeks:generateNotes(chart); weeks:applyChartMeta(meta)
--   else weeks:generateNotes(love.filesystem.load(path .. ".lua")()) end
--
-- (en la práctica esto lo encapsula weeks:loadChart)

local json = require("lib.json")
local converter = require("charts.psych.converter")

local M = {}

-- BUG real (Too Slow, exportado con una versión nueva de Psych Engine):
-- el formato "psych_v1_convert" pone "song" como STRING (el TÍTULO de la
-- canción, p.ej. "too-slow"), con notes/player1/player2/stage/etc. todos
-- en el nivel superior -- a diferencia del formato viejo (con wrapper),
-- donde "song" es la tabla ANIDADA que contiene todo eso. `decoded.song or
-- decoded` no distingue los dos casos: si decoded.song es un string no
-- vacío (truthy), lo usa TAL CUAL como si fuera la tabla del chart -- y
-- songData.notes explota ("attempt to index a string value") porque
-- songData es literalmente el string del título. Esta función trata
-- "song" como wrapper SOLO si es de verdad una tabla.
local function unwrapSongData(decoded)
	if type(decoded.song) == "table" then
		return decoded.song
	end
	return decoded
end

-- Lee <directorio del chart>/events.json (hermano, igual que Psych Engine
-- separa notas y eventos en archivos distintos). SIEMPRE devuelve una lista
-- YA APLANADA ({time=, name=, value1=, value2=}, mismo formato que
-- converter.lua:M.flattenEvents/M.extractLegacyEvents) -- nunca nil, para
-- que el resto del pipeline pueda iterarla con ipairs sin chequeo de nil.
--
-- BUG real encontrado (Too Slow): esta función solo sabía leer el formato
-- MODERNO (un campo "events" de nivel superior, [[time,[[name,v1,v2],...]],
-- ...]) -- si el events.json usa el formato VIEJO (eventos incrustados
-- dentro de song.notes[].sectionNotes, [time,-1,"name",v1,v2], igual que
-- charts/psych/converter.lua:M.extractLegacyEvents espera del chart
-- principal), esta función devolvía {} SIEMPRE, silenciosamente -- el
-- archivo existía y tenía datos, pero nunca se leían. Ahora intenta el
-- formato moderno primero y, si no hay nada, cae al viejo.
local function loadSiblingEvents(basePath)
	local dir = basePath:match("^(.*/)") or ""
	local eventsPath = dir .. "events.json"

	if not love.filesystem.getInfo(eventsPath) then
		return {}
	end

	local raw = love.filesystem.read(eventsPath)
	if not raw then
		return {}
	end

	local ok, decoded = pcall(json.decode, raw)
	if not ok or not decoded then
		print("WARN: events.json inválido '" .. eventsPath .. "': " .. tostring(decoded))
		return {}
	end

	local eventsData = unwrapSongData(decoded)
	if eventsData.events and #eventsData.events > 0 then
		return converter.flattenEvents(eventsData.events)
	end

	return converter.extractLegacyEvents(eventsData)
end

-- basePath: ruta sin extensión, p.ej. "data/bopeebo/bopeebo-hard"
-- Devuelve chart, meta si existe basePath..".json"; si no, nil.
function M.load(basePath)
	local jsonPath = basePath .. ".json"

	if not love.filesystem.getInfo(jsonPath) then
		return nil
	end

	local raw, readErr = love.filesystem.read(jsonPath)
	if not raw then
		print("WARN: no se pudo leer el chart Psych '" .. jsonPath .. "': " .. tostring(readErr))
		return nil
	end

	local ok, decoded = pcall(json.decode, raw)
	if not ok then
		print("WARN: chart Psych inválido '" .. jsonPath .. "': " .. tostring(decoded))
		return nil
	end

	local songData = unwrapSongData(decoded)

	local okConvert, chart, meta = pcall(converter.convertSong, songData)
	if not okConvert then
		print("WARN: no se pudo convertir el chart Psych '" .. jsonPath .. "': " .. tostring(chart))
		return nil
	end

	-- Si el chart NO trae sus propios eventos (ni modernos en song.events,
	-- ni viejos incrustados en sectionNotes -- M.convertSong ya mezcló
	-- ambos en meta.events), buscarlos en el events.json hermano y
	-- mezclarlos acá. Antes esto se intentaba ANTES de convertSong,
	-- pisando songData.events con el resultado (ya aplanado) de
	-- loadSiblingEvents, que luego M.flattenEvents (formato crudo) volvía
	-- a procesar mal -- los dos formatos no son compatibles entre sí.
	if meta and (not meta.events or #meta.events == 0) then
		meta.events = loadSiblingEvents(basePath)
	end

	return chart, meta
end

-- Convierte un songData en memoria (tabla ya decodificada, p.ej. desde el
-- editor de charts) sin leer ningún archivo. Mismo resultado que M.load pero
-- omite la parte de IO. Devuelve chart, meta, o nil+nil si falla.
function M.loadFromData(songData)
	local data = (type(songData) == "table" and unwrapSongData(songData)) or songData
	local okConvert, chart, meta = pcall(converter.convertSong, data)
	if not okConvert then
		print("WARN: no se pudo convertir el chart en memoria: " .. tostring(chart))
		return nil, nil
	end
	return chart, meta
end

return M
