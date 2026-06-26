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

local psychLoader = require("charts.psych.loader")
local psychEventDispatcher = require("charts.psych.events")
local psychCharacters = require("charts.psych.characters")
local psychStages = require("charts.psych.stages")
local psychNoteTypes = require("charts.psych.notetypes")
local splashShader = require("modules.splash_shader")

-- Los 6 tipos de nota incorporados de Psych Engine (objects/Note.hx
-- defaultNoteTypes). Cualquier otro noteTypeStr se trata como tipo
-- personalizado (custom_notetypes/<nombre>.txt, ver charts/psych/notetypes.lua).
local BUILTIN_NOTE_TYPES = {
	[""] = true,
	["Alt Animation"] = true,
	["Hey!"] = true,
	["Hurt Note"] = true,
	["GF Sing"] = true,
	["No Animation"] = true,
}

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

-- Middle Scroll (PlayState.hx real): centra las flechas del jugador --
-- las del oponente NO se ocultan, quedan visibles con alpha 0.35
-- superpuestas cerca del centro (antes esto las ocultaba del todo, lo
-- cual no coincide con el comportamiento real).
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
--
-- DESACTIVADO (puesto en 0): los frames "hold" y "end" del atlas pixel
-- (images/png/pixel/notes.png) comparten el MISMO canvas sin recorte (7x6,
-- offsetWidth/offsetHeight=0 en ambos) -- graphics.lua centra el pivote de
-- dibujado en el centro de ESE canvas para los dos frames por igual, así
-- que la pieza "end" (que ahora cae exactamente en el final real del
-- sustain, no en "donde dejó el loop") no necesita ningún desplazamiento
-- extra para alinearse con la última pieza "hold": comparten pivote.
-- El valor anterior (-97.5 con NoteSize=8.5, más de 2 pasos completos de
-- separación entre piezas) no corresponde a esta geometría -- venía de
-- antes de que el loop de abajo generara un número EXACTO de pasos
-- (ver "numSteps"/"stepSize"), probablemente tuneado a mano contra una
-- versión distinta de este sistema. Si vuelve a verse mal, ajustar este
-- valor de nuevo SOLO después de confirmar visualmente en el juego.
local PIXEL_END_NOTE_OFFSET = 0

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
	sonic  = {0, 88, 183},                      -- sonic
	sonic2  = {22, 13, 135},                      -- sonic2
	sonic2poop  = {22, 13, 135},                      -- sonic2poop
	sanic  = {0, 88, 183},                      -- sanic
	crappyonic = {22, 13, 135},
	darnell = {115, 94, 176},                      -- darnell
	majin = {1, 2, 214},
	crappyfriend = {49, 176, 209},
	-- kazuha/chaewon/eunchae/sakura/yunjin (colab Sserafim) comparten el
	-- mismo rosa pastel oscuro pedido (191,14,104) -- nombres de ícono
	-- confirmados en sprites/icons.lua. Mantenida como FALLBACK ahora que
	-- healthBarColorFor() (ver abajo) prefiere el campo real del
	-- personaje -- sigue haciendo falta para los pocos JSON de
	-- cutscene/pose sin "healthbar_colors" (nunca personajes de gameplay
	-- real) y como red de seguridad si la referencia al personaje
	-- estuviera nil en el momento exacto de dibujar.
	kazuha = {191, 14, 104},
	chaewon = {191, 14, 104},
	eunchae = {191, 14, 104},
	sakura = {191, 14, 104},
	yunjin = {191, 14, 104},
}

-- BUG corregido (round 44): el color de la barra de vida se sacaba
-- SIEMPRE de characterColors (arriba), indexado por el NOMBRE DEL
-- ÍCONO -- nunca del campo real del personaje ("healthbar_colors" en
-- characters/*.json, leído por charts/psych/character.lua en
-- sprite.psychChar.healthbar_colors, hasta ahora código muerto para
-- esto). Auditados los 38 JSON de personajes existentes: 34/38 tienen el
-- campo, y de esos, 32 coinciden EXACTO con la tabla hardcodeada -- bajo
-- riesgo de cambiar el color de algo que ya se veía bien (las únicas 2
-- diferencias reales encontradas, bf-pixel y nene, parecen ser la tabla
-- hardcodeada desactualizada respecto al JSON, no al revés). Ahora se
-- prefiere el campo del personaje REAL actualmente cargado en cada slot,
-- cayendo a esta tabla por nombre de ícono solo si ese personaje no
-- tiene el campo.
local function healthBarColorFor(characterSprite, iconName)
	local psychChar = characterSprite and characterSprite.psychChar
	return (psychChar and psychChar.healthbar_colors) or characterColors[iconName]
end

-- BUG corregido (round 45): mismo patrón que healthBarColorFor() arriba,
-- esta vez para el ÍCONO mismo -- charts/psych/character.lua YA lee
-- "healthicon" del JSON del personaje en sprite.psychChar.healthicon,
-- pero todo el código que llama a esto (acá, charts/psych/events.lua,
-- modules/weekLoader.lua) usaba SIEMPRE entry.icon (el campo de la
-- TABLA REGISTRO de charts/psych/characters.lua) en su lugar, código
-- muerto para el campo del JSON otra vez. A diferencia de
-- healthbar_colors, ACÁ el registro venía siendo la fuente correcta
-- (cubre casos donde el nombre crudo del JSON no es ni siquiera un
-- ícono real registrado en sprites/icons.lua, ej. "icon-sonic-exe") --
-- auditados los 36 personajes del registro contra su propio JSON Y
-- contra los nombres válidos de sprites/icons.lua: 25 de 36 JSON tenían
-- un healthicon viejo/inválido (convención corta estilo Psych original,
-- "bf"/"gf"/"dad"/"mom"/etc, que nunca coincide con los nombres más
-- largos que usa este motor) -- corregidos los 24 archivos únicos
-- afectados para que coincidan con el registro (ya confirmado válido en
-- icons.lua) antes de cambiar este código. Ahora se prefiere el campo
-- ya corregido del personaje, cayendo a entry.icon solo si falta.
local function healthIconNameFor(characterSprite, entryIcon)
	local psychChar = characterSprite and characterSprite.psychChar
	return (psychChar and psychChar.healthicon) or entryIcon
end

camScale = {x = 1, y = 1}   -- zoom base para el efecto de beat (defaultCamZoom de Psych)

-- "Empuje" de zoom momentáneo sobre camScale ("Add Camera Zoom" de Psych):
-- decae exponencialmente hacia 0 cada frame (ver update), igual que
-- FlxG.camera.zoom = lerp(defaultCamZoom, FlxG.camera.zoom, exp(-elapsed*3.125))
-- en PlayState.hx, que hace que el zoom añadido vuelva solo al normal.
camZoomBump = {x = 0, y = 0}

cameraEvents = {}

-- Offset de cámara propio del stage activo (camera_boyfriend/camera_opponent/
-- camera_girlfriend de stages/data/<id>.json -- boyfriendCameraOffset/
-- opponentCameraOffset/girlfriendCameraOffset en PlayState.hx). Antes estaba
-- hardcodeado en [0,0]; varios stages reales (limo, mall, school, schoolEvil)
-- tienen valores distintos de cero.
local function stageCamOffset(field)
	local data = psychStages.getCurrentData()
	local p = data and data[field]
	return (p and p[1]) or 0, (p and p[2]) or 0
end

-- Replica moveCamera(false) de Psych (PlayState.hx):
--   camFollow.x = bf.midpoint.x - 100 - bf.cameraPosition[0] + boyfriendCameraOffset[0]
--   camFollow.y = bf.midpoint.y - 100 + bf.cameraPosition[1] + boyfriendCameraOffset[1]
-- cam = -camFollow + CONST (CONST_X=0, CONST_Y=-25, derivados calibrando
-- contra los valores ya correctos de Week 1, donde boyfriendCameraOffset=0):
--   cam.x = -bf.x + 100 + cameraPosition[0] - stageOffset[0]
--   cam.y = -bf.y + 75  - cameraPosition[1] - stageOffset[1]
-- camera_position es un valor "crudo" de Psych, en la misma unidad que el
-- arte SIN escalar -- igual que anim.offsetX/Y (ver modules/graphics.lua),
-- NO debe usarse directo si el personaje tiene scale != 1. Para personajes
-- normales (scale=1, bf/dad/etc.) esto no cambia nada; para personajes pixel
-- (scale=6, semana 6) usarlo sin dividir amplificaba camera_position 6x,
-- lo cual era invisible para bf/dad/pico (camera_position=[0,0]) pero
-- catastrófico para Senpai ([-240,-330] sin dividir desplazaba la cámara
-- ~400px fuera de pantalla cuando debía enfocarlo).
local function bfCamTarget()
	local p = boyfriend.psychChar and boyfriend.psychChar.camera_position or {0, 0}
	local sx, sy = stageCamOffset("camera_boyfriend")
	local scaleX = math.abs(boyfriend.sizeX or 1)
	local scaleY = math.abs(boyfriend.sizeY or 1)
	return -boyfriend.x + 100 + (p[1] or 0) / scaleX - sx, -boyfriend.y + 75 - (p[2] or 0) / scaleY - sy
end

-- Replica moveCamera(true) de Psych:
--   camFollow.x = dad.midpoint.x + 150 + dad.cameraPosition[0] + opponentCameraOffset[0]
--   camFollow.y = dad.midpoint.y - 100 + dad.cameraPosition[1] + opponentCameraOffset[1]
-- cam = -camFollow + CONST (mismas CONST_X/Y que arriba):
--   cam.x = -dad.x - 150 - cameraPosition[0] - stageOffset[0]
--   cam.y = -dad.y + 75  - cameraPosition[1] - stageOffset[1]
local function enemyCamTarget()
	local p = enemy.psychChar and enemy.psychChar.camera_position or {0, 0}
	local sx, sy = stageCamOffset("camera_opponent")
	local scaleX = math.abs(enemy.sizeX or 1)
	local scaleY = math.abs(enemy.sizeY or 1)
	return -enemy.x - 150 - (p[1] or 0) / scaleX - sx, -enemy.y + 75 - (p[2] or 0) / scaleY - sy
end

-- "Set GF Speed" de Psych real (PlayState.hx: gfSpeed, default 1) --
-- MULTIPLICA al danceEveryNumBeats automático de girlfriend (ver
-- triggerDanceBeat() más abajo), no es un divisor compartido para los 3
-- personajes. El default real es 1 (sin esta gfDanceBeats=2 que tenía
-- antes antes de esta sesión).
gfDanceBeats = gfDanceBeats or 1
local psychEvents = {}  -- eventos de chart Psych pendientes, ordenados por tiempo
local spriteTimers = {}
local gfDanceLeft = false        -- alterna danceLeft/danceRight para girlfriend
local enemyDanceLeft = false     -- idem para enemy (p.ej. Skid and Pump, sin "idle" propio)
local boyfriendDanceLeft = false -- idem para boyfriend (personajes Psych sin "idle", p.ej. pico-player)
misses = 0
customGirlfriendIdle = customGirlfriendIdle or false

-- Character.hx dance(): si el personaje no tiene "idle" pero sí
-- danceLeft/danceRight, alterna entre ambos cada vez que se le pide
-- "bailar" (igual que GF) en vez de quedarse congelado en una sola pose.
-- Ver triggerDanceBeat() más abajo: protege cualquier animación que no sea
-- dance/idle de ser interrumpida por el ciclo de baile mientras sigue en
-- curso (notas reales, "scared", animaciones disparadas a mano en una
-- cutscene, etc.) -- comparar contra nombres Psych como "sing*" no sirve
-- porque getAnimName() devuelve el nombre INTERNO ya traducido (ver
-- charts/psych/animnames.lua: "singUP" -> "up", no "singUP").
local function isDanceOrIdle(name)
	return name == "idle" or name == "danceLeft" or name == "danceRight"
end

local function danceOrIdle(sprite, wasLeft)
	local anims = sprite:getAnims()
	if anims["danceLeft"] and anims["danceRight"] then
		local left = not wasLeft
		sprite:animate(left and "danceLeft" or "danceRight", false)
		return left
	elseif anims["idle"] then
		sprite:animate("idle", false)
		return wasLeft
	else
		-- Sin "idle" ni danceLeft/danceRight (p.ej. un personaje especial
		-- a mitad de una animación propia, como pico-speaker disparando):
		-- no tocar nada en vez de spamear un WARN inútil cada beat.
		return wasLeft
	end
end

-- Character.hx real (recalculateDanceIdle): cada personaje tiene su PROPIO
-- "danceEveryNumBeats", NO uno compartido -- si tiene danceLeft Y
-- danceRight baila cada 1 beat (alternando, así un ciclo completo de
-- ambas poses tarda 2 beats); si solo tiene "idle" baila cada 2 beats.
-- Antes Rewritten usaba un único gfDanceBeats (=2) para los tres
-- personajes por igual, sin mirar si cada uno tenía o no danceLeft/Right.
local function danceEveryNumBeats(sprite)
	local anims = sprite:getAnims()
	if anims["danceLeft"] and anims["danceRight"] then
		return 1
	end
	return 2
end

-- Contador de beats GLOBAL (no por personaje) -- cada llamada a
-- triggerDanceBeat() representa UN beat real transcurrido; cada personaje
-- decide POR SU CUENTA si le toca actuar en este beat según su propio
-- danceEveryNumBeats (igual que "beat % char.danceEveryNumBeats == 0" en
-- Character.hx/PlayState.hx real). Antes el ENVOLVENTE (afuera, en
-- update()) ya filtraba a "una vez cada gfDanceBeats beats" ANTES de
-- llegar acá, así que esta función nunca se enteraba de los beats
-- intermedios -- ahora se llama UNA VEZ POR BEAT (ver el cambio en
-- update() y en stages/military/stage.lua) y cada personaje filtra acá
-- adentro, independiente.
local danceBeatCounter = 0

-- Extraído del cuerpo de update() (antes vivía inline en el "if
-- musicThres~=oldMusicThres..." de ahí) para poder llamarlo también desde
-- afuera (weeks:triggerDanceBeat(), ver más abajo en el return) -- las
-- cutscenes de intro (p.ej. stages/military/stage.lua) congelan musicTime
-- por completo (_G.cutscenePause, así nadie pierde notas mientras dura la
-- cutscene), así que necesitan su PROPIO reloj de beat independiente para
-- seguir haciendo bailar a bf/gf/enemy -- llaman a esto directo, sin pasar
-- por la condición de musicThres/absMusicTime (que está congelada).
local function triggerDanceBeat()
	danceBeatCounter = danceBeatCounter + 1

	if not customGirlfriendIdle then
		if spriteTimers[1] == 0 then
			-- No interrumpir "sad" (Mom) ni "hairBlow"/"hairFall"
			-- (Philly, tren pasando) si aún están animándose --
			-- mismo patrón que "scared" para enemy/boyfriend más
			-- abajo (lightning strike de Spooky).
			local gfAnim = girlfriend:getAnimName()
			local gfSpecial = gfAnim == "sad" or gfAnim == "hairBlow" or gfAnim == "hairFall"
			-- BUG corregido: a diferencia de enemy/boyfriend más abajo
			-- (que SÍ tienen "isDanceOrIdle(anim) or not isAnimated()"),
			-- girlfriend NUNCA tuvo ese guard genérico -- solo el de
			-- "sad"/"hairBlow"/"hairFall" de arriba. Cualquier semana que
			-- anime a girlfriend con una pose que NO sea esas 3 ni
			-- danceLeft/danceRight/idle (ej. Sserafim: "left"/"right"/
			-- "up"/"down" cuando es su turno de cantar) se veía
			-- interrumpida por este baile automático apenas llegaba el
			-- siguiente beat -- mismo patrón que real (BaseCharacter.hx:
			-- dance() hace "if (isSinging()) return;" antes de bailar).
			local gfBusy = not isDanceOrIdle(gfAnim) and girlfriend:isAnimated()
			-- PlayState.hx real: "beat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0"
			-- -- gfSpeed (gfDanceBeats acá, evento de chart "Set GF Speed")
			-- MULTIPLICA al danceEveryNumBeats automático, no lo reemplaza.
			-- Es la única de las 3 con un evento de chart para esto (no hay
			-- "Set BF/Dad Speed" en Psych vanilla).
			local gfInterval = math.max(1, math.floor((gfDanceBeats or 1) * danceEveryNumBeats(girlfriend) + 0.5))
			if not (gfSpecial and girlfriend:isAnimated()) and not gfBusy and danceBeatCounter % gfInterval == 0 then
				local gfAnims = girlfriend:getAnims()
				if gfAnims["danceLeft"] and gfAnims["danceRight"] then
					gfDanceLeft = not gfDanceLeft
					girlfriend:animate(gfDanceLeft and "danceLeft" or "danceRight", false)
				elseif gfAnims["idle"] then
					girlfriend:animate("idle", false)
					girlfriend:setAnimSpeed(14.4 / (60 / bpm))
				end
				-- Si no tiene "idle" ni danceLeft/danceRight (p.ej.
				-- pico-speaker, que solo tiene shoot*/shoot*-loop),
				-- no tocar nada: no hay con qué "bailar" y forzar
				-- setAnimSpeed encima de su animación real (el loop
				-- de disparo) la dejaría sonando/jugando a velocidad
				-- equivocada.
			end
		end
	end
	if spriteTimers[2] == 0 then
		local enemyAnim = enemy:getAnimName()
		if (isDanceOrIdle(enemyAnim) or not enemy:isAnimated()) and danceBeatCounter % danceEveryNumBeats(enemy) == 0 then
			enemyDanceLeft = danceOrIdle(enemy, enemyDanceLeft)
		end
	end
	if spriteTimers[3] == 0 then
		local bfAnim = boyfriend:getAnimName()
		if (isDanceOrIdle(bfAnim) or not boyfriend:isAnimated()) and danceBeatCounter % danceEveryNumBeats(boyfriend) == 0 then
			boyfriendDanceLeft = danceOrIdle(boyfriend, boyfriendDanceLeft)
		end
	end
