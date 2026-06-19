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

-- Lee <directorio del chart>/events.json (hermano, igual que Psych Engine
-- separa notas y eventos en archivos distintos). SIEMPRE devuelve una tabla
-- (posiblemente vacía) — nunca nil, para que el resto del pipeline pueda
-- iterarla con ipairs sin chequeo de nil en cada call site.
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

	local eventsData = decoded.song or decoded
	return eventsData.events or {}
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

	local songData = decoded.song or decoded

	-- Si el chart no trae eventos embebidos (formato moderno de Psych, donde
	-- viven en events.json aparte), buscarlos en el archivo hermano.
	if not songData.events or #songData.events == 0 then
		songData.events = loadSiblingEvents(basePath)
	end

	local okConvert, chart, meta = pcall(converter.convertSong, songData)
	if not okConvert then
		print("WARN: no se pudo convertir el chart Psych '" .. jsonPath .. "': " .. tostring(chart))
		return nil
	end

	return chart, meta
end

-- Convierte un songData en memoria (tabla ya decodificada, p.ej. desde el
-- editor de charts) sin leer ningún archivo. Mismo resultado que M.load pero
-- omite la parte de IO. Devuelve chart, meta, o nil+nil si falla.
function M.loadFromData(songData)
	local data = (type(songData) == "table" and (songData.song or songData)) or songData
	local okConvert, chart, meta = pcall(converter.convertSong, data)
	if not okConvert then
		print("WARN: no se pudo convertir el chart en memoria: " .. tostring(chart))
		return nil, nil
	end
	return chart, meta
end

return M
