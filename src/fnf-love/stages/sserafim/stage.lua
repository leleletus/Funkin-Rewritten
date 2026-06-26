-- Stage: "sserafim" (colab especial LE SSERAFIM, canción "Spaghetti") --
-- puerto 1:1 desde cero contra funkin.assets-main real
-- (preload/data/stages/sserafim.json + preload/scripts/stages/sserafim.hxc),
-- verificado contra el código fuente real, NO contra la versión vieja
-- (movida a backup y completamente ignorada, no se reutilizó nada de ahí).
--
-- ESTADO ACTUAL (esqueleto, escalando capa por capa -- ver memoria del
-- proyecto "sserafim-port-research" para el plan completo):
--   HECHO: fondo del Diner (7 capas estáticas con su scroll/parallax real),
--     posicionamiento de personajes vía stage data real.
--   FALTA (próximas rondas): el sistema de 5 personajes simultáneos
--     (setGirlsVisible/setGirlsSinging), los eventos custom
--     (sserafimShow/Sing/Kick/Dark/Lights/PulseLights/Cover/Flash/
--     Beautiful/End), el shader HSL de ajuste de color, la cutscene de
--     intro (choque de auto + getup), y el floor con perspectiva/skew
--     sincronizado a cámara (PerspectiveSprite real).
--
-- NO portado todavía a propósito (sin asset real disponible o pendiente):
-- las luces (back-light-color/white, truck-light1/2) y los props
-- exclusivos de cutscene (backTablesCutscene/burgerCutscene) se cargan
-- pero quedan invisibles (alpha=0, igual que su valor real por defecto)
-- hasta que se porten los eventos que los activan.

local M = {}

local psychStages = require("charts.psych.stages")
local stagedata = require("charts.psych.stagedata")
local character = require("charts.psych.character")
local events = require("charts.psych.events")
local graphics = require("modules.graphics")
local audio = require("modules.audio")
local animateAtlas = require("modules.animate_atlas")
local lipsync = require("modules.lipsync")
local icons = require("sprites.icons")

-- ── Fondos ──────────────────────────────────────────────────────────────
local bg, floor, backTables, backStools, truck, truckDoor, frontStool
-- backTablesCutscene/burgerCutscene (props reales EXCLUSIVOS de la
-- cutscene -- la escena del choque usa un mostrador/hamburguesa propios,
-- DISTINTOS de los del diner normal, ver setCutsceneVisibility) --
-- antes no estaban portados, dejando la escena de la cutscene igual a la
-- de gameplay normal en vez de la suya propia.
local backTablesCutscene, burgerCutscene
local backLightColor, backLightWhite, truckLight1, truckLight2

-- Shader HSL real (SserafimShader.hx, ver shaders/sserafim.glsl para el
-- detalle del puerto) -- DOS instancias (characterShader/stageShader,
-- mismo criterio que addCharacter()/addProp() reales), porque "isChar"
-- cambia cómo se aplica el oscurecimiento (ver el .glsl) aunque
-- darkAmt/lightColor/pulseStrength/truckStrength se actualicen
-- IDÉNTICOS en ambas (ver M.update()).
local characterShader, stageShader

-- ── Cutscene de intro (introCutscene() real, sserafim.hxc:735-903) ──────
-- 3 sprites Adobe Animate NUEVOS, exclusivos de la cutscene (NO son
-- characters de slot, ni las extraGirls -- son props standalone, mismo
-- criterio que loadExtraGirl): el choque de auto completo (un solo
-- timeline raíz de 631 frames) + el "getup" de gf/bf (cada uno con 2
-- animaciones: "static"/"getup", ver characters/sserafim-{gf,bf}-getup.json).
local cutsceneMainSprite, cutsceneGfSprite, cutsceneBfSprite
local seeyou1, seeyou2

local cutsceneActive = false
local cutsceneTimers = {}
local cutsceneOnComplete
local cutsceneSounds = {}
local cutsceneSkipped = false
local confirmWasDown = false

-- Forward declarations: M.load() registra el handler "sserafimEnd" (más
-- abajo) que llama a endStuff(), pero endStuff()/introCutscene()/etc se
-- definen DESPUÉS de M.load() en este archivo -- en Lua un local solo es
-- visible desde su punto de declaración en adelante, así que sin esto el
-- closure del handler vería un global nil en vez de la función real.
-- idleLoop: MISMO problema, confirmado por el crash real
-- ("attempt to call global 'idleLoop' (a nil value)") -- onSserafimKick
-- (más arriba en el archivo que la definición real de idleLoop) la
-- referenciaba dentro de un callback, atado al global inexistente.
local endStuff, setCutsceneVisibility, skipCutscene, introCutscene, camFocusXY, idleLoop
local resetSserafimClear, startSserafimClear

local function addCutsceneTimer(handle)
	table.insert(cutsceneTimers, handle)
	return handle
end

local function clearCutsceneTimers()
	for _, h in ipairs(cutsceneTimers) do
		if h then Timer.cancel(h) end
	end
	cutsceneTimers = {}
end

local function stopCutsceneSounds()
	for _, snd in ipairs(cutsceneSounds) do
		if snd then snd:stop() end
	end
	cutsceneSounds = {}
end

-- ── Sistema de 5 personajes simultáneos (sserafim.hxc real) ─────────────
-- Confirmado leyendo el script real: kazuha es la ÚNICA de las 4 que el
-- motor registra como "enemy" normal (metadata real:
-- playData.characters.opponent="sserafim-kazuha") -- yunjin/chaewon/
-- eunchae se crean ahí como personajes EXTRA (CharacterType.OTHER),
-- simultáneos en pantalla, no por un slot del motor. weeks.lua de este
-- proyecto solo tiene 3 slots (boyfriend/girlfriend/enemy) -- mismo
-- criterio que el A-Bot de weekend1: las 3 extra se manejan como sprites
-- standalone a nivel de stage, posicionadas a mano en el slot "opponent"
-- (la MISMA posición que kazuha/enemy, total solo una está realmente
-- activa a la vez en la práctica) y actualizadas/dibujadas manualmente
-- acá, NO por weeks.lua.
--
-- setGirlsVisible/setGirlsSinging (sserafim.hxc:289-319): arrays de
-- bool reales, en ESTE orden exacto -- visible=[yunjin,kazuha,chaewon,
-- eunchae,sakura(bf)] (gf excluida a propósito, "itd break a lot of
-- stuff" -- comentario real), singing=[yunjin,kazuha,chaewon,eunchae,
-- sakura(bf),girlfriend]. "singing" en el real NO es "a quién redirigir
-- las notas del oponente" -- es el array que reasigna characterType
-- (BF/DAD) de las 6 (stages/sserafim.hxc:309-318) -- cada una reacciona
-- según SU PROPIO characterType actual sin importar qué slot físico
-- ocupe (BaseCharacter.hx:535-567): BF reacciona a notas del JUGADOR,
-- DAD a notas del OPONENTE. Ver customEnemyNoteHit/customNoteHit/
-- customNoteMiss más abajo para la implementación completa de esto.
local extraGirls = {} -- { yunjin=sprite, chaewon=sprite, eunchae=sprite }

local girlVisible = { yunjin = false, kazuha = true,  chaewon = false, eunchae = false, sakura = true }
local girlSinging = { yunjin = false, kazuha = true,  chaewon = false, eunchae = false, sakura = true, girlfriend = true }

-- BUG corregido: ninguno de los 4 "extra" (yunjin/chaewon/eunchae/
-- girlfriend) tiene un slot físico, así que el ciclo de baile genérico de
-- weeks.lua (triggerDanceBeat(), que SÍ vuelve a boyfriend/enemy a
-- idle/dance solo una vez termina su pose de canto) nunca los toca --
-- sin nada propio, su pose de canto se quedaba pegada para siempre tras
-- el último golpe de nota. El real (BaseCharacter.hx:onUpdate, líneas
-- 403-442) usa un "holdTimer" que se resetea en CADA golpe de nota
-- (onNoteHit, líneas 542/548/558/564) y, si supera "singTime" pasos (8
-- por defecto, DEFAULT_SINGTIME en CharacterData.hx -- ninguno de los 6
-- personajes de Sserafim lo sobreescribe en su JSON real) sin un golpe
-- nuevo que lo refresque, fuerza dance(true) (vuelta a idle). Replicado
-- acá de forma uniforme para las 6 (incluidas kazuha/sakura, que YA
-- tienen su propio mecanismo de slot pero no hace daño tenerlas también
-- acá -- si su slot ya las repuso a idle, esto es un no-op).
local singHoldTimer = { kazuha = 0, chaewon = 0, eunchae = 0, yunjin = 0, girlfriend = 0, sakura = 0 }
local SING_TIME_STEPS = 8 -- DEFAULT_SINGTIME real

local function isSingPoseName(name)
	return name == "left" or name == "right" or name == "up" or name == "down"
		or name == "left alt" or name == "right alt" or name == "up alt" or name == "down alt"
		or name == "miss left" or name == "miss right" or name == "miss up" or name == "miss down"
end

local function resetSingHold(name)
	singHoldTimer[name] = 0
end

local function updateSingHoldRevert(dt, name, sprite)
	if not sprite then return end
	local animName = sprite:getAnimName()
	if not isSingPoseName(animName) then
		singHoldTimer[name] = 0
		return
	end

	singHoldTimer[name] = (singHoldTimer[name] or 0) + dt

	local bpm = (weeks and weeks:getBPM()) or 100
	-- 8 steps a 4 steps/beat == 2 beats -- igual fórmula que el real
	-- (singTimeSteps * stepLengthMs/1000, con stepLengthMs = 60000/bpm/4).
	local singTimeSec = SING_TIME_STEPS * (60 / bpm / 4)
	if animName:find("^miss") then singTimeSec = singTimeSec * 2 end -- real: "makes it feel more awkward when you miss"

	if singHoldTimer[name] > singTimeSec then
		singHoldTimer[name] = 0
		sprite:animate("idle", true)
	end
end

-- sserafimBeautiful (sserafim-gf.hxc real): la GF tiene un segundo set
-- completo de animación con sufijo "-beautiful" -- se intercepta
-- girlfriend:animate() para agregar el sufijo en danceLeft/danceRight sin
-- tocar weeks.lua (que llama a esas 2 animaciones directo, sin hook
-- disponible para stages).
--
-- BUG corregido (round 35): el sufijo solo se agregaba para danceLeft/
-- danceRight -- el real (sserafim-gf.hxc:22-31, playAnimation()) lo
-- agrega a CUALQUIER nombre sin excepción, incluidas sus 4 poses de
-- canto (singLEFT/RIGHT/UP/DOWN + sus variantes miss). Confirmado además
-- contra el atlas real: "gf left 2"/"gf right 2"/etc (símbolos
-- DISTINTOS de "gf left"/"gf right", con sub-símbolos llamados
-- literalmente "chest hand"/"shoulder stub") son justo el contenido de
-- esas entradas "-beautiful" del JSON -- confirma que la "mano al
-- pecho" reportada por el usuario ES la variante -beautiful de sus
-- poses de canto, no algo aparte. Como animnames.lua:toInternal() NO
-- traduce el sufijo "-beautiful" (ningún patrón lo reconoce, pasa sin
-- tocar -- igual que "-joint" en sakura), pero SÍ traduce "singLEFT" a
-- "left" -- el código que llama (customNoteHit/customEnemyNoteHit) le
-- pasa a :animate() el nombre YA TRADUCIDO ("left", no "singLEFT") --
-- hay que reconstruir el nombre crudo correspondiente para poder
-- pegarle el sufijo, GF_SING_DIR_TO_RAW hace ese mapeo.
local GF_SING_DIR_TO_RAW = { left = "LEFT", right = "RIGHT", up = "UP", down = "DOWN" }

local isBeautiful = false
local girlfriendAnimateOriginal

-- BUG corregido (round 35): esto se instalaba UNA sola vez en M.load(),
-- que corre ANTES de que weeks.lua:applyChartMeta() reemplace el
-- girlfriend STALE por el real de esta canción (mismo patrón ya conocido
-- del shader, ver M.onCharacterReload() más abajo) -- el wrapper quedaba
-- pegado al objeto VIEJO, y el girlfriend REAL (el que de verdad se usa
-- durante el gameplay) JAMÁS recibía el sufijo "-beautiful" en nada,
-- incluida la animación de "mano al pecho" recién descrita. Extraído a
-- una función para poder instalarlo TANTO en M.load() (primera carga)
-- COMO en M.onCharacterReload() (cuando el slot se reemplaza de verdad).
local function installGirlfriendBeautifulWrapper(sprite)
	if not sprite then return end
	girlfriendAnimateOriginal = sprite.animate
	sprite.animate = function(self, animName, loopOverride, callback)
		if isBeautiful then
			if animName == "danceLeft" or animName == "danceRight" then
				animName = animName .. "-beautiful"
			elseif GF_SING_DIR_TO_RAW[animName] then
				animName = "sing" .. GF_SING_DIR_TO_RAW[animName] .. "-beautiful"
			else
				local missDir = animName:match("^miss (%a+)$")
				if missDir and GF_SING_DIR_TO_RAW[missDir] then
					animName = "sing" .. GF_SING_DIR_TO_RAW[missDir] .. "miss-beautiful"
				end
			end
		end
		return girlfriendAnimateOriginal(self, animName, loopOverride, callback)
	end
end