end

-- Variables para el evento Highlight (solo fade de HUD, ver setHighlight())
local guiAlphaObj = {value = 1}
local guiAlphaTween = nil
local currentMustHit = false

-- Pool de popups de rating/combo activos (cada uno con su propio sprite de
-- rating + 3 números + velocidad/aceleración + edad/alpha) -- ver
-- spawnRatingPopup() más abajo. Reemplaza el viejo sistema de un solo
-- "rating"/"numbers" reusado (que se comportaba como comboStacking=false,
-- al revés del default real de Psych).
local activeRatingPopups = {}

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
-- spriteLoopTimers[timerID]: un Timer.after por slot (1=girlfriend,
-- 2=enemy, 3=boyfriend) que corta a fuerza una animación en LOOP (notas
-- hold) de vuelta a "idle" una vez transcurrida su duración natural, si
-- para entonces sigue siendo la animación activa. Ver safeAnimate() más
-- abajo -- reemplaza los 3 hackeos viejos hardcodeados por personaje
-- (isTankman/isSonicEXE/isSonicYCR), que además solo cubrían UN nombre de
-- animación exacto cada uno (el de Sonic.exe apuntaba a "left alt", que ni
-- existe en characters/sonic-exe.json -- su única alt es "down alt" --
-- así que nunca se disparaba; y ninguno de los 3 cubría las notas hold SIN
-- alt, ni a ningún otro personaje/mod con el mismo problema).
local spriteLoopTimers = {}
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

    -- "Vanilla" real de Psych: solo en el camino DEFAULT (sin setSplash
    -- activo) y solo en semanas NO pixel -- el splash pixel queda intacto,
    -- a pedido explícito.
    local isVanillaDefault = (not splashLoaderIsCustom) and (not _G.isPixelWeek)

    if isVanillaDefault then
        -- Escala 1/0.7: el sprite ya está armado a partir del atlas REAL de
        -- Psych con scale=1 (noteSplashes-vanilla.json) -- 1/0.7 compensa el
        -- scale(0.7,0.7) global de drawUI() para que el tamaño final en
        -- pantalla coincida con Psych exacto (ver sprites/splash-down.lua).
        sp.sizeX, sp.sizeY = 1 / 0.7, 1 / 0.7

        -- Posición: igual que el splash viejo (sp.x/y = strum.x/y directo,
        -- SIN la resta de swagWidth que usa Psych real). Psych necesita esa
        -- resta porque babyArrow.x en Flixel es la esquina SUPERIOR-IZQUIERDA
        -- del hitbox del strum, no su centro -- acá sprite.x YA es
        -- conceptualmente el centro (ver graphics.lua: el dibujado centra
        -- usando el propio recorte del frame), así que restar swagWidth
        -- duplicaba el desplazamiento y el splash aparecía lejos del strum.
        -- El ajuste fino real de Psych (offset.set(10,10) + offset de la
        -- animación) sigue aplicado más abajo, vía anim.offsetX/Y.
        sp.x = boyfriendArrows[laneIdx].x
        sp.y = boyfriendArrows[laneIdx].y

        -- maxAnims=2 en Psych real (variantes "1"/"2" del atlas vanilla,
        -- elegidas al azar -- NoteSplash.hx: FlxG.random.int(0, maxAnims-1)).
        local anim = love.math.random(2) == 1 and "splash1" or "splash2"
        sp:animate(anim, false)
        -- fps al azar 22-26, igual que Psych (NoteSplash.hx: FlxG.random.int(minFps, maxFps)).
        sp:setAnimSpeed(love.math.random(22, 26))
        -- Tintado RGB por carril (PixelSplashShader real de Psych, ver
        -- modules/splash_shader.lua) -- el sprite es el mismo arte rojo/verde
        -- para los 4 colores, el shader lo recolorea según el carril.
        sp.shader = splashShader.forLane(laneIdx)
    else
        local scale
        if splashLoaderIsCustom then
            -- Splash custom: escala según lo que se indicó en setSplash
            scale = splashCustomIsPixel and NoteSize or 1.5
        else
            -- Splash default pixel: escala según el modo actual de la canción
            scale = _G.isPixelWeek and NoteSize or 1.5
        end
        sp.sizeX, sp.sizeY = scale, scale
        sp.x = boyfriendArrows[laneIdx].x
        sp.y = boyfriendArrows[laneIdx].y
        sp:animate(splashCustomAnim, false)
    end

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
-- NOTA: el sistema "HoldSplash" (cover animado sobre el strum mientras se
-- mantiene un sustain) se eliminó por completo a pedido del usuario
-- (2026-06-19), en ambos modos normal y pixel. Psych Engine real no tiene
-- este efecto -- era una adición propia de Rewritten. Su funcionamiento
-- completo quedó documentado en la memoria del asistente (memoria de
-- proyecto "holdsplash-system-removed") por si se necesita restaurar; los
-- archivos de sprite (sprites/HoldSplash-*.lua y sprites/pixel/HoldSplash-*.lua)
-- y las imágenes "holdCover*" NO se borraron, solo el código que los usaba.

-- Ventanas de tiempo (ms) y tiempo de eliminación de notas -- valores EXACTOS
-- de Psych Engine real (ClientPrefs.hx default: sickWindow=45, goodWindow=90,
-- badWindow=135; Conductor.safeZoneOffset = (10/60)*1000 = 166.666... como
-- límite de "shit"/miss). Antes estos valores no coincidían con Psych en
-- absoluto (ver auditoría de game feel).
local HIT_WINDOW_SICK = 45
local HIT_WINDOW_GOOD = 90
local HIT_WINDOW_BAD = 135

-- Multiplicador de velocidad visual de notas. Real Psych (Note.hx:
-- followStrumNote): distance = 0.45 * deltaTime * songSpeed, ya en píxeles
-- de pantalla finales (FlxG, sin transformación extra). Rewritten dibuja
-- TODO el gameplay/HUD dentro de un push() con scale(0.7,0.7) (drawUI(),
-- más abajo) -- por eso el multiplicador en "unidades locales" (antes de
-- ese 0.7) tiene que ser 0.45/0.7, no 0.45 directo, para que la velocidad
-- en píxeles de PANTALLA real coincida con Psych.
local NOTE_SCROLL_MULT = 0.45 / 0.7
local HIT_WINDOW_SHIT = 166.667
local NOTE_KILL_OFFSET = 300    -- antes 350

