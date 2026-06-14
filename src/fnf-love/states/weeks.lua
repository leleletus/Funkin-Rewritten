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

local highscores = require("highscores")
local settings = require("settings")
skipArrowStartTween = false

local jumpscare = require("events.jumpscare")  -- Carga el módulo jumpscare
local spoopyscare = require("events.spoopyscare")
local icons = require("sprites.icons")

-- ==========================================================
-- OPT: Helper de outline — 4 diagonales en vez de 24 offsets
-- ==========================================================
local OUTLINE_OFFSETS = { {-1,-1}, {1,-1}, {-1,1}, {1,1} }
local function drawTextWithOutline(font, text, x, y, scaleX, scaleY, guiAlpha)
	graphics.setColor(0, 0, 0, guiAlpha)
	for _, off in ipairs(OUTLINE_OFFSETS) do
		love.graphics.print(text, x + off[1], y + off[2], 0, scaleX, scaleY)
	end
	graphics.setColor(1, 1, 1, guiAlpha)
	love.graphics.print(text, x, y, 0, scaleX, scaleY)
end

-- ==========================================================
-- OPT: Cache del string de puntuación (evita format/concat cada frame)
-- ==========================================================
local cachedInfoText = ""
local lastCachedScore = -1
local lastCachedMisses = -1
local lastCachedRatingName = ""
local lastCachedRatingPercent = -1
local lastCachedRatingFC = ""
local cachedInfoTextWidth = 0

-- Variables para el modo BOTPLAY
local botplayActive = false
local botHolding = {false, false, false, false}
local botKeyTimers = {}  -- Para gestionar el retorno a "off" de las flechas

-- Middle Scroll: centra las flechas del jugador y oculta las del oponente
local middleScroll = false

local animList = {
	"left",
	"down",
	"up",
	"right"
}
local inputList = {
	"gameLeft",
	"gameDown",
	"gameUp",
	"gameRight"
}

local NoteSize = 8.5

-- Offset extra en coordenadas mundo para pegar la nota "end" al último "hold" en modo pixel.
-- Si ves hueco: aumenta este valor. Si se superpone: disminúyelo. (Solo afecta modo pixel)
local PIXEL_END_NOTE_OFFSET = (NoteSize - 1) * -13

-- ============================================
-- ESTILOS DE TEXTURA PARA NOTAS EN MODO PÍXEL
-- Para agregar un nuevo estilo, simplemente añade una entrada a esta tabla:
--   miEstilo = function()
--       local img = love.graphics.newImage("ruta/a/mi/textura.png")
--       img:setFilter("nearest", "nearest")
--       return img
--   end,
-- Luego úsalo con: self:setPixelMode(true, "miEstilo")
-- ============================================
local noteTextureStyles = {
	default = function()
		local img = love.graphics.newImage(graphics.imagePath("pixel/notes"))
		img:setFilter("nearest", "nearest")
		return img
	end,
	sonic = function()
		local img = love.graphics.newImage(graphics.imagePath("ycrPixelNotes"))
		img:setFilter("nearest", "nearest")
		return img
	end,
}

local characterColors = {
    boyfriend = {49, 176, 209},                   -- boyfriend
    ["skid and pump"] = {213, 126, 0},            -- skid and pump
    pico = {183, 216, 85},                        -- pico
    ["mommy mearest"] = {216, 85, 142},           -- mommy mearest
    tankman = {225, 225, 225},                    -- tankman
    unknown = {180, 180, 180},                    -- unknown (gris por defecto)
    ["daddy dearest"] = {175, 102, 206},          -- daddy dearest
    ["boyfriend (old)"] = {49, 176, 209},         -- boyfriend (old)
    girlfriend = {165, 0, 77},                    -- girlfriend
    ["dearest duo"] = {196, 94, 174},             -- dearest duo
    monster = {243, 255, 110},                    -- monster
    ["boyfriend (pixel)"] = {49, 176, 209},       -- boyfriend (pixel)
    senpai = {255, 170, 111},                     -- senpai
	["senpai-angry"] = {255, 170, 111},           -- senpai grrr
    spirit = {255, 60, 110},                      -- spirit
	yunjin = {223, 47, 136},                      -- yunjin
	sakura = {223, 47, 136},                      -- sakura
	chaewon  = {223, 47, 136},                    -- chaewon
	eunchae  = {223, 47, 136},                    -- eunchae
	kazuha  = {223, 47, 136},                     -- kazuha
	sonic  = {0, 88, 183},                      -- sonic
	sonic2  = {22, 13, 135},                      -- sonic2
	sonic2poop  = {22, 13, 135},                      -- sonic2poop
	sanic  = {0, 88, 183},                      -- sanic
	crappyonic = {22, 13, 135},
	darnell = {115, 94, 176},                      -- darnell
	majin = {1, 2, 214},
	crappyfriend = {49, 176, 209}
}

camScale = {x = 1, y = 1}   -- zoom base para el efecto de beat

cameraEvents = {}
local spriteTimers = {}
misses = 0
customGirlfriendIdle = customGirlfriendIdle or false

-- Variables para el evento Highlight
local highlightActive = false
local highlightTarget = nil
local guiAlphaObj = {value = 1}
local guiAlphaTween = nil
local highlightCamTimer = nil
local currentMustHit = false

local ratingTimers = {}
local beatPulse = 1
local beatPulseState = "idle"  -- "idle", "rising", "falling"
local beatPulseTimer = 0
local beatRiseTime = 0
local beatFallTime = 0
local holdGroupsInfo = {}
local lastEnemyAnim = ""
local lastBfAnim = ""
local activeHoldGroup = {nil, nil, nil, nil}
local nextGroupId = 1

local useAltAnims
local notMissed = {}
local enemyTimer
-- =============================================================
-- SISTEMA DE SPLASHES (FNF original)
-- Cada hit sick crea una instancia nueva e independiente.
-- Las instancias viven en activeSplashes[i] hasta que su
-- animación termina sola — nunca se interrumpen entre sí.
--
-- shared=true en setSplash significa "usa el mismo loader para
-- los 4 carriles" (ej. BloodSplash). Sigue creando instancias
-- nuevas por hit, igual que shared=false. No hay sprite único.
-- =============================================================
local activeSplashes       = {{}, {}, {}, {}}   -- activeSplashes[lane] = {sprite, ...}
local splashLoaderFns      = {nil, nil, nil, nil}
local splashLoaderIsCustom = false  -- true cuando vienen de setSplash (no default)
local splashCustomAnim     = "splash"  -- animación a usar en fireSplash (custom puede cambiarla)
local splashCustomIsPixel  = false  -- true si el splash custom es pixel (se escala con NoteSize)

-- Crea y lanza un splash en el carril dado.
-- El sprite nace, se anima, y vive hasta que su anim termina solo.
local function fireSplash(laneIdx)
    local loaderFn = splashLoaderFns[laneIdx]
    if not loaderFn then return end
    local sp = loaderFn()
    local scale
    if splashLoaderIsCustom then
        -- Splash custom: escala según lo que se indicó en setSplash
        scale = splashCustomIsPixel and NoteSize or 1.5
    else
        -- Splash default: escala según el modo actual de la canción
        scale = _G.isPixelWeek and NoteSize or 1.5
    end
    sp.sizeX, sp.sizeY = scale, scale
    sp.x = boyfriendArrows[laneIdx].x
    sp.y = boyfriendArrows[laneIdx].y
    sp:animate(splashCustomAnim, false)
    table.insert(activeSplashes[laneIdx], sp)
end

-- Actualiza splashLoaderFns con los loaders default del modo actual,
-- salvo que haya un custom splash activo (que se respeta).
local function resetDefaultSplashLoaders()
    if splashLoaderIsCustom then return end
    splashCustomAnim = "splash"
    local path = _G.isPixelWeek and "sprites/pixel/" or "sprites/"
    splashLoaderFns = {
        love.filesystem.load(path .. "splash-left.lua"),
        love.filesystem.load(path .. "splash-down.lua"),
        love.filesystem.load(path .. "splash-up.lua"),
        love.filesystem.load(path .. "splash-right.lua")
    }
end

-- ============================================
-- SPLASH PERSONALIZADO
-- customSplashLoader : función que devuelve un nuevo sprite (o nil = splash por defecto)
-- customSplashSound  : love.audio.Source a reproducir al disparar el splash (o nil)
-- ============================================
local customSplashLoader = nil
local customSplashSound  = nil
local holdSplashArrows
local holdSplashVisible = {false, false, false, false}
local holdActive = {false, false, false, false}
local holdActiveGroup = {nil, nil, nil, nil}  -- holdGroupId activo por carril
local enemyHoldSplashArrows
local enemyHoldSplashVisible = {false, false, false, false}
local enemyHoldActive = {false, false, false, false}

-- Ventanas de tiempo (ms) y tiempo de eliminación de notas
local HIT_WINDOW_SICK = 45      -- antes 22.5
local HIT_WINDOW_GOOD = 75      -- antes 45
local HIT_WINDOW_BAD = 140      -- antes 90
local HIT_WINDOW_SHIT = 200     -- antes 135
local NOTE_KILL_OFFSET = 300    -- antes 350