-- ── Lipsync (SserafimLipSyncSprite.hxc + LIP_SYNC_OFFSETS de cada
-- sserafim-<nombre>.hxc real) ───────────────────────────────────────────
-- El real INYECTA este sprite directo dentro del árbol de símbolos de
-- cada personaje, en cada keyframe que tenga un elemento llamado
-- "keyword" (así hereda automático la posición/rotación de la cabeza en
-- cada frame). Este motor no puede modificar el árbol en runtime, así
-- que en cambio se CALCULA dónde caería esa inyección cada frame
-- (animateAtlas.findNamedTransform(), ver modules/lipsync.lua) y se
-- dibuja aparte, en esa misma posición -- mismo resultado visual.
--
-- "poses": offset[x,y] + ángulo, A MANO por personaje/pose -- el real
-- solo los actualiza cuando el nombre de la animación actual existe en
-- esta tabla (si no, el offset/ángulo se queda en el último valor
-- aplicado -- por eso sakura no tiene entradas para "-bf1"/"-bf2"/
-- "-miss": esas poses simplemente heredan el offset de la pose anterior).
-- BUG corregido: las claves usaban el nombre CRUDO del JSON real
-- ("singLEFT" etc, igual que LIP_SYNC_OFFSETS en los .hxc reales) -- pero
-- ESTE motor traduce esos nombres a su convención INTERNA antes de
-- guardarlos en animLookup (ver charts/psych/animnames.lua:toInternal(),
-- "singLEFT" -> "left") -- sprite:getAnimName() (usado en
-- updateLipsyncFor() más abajo para decidir qué entrada de esta tabla
-- aplicar) por lo tanto SIEMPRE devuelve "left"/"right"/"up"/"down", NUNCA
-- "singLEFT" -- con las claves viejas, el offset/ángulo nunca se
-- actualizaba para NINGUNA pose de canto (solo "idle" coincidía, porque
-- ese nombre no se transforma). Los sufijos "-joint" de sakura SÍ se
-- dejan como estaban -- toInternal() solo reconoce los patrones "-alt"/
-- "miss", "-joint" no matchea ninguno y pasa SIN TRANSFORMAR.
-- Valores afinados a mano por el usuario con states/sserafim-lipsync-debug.lua
-- (ronda 28) -- reemplazan los offsets originales transcritos de los .hxc
-- reales, que ya no aplicaban 1:1 una vez corregida la fórmula de
-- composición (rondas 21-27).
local LIPSYNC_DATA = {
	kazuha = {
		atlasPath = "images/png/sserafim/lipsync",
		keyword = "mouth default",
		flipX = true,
		poses = {
			idle = { -13, -9, -13 }, left = { -13, -9, -14 }, right = { -11, -11, -13 },
			up = { -11, -11, -14 }, down = { -14, -7, -12 },
		},
	},
	chaewon = {
		atlasPath = "images/png/sserafim/lipsync",
		keyword = "mouth default",
		flipX = false,
		poses = {
			idle = { 17, -10, -166 }, left = { 16, -11, -165 }, right = { 15, -12, -165 },
			up = { 14, -13, -168 }, down = { 17, -10, -167 },
		},
	},
	eunchae = {
		atlasPath = "images/png/sserafim/lipsync",
		keyword = "mouth default",
		flipX = false,
		poses = {
			idle = { 17, -4, -168 }, left = { 17, -4, -169 }, right = { 16, -5, -166 },
			up = { 19, 0, -166 }, down = { 15, -7, -168 },
		},
	},
	yunjin = {
		atlasPath = "images/png/sserafim/lipsync-yunjin",
		keyword = "mouth yunjin",
		flipX = false,
		poses = {
			idle = { -17, -9, 23 }, left = { -19, -7, 23 }, right = { -19, -7, 23 },
			up = { -19, -7, 22 }, down = { -17, -9, 23 },
		},
	},
	sakura = {
		atlasPath = "images/png/sserafim/lipsync",
		keyword = "mouth edit",
		flipX = true,
		poses = {
			idle = { -18, -8, -14 }, left = { -18, -8, -14 }, right = { -18, -8, -15 },
			up = { -17, -9, -15 }, down = { -19, -7, -15 },
			["singLEFT-joint"] = { -18, -8, -16 }, ["singRIGHT-joint"] = { -19, -7, -15 },
			["singUP-joint"] = { -15, -11, -14 }, ["singDOWN-joint"] = { -20, -5, -15 },
		},
	},
}

local lipsyncSprites = {} -- [nombre] = instancia modules/lipsync.lua
local lipsyncMouthMat = {} -- [nombre] = matriz encontrada este frame (o nil)

-- Factorizado de M.load() -- ver el comentario en el sitio donde se llama
-- (límite duro de Lua de 60 upvalues por función, M.load() ya estaba al
-- límite antes de esto).
local function createLipsyncSprites()
	lipsyncSprites = {}
	lipsyncMouthMat = {}
	for name, ld in pairs(LIPSYNC_DATA) do
		local lip = lipsync.new(ld.atlasPath)
		lip.flipX = ld.flipX
		lipsyncSprites[name] = lip
	end
end

-- BUG corregido: character.load() llamado DIRECTO (sin pasar por
-- characters.lua:M.loadInto(), que es quien normalmente calcula
-- _slotConversionX/Y/_charOffsetX/Y vía sprite:getOrigin()+def.position)
-- nunca asigna esos campos -- quedan nil, perdiendo el offset propio del
-- personaje (su "position" real, ej. yunjin=[2,347]). Para estos 3
-- (cargados a mano porque no tienen un slot de weeks.lua propio), se lee
-- sprite.psychChar.position directo en vez de depender de esos campos.
-- _slotConversionX/Y sería 0 igual (getOrigin() de Adobe Animate siempre
-- da (0,0), ver character.lua), así que no se pierde nada más.
-- BUG corregido: yunjin/chaewon/eunchae NO comparten posición con el slot
-- "opponent" -- son posiciones ABSOLUTAS fijas, propias de cada una,
-- confirmadas en sserafim.hxc:162-164 (characterOrigin.x/y siempre (0,0)
-- para Adobe Animate, ver character.lua:getOrigin() -- así que el resto
-- de la resta no cambia nada, son los valores crudos directo). La
-- versión anterior las derivaba mal de stagedata.opponent +
-- psychChar.position, lo que las dejaba completamente descolocadas.
-- Ajuste fino agregado a mano sobre los valores reales (-621,154 / 687,98
-- / 770,675), encontrado con states/sserafim-stage-debug.lua: la fórmula
-- de origen "feet" (-(minX+w/2),-(minY+h)) da resultados correctos para
-- sakura/gf pero deja a yunjin/chaewon/eunchae (y a kazuha, ver su JSON
-- "position") sistemáticamente más arriba de lo que deberían -- no se
-- encontró la causa raíz exacta (la matemática y el bounding box
-- calculado están verificados correctos por separado) así que se
-- compensa con este ajuste empírico, igual criterio que ya se usó para
-- las posiciones de la cutscene antes de encontrar la fórmula "topleft".
local EXTRA_GIRL_POS = {
	["characters/sserafim-yunjin.json"]  = { -621 + 20, 154 + 280 },
	["characters/sserafim-chaewon.json"] = { 687, 98 + 323 },
	["characters/sserafim-eunchae.json"] = { 770 - 1, 675 + 248 },
}

-- Origen ("characterOrigin", bounds de la pose ACTIVA) en el ÚLTIMO frame
-- del rango/símbolo activo -- ver comentario de round 33 en
-- repositionExtraGirl() sobre por qué el último frame, no el primero/el
-- que esté activo en el momento de llamar.
local function settledOrigin(sprite)
	local inst = sprite:getAtlasInstance()
	local savedFrame = inst.frame
	inst.frame = math.max(0, sprite:getFrameCount() - 1)
	local ox, oy = sprite:getOrigin()
	inst.frame = savedFrame
	return ox, oy
end

local function loadExtraGirl(jsonPath)
	local sprite = character.load(jsonPath, false)
	local pos = EXTRA_GIRL_POS[jsonPath] or { 0, 0 }
	-- BUG corregido: yunjin/chaewon/eunchae usan "useBoundsOrigin" (ver
	-- character.lua:getOrigin()) -- el real (sserafim.hxc:162-164)
	-- explícitamente resta characterOrigin de la posición absoluta
	-- ("-621 - yunjin.characterOrigin.x", etc.) -- antes esto se omitía
	-- por completo, asumiendo origen (0,0), dejándolas lejísimos de su
	-- posición real (mismo bug que afectaba a kazuha/sakura/gf vía el
	-- sistema de slots).
	local ox, oy = sprite:getOrigin()
	sprite.x, sprite.y = pos[1] + ox, pos[2] + oy
	sprite.visible = false
	-- _anchorX/Y: el ancla ABSOLUTA fija de este personaje (ver
	-- EXTRA_GIRL_POS) -- repositionExtraGirl() la usa para sumarle el
	-- origen correcto según si está en idle o cantando, ver ahí.
	sprite._anchorX, sprite._anchorY = pos[1], pos[2]

	-- BUG corregido (round 34): el primer intento (round 28-33) recalculaba
	-- el origen por NOMBRE de pose -- arreglaba idle-vs-canto, pero cada
	-- dirección de canto (left/right/up/down) tiene SU PROPIO origen
	-- (ligeramente distinto entre sí -- confirmado con números reales,
	-- hasta ~6-9px de diferencia entre las más alejadas en eunchae), así
	-- que cambiar de dirección en pleno gameplay hacía que el ancla
	-- "saltara" un poco en CADA nota -- invisible en el editor de
	-- personajes (que nunca recalcula nada), pero muy notorio jugando de
	-- verdad. El real no tiene este problema porque "offsets" es [0,0]
	-- para las 4 direcciones en TODOS los personajes (ronda 11) -- el
	-- juego real simplemente no corrige nada pose por pose, así que estas
	-- pequeñas diferencias de dibujo a mano nunca se notan ahí (no hay
	-- ningún "salto" que corregir, todas comparten la MISMA posición
	-- base). Imitado acá precomputando UN solo origen de canto (usando
	-- "left" como referencia, cualquiera de las 4 sirve por ser todas
	-- parecidas) en vez de uno por pose -- repositionExtraGirl() ahora
	-- solo distingue 2 casos (idle vs cantando), no N (uno por pose).
	--
	-- BUG corregido (round 35): esto cambiaba la animación a "left" y
	-- luego la dejaba fija en "idle" SIEMPRE, sin condición -- yunjin
	-- arranca en "doorclosed" (primera animación de su JSON, ver
	-- M.load() más abajo), no en "idle" -- este código la pisaba y la
	-- dejaba bailando desde el primer frame del stage, ANTES de patear la
	-- puerta (reportado: "ya está ahí haciendo su idle" en vez de la
	-- puerta cerrada). Ahora se guarda cuál era su animación real ANTES
	-- de tocar nada, y se restaura esa exacta al final (con loopOverride
	-- nil, para que respete el "loop" propio de esa entrada del JSON en
	-- vez de forzar true) en lugar de asumir "idle" a ciegas.
	local initialAnim = sprite:getAnimName()
	sprite:animate("idle", nil)
	sprite._idleOx, sprite._idleOy = settledOrigin(sprite)
	sprite:animate("left", nil)
	sprite._singOx, sprite._singOy = settledOrigin(sprite)
	sprite:animate(initialAnim, nil)

	return sprite
end