-- ============================================
-- POSICIÓN DEL POPUP DE RATING/COMBO (igual que PlayState.hx:popUpScore)
-- ============================================
-- Real Psych: placement = FlxG.width*0.35 (lienzo 1280x720); rating.x =
-- placement-40 (top-left, SIN centrar); rating.y = screenCenter(720,height)-60.
-- El centro REAL del sprite (lo que a nosotros nos importa, porque nuestro
-- .x/.y ya es el centro) es top-left + mitad del tamaño NATIVO del frame --
-- y la altura se cancela algebraicamente: centerY = (720-h)/2 - 60 + h/2 =
-- 300 SIEMPRE, sin importar el rating (sick/good/bad/shit tienen alturas
-- distintas). Igual para los números: numScore.y = (720-h)/2 + 80 (SUMA,
-- no reemplaza) => centerY = (720-h)/2 + 80 + h/2 = 440 SIEMPRE.
-- El ancho NO se cancela (rating.x es fijo sin depender del ancho), así que
-- el centro horizontal sí varía un poco según el ancho de cada frame --
-- igual que en Psych real (no es un bug, es el comportamiento real: cada
-- imagen de rating tiene un ancho nativo distinto). Por eso estas funciones
-- leen el ancho ACTUAL del frame ya animado, en vez de usar una constante.
--
-- localValor = (pantallaValor - centroLienzo) / 0.7 (ver convención usada en
-- toda esta función para timeBar/healthBar).
local RATING_TOPLEFT_X_SCREEN = 1280 * 0.35 - 40   -- 408
local RATING_CENTER_Y_SCREEN = 300
local NUMBERS_TOPLEFT_X_BASE_SCREEN = 1280 * 0.35 - 90  -- 358 (+43 por dígito)
local NUMBERS_CENTER_Y_SCREEN = 440

local RATING_SPAWN_Y = (RATING_CENTER_Y_SCREEN - 360) / 0.7
local NUMBERS_SPAWN_Y = (NUMBERS_CENTER_Y_SCREEN - 360) / 0.7

-- spriteObj debe tener ya su animación actual seteada (:animate(...)) antes
-- de llamar a esto, porque usa el ancho del frame ACTUAL.
--
-- IMPORTANTE: NO multiplicar por spriteObj.sizeX acá -- el "+ancho/2" viene
-- de la derivación de Psych usando el ancho NATIVO del PNG (igual al
-- nuestro, son los mismos assets, confirmado con PIL), y esa derivación ya
-- canceló la escala propia de Psych (su setGraphicSize ocurre DESPUÉS de
-- fijar la posición). El sizeX de nuestro sprite es un factor de TAMAÑO
-- visual aparte (0.75 vs el 0.7 real de Psych, decidido en otra sesión),
-- no debe mezclarse con este cálculo de POSICIÓN.
local function ratingSpawnX(spriteObj)
	local screenCenterX = RATING_TOPLEFT_X_SCREEN + spriteObj:getFrameWidth() / 2
	return (screenCenterX - 640) / 0.7
end

-- loopIdx: 0 = centena, 1 = decena, 2 = unidad (igual que "daLoop" en Psych).
local function numberSpawnX(spriteObj, loopIdx)
	local topLeftScreen = NUMBERS_TOPLEFT_X_BASE_SCREEN + 43 * loopIdx
	local screenCenterX = topLeftScreen + spriteObj:getFrameWidth() / 2
	return (screenCenterX - 640) / 0.7
end

-- Crea un popup de rating/combo INDEPENDIENTE y lo agrega al pool
-- (activeRatingPopups) -- igual que el "new FlxSprite()" por golpe de
-- PlayState.hx:popUpScore real con comboStacking=true (el default, ver
-- ClientPrefs.hx:47): NO reusa ni cancela el popup anterior, así que con
-- combos rápidos se ven varios superpuestos, igual que en Psych real.
-- ratingLoaderFn/numbersLoaderFn/ratingScaleX·Y/numberScaleX·Y se asignan
-- en enter() según el modo (pixel/normal) vigente en ESE momento.
local function spawnRatingPopup(ratingType, comboNum)
	local popup = {
		age = 0,
		fadeDuration = 0.2,
		alpha = 1,
		rating = ratingLoaderFn(),
		numbers = {},
		numVelX = {}, numVelY = {}, numAccelY = {}
	}

	-- Velocidad/aceleración: PlayState.hx real las da en píxeles de PANTALLA
	-- (FlxG, sin transformación extra) -- igual que con NOTE_SCROLL_MULT,
	-- hay que dividir por 0.7 para que, tras el scale(0.7,0.7) de drawUI(),
	-- el movimiento en píxeles de pantalla REAL coincida con Psych. Sin
	-- esto, el popup se movía a la velocidad NUMÉRICA de Psych pero en
	-- unidades locales (más grandes), o sea, mucho más rápido en pantalla
	-- de lo que debía.
	popup.rating.sizeX, popup.rating.sizeY = ratingScaleX, ratingScaleY
	popup.rating:animate(ratingType, false)
	popup.rating.x = ratingSpawnX(popup.rating)
	popup.rating.y = RATING_SPAWN_Y
	popup.velX = -love.math.random(0, 10) / 0.7
	popup.velY = -love.math.random(140, 175) / 0.7
	popup.accelY = 550 / 0.7

	local digits = {
		math.floor(comboNum / 100 % 10),
		math.floor(comboNum / 10 % 10),
		math.floor(comboNum % 10)
	}
	for k = 1, 3 do
		local n = numbersLoaderFn()
		n.sizeX, n.sizeY = numberScaleX, numberScaleY
		n:animate(tostring(digits[k]), false)
		n.x = numberSpawnX(n, k - 1)
		n.y = NUMBERS_SPAWN_Y
		popup.numbers[k] = n
		popup.numVelX[k] = love.math.random(-5, 5) / 0.7
		popup.numVelY[k] = -love.math.random(140, 160) / 0.7
		popup.numAccelY[k] = love.math.random(200, 300) / 0.7
	end

	table.insert(activeRatingPopups, popup)
end

