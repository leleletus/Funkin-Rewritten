-- Loader genérico de datos de stage en formato Psych Engine
-- (stages/data/<id>.json). Solo posiciones/cámara/zoom — sin lógica de fondo
-- ni animaciones, igual que stage.json en Psych Engine (la lógica vive en
-- cada stages/<id>/stage.lua, igual que <Id>.hx en Psych).

local json = require("lib.json")

local M = {}

local cache = {}

-- id: nombre del stage (p.ej. "spooky", "mallEvil", "tank")
-- Devuelve la tabla decodificada de stages/data/<id>.json, cacheada para no
-- releer/decodificar el mismo archivo más de una vez por sesión.
function M.load(id)
	if cache[id] then return cache[id] end

	local jsonPath = "stages/data/" .. id .. ".json"
	local raw, readErr = love.filesystem.read(jsonPath)
	if not raw then
		print("WARN: no se pudo leer el stage Psych '" .. jsonPath .. "': " .. tostring(readErr))
		return nil
	end

	local ok, decoded = pcall(json.decode, raw)
	if not ok or not decoded then
		print("WARN: stage Psych inválido '" .. jsonPath .. "': " .. tostring(decoded))
		return nil
	end

	local data = {
		directory        = decoded.directory,
		defaultZoom       = decoded.defaultZoom or 1,
		stageUI           = decoded.stageUI or "",
		boyfriend         = decoded.boyfriend or {0, 0},
		girlfriend        = decoded.girlfriend or {0, 0},
		opponent          = decoded.opponent or {0, 0},
		hide_girlfriend   = decoded.hide_girlfriend or false,
		camera_boyfriend  = decoded.camera_boyfriend or {0, 0},
		camera_opponent   = decoded.camera_opponent or {0, 0},
		camera_girlfriend = decoded.camera_girlfriend or {0, 0},
		camera_speed      = decoded.camera_speed or 1,
	}

	cache[id] = data

	return data
end

return M
