-- Aplica posiciones de stage (formato Psych Engine, stages/data/<id>.json) a
-- boyfriend/girlfriend/enemy, igual que PlayState.hx hace con
-- stageData.boyfriend/girlfriend/opponent.
--
-- Fórmula (verificada exacta contra los valores ya correctos de Week 1):
--   sprite.x = stageJSON.slot.x + sprite._slotConversionX + sprite._charOffsetX
--   sprite.y = stageJSON.slot.y + sprite._slotConversionY + sprite._charOffsetY
-- Donde _slotConversionX/Y convierte el sistema de coordenadas de Psych
-- (top-left del bounding box sin trim) al de FNF Rewritten (centro del
-- bounding box sin trim) -- ver modules/graphics.lua:getOrigin() -- y
-- _charOffsetX/Y es el offset propio del personaje ("position" en su JSON).
-- Ambos los calcula y guarda charts/psych/characters.lua:loadInto().
--
-- Por diseño, M.apply() es una función PURA de reposicionamiento: asignación
-- absoluta (nunca acumulativa), no toca animaciones ni recarga nada. Llamarla
-- dos veces seguidas con el mismo id da exactamente el mismo resultado.

local stagedata = require("charts.psych.stagedata")

local M = {}

local currentStageId

-- id: nombre del stage (stages/data/<id>.json). Devuelve la tabla de datos
-- del stage, o nil + warn si no existe.
function M.get(id)
	if not id then return nil end

	local data = stagedata.load(id)
	if not data then
		print("WARN: stage Psych '" .. tostring(id) .. "' sin datos definidos en FNF Rewritten, se mantienen las posiciones actuales")
	end

	return data
end

-- Id del último stage aplicado con M.apply() (p.ej. "school", "mallEvil").
-- Usado por states/weeks.lua para leer camera_boyfriend/camera_opponent/
-- camera_girlfriend del stage activo sin acoplarse a cada stages/*/stage.lua.
function M.getCurrentId()
	return currentStageId
end

-- Datos completos (tabla de stagedata.lua) del stage activo, o nil si
-- ninguno se aplicó todavía o el id no existe.
function M.getCurrentData()
	if not currentStageId then return nil end
	return stagedata.load(currentStageId)
end

-- Reposiciona boyfriend/girlfriend/enemy según el stage indicado, y aplica
-- su defaultZoom (igual que PlayState.hx hace `FlxG.camera.zoom =
-- defaultCamZoom = stageData.defaultZoom` al cargar el stage -- antes cada
-- weekN.lua tenía que leerlo y aplicarlo a mano, y la mayoría ni lo hacía,
-- corriendo con zoom=1 en vez del real). Idempotente: no acumula sobre la
-- posición/zoom anterior, ni toca nada más.
function M.apply(id)
	local data = M.get(id)
	if not data then return false end

	currentStageId = id

	local slots = {
		boyfriend  = data.boyfriend,
		girlfriend = data.girlfriend,
		enemy      = data.opponent,
	}

	for slot, pos in pairs(slots) do
		local sprite = _G[slot]
		if sprite and pos then
			sprite.x = pos[1] + (sprite._slotConversionX or 0) + (sprite._charOffsetX or 0)
			sprite.y = pos[2] + (sprite._slotConversionY or 0) + (sprite._charOffsetY or 0)
		end
	end

	if _G.girlfriend then
		_G.girlfriend.visible = not data.hide_girlfriend
	end

	if _G.camScale then
		camScale.x, camScale.y = data.defaultZoom, data.defaultZoom
	end
	if _G.cam then
		cam.sizeX, cam.sizeY = data.defaultZoom, data.defaultZoom
	end

	return true
end

-- Expuesto para el editor de charts (selector de stages): lista de ids
-- derivada de los archivos reales en stages/data/, no hardcodeada.
local STAGES = {}
for _, file in ipairs(love.filesystem.getDirectoryItems("stages/data")) do
	local id = file:match("^(.+)%.json$")
	if id then STAGES[id] = true end
end
M.STAGES = STAGES

return M