return {
	enter = function(self, songIndex, songAppend, isStoryMode, songName)
		self.songName = songName or _G.currentSongName or (_G.weekSongs and _G.weekSongs[songIndex]) or "unknown"
		if isStoryMode ~= nil then
			self.isStoryMode = isStoryMode
			_G.storyMode = isStoryMode
		else
			self.isStoryMode = _G.storyMode or false
		end
		self.songIndex = songIndex or 1
		self.songAppend = songAppend or ""
		self.songEnded = false

		-- ============================================
		-- OPT FIX 1+2: Carga lazy — solo el set que se va a usar.
		-- timeBar compartida (una sola instancia, filter aplicado aquí).
		-- setPixelMode() recargará si cambia el modo en tiempo real.
		-- ============================================
		self.normalResources = nil
		self.pixelResources  = nil

		-- Imagen compartida entre modos: se crea una sola vez por sesión
		if not self._sharedTimeBar then
			self._sharedTimeBar = love.graphics.newImage(graphics.imagePath("timeBar"))
			self._sharedTimeBar:setFilter("nearest", "nearest")  -- OPT FIX 2: una vez, no en drawUI
		end

		if _G.isPixelWeek then
			-- Solo cargar recursos píxel
			local notesImgPixel = love.graphics.newImage(graphics.imagePath("pixel/notes"))
			notesImgPixel:setFilter("nearest", "nearest")
			local numbersImgPixel = love.graphics.newImage(graphics.imagePath("pixel/numbers"))
			numbersImgPixel:setFilter("nearest", "nearest")
			sounds = {
				countdown = {
					three = love.audio.newSource("sounds/pixel/countdown-3.ogg", "static"),
					two   = love.audio.newSource("sounds/pixel/countdown-2.ogg", "static"),
					one   = love.audio.newSource("sounds/pixel/countdown-1.ogg", "static"),
					go    = love.audio.newSource("sounds/pixel/countdown-date.ogg", "static")
				},
				miss = {
					love.audio.newSource("sounds/pixel/miss1.ogg", "static"),
					love.audio.newSource("sounds/pixel/miss2.ogg", "static"),
					love.audio.newSource("sounds/pixel/miss3.ogg", "static")
				},
				death = love.audio.newSource("sounds/pixel/death.ogg", "static")
			}
			images = {
				icons        = love.graphics.newImage(graphics.imagePath("icons")),
				notes        = notesImgPixel,
				numbers      = numbersImgPixel,
				noteSplashes = notesImgPixel,
				timeBar      = self._sharedTimeBar
			}
			sprites = {
				icons   = love.filesystem.load("sprites/icons.lua"),
				numbers = love.filesystem.load("sprites/pixel/numbers.lua")
			}
		else
			-- Solo cargar recursos normales
			sounds = {
				countdown = {
					three = love.audio.newSource("sounds/countdown-3.ogg", "static"),
					two   = love.audio.newSource("sounds/countdown-2.ogg", "static"),
					one   = love.audio.newSource("sounds/countdown-1.ogg", "static"),
					go    = love.audio.newSource("sounds/countdown-go.ogg", "static")
				},
				miss = {
					love.audio.newSource("sounds/miss1.ogg", "static"),
					love.audio.newSource("sounds/miss2.ogg", "static"),
					love.audio.newSource("sounds/miss3.ogg", "static")
				},
				death = love.audio.newSource("sounds/death.ogg", "static")
			}
			images = {
				icons        = love.graphics.newImage(graphics.imagePath("icons")),
				notes        = love.graphics.newImage(graphics.imagePath("notes")),
				numbers      = love.graphics.newImage(graphics.imagePath("numbers")),
				noteSplashes = love.graphics.newImage(graphics.imagePath("noteSplashes")),
				timeBar      = self._sharedTimeBar
			}
			sprites = {
				icons   = love.filesystem.load("sprites/icons.lua"),
				numbers = love.filesystem.load("sprites/numbers.lua")
			}
		end
		-- OPT FIX 1: Eliminada la 3ª carga redundante de timeBar que estaba aquí

		girlfriend = love.filesystem.load("sprites/girlfriend.lua")()
		boyfriend = love.filesystem.load("sprites/boyfriend.lua")()

		if _G.isPixelWeek then
			rating = love.filesystem.load("sprites/pixel/rating.lua")()
		else
			rating = love.filesystem.load("sprites/rating.lua")()
		end	

		if _G.isPixelWeek then
			rating.sizeX, rating.sizeY = NoteSize * 0.75, NoteSize * 0.75
			numbers = {}
			for i = 1, 3 do
				numbers[i] = sprites.numbers()
				numbers[i].sizeX, numbers[i].sizeY = NoteSize * 0.5, NoteSize * 0.5
			end
		else
			rating.sizeX, rating.sizeY = 0.75, 0.75
			numbers = {}
			for i = 1, 3 do
				numbers[i] = sprites.numbers()
				numbers[i].sizeX, numbers[i].sizeY = 0.5, 0.5
			end
		end

		enemyIcon = icons.create()
		boyfriendIcon = icons.create()

		if settings.downscroll then
			enemyIcon.y = -400
			boyfriendIcon.y = -400
		else
			enemyIcon.y = 400
			boyfriendIcon.y = 400
		end
		enemyIcon.sizeX, enemyIcon.sizeY = 1.5, 1.5
		boyfriendIcon.sizeX, boyfriendIcon.sizeY = -1.5, 1.5

		enemyIcon.baseSizeX = enemyIcon.sizeX
		enemyIcon.baseSizeY = enemyIcon.sizeY
		boyfriendIcon.baseSizeX = boyfriendIcon.sizeX
		boyfriendIcon.baseSizeY = boyfriendIcon.sizeY

		countdownFade = {}
		if _G.isPixelWeek then
			countdown = love.filesystem.load("sprites/pixel/countdown_pixel.lua")()
			countdown.sizeX, countdown.sizeY = NoteSize, NoteSize
		else
			countdown = love.filesystem.load("sprites/countdown.lua")()
		end
	end,

	load = function(self)
		if _G.currentSongName then
			self.songName = _G.currentSongName
		elseif _G.weekSongs and self.songIndex then
			self.songName = _G.weekSongs[self.songIndex] or self.songName
		end

		for i = 1, 4 do
			notMissed[i] = true
		end
		useAltAnims = false

		cam.x, cam.y = -boyfriend.x + 100, -boyfriend.y + 75

		rating.x = girlfriend.x
		for i = 1, 3 do
			numbers[i].x = girlfriend.x - 100 + 50 * i
		end

		ratingVisibility = {0}
		combo = 0
		self.songEnded = false

		customGirlfriendIdle = false
		enemy:animate("idle")
		boyfriend:animate("idle")

		spriteTimers[1] = 0  -- girlfriend
		spriteTimers[2] = 0  -- enemy
		spriteTimers[3] = 0  -- boyfriend

		graphics.fadeIn(0.5)
	end,

	initUI = function(self)
		events = {}
		enemyNotes = {}
		boyfriendNotes = {}
		health = 50
		misses = 0
		score = 0
		self.maxCombo = 0

		musicPos = 0
		musicTime = 0
		previousFrameTime = love.timer.getTime() * 1000
		lastReportedPlaytime = 0

		self.songPercent = 0
		self.timeText = "0:00 / 0:00"
		self.songLength = 0

		self.totalNotesHit = 0
		self.totalPlayed = 0
		self.ratingName = "?"
		self.ratingPercent = 0
		self.ratingFC = ""
		self.ratingsData = {
			sick = {hits = 0, score = 350, mod = 1},
			good = {hits = 0, score = 200, mod = 0.8},
			bad = {hits = 0, score = 100, mod = 0.5},
			shit = {hits = 0, score = 50, mod = 0.2}
		}
		self.ratingStuff = {
			{"You Suck!", 0.2},
			{"Shit", 0.4},
			{"Bad", 0.5},
			{"Bruh", 0.6},
			{"Meh", 0.69},
			{"Nice", 0.7},
			{"Good", 0.8},
			{"Great", 0.9},
			{"Sick!", 1},
			{"Perfect!!", 1}
		}
		self.scoreTextScale = 1
		self.scoreTextTween = nil

		-- Reiniciar variables de grupos y botplay
		nextGroupId = 1
		holdGroupsInfo = {}
		botHolding = {false, false, false, false}
		-- Resetear estado de splashes del enemigo Y del jugador.
		-- Si se sale de una canción mientras se sostiene un hold, los flags
		-- quedan en true y el sprite congelado se dibuja en la siguiente canción.
		holdActive             = {false, false, false, false}
		holdActiveGroup        = {nil, nil, nil, nil}
		holdSplashVisible      = {false, false, false, false}
		enemyHoldActive        = {false, false, false, false}
		enemyHoldSplashVisible = {false, false, false, false}
		-- Limpiar instancias de splash activas
		activeSplashes        = {{}, {}, {}, {}}
		splashLoaderFns       = {nil, nil, nil, nil}
		splashLoaderIsCustom  = false
		splashCustomIsPixel   = false

		-- Resetear splash personalizado al iniciar UI
		customSplashLoader = nil
		customSplashSound  = nil
		splashCustomAnim   = "splash"

		self:loadArrowSprites()

		enemyArrows = { sprites.leftArrow(), sprites.downArrow(), sprites.upArrow(), sprites.rightArrow() }
		boyfriendArrows = { sprites.leftArrow(), sprites.downArrow(), sprites.upArrow(), sprites.rightArrow() }
		activeSplashes = {{}, {}, {}, {}}
		holdSplashArrows = { sprites.holdSplashLeft(), sprites.holdSplashDown(), sprites.holdSplashUp(), sprites.holdSplashRight() }
		enemyHoldSplashArrows = { sprites.holdSplashLeft(), sprites.holdSplashDown(), sprites.holdSplashUp(), sprites.holdSplashRight() }

		if _G.isPixelWeek then
			for i = 1, 4 do
				holdSplashArrows[i].sizeX, holdSplashArrows[i].sizeY = NoteSize, NoteSize
				enemyHoldSplashArrows[i].sizeX, enemyHoldSplashArrows[i].sizeY = NoteSize, NoteSize
			end
			for i = 1, 4 do
				if middleScroll then
					boyfriendArrows[i].x = -412.5 + 165 * i
					enemyArrows[i].x = -925 + 165 * i
				else
					enemyArrows[i].x = -925 + 165 * i
					boyfriendArrows[i].x = 100 + 165 * i
				end
				if settings.downscroll then
					enemyArrows[i].y = 375
					boyfriendArrows[i].y = 375
				else
					enemyArrows[i].y = -375
					boyfriendArrows[i].y = -375
				end
				enemyArrows[i].sizeX, enemyArrows[i].sizeY = NoteSize, NoteSize
				boyfriendArrows[i].sizeX, boyfriendArrows[i].sizeY = NoteSize, NoteSize
				holdSplashArrows[i].x = boyfriendArrows[i].x
				holdSplashArrows[i].y = boyfriendArrows[i].y
				enemyHoldSplashArrows[i].x = enemyArrows[i].x
				enemyHoldSplashArrows[i].y = enemyArrows[i].y
				enemyNotes[i] = {}
				boyfriendNotes[i] = {}
			end
		else
			for i = 1, 4 do
				holdSplashArrows[i].sizeX, holdSplashArrows[i].sizeY = 1.5, 1.5
				enemyHoldSplashArrows[i].sizeX, enemyHoldSplashArrows[i].sizeY = 1.5, 1.5
			end
			for i = 1, 4 do
				if middleScroll then
					boyfriendArrows[i].x = -412.5 + 165 * i
					enemyArrows[i].x = -925 + 165 * i
				else
					enemyArrows[i].x = -925 + 165 * i
					boyfriendArrows[i].x = 100 + 165 * i
				end
				if settings.downscroll then
					enemyArrows[i].y = 375
					boyfriendArrows[i].y = 375
				else
					enemyArrows[i].y = -375
					boyfriendArrows[i].y = -375
				end
				holdSplashArrows[i].x = boyfriendArrows[i].x
				holdSplashArrows[i].y = boyfriendArrows[i].y
				enemyHoldSplashArrows[i].x = enemyArrows[i].x
				enemyHoldSplashArrows[i].y = enemyArrows[i].y
				enemyNotes[i] = {}
				boyfriendNotes[i] = {}
			end
		end
		-- Cargar loaders default del modo actual (pixel o normal)
		resetDefaultSplashLoaders()

		if not skipArrowStartTween then
			for i = 1, 4 do
				local enemyOriginalY = enemyArrows[i].y
				local boyfriendOriginalY = boyfriendArrows[i].y

				enemyArrows[i].alpha = 0
				enemyArrows[i].y = enemyOriginalY - 20

				boyfriendArrows[i].alpha = 0
				boyfriendArrows[i].y = boyfriendOriginalY - 20

				Timer.after(0.5 + 0.2 * (i-1), function()
					Timer.tween(1, enemyArrows[i], {alpha = 1, y = enemyOriginalY}, "out-circ")
					Timer.tween(1, boyfriendArrows[i], {alpha = 1, y = boyfriendOriginalY}, "out-circ")
				end)
			end
		else
			for i = 1, 4 do
				enemyArrows[i].alpha = 1
				boyfriendArrows[i].alpha = 1
			end
		end
	end,

	generateNotes = function(self, chart)
		local eventBpm
		local tiempo_acumulado = 0
		local bpm_anterior = nil

		for i = 1, #chart do
			bpm = chart[i].bpm
			if bpm then
				break
			end
		end
		if not bpm then
			bpm = 100
		end
		self.bpm = bpm

		speed = chart.speed
		local noteScale = _G.isPixelWeek and NoteSize or 1
		-- En pixel los sprites "hold" son NoteSize veces más altos visualmente,
		-- la nota "end" necesita desplazarse extra para quedar pegada sin hueco.
		local endNoteYOffset = _G.isPixelWeek and PIXEL_END_NOTE_OFFSET or 0

		for i = 1, #chart do
			local seccion = chart[i]
			eventBpm = seccion.bpm

			-- Calcular duración de la sección
			local lengthInSteps = seccion.lengthInSteps or 16
			local bpm_activo = eventBpm or bpm_anterior or bpm
			local duracion_seccion = (lengthInSteps / 16.0) * (240000.0 / bpm_activo)

			-- Detectar cambio de BPM en sección vacía
			if eventBpm and eventBpm ~= bpm_anterior then
				if #seccion.sectionNotes == 0 then
					table.insert(events, {
						eventTime = tiempo_acumulado,
						mustHitSection = seccion.mustHitSection or false,
						bpm = eventBpm,
						altAnim = seccion.altAnim or false
					})
				end
				bpm_anterior = eventBpm
			end

			for j = 1, #seccion.sectionNotes do
				local sprite

				local mustHitSection = seccion.mustHitSection
				local altAnim = seccion.altAnim
				local noteType = seccion.sectionNotes[j].noteType
				local noteTime = seccion.sectionNotes[j].noteTime
				local noteKind = seccion.sectionNotes[j].noteKind  -- Blazin fight note kind

				-- Crear grupo para notas largas
				local currentHoldGroupId = nil
				if seccion.sectionNotes[j].noteLength and seccion.sectionNotes[j].noteLength > 0 then
					currentHoldGroupId = nextGroupId
					nextGroupId = nextGroupId + 1
					holdGroupsInfo[currentHoldGroupId] = {hitCount = 0, totalNotes = 0, missed = false, completed = false, ratingType = nil}
				end

				if j == 1 then
					table.insert(events, {eventTime = seccion.sectionNotes[1].noteTime, mustHitSection = mustHitSection, bpm = eventBpm, altAnim = altAnim})
				end

				if noteType == 0 or noteType == 4 then
					sprite = sprites.leftArrow
				elseif noteType == 1 or noteType == 5 then
					sprite = sprites.downArrow
				elseif noteType == 2 or noteType == 6 then
					sprite = sprites.upArrow
				elseif noteType == 3 or noteType == 7 then
					sprite = sprites.rightArrow
				end

				if settings.downscroll then
					if mustHitSection then
						if noteType >= 4 then
							local id = noteType - 3
							local c = #enemyNotes[id] + 1
							local x = enemyArrows[id].x

							local newNote = sprite()
							newNote.sizeX, newNote.sizeY = noteScale, noteScale
							newNote.noteKind = noteKind
							table.insert(enemyNotes[id], newNote)
							enemyNotes[id][c].x = x
							enemyNotes[id][c].y = 375 - noteTime * 0.6 * speed
							enemyNotes[id][c].strumTime = noteTime
							enemyNotes[id][c].hit = false
							enemyNotes[id][c]:animate("on", false)
							enemyNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
							enemyNotes[id][c].isHoldStart = (seccion.sectionNotes[j].noteLength > 0) or false
							-- Asignar grupo si existe
							if currentHoldGroupId then
								holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
								newNote.holdGroupId = currentHoldGroupId
							end

							if seccion.sectionNotes[j].noteLength > 0 then
								for k = 71 / speed, seccion.sectionNotes[j].noteLength, 71 / speed do
									local c = #enemyNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									table.insert(enemyNotes[id], newHoldNote)
									enemyNotes[id][c].x = x
									enemyNotes[id][c].y = 375 - (noteTime + k) * 0.6 * speed
									enemyNotes[id][c].strumTime = noteTime + k
									enemyNotes[id][c].hit = false
									enemyNotes[id][c]:animate("hold", false)
									enemyNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
									enemyNotes[id][c].isHoldStart = false
									if currentHoldGroupId then
										holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
										newHoldNote.holdGroupId = currentHoldGroupId
									end
								end

								c = #enemyNotes[id]
								enemyNotes[id][c].y = enemyNotes[id][c].y - endNoteYOffset
								enemyNotes[id][c].offsetY = -10
								enemyNotes[id][c].sizeY = -noteScale
								enemyNotes[id][c]:animate("end", false)
								enemyNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false 
								enemyNotes[id][c].isHoldStart = false
								if currentHoldGroupId then
									-- Ya se contó en el bucle, pero la última nota ya tiene grupo
								end
							end
						else
							local id = noteType + 1
							local c = #boyfriendNotes[id] + 1
							local x = boyfriendArrows[id].x

							local newNote = sprite()
							newNote.sizeX, newNote.sizeY = noteScale, noteScale
							newNote.noteKind = noteKind
							table.insert(boyfriendNotes[id], newNote)
							boyfriendNotes[id][c].x = x
							boyfriendNotes[id][c].y = 375 - noteTime * 0.6 * speed
							boyfriendNotes[id][c].strumTime = noteTime
							boyfriendNotes[id][c].hit = false
							boyfriendNotes[id][c]:animate("on", false)
							boyfriendNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
							boyfriendNotes[id][c].isHoldStart = (seccion.sectionNotes[j].noteLength > 0) or false
							if currentHoldGroupId then
								holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
								newNote.holdGroupId = currentHoldGroupId
							end

							if seccion.sectionNotes[j].noteLength > 0 then
								for k = 71 / speed, seccion.sectionNotes[j].noteLength, 71 / speed do
									local c = #boyfriendNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									table.insert(boyfriendNotes[id], newHoldNote)
									boyfriendNotes[id][c].x = x
									boyfriendNotes[id][c].y = 375 - (noteTime + k) * 0.6 * speed
									boyfriendNotes[id][c].strumTime = noteTime + k
									boyfriendNotes[id][c].hit = false
									boyfriendNotes[id][c]:animate("hold", false)
									boyfriendNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
									boyfriendNotes[id][c].isHoldStart = false
									if currentHoldGroupId then
										holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
										newHoldNote.holdGroupId = currentHoldGroupId
									end
								end

								c = #boyfriendNotes[id]
								boyfriendNotes[id][c].y = boyfriendNotes[id][c].y - endNoteYOffset
								boyfriendNotes[id][c].offsetY = -10
								boyfriendNotes[id][c].sizeY = -noteScale
								boyfriendNotes[id][c]:animate("end", false)
								boyfriendNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
								boyfriendNotes[id][c].isHoldStart = false
								if currentHoldGroupId then
									-- ya contado
								end
							end
						end
					else
						if noteType >= 4 then
							local id = noteType - 3
							local c = #boyfriendNotes[id] + 1
							local x = boyfriendArrows[id].x

							local newNote = sprite()
							newNote.sizeX, newNote.sizeY = noteScale, noteScale
							newNote.noteKind = noteKind
							table.insert(boyfriendNotes[id], newNote)
							boyfriendNotes[id][c].x = x
							boyfriendNotes[id][c].y = 375 - noteTime * 0.6 * speed
							boyfriendNotes[id][c].strumTime = noteTime
							boyfriendNotes[id][c].hit = false
							boyfriendNotes[id][c]:animate("on", false)
							boyfriendNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
							boyfriendNotes[id][c].isHoldStart = (seccion.sectionNotes[j].noteLength > 0) or false
							if currentHoldGroupId then
								holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
								newNote.holdGroupId = currentHoldGroupId
							end

							if seccion.sectionNotes[j].noteLength > 0 then
								for k = 71 / speed, seccion.sectionNotes[j].noteLength, 71 / speed do
									local c = #boyfriendNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									table.insert(boyfriendNotes[id], newHoldNote)
									boyfriendNotes[id][c].x = x
									boyfriendNotes[id][c].y = 375 - (noteTime + k) * 0.6 * speed
									boyfriendNotes[id][c].strumTime = noteTime + k
									boyfriendNotes[id][c].hit = false
									boyfriendNotes[id][c]:animate("hold", false)
									boyfriendNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
									boyfriendNotes[id][c].isHoldStart = false
									if currentHoldGroupId then
										holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
										newHoldNote.holdGroupId = currentHoldGroupId
									end
								end

								c = #boyfriendNotes[id]
								boyfriendNotes[id][c].y = boyfriendNotes[id][c].y - endNoteYOffset
								boyfriendNotes[id][c].offsetY = -10
								boyfriendNotes[id][c].sizeY = -noteScale
								boyfriendNotes[id][c]:animate("end", false)
								boyfriendNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
								boyfriendNotes[id][c].isHoldStart = false
								if currentHoldGroupId then end
							end
						else
							local id = noteType + 1
							local c = #enemyNotes[id] + 1
							local x = enemyArrows[id].x

							local newNote = sprite()
							newNote.sizeX, newNote.sizeY = noteScale, noteScale
							newNote.noteKind = noteKind
							table.insert(enemyNotes[id], newNote)
							enemyNotes[id][c].x = x
							enemyNotes[id][c].y = 375 - noteTime * 0.6 * speed
							enemyNotes[id][c].strumTime = noteTime
							enemyNotes[id][c].hit = false
							enemyNotes[id][c]:animate("on", false)
							enemyNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
							enemyNotes[id][c].isHoldStart = (seccion.sectionNotes[j].noteLength > 0) or false
							if currentHoldGroupId then
								holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
								newNote.holdGroupId = currentHoldGroupId
							end

							if seccion.sectionNotes[j].noteLength > 0 then
								for k = 71 / speed, seccion.sectionNotes[j].noteLength, 71 / speed do
									local c = #enemyNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									table.insert(enemyNotes[id], newHoldNote)
									enemyNotes[id][c].x = x
									enemyNotes[id][c].y = 375 - (noteTime + k) * 0.6 * speed
									enemyNotes[id][c].strumTime = noteTime + k
									enemyNotes[id][c].hit = false
									enemyNotes[id][c]:animate("hold", false)
									enemyNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
									enemyNotes[id][c].isHoldStart = false
									if currentHoldGroupId then
										holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
										newHoldNote.holdGroupId = currentHoldGroupId
									end
								end

								c = #enemyNotes[id]
								enemyNotes[id][c].y = enemyNotes[id][c].y - endNoteYOffset
								enemyNotes[id][c].offsetY = -10
								enemyNotes[id][c].sizeY = -noteScale
								enemyNotes[id][c]:animate("end", false)
								enemyNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false 
								enemyNotes[id][c].isHoldStart = false
								if currentHoldGroupId then end
							end
						end
					end
				else
					if mustHitSection then
						if noteType >= 4 then
							local id = noteType - 3
							local c = #enemyNotes[id] + 1
							local x = enemyArrows[id].x

							local newNote = sprite()
							newNote.sizeX, newNote.sizeY = noteScale, noteScale
							newNote.noteKind = noteKind
							table.insert(enemyNotes[id], newNote)
							enemyNotes[id][c].x = x
							enemyNotes[id][c].y = -375 + noteTime * 0.6 * speed
							enemyNotes[id][c].strumTime = noteTime
							enemyNotes[id][c].hit = false
							enemyNotes[id][c]:animate("on", false)
							enemyNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
							enemyNotes[id][c].isHoldStart = (seccion.sectionNotes[j].noteLength > 0) or false
							if currentHoldGroupId then
								holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
								newNote.holdGroupId = currentHoldGroupId
							end

							if seccion.sectionNotes[j].noteLength > 0 then
								for k = 71 / speed, seccion.sectionNotes[j].noteLength, 71 / speed do
									local c = #enemyNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									table.insert(enemyNotes[id], newHoldNote)
									enemyNotes[id][c].x = x
									enemyNotes[id][c].y = -375 + (noteTime + k) * 0.6 * speed
									enemyNotes[id][c].strumTime = noteTime + k
									enemyNotes[id][c].hit = false
									enemyNotes[id][c]:animate("hold", false)
									enemyNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
									enemyNotes[id][c].isHoldStart = false
									if currentHoldGroupId then
										holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
										newHoldNote.holdGroupId = currentHoldGroupId
									end
								end

								c = #enemyNotes[id]
								enemyNotes[id][c].y = enemyNotes[id][c].y + endNoteYOffset
								enemyNotes[id][c].offsetY = -10
								enemyNotes[id][c]:animate("end", false)
								enemyNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false 
								enemyNotes[id][c].isHoldStart = false
								if currentHoldGroupId then end
							end
						else
							local id = noteType + 1
							local c = #boyfriendNotes[id] + 1
							local x = boyfriendArrows[id].x

							local newNote = sprite()
							newNote.sizeX, newNote.sizeY = noteScale, noteScale
							newNote.noteKind = noteKind
							table.insert(boyfriendNotes[id], newNote)
							boyfriendNotes[id][c].x = x
							boyfriendNotes[id][c].y = -375 + noteTime * 0.6 * speed
							boyfriendNotes[id][c].strumTime = noteTime
							boyfriendNotes[id][c].hit = false
							boyfriendNotes[id][c]:animate("on", false)
							boyfriendNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
							boyfriendNotes[id][c].isHoldStart = (seccion.sectionNotes[j].noteLength > 0) or false
							if currentHoldGroupId then
								holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
								newNote.holdGroupId = currentHoldGroupId
							end

							if seccion.sectionNotes[j].noteLength > 0 then
								for k = 71 / speed, seccion.sectionNotes[j].noteLength, 71 / speed do
									local c = #boyfriendNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									table.insert(boyfriendNotes[id], newHoldNote)
									boyfriendNotes[id][c].x = x
									boyfriendNotes[id][c].y = -375 + (noteTime + k) * 0.6 * speed
									boyfriendNotes[id][c].strumTime = noteTime + k
									boyfriendNotes[id][c].hit = false
									boyfriendNotes[id][c]:animate("hold", false)
									boyfriendNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
									boyfriendNotes[id][c].isHoldStart = false
									if currentHoldGroupId then
										holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
										newHoldNote.holdGroupId = currentHoldGroupId
									end
								end

								c = #boyfriendNotes[id]
								boyfriendNotes[id][c].y = boyfriendNotes[id][c].y + endNoteYOffset
								boyfriendNotes[id][c].offsetY = -10
								boyfriendNotes[id][c]:animate("end", false)
								boyfriendNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
								boyfriendNotes[id][c].isHoldStart = false
								if currentHoldGroupId then end
							end
						end
					else
						if noteType >= 4 then
							local id = noteType - 3
							local c = #boyfriendNotes[id] + 1
							local x = boyfriendArrows[id].x

							local newNote = sprite()
							newNote.sizeX, newNote.sizeY = noteScale, noteScale
							newNote.noteKind = noteKind
							table.insert(boyfriendNotes[id], newNote)
							boyfriendNotes[id][c].x = x
							boyfriendNotes[id][c].y = -375 + noteTime * 0.6 * speed
							boyfriendNotes[id][c].strumTime = noteTime
							boyfriendNotes[id][c].hit = false
							boyfriendNotes[id][c]:animate("on", false)
							boyfriendNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
							boyfriendNotes[id][c].isHoldStart = (seccion.sectionNotes[j].noteLength > 0) or false
							if currentHoldGroupId then
								holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
								newNote.holdGroupId = currentHoldGroupId
							end

							if seccion.sectionNotes[j].noteLength > 0 then
								for k = 71 / speed, seccion.sectionNotes[j].noteLength, 71 / speed do
									local c = #boyfriendNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									table.insert(boyfriendNotes[id], newHoldNote)
									boyfriendNotes[id][c].x = x
									boyfriendNotes[id][c].y = -375 + (noteTime + k) * 0.6 * speed
									boyfriendNotes[id][c].strumTime = noteTime + k
									boyfriendNotes[id][c].hit = false
									boyfriendNotes[id][c]:animate("hold", false)
									boyfriendNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
									boyfriendNotes[id][c].isHoldStart = false
									if currentHoldGroupId then
										holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
										newHoldNote.holdGroupId = currentHoldGroupId
									end
								end

								c = #boyfriendNotes[id]
								boyfriendNotes[id][c].y = boyfriendNotes[id][c].y + endNoteYOffset
								boyfriendNotes[id][c].offsetY = -10
								boyfriendNotes[id][c]:animate("end", false)
								boyfriendNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
								boyfriendNotes[id][c].isHoldStart = false
								if currentHoldGroupId then end
							end
						else
							local id = noteType + 1
							local c = #enemyNotes[id] + 1
							local x = enemyArrows[id].x

							local newNote = sprite()
							newNote.sizeX, newNote.sizeY = noteScale, noteScale
							newNote.noteKind = noteKind
							table.insert(enemyNotes[id], newNote)
							enemyNotes[id][c].x = x
							enemyNotes[id][c].y = -375 + noteTime * 0.6 * speed
							enemyNotes[id][c].strumTime = noteTime
							enemyNotes[id][c].hit = false
							enemyNotes[id][c]:animate("on", false)
							enemyNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false
							enemyNotes[id][c].isHoldStart = (seccion.sectionNotes[j].noteLength > 0) or false
							if currentHoldGroupId then
								holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
								newNote.holdGroupId = currentHoldGroupId
							end

							if seccion.sectionNotes[j].noteLength > 0 then
								for k = 71 / speed, seccion.sectionNotes[j].noteLength, 71 / speed do
									local c = #enemyNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									table.insert(enemyNotes[id], newHoldNote)
									enemyNotes[id][c].x = x
									enemyNotes[id][c].y = -375 + (noteTime + k) * 0.6 * speed
									enemyNotes[id][c].strumTime = noteTime + k
									enemyNotes[id][c].hit = false
									enemyNotes[id][c]:animate("hold", false)
									enemyNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false 
									enemyNotes[id][c].isHoldStart = false
									if currentHoldGroupId then
										holdGroupsInfo[currentHoldGroupId].totalNotes = holdGroupsInfo[currentHoldGroupId].totalNotes + 1
										newHoldNote.holdGroupId = currentHoldGroupId
									end
								end

								c = #enemyNotes[id]
								enemyNotes[id][c].y = enemyNotes[id][c].y + endNoteYOffset
								enemyNotes[id][c].offsetY = -10
								-- upscroll: sizeY queda positivo (igual que los otros bloques upscroll)
								enemyNotes[id][c]:animate("end", false)
								enemyNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false 
								enemyNotes[id][c].isHoldStart = false
								if currentHoldGroupId then end
							end
						end
					end
				end
			end

			-- Actualizar tiempo acumulado
			tiempo_acumulado = tiempo_acumulado + duracion_seccion
		end

		-- Vaciar la tabla existente manteniendo la referencia
		for i = #cameraEvents, 1, -1 do
			cameraEvents[i] = nil
		end

		-- Recorrer todas las secciones del chart con ipairs (índices numéricos)
		for i, section in ipairs(chart) do
			if section.events then
				-- Recorrer los eventos de la sección con ipairs también
				for j, ev in ipairs(section.events) do
					-- Asegurar que el evento tenga al menos un tipo y un tiempo
					if ev.type and ev.time then
						table.insert(cameraEvents, ev)
					end
				end
			end
		end

		-- Ordenar los eventos por tiempo
		table.sort(cameraEvents, function(a,b) return a.time < b.time end)

		if settings.downscroll then
			for i = 1, 4 do
				table.sort(enemyNotes[i], function(a, b) return a.y > b.y end)
				table.sort(boyfriendNotes[i], function(a, b) return a.y > b.y end)
			end
		else
			for i = 1, 4 do
				table.sort(enemyNotes[i], function(a, b) return a.y < b.y end)
				table.sort(boyfriendNotes[i], function(a, b) return a.y < b.y end)
			end
		end

		-- Eliminar notas duplicadas
		for i = 1, 4 do
			local offset = 0
			for j = 2, #enemyNotes[i] do
				local index = j - offset
				if enemyNotes[i][index]:getAnimName() == "on" and enemyNotes[i][index - 1]:getAnimName() == "on" and ((not settings.downscroll and enemyNotes[i][index].y - enemyNotes[i][index - 1].y <= 10) or (settings.downscroll and enemyNotes[i][index].y - enemyNotes[i][index - 1].y >= -10)) then
					table.remove(enemyNotes[i], index)
					offset = offset + 1
				end
			end
		end
		for i = 1, 4 do
			local offset = 0
			for j = 2, #boyfriendNotes[i] do
				local index = j - offset
				if boyfriendNotes[i][index]:getAnimName() == "on" and boyfriendNotes[i][index - 1]:getAnimName() == "on" and ((not settings.downscroll and boyfriendNotes[i][index].y - boyfriendNotes[i][index - 1].y <= 10) or (settings.downscroll and boyfriendNotes[i][index].y - boyfriendNotes[i][index - 1].y >= -10)) then
					table.remove(boyfriendNotes[i], index)
					offset = offset + 1
				end
			end
		end
		print(">>> cameraEvents después de generar notas:", #cameraEvents)
		for i, ev in ipairs(cameraEvents) do
			print("   Evento", i, "tipo:", ev.type, "tiempo:", ev.time)
		end
	end,

	recalculateRating = function(self, badHit)
        if self.totalPlayed == 0 then
            self.ratingPercent = 0
            self.ratingName = "?"
        else
            self.ratingPercent = math.min(1, math.max(0, self.totalNotesHit / self.totalPlayed))
            self.ratingName = self.ratingStuff[#self.ratingStuff][1]
            for i = 1, #self.ratingStuff - 1 do
                if self.ratingPercent < self.ratingStuff[i][2] then
                    self.ratingName = self.ratingStuff[i][1]
                    break
                end
            end
        end
        local sicks = self.ratingsData.sick.hits
        local goods = self.ratingsData.good.hits
        local bads = self.ratingsData.bad.hits
        local shits = self.ratingsData.shit.hits
        if misses == 0 then
            if bads > 0 or shits > 0 then
                self.ratingFC = 'FC'
            elseif goods > 0 then
                self.ratingFC = 'GFC'
            elseif sicks > 0 then
                self.ratingFC = 'SFC'
            else
                self.ratingFC = ''
            end
        else
            if misses < 10 then
                self.ratingFC = 'SDCB'
            else
                self.ratingFC = 'Clear'
            end
        end
    end,

	setupCountdown = function(self)
		-- Si estamos cargando via weekLoader, no arrancar el countdown todavía.
		-- Marcamos que fue solicitado para que onLoadingComplete lo ejecute después.
		if _G._loadingViaWeekLoader then
			_G._countdownWasSkipped = true
			return
		end

		lastReportedPlaytime = 0
		musicTime = (240 / bpm) * -1000

		musicThres = 0
		musicPos = 0

		local readyAnim = _G.isPixelWeek and "ready-pixel" or "ready"
		local setAnim   = _G.isPixelWeek and "set-pixel"   or "set"
		local goAnim    = _G.isPixelWeek and "date-pixel"  or "go"

		countingDown = true
		countdownFade[1] = 0
		audio.playSound(sounds.countdown.three)
		Timer.after(
			(60 / bpm),
			function()
				countdown:animate(readyAnim)
				countdownFade[1] = 1
				audio.playSound(sounds.countdown.two)
				Timer.tween(
					(60 / bpm),
					countdownFade,
					{0},
					"linear",
					function()
						countdown:animate(setAnim)
						countdownFade[1] = 1
						audio.playSound(sounds.countdown.one)
						Timer.tween(
							(60 / bpm),
							countdownFade,
							{0},
							"linear",
							function()
								countdown:animate(goAnim)
								countdownFade[1] = 1
								audio.playSound(sounds.countdown.go)
								Timer.tween(
									(60 / bpm),
									countdownFade,
									{0},
									"linear",
									function()
										countingDown = false
										previousFrameTime = love.timer.getTime() * 1000
										musicTime = 0
										if inst then inst:play() end
										if voices then voices:play() end
										if inst then
											self.songLength = inst:getDuration() * 1000
										else
											self.songLength = 0
										end
									end
								)
							end
						)
					end
				)
			end
		)
	end,

	safeAnimate = function(self, sprite, animName, loopAnim, timerID)
		-- Girlfriend + "sad": nunca hacer loop, y dar tiempo suficiente
		-- para que la animación se reproduzca completa antes de volver a idle.
		if sprite == girlfriend and animName == "sad" then
			loopAnim = false
		end

		sprite:animate(animName, loopAnim)
		if sprite.isTankman and animName == "down alt" then
			local animDef = sprite.anims[animName]
			local duration = (animDef.stop - animDef.start + 1) / animDef.speed
			if enemyTimer then Timer.cancel(enemyTimer) end
			enemyTimer = Timer.after(duration, function()
				if enemy and enemy:getAnimName() == "down alt" then
					enemy:animate("idle", false)
				end
			end)
			spriteTimers[timerID] = 999999
		elseif sprite.isSonicEXE and animName == "left alt" then
			local animDef = sprite.anims[animName]
			local duration = (animDef.stop - animDef.start + 1) / animDef.speed
			if enemyTimer then Timer.cancel(enemyTimer) end
			enemyTimer = Timer.after(duration, function()
				if enemy and enemy:getAnimName() == "left alt" then
					enemy:animate("idle", false)
				end
			end)
			spriteTimers[timerID] = 999999	
		elseif sprite.isSonicYCR and animName == "up alt" then
			local animDef = sprite.anims[animName]
			local duration = (animDef.stop - animDef.start + 1) / animDef.speed
			if enemyTimer then Timer.cancel(enemyTimer) end
			enemyTimer = Timer.after(duration, function()
				if enemy and enemy:getAnimName() == "up alt" then
					enemy:animate("idle", false)
				end
			end)
			spriteTimers[timerID] = 999999	
		else
			spriteTimers[timerID] = 12
		end
	end,

    update = function(self, dt)
            oldMusicThres = musicThres
			if countingDown or love.system.getOS() == "Web" then
				musicTime = musicTime + 1000 * dt
				self.musicTime = musicTime
			else
				if not graphics.isFading() then
					local time = love.timer.getTime()
					-- Usamos SOLO inst como fuente de verdad del tiempo.
					-- voices puede terminar antes/después que inst y su :tell()
					-- volvería a 0 al acabar, causando que musicTime salte hacia atrás.
					local seconds = inst and inst:tell("seconds") or 0

					musicTime = musicTime + (time * 1000) - previousFrameTime
					previousFrameTime = time * 1000

					if inst and inst:isPlaying() and lastReportedPlaytime ~= seconds * 1000 then
						lastReportedPlaytime = seconds * 1000
						musicTime = (musicTime + lastReportedPlaytime) / 2
					end
				end
				self.musicTime = musicTime
			end
            absMusicTime = math.abs(musicTime)
            musicThres = math.floor(absMusicTime / 100)

            for i = 1, #events do
                if events[i].eventTime <= absMusicTime then
                    local oldBpm = bpm

                    if events[i].bpm then
                        bpm = events[i].bpm
						self.bpm = bpm
                        if not bpm then bpm = oldBpm end
                    end

					if camTimer and not _G.disableAutoCam then
						Timer.cancel(camTimer)
					end
					if not _G.disableAutoCam then
						currentMustHit = events[i].mustHitSection or false
						if currentMustHit then
							camTimer = Timer.tween(1.25, cam, {x = -boyfriend.x + 100, y = -boyfriend.y + 75}, "out-quad")
						else
							camTimer = Timer.tween(1.25, cam, {x = -enemy.x - 100, y = -enemy.y + 75}, "out-quad")
						end
					end

                    if events[i].altAnim then
                        useAltAnims = true
                    else
                        useAltAnims = false
                    end

                    table.remove(events, i)
                    break
                end
            end

			for i = #cameraEvents, 1, -1 do
				local ev = cameraEvents[i]
				if musicTime >= ev.time then
					if ev.type == "SonicJumpscare" then
						jumpscare.trigger()
						table.remove(cameraEvents, i)
					elseif ev.type == "Spoopy Scare" then
						spoopyscare.trigger()
						table.remove(cameraEvents, i)
					elseif ev.type == "HighlightOn" then
						-- Activar highlight
						highlightActive = true
						highlightTarget = ev.target or "enemy"
						currentMustHit = events[1] and events[1].mustHitSection or false
						if guiAlphaTween then Timer.cancel(guiAlphaTween) end
						guiAlphaTween = Timer.tween(0.5, guiAlphaObj, {value = 0}, "linear", function() guiAlphaTween = nil end)
						if highlightCamTimer then Timer.cancel(highlightCamTimer) end
						local targetX, targetY
						if highlightTarget == "enemy" then
							targetX = -enemy.x - 100
							targetY = -enemy.y + 75
						else
							targetX = -boyfriend.x + 100
							targetY = -boyfriend.y + 75
						end
						highlightCamTimer = Timer.tween(1.25, cam, {x = targetX, y = targetY}, "out-quad", function() highlightCamTimer = nil end)
						table.remove(cameraEvents, i)
					elseif ev.type == "HighlightOff" then
						highlightActive = false
						highlightTarget = nil
						if guiAlphaTween then Timer.cancel(guiAlphaTween) end
						guiAlphaTween = Timer.tween(0.5, guiAlphaObj, {value = 1}, "linear", function() guiAlphaTween = nil end)
						if highlightCamTimer then Timer.cancel(highlightCamTimer); highlightCamTimer = nil end
						if camTimer then Timer.cancel(camTimer) end
						local currentSectionMustHit = false
						for j = 1, #events do
							if events[j].eventTime <= musicTime then
								currentSectionMustHit = events[j].mustHitSection or false
							end
						end
						if currentSectionMustHit then
							camTimer = Timer.tween(1.25, cam, {x = -boyfriend.x + 100, y = -boyfriend.y + 75}, "out-quad")
						else
							camTimer = Timer.tween(1.25, cam, {x = -enemy.x - 100, y = -enemy.y + 75}, "out-quad")
						end
						table.remove(cameraEvents, i)

						end
						-- No se eliminan eventos de tipo desconocido
					end
				end

			-- Beat pulse update (reemplaza el antiguo zoom rítmico por tweens)
			if bpm and bpm > 0 then
				local beatDuration = 60 / bpm -- en segundos
				local riseTime = beatDuration / 16
				local fallTime = beatDuration

				-- Detectar el beat (misma condición que antes)
				if musicThres ~= oldMusicThres and math.fmod(absMusicTime, 240000 / bpm) < 100 then
					beatPulseState = "rising"
					beatPulseTimer = 0
					beatRiseTime = riseTime
					beatFallTime = fallTime
				end

				-- Actualizar el factor de pulso según el estado
				if beatPulseState == "rising" then
					beatPulseTimer = beatPulseTimer + dt
					local t = beatPulseTimer / beatRiseTime
					if t >= 1 then
						beatPulse = 1.05
						beatPulseState = "falling"
						beatPulseTimer = 0
					else
						beatPulse = 1 + 0.05 * t   -- lineal de 1 a 1.05
					end
				elseif beatPulseState == "falling" then
					beatPulseTimer = beatPulseTimer + dt
					local t = beatPulseTimer / beatFallTime
					if t >= 1 then
						beatPulse = 1
						beatPulseState = "idle"
					else
						beatPulse = 1.05 - 0.05 * t  -- lineal de 1.05 a 1
					end
				else
					beatPulse = 1
				end
			else
				beatPulse = 1
			end

			-- Aplicar el pulso a la cámara (escala final = escala base * pulso)
			cam.sizeX = camScale.x * beatPulse
			cam.sizeY = camScale.y * beatPulse

			-- Mantener el tween de cámara activo cada frame para que siempre apunte
			-- al personaje correcto (necesario cuando los personajes cambian de posición,
			-- como en you-cant-run al cambiar de personaje).
			-- El cancel+recreate cada frame es intencional: garantiza seguimiento inmediato.
			if not _G.disableAutoCam and not highlightActive then
				if camTimer then Timer.cancel(camTimer) end
				if currentMustHit then
					camTimer = Timer.tween(1.25, cam, {x = -boyfriend.x + 100, y = -boyfriend.y + 75}, "out-quad")
				else
					camTimer = Timer.tween(1.25, cam, {x = -enemy.x - 100, y = -enemy.y + 75}, "out-quad")
				end
			end

            girlfriend:update(dt)
            enemy:update(dt)
            boyfriend:update(dt)
			spoopyscare.update(dt)

			-- Actualizar splashes activos; eliminar los que terminaron su animación
			for i = 1, 4 do
				local keep = {}
				for _, sp in ipairs(activeSplashes[i]) do
					sp:update(dt)
					if sp:isAnimated() then
						table.insert(keep, sp)
					end
				end
				activeSplashes[i] = keep
			end
			for i = 1, 4 do
				if holdSplashVisible[i] then
					holdSplashArrows[i]:update(dt)
					if not holdSplashArrows[i]:isAnimated() and holdSplashArrows[i]:getAnimName() == "end" then
						holdSplashVisible[i] = false
					end
				end
			end
			for i = 1, 4 do
				if enemyHoldSplashVisible[i] then
					enemyHoldSplashArrows[i]:update(dt)
					if not enemyHoldSplashArrows[i]:isAnimated() and enemyHoldSplashArrows[i]:getAnimName() == "end" then
						enemyHoldSplashVisible[i] = false
					end
				end
			end

			if musicThres ~= oldMusicThres and math.fmod(absMusicTime, 120000 / bpm) < 100 then
				if not customGirlfriendIdle then
					if spriteTimers[1] == 0 then
						-- No interrumpir "sad" si aún está animándose
						local gfAnim = girlfriend:getAnimName()
						if not (gfAnim == "sad" and girlfriend:isAnimated()) then
							girlfriend:animate("idle", false)
							girlfriend:setAnimSpeed(14.4 / (60 / bpm))
						end
					end
				end
				if spriteTimers[2] == 0 then
					self:safeAnimate(enemy, "idle", false, 2)
				end
				if spriteTimers[3] == 0 then
					self:safeAnimate(boyfriend, "idle", false, 3)
				end
			end

			for i = 1, 3 do
				local spriteTimer = spriteTimers[i]
				if spriteTimer and spriteTimer > 0 then
					spriteTimers[i] = spriteTimer - 1
				end
			end
    end,

	updateUI = function(self, dt)
		-- Detectar pulsación de F1 para alternar botplay (solo un cambio por frame)
		if not graphics.isFading() then
			if input:pressed("debug") then
				botplayActive = not botplayActive
				if not botplayActive then
					botHolding = {false, false, false, false}
				end
			end
		end

		if settings.downscroll then
			musicPos = -musicTime * 0.6 * speed
		else
			musicPos = musicTime * 0.6 * speed
		end

		for i = 1, 4 do
			local enemyArrow = enemyArrows[i]
			local boyfriendArrow = boyfriendArrows[i]
			local enemyNote = enemyNotes[i]
			local boyfriendNote = boyfriendNotes[i]
			local curAnim = animList[i]
			local curInput = inputList[i]
			local noteNum = i

			enemyArrow:update(dt)
			boyfriendArrow:update(dt)

			if not enemyArrow:isAnimated() then
				enemyArrow:animate("off", false)
			end

			-- Enemy notes (position‑based removal, still works)
			if #enemyNote > 0 then
				local shouldUseAlt = useAltAnims or (enemyNote[1].altNote == true) or (enemyNote[1].altNote == "picoShoot")
				if (not settings.downscroll and enemyNote[1].y - musicPos <= -375) or (settings.downscroll and enemyNote[1].y - musicPos >= 375) then
					if voices then voices:setVolume(1) end
					enemyArrow:animate("confirm", false)
					local animName = enemyNote[1]:getAnimName()
					if animName == "hold" then
						-- Nota hold intermedia: el splash ya debería estar en "loop", no tocar
						if shouldUseAlt then
							if (not enemy:isAnimated()) or enemy:getAnimName() == "idle" then self:safeAnimate(enemy, curAnim .. " alt", true, 2) end
						else
							if (not enemy:isAnimated()) or enemy:getAnimName() == "idle" then self:safeAnimate(enemy, curAnim, true, 2) end
						end
					elseif animName == "end" then
						-- Última nota del hold: terminar el splash
						if enemyHoldActive[i] then
							enemyHoldActive[i] = false
							enemyHoldSplashArrows[i]:animate("end", false)
						end
						if shouldUseAlt then
							if (not enemy:isAnimated()) or enemy:getAnimName() == "idle" then self:safeAnimate(enemy, curAnim .. " alt", true, 2) end
						else
							if (not enemy:isAnimated()) or enemy:getAnimName() == "idle" then self:safeAnimate(enemy, curAnim, true, 2) end
						end
					else
						-- Nota "on" (inicio): si tiene notas hold detrás, arrancar el splash
						-- Blazin fight: interceptar notas con noteKind
						if enemyNote[1].noteKind and _G.currentWeek and _G.currentWeek.onEnemyNoteHit then
							_G.currentWeek.onEnemyNoteHit(enemyNote[1].noteKind)
						elseif shouldUseAlt then
							self:safeAnimate(enemy, curAnim .. " alt", false, 2)
						else
							self:safeAnimate(enemy, curAnim, false, 2)
						end
						-- Revisar si la siguiente nota es un hold para iniciar el splash
						if #enemyNote > 1 then
							local nextAnim = enemyNote[2]:getAnimName()
							if (nextAnim == "hold" or nextAnim == "end") and not enemyHoldActive[i] then
								enemyHoldActive[i] = true
								enemyHoldSplashVisible[i] = true
								enemyHoldSplashArrows[i]:animate("start", false)
								Timer.after(1/24, function()
									if enemyHoldActive[i] then
										enemyHoldSplashArrows[i]:animate("loop", true)
									end
								end)
							end
						end
					end
					table.remove(enemyNote, 1)
				end
			end

			-- Si el botplay está activo, NO procesamos entrada del jugador
			if not botplayActive then
				-- Pulsación de tecla
				if input:pressed(curInput) then
					boyfriendArrow:animate("press", false)
					local hit = false

					if #boyfriendNote > 0 then
						for j = 1, #boyfriendNote do
							local note = boyfriendNote[j]
							if note and note:getAnimName() == "on" and not note.hit then
								local timeDiff = math.abs(note.strumTime - musicTime)
								if timeDiff <= HIT_WINDOW_SHIT then
									hit = true
									notMissed[noteNum] = true
									if voices then voices:setVolume(1) end
									boyfriendArrow:animate("confirm", false)

									local ratingType
									if timeDiff <= HIT_WINDOW_SICK then
										ratingType = "sick"
										if not note.isHoldStart then
											fireSplash(noteNum)
											if customSplashSound then
												customSplashSound:stop()
												customSplashSound:play()
											end
										end
									elseif timeDiff <= HIT_WINDOW_GOOD then
										ratingType = "good"
									elseif timeDiff <= HIT_WINDOW_BAD then
										ratingType = "bad"
									else
										ratingType = "shit"
									end

									if note.holdGroupId then
										-- Nota larga: solo guardamos el rating y marcamos el grupo
										local group = holdGroupsInfo[note.holdGroupId]
										if group and not group.missed and not group.completed then
											group.hitCount = 1
											group.started = true
											group.ratingType = ratingType
										end
									else
										-- Nota normal: sumamos puntos, vida, combo, etc.
										local ratingInfo = self.ratingsData[ratingType]
										score = score + ratingInfo.score
										self.totalNotesHit = self.totalNotesHit + ratingInfo.mod
										ratingInfo.hits = ratingInfo.hits + 1
										self.totalPlayed = self.totalPlayed + 1
										self:recalculateRating(false)

										if self.scoreTextTween then Timer.cancel(self.scoreTextTween) end
										self.scoreTextScale = 1.1
										self.scoreTextTween = Timer.tween(0.2, self, {scoreTextScale = 1}, "out-quad", function() self.scoreTextTween = nil end)

										combo = combo + 1
										if combo > self.maxCombo then self.maxCombo = combo end

										rating:animate(ratingType, false)
										numbers[1]:animate(tostring(math.floor(combo / 100 % 10)), false)
										numbers[2]:animate(tostring(math.floor(combo / 10 % 10)), false)
										numbers[3]:animate(tostring(math.floor(combo % 10)), false)

										for k = 1, 5 do
											if ratingTimers[k] then Timer.cancel(ratingTimers[k]) end
										end

										ratingVisibility[1] = 1
										rating.y = girlfriend.y - 50
										for k = 1, 3 do
											numbers[k].y = girlfriend.y + 50
										end

										ratingTimers[1] = Timer.tween(2, ratingVisibility, {0})
										ratingTimers[2] = Timer.tween(2, rating, {y = girlfriend.y - 100}, "out-elastic")
										ratingTimers[3] = Timer.tween(2, numbers[1], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")
										ratingTimers[4] = Timer.tween(2, numbers[2], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")
										ratingTimers[5] = Timer.tween(2, numbers[3], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")

										health = health + 1
									end

									local currentNote = note
									local noteAlt = currentNote.altNote
									local animToPlay = curAnim
									if noteAlt then
										if noteAlt == "random" then
											if love.math.random() < 0.5 then
												animToPlay = curAnim .. " alt"
											else
												animToPlay = curAnim .. " bf"
											end
										elseif noteAlt == true then
											animToPlay = curAnim .. " alt"
										end
									end

									local handled = false
									if _G.currentWeek and _G.currentWeek.customNoteHit then
										handled = _G.currentWeek:customNoteHit(curAnim, currentNote, boyfriend)
									end
									if not handled then
										self:safeAnimate(boyfriend, animToPlay, false, 3)
									end

									note.hit = true
									table.remove(boyfriendNote, j)

									if #boyfriendNote > 0 and (boyfriendNote[1]:getAnimName() == "hold" or boyfriendNote[1]:getAnimName() == "end") then
										holdActive[noteNum] = true
										holdActiveGroup[noteNum] = note.holdGroupId
										holdSplashVisible[noteNum] = true
										holdSplashArrows[noteNum]:animate("start", false)
										Timer.after(1/24, function()
											if holdActive[noteNum] then
												holdSplashArrows[noteNum]:animate("loop", true)
											end
										end)
									end

									break
								end
							end
						end
					end

					if not hit then
						if not settings.ghostTapping then
							audio.playSound(sounds.miss[love.math.random(3)])
							notMissed[noteNum] = false
							if combo >= 5 then self:safeAnimate(girlfriend, "sad", true, 1) end
							self:safeAnimate(boyfriend, "miss " .. curAnim, false, 3)
							score = score - 10
							combo = 0
							health = health - 2
							self.totalPlayed = self.totalPlayed + 1
							self:recalculateRating(true)
						end
					end
				end

				-- Mantener pulsado para holds (posición‑based)
				if notMissed[noteNum] and #boyfriendNote > 0 and input:down(curInput) and ((not settings.downscroll and boyfriendNote[1].y - musicPos <= -375) or (settings.downscroll and boyfriendNote[1].y - musicPos >= 375)) and (boyfriendNote[1]:getAnimName() == "hold" or boyfriendNote[1]:getAnimName() == "end") then
					if voices then voices:setVolume(1) end

					local removedNote = boyfriendNote[1]
					local animName = removedNote:getAnimName()
					removedNote.hit = true
					table.remove(boyfriendNote, 1)

					if animName == "end" then
						holdActive[noteNum] = false
						holdActiveGroup[noteNum] = nil
						holdSplashArrows[noteNum]:animate("end", false)
					elseif animName == "hold" then
						-- El splash sigue en "loop"
					end

					boyfriendArrow:animate("confirm", false)

					local handledHold = false
					if _G.currentWeek and _G.currentWeek.customNoteHold then
						handledHold = _G.currentWeek:customNoteHold(curAnim, removedNote, boyfriend)
					end
					if not handledHold then
						if (not boyfriend:isAnimated()) or boyfriend:getAnimName() == "idle" then
							self:safeAnimate(boyfriend, curAnim, true, 3)
						end
					end

					-- Lógica de grupo para holds
					if removedNote.holdGroupId then
						local group = holdGroupsInfo[removedNote.holdGroupId]
						if group and not group.missed and not group.completed then
							group.hitCount = group.hitCount + 1
							if group.hitCount == group.totalNotes then
								-- Nota larga completada manteniendo presionado → siempre sick
								group.completed = true
								holdActiveGroup[noteNum] = nil  -- ya resuelto, limpiar
								local ratingType = "sick"
								local ratingInfo = self.ratingsData[ratingType]
								score = score + ratingInfo.score
								self.totalNotesHit = self.totalNotesHit + ratingInfo.mod
								ratingInfo.hits = ratingInfo.hits + 1
								self.totalPlayed = self.totalPlayed + 1
								self:recalculateRating(false)

								if self.scoreTextTween then Timer.cancel(self.scoreTextTween) end
								self.scoreTextScale = 1.1
								self.scoreTextTween = Timer.tween(0.2, self, {scoreTextScale = 1}, "out-quad", function() self.scoreTextTween = nil end)

								combo = combo + 1
										if combo > self.maxCombo then self.maxCombo = combo end
								rating:animate(ratingType, false)
								numbers[1]:animate(tostring(math.floor(combo / 100 % 10)), false)
								numbers[2]:animate(tostring(math.floor(combo / 10 % 10)), false)
								numbers[3]:animate(tostring(math.floor(combo % 10)), false)

								for k = 1, 5 do
									if ratingTimers[k] then Timer.cancel(ratingTimers[k]) end
								end
								ratingVisibility[1] = 1
								rating.y = girlfriend.y - 50
								for k = 1, 3 do
									numbers[k].y = girlfriend.y + 50
								end
								ratingTimers[1] = Timer.tween(2, ratingVisibility, {0})
								ratingTimers[2] = Timer.tween(2, rating, {y = girlfriend.y - 100}, "out-elastic")
								ratingTimers[3] = Timer.tween(2, numbers[1], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")
								ratingTimers[4] = Timer.tween(2, numbers[2], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")
								ratingTimers[5] = Timer.tween(2, numbers[3], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")

								health = health + 1
							end
						end
					else
						-- Nota de hold sin grupo (no debería ocurrir, pero por seguridad)
						health = health + 1
					end
				end

				-- Al soltar la tecla
				if input:released(curInput) then
					boyfriendArrow:animate("off", false)
					if holdActive[noteNum] then
						holdActive[noteNum] = false
						holdSplashArrows[noteNum]:animate("end", false)

						-- Buscar la nota "end" del grupo activo para calcular precisión del release
						local groupId = holdActiveGroup[noteNum]
						holdActiveGroup[noteNum] = nil
						if groupId then
							local group = holdGroupsInfo[groupId]
							if group and not group.missed and not group.completed then
								-- Buscar strumTime de la nota "end" del grupo
								local endStrumTime = nil
								for _, n in ipairs(boyfriendNote) do
									if n.holdGroupId == groupId and n:getAnimName() == "end" then
										endStrumTime = n.strumTime
										break
									end
								end
								-- Si no hay nota "end" pendiente, significa que ya pasaron todas → sick
								local earlyMs = endStrumTime and (endStrumTime - musicTime) or 0
								if earlyMs < 0 then earlyMs = 0 end

								local ratingType
								if earlyMs <= HIT_WINDOW_SICK then
									ratingType = "sick"
								elseif earlyMs <= HIT_WINDOW_GOOD then
									ratingType = "good"
								elseif earlyMs <= HIT_WINDOW_BAD then
									ratingType = "bad"
								else
									ratingType = "shit"
								end

								group.completed = true
								-- Marcar todas las notas restantes del grupo como hit para que no generen miss
								for _, n in ipairs(boyfriendNote) do
									if n.holdGroupId == groupId then
										n.hit = true
									end
								end

								local ratingInfo = self.ratingsData[ratingType]
								score = score + ratingInfo.score
								self.totalNotesHit = self.totalNotesHit + ratingInfo.mod
								ratingInfo.hits = ratingInfo.hits + 1
								self.totalPlayed = self.totalPlayed + 1
								self:recalculateRating(false)

								if self.scoreTextTween then Timer.cancel(self.scoreTextTween) end
								self.scoreTextScale = 1.1
								self.scoreTextTween = Timer.tween(0.2, self, {scoreTextScale = 1}, "out-quad", function() self.scoreTextTween = nil end)

								combo = combo + 1
										if combo > self.maxCombo then self.maxCombo = combo end
								rating:animate(ratingType, false)
								numbers[1]:animate(tostring(math.floor(combo / 100 % 10)), false)
								numbers[2]:animate(tostring(math.floor(combo / 10 % 10)), false)
								numbers[3]:animate(tostring(math.floor(combo % 10)), false)

								for k = 1, 5 do
									if ratingTimers[k] then Timer.cancel(ratingTimers[k]) end
								end
								ratingVisibility[1] = 1
								rating.y = girlfriend.y - 50
								for k = 1, 3 do
									numbers[k].y = girlfriend.y + 50
								end
								ratingTimers[1] = Timer.tween(2, ratingVisibility, {0})
								ratingTimers[2] = Timer.tween(2, rating, {y = girlfriend.y - 100}, "out-elastic")
								ratingTimers[3] = Timer.tween(2, numbers[1], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")
								ratingTimers[4] = Timer.tween(2, numbers[2], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")
								ratingTimers[5] = Timer.tween(2, numbers[3], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")

								health = health + 1
							end
						end
					end
				end
			end
		end

		-- ** Procesamiento del bot (si está activo) **
		if botplayActive then
			for i = 1, 4 do
				local boyfriendNote = boyfriendNotes[i]
				local curAnim = animList[i]
				local noteNum = i
				local j = 1
				while j <= #boyfriendNote do
					local note = boyfriendNote[j]
					if not note.hit then
						local timeDiff = note.strumTime - musicTime
						-- Ventana de acierto (usamos SICK para ser perfectos)
						if timeDiff <= HIT_WINDOW_SICK and timeDiff >= -HIT_WINDOW_SICK then
							-- Cancelar cualquier timer pendiente para esta flecha
							if botKeyTimers[i] then
								Timer.cancel(botKeyTimers[i])
								botKeyTimers[i] = nil
							end

							-- Golpear la nota
							note.hit = true
							boyfriendArrows[i]:animate("confirm", false)

							-- Determinar animación del novio
							local noteAlt = note.altNote
							local animToPlay = curAnim
							if noteAlt then
								if noteAlt == "random" then
									if love.math.random() < 0.5 then
										animToPlay = curAnim .. " alt"
									else
										animToPlay = curAnim .. " bf"
									end
								elseif noteAlt == true then
									animToPlay = curAnim .. " alt"
								end
							end

							local handled = false
							if _G.currentWeek and _G.currentWeek.customNoteHit then
								handled = _G.currentWeek:customNoteHit(curAnim, note, boyfriend)
							end
							if not handled then
								self:safeAnimate(boyfriend, animToPlay, false, 3)
							end

							-- Manejo de grupos de hold
							if note.holdGroupId then
								local group = holdGroupsInfo[note.holdGroupId]
								if group and not group.missed and not group.completed then
									if note.isHoldStart then
										-- Primera nota del hold
										group.hitCount = 1
										group.started = true
										group.ratingType = "sick"
										-- Iniciar salpicadura de hold
										holdSplashVisible[i] = true
										holdSplashArrows[i]:animate("start", false)
										Timer.after(1/24, function()
											if holdSplashVisible[i] then
												holdSplashArrows[i]:animate("loop", true)
											end
										end)
										botHolding[i] = true
										-- La flecha se queda en "confirm" durante todo el hold
									else
										-- Nota de hold intermedia o final
										group.hitCount = group.hitCount + 1
										if group.hitCount == group.totalNotes then
											-- Hold completado
											group.completed = true
											local ratingInfo = self.ratingsData["sick"]
											score = score + ratingInfo.score
											self.totalNotesHit = self.totalNotesHit + ratingInfo.mod
											ratingInfo.hits = ratingInfo.hits + 1
											self.totalPlayed = self.totalPlayed + 1
											self:recalculateRating(false)

											combo = combo + 1
										if combo > self.maxCombo then self.maxCombo = combo end
											rating:animate("sick", false)
											numbers[1]:animate(tostring(math.floor(combo / 100 % 10)), false)
											numbers[2]:animate(tostring(math.floor(combo / 10 % 10)), false)
											numbers[3]:animate(tostring(math.floor(combo % 10)), false)

											for k = 1, 5 do
												if ratingTimers[k] then Timer.cancel(ratingTimers[k]) end
											end
											ratingVisibility[1] = 1
											rating.y = girlfriend.y - 50
											for k = 1, 3 do
												numbers[k].y = girlfriend.y + 50
											end
											ratingTimers[1] = Timer.tween(2, ratingVisibility, {0})
											ratingTimers[2] = Timer.tween(2, rating, {y = girlfriend.y - 100}, "out-elastic")
											ratingTimers[3] = Timer.tween(2, numbers[1], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")
											ratingTimers[4] = Timer.tween(2, numbers[2], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")
											ratingTimers[5] = Timer.tween(2, numbers[3], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")

											health = health + 1
											botHolding[i] = false
											holdSplashArrows[i]:animate("end", false)
											-- Al terminar el hold, la flecha vuelve a "off"
											boyfriendArrows[i]:animate("off", false)
										end
									end
								end
							else
								-- Nota normal
								local ratingInfo = self.ratingsData["sick"]
								score = score + ratingInfo.score
								self.totalNotesHit = self.totalNotesHit + ratingInfo.mod
								ratingInfo.hits = ratingInfo.hits + 1
								self.totalPlayed = self.totalPlayed + 1
								self:recalculateRating(false)

								if self.scoreTextTween then Timer.cancel(self.scoreTextTween) end
								self.scoreTextScale = 1.1
								self.scoreTextTween = Timer.tween(0.2, self, {scoreTextScale = 1}, "out-quad", function() self.scoreTextTween = nil end)

								combo = combo + 1
										if combo > self.maxCombo then self.maxCombo = combo end

								rating:animate("sick", false)
								numbers[1]:animate(tostring(math.floor(combo / 100 % 10)), false)
								numbers[2]:animate(tostring(math.floor(combo / 10 % 10)), false)
								numbers[3]:animate(tostring(math.floor(combo % 10)), false)

								for k = 1, 5 do
									if ratingTimers[k] then Timer.cancel(ratingTimers[k]) end
								end

								ratingVisibility[1] = 1
								rating.y = girlfriend.y - 50
								for k = 1, 3 do
									numbers[k].y = girlfriend.y + 50
								end

								ratingTimers[1] = Timer.tween(2, ratingVisibility, {0})
								ratingTimers[2] = Timer.tween(2, rating, {y = girlfriend.y - 100}, "out-elastic")
								ratingTimers[3] = Timer.tween(2, numbers[1], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")
								ratingTimers[4] = Timer.tween(2, numbers[2], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")
								ratingTimers[5] = Timer.tween(2, numbers[3], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")

								health = health + 1

								-- Salpicadura: instancia nueva e independiente siempre
								fireSplash(i)
								if customSplashSound then
									customSplashSound:stop()
									customSplashSound:play()
								end

								-- Programar retorno a "off" después de un breve lapso (simula soltar la tecla)
								botKeyTimers[i] = Timer.after(0.2, function()
									if not botHolding[i] then  -- Solo si no estamos en un hold
										boyfriendArrows[i]:animate("off", false)
									end
									botKeyTimers[i] = nil
								end)
							end

							-- Eliminar la nota
							table.remove(boyfriendNote, j)
							-- No incrementamos j porque el siguiente elemento ahora está en esta posición
						else
							j = j + 1
						end
					else
						j = j + 1
					end
				end
			end
		end

		-- ** Detección de fallos basada en tiempo (solo si no es botplay, o igual la dejamos para limpieza) **
		-- En botplay no debería haber fallos, pero por si acaso la dejamos para que elimine notas muy viejas
		for i = 1, 4 do
			local boyfriendNote = boyfriendNotes[i]
			local j = 1
			while j <= #boyfriendNote do
				local note = boyfriendNote[j]
				if note and not note.hit then
					local timeDiff = musicTime - note.strumTime
					local animName = note:getAnimName()

					-- FIX FPS BAJO: si el jugador ya golpeó la nota inicial del hold
					-- (group.started == true) y esta nota hold/end ya pasó el strum,
					-- la consumimos automáticamente sin penalizar. Esto evita que en
					-- frames lentos (Switch, PC lento) el hold quede flotando porque el
					-- check de input:down() no alcanzó a ejecutarse en el frame correcto.
					if (animName == "hold" or animName == "end") and note.holdGroupId then
						local group = holdGroupsInfo[note.holdGroupId]
						if group and group.started and not group.missed and not group.completed then
							local pastStrum = (not settings.downscroll and note.y - musicPos <= -375)
								or (settings.downscroll and note.y - musicPos >= 375)
							if pastStrum then
								note.hit = true
								group.hitCount = group.hitCount + 1
								if group.hitCount == group.totalNotes then
									group.completed = true
									holdActive[i] = false
									holdActiveGroup[i] = nil
									holdSplashArrows[i]:animate("end", false)
									local ratingInfo = self.ratingsData["sick"]
									score = score + ratingInfo.score
									self.totalNotesHit = self.totalNotesHit + ratingInfo.mod
									ratingInfo.hits = ratingInfo.hits + 1
									self.totalPlayed = self.totalPlayed + 1
									self:recalculateRating(false)
									combo = combo + 1
									if combo > self.maxCombo then self.maxCombo = combo end
									health = health + 1
								end
								table.remove(boyfriendNote, j)
								goto continueKillLoop
							end
						end
					end

					if timeDiff > NOTE_KILL_OFFSET then
						if note.holdGroupId then
							-- Nota de grupo
							local group = holdGroupsInfo[note.holdGroupId]
							if group and not group.missed and not group.completed then
								-- Primer fallo del grupo
								group.missed = true
								if inst and voices then voices:setVolume(0) end
								misses = misses + 1
								self.totalPlayed = self.totalPlayed + 1
								self:recalculateRating(true)
								audio.playSound(sounds.miss[love.math.random(3)])
								combo = 0
								health = health - 2
								if combo >= 5 then self:safeAnimate(girlfriend, "sad", true, 1) end
								if holdActive[i] then
									holdActive[i] = false
									holdSplashArrows[i]:animate("end", false)
								end
								if animName == "on" then
									-- Animación de miss si es la primera nota
									local handled = false
									if _G.currentWeek and _G.currentWeek.customNoteMiss then
										handled = _G.currentWeek:customNoteMiss(animList[i], note, boyfriend)
									end
									if not handled then
										self:safeAnimate(boyfriend, "miss " .. animList[i], false, 3)
									end
								end
							end
							-- Eliminar esta nota (ya sea porque el grupo ya falló o es la primera)
							table.remove(boyfriendNote, j)
						else
							-- Nota normal (sin grupo)
							if animName == "on" then
								if inst and voices then voices:setVolume(0) end
								notMissed[i] = false
								misses = misses + 1
								self.totalPlayed = self.totalPlayed + 1
								self:recalculateRating(true)
								audio.playSound(sounds.miss[love.math.random(3)])

								local handled = false
								if _G.currentWeek and _G.currentWeek.customNoteMiss then
									handled = _G.currentWeek:customNoteMiss(animList[i], note, boyfriend)
								end
								if not handled then
									self:safeAnimate(boyfriend, "miss " .. animList[i], false, 3)
								end

								if combo >= 5 then self:safeAnimate(girlfriend, "sad", true, 1) end
								combo = 0
								health = health - 2
							else
								-- Nota de hold sin grupo (no debería ocurrir)
								misses = misses + 1
								self.totalPlayed = self.totalPlayed + 1
								self:recalculateRating(true)
								if holdActive[i] then
									holdActive[i] = false
									holdSplashArrows[i]:animate("end", false)
								end
							end
							table.remove(boyfriendNote, j)
						end
					else
						j = j + 1
					end
				else
					j = j + 1
				end
				::continueKillLoop::
			end
		end

		if health > 100 then
			health = 100
		end

		if health <= 0 then
			-- Si existe un manejador custom de muerte lo ejecutamos (ej. sanic.lua lo registra en enter)
			if _G.customOnPlayerDeath then
				_G.customOnPlayerDeath()
				return
			end

			-- Si hay un bloqueo global, lo respetamos (fallback)
			if _G.blockGameOver then
				return
			end

			if _G.deathBoyfriend then
				fakeBoyfriend = _G.deathBoyfriend   -- usa el sprite de muerte específico si existe
			else
				fakeBoyfriend = boyfriend            -- fallback al boyfriend actual
			end
			Gamestate.push(gameOver)
			return
		end

		local currentBfAnim = boyfriendIcon:getAnimName()
		local isBfLosing = currentBfAnim:match(" losing$")
		if health > 20 then
			if isBfLosing then
				local baseAnim = currentBfAnim:gsub(" losing$", "")
				boyfriendIcon:animate(baseAnim, false)
			end
		elseif health <= 20 then
			if not isBfLosing then
				boyfriendIcon:animate(currentBfAnim .. " losing", false)
			end
		end

		-- Manejo del ícono del oponente (cambia a "losing" cuando la salud del enemigo es alta)
        local currentEnemyAnim = enemyIcon:getAnimName()
        local isEnemyLosing = currentEnemyAnim:match(" losing$")
        local baseEnemyAnim = isEnemyLosing and currentEnemyAnim:gsub(" losing$", "") or currentEnemyAnim

        if health >= 80 then
            -- Si no está ya en modo losing y existe la animación "losing", cambiar
            if not isEnemyLosing and enemyIcon.anims[baseEnemyAnim .. " losing"] then
                enemyIcon:animate(baseEnemyAnim .. " losing", false)
            end
        else
            -- Si está en modo losing, volver al normal
            if isEnemyLosing then
                enemyIcon:animate(baseEnemyAnim, false)
            end
        end

		enemyIcon.x = 425 - health * 10
		boyfriendIcon.x = 585 - health * 10

		local enemyAnim = enemyIcon:getAnimName()
		if enemyAnim ~= lastEnemyAnim then
			lastEnemyAnim = enemyAnim
			local baseAnim = enemyAnim:gsub(" losing$", "")
			local factor = icons.getScaleFactor(baseAnim)
			local newBaseX = 1.5 * factor
			local newBaseY = 1.5 * factor
			enemyIcon.baseSizeX = newBaseX
			enemyIcon.baseSizeY = newBaseY
			enemyIcon.sizeX = newBaseX
			enemyIcon.sizeY = newBaseY
			-- Cancelar cualquier tween activo para evitar interferencias
			if enemyIconTimer then
				Timer.cancel(enemyIconTimer)
				enemyIconTimer = nil
			end
		end

		-- Lo mismo para el ícono del novio
		local bfAnim = boyfriendIcon:getAnimName()
		if bfAnim ~= lastBfAnim then
			lastBfAnim = bfAnim
			local baseAnim = bfAnim:gsub(" losing$", "")
			local factor = icons.getScaleFactor(baseAnim)
			local newBaseX = -1.5 * factor  -- negativo para que mire a la izquierda
			local newBaseY = 1.5 * factor
			boyfriendIcon.baseSizeX = newBaseX
			boyfriendIcon.baseSizeY = newBaseY
			boyfriendIcon.sizeX = newBaseX
			boyfriendIcon.sizeY = newBaseY
			if boyfriendIconTimer then
				Timer.cancel(boyfriendIconTimer)
				boyfriendIconTimer = nil
			end
		end

        if musicThres ~= oldMusicThres and math.fmod(absMusicTime, 60000 / bpm) < 100 then
            if enemyIconTimer then Timer.cancel(enemyIconTimer) end
            if boyfriendIconTimer then Timer.cancel(boyfriendIconTimer) end

            local enemyBaseX = enemyIcon.baseSizeX or 1.5
            local enemyBaseY = enemyIcon.baseSizeY or 1.5
            local boyfriendBaseX = boyfriendIcon.baseSizeX or -1.5
            local boyfriendBaseY = boyfriendIcon.baseSizeY or 1.5

            enemyIconTimer = Timer.tween((60 / bpm) / 16, enemyIcon,
                {sizeX = enemyBaseX * 1.16, sizeY = enemyBaseY * 1.16}, "out-quad", function()
                enemyIconTimer = Timer.tween((60 / bpm), enemyIcon,
                    {sizeX = enemyBaseX, sizeY = enemyBaseY}, "out-quad")
            end)

            boyfriendIconTimer = Timer.tween((60 / bpm) / 16, boyfriendIcon,
                {sizeX = boyfriendBaseX * 1.16, sizeY = boyfriendBaseY * 1.16}, "out-quad", function()
                boyfriendIconTimer = Timer.tween((60 / bpm), boyfriendIcon,
                    {sizeX = boyfriendBaseX, sizeY = boyfriendBaseY}, "out-quad")
            end)
        end

		-- Activa el subestado de pausa si presionas Enter/Esc
		if not countingDown and (input:pressed("pause")) then
			Gamestate.push(pauseMenu)
		end

		if not countingDown and not self.songEnded then
			local anyNotes = false
			for i = 1, 4 do
				if #enemyNotes[i] > 0 or #boyfriendNotes[i] > 0 then
					anyNotes = true
					break
				end
			end
			if not anyNotes and not (inst and inst:isPlaying()) then
				-- Condición de fin: no quedan notas Y la instrumental ya terminó.
				-- No usamos voices:isPlaying() porque voices puede terminar antes
				-- o después que inst, causando que el juego no termine o se atasque.
				-- Si no hay inst (canción sin instrumental), caemos al check de songLength.
				local instDone = (inst == nil) or (not inst:isPlaying())
				local timeDone = (self.songLength and self.songLength > 0)
					and (musicTime >= self.songLength - 200)
				if instDone or timeDone then
					print("FIN DE CANCIÓN DETECTADO")
					self.songEnded = true
					-- Guardar scores
					if _G.storyMode then
						_G.weekTotalScore = (_G.weekTotalScore or 0) + score
						if _G.currentSongIndex == #_G.weekSongs then
							local old = highscores.getStoryScore(_G.currentWeekId, _G.currentDifficulty)
							if _G.weekTotalScore > old then
								highscores.setStoryScore(_G.currentWeekId, _G.currentDifficulty, _G.weekTotalScore)
							end
						end
					else
						local sName = _G.currentSongName or "unknown"
						local songKey = _G.currentWeekId .. "_" .. sName
						local old = highscores.getFreeplayScore(songKey, _G.currentDifficulty)
						if score > old then
							highscores.setFreeplayScore(songKey, _G.currentDifficulty, score)
						end
					end
					-- Iniciar transición
					self:handleSongEnd()
				end
			end
		end

		-- Actualizar barra de tiempo
		if self.songLength and self.songLength > 0 then
			self.songPercent = musicTime / self.songLength
			if self.songPercent > 1 then self.songPercent = 1 end
			if self.songPercent < 0 then self.songPercent = 0 end
		else
			self.songPercent = 0
		end

		local currentSeconds = math.max(0, math.floor(musicTime / 1000))
		local totalSeconds = math.floor(self.songLength / 1000)
		
		if settings.timebarMode == "remaining" then
			local remainingSeconds = totalSeconds - currentSeconds
			if remainingSeconds < 0 then remainingSeconds = 0 end
			local remainingMinutes = math.floor(remainingSeconds / 60)
			local remainingSecs = remainingSeconds % 60
			self.timeText = string.format("%d:%02d", remainingMinutes, remainingSecs)
		elseif settings.timebarMode == "songname" then
			self.timeText = self.songName or "unknown"
		elseif settings.timebarMode == "none" then
			self.timeText = ""
		else
			local currentMinutes = math.floor(currentSeconds / 60)
			local currentSecs = currentSeconds % 60
			local totalMinutes = math.floor(totalSeconds / 60)
			local totalSecs = totalSeconds % 60
			self.timeText = string.format("%d:%02d / %d:%02d", currentMinutes, currentSecs, totalMinutes, totalSecs)
		end

		-- OPT FIX 4: Reconstruir infoText solo cuando algún valor cambia
		if score ~= lastCachedScore or misses ~= lastCachedMisses
		   or self.ratingName ~= lastCachedRatingName
		   or self.ratingPercent ~= lastCachedRatingPercent
		   or self.ratingFC ~= lastCachedRatingFC then
			lastCachedScore         = score
			lastCachedMisses        = misses
			lastCachedRatingName    = self.ratingName
			lastCachedRatingPercent = self.ratingPercent
			lastCachedRatingFC      = self.ratingFC
			local percentStr = self.totalPlayed > 0
				and string.format(" (%.2f%%)", self.ratingPercent * 100) or ""
			local fcStr = self.ratingFC ~= "" and " - " .. self.ratingFC or ""
			cachedInfoText = string.format("Score: %d | Misses: %d | Rating: %s%s%s",
				score, misses, self.ratingName, percentStr, fcStr)
			-- OPT FIX 5+10: cachear también el ancho del texto y altura del font
			local font = love.graphics.getFont()
			cachedInfoTextWidth  = font:getWidth(cachedInfoText)
			self.cachedFontHeight = font:getHeight()
		end
	end,

	drawRating = function(self, multiplier)
		love.graphics.push()
			if multiplier then
				love.graphics.translate(cam.x * multiplier, cam.y * multiplier)
			else
				love.graphics.translate(cam.x, cam.y)
			end
			graphics.setColor(1, 1, 1, ratingVisibility[1])
			rating:draw()
			for i = 1, 3 do
				numbers[i]:draw()
			end
			graphics.setColor(1, 1, 1)
		love.graphics.pop()
	end,

drawUI = function(self)
        love.graphics.push()
            love.graphics.translate(lovesize.getWidth() / 2, lovesize.getHeight() / 2)
            love.graphics.scale(0.7, 0.7)

            for i = 1, 4 do
                -- Flechas estáticas con transparencia
                if not middleScroll then
                    graphics.setColor(1, 1, 1, (enemyArrows[i].alpha or 1) * guiAlphaObj.value)
                    enemyArrows[i]:draw()
                end
                graphics.setColor(1, 1, 1, (boyfriendArrows[i].alpha or 1) * guiAlphaObj.value)
                boyfriendArrows[i]:draw()
                graphics.setColor(1, 1, 1)

                love.graphics.push()
                    love.graphics.translate(0, -musicPos)
                    if not middleScroll then
                    for j = #enemyNotes[i], 1, -1 do
                        if (not settings.downscroll and enemyNotes[i][j].y - musicPos <= 560) or (settings.downscroll and enemyNotes[i][j].y - musicPos >= -560) then
                            local animName = enemyNotes[i][j]:getAnimName()
                            local alpha
                            if settings.downscroll then
                                if animName == "hold" or animName == "end" then
                                    alpha = math.min(0.85, (500 - (enemyNotes[i][j].y - musicPos)) / 150)
                                else
                                    alpha = math.min(1, (500 - (enemyNotes[i][j].y - musicPos)) / 75)
                                end
                            else
                                if animName == "hold" or animName == "end" then
                                    alpha = math.min(0.85, (500 + (enemyNotes[i][j].y - musicPos)) / 150)
                                else
                                    alpha = math.min(1, (500 + (enemyNotes[i][j].y - musicPos)) / 75)
                                end
                            end
                            graphics.setColor(1, 1, 1, alpha * guiAlphaObj.value)
                            enemyNotes[i][j]:draw()
                            graphics.setColor(1, 1, 1)
                        end
                    end
                    end -- middleScroll
                    for j = #boyfriendNotes[i], 1, -1 do
                        if (not settings.downscroll and boyfriendNotes[i][j].y - musicPos <= 560) or (settings.downscroll and boyfriendNotes[i][j].y - musicPos >= -560) then
                            local animName = boyfriendNotes[i][j]:getAnimName()
                            local alpha
                            if settings.downscroll then
                                if animName == "hold" or animName == "end" then
                                    alpha = math.min(0.85, (500 - (boyfriendNotes[i][j].y - musicPos)) / 150)
                                else
                                    alpha = math.min(1, (500 - (boyfriendNotes[i][j].y - musicPos)) / 75)
                                end
                            else
                                if animName == "hold" or animName == "end" then
                                    alpha = math.min(0.85, (500 + (boyfriendNotes[i][j].y - musicPos)) / 150)
                                else
                                    alpha = math.min(1, (500 + (boyfriendNotes[i][j].y - musicPos)) / 75)
                                end
                            end
                            graphics.setColor(1, 1, 1, alpha * guiAlphaObj.value)
                            boyfriendNotes[i][j]:draw()
                        end
                    end
                    graphics.setColor(1, 1, 1)
                love.graphics.pop()
            end

            -- Dibujar todas las instancias de splash activas (cada una independiente)
            for i = 1, 4 do
                for _, sp in ipairs(activeSplashes[i]) do
                    graphics.setColor(1, 1, 1, guiAlphaObj.value)
                    sp:draw()
                end
            end

			for i = 1, 4 do
                if holdSplashVisible[i] then
                    graphics.setColor(1, 1, 1, guiAlphaObj.value)
                    holdSplashArrows[i]:draw()
                end
            end

            for i = 1, 4 do
                if enemyHoldSplashVisible[i] and not middleScroll then
                    graphics.setColor(1, 1, 1, guiAlphaObj.value)
                    enemyHoldSplashArrows[i]:draw()
                end
            end

            local enemyIconName = enemyIcon:getAnimName():gsub(" losing$", "")
            local enemyCol = characterColors[enemyIconName] or {255,0,0}
            local playerIconName = boyfriendIcon:getAnimName():gsub(" losing$", "")
            local playerCol = characterColors[playerIconName] or characterColors["boyfriend"] or {0,255,0}
            
            -- Barra de salud con transparencia
            if settings.downscroll then
                local y = -400
                graphics.setColor(enemyCol[1]/255, enemyCol[2]/255, enemyCol[3]/255, guiAlphaObj.value)
                love.graphics.rectangle("fill", -500, y, 1000, 25)
                graphics.setColor(playerCol[1]/255, playerCol[2]/255, playerCol[3]/255, guiAlphaObj.value)
                love.graphics.rectangle("fill", 500, y, -health * 10, 25)
                graphics.setColor(0, 0, 0, guiAlphaObj.value)
                love.graphics.setLineWidth(10)
                love.graphics.rectangle("line", -500, y, 1000, 25)
                love.graphics.setLineWidth(1)
            else
                local y = 400
                graphics.setColor(enemyCol[1]/255, enemyCol[2]/255, enemyCol[3]/255, guiAlphaObj.value)
                love.graphics.rectangle("fill", -500, y, 1000, 25)
                graphics.setColor(playerCol[1]/255, playerCol[2]/255, playerCol[3]/255, guiAlphaObj.value)
                love.graphics.rectangle("fill", 500, y, -health * 10, 25)
                graphics.setColor(0, 0, 0, guiAlphaObj.value)
                love.graphics.setLineWidth(10)
                love.graphics.rectangle("line", -500, y, 1000, 25)
                love.graphics.setLineWidth(1)
            end

            -- Barra de tiempo con transparencia
            if settings.timebarMode ~= "none" then
                local timeBarHeight = 25
                local timeBarWidth = 500
                local timeBarX = -timeBarWidth / 2
                local timeBarY = settings.downscroll and 470 or -500
                local margin = 4

                graphics.setColor(0, 0, 0, guiAlphaObj.value)
                love.graphics.rectangle("fill", timeBarX, timeBarY, timeBarWidth, timeBarHeight)

                graphics.setColor(1, 1, 1, guiAlphaObj.value)
                local fillWidth = self.songPercent * (timeBarWidth - 2 * margin)
                love.graphics.rectangle("fill", timeBarX + margin, timeBarY + margin, fillWidth, timeBarHeight - 2 * margin)

                -- OPT FIX 2: setFilter eliminado de aquí (se aplica al crear la imagen)
                graphics.setColor(1, 1, 1, guiAlphaObj.value)
                love.graphics.draw(images.timeBar, timeBarX, timeBarY, 0, timeBarWidth / images.timeBar:getWidth(), timeBarHeight / images.timeBar:getHeight())

                -- OPT FIX 3+5: outline con 4 diagonales; font cacheada en updateUI
                local font = love.graphics.getFont()
                local text = self.timeText or ""
                local textScale = 1.5
                local textWidth = font:getWidth(text) * textScale
                local textHeight = (self.cachedFontHeight or font:getHeight()) * textScale
                local textX = -textWidth / 2
                local timeTextY = timeBarY + (timeBarHeight / 2) - (textHeight / 2)
                drawTextWithOutline(font, text, textX, timeTextY, textScale, textScale, guiAlphaObj.value)
            end

            -- Texto BOTPLAY (si está activo)
            if botplayActive then
                local font = love.graphics.getFont()
                local text = "BOTPLAY"
                local scale = 2
                local textWidth = font:getWidth(text) * scale
                local textHeight = (self.cachedFontHeight or font:getHeight()) * scale
                local x = -textWidth / 2
                local y = settings.downscroll and -500 or 300
                -- OPT FIX 3: outline con 4 diagonales
                drawTextWithOutline(font, text, x, y, scale, scale, guiAlphaObj.value)
            end

            -- Iconos con transparencia (boyfriendIcon primero, enemyIcon encima)
            enemyIcon.alpha = guiAlphaObj.value
            boyfriendIcon.alpha = guiAlphaObj.value
            boyfriendIcon:draw()
            enemyIcon:draw()

            -- OPT FIX 3+4+5: infoText cacheado; outline con 4 diagonales; sin getFont/format cada frame
            local infoText  = cachedInfoText
            local textWidth = cachedInfoTextWidth
            local textHeight = self.cachedFontHeight or love.graphics.getFont():getHeight()
            local textScale = 1.4
            local textY = settings.downscroll and -325 or 475

            love.graphics.push()
                love.graphics.translate(0, textY)
                love.graphics.scale(textScale * self.scoreTextScale, textScale * self.scoreTextScale)
                drawTextWithOutline(love.graphics.getFont(), infoText,
                    -textWidth/2, -textHeight/2, 1, 1, guiAlphaObj.value)
            love.graphics.pop()

            if countingDown then
                graphics.setColor(1, 1, 1, countdownFade[1] * guiAlphaObj.value)
                countdown:draw()
                graphics.setColor(1, 1, 1)
            end
        love.graphics.pop()

        -- Dibujar jumpscare en coordenadas de pantalla (sin transformaciones)
        love.graphics.push()
        jumpscare.draw()
        spoopyscare.draw()
        love.graphics.pop()
    end,

	-- ============================================================
	-- buildScoreData(): Construye la tabla que results.lua espera
	-- ============================================================
	buildScoreData = function(self)
		-- Normalizar la dificultad: "-hard" → "hard", "" → "normal", "-easy" → "easy"
		local rawDiff = _G.currentDifficulty or self.songAppend or ""
		local diff = rawDiff:gsub("^%-", "")  -- quitar guión inicial
		if diff == "" then diff = "normal" end

		return {
			diff = diff,
			song = _G.currentSongName or self.songName or "unknown",
			displaySong = _G.currentSongDisplayName or nil,
			artist = _G.currentArtist or nil,
			scores = {
				score       = _G.storyMode and (_G.weekTotalScore or 0) or score,
				sickCount   = self.ratingsData.sick.hits,
				goodCount   = self.ratingsData.good.hits,
				badCount    = self.ratingsData.bad.hits,
				shitCount   = self.ratingsData.shit.hits,
				missedCount = misses,
				maxCombo    = self.maxCombo or 0,
			}
		}
	end,

	-- ============================================================
	-- handleSongEnd(): Centraliza TODA la lógica de transición
	--   - Freeplay: siempre va a results después de cada canción
	--   - Story mode: avanza a la siguiente canción, o va a results
	--     después de la última canción de la semana
	-- ============================================================
	handleSongEnd = function(self)
		-- Cargar results de forma lazy (no está declarado como global en main.lua)
		local resultsState = results or love.filesystem.load("states/results.lua")()
		if not results then results = resultsState end

		if _G.storyMode then
			-- ¿Hay más canciones en la semana?
			if _G.currentSongIndex < #_G.weekSongs then
				-- Avanzar a la siguiente canción — la semana se encarga de cargarla
				-- (el flag songEnded ya está en true, las semanas lo detectan)
				return
			else
				-- Última canción de la semana → pantalla de resultados
				local sd = self:buildScoreData()
				-- En story mode el score mostrado es el total de la semana
				sd.song = _G.currentWeekName or sd.song
				status.setLoading(true)
				graphics.fadeOut(0.5, function()
					Gamestate.switch(resultsState, sd)
					status.setLoading(false)
				end)
			end
		else
			-- Freeplay → siempre pantalla de resultados
			local sd = self:buildScoreData()
			status.setLoading(true)
			graphics.fadeOut(0.5, function()
				Gamestate.switch(resultsState, sd)
				status.setLoading(false)
			end)
		end
	end,

	leave = function(self)
		if inst   then inst:stop();   if inst.release   then inst:release()   end; inst   = nil end
		if voices then voices:stop(); if voices.release then voices:release() end; voices = nil end
		Timer.clear()

		-- OPT FIX 9: Liberar fuentes de audio explícitamente (evita leak en driver de Switch)
		if sounds then
			local function stopAndRelease(src)
				if src then
					if src.stop then src:stop() end
					if src.release then src:release() end
				end
			end
			if sounds.countdown then
				for _, v in pairs(sounds.countdown) do stopAndRelease(v) end
			end
			if sounds.miss then
				for _, v in ipairs(sounds.miss) do stopAndRelease(v) end
			end
			stopAndRelease(sounds.death)
			sounds = nil
		end

		-- OPT FIX 4: Resetear cache de infoText
		lastCachedScore         = -1
		lastCachedMisses        = -1
		lastCachedRatingName    = ""
		lastCachedRatingPercent = -1
		lastCachedRatingFC      = ""
		cachedInfoText          = ""
		cachedInfoTextWidth     = 0

		-- Liberar sprites de flechas (son objetos, pero no tienen método destroy; el GC se encargará)
		if enemyArrows then
			for i = 1, #enemyArrows do enemyArrows[i] = nil end
			enemyArrows = {}   -- reiniciar tabla
		end
		if boyfriendArrows then
			for i = 1, #boyfriendArrows do boyfriendArrows[i] = nil end
			boyfriendArrows = {}
		end
		if activeSplashes then
			activeSplashes       = {{}, {}, {}, {}}
			splashLoaderFns      = {nil, nil, nil, nil}
			splashLoaderIsCustom = false
			splashCustomAnim     = "splash"
			splashCustomIsPixel  = false
		end
		-- Apagar flags ANTES de destruir los sprites, por si drawUI
		-- se llama durante el fade-out después de leave
		holdActive             = {false, false, false, false}
		holdSplashVisible      = {false, false, false, false}
		enemyHoldActive        = {false, false, false, false}
		enemyHoldSplashVisible = {false, false, false, false}
		if holdSplashArrows then
			for i = 1, #holdSplashArrows do holdSplashArrows[i] = nil end
			holdSplashArrows = {}
		end
		if enemyHoldSplashArrows then
			for i = 1, #enemyHoldSplashArrows do enemyHoldSplashArrows[i] = nil end
			enemyHoldSplashArrows = {}
		end

		-- Liberar notas (tablas anidadas)
		if enemyNotes then
			for i = 1, 4 do
				if enemyNotes[i] then
					for j = 1, #enemyNotes[i] do enemyNotes[i][j] = nil end
					enemyNotes[i] = {}
				end
			end
			enemyNotes = {}   -- reiniciar tabla principal
		end
		if boyfriendNotes then
			for i = 1, 4 do
				if boyfriendNotes[i] then
					for j = 1, #boyfriendNotes[i] do boyfriendNotes[i][j] = nil end
					boyfriendNotes[i] = {}
				end
			end
			boyfriendNotes = {}
		end

		-- Vaciar otras tablas (mantener la referencia, solo limpiar contenido)
		if events then
			for i = 1, #events do events[i] = nil end
			-- No reiniciamos a {} porque puede ser global, pero podemos dejar que se sobrescriba en generateNotes
			-- Sin embargo, es seguro hacer events = {}
			events = {}
		end
		if cameraEvents then
			for i = 1, #cameraEvents do cameraEvents[i] = nil end
			for i = #cameraEvents, 1, -1 do cameraEvents[i] = nil end
		end
		if spriteTimers then
			for i = 1, #spriteTimers do spriteTimers[i] = nil end
			-- Importante: mantener la tabla, solo vaciarla
			spriteTimers = {}
		end

		-- Limpiar grupos y botplay
		holdGroupsInfo = {}
		nextGroupId = 1
		botHolding = {false, false, false, false}
		botplayActive = false
		middleScroll = false
		for i = 1, 4 do
			if botKeyTimers[i] then
				Timer.cancel(botKeyTimers[i])
				botKeyTimers[i] = nil
			end
		end

		-- Liberar sprites de personajes (globales, se recargan en load)
		girlfriend = nil
		boyfriend = nil
		enemy = nil
		fakeBoyfriend = nil
		rating = nil
		numbers = nil
		countdown = nil
		enemyIcon = nil
		boyfriendIcon = nil

		-- Liberar tablas de imágenes (también se recargan)
		-- MEM FIX: nil los campos individuales primero para soltar referencias a GPU textures
		-- antes de que la GC tenga oportunidad de correr.
		if images then
			images.notes        = nil
			images.numbers      = nil
			images.noteSplashes = nil
			images.icons        = nil
			-- timeBar es shared, se libera con self._sharedTimeBar
			images = nil
		end
		self._sharedTimeBar = nil
		sprites = nil

		-- OPT FIX 7: Dos ciclos completos de GC para liberar referencias circulares
		collectgarbage("collect")
		collectgarbage("collect")
	end,

    getBPM = function() return bpm end,
    getMusicTime = function() return musicTime end,
    cameraEvents = cameraEvents,

	getSpriteTimer = function(self, id)
		return spriteTimers[id]
	end,
	setSpriteTimer = function(self, id, value)
		spriteTimers[id] = value
	end,

	setMiddleScroll = function(self, enabled)
		middleScroll = enabled or false
	end,
	rotateArrows = function(self, rad)
		for i = 1, 4 do
			if enemyArrows[i] then
				enemyArrows[i].orientation = rad
			end
			if boyfriendArrows[i] then
				boyfriendArrows[i].orientation = rad
			end
		end
	end,
	getMiddleScroll = function(self)
		return middleScroll
	end,

	-- ============================================================================
	-- FUNCIONES PARA CAMBIAR DE MODO NORMAL A PÍXEL EN TIEMPO REAL
	-- ============================================================================

	setPixelMode = function(self, enabled, noteTexture)
		-- Si ya estamos en el modo deseado, no hacer nada
		if (enabled and _G.isPixelWeek) or (not enabled and not _G.isPixelWeek) then
			return
		end

		-- MEM FIX: Liberar fuentes de audio viejas ANTES de crear las nuevas
		-- (mismo patrón que leave() OPT FIX 9 para evitar leak en driver de Switch)
		if sounds then
			local function releaseSource(src)
				if src then
					if src.stop  then src:stop()    end
					if src.release then src:release() end
				end
			end
			if sounds.countdown then
				for _, v in pairs(sounds.countdown) do releaseSource(v) end
			end
			if sounds.miss then
				for _, v in ipairs(sounds.miss) do releaseSource(v) end
			end
			releaseSource(sounds.death)
			sounds = nil
		end

		-- MEM FIX: Soltar referencias a texturas viejas ANTES de crear las nuevas.
		-- Esto permite que la GC libere la VRAM antes de la carga, evitando OOM en Switch.
		-- No tocamos timeBar porque es shared y no nos pertenece.
		if images then
			images.notes        = nil
			images.numbers      = nil
			images.noteSplashes = nil
			-- icons no cambia entre modos; se reutiliza abajo
			local savedIcons   = images.icons
			local savedTimeBar = images.timeBar
			images = nil
			-- Correr GC ahora que las refs están sueltas, ANTES de cargar nuevas texturas
			collectgarbage("collect")
			collectgarbage("collect")
			-- Restaurar los que no necesitan recargarse
			images = { icons = savedIcons, timeBar = savedTimeBar }
		end

		-- Cambiar el flag global
		_G.isPixelWeek = enabled

		-- OPT FIX 1 (compat): recargar el set de recursos que se necesita ahora
		-- (con carga lazy los dos sets no coexisten en memoria)
		if enabled then
			local styleName = noteTexture or "default"
			local styleLoader = noteTextureStyles[styleName] or noteTextureStyles["default"]
			if not noteTextureStyles[styleName] then
				print("ADVERTENCIA: Estilo de notas '" .. tostring(noteTexture) .. "' no existe, usando 'default'.")
			end
			local notesImg = styleLoader()
			local numbersImgPixel = love.graphics.newImage(graphics.imagePath("pixel/numbers"))
			numbersImgPixel:setFilter("nearest", "nearest")
			sounds = {
				countdown = {
					three = love.audio.newSource("sounds/pixel/countdown-3.ogg", "static"),
					two   = love.audio.newSource("sounds/pixel/countdown-2.ogg", "static"),
					one   = love.audio.newSource("sounds/pixel/countdown-1.ogg", "static"),
					go    = love.audio.newSource("sounds/pixel/countdown-date.ogg", "static")
				},
				miss = {
					love.audio.newSource("sounds/pixel/miss1.ogg", "static"),
					love.audio.newSource("sounds/pixel/miss2.ogg", "static"),
					love.audio.newSource("sounds/pixel/miss3.ogg", "static")
				},
				death = love.audio.newSource("sounds/pixel/death.ogg", "static")
			}
			images.notes        = notesImg
			images.numbers      = numbersImgPixel
			images.noteSplashes = notesImg
			sprites = {
				icons   = love.filesystem.load("sprites/icons.lua"),
				numbers = love.filesystem.load("sprites/pixel/numbers.lua")
			}
		else
			sounds = {
				countdown = {
					three = love.audio.newSource("sounds/countdown-3.ogg", "static"),
					two   = love.audio.newSource("sounds/countdown-2.ogg", "static"),
					one   = love.audio.newSource("sounds/countdown-1.ogg", "static"),
					go    = love.audio.newSource("sounds/countdown-go.ogg", "static")
				},
				miss = {
					love.audio.newSource("sounds/miss1.ogg", "static"),
					love.audio.newSource("sounds/miss2.ogg", "static"),
					love.audio.newSource("sounds/miss3.ogg", "static")
				},
				death = love.audio.newSource("sounds/death.ogg", "static")
			}
			images.notes        = love.graphics.newImage(graphics.imagePath("notes"))
			images.numbers      = love.graphics.newImage(graphics.imagePath("numbers"))
			images.noteSplashes = love.graphics.newImage(graphics.imagePath("noteSplashes"))
			sprites = {
				icons   = love.filesystem.load("sprites/icons.lua"),
				numbers = love.filesystem.load("sprites/numbers.lua")
			}
		end

		self:loadArrowSprites()

		-- Recrear todos los elementos visuales
		self:recreateStaticArrows()
		self:recreateSplashes()
		self:recreateRatingAndNumbers()
		if countingDown then
			self:recreateCountdown()
		end
		self:recreateAllNotes()

		print("Modo cambiado a", enabled and "PÍXEL" or "NORMAL")
	end,

	recreateStaticArrows = function(self)
		-- Guardar propiedades de las flechas actuales
		local oldEnemyArrows = {}
		local oldBoyfriendArrows = {}
		for i = 1, 4 do
			oldEnemyArrows[i] = {
				x = enemyArrows[i].x,
				y = enemyArrows[i].y,
				alpha = enemyArrows[i].alpha
			}
			oldBoyfriendArrows[i] = {
				x = boyfriendArrows[i].x,
				y = boyfriendArrows[i].y,
				alpha = boyfriendArrows[i].alpha
			}
		end

		-- Crear nuevas flechas con los sprites actuales
		enemyArrows = { sprites.leftArrow(), sprites.downArrow(), sprites.upArrow(), sprites.rightArrow() }
		boyfriendArrows = { sprites.leftArrow(), sprites.downArrow(), sprites.upArrow(), sprites.rightArrow() }

		-- Escala según modo. Normal usa 1 (sin size explícito en initUI = default 1).
		local scale = _G.isPixelWeek and NoteSize or 1
		for i = 1, 4 do
			enemyArrows[i].sizeX, enemyArrows[i].sizeY = scale, scale
			boyfriendArrows[i].sizeX, boyfriendArrows[i].sizeY = scale, scale

			-- Restaurar posición y alpha (recalcular si middleScroll)
			if middleScroll then
				boyfriendArrows[i].x = -330 + 165 * i
				enemyArrows[i].x = oldEnemyArrows[i].x
			else
				enemyArrows[i].x = oldEnemyArrows[i].x
				boyfriendArrows[i].x = oldBoyfriendArrows[i].x
			end
			enemyArrows[i].y = oldEnemyArrows[i].y
			enemyArrows[i].alpha = oldEnemyArrows[i].alpha

			boyfriendArrows[i].y = oldBoyfriendArrows[i].y
			boyfriendArrows[i].alpha = oldBoyfriendArrows[i].alpha

			-- Asegurar animación inicial
			enemyArrows[i]:animate("off", false)
			boyfriendArrows[i]:animate("off", false)
		end
	end,

	recreateSplashes = function(self)
		-- Reconstruir hold-splashes (sin cambios)
		holdSplashArrows = { sprites.holdSplashLeft(), sprites.holdSplashDown(), sprites.holdSplashUp(), sprites.holdSplashRight() }
		enemyHoldSplashArrows = { sprites.holdSplashLeft(), sprites.holdSplashDown(), sprites.holdSplashUp(), sprites.holdSplashRight() }

		local scale = _G.isPixelWeek and NoteSize or 1.5
		for i = 1, 4 do
			holdSplashArrows[i].sizeX, holdSplashArrows[i].sizeY = scale, scale
			enemyHoldSplashArrows[i].sizeX, enemyHoldSplashArrows[i].sizeY = scale, scale
			holdSplashArrows[i].x = boyfriendArrows[i].x
			holdSplashArrows[i].y = boyfriendArrows[i].y
			enemyHoldSplashArrows[i].x = enemyArrows[i].x
			enemyHoldSplashArrows[i].y = enemyArrows[i].y
			holdSplashVisible[i] = false
			enemyHoldSplashVisible[i] = false
			enemyHoldActive[i] = false
		end

		-- Descartar instancias activas; actualizar loaders al modo actual
		-- (si hay un custom splash activo, resetDefaultSplashLoaders lo respeta)
		activeSplashes = {{}, {}, {}, {}}
		resetDefaultSplashLoaders()
	end,

	recreateRatingAndNumbers = function(self)
		-- Guardar posición y visibilidad del rating actual
		local oldRatingX, oldRatingY = rating.x, rating.y
		local oldRatingVis = ratingVisibility[1]
		local oldNumbers = {}
		for i = 1, 3 do
			oldNumbers[i] = { x = numbers[i].x, y = numbers[i].y }
		end

		-- Crear nuevo rating y números
		if _G.isPixelWeek then
			rating = love.filesystem.load("sprites/pixel/rating.lua")()
			rating.sizeX, rating.sizeY = NoteSize * 0.75, NoteSize * 0.75
			numbers = {}
			for i = 1, 3 do
				numbers[i] = love.filesystem.load("sprites/pixel/numbers.lua")()
				numbers[i].sizeX, numbers[i].sizeY = NoteSize * 0.5, NoteSize * 0.5
			end
		else
			rating = love.filesystem.load("sprites/rating.lua")()
			rating.sizeX, rating.sizeY = 0.75, 0.75
			numbers = {}
			for i = 1, 3 do
				numbers[i] = love.filesystem.load("sprites/numbers.lua")()
				numbers[i].sizeX, numbers[i].sizeY = 0.5, 0.5
			end
		end

		-- Restaurar posiciones
		rating.x = oldRatingX
		rating.y = oldRatingY
		for i = 1, 3 do
			numbers[i].x = oldNumbers[i].x
			numbers[i].y = oldNumbers[i].y
		end
		ratingVisibility[1] = oldRatingVis
	end,

	recreateCountdown = function(self)
		-- Guardar propiedades del countdown actual
		local oldCountdownX, oldCountdownY = countdown.x, countdown.y
		local oldCountdownAlpha = countdown.alpha

		-- Crear nuevo countdown
		if _G.isPixelWeek then
			countdown = love.filesystem.load("sprites/pixel/countdown_pixel.lua")()
			countdown.sizeX, countdown.sizeY = NoteSize, NoteSize
		else
			countdown = love.filesystem.load("sprites/countdown.lua")()
		end

		-- Restaurar posición y alpha
		countdown.x = oldCountdownX
		countdown.y = oldCountdownY
		countdown.alpha = oldCountdownAlpha
	end,

	recreateAllNotes = function(self)
		-- El offset que estaba horneado en .y de las notas "end" antes de este cambio de modo.
		-- isPixelWeek YA fue actualizado al modo nuevo, así que el modo viejo es el opuesto.
		local oldEndNoteYOffset = _G.isPixelWeek and 0 or PIXEL_END_NOTE_OFFSET

		-- Recopilar datos de las notas actuales.
		-- Para notas "end" guardamos la y BASE (sin el offset viejo) para reaplicar
		-- el offset correcto del modo nuevo al reconstruir.
		local notesData = { enemy = {}, boyfriend = {} }

		local function serializeNote(note)
			local animName = note:getAnimName()
			local baseY = note.y
			if animName == "end" then
				-- Revertir el offset que se aplicó en generateNotes con el modo viejo
				if settings.downscroll then
					baseY = baseY + oldEndNoteYOffset
				else
					baseY = baseY - oldEndNoteYOffset
				end
			end
			return {
				strumTime   = note.strumTime,
				animName    = animName,
				holdGroupId = note.holdGroupId,
				altNote     = note.altNote,
				isHoldStart = note.isHoldStart,
				noteKind    = note.noteKind,
				x           = note.x,
				baseY       = baseY,
				hit         = note.hit
			}
		end

		for i = 1, 4 do
			notesData.enemy[i] = {}
			for j, note in ipairs(enemyNotes[i]) do
				table.insert(notesData.enemy[i], serializeNote(note))
			end
			notesData.boyfriend[i] = {}
			for j, note in ipairs(boyfriendNotes[i]) do
				table.insert(notesData.boyfriend[i], serializeNote(note))
			end
		end

		-- Vaciar listas actuales
		for i = 1, 4 do
			enemyNotes[i] = {}
			boyfriendNotes[i] = {}
		end

		-- Crear nota según índice
		local function createNoteByIndex(idx)
			if idx == 1 then return sprites.leftArrow() end
			if idx == 2 then return sprites.downArrow() end
			if idx == 3 then return sprites.upArrow() end
			if idx == 4 then return sprites.rightArrow() end
		end

		local noteScale = _G.isPixelWeek and NoteSize or 1
		local newEndNoteYOffset = _G.isPixelWeek and PIXEL_END_NOTE_OFFSET or 0
		print("recreateAllNotes: _G.isPixelWeek =", _G.isPixelWeek, "noteScale =", noteScale)

		-- Reconstruir notas del enemigo
		for i = 1, 4 do
			for _, data in ipairs(notesData.enemy[i]) do
				local newNote = createNoteByIndex(i)
				newNote.sizeX, newNote.sizeY = noteScale, noteScale
				newNote.x           = data.x
				newNote.strumTime   = data.strumTime
				newNote.hit         = data.hit
				newNote.altNote     = data.altNote
				newNote.isHoldStart = data.isHoldStart
				newNote.holdGroupId = data.holdGroupId
				newNote.noteKind    = data.noteKind

				if data.animName == "end" then
					if settings.downscroll then
						newNote.y     = data.baseY - newEndNoteYOffset
						newNote.sizeY = -noteScale
					else
						newNote.y     = data.baseY + newEndNoteYOffset
						-- upscroll: sizeY queda positivo (igual que generateNotes)
					end
					newNote.offsetY = -10
				else
					newNote.y       = data.baseY
					newNote.offsetY = 0
				end

				newNote:animate(data.animName, false)
				table.insert(enemyNotes[i], newNote)
			end
		end

		-- Reconstruir notas del novio (misma lógica)
		for i = 1, 4 do
			for _, data in ipairs(notesData.boyfriend[i]) do
				local newNote = createNoteByIndex(i)
				newNote.sizeX, newNote.sizeY = noteScale, noteScale
				newNote.x           = data.x
				newNote.strumTime   = data.strumTime
				newNote.hit         = data.hit
				newNote.altNote     = data.altNote
				newNote.isHoldStart = data.isHoldStart
				newNote.holdGroupId = data.holdGroupId
				newNote.noteKind    = data.noteKind

				if data.animName == "end" then
					if settings.downscroll then
						newNote.y     = data.baseY - newEndNoteYOffset
						newNote.sizeY = -noteScale
					else
						newNote.y     = data.baseY + newEndNoteYOffset
					end
					newNote.offsetY = -10
				else
					newNote.y       = data.baseY
					newNote.offsetY = 0
				end

				newNote:animate(data.animName, false)
				table.insert(boyfriendNotes[i], newNote)
			end
		end
	end,
	loadArrowSprites = function(self)
		local arrowPath = _G.isPixelWeek and "sprites/pixel/" or "sprites/"
		local splashPath = _G.isPixelWeek and "sprites/pixel/" or "sprites/"
		local holdSplashPath = _G.isPixelWeek and "sprites/pixel/" or "sprites/"

		sprites.leftArrow = love.filesystem.load(arrowPath .. "left-arrow.lua")
		sprites.downArrow = love.filesystem.load(arrowPath .. "down-arrow.lua")
		sprites.upArrow = love.filesystem.load(arrowPath .. "up-arrow.lua")
		sprites.rightArrow = love.filesystem.load(arrowPath .. "right-arrow.lua")

		sprites.splashLeft = love.filesystem.load(splashPath .. "splash-left.lua")
		sprites.splashDown = love.filesystem.load(splashPath .. "splash-down.lua")
		sprites.splashUp = love.filesystem.load(splashPath .. "splash-up.lua")
		sprites.splashRight = love.filesystem.load(splashPath .. "splash-right.lua")

		sprites.holdSplashLeft = love.filesystem.load(holdSplashPath .. "HoldSplash-left.lua")
		sprites.holdSplashDown = love.filesystem.load(holdSplashPath .. "HoldSplash-down.lua")
		sprites.holdSplashUp = love.filesystem.load(holdSplashPath .. "HoldSplash-up.lua")
		sprites.holdSplashRight = love.filesystem.load(holdSplashPath .. "HoldSplash-right.lua")
	end,

	-- ============================================================
	-- setSplash(loaderFn, soundSource, shared, animName, isPixel)
	--   loaderFn    : función sin argumentos que devuelve un nuevo sprite.
	--   soundSource : love.audio.Source (opcional). nil = sin sonido.
	--   shared      : ignorado (compatibilidad). Cada hit crea instancia nueva.
	--   animName    : animación a ejecutar en el sprite (default "splash").
	--                 Ej: "Squirt" para BloodSplash.
	--   isPixel     : boolean (default false). true = el sprite es pixel y se
	--                 escala con NoteSize igual que los splashes default pixel.
	--                 false (o nil) = escala normal 1.5 siempre.
	--
	-- Ejemplo con BloodSplash (normal, anim "Squirt"):
	--   weeks:setSplash(love.filesystem.load("sprites/BloodSplash.lua"), nil, false, "Squirt")
	-- Ejemplo con splash pixel custom:
	--   weeks:setSplash(love.filesystem.load("sprites/pixel/myPixelSplash.lua"), nil, false, "splash", true)
	-- ============================================================
	setSplash = function(self, loaderFn, soundSource, shared, animName, isPixel)
		customSplashLoader = loaderFn
		customSplashSound  = soundSource

		activeSplashes        = {{}, {}, {}, {}}
		splashLoaderIsCustom  = true
		splashCustomAnim      = animName or "splash"
		splashCustomIsPixel   = isPixel == true
		for i = 1, 4 do
			splashLoaderFns[i] = loaderFn
		end
	end,

	-- ============================================================
	-- resetSplash()
	-- Restaura el splash por defecto (el del modo actual: normal o pixel).
	-- ============================================================
	resetSplash = function(self)
		customSplashLoader = nil
		customSplashSound  = nil

		activeSplashes       = {{}, {}, {}, {}}
		splashLoaderIsCustom = false
		splashCustomAnim     = "splash"
		splashCustomIsPixel  = false
		resetDefaultSplashLoaders()
	end,

	-- ============================================================
	-- setSplashPerLane(loaders, soundSource, isPixel)
	--   loaders     : tabla con 4 funciones, una por carril.
	--                 loaders[1]=left, [2]=down, [3]=up, [4]=right.
	--                 Cada función devuelve un nuevo sprite ya animado.
	--   soundSource : love.audio.Source opcional (mismo para todos).
	--   isPixel     : boolean opcional (default false).
	--
	-- Permite asignar un loader DISTINTO por carril, a diferencia de
	-- setSplash que asigna el mismo a los 4.
	-- ============================================================
	setSplashPerLane = function(self, loaders, soundSource, isPixel)
		customSplashLoader = loaders[1]  -- referencia al primero (solo para compatibilidad)
		customSplashSound  = soundSource or nil

		activeSplashes       = {{}, {}, {}, {}}
		splashLoaderIsCustom = true
		splashCustomAnim     = "splash"
		splashCustomIsPixel  = isPixel == true

		for i = 1, 4 do
			splashLoaderFns[i] = loaders[i]
		end
	end,
}