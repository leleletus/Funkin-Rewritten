--[[----------------------------------------------------------------------------
  genericWeek — semana 100% data-driven, sin necesitar weeks/<id>.lua

  FASE 1 de la refactorización de ergonomía de modding (auditoría completa
  Psych Engine real vs este puerto, ver memoria del proyecto
  "modding-ergonomics-refactor"). Hallazgo crítico #1: toda semana, sin
  excepción, necesitaba un weeks/<id>.lua escrito a mano (enter/load/initUI/
  update/draw/loadStage/leave) aunque reutilizara un stage y personajes
  100% existentes -- en Psych Engine real, una semana así es PURO JSON
  (PlayState.hx es genérico, no existe ningún .hx por semana).

  M.create(weekId) devuelve una tabla con la MISMA forma que un módulo
  weeks/<id>.lua manual -- mismo patrón ya usado en weeks/week1-3.lua (los
  3 sin lógica propia), leído línea por línea antes de escribir esto.
  Sirve para CUALQUIER semana simple: un solo stage fijo para toda la
  semana, sin lógica de cámara/cutscene/transición propia por canción.
  Semanas con eso (week4: zoom de cámara cronometrado; week5: cambio de
  stage/villano a mitad; weekend1/sserafim/etc: cutscenes/efectos custom)
  SIGUEN necesitando su propio .lua -- esto es un FALLBACK para el caso
  simple, no una migración forzada (ver modules/weekLoader.lua).

  weekJSON.weekBackground -- YA existe en TODOS los weeks/<id>.json desde
  siempre, y YA coincide exacto con el nombre de carpeta del stage en las
  8 semanas comprobadas (week1->"stage", week2->"spooky", ...,
  weekend1->"phillyStreets") -- pero NINGÚN código lo leía hasta esta
  fase (confirmado por grep, cero resultados). No hace falta ningún campo
  nuevo en el esquema del JSON para que esto funcione.
------------------------------------------------------------------------------]]

local json = require("lib.json")

local M = {}

-- Centraliza las 2 rutas que se repetían copy-pasteadas en cada
-- weeks/<id>.lua manual (pedido explícito del usuario, hallazgo #2 de la
-- auditoría de canciones/charts).
local function audioPathsFor(fileName)
	return "music/" .. fileName .. "/Inst.ogg", "music/" .. fileName .. "/Voices.ogg"
end

local function chartPathFor(fileName, difficulty)
	return "data/" .. fileName .. "/" .. fileName .. difficulty
end

-- M.create(weekId): cada llamada arma su PROPIO conjunto de variables
-- (weekJSON/stage/song/difficulty) como locales DENTRO de esta función,
-- no a nivel de módulo -- detalle de implementación verificado a mano
-- contra weeks/week1-3.lua antes de escribir esto: ahí, "song"/
-- "difficulty" son locales A NIVEL DE ARCHIVO (no campos de self/
-- weekState), y funcionan como estado privado porque require() carga
-- cada .lua UNA sola vez, con sus propias upvalues. Si esto se
-- declarara a nivel de MÓDULO acá (fuera de create()), TODAS las
-- semanas que usaran este sistema compartirían el mismo contador de
-- canción -- un bug real de estado cruzado apenas hubiera más de una
-- instancia viva a la vez. Declarándolas dentro de create(), cada
-- llamada cierra sobre su propio conjunto independiente, replicando
-- exactamente el aislamiento que ya tiene cada archivo de semana manual.
function M.create(weekId)
	local weekJSON = json.decode(love.filesystem.read("weeks/" .. weekId .. ".json"))
	local stage = require("stages." .. weekJSON.weekBackground .. ".stage")
	local song, difficulty

	return {
		enter = function(self, from, songNum, songAppend, isStoryMode, songName)
			weeks.enter(self, songNum, songAppend, isStoryMode, songName)
			self:loadStage(songNum, songAppend)
			self:load()
		end,

		load = function(self)
			weeks:load()

			local fileName = weekJSON.songs[song][4]
			local instPath, voicesPath = audioPathsFor(fileName)
			inst   = love.audio.newSource(instPath,   "stream")
			voices = love.audio.newSource(voicesPath, "stream")

			self:initUI()
			weeks:setupCountdown()
		end,

		initUI = function(self)
			weeks:initUI()

			local fileName = weekJSON.songs[song][4]
			weeks:loadChart(chartPathFor(fileName, difficulty))
		end,

		update = function(self, dt)
			weeks:update(dt)
			stage.update(dt)

			-- "song < #weekJSON.songs" -- la fórmula CORRECTA (dinámica,
			-- usada por week2.lua en adelante). weeks/week1.lua:56 tiene
			-- "song < 3" hardcodeado (un bug real, documentado en la
			-- auditoría) -- no se replica acá a propósito.
			if not (countingDown or graphics.isFading()) and weeks.songEnded then
				if _G.storyMode and song < #weekJSON.songs then
					song = song + 1
					_G.currentSongIndex = song
					_G.currentSongName  = _G.weekSongs[song]
					self:load()
				end
			end

			weeks:updateUI(dt)
		end,

		draw = function(self)
			stage.draw()
			weeks:drawUI()
		end,

		loadStage = function(self, songNum, songAppend)
			song       = songNum
			difficulty = songAppend
			-- Lua ignora argumentos extra sin error -- stages/stage/stage.lua
			-- (la única semana cuyo M.load() no toma songNum) no se rompe
			-- si igual se le pasa acá, confirmado leyendo su firma real.
			stage.load(songNum)
		end,

		leave = function(self)
			stage.leave()
			weeks:leave()
		end,
	}
end

return M