-- Historia de este fix (por si hay que revisarlo de nuevo):
-- round 28: getOrigin() se calculaba UNA sola vez en loadExtraGirl() con
--   "idle" activa, nunca se recalculaba al cambiar de pose -- eunchae
--   quedaba bien en idle pero rota en TODAS sus poses de canto (su "idle
--   e" tiene un origen ~330px distinto al de sus otras 8 poses). Fix:
--   recalcular cada frame según la pose activa.
-- round 31: recalcularlo cada frame literal hacía temblar el personaje
--   DURANTE una misma pose de canto (que es un RANGO de varios frames,
--   no uno fijo, y el bounding box varía un poco cuadro a cuadro). Fix:
--   cachear por NOMBRE de pose, recalcular solo al cambiar de nombre.
-- round 33: el frame "activo justo cuando cambia el nombre" podía ser un
--   frame de transición atípico (el "down" de yunjin tiene su origen
--   real en sus frames 2-12, pero el 0-1 está ~60px desplazado). Fix:
--   muestrear el ÚLTIMO frame del rango en vez del que esté activo.
-- round 34 (ACTUAL): aun muestreando bien, CADA dirección de canto
--   (left/right/up/down) tiene su PROPIO origen, ligeramente distinto
--   entre sí (hasta ~6-9px de diferencia en eunchae) -- cambiar de
--   dirección en pleno gameplay hacía "saltar" el ancla un poco en cada
--   nota. Invisible en el editor de personajes (nunca recalcula nada),
--   muy notorio jugando de verdad -- el real nunca tiene este problema
--   porque sus 4 direcciones comparten "offsets":[0,0] sin excepción
--   (ronda 11), o sea NINGUNA corrección pose-por-pose, todas comparten
--   la misma base. Fix: precomputar SOLO 2 orígenes en loadExtraGirl()
--   (idle y "cantando", este último usando "left" como referencia única
--   para las 4 direcciones) en vez de uno por pose -- ver
--   sprite._idleOx/Oy / sprite._singOx/Oy ahí.
local function repositionExtraGirl(sprite)
	if not sprite then return end

	local ox, oy
	if sprite:getAnimName() == "idle" then
		ox, oy = sprite._idleOx, sprite._idleOy
	else
		ox, oy = sprite._singOx, sprite._singOy
	end

	sprite.x, sprite.y = sprite._anchorX + ox, sprite._anchorY + oy
end

-- ── Luces / oscurecimiento / cover / flash (sserafim.hxc real) ──────────
-- Portado literal contra setDarkenAmt()/flashTruckLights()/setLightState()/
-- flashBackLight()/onBeatHit()/setCoverVisible()/flashScreen() reales
-- (líneas 279-505). characterShader/stageShader.darkenAmount/
-- truckLightStrength/pulseLightColor/pulseLightStrength son uniforms del
-- shader HSL real (SserafimShader.hx, todavía sin portar) -- se guardan
-- en lightState YA, listos para que M.draw() los aplique al shader en
-- cuanto se porte (ver tarea pendiente "shader HSL").
local lightState = { darkenAmount = 0, truckLightStrength = 0, pulseLightStrength = 0 }
local pulseLightColor = { 1, 1, 1 }

-- setAdjustColor() real (SserafimShader.hx) -- SOLO se usa durante la
-- cutscene de intro (introCutscene(), tweens de brightness/hue/contrast
-- durante el choque de auto), nunca en gameplay normal. Se inicializa en
-- 0 (identidad) y M.startCutscene() lo tweenea -- ver más abajo.
local colorAdjust = { hue = 0, saturation = 0, brightness = 0, contrast = 0 }

-- Tabla (no número suelto) para poder tweenearla con Timer.tween (ver
-- M.startCutscene -- el fade de salida del choque la anima de 1 a 0).
local coverState = { alpha = 0 }

-- FlxG.camera.flash(color, duration)/fade(color,duration,fadeIn=true) real
-- -- mismo patrón ya usado en states/title.lua, generalizado con color
-- (la cutscene de intro usa fade NEGRO al empezar y BLANCO en el choque,
-- ambos con fadeIn=true -- decaen de opaco a transparente igual que un
-- flash, solo cambia el color y la duración).
local flashAlpha, flashDuration = 0, 1
local flashColor = { 1, 1, 1 }
local function triggerFlash(duration, color)
	flashAlpha = 1
	flashDuration = duration or 1
	flashColor = color or { 1, 1, 1 }
end

local lightsEnabled = false
local lightsColors, lightsDurations, lightsIntensities = {}, {}, {}
local lastBeatNum = -1

-- BUG corregido: onSserafimKick(final=true) esperaba a que kick2
-- terminara su animación COMPLETA (60 frames/2.5s, ver
-- characters/sserafim-yunjin.json:"kick2") antes de pasar a "idle" -- el
-- real (sserafim.hxc:230-232) NO espera eso: hace
-- "yunjin.playAnimation('kick2',...); yunjin.danceEvery = 1" -- danceEvery
-- reactiva el sistema NORMAL de baile-por-beat de BaseCharacter, que
-- interrumpe a kick2 en el SIGUIENTE BEAT (mucho antes de sus 2.5s
-- completos) y la pasa a su pose de baile/idle normal. Sin un sistema de
-- "baile por beat" genérico portado para personajes Adobe Animate
-- sueltos como yunjin, se aproxima directo: programar el cambio a "idle"
-- para el PRÓXIMO BEAT después de iniciar kick2, en vez de esperar su
-- fin natural.
local yunjinPendingIdleBeat = false
local yunjinKickBeatNum = -1
local yunjinKickStartTime = 0
-- Mínimo de tiempo visible (ms) antes de permitir el corte al próximo
-- beat -- confirmado contra Bopper.hx ("step % (danceEvery*STEPS_PER_BEAT)
-- == 0") que el real es puramente "al ras de la grilla de beats", sin
-- ningún mínimo -- en teoría el real PODRÍA cortar casi instantáneo si el
-- evento cae justo antes de un tick, igual que acá, pero el chart real
-- evidentemente lo evita por cómo está posicionado el timestamp del
-- evento contra el BPM. Sin poder verificar en un motor real si el
-- cálculo de beat de este puerto está en la MISMA fase exacta que
-- Conductor.currentStep, perseguir ese desajuste a ciegas es arriesgado
-- -- este mínimo es una red de seguridad pragmática: nunca corta antes de
-- este tiempo, así sea cual sea la fase real, kick2 siempre se ve un
-- rato razonable (mucho menos que sus 2.5s completos, pero no
-- instantáneo tampoco).
--
-- BUG corregido (round 35): 600ms resultó DEMASIADO ajustado en la
-- práctica -- spaghetti.json es BPM 111.5 (1 beat ~538ms), así que 600ms
-- ya cruzó el primer beat completo y el corte pasaba ahí mismo (apenas
-- ~24% de los 2.5s/60 frames reales de kick2, reportado como "a las
-- justas le da tiempo a reproducirse, parece bug"). Subido a un valor
-- más cómodo (todavía bien por debajo de sus 2.5s completos, pero deja
-- leerse la patada con claridad) -- sigue siendo un valor ajustado a
-- ojo, no medido contra un motor real corriendo (la nota de arriba sobre
-- por qué sigue aplicando) -- avisar si todavía se ve mal cortada o
-- termina viéndose demasiado larga.
local YUNJIN_KICK2_MIN_VISIBLE_MS = 1625

-- ── Cámara genérica del motor moderno (FocusCamera/ZoomCamera/
-- SetCameraBop/SetHealthIcon, los 4 tipos de evento que cubren 389 de los
-- 468 eventos reales del chart -- portados leyendo
-- Funkin-main/source/funkin/play/event/*SongEvent.hx directo, no
-- adivinados). Esta semana usa estos eventos para TODA la coreografía de
-- cámara (264 FocusCamera+ZoomCamera a lo largo de toda la canción) --
-- por eso se desactiva la cámara automática de weeks.lua por completo
-- (_G.disableAutoCam=true durante todo el gameplay, no solo la cutscene)
-- y se la reemplaza 100% por estos eventos, igual que el motor real
-- (que tampoco tiene auto-follow por nota -- cameraFollowPoint solo
-- cambia por estos eventos explícitos).
--
-- zoomBase: el "zoom limpio" que ZoomCamera tweenea (mode "stage" -- SIEMPRE
-- en este chart real, confirmado -- multiplica por defaultZoom=0.5).
-- bopMultiplier: el empuje rítmico de SetCameraBopSongEvent.hx real,
-- aplicado ENCIMA de zoomBase cada frame (cam.sizeX/Y = zoomBase * bopMultiplier)
-- -- fórmula de decaimiento exacta (PlayState.hx:1220-1225): decayRate=0.95,
-- lerp(1.0, bopMultiplier, 0.95^dt).
local zoomBase = { x = 0.5, y = 0.5 }
local bopMultiplier = 1.0
local bopRate, bopOffset, bopIntensity = 4, 0, 1.0
local lastStepNum = -1
-- camFocusXY (tweenCameraToPosition real -> cam.x/y) ya está forward-
-- declarado más arriba (ver bloque de cutscene) y se reutiliza acá tal
-- cual -- por eso este bloque NO lo redefine.

-- "#RRGGBB" / "0xAARRGGBB" -> {r,g,b} 0..1 (FlxColor.fromString real).
local function hexToRGB(hexStr)
	local hex = tostring(hexStr):gsub("^#", ""):gsub("^0[xX]", "")
	if #hex == 8 then hex = hex:sub(3) end -- descarta canal alpha (AARRGGBB)
	local r = tonumber(hex:sub(1, 2), 16) or 255
	local g = tonumber(hex:sub(3, 4), 16) or 255
	local b = tonumber(hex:sub(5, 6), 16) or 255
	return { r / 255, g / 255, b / 255 }
end

local function setDarkenAmt(darkAmt, duration)
	Timer.tween(duration, lightState, { darkenAmount = darkAmt }, "in-out-sine")
end

-- BUG corregido: FlxSprite.alpha REAL clampea automático a [0,1] al
-- asignarlo (set_alpha de Flixel, FlxMath.bound(value,0,1)) -- acá
-- "backLightColor.alpha"/"truckLight1.alpha" son campos sueltos sin
-- ningún clamp, y las intensidades reales del chart llegan hasta 1.8
-- (alpha = 1.8*0.8 = 1.44). El real LEE el alpha YA CLAMPEADO de vuelta
-- para mandárselo al shader (pulseLightStrength/truckLightStrength) --
-- sin este clamp, esos uniforms superan 1.0, lo que empuja la
-- luminancia (L) de rgb2hsl/hsl2rgb fuera de su rango válido y produce
-- colores rotos/cortados (RGB con componentes >1 o <0 sin clampear en
-- ningún punto del shader) -- el origen real de los "cortes con colores
-- mezclados".
local function clamp01(v)
	if v < 0 then return 0 end
	if v > 1 then return 1 end
	return v
end

local function flashTruckLights(amount, duration)
	if truckLight1 then
		truckLight1.alpha = clamp01(amount)
		Timer.tween(duration, truckLight1, { alpha = 0 }, "in-out-cubic", function()
			lightState.truckLightStrength = 0
		end)
	end
	if truckLight2 then
		truckLight2.alpha = clamp01(amount)
		Timer.tween(duration, truckLight2, { alpha = 0 }, "in-out-cubic")
	end
	lightState.truckLightStrength = truckLight1 and truckLight1.alpha or clamp01(amount)
end

local function flashBackLight(amount, duration, color)
	pulseLightColor = color or pulseLightColor
	if backLightColor then
		backLightColor.alpha = clamp01(amount * 0.8)
		Timer.tween(duration, backLightColor, { alpha = 0 }, "in-out-cubic", function()
			lightState.pulseLightStrength = 0
		end)
	end
	if backLightWhite then
		backLightWhite.alpha = clamp01(amount * 0.7)
		Timer.tween(duration, backLightWhite, { alpha = 0 }, "in-out-cubic")
	end
	lightState.pulseLightStrength = backLightColor and backLightColor.alpha or 0
end

local function setLightState(enabled, colors, durations, intensities)
	lightsEnabled = enabled or false
	if not (colors and durations and intensities) then return end
	lightsColors = {}
	for i, c in ipairs(colors) do lightsColors[i] = hexToRGB(c) end
	lightsDurations = durations
	lightsIntensities = intensities
end

local function setCoverVisible(visible)
	coverState.alpha = visible and 1.0 or 0.0
end

local function flashScreen(duration)
	triggerFlash(duration)
end

-- sserafimKick (sserafim.hxc:226-273) -- simplificado: se omite a
-- propósito la parte ligada a la cutscene todavía sin portar (mostrar el
-- prop "truckDoor" estático en el frame 23 de la animación de yunjin,
-- ocultar sserafimGf/sserafimBf -- sprites EXCLUSIVOS de la cutscene,
-- startClear()) -- se completa cuando se porte la cutscene de intro.
local function onSserafimKick(final)
	local yunjin = extraGirls.yunjin
	if not yunjin then return end

	if final then
		yunjin:animate("kick2", false)
		-- danceEvery=1 real -- ver comentario en la declaración de
		-- yunjinPendingIdleBeat más arriba. Se programa el cambio a
		-- "idle" para el próximo beat, en vez de esperar a que kick2
		-- termine sola.
		yunjinPendingIdleBeat = true
		yunjinKickStartTime = weeks:getMusicTime() or 0
		do
			local bpm = weeks:getBPM() or 0
			yunjinKickBeatNum = (bpm > 0) and math.floor((weeks:getMusicTime() or 0) * bpm / 60000) or -1
		end
		audio.playSound(love.audio.newSource("sounds/sserafim/doorKick2.ogg", "static"))

		-- startClear() real: arranca el desvanecido del polvo/ajuste de
		-- color de resetSserafimClear() de vuelta a neutral -- ver
		-- comentario ahí.
		startSserafimClear()

		if enemyIcon then enemyIcon.visible = true end

		-- BUG corregido: este bloque NUNCA se implementaba (quedó como
		-- TODO desde la ronda de la cutscene) -- sin esto, sserafimGf/Bf
		-- (los sprites de "levantarse" de la cutscene) se quedaban
		-- visibles y animando "getup" en bucle por el resto de la
		-- canción, la GF real NUNCA se mostraba (setCutsceneVisibility ya
		-- la oculta sin condición, ver comentario ahí -- el real cuenta
		-- con ESTE bloque para volver a mostrarla), y la puerta del
		-- camión nunca pasaba a su estado "abierta" estático.
		if cutsceneGfSprite then cutsceneGfSprite.visible = false end
		if cutsceneBfSprite then cutsceneBfSprite.visible = false end
		if girlfriend then girlfriend.visible = true end

		-- "at this point in the animation, the door is no longer part of
		-- her animation... show a static one!" (sserafim.hxc:253-255) --
		-- frame 23 RELATIVO al inicio de kick2 (real: onFrameChange con
		-- frameNumber==23) -- este motor no expone un callback por frame,
		-- se aproxima por tiempo a 24fps (MD.FRT confirmado del atlas).
		addCutsceneTimer(Timer.after(23 / 24, function()
			if truckDoor then truckDoor.alpha = 1 end
		end))
	else
		-- kick1 NO vuelve a idle sola -- se queda congelada en el último
		-- frame (loop:false real) hasta que kick2 dispare ~1.4s después
		-- (mismo intervalo real entre los 2 eventos del chart) -- recién
		-- kick2 hace "yunjin.danceEvery = 1" (vuelve a bailar normal).
		yunjin:animate("kick1", false)
		audio.playSound(love.audio.newSource("sounds/sserafim/doorKick1.ogg", "static"))
	end
end

-- Mismo patrón ya probado en weekend1 (cutscene de Darnell): re-disparar
-- "idle" cada vez que termina, porque estos 3 personajes NO pasan por el
-- ciclo de animación automático de weeks.lua (ningún slot los conoce).
idleLoop = function(name)
	local spr = extraGirls[name]
	if not spr then return end
	spr:animate("idle", false, function() idleLoop(name) end)
end

-- graphics.newImage() no expone :getWidth()/:getHeight() (solo el
-- love.graphics.Image crudo) -- se calcula el centro ANTES de envolver,
-- igual que stages/phillyStreets/stage.lua:loadCenteredImage().
local function loadCenteredImage(path, psychX, psychY)
	local raw = love.graphics.newImage(graphics.imagePath(path))
	local sprite = graphics.newImage(raw)
	sprite.x, sprite.y = psychX + raw:getWidth() / 2, psychY + raw:getHeight() / 2
	return sprite
end

-- ── PerspectiveSprite real (props/PerspectiveSprite.hxc) ─────────────────
-- El piso SIEMPRE visible del gameplay real -- DISTINTO del prop JSON
-- "fucker" (assetPath "floor", alpha=0.0 real, ver "floor" más arriba en
-- este archivo, que se mantiene en alpha=0 a propósito) -- ese prop es un
-- respaldo invisible; ESTE es el piso de verdad, con un skew entre dos
-- puntos (bottomObj/topObj) que sigue a la cámara cuadro a cuadro.
--
-- Flixel hace esto con una matriz de transformación manual
-- (FlxSkewedSprite). Acá se reproduce con los parámetros de shear NATIVOS
-- de love.graphics.draw(img,x,y,r,sx,sy,ox,oy,kx,ky), eligiendo el pivote
-- (ox,oy) en el CENTRO INFERIOR de la imagen: con ese pivote, el punto
-- inferior queda fijo en (x,y) sin que el shear/escala lo muevan, y se
-- resuelve kx/sy para que el punto SUPERIOR caiga exacto en topScreen --
-- derivación verificada a mano contra la fórmula real (distX/distY del
-- PerspectiveSprite.hxc original), no inventada.
--
-- bottomObj/topObj son PUNTOS (sin tamaño) en coordenadas de mundo
-- crudas -- no llevan la conversión de loadCenteredImage (esa conversión
-- es solo para sprites con ancho/alto reales que se posicionan por su
-- esquina superior izquierda; estos son puntos de referencia puros).
-- setPositions(760,1375,790,625) + setScrollFactors(1.05,1.05,0.93,0.93) reales.
local FLOOR_BOTTOM = { x = 760, y = 1375, sf = 1.05 }
local FLOOR_TOP    = { x = 790, y = 625,  sf = 0.93 }

local floorImageNormal, floorImageCutscene
local floorRawWidth, floorRawHeight

-- Misma fórmula que graphics.lua:pushParallax(sf), pero evaluada para un
-- punto puntual en vez de empujar toda la pila de transformaciones de
-- LÖVE2D -- necesario porque bottomObj y topObj tienen scrollFactor
-- DISTINTO entre sí (1.05 vs 0.93), así que ningún pushParallax() único
-- sirve para los dos a la vez.
local function perspectiveScreenPos(worldX, worldY, sf)
	local w, h = graphics.getWidth() / 2, graphics.getHeight() / 2
	return w + cam.sizeX * (worldX + w * (sf - 1) + cam.x * sf),
		h + cam.sizeY * (worldY + h * (sf - 1) + cam.y * sf)
end

local function drawPerspectiveFloor()
	local img = cutsceneActive and floorImageCutscene or floorImageNormal
	if not img or not floorRawHeight then return end

	local bx, by = perspectiveScreenPos(FLOOR_BOTTOM.x, FLOOR_BOTTOM.y, FLOOR_BOTTOM.sf)
	local tx, ty = perspectiveScreenPos(FLOOR_TOP.x, FLOOR_TOP.y, FLOOR_TOP.sf)

	local distX = tx - bx
	local kx = -distX / (cam.sizeX * floorRawHeight)
	local sy = (by - ty) / floorRawHeight

	if stageShader then love.graphics.setShader(stageShader) end
	love.graphics.draw(img, bx, by, 0, cam.sizeX, sy, floorRawWidth / 2, floorRawHeight, kx, 0)
	if stageShader then love.graphics.setShader() end
end

-- ── Polvo de la cutscene (4× FlxBackdrop reales, buildStage():104-144) ──
-- FlxBackdrop es un sprite que se TILEA infinito mientras escrollea --
-- este motor no tiene un equivalente nativo, así que se aproxima
-- dibujando la textura 2 veces lado a lado (suficiente: las texturas
-- reales son 2048x1280, ya mucho más grandes que la pantalla incluso a
-- escala 1) con el offset horizontal envuelto módulo el ancho de la
-- textura -- visualmente continuo, sin un sistema de tiling genérico.
-- Solo visible durante la cutscene (hideDust(!inCutscene) real).
local dustSprites = {}
-- Empieza en false (igual que el real: dust1-4 arrancan sin .visible
-- seteado hasta el primer setCutsceneVisibility(true), que las oculta
-- de una -- el polvo real solo aparece DESPUÉS del choque, durante
-- gameplay normal, nunca durante la cutscene en sí).
local dustVisible = false

local function loadDust()
	local function makeDust(path, x, y, sf, scale, r, g, b, alpha, velX)
		local raw = love.graphics.newImage(graphics.imagePath(path))
		return {
			image = raw, x = x, y = y, sf = sf, scale = scale,
			color = { r / 255, g / 255, b / 255 }, alpha = alpha,
			velX = velX, offsetX = 0, w = raw:getWidth(),
		}
	end
	dustSprites = {
		makeDust("sserafim/dust/dustMid",  -650, -200,  1.10, 1.5, 0x98, 0x84, 0x7d, 0.8, 350),
		makeDust("sserafim/dust/dustBack", -650, -250,  1.15, 1.5, 0x8b, 0x6c, 0x63, 0.9, -300),
		makeDust("sserafim/dust/dustMid",  -650, -400,  1.20, 2.0, 0x6e, 0x64, 0x5c, 0.8, -200),
		makeDust("sserafim/dust/dustBack", -650, -1300, 1.25, 3.5, 0x88, 0x6a, 0x60, 0.9, -150),
	}
end

local function updateDust(dt)
	for _, d in ipairs(dustSprites) do
		d.offsetX = d.offsetX + d.velX * dt
	end
end

local function drawDust()
	for _, d in ipairs(dustSprites) do
		local tileW = d.w * d.scale
		local wrapped = d.offsetX % tileW
		love.graphics.setColor(d.color[1], d.color[2], d.color[3], d.alpha)
		graphics.pushParallax(d.sf, d.sf)
			love.graphics.draw(d.image, d.x + wrapped, d.y, 0, d.scale, d.scale)
			love.graphics.draw(d.image, d.x + wrapped - tileW, d.y, 0, d.scale, d.scale)
		love.graphics.pop()
		love.graphics.setColor(1, 1, 1, 1)
	end
end

-- resetClear() real (sserafim.hxc:941-970) -- corre justo cuando se sale
-- del flash blanco del choque (timer 650/24). El polvo, DURANTE la
-- cutscene en sí, está más arriba y a media opacidad (0.8/0.9, ver
-- loadDust()) -- ACÁ se reposiciona más abajo (más cerca/denso) y a
-- alpha=1 completo (el "debe haber MÁS polvo" reportado), y se le aplica
-- al shader un ajuste de color (setAdjustColor(b,h,c,s) real -- orden
-- CONFIRMADO leyendo SserafimShader.hx: brillo,tono,contraste,
-- saturación) que tiñe TODA la escena (stage Y personajes) de un marrón/
-- rojizo desaturado y oscurecido -- el "todo empolvado, sucio y
-- colorado" reportado. Dura hasta que yunjin patea la puerta (kick2),
-- ver startSserafimClear()/onSserafimKick().
resetSserafimClear = function()
	if #dustSprites < 4 then return end
	-- NOTA: el real cancela tweens en curso de estas mismas propiedades
	-- antes de reasignarlas (FlxTween.cancelTweensOf) -- este motor no
	-- tiene un "cancelar tweens de este objeto" genérico (solo
	-- Timer.cancel(handle) con un handle guardado a mano), así que esto
	-- es un riesgo menor aceptado: si la canción se reinicia A MITAD del
	-- desvanecido de startSserafimClear(), un tween viejo podría seguir
	-- escribiendo y/alpha por encima de esto durante un instante -- mismo
	-- nivel de robustez que flashTruckLights()/flashBackLight() ya
	-- aceptan en este archivo, sin cancelación previa tampoco.
	local ys = { -400, -450, -600, -1500 }
	for i, d in ipairs(dustSprites) do
		d.y = ys[i]
		d.alpha = 1
	end
	colorAdjust.brightness, colorAdjust.hue = -24, 6
	colorAdjust.contrast, colorAdjust.saturation = -26, -74
end

-- startClear() real (sserafim.hxc:972-990) -- disparado por
-- onSserafimKick(final=true), ver ahí. Desvanece el polvo y el ajuste de
-- color de vuelta a neutral, cada capa de polvo con su propia duración
-- real (5/4/6/4 segundos * 4 -- sic, son esos los valores reales) además
-- de desplazarse un poco hacia abajo mientras se desvanece.
startSserafimClear = function()
	Timer.tween(6.0 * 4, colorAdjust, { brightness = 0, hue = 0, contrast = 0, saturation = 0 }, "out-sine")
	local durations = { 5.0 * 4, 4.0 * 4, 6.0 * 4, 4.0 * 4 }
	local dy = { 100, 200, 150, 100 }
	for i, d in ipairs(dustSprites) do
		Timer.tween(durations[i], d, { alpha = 0, y = d.y + dy[i] }, "out-sine")
	end
end

-- Factorizado de M.load() -- ver el comentario en createLipsyncSprites()
-- sobre el límite duro de Lua de 60 upvalues por función. Este bloque
-- solo (fondos/props/luces/floor) ya referenciaba ~19 variables de
-- estado distintas -- como función propia, M.load() solo necesita UNA
-- referencia (a esta función), no 19.
local function loadBackgroundProps()
	-- Posiciones/scroll EXACTOS de preload/data/stages/sserafim.json
	-- (props[].position/scroll) -- citados ahí, no inventados.
	bg         = loadCenteredImage("sserafim/bg",          -1853, -815)
	floor      = loadCenteredImage("sserafim/floor",         790,  625)
	backTables = loadCenteredImage("sserafim/back-tables", -1857,  267)
	backStools = loadCenteredImage("sserafim/back-stools", -1357,  426)
	truck      = loadCenteredImage("sserafim/truck-stuff",  -983, -707)
	truckDoor  = loadCenteredImage("sserafim/truck-door",   -980, -173)
	frontStool = loadCenteredImage("sserafim/front-stool",  -280,  818)

	-- BUG corregido: .alpha nunca se inicializaba para estos 5 -- en modo
	-- no-historia (freeplay) setCutsceneVisibility() NUNCA se llama, así
	-- que "if backTables.alpha > 0" comparaba contra nil y explotaba.
	-- Visibles por defecto (estado normal de gameplay); truckDoor oculto
	-- hasta el frame-23 real de kick2 (ver onSserafimKick).
	backTables.alpha = 1
	backStools.alpha = 1
	truck.alpha = 1
	frontStool.alpha = 1
	truckDoor.alpha = 0

	-- backTablesCutscene/burgerCutscene (props reales, sserafim.json):
	-- scale [400,1] real para backTablesCutscene -- una tira angosta
	-- (16x256 cruda) estirada horizontalmente a un mostrador largo.
	-- loadCenteredImage no sirve acá directo (asume escala 1 para el
	-- centrado) -- se calcula a mano con la escala real.
	do
		local rawBT = love.graphics.newImage(graphics.imagePath("sserafim/cutscene/counter-stretch"))
		backTablesCutscene = graphics.newImage(rawBT)
		backTablesCutscene.sizeX, backTablesCutscene.sizeY = 400, 1
		backTablesCutscene.x = -1858 + rawBT:getWidth() * 400 / 2
		backTablesCutscene.y = 377 + rawBT:getHeight() * 1 / 2
		backTablesCutscene.alpha = 0
	end
	burgerCutscene = loadCenteredImage("sserafim/cutscene/burger-cutscene", -97, 237)
	burgerCutscene.alpha = 0

	-- Luces: alpha=0.0 por defecto en el real (activadas por
	-- sserafimDark/sserafimLights/sserafimPulseLights, todavía sin
	-- portar) -- cargadas ya, listas para cuando se porten esos eventos.
	backLightColor = loadCenteredImage("sserafim/lights/back-light-color", -1241, -949)
	backLightWhite = loadCenteredImage("sserafim/lights/back-light-white",  -771, -599)
	truckLight1    = loadCenteredImage("sserafim/lights/truck-light1",      -962, -607)
	truckLight2    = loadCenteredImage("sserafim/lights/truck-light2",      -781, -464)
	backLightColor.alpha = 0
	backLightWhite.alpha = 0
	truckLight1.alpha = 0
	truckLight2.alpha = 0
	-- floor (prop "fucker" real) también arranca en alpha=0.0 en el JSON
	-- real -- el floor NORMAL de gameplay es perspectiveFloor (ver
	-- drawPerspectiveFloor() más arriba), cargado justo abajo. Se respeta
	-- el valor real del prop JSON acá.
	floor.alpha = 0

	local floorRaw = love.graphics.newImage(graphics.imagePath("sserafim/floor"))
	local floorCutsceneRaw = love.graphics.newImage(graphics.imagePath("sserafim/cutscene/floor-cutscene"))
	floorImageNormal, floorImageCutscene = floorRaw, floorCutsceneRaw
	floorRawWidth, floorRawHeight = floorRaw:getWidth(), floorRaw:getHeight()

	loadDust()
end

-- Factorizado de M.load() -- mismo motivo que loadBackgroundProps()
-- (límite duro de Lua de 60 upvalues por función) -- todos los
-- events.registerHandler(...) del chart real (sserafim.hxc:onSongEvent(),
-- líneas 203-277) en un solo bloque, referenciando ~20 variables/
-- funciones distintas que ya no cuentan para el presupuesto de M.load().
--
-- charts/psych/events.lua solo soporta {time,name,value1,value2} (dos
-- strings, igual que el formato Psych clásico) -- los arrays/objetos
-- reales (ej. sserafimShow:{visible:[bool×5]}) se codifican como strings
-- delimitados por comas en value1 (ver memoria del proyecto
-- "sserafim-port-research" sobre este problema de formato).
local function registerSserafimEvents()
	local function parseBoolArray(str)
		local arr = {}
		for tok in tostring(str or ""):gmatch("[^,]+") do
			table.insert(arr, tok == "1" or tok == "true")
		end
		return arr
	end

	events.registerHandler("sserafimShow", function(ev)
		M.setGirlsVisible(parseBoolArray(ev.value1))
	end)

	events.registerHandler("sserafimSing", function(ev)
		M.setGirlsSinging(parseBoolArray(ev.value1))
	end)

	events.registerHandler("sserafimBeautiful", function(ev)
		M.setBeautiful(ev.value1 == "1" or ev.value1 == "true")
	end)

	events.registerHandler("sserafimDark", function(ev)
		setDarkenAmt(tonumber(ev.value1) or 0, tonumber(ev.value2) or 0.5)
	end)

	events.registerHandler("sserafimLights", function(ev)
		flashTruckLights(tonumber(ev.value1) or 1, tonumber(ev.value2) or 0.5)
	end)

	events.registerHandler("sserafimCover", function(ev)
		setCoverVisible(ev.value1 == "1" or ev.value1 == "true")
	end)

	events.registerHandler("sserafimFlash", function(ev)
		flashScreen(tonumber(ev.value1) or 1)
	end)

	-- value2 (si está): "color1:dur1:int1,color2:dur2:int2,..." -- solo
	-- se usa cuando value1="1" Y el chart manda colores/duraciones/
	-- intensidades custom; si value2 viene vacío, se respeta el último
	-- set ya cargado (mismo criterio que el real: "if colors==null...
	-- return" sin tocar los arrays existentes).
	events.registerHandler("sserafimPulseLights", function(ev)
		local enabled = ev.value1 == "1" or ev.value1 == "true"
		if not ev.value2 or ev.value2 == "" then
			setLightState(enabled)
			return
		end
		local colors, durations, intensities = {}, {}, {}
		for entry in ev.value2:gmatch("[^,]+") do
			local c, d, i = entry:match("([^:]+):([^:]+):([^:]+)")
			table.insert(colors, c)
			table.insert(durations, tonumber(d))
			table.insert(intensities, tonumber(i))
		end
		setLightState(enabled, colors, durations, intensities)
	end)

	events.registerHandler("sserafimKick", function(ev)
		onSserafimKick(ev.value1 == "1" or ev.value1 == "true")
	end)

	events.registerHandler("sserafimEnd", function(ev)
		endStuff()
	end)

	-- ── Cámara genérica del motor moderno (FocusCamera/ZoomCamera/
	-- SetCameraBop/SetHealthIcon) -- ver el bloque de estado más arriba
	-- para el porqué de disableAutoCam permanente y zoomBase/bopMultiplier.
	--
	-- BUG corregido (round 35): "id" es el ID crudo del evento real
	-- (SetHealthIconSongEvent.hx real: "id" -- en este chart real, "bf"/
	-- "gf" para los íconos genéricos de boyfriend/girlfriend, igual
	-- convención que el nombre de archivo real icon-bf.png/icon-gf.png)
	-- -- se le pasaba DIRECTO a :animate() sin traducir, pero
	-- sprites/icons.lua registra esas 2 animaciones como "boyfriend"/
	-- "girlfriend" (nombres largos), NO "bf"/"gf" -- de ahí el warning
	-- "animación 'bf'/'gf' no existe en sprite". Las otras 5 chicas
	-- (kazuha/chaewon/eunchae/yunjin/sakura) coinciden directo porque sus
	-- IDs de ícono YA son iguales a sus nombres registrados -- solo
	-- bf/gf necesitan este mapeo especial.
	local HEALTH_ICON_ID_MAP = { bf = "boyfriend", gf = "girlfriend" }
	events.registerHandler("SetHealthIcon", function(ev)
		local id = HEALTH_ICON_ID_MAP[ev.value1] or ev.value1
		local char = tonumber(ev.value2) or 1
		if char == 0 then
			if boyfriendIcon then icons.animate(boyfriendIcon, id, false) end
		else
			if enemyIcon then icons.animate(enemyIcon, id, false) end
		end
	end)

	events.registerHandler("SetCameraBop", function(ev)
		local rate, offset, intensity = ev.value1:match("([^:]+):([^:]+):([^:]+)")
		bopRate = tonumber(rate) or 4
		bopOffset = tonumber(offset) or 0
		bopIntensity = tonumber(intensity) or 1.0
	end)

	-- FocusCamera real: char SIEMPRE -1 en este chart (confirmado contra
	-- spaghetti-chart.json) -- x,y ya vienen resueltos a coordenadas de
	-- mundo directas desde el conversor Python, sin offset de personaje.
	events.registerHandler("FocusCamera", function(ev)
		local x, y, dur = ev.value1:match("([^:]+):([^:]+):([^:]+)")
		x, y, dur = tonumber(x), tonumber(y), tonumber(dur)
		local ease = ev.value2

		if ease == "instant" or ease == "classic" then
			cam.x, cam.y = camFocusXY(x, y)
		else
			local tx, ty = camFocusXY(x, y)
			Timer.tween(dur, cam, { x = tx, y = ty }, ease)
		end
	end)

	-- ZoomCamera real: tweenea zoomBase (el "zoom limpio"), NO cam.sizeX/Y
	-- directo -- el bop rítmico (M.update) multiplica encima cada frame.
	events.registerHandler("ZoomCamera", function(ev)
		local zoom, dur = ev.value1:match("([^:]+):([^:]+)")
		zoom, dur = tonumber(zoom), tonumber(dur)
		local ease = ev.value2

		if ease == "instant" then
			zoomBase.x, zoomBase.y = zoom, zoom
		else
			Timer.tween(dur, zoomBase, { x = zoom, y = zoom }, ease)
		end
	end)
end

-- Factorizado de M.load() -- mismo motivo que loadBackgroundProps()/
-- registerSserafimEvents() (límite duro de Lua de 60 upvalues por
-- función). createCutsceneSprites() real (sserafim.hxc:628-678) -- se
-- crean siempre (igual que el real, una sola vez en buildStage()),
-- ocultos hasta que M.startCutscene() los active. Posiciones/alpha/
-- scrollFactor EXACTOS del real.
--
-- BUG corregido: estos 3 también necesitan la corrección de origen
-- (modo "topleft" -- ver character.lua:getOrigin() -- no heredan de
-- BaseCharacter, así que NO es el modo "feet", pero Flixel SÍ ancla su
-- x,y a la esquina superior izquierda del bounding box real, algo que
-- este motor tampoco hacía antes) -- los ajustes a mano de la ronda
-- anterior (con sserafim-cutscene-debug.lua) compensaban justamente
-- esto a ciegas; ya no son necesarios con el origen real aplicado, así
-- que se revierte a los valores reales 1:1.
local function createCutsceneSprites()
	cutsceneMainSprite = character.load("characters/sserafim-cutscene-main.json", false)
	do
		local ox, oy = cutsceneMainSprite:getOrigin()
		cutsceneMainSprite.x, cutsceneMainSprite.y = -395 + ox, 10 + oy
	end
	cutsceneMainSprite.shader = characterShader
	cutsceneMainSprite.visible = false

	-- Ajuste fino agregado a mano (-22,-111) sobre el real (655,-104),
	-- encontrado con states/sserafim-cutscene-debug.lua (fase 1b) -- la
	-- fórmula "topleft" la acercó mucho pero no exacto.
	cutsceneGfSprite = character.load("characters/sserafim-gf-getup.json", false)
	do
		local ox, oy = cutsceneGfSprite:getOrigin()
		cutsceneGfSprite.x, cutsceneGfSprite.y = (655 - 22) + ox, (-104 - 111) + oy
	end
	cutsceneGfSprite.shader = characterShader
	cutsceneGfSprite.alpha = 0.5
	cutsceneGfSprite.visible = false

	-- Ajuste fino agregado a mano (+0,+170) sobre el real (1220,531).
	cutsceneBfSprite = character.load("characters/sserafim-bf-getup.json", false)
	do
		local ox, oy = cutsceneBfSprite:getOrigin()
		cutsceneBfSprite.x, cutsceneBfSprite.y = 1220 + ox, (531 + 170) + oy
	end
	cutsceneBfSprite.shader = characterShader
	cutsceneBfSprite.visible = false

	-- SEEYOU1/2 (createCutsceneSprites() real, líneas 656-677) -- screen-
	-- space, mismas escalas/posiciones reales (0.67, centrado/esquina
	-- inferior derecha con margen 40px sobre 1280x720, la resolución base
	-- de este motor -- ver main.lua:93).
	do
		local raw1 = love.graphics.newImage(graphics.imagePath("sserafim/end/end1"))
		seeyou1 = graphics.newImage(raw1)
		seeyou1.sizeX, seeyou1.sizeY = 0.67, 0.67
		seeyou1.x, seeyou1.y = 640, 360
		seeyou1.visible = false

		local raw2 = love.graphics.newImage(graphics.imagePath("sserafim/end/end2"))
		seeyou2 = graphics.newImage(raw2)
		seeyou2.sizeX, seeyou2.sizeY = 0.67, 0.67
		seeyou2.x = 1280 - 40 - (raw2:getWidth() * 0.67) / 2
		seeyou2.y = 720 - 40 - (raw2:getHeight() * 0.67) / 2
		seeyou2.visible = false
	end
end

function M.load(songNum)
	loadBackgroundProps()

	psychStages.apply("sserafim")

	-- El motor real NO tiene auto-follow por nota en esta canción -- la
	-- cámara es 100% manejada por FocusCamera/ZoomCamera (264 eventos a lo
	-- largo de toda la canción, ver bloque de estado más arriba) -- se
	-- desactiva la cámara automática de este motor por completo, dejando
	-- la posición que psychStages.apply() ya calculó como punto de partida
	-- (evita un salto en el primer frame, antes de que llegue el primer
	-- evento del chart).
	_G.disableAutoCam = true
	zoomBase.x, zoomBase.y = cam.sizeX or 0.5, cam.sizeY or 0.5
	bopMultiplier = 1.0
	bopRate, bopOffset, bopIntensity = 4, 0, 1.0
	lastStepNum = -1

	-- BUG corregido (era exactamente al revés): estado inicial real
	-- (baseVisible/baseSinging, sserafim.hxc:28-29) -- SOLO yunjin arranca
	-- visible (está afuera rompiendo la puerta del camión, kick1/kick2 ya
	-- disparan en los primeros ~2.5s reales del chart, ANTES de que
	-- exista ningún evento sserafimShow -- confirmado: el primer
	-- sserafimShow real recién aparece en t=13183ms). kazuha/chaewon/
	-- eunchae/sakura(boyfriend) arrancan TODAS ocultas -- addCharacter()
	-- real les aplica baseVisible[target] una sola vez al construir el
	-- stage, antes de que cuente el countdown. "Nadie cantando" al
	-- principio (baseSinging todo false) también es real -- el bf/sakura
	-- sigue animando notas por el mecanismo normal del motor
	-- (independiente de girlSinging), pero como boyfriend.visible=false
	-- todavía no se VE -- coincide con que en el video real no se ve a
	-- nadie reaccionando hasta que yunjin termina de abrir la puerta.
	girlVisible = { yunjin = true, kazuha = false, chaewon = false, eunchae = false, sakura = false }
	girlSinging = { yunjin = false, kazuha = false, chaewon = false, eunchae = false, sakura = false, girlfriend = false }
	isBeautiful = false

	extraGirls.yunjin  = loadExtraGirl("characters/sserafim-yunjin.json")
	extraGirls.chaewon = loadExtraGirl("characters/sserafim-chaewon.json")
	extraGirls.eunchae = loadExtraGirl("characters/sserafim-eunchae.json")
	-- BUG corregido: yunjin arranca en "doorclosed" (primera animación del
	-- JSON, su pose por defecto antes de patear -- sserafim.hxc nunca
	-- llama nada de animación para ella hasta el primer sserafimKick) --
	-- forzarla a "idle" (bailando) de una la dejaba bailando ANTES de
	-- siquiera patear la puerta. Solo chaewon/eunchae arrancan en su loop
	-- de idle normal -- yunjin entra al loop recién en onSserafimKick(true).
	for name in pairs(extraGirls) do
		if name ~= "yunjin" then idleLoop(name) end
	end

	-- Lipsync: una instancia por cada una de las 5 (ver LIPSYNC_DATA más
	-- arriba) -- gf excluida a propósito, no tiene lipsync en el real.
	-- Factorizado a una función aparte (BUG corregido: M.load() es TAN
	-- grande que ya estaba cerca del límite duro de Lua de 60 upvalues
	-- por función -- referenciar LIPSYNC_DATA/lipsyncSprites/
	-- lipsyncMouthMat/lipsync directo acá lo hacía pasarse del límite,
	-- "function at line 599 has more than 60 upvalues" -- factorizarlo a
	-- una función propia cuenta como UNA sola referencia desde M.load(),
	-- no cuatro).
	createLipsyncSprites()

	-- Aplica el estado inicial recién armado a los sprites reales (los 3
	-- extra ya existen acá; boyfriend/enemy ya los creó psychStages.apply()
	-- más arriba). girlfriend NO está en este array (real: "gf visibility
	-- ISNT stored here") -- arranca oculta a mano, igual que
	-- baseVisible[5]=false, y solo sserafimKick(final=true) la revela.
	if extraGirls.yunjin  then extraGirls.yunjin.visible  = girlVisible.yunjin  end
	if extraGirls.chaewon then extraGirls.chaewon.visible = girlVisible.chaewon end
	if extraGirls.eunchae then extraGirls.eunchae.visible = girlVisible.eunchae end
	if enemy      then enemy.visible      = girlVisible.kazuha end
	if boyfriend  then boyfriend.visible  = girlVisible.sakura end
	if girlfriend then girlfriend.visible = false end

	-- sserafimBeautiful (ver comentario arriba en installGirlfriendBeautifulWrapper()):
	-- esto es solo la carga INICIAL -- M.onCharacterReload() reinstala lo
	-- mismo cuando weeks.lua reemplaza este sprite por el real de la canción.
	installGirlfriendBeautifulWrapper(girlfriend)

	lightState.darkenAmount = 0
	lightState.truckLightStrength = 0
	lightState.pulseLightStrength = 0
	lightsEnabled = false
	coverState.alpha = 0
	flashAlpha = 0
	lastBeatNum = -1
	yunjinPendingIdleBeat = false
	yunjinKickBeatNum = -1
	yunjinKickStartTime = 0

	registerSserafimEvents()

	-- ── Shader HSL real (addCharacter()/addProp(), sserafim.hxc:175-177 y
	-- 383-411) ── characterShader: boyfriend/girlfriend/enemy/extraGirls
	-- (isChar=true). stageShader: props de fondo (isChar=false) EXCEPTO
	-- truckLight1/2, backLightColor/White y solidCover, que el real deja
	-- explícitamente sin shader ("prop.shader = null").
	characterShader = love.graphics.newShader("shaders/sserafim.glsl")
	stageShader = love.graphics.newShader("shaders/sserafim.glsl")
	characterShader:send("isChar", true)
	stageShader:send("isChar", false)
	colorAdjust.hue, colorAdjust.saturation = 0, 0
	colorAdjust.brightness, colorAdjust.contrast = 0, 0

	if boyfriend  then boyfriend.shader  = characterShader end
	if girlfriend then girlfriend.shader = characterShader end
	if enemy      then enemy.shader      = characterShader end
	if extraGirls.yunjin  then extraGirls.yunjin.shader  = characterShader end
	if extraGirls.chaewon then extraGirls.chaewon.shader = characterShader end
	if extraGirls.eunchae then extraGirls.eunchae.shader = characterShader end

	bg.shader = stageShader
	floor.shader = stageShader
	backTables.shader = stageShader
	backStools.shader = stageShader
	truck.shader = stageShader
	truckDoor.shader = stageShader
	frontStool.shader = stageShader

	createCutsceneSprites()
end

-- API pública para los eventos custom de arriba -- también queda
-- disponible si se necesita llamar a mano (debug, etc.).
-- visible/singing: arrays Lua 1-indexados, MISMO orden que el real --
-- visible={yunjin,kazuha,chaewon,eunchae,sakura} (5),
-- singing={yunjin,kazuha,chaewon,eunchae,sakura,girlfriend} (6).
-- BUG corregido: esto mutaba girlVisible (el equivalente de baseVisible
-- real) en cada llamada -- el real setGirlsVisible() (sserafim.hxc:289-
-- 303) SOLO asigna ".visible" a cada sprite, JAMÁS toca baseVisible (es
-- el "estado real" congelado al construir el stage, de ahí el nombre).
-- Mutarlo acá rompía setCutsceneVisibility(true) -> setGirlsVisible(todo
-- false): pisaba girlVisible.yunjin a false, así que cuando
-- setCutsceneVisibility(false) llamaba setGirlsVisible({girlVisible.yunjin,
-- ...}) más tarde para restaurar, ya no tenía el "true" original para
-- devolverle -- yunjin (la única visible desde el arranque real) se
-- quedaba invisible hasta el primer evento sserafimShow posterior
-- (mucho más tarde, justo antes de que aparezca kazuha) en vez de
-- recuperar su visibilidad apenas termina la cinematica.
function M.setGirlsVisible(visible)
	if extraGirls.yunjin  then extraGirls.yunjin.visible  = visible[1] or false end
	if enemy then enemy.visible = visible[2] or false end
	if extraGirls.chaewon then extraGirls.chaewon.visible = visible[3] or false end
	if extraGirls.eunchae then extraGirls.eunchae.visible = visible[4] or false end
	if boyfriend then boyfriend.visible = visible[5] or false end
end

function M.setGirlsSinging(singing)
	girlSinging.yunjin     = singing[1] or false
	girlSinging.kazuha     = singing[2] or false
	girlSinging.chaewon    = singing[3] or false
	girlSinging.eunchae    = singing[4] or false
	girlSinging.sakura     = singing[5] or false
	girlSinging.girlfriend = singing[6] or false
end

function M.setBeautiful(beautiful)
	isBeautiful = beautiful
end

-- BUG corregido (modelo completo, encontrado leyendo
-- funkin/play/character/BaseCharacter.hx real): NO es "redirigir notas de
-- enemigo a quien esté cantando" -- es que CADA UNA de las 6 (incluidas
-- kazuha/sakura, no solo las 4 extra) reacciona según su PROPIO
-- characterType actual, sin importar qué slot físico ocupe:
--   characterType==BF  (girlSinging.X==true,  es su turno) -> reacciona a
--     notas del JUGADOR (boyfriend)
--   characterType==DAD (girlSinging.X==false, NO es su turno) -> reacciona
--     a notas del OPONENTE (enemy)
-- (BaseCharacter.hx:535-567, onNoteHit: "getMustHitNote() && BF" /
-- "!getMustHitNote() && DAD"). stages/sserafim.hxc:309-318 confirma que
-- sserafimSing reasigna characterType de las 6 -- incluyendo
-- getDad()/getBoyfriend() -- con el MISMO singingArray que ya tengo como
-- girlSinging. Antes esto solo cubría las 4 "extra" y solo cuando
-- girlSinging.X era true -- por eso kazuha/sakura (su propio caso DAD por
-- defecto) funcionaban por casualidad vía el slot normal, pero
-- chaewon/eunchae/yunjin/girlfriend (sin slot, sin mecanismo DAD-por-
-- defecto propio) se quedaban en idle el resto de la canción, cuando en
-- realidad TODAS deberían reaccionar a las notas de enemigo salvo cuando
-- es su propio turno.
function M.customEnemyNoteHit(self, curAnim, note, enemySprite)
	if not girlSinging.kazuha     and enemy             then enemy:animate(curAnim, false);             resetSingHold("kazuha") end
	if not girlSinging.yunjin     and extraGirls.yunjin  then extraGirls.yunjin:animate(curAnim, false);  resetSingHold("yunjin") end
	if not girlSinging.chaewon    and extraGirls.chaewon then extraGirls.chaewon:animate(curAnim, false); resetSingHold("chaewon") end
	if not girlSinging.eunchae    and extraGirls.eunchae then extraGirls.eunchae:animate(curAnim, false); resetSingHold("eunchae") end
	if not girlSinging.girlfriend and girlfriend         then girlfriend:animate(curAnim, false);         resetSingHold("girlfriend") end
	if not girlSinging.sakura     and boyfriend          then boyfriend:animate(curAnim, false);          resetSingHold("sakura") end
	return true
end

-- Notas con "kind" custom (sakura-joint/sakura-bf1/sakura-bf2, ver chart
-- real convertido) -- duetos posados de Sakura con otra chica de fondo.
-- El .hxc real no hace nada especial en onNoteHit() (líneas 182-186); la
-- selección de animación por "kind" vive en el motor base (no portado
-- acá) -- esta es la interpretación directa más simple y fiel: redirigir
-- la animación de Sakura al set "-joint"/"-bf1"/"-bf2" (ver los nombres
-- exactos en characters/sserafim-sakura.json) en vez del set normal.
local function kindSuffix(noteTypeStr)
	if noteTypeStr == "sakura-joint" or noteTypeStr == "sakura-bf1" or noteTypeStr == "sakura-bf2" then
		return noteTypeStr:sub(7) -- "sakura-joint" -> "-joint" (el prefijo "sakura-" mide 7)
	end
	return nil
end

-- IMPORTANTE: curAnim que llega acá ya viene traducido a la convención
-- INTERNA de este motor ("left"/"down"/"up"/"right" -- ver animList en
-- states/weeks.lua) -- NO es el string crudo "singLEFT" del JSON. Y
-- charts/psych/animnames.lua:toInternal() solo reconoce los patrones
-- "-alt"/"miss" -- un sufijo nuevo como "-joint" no matchea ninguno de
-- sus 4 patrones, así que pasa SIN TRANSFORMAR (la animación queda
-- registrada en animLookup bajo el string CRUDO del JSON, ej.
-- "singLEFT-joint", no "left-joint"). Por eso se reconstruye el nombre
-- crudo a mano acá en vez de concatenar curAnim directo.
--
-- También cubre la mitad "characterType==BF reacciona a notas de
-- jugador" del modelo de arriba: si NO es el turno de sakura (DAD-type),
-- su propio cuerpo no debe reaccionar a las notas del jugador -- eso ya
-- lo cubre customEnemyNoteHit (ella reacciona a las de enemigo en su
-- lugar) -- así que se bloquea el fallback genérico de weeks.lua en ese
-- caso. Las otras 5 (incluida kazuha) se animan acá DIRECTO cuando es su
-- turno (characterType==BF), sin bloquear nada de sakura/boyfriend.
function M.customNoteHit(self, curAnim, note, boyfriend)
	local suffix = kindSuffix(note.noteTypeStr)
	if suffix then
		boyfriend:animate("sing" .. curAnim:upper() .. suffix, false)
	end

	if girlSinging.kazuha     and enemy             then enemy:animate(curAnim, false);             resetSingHold("kazuha") end
	if girlSinging.yunjin     and extraGirls.yunjin  then extraGirls.yunjin:animate(curAnim, false);  resetSingHold("yunjin") end
	if girlSinging.chaewon    and extraGirls.chaewon then extraGirls.chaewon:animate(curAnim, false); resetSingHold("chaewon") end
	if girlSinging.eunchae    and extraGirls.eunchae then extraGirls.eunchae:animate(curAnim, false); resetSingHold("eunchae") end
	if girlSinging.girlfriend and girlfriend         then girlfriend:animate(curAnim, false);         resetSingHold("girlfriend") end
	if girlSinging.sakura then resetSingHold("sakura") end

	if suffix then return true end
	return not girlSinging.sakura
end

-- Mismo modelo que customNoteHit -- "miss" en la convención INTERNA es
-- "miss " .. direccion (animnames.lua: "singLEFTmiss" -> "miss left"), NO
-- direccion.."miss" (eso solo aplica al sufijo crudo "-joint"/"-bf2" de
-- sakura, que no se traduce).
function M.customNoteMiss(self, curAnim, note, boyfriend)
	local suffix = kindSuffix(note.noteTypeStr)
	-- "-bf1" no tiene variante de miss propia (ver sserafim-sakura.json) --
	-- cae al miss normal en ese caso.
	local hasOwnMiss = suffix and suffix ~= "-bf1"
	if hasOwnMiss then
		boyfriend:animate("sing" .. curAnim:upper() .. "miss" .. suffix, false)
	end

	local missAnim = "miss " .. curAnim
	if girlSinging.kazuha     and enemy             then enemy:animate(missAnim, false) end
	if girlSinging.yunjin     and extraGirls.yunjin  then extraGirls.yunjin:animate(missAnim, false) end
	if girlSinging.chaewon    and extraGirls.chaewon then extraGirls.chaewon:animate(missAnim, false) end
	if girlSinging.eunchae    and extraGirls.eunchae then extraGirls.eunchae:animate(missAnim, false) end
	if girlSinging.girlfriend and girlfriend         then girlfriend:animate(missAnim, false) end

	if hasOwnMiss then return true end
	return not girlSinging.sakura
end

-- BUG corregido: weeks.lua tiene un hook genérico "customNoteHold" para
-- el tramo sostenido de una nota larga (igual patrón que customNoteHit
-- para el golpe inicial) que Sserafim nunca implementaba -- sin esto, en
-- CUANTO una nota larga con kind (sakura-joint/bf1/bf2) entraba en su
-- tramo "hold"/"end", weeks.lua volvía a la animación PLANA sin sufijo
-- (curAnim solo, ej. "singLEFT") en vez de mantener "singLEFT-joint" que
-- el golpe inicial ya había puesto -- la pose dueto se cortaba apenas
-- empezaba a sostenerse la nota.
function M.customNoteHold(self, curAnim, note, boyfriend)
	local suffix = kindSuffix(note.noteTypeStr)
	if not suffix then return false end
	boyfriend:animate("sing" .. curAnim:upper() .. suffix, true)
	return true
end

-- BUG corregido: M.load() (más arriba) asigna characterShader a
-- boyfriend/girlfriend/enemy UNA SOLA VEZ, pero corre ANTES de que
-- weeks.lua:applyChartMeta() reemplace esos 3 sprites por los reales de
-- ESTA canción (ver weeks/sserafim.lua:enter() -- self:loadStage() antes
-- de self:load()/loadChart()) -- la asignación de M.load() le pega al
-- sprite VIEJO (semana/canción anterior, o nil), nunca al nuevo. Como
-- depende de qué hubiera en _G.boyfriend/girlfriend/enemy ANTES de
-- entrar (primera vez, reintento, semana anterior), a quién le queda
-- pegado el shader parece aleatorio entre partidas. Hook opt-in llamado
-- por weeks.lua justo después de cada loadInto() exitoso, para re-aplicar
-- el shader al sprite REAL recién cargado.
--
-- BUG corregido (mismo mecanismo, otra propiedad): el sprite NUEVO que
-- crea loadInto() también pisa la VISIBILIDAD que M.load() ya había
-- aplicado (girlVisible.kazuha/sakura = false al arranque) -- character.
-- load() no tiene por qué arrancar oculto, así que el sprite nuevo queda
-- visible por defecto. Reportado en Freeplay (sin cinematica): kazuha
-- visible desde el inicio cuando debería arrancar oculta hasta su primer
-- evento sserafimShow real.
function M.onCharacterReload(self, slot, sprite)
	if characterShader and sprite then
		sprite.shader = characterShader
	end
	if slot == "enemy" then
		sprite.visible = girlVisible.kazuha
	elseif slot == "boyfriend" then
		sprite.visible = girlVisible.sakura
	elseif slot == "girlfriend" then
		-- gf no está en girlVisible (igual que el real, "gf visibility
		-- ISNT stored here") -- arranca oculta a mano, solo
		-- onSserafimKick(final=true) la revela.
		sprite.visible = false
		-- BUG corregido (round 35): ver comentario en
		-- installGirlfriendBeautifulWrapper() -- sin esto, el girlfriend
		-- REAL (este "sprite", el que de verdad se usa durante el
		-- gameplay) nunca recibía el wrapper -- quedaba pegado al objeto
		-- viejo que M.load() ve antes de que weeks.lua haga el reemplazo.
		installGirlfriendBeautifulWrapper(sprite)
	end
end

-- Actualiza el sprite de lipsync de UN personaje: encuentra dónde cae el
-- placeholder de boca en su frame ACTUAL, actualiza el offset/ángulo fino
-- si la pose actual está en la tabla (igual condición que el real,
-- "LIP_SYNC_OFFSETS.exists(name)"), y fija shouldSing.
local function updateLipsyncFor(name, ownerSprite, shouldSing)
	local lip = lipsyncSprites[name]
	if not lip or not ownerSprite then return end

	local ld = LIPSYNC_DATA[name]
	local ownerInst = ownerSprite:getAtlasInstance()
	lipsyncMouthMat[name] = animateAtlas.findNamedTransform(ownerInst, ld.keyword)

	local pose = ld.poses[ownerSprite:getAnimName()]
	if pose then
		lip:setPoseOffset(pose[1], pose[2], pose[3])
	end

	lip.shader = ownerSprite.shader
	lip.shouldSing = shouldSing
	lip:update(weeks:getMusicTime() or 0)
end

function M.update(dt)
	if extraGirls.yunjin  then extraGirls.yunjin:update(dt) end
	if extraGirls.chaewon then extraGirls.chaewon:update(dt) end
	if extraGirls.eunchae then extraGirls.eunchae:update(dt) end

	-- Reposicionar DESPUÉS de actualizar -- ver repositionExtraGirl() más
	-- arriba sobre por qué esto tiene que recalcularse cada frame en vez
	-- de una sola vez al cargar.
	repositionExtraGirl(extraGirls.yunjin)
	repositionExtraGirl(extraGirls.chaewon)
	repositionExtraGirl(extraGirls.eunchae)

	-- Ver comentario de singHoldTimer/updateSingHoldRevert más arriba.
	-- sakura/boyfriend SOLO se chequea acá cuando NO es su propio turno
	-- (girlSinging.sakura==false) -- cuando SÍ lo es, weeks.lua YA la
	-- maneja con su propio mecanismo de nota sostenida (que sabe
	-- distinguir "el jugador sigue sosteniendo la nota" de "ya soltó"),
	-- y este timer simplificado no -- aplicarlo ahí cortaría una nota
	-- sostenida real antes de tiempo.
	-- girlfriend NO entra acá -- a diferencia de las otras 5, ella no
	-- tiene animación "idle" (solo danceLeft/danceRight, ver su JSON
	-- real), así que el ":animate('idle', true)" de updateSingHoldRevert
	-- fallaba siempre para ella (WARN "animación 'idle' no existe...",
	-- sin efecto real). weeks.lua:triggerDanceBeat() ya la devuelve a
	-- danceLeft/danceRight sola una vez que termina de cantar (con el
	-- guard "gfBusy" agregado en la ronda anterior) -- no hace falta este
	-- timer para ella.
	updateSingHoldRevert(dt, "kazuha",     enemy)
	updateSingHoldRevert(dt, "yunjin",     extraGirls.yunjin)
	updateSingHoldRevert(dt, "chaewon",    extraGirls.chaewon)
	updateSingHoldRevert(dt, "eunchae",    extraGirls.eunchae)
	if not girlSinging.sakura then
		updateSingHoldRevert(dt, "sakura", boyfriend)
	end

	-- BUG corregido: shouldSing de sakura estaba en `true` fijo, asumiendo
	-- que el slot boyfriend siempre es characterType.BF -- FALSO. El real
	-- (stages/sserafim.hxc, ver más abajo en customEnemyNoteHit/
	-- customNoteHit) REASIGNA characterType de LAS 6 -- incluida sakura --
	-- cada vez que corre sserafimSing: BF si es su turno (singingArray[i]),
	-- DAD si no. lipSyncSprite.shouldSing = characterType==BF en las 5 sin
	-- excepción -- sakura NO es la excepción que el comentario viejo decía,
	-- solo sigue girlSinging.sakura igual que las demás.
	updateLipsyncFor("sakura",  boyfriend, girlSinging.sakura)
	updateLipsyncFor("kazuha",  enemy, girlSinging.kazuha)
	updateLipsyncFor("chaewon", extraGirls.chaewon, girlSinging.chaewon)
	updateLipsyncFor("eunchae", extraGirls.eunchae, girlSinging.eunchae)
	updateLipsyncFor("yunjin",  extraGirls.yunjin, girlSinging.yunjin)

	if cutsceneMainSprite then cutsceneMainSprite:update(dt) end
	if cutsceneGfSprite then cutsceneGfSprite:update(dt) end
	if cutsceneBfSprite then cutsceneBfSprite:update(dt) end

	if dustVisible then updateDust(dt) end

	-- Skip de un solo toque (CUTSCENE_ADVANCE real, sserafim.hxc:529-549
	-- -- a diferencia de Tankman/semana 7, NO tiene el dial de 1s
	-- sostenido, alcanza con una pulsación). Detección por flanco (down
	-- ahora, no estaba abajo el frame anterior) porque input:down() es
	-- continuo, no "justPressed".
	if cutsceneActive and not cutsceneSkipped then
		local confirmDown = input:down("confirm")
		if confirmDown and not confirmWasDown then
			skipCutscene()
		end
		confirmWasDown = confirmDown
	end

	-- Sincroniza los uniforms del shader HSL cada frame -- lightState/
	-- pulseLightColor cambian por Timer.tween (setDarkenAmt/
	-- flashTruckLights/flashBackLight más arriba), no por asignación
	-- directa, así que el envío se hace acá en vez de en cada setter.
	if characterShader and stageShader then
		for _, shader in ipairs({ characterShader, stageShader }) do
			shader:send("darkAmt", lightState.darkenAmount)
			shader:send("lightColor", pulseLightColor)
			shader:send("pulseStrength", lightState.pulseLightStrength)
			shader:send("truckStrength", lightState.truckLightStrength)
			shader:send("hue", colorAdjust.hue)
			shader:send("saturation", colorAdjust.saturation)
			shader:send("brightness", colorAdjust.brightness)
			shader:send("contrast", colorAdjust.contrast)
		end
	end

	if flashAlpha > 0 then
		flashAlpha = math.max(0, flashAlpha - dt / flashDuration)
	end

	-- yunjinPendingIdleBeat: ver comentario en su declaración -- corta
	-- kick2 al "idle" en el primer beat posterior a cuando arrancó, en
	-- vez de esperar sus 2.5s completos.
	if yunjinPendingIdleBeat then
		local bpm = weeks:getBPM() or 0
		if bpm > 0 then
			local musicTime = weeks:getMusicTime() or 0
			local beat = math.floor(musicTime * bpm / 60000)
			if beat > yunjinKickBeatNum and (musicTime - yunjinKickStartTime) >= YUNJIN_KICK2_MIN_VISIBLE_MS then
				yunjinPendingIdleBeat = false
				idleLoop("yunjin")
			end
		end
	end

	-- onBeatHit (sserafim.hxc:498-505) -- "beat" real = negra (quarter
	-- note), igual que Conductor.currentBeat -- este motor no expone un
	-- callback de beat a nivel stage, así que se detecta por polling
	-- (mismo criterio que phillyBlazin/phillyStreets ya usan con
	-- lastBeatNum).
	if lightsEnabled and #lightsColors > 0 then
		local bpm = weeks:getBPM() or 0
		if bpm > 0 then
			local beat = math.floor((weeks:getMusicTime() or 0) * bpm / 60000)
			if beat > lastBeatNum then
				lastBeatNum = beat
				local n = #lightsColors
				flashBackLight(
					lightsIntensities[(beat % n) + 1],
					lightsDurations[(beat % n) + 1],
					lightsColors[(beat % n) + 1]
				)
			end
		end
	end

	-- SetCameraBopSongEvent / PlayState.hx:1849-1862,1220-1230 reales --
	-- "step" (no beat) es la granularidad real del chequeo de bop, 4 steps
	-- por beat (Constants.STEPS_PER_BEAT). Se omite durante la cutscene
	-- (esa cámara se maneja 100% a mano, ver introCutscene) para no pelear
	-- por cam.sizeX/Y cuadro a cuadro.
	if not cutsceneActive then
		local bpm = weeks:getBPM() or 0
		if bpm > 0 and bopRate > 0 then
			local step = math.floor((weeks:getMusicTime() or 0) * bpm / 60000 * 4)
			if step > lastStepNum then
				lastStepNum = step
				if (step + bopOffset * 4) % (bopRate * 4) == 0 then
					bopMultiplier = 1.0 + (1.015 - 1.0) * bopIntensity
				end
			end
		end
		bopMultiplier = 1.0 + (bopMultiplier - 1.0) * (0.95 ^ dt)
		cam.sizeX = zoomBase.x * bopMultiplier
		cam.sizeY = zoomBase.y * bopMultiplier
	end
end

-- Dibuja el lipsync de UN personaje -- llamar DENTRO del mismo
-- graphics.pushParallax(...) que ya envuelve el draw() del personaje
-- dueño, justo después, para que herede exactamente la misma cámara/
-- parallax (mouthMat ya viene en el mismo espacio "mundo" que ese draw()
-- usa internamente).
local function drawLipsyncFor(name)
	local lip = lipsyncSprites[name]
	if not lip then return end
	lip:drawAt(lipsyncMouthMat[name], 1)
end

function M.draw()
	-- zIndex real (sserafim.json): bg=10, floor("fucker")=10,
	-- perspectiveFloor=11 (código, no prop JSON), backTables=12,
	-- backStools=14, backLightColor=17, backLightWhite=18, truck=20,
	-- truckDoor=21, truckLight2=22, truckLight1=23, frontStool=1500 --
	-- mismo orden acá (lo último dibujado queda al frente).
	graphics.pushParallax(0.75, 0.75)
		bg:draw()
	love.graphics.pop()

	graphics.pushParallax(0.85, 0.85)
		if floor.alpha > 0 then floor:draw() end
	love.graphics.pop()

	-- perspectiveFloor (screen-space, sin pushParallax -- ver
	-- drawPerspectiveFloor()/perspectiveScreenPos(), calcula su propia
	-- proyección por punto porque bottomObj/topObj tienen scrollFactor
	-- distinto entre sí).
	drawPerspectiveFloor()

	-- BUG corregido: graphics.newImage().draw() NO chequea .alpha solo
	-- (es una convención -- el LLAMADOR decide si dibuja o no según
	-- .alpha > 0, mismo criterio ya usado para floor/backLightColor/etc
	-- en este mismo archivo) -- backTables/backStools/truck/truckDoor/
	-- frontStool se dibujaban SIEMPRE sin chequear esto, así que
	-- setCutsceneVisibility() (que solo cambia .alpha) nunca tenía efecto
	-- visual real -- el camión/mesas/sillas quedaban visibles SIEMPRE,
	-- inclusive durante la cutscene.
	graphics.pushParallax(0.93, 0.93)
		if backTables.alpha > 0 then backTables:draw() end
		if backTablesCutscene.alpha > 0 then backTablesCutscene:draw() end
	love.graphics.pop()

	if burgerCutscene.alpha > 0 then
		graphics.pushParallax(0.93, 0.93)
			burgerCutscene:draw()
		love.graphics.pop()
	end

	graphics.pushParallax(0.94, 0.94)
		if backStools.alpha > 0 then backStools:draw() end
	love.graphics.pop()

	-- BUG corregido (round 42): el intento de la ronda 41 usaba
	-- love.graphics.setBlendState -- CONFIRMADO que esa función NO EXISTE
	-- en LÖVE 11.5 (la versión real de este proyecto, ver conf.lua +
	-- resources/win64/love/love.dll) -- es agregada en LÖVE 12
	-- (rama "main" de GitHub, que es la que se leyó por error en la
	-- ronda 41 en vez del tag "11.5" real) -- crasheaba con "attempt to
	-- call field 'setBlendState' (a nil value)". Revertido a blending
	-- alpha normal otra vez -- en LÖVE 11.5 solo existe el setBlendMode()
	-- de alto nivel, sin forma de separar la ecuación de alpha de la de
	-- RGB -- cualquier intento futuro con add/screen necesita una técnica
	-- distinta que NO dependa de controlar el canal alpha por separado
	-- (ver memoria del proyecto).
	graphics.pushParallax(0.93, 0.93)
		if backLightColor.alpha > 0 then backLightColor:draw() end
	love.graphics.pop()

	graphics.pushParallax(0.93, 0.93)
		if backLightWhite.alpha > 0 then backLightWhite:draw() end
	love.graphics.pop()

	graphics.pushParallax(0.95, 0.95)
		if truck.alpha > 0 then truck:draw() end
		-- truckLight2 real NO tiene blend especial (se queda en alpha
		-- normal) -- solo truckLight1 usa SCREEN.
		if truckLight2.alpha > 0 then truckLight2:draw() end
		-- Revertido el blend SCREEN de truckLight1 (real: blend=12 también
		-- ahí) -- el usuario confirmó que esta luz YA se veía bien con
		-- blending normal antes, y que agregarle SCREEN la rompió. La
		-- causa real del aura blanca reportada (ver más abajo) eran
		-- backLightColor/White, detrás del camión -- truckLight1 nunca
		-- fue parte de ese bug, se le aplicó el cambio de más, así que se
		-- deja en alpha normal en vez de perseguir el 1:1 literal acá.
		if truckLight1.alpha > 0 then truckLight1:draw() end
	love.graphics.pop()

	graphics.pushParallax(0.95, 0.95)
		if truckDoor.alpha > 0 then truckDoor:draw() end
	love.graphics.pop()

	graphics.pushParallax(1)
		if boyfriend and boyfriend.visible then
			boyfriend:draw()
			drawLipsyncFor("sakura")
		end
		if girlfriend then girlfriend:draw() end
		if enemy and enemy.visible then
			enemy:draw()
			drawLipsyncFor("kazuha")
		end
		weeks:drawRating()
	love.graphics.pop()

	-- yunjin/chaewon/eunchae: scrollFactor REAL propio (0.95/0.95/0.97,
	-- sserafim.hxc:158-160) -- NO comparten el 1.0 de boyfriend/girlfriend/
	-- enemy (bug corregido junto con la posición absoluta, ver
	-- loadExtraGirl más arriba).
	if extraGirls.yunjin and extraGirls.yunjin.visible then
		graphics.pushParallax(0.95, 0.95)
			extraGirls.yunjin:draw()
			drawLipsyncFor("yunjin")
		love.graphics.pop()
	end
	if extraGirls.chaewon and extraGirls.chaewon.visible then
		graphics.pushParallax(0.95, 0.95)
			extraGirls.chaewon:draw()
			drawLipsyncFor("chaewon")
		love.graphics.pop()
	end
	if extraGirls.eunchae and extraGirls.eunchae.visible then
		graphics.pushParallax(0.97, 0.97)
			extraGirls.eunchae:draw()
			drawLipsyncFor("eunchae")
		love.graphics.pop()
	end

	graphics.pushParallax(1, 1)
		if frontStool.alpha > 0 then frontStool:draw() end
	love.graphics.pop()

	-- ── Cutscene de intro (createCutsceneSprites() real, líneas 628-678) --
	-- scrollFactor real exacto por sprite (0.94/0.95/0.99). Orden de
	-- zIndex real respetado: cutsceneMain(25)/Gf(25)/Bf(305) < dust(2000)
	-- < solidCover(9999) < SEEYOU1/2(10000, cámara propia sin scroll).
	if cutsceneMainSprite and cutsceneMainSprite.visible then
		graphics.pushParallax(0.94, 0.94)
			cutsceneMainSprite:draw()
		love.graphics.pop()
	end
	if cutsceneGfSprite and cutsceneGfSprite.visible then
		graphics.pushParallax(0.95, 0.95)
			cutsceneGfSprite:draw()
		love.graphics.pop()
	end
	if cutsceneBfSprite and cutsceneBfSprite.visible then
		graphics.pushParallax(0.99, 0.99)
			cutsceneBfSprite:draw()
		love.graphics.pop()
	end

	if dustVisible then drawDust() end

	-- solidCover (zIndex 9999 real -- encima de TODO el stage, debajo del
	-- destello blanco) + sserafimFlash (FlxG.camera.flash real).
	if coverState.alpha > 0 then
		love.graphics.setColor(0, 0, 0, coverState.alpha)
		love.graphics.rectangle("fill", -2000, -2000, 5000, 5000)
		love.graphics.setColor(1, 1, 1, 1)
	end
	if flashAlpha > 0 then
		love.graphics.setColor(flashColor[1], flashColor[2], flashColor[3], flashAlpha)
		love.graphics.rectangle("fill", -2000, -2000, 5000, 5000)
		love.graphics.setColor(1, 1, 1, 1)
	end

	if seeyou1 and seeyou1.visible then seeyou1:draw() end
	if seeyou2 and seeyou2.visible then seeyou2:draw() end
end

-- setCutsceneVisibility() real (sserafim.hxc:599-626) -- oculta/muestra
-- todo lo que NO es parte de la cutscene (las 4 girls + props del diner
-- normal) y lo que SÍ lo es (cutsceneMainSprite). El swap de textura del
-- floor (PerspectiveSprite real) se omite -- ver cabecera del archivo,
-- "floor" en este puerto ya queda en alpha=0 siempre (mismo valor real
-- del prop JSON), el floor "de verdad" es un sprite aparte que este
-- puerto no construyó.
setCutsceneVisibility = function(inCutscene)
	if inCutscene then
		M.setGirlsVisible({ false, false, false, false, false })
	else
		M.setGirlsVisible({ girlVisible.yunjin, girlVisible.kazuha, girlVisible.chaewon, girlVisible.eunchae, girlVisible.sakura })
	end

	if truck      then truck.alpha      = inCutscene and 0 or 1 end
	if truckDoor  then truckDoor.alpha  = 0 end
	if backTables then backTables.alpha = inCutscene and 0 or 1 end
	if backStools then backStools.alpha = inCutscene and 0 or 1 end
	if frontStool then frontStool.alpha = inCutscene and 0 or 1 end

	if backTablesCutscene then backTablesCutscene.alpha = inCutscene and 1 or 0 end
	if burgerCutscene     then burgerCutscene.alpha     = inCutscene and 1 or 0 end

	if girlfriend then girlfriend.visible = false end

	if cutsceneMainSprite then cutsceneMainSprite.visible = inCutscene end

	-- BUG corregido: hideDust(visible:Bool) real NO "oculta si true" --
	-- a pesar del nombre, asigna .visible = visible DIRECTO (mal
	-- nombrada). setCutsceneVisibility llama hideDust(!inCutscene) -- o
	-- sea: polvo OCULTO durante la cutscene, VISIBLE durante gameplay
	-- normal (justo después del choque, que es cuando debería
	-- aparecer) -- antes tenía esto exactamente al revés.
	dustVisible = not inCutscene
end

-- endStuff() real (sserafim.hxc:680-715) -- SEEYOU1/2 + sonidos +
-- endSong(). Disparado por el evento sserafimEnd (ver M.load()).
endStuff = function()
	audio.playSound(love.audio.newSource("sounds/sserafim/cutscene/end1.ogg", "static"))

	addCutsceneTimer(Timer.after(0.05, function()
		if seeyou1 then seeyou1.visible = true end
		coverState.alpha = 1
		-- BUG corregido: real hace camHUD.visible=false + isInCutscene=true
		-- acá (sserafim.hxc:690-692) -- sin esto, el HUD/strumline
		-- (weeks:drawUI(), ver weeks/sserafim.lua) se dibuja ENCIMA de
		-- SEEYOU1/2 -- por eso no tapaban "absolutamente todo".
		_G.cutscenePause = true
	end))

	addCutsceneTimer(Timer.after(4, function()
		if seeyou1 then seeyou1.visible = false end
		if seeyou2 then seeyou2.visible = true end
		audio.playSound(love.audio.newSource("sounds/sserafim/cutscene/end2.ogg", "static"))
	end))

	addCutsceneTimer(Timer.after(8, function()
		if seeyou1 then seeyou1.visible = false end
		if seeyou2 then seeyou2.visible = false end
		-- BUG corregido (round 35): _G.cutscenePause se prendía a los
		-- +0.05s (arriba) pero NUNCA se apagaba -- weeks.lua tiene un
		-- guard "if _G.cutscenePause then return end" (states/weeks.lua:
		-- 1957/2196) que bloquea TODA su lógica de update mientras esté
		-- prendida, incluida la detección de "canción terminada" que el
		-- párrafo de abajo dice que se necesita para la transición a
		-- resultados -- sin apagarla, esa detección NUNCA llega a correr,
		-- así que NUNCA pasa nada después de que desaparece seeyou2:
		-- pantalla negra, juego congelado para siempre (softlock
		-- reportado). Apagarla acá (la secuencia visual de seeyou ya
		-- terminó en este punto) deja que weeks.lua vuelva a correr
		-- normal y la detección natural descrita abajo haga su trabajo.
		_G.cutscenePause = false
	end))

	-- endSong(true) real: corta directo a resultados sin esperar a que
	-- termine la instrumental. Este motor no expone un endSong() público
	-- -- weeks.lua YA detecta el fin solo (sin notas restantes + inst
	-- terminada, states/weeks.lua:2800-2818), y ESE mismo bloque guarda
	-- los scores (_G.weekTotalScore, etc.) -- forzar self.songEnded=true
	-- a mano desde acá saltearía ese guardado por completo. Se deja que
	-- la detección natural haga la transición (unos segundos más tarde,
	-- sin instrumental sonando de fondo igual) en vez de arriesgar el
	-- guardado de puntaje por ahorrar esos segundos.
end

-- skipCutscene() real (simplificado, mismo criterio ya usado en
-- stages/military/stage.lua: cancela todo, deja todo en su estado FINAL
-- y pasa directo a empezar la canción -- sin replicar los pasos
-- intermedios del choque/getup).
skipCutscene = function()
	if not cutsceneActive then return end
	cutsceneActive = false
	cutsceneSkipped = true
	clearCutsceneTimers()
	stopCutsceneSounds()

	setCutsceneVisibility(false)
	coverState.alpha = 0
	flashAlpha = 0

	-- BUG corregido (round 40): saltear la cutscene NO debe dejar todo en
	-- estado "limpio" (colorAdjust en 0) -- yunjin todavía no pateó la
	-- puerta en este punto (eso pasa DESPUÉS, vía el evento de chart
	-- sserafimKick, ya entrada la canción) -- el estado correcto al
	-- saltear es el mismo "recién after el choque, polvo y todo sucio"
	-- que resetSserafimClear() ya aplica normalmente al llegar ahí sin
	-- saltear -- antes esto se zureaba a 0 directo, dejando el salteo en
	-- un estado que el juego real nunca tiene en este punto de la canción.
	resetSserafimClear()

	if cutsceneGfSprite then cutsceneGfSprite.visible = true end
	if cutsceneBfSprite then cutsceneBfSprite.visible = true end
	if cutsceneGfSprite then cutsceneGfSprite:animate("getup", true) end
	if cutsceneBfSprite then cutsceneBfSprite:animate("getup", true) end

	_G.cutscenePause = false
	-- _G.disableAutoCam NO se reactiva acá -- mismo motivo que en
	-- introCutscene(), queda en true para toda la canción.

	local cb = cutsceneOnComplete
	cutsceneOnComplete = nil
	if cb then cb() end
end

-- tweenCameraToPosition(x,y,...) real -> cam.x/y (convención YA
-- verificada en states/weeks.lua:190-191, bfCamTarget): cam.x=-x+100,
-- cam.y=-y+75 (100,75 = mitad del viewport conceptual de Psych).
-- BUG corregido: la fórmula real de tweenCameraToPosition() (la que
-- ACTUALMENTE usan FocusCamera/ZoomCamera y la cutscene, PlayState.hx:
-- 3913-3949) es "scroll = followPoint - mitad_de_pantalla" -- SIN
-- ningún offset extra. El "+100,+75" que tenía antes venía de
-- bfCamTarget()/enemyCamTarget() en weeks.lua -- esas SON un cálculo
-- DISTINTO (moveCamera() real, el offset artístico para que el
-- personaje jugable no quede exactamente centrado durante el seguimiento
-- automático por nota) -- no aplica para un "foco puro" como este. Esta
-- confusión era la causa real de "la cámara enfoca demasiado arriba".
camFocusXY = function(x, y)
	return -x, -y
end

-- introCutscene() real (sserafim.hxc:735-903) -- timestamps reales en
-- frames/24fps (MD.FRT del atlas cutsceneMain), convertidos a segundos
-- (/24) para Timer.after. HapticUtil.vibrate (mobile-only) se omite --
-- sin equivalente de escritorio.
introCutscene = function()
	cutsceneActive = true
	cutsceneSkipped = false

	-- BUG corregido: nunca se seteaba _G.cutscenePause -- weeks.lua sigue
	-- corriendo notas/musicTime/chart en segundo plano durante TODA la
	-- cutscene si no se congela explícito (mismo mecanismo ya usado por
	-- stages/military/stage.lua y stages/phillyStreets/stage.lua --
	-- weeks:update() lo chequea como primera línea y retorna entero si es
	-- true, ver states/weeks.lua:1862). _G.disableAutoCam YA queda en
	-- true desde M.load() (la cámara de esta semana es 100% por eventos
	-- del chart, nunca auto-follow) -- no hace falta tocarlo acá.
	_G.cutscenePause = true

	if cutsceneMainSprite then
		cutsceneMainSprite.visible = true
		cutsceneMainSprite:animate("play", true)
	end

	-- snap inicial + fade desde negro (3s)
	cam.sizeX, cam.sizeY = 0.5, 0.5
	cam.x, cam.y = camFocusXY(660, -200)
	triggerFlash(3, { 0, 0, 0 })

	addCutsceneTimer(Timer.after(20 / 24, function()
		table.insert(cutsceneSounds, love.audio.newSource("sounds/sserafim/cutscene/startCutscene.ogg", "static"))
		audio.playSound(cutsceneSounds[#cutsceneSounds])
	end))

	-- tween de zoom/posición circOut, 3s (arranca ya, en paralelo al fade)
	do
		local tx, ty = camFocusXY(660, 300)
		Timer.tween(3, cam, { sizeX = 0.7, sizeY = 0.7, x = tx, y = ty }, "out-circ")
	end

	-- gf se toca a sí misma
	addCutsceneTimer(Timer.after(245 / 24, function() setDarkenAmt(0.2, 0.01) end))
	addCutsceneTimer(Timer.after(251 / 24, function() setDarkenAmt(0, 0.8) end))

	-- gf toca a bf
	addCutsceneTimer(Timer.after(406 / 24, function() setDarkenAmt(0.2, 0.01) end))
	addCutsceneTimer(Timer.after(411 / 24, function() setDarkenAmt(0, 0.8) end))

	-- el camión se empieza a acercar
	addCutsceneTimer(Timer.after(499 / 24, function()
		Timer.tween(49 / 24, colorAdjust, { brightness = 55, hue = 0, contrast = -30, saturation = 0 }, "out-sine")
	end))

	-- el camión está MUY cerca
	addCutsceneTimer(Timer.after(548 / 24, function()
		Timer.tween(15 / 24, colorAdjust, { brightness = 66, hue = 10, contrast = -17, saturation = 0 }, "in-expo")
	end))

	-- choque + flash blanco
	addCutsceneTimer(Timer.after(563 / 24, function()
		colorAdjust.hue, colorAdjust.saturation = 0, 0
		colorAdjust.brightness, colorAdjust.contrast = 0, 0
		triggerFlash(30 / 24, { 1, 1, 1 })
		coverState.alpha = 1
		setCutsceneVisibility(false)
	end))

	-- fade desde negro, vuelve el diner normal
	addCutsceneTimer(Timer.after(650 / 24, function()
		cam.sizeX, cam.sizeY = 0.7, 0.7
		Timer.tween(3, cam, { sizeX = 0.55, sizeY = 0.55 }, "out-circ")
		cam.x, cam.y = camFocusXY(1070, 470)

		Timer.tween(3, coverState, { alpha = 0 }, "out-sine")

		-- resetClear() real -- ver comentario en resetSserafimClear()
		-- arriba (más polvo + denso, escena entera teñida sucia/colorada,
		-- hasta que yunjin patee la puerta).
		resetSserafimClear()

		if cutsceneGfSprite then cutsceneGfSprite.visible = true; cutsceneGfSprite:animate("static", true) end
		if cutsceneBfSprite then cutsceneBfSprite.visible = true; cutsceneBfSprite:animate("static", true) end
	end))

	addCutsceneTimer(Timer.after(710 / 24, function()
		if cutsceneGfSprite then cutsceneGfSprite:animate("getup", true) end
		if cutsceneBfSprite then cutsceneBfSprite:animate("getup", true) end
	end))

	-- arranca la canción de verdad
	addCutsceneTimer(Timer.after(730 / 24, function()
		cutsceneActive = false
		_G.cutscenePause = false
		-- _G.disableAutoCam NO se reactiva acá -- queda en true para TODA
		-- la canción (ver M.load()), porque esta semana maneja la cámara
		-- 100% vía FocusCamera/ZoomCamera, nunca con auto-follow.

		local cb = cutsceneOnComplete
		cutsceneOnComplete = nil
		if cb then cb() end
	end))
end

-- BUG corregido (round 40): en freeplay (sin Story Mode) nunca corre
-- introCutscene() NI skipCutscene() -- la canción arranca directo en
-- weeks:setupCountdown(), así que resetSserafimClear() (el polvo
-- denso + tinte sucio post-choque) nunca se aplicaba -- el juego
-- arrancaba "limpio" cuando en realidad yunjin todavía no pateó la
-- puerta en ese punto de la canción (eso pasa recién con el evento de
-- chart sserafimKick, ya entrada la música), sin importar si hubo
-- cutscene visual o no. Llamado por weeks/sserafim.lua en el branch de
-- freeplay.
function M.applyPostCrashDustState()
	resetSserafimClear()
end

-- Llamado por weeks/sserafim.lua en Story Mode.
function M.startCutscene(songNum, onComplete)
	cutsceneOnComplete = onComplete

	-- BUG corregido: onCountdownStart() real llama setCutsceneVisibility(true)
	-- ANTES de introCutscene() (sserafim.hxc:593-594) -- nunca se llamaba
	-- acá, así que el camión/mesas/sillas/las 4 chicas/gf de la escena
	-- NORMAL de gameplay quedaban visibles DURANTE toda la cutscene en vez
	-- de la escena propia del choque (solidCover/cutsceneMainSprite +
	-- backTablesCutscene/burgerCutscene).
	setCutsceneVisibility(true)
	introCutscene()
end

function M.leave()
	bg = nil; floor = nil; backTables = nil; backStools = nil
	truck = nil; truckDoor = nil; frontStool = nil
	backTablesCutscene = nil; burgerCutscene = nil
	backLightColor = nil; backLightWhite = nil; truckLight1 = nil; truckLight2 = nil
	floorImageNormal = nil; floorImageCutscene = nil; floorRawWidth = nil; floorRawHeight = nil
	dustSprites = {}

	extraGirls = {}
	lipsyncSprites = {}
	lipsyncMouthMat = {}
	-- Restaura el animate() original de girlfriend -- si no, la PRÓXIMA
	-- semana que cargue a esta MISMA instancia de sprite (poco probable
	-- pero posible si _G.girlfriend persiste) quedaría con el wrapper de
	-- "-beautiful" pegado para siempre.
	if girlfriend and girlfriendAnimateOriginal then
		girlfriend.animate = girlfriendAnimateOriginal
	end
	girlfriendAnimateOriginal = nil
	isBeautiful = false

	lightsEnabled = false
	lightsColors, lightsDurations, lightsIntensities = {}, {}, {}
	coverState.alpha = 0
	flashAlpha = 0

	-- Igual que con girlfriendAnimateOriginal arriba: boyfriend/girlfriend/
	-- enemy son globals que pueden persistir entre semanas -- si no se
	-- limpia .shader acá, la PRÓXIMA semana que reuse esa instancia de
	-- sprite quedaría tintada por este shader para siempre.
	if boyfriend  then boyfriend.shader  = nil end
	if girlfriend then girlfriend.shader = nil end
	if enemy      then enemy.shader      = nil end
	characterShader = nil
	stageShader = nil

	clearCutsceneTimers()
	stopCutsceneSounds()
	cutsceneActive = false
	cutsceneSkipped = false
	cutsceneOnComplete = nil
	confirmWasDown = false
	_G.disableAutoCam = false
	-- Por si se sale de la semana A MITAD de la cutscene (quit a menú,
	-- etc.) -- sin esto, _G.cutscenePause quedaría en true colgado para
	-- la PRÓXIMA semana que cargue, congelándola desde el primer frame.
	_G.cutscenePause = false
	cutsceneMainSprite, cutsceneGfSprite, cutsceneBfSprite = nil, nil, nil
	seeyou1, seeyou2 = nil, nil
end

return M