-- Paso entre piezas de sustain ("for k = HOLD_STEP/speed, noteLength,
-- HOLD_STEP/speed"). El "71" original estaba calibrado para el multiplicador
-- de velocidad VIEJO (0.6 local): paso real en píxeles = 71*0.6. Al cambiar
-- NOTE_SCROLL_MULT, ese paso en píxeles creció ~7% sin que el tamaño de cada
-- pieza cambiara, dejando un hueco visible entre piezas (sustain "entrecortado").
-- Se compensa para que el paso en píxeles quede igual que antes.
local HOLD_STEP = 71 * 0.6 / NOTE_SCROLL_MULT

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
			local ratingImgPixel = love.graphics.newImage(graphics.imagePath("pixel/rating"))
			ratingImgPixel:setFilter("nearest", "nearest")
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
				rating       = ratingImgPixel,
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
				rating       = love.graphics.newImage(graphics.imagePath("rating")),
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

		-- Pool de popups de rating/combo (ver spawnRatingPopup) -- igual que
		-- Psych real con comboStacking=true (default, ClientPrefs.hx:47):
		-- cada golpe crea SU PROPIA instancia independiente, no se reusa ni
		-- se cancela la anterior, así que pueden verse varias superpuestas
		-- si se pulsa rápido. Los loaders quedan guardados para que
		-- spawnRatingPopup() cree instancias frescas en el modo correcto.
		-- /0.7: estas escalas se pensaron para dibujarse SIN el scale(0.7,0.7)
		-- extra de drawUI() (antes drawRating() se llamaba desde el stage,
		-- sin ese scale). Al mover el dibujado a drawUI(), sin esta
		-- compensación el resultado final quedaba 0.7x más chico de lo que
		-- debía (igual que con posición/velocidad -- misma conversión,
		-- aplicada a escala esta vez).
		if _G.isPixelWeek then
			ratingLoaderFn = love.filesystem.load("sprites/pixel/rating.lua")
			numbersLoaderFn = love.filesystem.load("sprites/pixel/numbers.lua")
			ratingScaleX, ratingScaleY = NoteSize * 0.75 / 0.7, NoteSize * 0.75 / 0.7
			numberScaleX, numberScaleY = NoteSize * 0.5 / 0.7, NoteSize * 0.5 / 0.7
		else
			ratingLoaderFn = love.filesystem.load("sprites/rating.lua")
			numbersLoaderFn = love.filesystem.load("sprites/numbers.lua")
			ratingScaleX, ratingScaleY = 0.75 / 0.7, 0.75 / 0.7
			numberScaleX, numberScaleY = 0.5 / 0.7, 0.5 / 0.7
		end
		activeRatingPopups = {}

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

		cam.x, cam.y = bfCamTarget()

		activeRatingPopups = {}
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
		-- mod = ratingMod real de Psych Engine (Rating.hx): sick=1, good=0.67,
		-- bad=0.34, shit=0 -- antes estos valores eran más altos (0.8/0.5/0.2),
		-- lo que hacía que el % de accuracy se reportara más alto que en Psych
		-- para los mismos hits exactos.
		self.ratingsData = {
			sick = {hits = 0, score = 350, mod = 1},
			good = {hits = 0, score = 200, mod = 0.67},
			bad = {hits = 0, score = 100, mod = 0.34},
			shit = {hits = 0, score = 50, mod = 0}
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

		if _G.isPixelWeek then
			for i = 1, 4 do
				if middleScroll then
					boyfriendArrows[i].x = -412.5 + 165 * i
					-- Real (PlayState.hx): el oponente NO se oculta en
					-- middlescroll, se superpone cerca del centro con
					-- alpha 0.35 (left/down un casillero a la izquierda
					-- del rango del jugador, up/right uno a la derecha).
					enemyArrows[i].x = (-412.5 + 165 * i) + (i <= 2 and -550 or 550)
					enemyArrows[i].alpha = 0.35
				else
					enemyArrows[i].x = -925 + 165 * i
					boyfriendArrows[i].x = 100 + 165 * i
					enemyArrows[i].alpha = 1
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
				enemyNotes[i] = {}
				boyfriendNotes[i] = {}
			end
		else
			for i = 1, 4 do
				if middleScroll then
					boyfriendArrows[i].x = -412.5 + 165 * i
					enemyArrows[i].x = (-412.5 + 165 * i) + (i <= 2 and -550 or 550)
					enemyArrows[i].alpha = 0.35
				else
					enemyArrows[i].x = -925 + 165 * i
					boyfriendArrows[i].x = 100 + 165 * i
					enemyArrows[i].alpha = 1
				end
				if settings.downscroll then
					enemyArrows[i].y = 375
					boyfriendArrows[i].y = 375
				else
					enemyArrows[i].y = -375
					boyfriendArrows[i].y = -375
				end
				enemyNotes[i] = {}
				boyfriendNotes[i] = {}
			end
		end
		-- Cargar loaders default del modo actual (pixel o normal)
		resetDefaultSplashLoaders()

		-- Alpha FINAL del oponente: 0.35 en middlescroll (superpuesto cerca
		-- del centro, ver initUI() arriba), 1 en modo normal -- el tween/
		-- asignación de entrada de abajo apuntaba siempre a 1 sin importar
		-- middleScroll, pisando el 0.35 ya seteado más arriba.
		local enemyTargetAlpha = middleScroll and 0.35 or 1

		if not skipArrowStartTween then
			-- Nota: Psych real solo anima alpha acá (sin desplazamiento de Y).
			-- Se probó sacar el slide vertical para igualar a Psych al pixel,
			-- pero el resultado se sentía peor -- se restaura el slide de
			-- 20px porque es una mejora visual propia de Rewritten que vale
			-- la pena conservar (caída suave + fade, no solo fade).
			for i = 1, 4 do
				local enemyOriginalY = enemyArrows[i].y
				local boyfriendOriginalY = boyfriendArrows[i].y

				enemyArrows[i].alpha = 0
				enemyArrows[i].y = enemyOriginalY - 20

				boyfriendArrows[i].alpha = 0
				boyfriendArrows[i].y = boyfriendOriginalY - 20

				Timer.after(0.5 + 0.2 * (i-1), function()
					Timer.tween(1, enemyArrows[i], {alpha = enemyTargetAlpha, y = enemyOriginalY}, "out-circ")
					Timer.tween(1, boyfriendArrows[i], {alpha = 1, y = boyfriendOriginalY}, "out-circ")
				end)
			end
		else
			for i = 1, 4 do
				enemyArrows[i].alpha = enemyTargetAlpha
				boyfriendArrows[i].alpha = 1
			end
		end
	end,

	-- Carga un chart desde basePath (sin extensión): si existe basePath..".json"
	-- en formato Psych Engine, lo convierte y aplica sus metadatos
	-- (personajes/stage/eventos); si no, carga basePath..".lua" como siempre
	-- (comportamiento 100% idéntico al actual, sin meta).
	loadChart = function(self, basePath)
		local chart, meta

		-- Cuando se llega desde el editor de charts (test-play), usar el song
		-- en memoria directamente para garantizar que los cambios no guardados
		-- o no reflejados en disco se usen igualmente.
		if _G.chartEditorPreviewSong then
			chart, meta = psychLoader.loadFromData(_G.chartEditorPreviewSong)
			-- No limpiamos aquí para que Restart Song pueda reusar el mismo chart.
			-- Se limpia en pause.lua al hacer "Exit to menu".
		end

		if not chart then
			chart, meta = psychLoader.load(basePath)
		end

		if not chart then
			chart = love.filesystem.load(basePath .. ".lua")()
		end

		self:generateNotes(chart)

		if meta then
			self:applyChartMeta(meta)
		end
	end,

	-- Aplica los metadatos de un chart Psych (player1/player2/gfVersion/stage,
	-- eventos) sobre el estado actual del week. Personajes/stages sin sprite
	-- Lua equivalente generan un warning y se ignoran (ver charts/psych/*).
	applyChartMeta = function(self, meta)
		psychEvents = {}
		for _, ev in ipairs(meta.events or {}) do
			table.insert(psychEvents, ev)
		end

		-- DIAGNÓSTICO TEMPORAL (too-slow): cuenta y lista los nombres de
		-- evento únicos que realmente llegaron a psychEvents -- para saber
		-- si el problema es que el chart no trae los eventos nuevos, o si
		-- los trae pero algo después no los dispara.
		do
			local nameCounts = {}
			for _, ev in ipairs(psychEvents) do
				nameCounts[ev.name] = (nameCounts[ev.name] or 0) + 1
			end
			local parts = {}
			for name, count in pairs(nameCounts) do
				table.insert(parts, name .. "x" .. count)
			end
			print("[DIAG applyChartMeta] psychEvents total=" .. #psychEvents .. " -> " .. table.concat(parts, ", "))
		end

		local bfChanged, gfChanged = false, false

		-- BUG corregido: loadStage() (stage.load()) corre ANTES que esto
		-- (ver weeks/sserafim.lua:enter() -- self:loadStage(...) antes de
		-- self:load()/initUI()/loadChart()) -- así que cualquier cosa que
		-- un stage le asigne a boyfriend/girlfriend/enemy en su PROPIO
		-- M.load() (p.ej. stages/sserafim/stage.lua asignando
		-- characterShader) se le asigna al sprite VIEJO (de la semana/
		-- canción anterior, o nil) -- loadInto() de acá ABAJO crea un
		-- sprite COMPLETAMENTE NUEVO, que nunca recibe esa asignación.
		-- Resultado: si el sprite previo en _G.boyfriend/girlfriend/enemy
		-- daba "truthy" justo cuando el stage corrió su asignación, esa
		-- asignación se pierde silenciosamente -- y como depende de qué
		-- había ahí antes de entrar a la canción (replay, semana
		-- anterior, primera vez, etc.) el resultado visual ("a quién le
		-- aplicó el shader") parece aleatorio entre partidas. Hook opt-in
		-- (mismo patrón que customNoteHit/customEnemyNoteHit) para que el
		-- stage pueda re-aplicar lo que necesite DESPUÉS de que el sprite
		-- real ya esté en su lugar.
		if meta.player1 then
			local ok, entry = psychCharacters.loadInto("boyfriend", meta.player1)
			if ok then
				bfChanged = true
				local iconName = healthIconNameFor(boyfriend, entry.icon)
				if iconName and boyfriendIcon then icons.animate(boyfriendIcon, iconName, false) end
				if _G.currentWeek and _G.currentWeek.onCharacterReload then
					_G.currentWeek:onCharacterReload("boyfriend", boyfriend)
				end
			end
		end

		if meta.player2 then
			local ok, entry = psychCharacters.loadInto("enemy", meta.player2)
			if ok then
				local iconName = healthIconNameFor(enemy, entry.icon)
				if iconName and enemyIcon then
					icons.animate(enemyIcon, iconName, false)
				end
				if _G.currentWeek and _G.currentWeek.onCharacterReload then
					_G.currentWeek:onCharacterReload("enemy", enemy)
				end
			end
		end

		if meta.gfVersion then
			if psychCharacters.loadInto("girlfriend", meta.gfVersion) then
				gfChanged = true
				if _G.currentWeek and _G.currentWeek.onCharacterReload then
					_G.currentWeek:onCharacterReload("girlfriend", girlfriend)
				end
			end
		end

		-- Muchos charts (la mayoría de semana 1-6, no solo "monster"/"south"
		-- de Skid & Pump) NO declaran "stage" en sus metadatos -- antes,
		-- sin meta.stage, esta línea nunca se ejecutaba, así que
		-- psychStages.apply() (que necesita que el personaje YA esté
		-- cargado para leer sprite._slotConversionX/Y y sprite._charOffsetX/Y
		-- correctamente, ver charts/psych/stages.lua) nunca se volvía a
		-- llamar DESPUÉS de loadInto() -- loadStage() ya lo había llamado
		-- antes, pero en ese momento el personaje real (p.ej. "spooky")
		-- todavía no existía, así que esa primera llamada no podía
		-- posicionarlo. Resultado: cualquier personaje con position/offset
		-- propio no nulo (Skid & Pump, pico-speaker, etc.) quedaba sin la
		-- posición real del slot del stage sumada -- "descolocado". Usar
		-- el id del stage YA activo (psychStages.getCurrentId(), puesto
		-- por loadStage() al principio) en vez de exigir meta.stage
		-- arregla esto para TODOS los charts, no solo los que declaran
		-- "stage" explícitamente.
		local stageToApply = meta.stage or psychStages.getCurrentId()
		if stageToApply and psychStages.apply(stageToApply) then
			bfChanged = true
			gfChanged = true
		end

		if bfChanged then
			cam.x, cam.y = bfCamTarget()
		end
		-- El popup de rating/combo ya no depende de girlfriend.x (ver
		-- ratingSpawnX/numberSpawnX) -- antes acá se reanclaba al cambiar
		-- de girlfriend, ya no aplica.
	end,

	generateNotes = function(self, chart)
		local eventBpm
		local tiempo_acumulado = 0
		local bpm_anterior = nil

		psychEvents = {}

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

			-- Evento de cambio de sección: SIEMPRE uno por sección (con o sin
			-- notas), anclado a sectionStartTime (tiempo_acumulado al inicio
			-- de esta sección). Así mustHitSection/altAnim/bpm se aplican en
			-- el momento correcto aunque la sección no tenga notas, igual que
			-- PlayState.hx de Psych (basado en sectionLength, no en notas).
			table.insert(events, {
				eventTime = tiempo_acumulado,
				mustHitSection = seccion.mustHitSection or false,
				bpm = eventBpm,
				altAnim = seccion.altAnim or false
			})
			bpm_anterior = bpm_activo

			for j = 1, #seccion.sectionNotes do
				local sprite

				local mustHitSection = seccion.mustHitSection
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
							newNote.gfNote = seccion.sectionNotes[j].gfNote or false
								newNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
								newNote.noAnimation = (newNote.noteTypeStr == "No Animation")
								newNote.isMine = (newNote.noteTypeStr == "Hurt Note")
								if newNote.noteTypeStr and not BUILTIN_NOTE_TYPES[newNote.noteTypeStr] then
									psychNoteTypes.apply(newNote, newNote.noteTypeStr)
								end
							enemyNotes[id][c].x = x
							enemyNotes[id][c].y = 375 - noteTime * NOTE_SCROLL_MULT * speed
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
								local susLength = seccion.sectionNotes[j].noteLength
								local stepSize = HOLD_STEP / speed
								local numSteps = math.floor(susLength / stepSize + 0.5)
								if numSteps >= 1 then stepSize = susLength / numSteps end
								for stepIdx = 1, numSteps do
									local k = stepIdx * stepSize
									local c = #enemyNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									-- BUG corregido: las piezas hold/end NUNCA heredaban
									-- noteTypeStr de la nota cabeza -- stages/sserafim/
									-- stage.lua:customNoteHold() (y cualquier otro hook
									-- basado en noteTypeStr) recibía siempre nil acá,
									-- perdiendo el "kind" (sakura-joint/bf1/bf2) durante
									-- TODO el sostenido de la nota, no solo en el golpe.
									newHoldNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
									table.insert(enemyNotes[id], newHoldNote)
									enemyNotes[id][c].x = x
									enemyNotes[id][c].y = 375 - (noteTime + k) * NOTE_SCROLL_MULT * speed
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
							newNote.gfNote = seccion.sectionNotes[j].gfNote or false
								newNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
								newNote.noAnimation = (newNote.noteTypeStr == "No Animation")
								newNote.isMine = (newNote.noteTypeStr == "Hurt Note")
								if newNote.noteTypeStr and not BUILTIN_NOTE_TYPES[newNote.noteTypeStr] then
									psychNoteTypes.apply(newNote, newNote.noteTypeStr)
								end
							boyfriendNotes[id][c].x = x
							boyfriendNotes[id][c].y = 375 - noteTime * NOTE_SCROLL_MULT * speed
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
								local susLength = seccion.sectionNotes[j].noteLength
								local stepSize = HOLD_STEP / speed
								local numSteps = math.floor(susLength / stepSize + 0.5)
								if numSteps >= 1 then stepSize = susLength / numSteps end
								for stepIdx = 1, numSteps do
									local k = stepIdx * stepSize
									local c = #boyfriendNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									-- BUG corregido: las piezas hold/end NUNCA heredaban
									-- noteTypeStr de la nota cabeza -- stages/sserafim/
									-- stage.lua:customNoteHold() (y cualquier otro hook
									-- basado en noteTypeStr) recibía siempre nil acá,
									-- perdiendo el "kind" (sakura-joint/bf1/bf2) durante
									-- TODO el sostenido de la nota, no solo en el golpe.
									newHoldNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
									table.insert(boyfriendNotes[id], newHoldNote)
									boyfriendNotes[id][c].x = x
									boyfriendNotes[id][c].y = 375 - (noteTime + k) * NOTE_SCROLL_MULT * speed
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
							local c = #enemyNotes[id] + 1
							local x = enemyArrows[id].x

							local newNote = sprite()
							newNote.sizeX, newNote.sizeY = noteScale, noteScale
							newNote.noteKind = noteKind
							table.insert(enemyNotes[id], newNote)
							newNote.gfNote = seccion.sectionNotes[j].gfNote or false
								newNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
								newNote.noAnimation = (newNote.noteTypeStr == "No Animation")
								newNote.isMine = (newNote.noteTypeStr == "Hurt Note")
								if newNote.noteTypeStr and not BUILTIN_NOTE_TYPES[newNote.noteTypeStr] then
									psychNoteTypes.apply(newNote, newNote.noteTypeStr)
								end
							enemyNotes[id][c].x = x
							enemyNotes[id][c].y = 375 - noteTime * NOTE_SCROLL_MULT * speed
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
								local susLength = seccion.sectionNotes[j].noteLength
								local stepSize = HOLD_STEP / speed
								local numSteps = math.floor(susLength / stepSize + 0.5)
								if numSteps >= 1 then stepSize = susLength / numSteps end
								for stepIdx = 1, numSteps do
									local k = stepIdx * stepSize
									local c = #enemyNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									-- BUG corregido: las piezas hold/end NUNCA heredaban
									-- noteTypeStr de la nota cabeza -- stages/sserafim/
									-- stage.lua:customNoteHold() (y cualquier otro hook
									-- basado en noteTypeStr) recibía siempre nil acá,
									-- perdiendo el "kind" (sakura-joint/bf1/bf2) durante
									-- TODO el sostenido de la nota, no solo en el golpe.
									newHoldNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
									table.insert(enemyNotes[id], newHoldNote)
									enemyNotes[id][c].x = x
									enemyNotes[id][c].y = 375 - (noteTime + k) * NOTE_SCROLL_MULT * speed
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
						else
							local id = noteType + 1
							local c = #boyfriendNotes[id] + 1
							local x = boyfriendArrows[id].x

							local newNote = sprite()
							newNote.sizeX, newNote.sizeY = noteScale, noteScale
							newNote.noteKind = noteKind
							table.insert(boyfriendNotes[id], newNote)
							newNote.gfNote = seccion.sectionNotes[j].gfNote or false
								newNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
								newNote.noAnimation = (newNote.noteTypeStr == "No Animation")
								newNote.isMine = (newNote.noteTypeStr == "Hurt Note")
								if newNote.noteTypeStr and not BUILTIN_NOTE_TYPES[newNote.noteTypeStr] then
									psychNoteTypes.apply(newNote, newNote.noteTypeStr)
								end
							boyfriendNotes[id][c].x = x
							boyfriendNotes[id][c].y = 375 - noteTime * NOTE_SCROLL_MULT * speed
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
								local susLength = seccion.sectionNotes[j].noteLength
								local stepSize = HOLD_STEP / speed
								local numSteps = math.floor(susLength / stepSize + 0.5)
								if numSteps >= 1 then stepSize = susLength / numSteps end
								for stepIdx = 1, numSteps do
									local k = stepIdx * stepSize
									local c = #boyfriendNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									-- BUG corregido: las piezas hold/end NUNCA heredaban
									-- noteTypeStr de la nota cabeza -- stages/sserafim/
									-- stage.lua:customNoteHold() (y cualquier otro hook
									-- basado en noteTypeStr) recibía siempre nil acá,
									-- perdiendo el "kind" (sakura-joint/bf1/bf2) durante
									-- TODO el sostenido de la nota, no solo en el golpe.
									newHoldNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
									table.insert(boyfriendNotes[id], newHoldNote)
									boyfriendNotes[id][c].x = x
									boyfriendNotes[id][c].y = 375 - (noteTime + k) * NOTE_SCROLL_MULT * speed
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
							newNote.gfNote = seccion.sectionNotes[j].gfNote or false
								newNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
								newNote.noAnimation = (newNote.noteTypeStr == "No Animation")
								newNote.isMine = (newNote.noteTypeStr == "Hurt Note")
								if newNote.noteTypeStr and not BUILTIN_NOTE_TYPES[newNote.noteTypeStr] then
									psychNoteTypes.apply(newNote, newNote.noteTypeStr)
								end
							enemyNotes[id][c].x = x
							enemyNotes[id][c].y = -375 + noteTime * NOTE_SCROLL_MULT * speed
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
								local susLength = seccion.sectionNotes[j].noteLength
								local stepSize = HOLD_STEP / speed
								local numSteps = math.floor(susLength / stepSize + 0.5)
								if numSteps >= 1 then stepSize = susLength / numSteps end
								for stepIdx = 1, numSteps do
									local k = stepIdx * stepSize
									local c = #enemyNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									-- BUG corregido: las piezas hold/end NUNCA heredaban
									-- noteTypeStr de la nota cabeza -- stages/sserafim/
									-- stage.lua:customNoteHold() (y cualquier otro hook
									-- basado en noteTypeStr) recibía siempre nil acá,
									-- perdiendo el "kind" (sakura-joint/bf1/bf2) durante
									-- TODO el sostenido de la nota, no solo en el golpe.
									newHoldNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
									table.insert(enemyNotes[id], newHoldNote)
									enemyNotes[id][c].x = x
									enemyNotes[id][c].y = -375 + (noteTime + k) * NOTE_SCROLL_MULT * speed
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
							newNote.gfNote = seccion.sectionNotes[j].gfNote or false
								newNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
								newNote.noAnimation = (newNote.noteTypeStr == "No Animation")
								newNote.isMine = (newNote.noteTypeStr == "Hurt Note")
								if newNote.noteTypeStr and not BUILTIN_NOTE_TYPES[newNote.noteTypeStr] then
									psychNoteTypes.apply(newNote, newNote.noteTypeStr)
								end
							boyfriendNotes[id][c].x = x
							boyfriendNotes[id][c].y = -375 + noteTime * NOTE_SCROLL_MULT * speed
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
								local susLength = seccion.sectionNotes[j].noteLength
								local stepSize = HOLD_STEP / speed
								local numSteps = math.floor(susLength / stepSize + 0.5)
								if numSteps >= 1 then stepSize = susLength / numSteps end
								for stepIdx = 1, numSteps do
									local k = stepIdx * stepSize
									local c = #boyfriendNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									-- BUG corregido: las piezas hold/end NUNCA heredaban
									-- noteTypeStr de la nota cabeza -- stages/sserafim/
									-- stage.lua:customNoteHold() (y cualquier otro hook
									-- basado en noteTypeStr) recibía siempre nil acá,
									-- perdiendo el "kind" (sakura-joint/bf1/bf2) durante
									-- TODO el sostenido de la nota, no solo en el golpe.
									newHoldNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
									table.insert(boyfriendNotes[id], newHoldNote)
									boyfriendNotes[id][c].x = x
									boyfriendNotes[id][c].y = -375 + (noteTime + k) * NOTE_SCROLL_MULT * speed
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
							local c = #enemyNotes[id] + 1
							local x = enemyArrows[id].x

							local newNote = sprite()
							newNote.sizeX, newNote.sizeY = noteScale, noteScale
							newNote.noteKind = noteKind
							table.insert(enemyNotes[id], newNote)
							newNote.gfNote = seccion.sectionNotes[j].gfNote or false
								newNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
								newNote.noAnimation = (newNote.noteTypeStr == "No Animation")
								newNote.isMine = (newNote.noteTypeStr == "Hurt Note")
								if newNote.noteTypeStr and not BUILTIN_NOTE_TYPES[newNote.noteTypeStr] then
									psychNoteTypes.apply(newNote, newNote.noteTypeStr)
								end
							enemyNotes[id][c].x = x
							enemyNotes[id][c].y = -375 + noteTime * NOTE_SCROLL_MULT * speed
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
								local susLength = seccion.sectionNotes[j].noteLength
								local stepSize = HOLD_STEP / speed
								local numSteps = math.floor(susLength / stepSize + 0.5)
								if numSteps >= 1 then stepSize = susLength / numSteps end
								for stepIdx = 1, numSteps do
									local k = stepIdx * stepSize
									local c = #enemyNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									-- BUG corregido: las piezas hold/end NUNCA heredaban
									-- noteTypeStr de la nota cabeza -- stages/sserafim/
									-- stage.lua:customNoteHold() (y cualquier otro hook
									-- basado en noteTypeStr) recibía siempre nil acá,
									-- perdiendo el "kind" (sakura-joint/bf1/bf2) durante
									-- TODO el sostenido de la nota, no solo en el golpe.
									newHoldNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
									table.insert(enemyNotes[id], newHoldNote)
									enemyNotes[id][c].x = x
									enemyNotes[id][c].y = -375 + (noteTime + k) * NOTE_SCROLL_MULT * speed
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
							newNote.gfNote = seccion.sectionNotes[j].gfNote or false
								newNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
								newNote.noAnimation = (newNote.noteTypeStr == "No Animation")
								newNote.isMine = (newNote.noteTypeStr == "Hurt Note")
								if newNote.noteTypeStr and not BUILTIN_NOTE_TYPES[newNote.noteTypeStr] then
									psychNoteTypes.apply(newNote, newNote.noteTypeStr)
								end
							boyfriendNotes[id][c].x = x
							boyfriendNotes[id][c].y = -375 + noteTime * NOTE_SCROLL_MULT * speed
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
								local susLength = seccion.sectionNotes[j].noteLength
								local stepSize = HOLD_STEP / speed
								local numSteps = math.floor(susLength / stepSize + 0.5)
								if numSteps >= 1 then stepSize = susLength / numSteps end
								for stepIdx = 1, numSteps do
									local k = stepIdx * stepSize
									local c = #boyfriendNotes[id] + 1
									local newHoldNote = sprite()
									newHoldNote.sizeX, newHoldNote.sizeY = noteScale, noteScale
									newHoldNote.noteKind = noteKind
									-- BUG corregido: las piezas hold/end NUNCA heredaban
									-- noteTypeStr de la nota cabeza -- stages/sserafim/
									-- stage.lua:customNoteHold() (y cualquier otro hook
									-- basado en noteTypeStr) recibía siempre nil acá,
									-- perdiendo el "kind" (sakura-joint/bf1/bf2) durante
									-- TODO el sostenido de la nota, no solo en el golpe.
									newHoldNote.noteTypeStr = seccion.sectionNotes[j].noteTypeStr
									table.insert(boyfriendNotes[id], newHoldNote)
									boyfriendNotes[id][c].x = x
									boyfriendNotes[id][c].y = -375 + (noteTime + k) * NOTE_SCROLL_MULT * speed
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
								-- upscroll: sizeY queda positivo (igual que los otros bloques upscroll)
								boyfriendNotes[id][c]:animate("end", false)
								boyfriendNotes[id][c].altNote = seccion.sectionNotes[j].altNote or false 
								boyfriendNotes[id][c].isHoldStart = false
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

		-- Una animación en LOOP (notas hold) nunca se corta sola -- si
		-- después del último frame de hold no llega ninguna nota nueva
		-- (corte de sección, último hold de la canción, etc.), el
		-- personaje se queda animando ese frame en bucle indefinidamente
		-- hasta que el countdown genérico de abajo (12 beats) lo libere.
		-- Programamos un corte a fuerza de vuelta a "idle" una sola vez
		-- transcurrida la duración NATURAL del clip -- si llega una nota
		-- nueva antes (otro safeAnimate la cancela y reprograma), no pasa
		-- nada; si la animación ya cambió por otro lado para entonces,
		-- tampoco (el chequeo getAnimName()==animName lo evita).
		if loopAnim then
			local animDef = sprite.anims and sprite.anims[animName]
			if animDef and animDef.speed and animDef.speed > 0 then
				local duration = (animDef.stop - animDef.start + 1) / animDef.speed
				if spriteLoopTimers[timerID] then Timer.cancel(spriteLoopTimers[timerID]) end
				spriteLoopTimers[timerID] = Timer.after(duration, function()
					spriteLoopTimers[timerID] = nil
					if sprite:getAnimName() == animName then
						sprite:animate("idle", false)
					end
				end)
			end
		end

		spriteTimers[timerID] = 12
	end,

    update = function(self, dt)
            -- _G.cutscenePause (cutscenes de intro de historia, p.ej.
            -- stages/military/stage.lua): congela TODO -- musicTime no
            -- avanza ni con el reloj real (la rama "else" de abajo lo
            -- hace incluso con countingDown=false, que es exactamente el
            -- estado durante una cutscene -- sin este freeze, el chart
            -- "arranca solo" en segundo plano mientras la cutscene corre,
            -- y bf puede morir por notas falladas que nunca debieron
            -- existir todavía).
            if _G.cutscenePause then return end

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

					musicTime = musicTime + (time * 1000) - (previousFrameTime or time * 1000)
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

            for i = 1, #(events or {}) do
                if events[i].eventTime <= absMusicTime then
                    local oldBpm = bpm

                    if events[i].bpm then
                        bpm = events[i].bpm
						self.bpm = bpm
                        if not bpm then bpm = oldBpm end
                    end

					-- BUG real (bamboleo de cámara al soltar el shake, ronda
					-- anterior): currentMustHit solo se actualizaba acá
					-- DENTRO del "if not _G.disableAutoCam" -- si un cambio
					-- de sección caía justo durante el shake (disableAutoCam
					-- en true por entonces), el evento se consumía
					-- (table.remove más abajo) pero currentMustHit quedaba
					-- desactualizado para SIEMPRE (el evento ya no está en
					-- la lista para reintentarlo). Ahora currentMustHit se
					-- actualiza SIEMPRE (nunca queda obsoleto); solo la
					-- creación/cancelación del camTimer se sigue salteando
					-- mientras está desactivada la cámara automática.
					-- (Highlight ya no entra en este problema: ya no toca la
					-- cámara para nada, ver setHighlight() más abajo.)
					currentMustHit = events[i].mustHitSection or false
					-- Expuesto en la tabla compartida `weeks` (global) para
					-- que stages/*/stage.lua puedan leer de quién es el
					-- turno sin acceso directo a este local -- ningún otro
					-- stage lo necesitó hasta Weekend1 (A-Bot mirando a
					-- quien canta).
					weeks.currentMustHit = currentMustHit
					if not _G.disableAutoCam then
						if camTimer then
							Timer.cancel(camTimer)
						end
						if currentMustHit then
							local tx, ty = bfCamTarget()
							camTimer = Timer.tween(1.25, cam, {x = tx, y = ty}, "out-quad")
						else
							local tx, ty = enemyCamTarget()
							camTimer = Timer.tween(1.25, cam, {x = tx, y = ty}, "out-quad")
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
						-- Highlight: SOLO oculta el HUD/GUI (fade de guiAlphaObj).
						-- Ya NO toca la cámara para nada -- antes tweemeaba
						-- cam.x/y hacia bf/enemy y suspendía el auto-cam
						-- (highlightActive) mientras durase, lo que competía
						-- con el seguimiento normal y causaba bamboleo al
						-- soltar. A pedido: el evento queda reducido a
						-- activar/desactivar la HUD nomás.
						if guiAlphaTween then Timer.cancel(guiAlphaTween) end
						guiAlphaTween = Timer.tween(0.5, guiAlphaObj, {value = 0}, "linear", function() guiAlphaTween = nil end)
						table.remove(cameraEvents, i)
					elseif ev.type == "HighlightOff" then
						if guiAlphaTween then Timer.cancel(guiAlphaTween) end
						guiAlphaTween = Timer.tween(0.5, guiAlphaObj, {value = 1}, "linear", function() guiAlphaTween = nil end)
						table.remove(cameraEvents, i)
						-- No se eliminan eventos de tipo desconocido
					end
				end
			end

			-- Eventos de chart Psych (Hey!, Play Animation, Change Character, ...)
			for i = #psychEvents, 1, -1 do
				if musicTime >= psychEvents[i].time then
					psychEventDispatcher.trigger(psychEvents[i])
					table.remove(psychEvents, i)
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

			-- Decaimiento del empuje de "Add Camera Zoom" hacia 0 (vuelve solo a
			-- camScale, igual que el lerp hacia defaultCamZoom de Psych)
			local zoomDecay = math.exp(-dt * 3.125)
			camZoomBump.x = camZoomBump.x * zoomDecay
			camZoomBump.y = camZoomBump.y * zoomDecay

			-- Aplicar el pulso y el empuje de zoom a la cámara -- gateado por
			-- disableAutoCam igual que el tween de posición: sin esto, una
			-- cutscene que anima cam.sizeX/Y a mano (p.ej. la scary intro de
			-- Winter Horrorland) queda compitiendo cada frame contra este
			-- pulso, que además sigue calculándose con el bpm/absMusicTime
			-- de la canción ANTERIOR (la nueva todavía no cargó su chart).
			if not _G.disableAutoCam then
				cam.sizeX = (camScale.x + camZoomBump.x) * beatPulse
				cam.sizeY = (camScale.y + camZoomBump.y) * beatPulse
			end

			-- Mantener el tween de cámara activo cada frame para que siempre apunte
			-- al personaje correcto (necesario cuando los personajes cambian de posición,
			-- como en you-cant-run al cambiar de personaje).
			-- El cancel+recreate cada frame es intencional: garantiza seguimiento inmediato.
			-- Highlight ya NO suspende esto (ver setHighlight() más abajo) --
			-- el auto-cam corre siempre, Highlight solo afecta al HUD.
			if not _G.disableAutoCam then
				if camTimer then Timer.cancel(camTimer) end
				local tx, ty
				if currentMustHit then
					tx, ty = bfCamTarget()
				else
					tx, ty = enemyCamTarget()
				end
				camTimer = Timer.tween(1.25, cam, {x = tx, y = ty}, "out-quad")
			end

            girlfriend:update(dt)
            enemy:update(dt)
            boyfriend:update(dt)
			spoopyscare.update(dt)
			jumpscare.update(dt)

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

			-- Antes filtraba acá afuera con "*gfDanceBeats" (un solo
			-- divisor para los 3 personajes). Ahora se llama CADA beat
			-- real -- triggerDanceBeat() filtra adentro, por personaje,
			-- según si cada uno tiene danceLeft/danceRight (ver su
			-- definición más arriba).
			if musicThres ~= oldMusicThres and math.fmod(absMusicTime, (60000 / bpm)) < 100 then
				triggerDanceBeat()
			end

			for i = 1, 3 do
				local spriteTimer = spriteTimers[i]
				if spriteTimer and spriteTimer > 0 then
					spriteTimers[i] = spriteTimer - 1
				end
			end
    end,

	updateUI = function(self, dt)
		-- _G.cutscenePause: congela ESTO también, no solo update(). musicPos
		-- se recalcula acá mismo a partir de musicTime en CADA llamada --
		-- aunque musicTime esté congelado por update(), si su valor
		-- congelado ya alcanza/pasa el tiempo de la primera nota del chart
		-- (p.ej. una nota en t≈0 y musicTime congelado en ≈0), el chequeo
		-- de "¿la nota ya pasó la línea?" de más abajo se cumple UNA VEZ,
		-- en el primer frame congelado, y dispara la animación de esa nota
		-- (enemy cantando) mucho antes de que la cutscene o el resto del
		-- chart arranquen. Sin este freeze, congelar solo update() no
		-- alcanza.
		if _G.cutscenePause then return end

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
			musicPos = -musicTime * NOTE_SCROLL_MULT * speed
		else
			musicPos = musicTime * NOTE_SCROLL_MULT * speed
		end

		-- Movimiento físico de cada popup de rating/combo activo (igual que
		-- FlxSprite.velocity/acceleration en PlayState.hx:popUpScore real --
		-- un "pop" hacia arriba que cae por gravedad, no un tween de
		-- posición). Integración simple de Euler, igual de válida que la de
		-- Flixel para este uso (un par de décimas de segundo de animación).
		-- Recorrido hacia atrás porque table.remove() durante el loop.
		for i = #activeRatingPopups, 1, -1 do
			local p = activeRatingPopups[i]
			p.age = p.age + dt
			if p.age >= p.fadeDuration then
				table.remove(activeRatingPopups, i)
			else
				p.alpha = 1 - (p.age / p.fadeDuration)

				p.velY = p.velY + p.accelY * dt
				p.rating.x = p.rating.x + p.velX * dt
				p.rating.y = p.rating.y + p.velY * dt
				for k = 1, 3 do
					p.numVelY[k] = p.numVelY[k] + p.numAccelY[k] * dt
					p.numbers[k].x = p.numbers[k].x + p.numVelX[k] * dt
					p.numbers[k].y = p.numbers[k].y + p.numVelY[k] * dt
				end
			end
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
						-- Nota hold intermedia
						--
						-- BUG corregido: antes esto solo (re)disparaba
						-- safeAnimate() si el personaje YA estaba en "idle"
						-- (o sin animar) -- una vez el primer segmento lo
						-- ponía a cantar en loop, ese gate quedaba
						-- permanentemente en falso (nunca vuelve a "idle"
						-- por sí solo estando en loop) y el temporizador de
						-- "volver a idle" de safeAnimate() (armado por ESE
						-- primer segmento, nunca cancelado/reprogramado por
						-- los siguientes porque el gate les impedía
						-- llamarla) terminaba disparando A MITAD del hold,
						-- sacando al personaje de la animación sin que
						-- nada lo retomara hasta el siguiente segmento --
						-- visualmente "se queda tieso en idle". El real
						-- (y Psych) simplemente re-disparan la animación
						-- en CADA segmento sin condición -- ahora es seguro
						-- hacer lo mismo acá (animate()/safeAnimate() ya no
						-- reinicia el frame si la animación no cambió).
						if shouldUseAlt then
							self:safeAnimate(enemy, curAnim .. " alt", true, 2)
						else
							self:safeAnimate(enemy, curAnim, true, 2)
						end
					elseif animName == "end" then
						-- Última nota del hold -- mismo criterio que arriba.
						if shouldUseAlt then
							self:safeAnimate(enemy, curAnim .. " alt", true, 2)
						else
							self:safeAnimate(enemy, curAnim, true, 2)
						end
					else
						-- Nota "on" (inicio)
						-- Hook genérico lado-oponente (mismo patrón que customNoteHit
						-- del lado boyfriend, ver más abajo) -- Weekend 1/PhillyStreets
						-- lo usa para "weekend-1-lightcan"/"kickcan"/"kneecan"
						-- (PlayState.hx real: opponentNoteHit()).
						local handledEnemy = false
						if _G.currentWeek and _G.currentWeek.customEnemyNoteHit then
							handledEnemy = _G.currentWeek:customEnemyNoteHit(curAnim, enemyNote[1], enemy)
						end

						-- Blazin fight: interceptar notas con noteKind (mecanismo viejo,
						-- se mantiene por compatibilidad -- noteKind no lo puebla
						-- ningún chart actual, customEnemyNoteHit lo reemplaza).
						if not handledEnemy and enemyNote[1].noteKind and _G.currentWeek and _G.currentWeek.onEnemyNoteHit then
							_G.currentWeek.onEnemyNoteHit(enemyNote[1].noteKind)
						elseif not handledEnemy and not enemyNote[1].noAnimation then
							if shouldUseAlt then
								self:safeAnimate(enemy, curAnim .. " alt", false, 2)
							else
								self:safeAnimate(enemy, curAnim, false, 2)
							end
						end
					end

					if enemyNote[1].gfNote then
						self:safeAnimate(girlfriend, curAnim, false, 1)
					end

					-- Tipo de nota "Hey!" en una nota del oponente: el propio
					-- oponente reacciona con su animación "hey" (PlayState.hx
					-- opponentNoteHit) -- distinto del evento de chart "Hey!",
					-- que es un mecanismo aparte y siempre afecta a bf/gf.
					if enemyNote[1].noteTypeStr == "Hey!" and enemy:getAnims()["hey"] then
						enemy:animate("hey", false)
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

										spawnRatingPopup(ratingType, combo)

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
									if not handled and not currentNote.noAnimation then
										self:safeAnimate(boyfriend, animToPlay, false, 3)
									end

									if currentNote.gfNote then
										self:safeAnimate(girlfriend, curAnim, false, 1)
									end

									-- Tipo de nota "Hey!": el propio boyfriend reacciona con su
									-- animación "hey" (PlayState.hx noteHit) -- distinto del
									-- evento de chart "Hey!", que es un mecanismo aparte.
									if currentNote.noteTypeStr == "Hey!" and boyfriend:getAnims()["hey"] then
										boyfriend:animate("hey", false)
									end

									note.hit = true
									table.remove(boyfriendNote, j)

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
					removedNote.hit = true
					table.remove(boyfriendNote, 1)

					boyfriendArrow:animate("confirm", false)

					local handledHold = false
					if _G.currentWeek and _G.currentWeek.customNoteHold then
						handledHold = _G.currentWeek:customNoteHold(curAnim, removedNote, boyfriend)
					end
					if not handledHold then
						-- BUG corregido: el gate "solo si está en idle"
						-- quedaba permanentemente bloqueado una vez el
						-- primer segmento del hold lo ponía a cantar en
						-- loop (nunca vuelve a "idle" solo estando en
						-- loop), así que el temporizador de "volver a
						-- idle" de safeAnimate() -- armado por ese primer
						-- segmento y nunca reprogramado por los
						-- siguientes, porque el gate les impedía llamarla
						-- -- terminaba disparando A MITAD del hold y
						-- nada lo retomaba hasta des-idle-arse de nuevo.
						-- El real (y Psych) re-disparan sin condición en
						-- cada segmento -- ahora es seguro hacer lo mismo
						-- (animate() ya no reinicia el frame si la
						-- animación no cambió).
						self:safeAnimate(boyfriend, curAnim, true, 3)
					end

					-- Lógica de grupo para holds
					if removedNote.holdGroupId then
						local group = holdGroupsInfo[removedNote.holdGroupId]
						if group and not group.missed and not group.completed then
							group.hitCount = group.hitCount + 1
							if group.hitCount == group.totalNotes then
								-- Nota larga completada manteniendo presionado → siempre sick
								group.completed = true
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
								spawnRatingPopup(ratingType, combo)

								health = health + 1
							end
						end
					else
						-- Nota de hold sin grupo (no debería ocurrir, pero por seguridad)
						health = health + 1
					end
				end

				-- Al soltar la tecla: Psych real no hace nada especial acá más
				-- que volver la flecha a "off" (PlayState.hx: keyReleased()) --
				-- no hay rating/score/combo/health bonus por soltar. Antes
				-- esto otorgaba una nota "fantasma" extra (rating según qué
				-- tan temprano se soltó, con su propio popup/combo/vida),
				-- algo que Psych no tiene. Las piezas del sustain que queden
				-- sin tocar simplemente van a fallar solas por el camino
				-- normal de "nota no tocada a tiempo" (más abajo, NOTE_KILL_OFFSET),
				-- igual que en Psych.
				if input:released(curInput) then
					boyfriendArrow:animate("off", false)
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
							if not handled and not note.noAnimation then
								self:safeAnimate(boyfriend, animToPlay, false, 3)
							end

							if note.gfNote then
								self:safeAnimate(girlfriend, curAnim, false, 1)
							end

							if note.noteTypeStr == "Hey!" and boyfriend:getAnims()["hey"] then
								boyfriend:animate("hey", false)
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
											spawnRatingPopup("sick", combo)

											health = health + 1
											botHolding[i] = false
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

								spawnRatingPopup("sick", combo)

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

		-- BUG corregido: las notas del enemy SOLO se eliminaban por
		-- posición (boyfriendNote[1].y - musicPos <= -375 dentro del bucle
		-- principal, arriba) -- a diferencia de boyfriend, nunca tenían
		-- una red de seguridad por TIEMPO como la de arriba
		-- (NOTE_KILL_OFFSET). Si por cualquier motivo (cambio de
		-- velocidad, redondeo, un evento que desincroniza musicPos) ese
		-- chequeo de posición no llega a cumplirse para AUNQUE SEA una
		-- nota, esa nota (y todo lo que viene detrás en la cola, porque
		-- solo se mira enemyNote[1]) se queda atascada para siempre --
		-- "anyNotes" (la condición de fin de canción) nunca se vuelve
		-- false, y la canción no termina nunca. El enemy no "falla" notas
		-- (no hay penalización para el CPU), así que esta limpieza es
		-- puramente defensiva, sin efectos de puntaje/animación.
		for i = 1, 4 do
			local enemyNote = enemyNotes[i]
			local j = 1
			while j <= #enemyNote do
				local note = enemyNote[j]
				if note and (musicTime - note.strumTime) > NOTE_KILL_OFFSET then
					table.remove(enemyNote, j)
				else
					j = j + 1
				end
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

		-- Anclas escaladas en la misma proporción que el nuevo ancho de la
		-- barra de salud (850 vs los 1000 anteriores -> factor 0.85), para
		-- que los iconos sigan alineados con los bordes de la barra ya
		-- recalibrada (ver drawUI()).
		enemyIcon.x = 361.25 - health * 8.5
		boyfriendIcon.x = 497.25 - health * 8.5

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

        -- absMusicTime se pone en update() (no acá) -- puede llegar nil en
        -- el PRIMER frame post-cutscene: el skip (stage.lua:skipCutscene
        -- -> finishCutscene) apaga _G.cutscenePause A MITAD del frame
        -- (dentro de stage.update(dt), que corre DESPUÉS de weeks:update()
        -- en week7.lua), así que weeks:update() de ESTE frame todavía
        -- corrió con cutscenePause=true (early return, sin tocar
        -- absMusicTime) -- pero el guard de arriba (_G.cutscenePause) ya
        -- no bloquea acá porque para cuando se llega a updateUI() ya está
        -- en false. Sin este chequeo, math.fmod(nil,...) tira "bad
        -- argument #1" y rompe el juego entero.
        if absMusicTime and bpm and musicThres ~= oldMusicThres and math.fmod(absMusicTime, 60000 / bpm) < 100 then
            if enemyIconTimer then Timer.cancel(enemyIconTimer) end
            if boyfriendIconTimer then Timer.cancel(boyfriendIconTimer) end

            local enemyBaseX = enemyIcon.baseSizeX or 1.5
            local enemyBaseY = enemyIcon.baseSizeY or 1.5
            local boyfriendBaseX = boyfriendIcon.baseSizeX or -1.5
            local boyfriendBaseY = boyfriendIcon.baseSizeY or 1.5

            -- Magnitud (1.2x) y caída ajustadas a Psych real (HealthIcon
            -- bump: scale.set(1.2,1.2) instantáneo, decae con constante de
            -- tiempo fija ~0.11s, INDEPENDIENTE del bpm). Antes la subida
            -- era 1.16x y la caída duraba un beat completo (mucho más lento
            -- a bpm bajos que el decay fijo de Psych).
            enemyIconTimer = Timer.tween((60 / bpm) / 16, enemyIcon,
                {sizeX = enemyBaseX * 1.2, sizeY = enemyBaseY * 1.2}, "out-quad", function()
                enemyIconTimer = Timer.tween(0.2, enemyIcon,
                    {sizeX = enemyBaseX, sizeY = enemyBaseY}, "out-quad")
            end)

            boyfriendIconTimer = Timer.tween((60 / bpm) / 16, boyfriendIcon,
                {sizeX = boyfriendBaseX * 1.2, sizeY = boyfriendBaseY * 1.2}, "out-quad", function()
                boyfriendIconTimer = Timer.tween(0.2, boyfriendIcon,
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
						-- BUG real: sick/good/bad/shit/missed/maxCombo/accuracy se
						-- reseteaban por canción en initUI() sin ningún acumulador
						-- equivalente a weekTotalScore -- la pantalla de resultados
						-- al final de semana (buildScoreData(), llamada DESPUÉS de
						-- este bloque para la última canción) terminaba mostrando
						-- solo los valores de la ÚLTIMA canción, no el total de la
						-- semana, aunque el score sí estuviera bien acumulado.
						-- totalNotesHit/totalPlayed (no el ratingPercent ya
						-- dividido) son los que se acumulan para accuracy -- un
						-- promedio de porcentajes por canción sería incorrecto si
						-- las canciones tienen distinta cantidad de notas.
						_G.weekTotalSick      = (_G.weekTotalSick or 0) + self.ratingsData.sick.hits
						_G.weekTotalGood      = (_G.weekTotalGood or 0) + self.ratingsData.good.hits
						_G.weekTotalBad       = (_G.weekTotalBad or 0) + self.ratingsData.bad.hits
						_G.weekTotalShit      = (_G.weekTotalShit or 0) + self.ratingsData.shit.hits
						_G.weekTotalMissed    = (_G.weekTotalMissed or 0) + misses
						_G.weekTotalNotesHit  = (_G.weekTotalNotesHit or 0) + self.totalNotesHit
						_G.weekTotalPlayed    = (_G.weekTotalPlayed or 0) + self.totalPlayed
						_G.weekMaxCombo       = math.max(_G.weekMaxCombo or 0, self.maxCombo or 0)
						if _G.currentSongIndex == #_G.weekSongs then
							local old = highscores.getStoryScore(_G.currentWeekId, _G.currentDifficulty)
							if _G.weekTotalScore > old then
								highscores.setStoryScore(_G.currentWeekId, _G.currentDifficulty, _G.weekTotalScore)
							end
							-- Port 1:1 de PlayState.hx:2468 (weekCompleted.set) --
							-- desbloquea la semana siguiente en el StoryMenu.
							highscores.setWeekCompleted(_G.currentWeekId)
						end
					else
						local sName = _G.currentSongName or "unknown"
						local songKey = _G.currentWeekId .. "_" .. sName
						local old = highscores.getFreeplayScore(songKey, _G.currentDifficulty)
						if score > old then
							highscores.setFreeplayScore(songKey, _G.currentDifficulty, score)
							highscores.setFreeplayAccuracy(songKey, _G.currentDifficulty, self.ratingPercent or 0)
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

	-- Ya no dibuja nada: el popup de rating/combo se mueve a HUD fijo, ver
	-- drawUI(). Se deja como no-op (no se borra) porque la llaman los 8
	-- archivos stages/*/stage.lua -- quitar esas llamadas no aporta nada
	-- y es más superficie para romper algo por accidente.
	drawRating = function(self, multiplier)
	end,

drawUI = function(self)
        love.graphics.push()
            love.graphics.translate(lovesize.getWidth() / 2, lovesize.getHeight() / 2)
            love.graphics.scale(0.7, 0.7)

            for i = 1, 4 do
                -- Tintado RGB real de Psych (StrumNote.hx/Note.hx: el atlas
                -- NOTE_assets.png es "crudo" -- mismo arte para los 4
                -- carriles, recoloreado por shader, igual que los splashes).
                -- Solo en semanas NO pixel (el atlas pixel ya viene coloreado
                -- de antemano, sin necesidad de shader). El strum NO se
                -- tinta mientras está en "off" (StrumNote.hx: rgbShader solo
                -- se activa si animation.curAnim.name != 'static').
                if not _G.isPixelWeek then
                    enemyArrows[i].shader = (enemyArrows[i]:getAnimName() ~= "off") and splashShader.forLane(i) or nil
                    boyfriendArrows[i].shader = (boyfriendArrows[i]:getAnimName() ~= "off") and splashShader.forLane(i) or nil
                end

                -- Flechas estáticas con transparencia -- Real (PlayState.hx):
                -- el oponente NO se oculta en middlescroll, queda visible con
                -- alpha 0.35 (ya seteado en initUI()) superpuesto cerca del
                -- centro -- antes esto lo ocultaba del todo.
                graphics.setColor(1, 1, 1, (enemyArrows[i].alpha or 1) * guiAlphaObj.value)
                enemyArrows[i]:draw()
                graphics.setColor(1, 1, 1, (boyfriendArrows[i].alpha or 1) * guiAlphaObj.value)
                boyfriendArrows[i]:draw()
                graphics.setColor(1, 1, 1)

                love.graphics.push()
                    love.graphics.translate(0, -musicPos)
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
                            if not _G.isPixelWeek then enemyNotes[i][j].shader = splashShader.forLane(i) end
                            enemyNotes[i][j]:draw()
                            graphics.setColor(1, 1, 1)
                        end
                    end
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
                            if not _G.isPixelWeek then boyfriendNotes[i][j].shader = splashShader.forLane(i) end
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

			local enemyIconName = enemyIcon:getAnimName():gsub(" losing$", "")
            local enemyCol = healthBarColorFor(enemy, enemyIconName) or {255,0,0}
            local playerIconName = boyfriendIcon:getAnimName():gsub(" losing$", "")
            local playerCol = healthBarColorFor(boyfriend, playerIconName) or characterColors["boyfriend"] or {0,255,0}
            
            -- Barra de salud con transparencia. Tamaño recalibrado para que,
            -- tras el scale(0.7,0.7) de este bloque, el resultado en píxeles
            -- de PANTALLA real coincida con el gráfico COMPLETO de Psych
            -- (601x19 -- el 595x13 es solo el área interior de relleno,
            -- descontando 3px de borde a cada lado; el alto VISIBLE total
            -- del barra es 19, no 13 -- usar 13 la dejaba mucho más fina de
            -- lo que se ve en Psych). La posición Y (400/-400 local) ya
            -- coincidía casi exacto con Psych, no se toca.
            local healthBarWidth = 601 / 0.7
            local healthBarHeight = 19 / 0.7
            local healthBarHalf = healthBarWidth / 2
            local healthFillMult = healthBarWidth / 100
            if settings.downscroll then
                local y = -400
                graphics.setColor(enemyCol[1]/255, enemyCol[2]/255, enemyCol[3]/255, guiAlphaObj.value)
                love.graphics.rectangle("fill", -healthBarHalf, y, healthBarWidth, healthBarHeight)
                graphics.setColor(playerCol[1]/255, playerCol[2]/255, playerCol[3]/255, guiAlphaObj.value)
                love.graphics.rectangle("fill", healthBarHalf, y, -health * healthFillMult, healthBarHeight)
                graphics.setColor(0, 0, 0, guiAlphaObj.value)
                love.graphics.setLineWidth(10)
                love.graphics.rectangle("line", -healthBarHalf, y, healthBarWidth, healthBarHeight)
                love.graphics.setLineWidth(1)
            else
                local y = 400
                graphics.setColor(enemyCol[1]/255, enemyCol[2]/255, enemyCol[3]/255, guiAlphaObj.value)
                love.graphics.rectangle("fill", -healthBarHalf, y, healthBarWidth, healthBarHeight)
                graphics.setColor(playerCol[1]/255, playerCol[2]/255, playerCol[3]/255, guiAlphaObj.value)
                love.graphics.rectangle("fill", healthBarHalf, y, -health * healthFillMult, healthBarHeight)
                graphics.setColor(0, 0, 0, guiAlphaObj.value)
                love.graphics.setLineWidth(10)
                love.graphics.rectangle("line", -healthBarHalf, y, healthBarWidth, healthBarHeight)
                love.graphics.setLineWidth(1)
            end

            -- Barra de tiempo con transparencia
            if settings.timebarMode ~= "none" then
                -- Tamaño/posición recalibrados para que, tras el scale(0.7,0.7)
                -- de este bloque, el resultado en píxeles de PANTALLA real
                -- coincida con Psych real (PlayState.hx): barra 400x19
                -- (19 = alto del gráfico COMPLETO; 13 era solo el área
                -- interior de relleno y dejaba la barra demasiado fina),
                -- Y = 27 (upscroll) / 684 (downscroll) sobre un lienzo 1280x720.
                -- localValor = pantallaValor / 0.7 (o, para Y, (pantallaY-360)/0.7
                -- ya que este bloque también traslada el origen al centro).
                local timeBarHeight = 19 / 0.7
                local timeBarWidth = 400 / 0.7
                local timeBarX = -timeBarWidth / 2
                -- love.graphics.rectangle dibuja desde (x,y) hacia abajo/derecha,
                -- así que al pasar el alto de 13->19 la barra "creció" hacia
                -- abajo y empezó a tapar levemente los strums. Se resta la
                -- mitad del crecimiento para que la barra quede centrada en
                -- la misma posición de antes, en vez de crecer solo hacia abajo.
                local timeBarYBase = settings.downscroll and ((684 - 360) / 0.7) or ((27 - 360) / 0.7)
                -- Ajuste empírico extra: el strum no es un punto, tiene su
                -- propio alto visual alrededor de su .y -- la sola
                -- recalibración del centro de la barra no alcanzaba para
                -- separarla del strum (reportado por el usuario con
                -- screenshots, primero solo en upscroll). Este "15" es a ojo.
                --
                -- El SIGNO depende de la dirección: en upscroll la barra
                -- está ARRIBA del strum (bar.y=27 < strum.y screen=97.5) --
                -- alejarla es restar (subir más). En downscroll la barra
                -- está ABAJO del strum (bar.y=684 > strum.y screen=622.5) --
                -- alejarla es SUMAR (bajar más), lo opuesto. Antes se restaba
                -- en los dos casos por igual, así que en downscroll el ajuste
                -- empujaba la barra HACIA el strum (empeorando el solape) en
                -- vez de alejarla -- por eso "no cambiaba nada" ahí.
                local timeBarYNudge = settings.downscroll and 15 or -15
                local timeBarY = timeBarYBase - ((19 - 13) / 0.7) / 2 + timeBarYNudge
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
                -- Fuente base = 24 (main.lua). Psych usa tamaño 32 fijo para
                -- el texto de tiempo -- 24*textScale*0.7(transform) = 32
                -- => textScale = 32/(24*0.7). Antes (1.5) daba ~25px en
                -- pantalla real, notablemente más chico que Psych.
                local textScale = 32 / (24 * 0.7)
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

            -- Popups de rating/combo activos: HUD FIJO (igual que
            -- comboGroup con cameras=[camHUD] en PlayState.hx real) -- antes
            -- se dibujaba en drawRating(), adentro del cam.x/y de paneo/zoom
            -- de CADA stage, así que terminaba en una posición de pantalla
            -- distinta (a veces fuera de lo visible) según el stage y el
            -- estado de la cámara en ese momento. Acá, dentro del mismo
            -- push() de drawUI(), su posición en pantalla es siempre la
            -- misma sin importar el stage o la cámara. Se dibujan TODOS los
            -- popups activos del pool (comboStacking=true real -- ver
            -- spawnRatingPopup), no solo el último.
            for _, p in ipairs(activeRatingPopups) do
                graphics.setColor(1, 1, 1, p.alpha * guiAlphaObj.value)
                p.rating:draw()
                for i = 1, 3 do
                    p.numbers[i]:draw()
                end
            end
            graphics.setColor(1, 1, 1)
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

		-- En modo historia, los resultados de fin de semana usan los
		-- acumulados de TODA la semana (ver el bloque de fin de canción más
		-- arriba) en vez de los datos de self/ratingsData (que solo
		-- reflejan la ÚLTIMA canción, porque initUI() los resetea en cada
		-- canción nueva). totalNotesHit/totalPlayed acumulados se dividen
		-- acá -- promediar el ratingPercent de cada canción por separado
		-- daría un resultado incorrecto si las canciones tienen distinta
		-- cantidad de notas.
		local weekAccuracy = 0
		if _G.weekTotalPlayed and _G.weekTotalPlayed > 0 then
			weekAccuracy = math.min(1, math.max(0, (_G.weekTotalNotesHit or 0) / _G.weekTotalPlayed))
		end

		return {
			diff = diff,
			song = _G.currentSongName or self.songName or "unknown",
			displaySong = _G.currentSongDisplayName or nil,
			artist = _G.currentArtist or nil,
			scores = {
				score       = _G.storyMode and (_G.weekTotalScore or 0) or score,
				sickCount   = _G.storyMode and (_G.weekTotalSick or 0) or self.ratingsData.sick.hits,
				goodCount   = _G.storyMode and (_G.weekTotalGood or 0) or self.ratingsData.good.hits,
				badCount    = _G.storyMode and (_G.weekTotalBad or 0) or self.ratingsData.bad.hits,
				shitCount   = _G.storyMode and (_G.weekTotalShit or 0) or self.ratingsData.shit.hits,
				missedCount = _G.storyMode and (_G.weekTotalMissed or 0) or misses,
				maxCombo    = _G.storyMode and (_G.weekMaxCombo or 0) or (self.maxCombo or 0),
				-- Mismo ratingPercent que se muestra en vivo durante el gameplay
				-- (HUD, recalculateRating()) -- states/results.lua lo usa directo
				-- en vez de recalcular el accuracy con otra fórmula/otros pesos,
				-- que antes daba un % distinto al del HUD para la misma partida.
				accuracy    = _G.storyMode and weekAccuracy or (self.ratingPercent or 0),
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
		psychEvents = {}
		if spriteTimers then
			for i = 1, #spriteTimers do spriteTimers[i] = nil end
			-- Importante: mantener la tabla, solo vaciarla
			spriteTimers = {}
		end
		for id, t in pairs(spriteLoopTimers) do
			Timer.cancel(t)
			spriteLoopTimers[id] = nil
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
		ratingLoaderFn = nil
		numbersLoaderFn = nil
		activeRatingPopups = {}
		countdown = nil
		enemyIcon = nil
		boyfriendIcon = nil

		-- Liberar tablas de imágenes (también se recargan)
		-- MEM FIX: nil los campos individuales primero para soltar referencias a GPU textures
		-- antes de que la GC tenga oportunidad de correr.
		if images then
			images.notes        = nil
			images.numbers      = nil
			images.rating       = nil
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

    -- Expone bfCamTarget()/enemyCamTarget() (locales a este archivo) para
    -- que un stage (p.ej. stages/military/stage.lua, cutscenes de semana 7)
    -- pueda enfocar la cámara en boyfriend/enemy sin reinventar la fórmula
    -- (offsets de personaje, camera_position, stageOffset, escala...).
    getBfCamTarget = function(self) return bfCamTarget() end,
    getEnemyCamTarget = function(self) return enemyCamTarget() end,

    -- Expone la MISMA tabla guiAlphaObj (local a este archivo) -- al ser
    -- una tabla, el llamador puede mutar guiAlphaObj.value directamente y
    -- el cambio se ve acá también (son la misma referencia). Usado por
    -- cutscenes (p.ej. stages/military/stage.lua) para ocultar el HUD
    -- igual que camHUD.visible=false en Psych real.
    getGuiAlphaObj = function(self) return guiAlphaObj end,

    -- Réplica exacta de los eventos "HighlightOn"/"HighlightOff" de
    -- cameraEvents (ver el for de más arriba) -- extraído a método para que
    -- un stage con su propio chart Psych (p.ej. data/too-slow/events.json,
    -- que NO pasa por cameraEvents) pueda dispararlo vía
    -- charts/psych/events.lua:M.registerHandler sin duplicar la lógica de
    -- guiAlphaObj.
    --
    -- A pedido: Highlight ya NO toca la cámara para nada (antes tweemeaba
    -- cam.x/y hacia bf/enemy y suspendía el auto-cam con highlightActive
    -- mientras durara -- eso es justo lo que causaba el bamboleo al soltar,
    -- por más que se le corrigiera el cálculo del objetivo). Ahora el
    -- evento queda reducido a lo único que se pidió: mostrar/ocultar el
    -- HUD. El auto-cam (seguimiento bf/enemy por mustHitSection) sigue
    -- corriendo siempre, sin interrupción, exactamente igual que si
    -- Highlight no existiera.
    setHighlight = function(self, on, target)
        if guiAlphaTween then Timer.cancel(guiAlphaTween) end
        guiAlphaTween = Timer.tween(0.5, guiAlphaObj, {value = on and 0 or 1}, "linear", function() guiAlphaTween = nil end)
    end,

    -- Reloj de beat independiente para cutscenes (ver triggerDanceBeat()
    -- más arriba) -- hace bailar a girlfriend/enemy/boyfriend sin depender
    -- de musicTime (congelado por _G.cutscenePause durante una cutscene).
    triggerDanceBeat = function(self) triggerDanceBeat() end,

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
			images.rating       = nil
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
			local ratingImgPixel = love.graphics.newImage(graphics.imagePath("pixel/rating"))
			ratingImgPixel:setFilter("nearest", "nearest")
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
			images.rating       = ratingImgPixel
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
			images.rating       = love.graphics.newImage(graphics.imagePath("rating"))
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
		-- Descartar instancias activas; actualizar loaders al modo actual
		-- (si hay un custom splash activo, resetDefaultSplashLoaders lo respeta)
		activeSplashes = {{}, {}, {}, {}}
		resetDefaultSplashLoaders()
	end,

	-- Ya no hay un único "rating"/"numbers" para migrar (ver
	-- spawnRatingPopup/activeRatingPopups) -- esto sólo actualiza los
	-- loaders y la escala para que los PRÓXIMOS popups usen el modo
	-- correcto. Los popups ya en pantalla en este instante (viven ~0.2s)
	-- se quedan con su sprite/escala viejo hasta que terminen de
	-- desvanecerse -- no vale la pena migrarlos en caliente por algo tan
	-- breve.
	recreateRatingAndNumbers = function(self)
		-- /0.7: ver comentario completo en enter().
		if _G.isPixelWeek then
			ratingLoaderFn = love.filesystem.load("sprites/pixel/rating.lua")
			numbersLoaderFn = love.filesystem.load("sprites/pixel/numbers.lua")
			ratingScaleX, ratingScaleY = NoteSize * 0.75 / 0.7, NoteSize * 0.75 / 0.7
			numberScaleX, numberScaleY = NoteSize * 0.5 / 0.7, NoteSize * 0.5 / 0.7
		else
			ratingLoaderFn = love.filesystem.load("sprites/rating.lua")
			numbersLoaderFn = love.filesystem.load("sprites/numbers.lua")
			ratingScaleX, ratingScaleY = 0.75 / 0.7, 0.75 / 0.7
			numberScaleX, numberScaleY = 0.5 / 0.7, 0.5 / 0.7
		end
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

		sprites.leftArrow = love.filesystem.load(arrowPath .. "left-arrow.lua")
		sprites.downArrow = love.filesystem.load(arrowPath .. "down-arrow.lua")
		sprites.upArrow = love.filesystem.load(arrowPath .. "up-arrow.lua")
		sprites.rightArrow = love.filesystem.load(arrowPath .. "right-arrow.lua")

		sprites.splashLeft = love.filesystem.load(splashPath .. "splash-left.lua")
		sprites.splashDown = love.filesystem.load(splashPath .. "splash-down.lua")
		sprites.splashUp = love.filesystem.load(splashPath .. "splash-up.lua")
		sprites.splashRight = love.filesystem.load(splashPath .. "splash-right.lua")
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