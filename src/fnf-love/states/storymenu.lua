--[[----------------------------------------------------------------------------
  storymenu — Port 1:1 de StoryMenuState.hx real de Psych Engine.

  Reescrito desde cero contra el código fuente real (FNF-PsychEngine-main/
  source/states/StoryMenuState.hx, objects/MenuItem.hx, objects/
  MenuCharacter.hx, backend/Difficulty.hx, backend/WeekData.hx) -- ver
  memoria del proyecto "storymenu-port" para el detalle completo de cada
  decisión de fidelidad. La versión anterior de este archivo era una
  implementación propia (sistema de "stage layers", un solo título
  centrado, sin lista deslizante ni bloqueo real) -- NO un puerto. Esa
  versión y su stage de configuración (stages/storymenu.lua, ya borrado)
  quedan reemplazados por completo.

  Constantes/posiciones/colores citados abajo son TODOS del archivo real,
  resolución virtual 1280x720 (igual que FlxG.width/height real, y la
  misma que ya usa este motor -- confirmado que no hace falta ningún
  factor de escala extra en draw(), lovesize ya lo maneja en main.lua).

  2 desviaciones DELIBERADAS del 1:1 (pedidas explícitamente por el
  usuario tras probar la primera versión de este port, no por fidelidad
  a Psych real):
  1. Las animaciones de los íconos de personaje SÍ se re-disparan cada
     beat con un Conductor (alternando danceLeft/danceRight en la
     novia) -- el StoryMenuState.hx real NO tiene esto (confirmado por
     grep, cero coincidencias de "beatHit"/"Conductor" ahí), pero
     Rewritten ya lo tenía así desde antes y el usuario prefiere
     mantenerlo (se ven "tiesos" sin esto).
  2. El sistema de bloqueo de semanas (weekIsLocked) está DESACTIVADO a
     propósito (ver ENFORCE_WEEK_LOCKING más abajo) -- el usuario señaló
     que ni el Psych Engine real lo usa en la práctica. La lógica real
     queda completa e intacta, simplemente no se aplica.
------------------------------------------------------------------------------]]

local highscores = require("highscores")
local wmd = require("modules.weekMetadata")
local Conductor = require("modules.conductor")
local menuCharLoader = require("sprites.storymenu.menuCharacter")

local storymenu = {}

local SCREEN_W, SCREEN_H = 1280, 720

-- Colores reales (StoryMenuState.hx) -- 0xFFRRGGBB -> rgb/255.
local YELLOW_BG   = {249/255, 207/255, 81/255}   -- 0xFFF9CF51
local TRACK_COLOR = {229/255, 87/255, 119/255}   -- 0xFFe55777
local FLASH_COLOR = {51/255, 255/255, 255/255}   -- 0xFF33FFFF (MenuItem.hx _flashColor)

-- Posición TOP-LEFT real de las flechas (StoryMenuState.hx: leftArrow =
-- new FlxSprite(850, grpWeekText.members[0].y+10), donde ese "y" es el
-- valor de CREACIÓN del primer item -- bgSprite.y+396=452 -- nunca el
-- del scroll-lerp). Constantes a nivel de módulo porque changeDifficulty()
-- también las necesita en su forma CRUDA (sin la conversión top-left->
-- centro de getOrigin(), que solo aplica a leftArrow.x/y mismos).
local ARROW_TOPLEFT_X = 850
local ARROW_TOPLEFT_Y = 56 + 396 + 10

-- ============================================================
-- Semanas de story mode (igual filtro que antes: not hideStoryMode)
-- ============================================================
local storyWeeks = {}
for _, week in ipairs(wmd.weeks) do
	if not week.hideStoryMode then
		table.insert(storyWeeks, week)
	end
end

-- ============================================================
-- Personajes de menú reales (images/menucharacters/<id>.json de Psych
-- real) -- "baked": ya existe sprites/storymenu/props/Menu_X.lua (9
-- personajes del juego base, ya verificado fiel, ver memoria del
-- proyecto). "atlas": sin pre-hornear, se carga vía menuCharLoader
-- (atlas Sparrow real copiado a images/png/storymenu/props/).
-- "position": campo crudo del JSON real, RESTADO de sprite.x/y en
-- draw() (NO sumado -- ver el comentario completo ahí: a diferencia de
-- charts/psych/characters.lua, MenuCharacter.hx real aplica esto vía
-- offset.set() de Flixel, que se resta al dibujar).
-- ============================================================
-- "path": ruta de ARCHIVO (no de módulo dotted) -- se carga con
-- love.filesystem.load(path)() en vez de require(path) a propósito: dos
-- semanas (ej. tutorial.json: weekCharacters=["gf","bf","gf"]) pueden
-- necesitar el MISMO personaje horneado en DOS slots a la vez (enemigo Y
-- girlfriend). require() cachea y devolvería la MISMA tabla compartida
-- para ambos slots -- :animate()/.x/.y de uno pisaría al otro, ya que
-- serían literalmente el mismo objeto. love.filesystem.load(path)()
-- re-ejecuta el chunk cada vez, dando una instancia nueva e independiente.
local MENU_CHARACTERS = {
	bf = { kind = "baked", path = "sprites/storymenu/props/Menu_BF.lua", position = {15, -40} },
	gf = { kind = "baked", path = "sprites/storymenu/props/Menu_GF.lua", position = {0, -25} },
	dad = { kind = "baked", path = "sprites/storymenu/props/Menu_Dad.lua", position = {0, 0} },
	spooky = { kind = "baked", path = "sprites/storymenu/props/Menu_Spooky_Kids.lua", position = {0, -80} },
	pico = { kind = "baked", path = "sprites/storymenu/props/Menu_Pico.lua", position = {0, -120} },
	mom = { kind = "baked", path = "sprites/storymenu/props/Menu_Mom.lua", position = {0, 10} },
	["parents-christmas"] = { kind = "baked", path = "sprites/storymenu/props/Menu_Parents.lua", position = {110, 10} },
	senpai = { kind = "baked", path = "sprites/storymenu/props/Menu_Senpai.lua", position = {60, -70} },
	tankman = { kind = "baked", path = "sprites/storymenu/props/Menu_Tankman.lua", position = {0, -95} },
	darnell = { kind = "atlas", image = "darnell", idle_anim = "idle", confirm_anim = "idle", position = {-20, -90} },
	nene = { kind = "atlas", image = "nene", idle_anim = "idle", confirm_anim = "idle", position = {-30, -10} },
	["pico-playable"] = { kind = "atlas", image = "pico-player", idle_anim = "idle", confirm_anim = "confirm", position = {20, 0} },
}

-- ============================================================
-- Sonidos reales (scrollMenu/confirmMenu/cancelMenu de Psych)
-- ============================================================
local scrollSound  = love.audio.newSource("sounds/menu/select.ogg", "static")
local confirmSound = love.audio.newSource("sounds/menu/confirm.ogg", "static")
local cancelSound  = love.audio.newSource("sounds/menu/cancel.ogg", "static")

-- ============================================================
-- Dificultades (sin módulo "Difficulty" genérico a propósito -- ver
-- memoria del proyecto, punto 5: ninguna semana usa difficultades
-- custom hoy, eso es trabajo de la auditoría de ergonomía pausada).
-- ============================================================
local difficultyKeys = {"easy", "normal", "hard"}
local difficultySuffixes = { easy = "-easy", normal = "", hard = "-hard" }

local function loadImage(path)
	local fullPath = graphics.imagePath(path)
	if love.filesystem.getInfo(fullPath) then
		return graphics.newImage(love.graphics.newImage(fullPath))
	end
	return nil
end

local difficultySprites = {
	easy = loadImage("storymenu/difficulties/easy"),
	normal = loadImage("storymenu/difficulties/normal"),
	hard = loadImage("storymenu/difficulties/hard"),
}

local lockImage = loadImage("storymenu/ui/lock")

-- Flechas: DOS instancias independientes (no compartir sprites/storymenu/
-- ui/arrows.lua vía require -- ese módulo hornea UNA sola instancia
-- cacheada por Lua, y acá hacen falta dos con estado de animación
-- propio). Mismos frames reales (XML campaign_menu_UI_assets real:
-- arrow left 48x85, arrow push left 42x75, arrow push right 41x74,
-- arrow right 47x85) ya extraídos en images/png/storymenu/ui/arrows.png.
local arrowImage = love.graphics.newImage(graphics.imagePath("storymenu/ui/arrows"))
local arrowFrames = {
	{x = 4, y = 4, width = 48, height = 85, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
	{x = 56, y = 4, width = 47, height = 85, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
	{x = 107, y = 4, width = 42, height = 75, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
	{x = 153, y = 4, width = 41, height = 74, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},
}
local arrowAnims = {
	leftIdle = {start = 1, stop = 1, speed = 24, offsetX = 0, offsetY = 0},
	rightIdle = {start = 2, stop = 2, speed = 24, offsetX = 0, offsetY = 0},
	leftConfirm = {start = 3, stop = 3, speed = 24, offsetX = 0, offsetY = 0},
	rightConfirm = {start = 4, stop = 4, speed = 24, offsetX = 0, offsetY = 0},
}
local leftArrow = graphics.newSprite(arrowImage, arrowFrames, arrowAnims, "leftIdle", false)
local rightArrow = graphics.newSprite(arrowImage, arrowFrames, arrowAnims, "rightIdle", false)

-- Fuente VCR OSD MONO tamaño 32 (Paths.font("vcr.ttf"), 32 real -- las
-- otras pantallas usan el "font" global de main.lua a tamaño 24, no
-- sirve para esto).
local font32

-- ============================================================
-- Estado del menú (reconstruido en enter(), salvo lastDifficultyName --
-- ver más abajo, persiste entre reentradas igual que el "static var"
-- real de Psych).
-- ============================================================
local weekItems = {}     -- {week=, titleImage=, height=, y=, targetY=, alpha=, locked=, isFlashing=, flashElapsed=}
local curWeekIdx = 1
local curDifficultyIdx = 1
local lastDifficultyName = nil -- persistente entre reentradas (Difficulty.lastDifficultyName real es "static")

local charIcons = {}      -- 3 slots: enemigo, bf, gf

local lerpScore = 49324858 -- valor real de Psych (placeholder "feo" que cuenta hacia el real al entrar)
local intendedScore = 0
local trackListLines = {}
local weekTitleText = ""

local diffTween = nil -- {fromY=, toY=, fromAlpha=, toAlpha=, elapsed=, duration=}

local exiting = false
local selected = false

local conductor

-- BUG corregido (reportado por el usuario tras probar la primera versión
-- de este port): chequeaba una variable LOCAL "music" (siempre nil al
-- entrar por primera vez desde el main menu, sin idea de que
-- states/menu.lua YA dejó algo sonando) en vez de la GLOBAL _G.music que
-- states/menu.lua:146-149 usa y escribe -- por eso la música se
-- reiniciaba siempre al entrar al story menu, aunque Rewritten antes NO
-- lo hacía (porque su versión anterior de este archivo sí miraba
-- _G.music). Ver ese mismo archivo para el patrón exacto a replicar.

-- ============================================================
-- ENFORCE_WEEK_LOCKING: pedido explícito del usuario (ronda posterior a
-- la primera versión de este port) -- ni el Psych Engine real usa esto
-- en la práctica según el usuario. La lógica real de weekIsLocked()
-- queda completa abajo, simplemente no se aplica mientras esto sea
-- false. Cambiar a true para reactivarla sin tocar nada más.
-- ============================================================
local ENFORCE_WEEK_LOCKING = false

-- ============================================================
-- Herramienta de ajuste en vivo TEMPORAL para la posición de los íconos
-- de personaje (reportado por el usuario: "algunos personajes están
-- ligeramente descolocados" -- ver memoria "live-offset-tuning-tool-
-- pattern": al no poder correr LÖVE2D acá para verificar visualmente, en
-- vez de adivinar una 2da corrección a ciegas se construye esto). F5
-- activa/desactiva (sin efecto si está apagada). Tab cambia cuál de los
-- 3 slots visibles se ajusta. I/K mueven Y, J/L mueven X (no flechas,
-- chocan con la navegación del menú); Shift = 10x más rápido. F7
-- imprime la posición FINAL (la que hay que pegar en MENU_CHARACTERS).
-- BORRAR TODO ESTO (este bloque, el manejo de teclas en update(), el
-- overlay en draw(), y la suma de debugDX/DY al dibujar el ícono) una
-- vez que el usuario confirme los valores finales.
-- ============================================================
local debugTuning = false
local debugSlotOrder = {"enemy", "boyfriend", "girlfriend"}
local debugSlotIdx = 1
local debugDX, debugDY = 0, 0
local debugPrevKeys = {}

local function debugKeyPressed(key)
	local now = love.keyboard.isDown(key)
	local was = debugPrevKeys[key]
	debugPrevKeys[key] = now
	return now and not was
end

-- ============================================================
-- weekIsLocked: port 1:1 de StoryMenuState.hx:weekIsLocked()
-- ============================================================
local function weekIsLocked(week)
	if not ENFORCE_WEEK_LOCKING then return false end
	if week.startUnlocked then return false end
	if not week.weekBefore or week.weekBefore == "" then return false end
	return not highscores.getWeekCompleted(week.weekBefore)
end

-- ============================================================
-- MenuCharacter: crea/recicla el sprite de un slot (enemigo/bf/gf)
-- ============================================================
local function changeCharacterIcon(slot, characterId)
	local icon = charIcons[slot]
	if icon.character == characterId then return end

	icon.character = characterId
	icon.sprite = nil
	icon.hasConfirmAnimation = false

	if not characterId or characterId == "" then return end

	local def = MENU_CHARACTERS[characterId]
	if not def then
		-- Personaje sin definición de menú real (contenido custom del mod,
		-- ej. sserafim-*/sonicexe) -- mismo manejo seguro que
		-- MenuCharacter.hx caso '': no se dibuja nada, no se inventa un
		-- ícono que Psych real no tiene.
		return
	end

	local sprite, hasConfirm
	if def.kind == "baked" then
		sprite = love.filesystem.load(def.path)()
		hasConfirm = (sprite:getAnims() and sprite:getAnims()["confirm"] ~= nil)
	else
		sprite, hasConfirm = menuCharLoader.create(def)
	end

	-- MenuCharacter.hx real: animation.addByPrefix(..., 24) usa Looped=true
	-- por defecto, y animation.play('idle') la deja en loop continuo --
	-- StoryMenuState.hx NO tiene NINGÚN callback de beat que vuelva a
	-- disparar la animación (confirmado por grep contra el .hx real -- la
	-- versión anterior de este archivo SÍ tenía eso, invención propia, no
	-- de Psych). graphics.newSprite() de este motor no loopea por defecto
	-- si no se le pide -- forzarlo acá explícito para igualar el real.
	sprite:animate("idle", true)

	icon.sprite = sprite
	icon.hasConfirmAnimation = hasConfirm
	icon.positionX = def.position[1]
	icon.positionY = def.position[2]
end

-- ============================================================
-- refresh(): texto de tracklist + puntuación + sprite de dificultad
-- (port de updateText() + parte de changeDifficulty())
-- ============================================================
local function refresh()
	local week = weekItems[curWeekIdx].week

	-- BUG corregido (reportado por el usuario): "TRACKS" NO va como línea
	-- de texto -- updateText() real arma txtTracklist.text SOLO con los
	-- nombres de canción (stringThing), nunca un header "TRACKS" -- esa
	-- palabra ya viene dibujada dentro de Menu_Tracks.png (la imagen),
	-- agregarla también como texto la duplicaba.
	trackListLines = {}
	for _, song in ipairs(week.songs) do
		table.insert(trackListLines, song[1]:upper())
	end

	intendedScore = highscores.getStoryScore(week.id, difficultyKeys[curDifficultyIdx])

	for i, slot in ipairs({"enemy", "boyfriend", "girlfriend"}) do
		changeCharacterIcon(slot, week.weekCharacters[i])
	end
end

-- ============================================================
-- changeDifficulty(): port 1:1 (incluye el tween real de entrada del
-- sprite de dificultad, FlxTween.tween(sprDifficulty,{y+30,alpha:1},0.07))
-- ============================================================
local function changeDifficulty(delta)
	delta = delta or 0
	curDifficultyIdx = curDifficultyIdx + delta
	if curDifficultyIdx < 1 then curDifficultyIdx = #difficultyKeys end
	if curDifficultyIdx > #difficultyKeys then curDifficultyIdx = 1 end

	local key = difficultyKeys[curDifficultyIdx]
	local sprite = difficultySprites[key]
	if sprite then
		local img = sprite:getImage()
		local w, h = img:getWidth(), img:getHeight()

		-- Fórmula real (StoryMenuState.hx:390-393), en coordenadas TOP-LEFT
		-- (leftArrow.x/y CRUDOS, sin la conversión de getOrigin() que solo
		-- aplica al sprite de la flecha) -- convertidas a centro (+w/2,+h/2)
		-- porque graphics.newImage() dibuja centrado en x,y.
		local topLeftX = ARROW_TOPLEFT_X + 60 + (308 - w) / 3
		local topLeftY = ARROW_TOPLEFT_Y - h + 50

		sprite.x = topLeftX + w / 2
		sprite.y = topLeftY + h / 2
		sprite.alpha = 0

		diffTween = { sprite = sprite, fromY = sprite.y, toY = sprite.y + 30, elapsed = 0, duration = 0.07 }
	end

	lastDifficultyName = key
	intendedScore = highscores.getStoryScore(weekItems[curWeekIdx].week.id, key)
end

-- ============================================================
-- changeWeek(): port 1:1 (scroll suave manejado en update(), acá solo
-- se cambia el índice y se recarga difficulty/personajes/tracklist)
-- ============================================================
local function changeWeek(delta)
	delta = delta or 0
	curWeekIdx = curWeekIdx + delta
	if curWeekIdx < 1 then curWeekIdx = #weekItems end
	if curWeekIdx > #weekItems then curWeekIdx = 1 end

	local week = weekItems[curWeekIdx].week
	weekTitleText = (week.storyName or week.weekName or ""):upper()

	local unlocked = not weekItems[curWeekIdx].locked
	for i, item in ipairs(weekItems) do
		item.alpha = (i == curWeekIdx and unlocked) and 1 or 0.6
	end

	-- Reset de dificultad real (Difficulty.hx:loadFromWeek -- sin lista
	-- custom por semana hoy, ver comentario de difficultyKeys arriba):
	-- vuelve a "normal" salvo que lastDifficultyName siga existiendo en
	-- la lista (siempre existe, lista global fija).
	curDifficultyIdx = 2 -- "normal", default real (Difficulty.getDefault())
	if lastDifficultyName then
		for i, key in ipairs(difficultyKeys) do
			if key == lastDifficultyName then curDifficultyIdx = i; break end
		end
	end

	refresh()
end

-- ============================================================
-- selectWeek(): port 1:1 (flash + confirm anims + delay real de 1s)
-- ============================================================
local function selectWeek()
	if selected then return end

	local week = weekItems[curWeekIdx].week
	if weekIsLocked(week) then
		audio.playSound(cancelSound)
		return
	end

	selected = true
	audio.playSound(confirmSound)

	weekItems[curWeekIdx].isFlashing = true
	weekItems[curWeekIdx].flashElapsed = 0

	for _, icon in pairs(charIcons) do
		if icon.sprite and icon.character ~= "" and icon.hasConfirmAnimation then
			icon.sprite:animate("confirm", false)
		end
	end

	local firstSongName = week.songs[1][1]
	_G.storyMode = true
	_G.currentWeekId = week.id
	_G.currentDifficulty = difficultyKeys[curDifficultyIdx]
	_G.currentSongName = firstSongName
	_G.weekSongs = {}
	for _, s in ipairs(week.songs) do
		table.insert(_G.weekSongs, s[1])
	end
	_G.weekTotalScore = 0
	_G.weekTotalSick, _G.weekTotalGood, _G.weekTotalBad, _G.weekTotalShit, _G.weekTotalMissed = 0, 0, 0, 0, 0
	_G.weekTotalNotesHit, _G.weekTotalPlayed, _G.weekMaxCombo = 0, 0, 0
	_G.currentSongIndex = 1

	-- Delay real: new FlxTimer().start(1, ...) -- StoryMenuState.hx:358.
	Timer.after(1, function()
		local wl = require("modules.weekLoader")
		local songAppend = difficultySuffixes[_G.currentDifficulty]
		wl.startFromMenu(week.id, 1, songAppend, true, firstSongName)
	end)
end

local function goBack()
	if exiting or selected then return end
	exiting = true
	audio.playSound(cancelSound)
	graphics.fadeOut(0.5, function()
		Gamestate.switch(require("states.menu"))
	end)
end

-- ============================================================
-- enter()
-- ============================================================
function storymenu.enter(self, previous)
	if not font32 then font32 = love.graphics.newFont("fonts/vcr.ttf", 32) end

	exiting = false
	selected = false
	lerpScore = 49324858
	diffTween = nil

	charIcons = {
		enemy = { character = nil },
		boyfriend = { character = nil },
		girlfriend = { character = nil },
	}

	-- Construir la lista de semanas visibles (igual filtro real:
	-- StoryMenuState.hx:96-127 -- se incluye toda semana que NO esté
	-- bloqueada, o que SÍ lo esté pero sin hiddenUntilUnlocked. Ningún
	-- weeks/*.json define ese campo hoy -> default false -> todas se
	-- muestran con candado si están bloqueadas, igual que el juego base
	-- real).
	weekItems = {}
	local itemTargetY = 0
	for _, week in ipairs(storyWeeks) do
		local locked = weekIsLocked(week)
		if not locked or not week.hiddenUntilUnlocked then
			local titleImage = loadImage("storymenu/titles/" .. (week.title or week.id))
			local titleW, titleH = 0, 89
			if titleImage then
				local img = titleImage:getImage()
				titleW, titleH = img:getWidth(), img:getHeight()
			end

			table.insert(weekItems, {
				week = week,
				titleWidth = titleW,
				titleImage = titleImage,
				height = titleH,
				y = itemTargetY,
				targetY = itemTargetY,
				alpha = 0.6,
				locked = locked,
				isFlashing = false,
				flashElapsed = 0,
			})

			itemTargetY = itemTargetY + math.max(titleH, 110) + 10
		end
	end

	if #weekItems < 1 then
		-- Psych real cae a un ErrorState con accesos al editor de semanas;
		-- este motor no tiene editor de semanas -- evitar crashear, volver
		-- al menú principal directo.
		Gamestate.switch(require("states.menu"))
		return
	end

	if curWeekIdx > #weekItems then curWeekIdx = 1 end

	-- Posición de las flechas: FIJA para toda la sesión (StoryMenuState.hx:
	-- leftArrow = new FlxSprite(850, grpWeekText.members[0].y+10) -- el "y"
	-- ahí es el valor de CREACIÓN del primer item (bgSprite.y+396 = 452),
	-- ANTES de que update() empiece a animarlo con el scroll -- nunca se
	-- vuelve a tocar después. NO es lo mismo que weekItems[1].targetY (el
	-- acumulador usado solo para el scroll-lerp, ver changeWeek/update).
	local lox, loy = leftArrow:getOrigin()
	local rox, roy = rightArrow:getOrigin()
	leftArrow.x, leftArrow.y = ARROW_TOPLEFT_X + lox, ARROW_TOPLEFT_Y + loy
	rightArrow.x, rightArrow.y = ARROW_TOPLEFT_X + 376 + rox, ARROW_TOPLEFT_Y + roy

	-- changeWeek(0) recalcula título/alpha/dificultad/tracklist/personajes
	-- para la semana ya seleccionada (igual que el real: create() llama
	-- changeWeek() sin delta al final).
	changeWeek(0)
	changeDifficulty(0)

	-- _G.music, NO una variable local (ver comentario arriba) -- mismo
	-- patrón que states/menu.lua:146-149, así esto detecta correctamente
	-- la música que el main menu ya dejó sonando.
	if not _G.music or not _G.music:isPlaying() then
		_G.music = love.audio.newSource("music/menu/menu.ogg", "stream")
		_G.music:setLooping(true)
		_G.music:play()
	end

	-- Restaura el comportamiento que Rewritten ya tenía (pedido explícito
	-- del usuario, ver nota del encabezado del archivo): los íconos de
	-- personaje "bailan" cada beat en vez de quedarse en un solo frame
	-- estático -- StoryMenuState.hx real no lo hace, esto es a propósito
	-- distinto del 1:1.
	conductor = Conductor.new(102)
	local beatCounter = 0
	conductor:addBeatHitCallback(function(beat)
		beatCounter = beatCounter + 1

		local enemyIcon = charIcons.enemy
		if enemyIcon.sprite and enemyIcon.sprite:getAnims()["idle"] then
			enemyIcon.sprite:animate("idle", false)
		end

		local bfIcon = charIcons.boyfriend
		if bfIcon.sprite and bfIcon.sprite:getAnims()["idle"] then
			bfIcon.sprite:animate("idle", false)
		end

		local gfIcon = charIcons.girlfriend
		if gfIcon.sprite then
			local animName = (beatCounter % 2 == 1) and "danceLeft" or "danceRight"
			if gfIcon.sprite:getAnims()[animName] then
				gfIcon.sprite:animate(animName, false)
			elseif gfIcon.sprite:getAnims()["idle"] then
				gfIcon.sprite:animate("idle", false)
			end
		end
	end)

	graphics.setFade(0)
	graphics.fadeIn(0.5)
end

function storymenu.resume(self)
	refresh()
end

-- ============================================================
-- update()
-- ============================================================
function storymenu.update(self, dt)
	if _G.music and _G.music:isPlaying() then
		conductor:update(dt, _G.music:tell() * 1000)
	end

	-- BUG corregido (reportado por el usuario: "los personajes siguen sin
	-- moverse"): faltaba avanzar el frame de cada sprite -- sin esto,
	-- isLooped/isAnimated no importan, graphics.lua:update() (quien
	-- realmente incrementa "frame" cada llamada) nunca se ejecutaba para
	-- estos íconos. La versión anterior de storymenu.lua sí lo hacía
	-- (recorría stageLayers llamando :update(dt) en cada sprite) -- se
	-- perdió al reescribir el archivo con personajes nombrados en vez de
	-- una lista de capas genérica.
	for _, icon in pairs(charIcons) do
		if icon.sprite and icon.sprite.update then icon.sprite:update(dt) end
	end
	leftArrow:update(dt)
	rightArrow:update(dt)

	-- Orden real (StoryMenuState.hx:197-293): primero los controles
	-- (gateados por movedBack/selectedWeek/fading), DESPUÉS super.update()
	-- + el scroll-lerp -- éste último corre SIEMPRE, sin gate.
	if not (graphics.isFading() or exiting or selected) then
		if input:pressed("up") then
			changeWeek(-1)
			audio.playSound(scrollSound)
		elseif input:pressed("down") then
			changeWeek(1)
			audio.playSound(scrollSound)
		end

		rightArrow:animate(input:down("right") and "rightConfirm" or "rightIdle", false)
		leftArrow:animate(input:down("left") and "leftConfirm" or "leftIdle", false)

		if input:pressed("right") then
			changeDifficulty(1)
		elseif input:pressed("left") then
			changeDifficulty(-1)
		end

		if input:pressed("confirm") then
			selectWeek()
		elseif input:pressed("back") then
			goBack()
		end
	end

	-- Scroll suave de la lista -- corre siempre, igual que el real.
	local offY = weekItems[curWeekIdx].targetY
	local ratio = math.exp(-dt * 10.2)
	for _, item in ipairs(weekItems) do
		local target = item.targetY - offY + 480
		item.y = target + (item.y - target) * ratio
	end

	if weekItems[curWeekIdx].isFlashing then
		local item = weekItems[curWeekIdx]
		item.flashElapsed = item.flashElapsed + dt
	end

	if diffTween then
		diffTween.elapsed = diffTween.elapsed + dt
		local t = math.min(1, diffTween.elapsed / diffTween.duration)
		diffTween.sprite.y = diffTween.fromY + (diffTween.toY - diffTween.fromY) * t
		diffTween.sprite.alpha = t
		if t >= 1 then diffTween = nil end
	end

	if intendedScore ~= lerpScore then
		lerpScore = math.floor(intendedScore + (lerpScore - intendedScore) * math.exp(-dt * 30))
		if math.abs(intendedScore - lerpScore) < 10 then lerpScore = intendedScore end
	end

	-- Herramienta de ajuste en vivo (TEMPORAL, ver comentario donde se
	-- declaran debugTuning/etc más arriba).
	if debugKeyPressed("f5") then debugTuning = not debugTuning end
	if debugTuning then
		if debugKeyPressed("tab") then
			debugSlotIdx = debugSlotIdx % #debugSlotOrder + 1
			debugDX, debugDY = 0, 0
		end

		local speed = (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) and 400 or 40
		if love.keyboard.isDown("j") then debugDX = debugDX - speed * dt end
		if love.keyboard.isDown("l") then debugDX = debugDX + speed * dt end
		if love.keyboard.isDown("i") then debugDY = debugDY - speed * dt end
		if love.keyboard.isDown("k") then debugDY = debugDY + speed * dt end

		if debugKeyPressed("f7") then
			local slot = debugSlotOrder[debugSlotIdx]
			local icon = charIcons[slot]
			if icon and icon.character then
				local finalX = (icon.positionX or 0) + debugDX
				local finalY = (icon.positionY or 0) + debugDY
				print(string.format("[storymenu debug] %s (%s): position = {%d, %d}", slot, icon.character, math.floor(finalX + 0.5), math.floor(finalY + 0.5)))
			end
		end
	end
end

-- ============================================================
-- draw() -- orden de capas EXACTO de StoryMenuState.hx (ver memoria del
-- proyecto, hallazgo 6: el panel amarillo/fondo se dibuja ENCIMA de la
-- lista de semanas a propósito, no es un error de capas).
-- ============================================================
function storymenu.draw(self)
	-- BUG corregido (reportado por el usuario: "el fadeout negro... no
	-- está siendo aplicado"): TODO color en este draw() tiene que pasar
	-- por graphics.clear()/graphics.setColor() (modules/graphics.lua),
	-- NUNCA love.graphics.clear()/love.graphics.setColor() directo --
	-- son esas dos funciones, y solo ellas, las que multiplican r/g/b por
	-- el factor de fade activo (graphics.fadeIn/fadeOut/setFade) antes de
	-- llamar a la función real de LÖVE. Llamar a love.graphics.* directo
	-- (lo que este archivo hacía en todas partes) ignora el fade por
	-- completo -- nunca se ponía negro al entrar/salir.
	graphics.clear(0, 0, 0, 1)

	-- 1) Lista de semanas (MenuItem) -- enmascarada por el panel de abajo.
	for i, item in ipairs(weekItems) do
		if item.titleImage then
			if item.isFlashing then
				local flashing = math.floor(item.flashElapsed * 60 * 6) % 2 == 0
				local c = flashing and FLASH_COLOR or {1, 1, 1}
				graphics.setColor(c[1], c[2], c[3], item.alpha)
			else
				graphics.setColor(1, 1, 1, item.alpha)
			end
			-- item.y es el TOP-LEFT real de Psych (igual fórmula que
			-- weekThing.y) -- graphics.newImage() acá dibuja centrado en
			-- (x,y), así que hay que sumar la mitad de la altura para
			-- convertir top-left -> centro (mismo ajuste que hace Psych
			-- real para el candado, ver más abajo).
			item.titleImage.x = SCREEN_W / 2
			item.titleImage.y = item.y + item.height / 2
			item.titleImage:draw()
		end
	end
	graphics.setColor(1, 1, 1, 1)

	-- 2) Barra negra superior.
	graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle("fill", 0, 0, SCREEN_W, 56)

	-- 3) Candados sobre las semanas bloqueadas.
	if lockImage then
		local lockW = lockImage:getImage():getWidth()
		graphics.setColor(1, 1, 1, 1)
		for i, item in ipairs(weekItems) do
			if item.locked then
				-- lock.y real = weekThing.y + height/2 - lock.height/2 (top-left)
				-- -> centro = weekThing.y + height/2 (mismo centro que el título).
				lockImage.x = SCREEN_W / 2 + item.titleWidth / 2 + 10 + lockW / 2
				lockImage.y = item.y + item.height / 2
				lockImage:draw()
			end
		end
	end

	-- 4) Flechas + sprite de dificultad. Posición FIJA para toda la sesión
	-- (calculada una sola vez en enter(), ver comentario ahí) -- Psych
	-- real tampoco la recalcula nunca después de crear los sprites.
	graphics.setColor(1, 1, 1, 1)
	local unlocked = not weekItems[curWeekIdx].locked
	if unlocked then
		leftArrow:draw()
		rightArrow:draw()

		local diffSprite = difficultySprites[difficultyKeys[curDifficultyIdx]]
		if diffSprite then
			graphics.setColor(1, 1, 1, diffSprite.alpha or 1)
			diffSprite:draw()
			graphics.setColor(1, 1, 1, 1)
		end
	end

	-- 5) Panel amarillo + fondo decorativo de la semana (ENCIMA de 1-4).
	graphics.setColor(YELLOW_BG[1], YELLOW_BG[2], YELLOW_BG[3], 1)
	love.graphics.rectangle("fill", 0, 56, SCREEN_W, 386)

	local bgKey = weekItems[curWeekIdx].week.storyMenuBackground
	if bgKey and bgKey ~= "" then
		local bgSprite = loadImage("menubackgrounds/menu_" .. bgKey)
		if bgSprite then
			graphics.setColor(1, 1, 1, 1)
			bgSprite.x = SCREEN_W / 2
			bgSprite.y = 56 + 386 / 2
			bgSprite:draw()
		end
	end

	-- 6) Íconos de personaje (3 slots, fórmula real: 0.25*W*(1+i)-150).
	graphics.setColor(1, 1, 1, 1)
	local slotOrder = {"enemy", "boyfriend", "girlfriend"}
	for i, slot in ipairs(slotOrder) do
		local icon = charIcons[slot]
		if icon.sprite then
			-- baseX/70: anclas top-left reales de Psych (MenuCharacter.hx:
			-- new(x) + y+=70). ox,oy: conversión top-left->centro de ESTE
			-- motor (graphics.lua:getOrigin()).
			--
			-- BUG corregido (reportado por el usuario, personajes
			-- descolocados): "position" se RESTA, no se suma. Verificado
			-- contra el código real: PlayState.hx:825-826 (personajes de
			-- GAMEPLAY) hace "char.x += char.positionArray[0]" -- suma
			-- directa, que es lo que charts/psych/characters.lua replica
			-- correctamente. PERO MenuCharacter.hx:94 usa un mecanismo
			-- DISTINTO: "offset.set(charFile.position[0], ...)" -- el
			-- offset GENÉRICO de Flixel (FlxSprite.hx, doc real: "offset.x
			-- = 10 will show the graphic 10 pixels LEFT of the hitbox" --
			-- confirmado además en FlxSprite.hx:1392-1393, "- offset.x").
			-- Son dos campos "position" con el mismo nombre pero
			-- mecanismos DISTINTOS en Psych real -- copié la convención de
			-- personajes de gameplay (suma) para íconos de menú (resta)
			-- por error.
			local baseX = SCREEN_W * 0.25 * i - 150
			local ox, oy = icon.sprite:getOrigin()
			local extraX, extraY = 0, 0
			if debugTuning and slot == debugSlotOrder[debugSlotIdx] then
				extraX, extraY = debugDX, debugDY
			end
			icon.sprite.x = baseX + ox - (icon.positionX or 0) + extraX
			icon.sprite.y = 70 + oy - (icon.positionY or 0) + extraY
			icon.sprite:draw()
		end
	end

	if debugTuning then
		local slot = debugSlotOrder[debugSlotIdx]
		local icon = charIcons[slot]
		local charName = (icon and icon.character) or "(ninguno)"
		local finalX = math.floor(((icon and icon.positionX) or 0) + debugDX + 0.5)
		local finalY = math.floor(((icon and icon.positionY) or 0) + debugDY + 0.5)
		local lines = {
			"AJUSTE EN VIVO (F5 para salir)",
			"Slot: " .. slot .. "  Personaje: " .. charName,
			"Tab: cambiar slot | IJKL: mover | Shift: rapido | F7: imprimir",
			"position actual = {" .. finalX .. ", " .. finalY .. "}",
		}
		graphics.setColor(0, 0, 0, 0.7)
		love.graphics.rectangle("fill", 10, SCREEN_H - 90, 620, 80)
		graphics.setColor(1, 1, 0, 1)
		for i, line in ipairs(lines) do
			love.graphics.print(line, 18, SCREEN_H - 84 + (i - 1) * 18)
		end
		graphics.setColor(1, 1, 1, 1)
	end

	-- 7) Menu_Tracks + lista de canciones. tracksY es el TOP-LEFT real de
	-- Psych (tracksSprite.y = bgSprite.y+425) -- usado tal cual para el
	-- texto (printf no centra verticalmente), y +height/2 para la imagen
	-- (graphics.newImage() dibuja centrada en x,y).
	local tracksImage = loadImage("Menu_Tracks")
	local tracksY = 56 + 425
	if tracksImage then
		graphics.setColor(1, 1, 1, 1)
		local th = tracksImage:getImage():getHeight()
		tracksImage.x = SCREEN_W * 0.07 + 100
		tracksImage.y = tracksY + th / 2
		tracksImage:draw()
	end

	love.graphics.setFont(font32)
	graphics.setColor(TRACK_COLOR[1], TRACK_COLOR[2], TRACK_COLOR[3], 1)
	do
		local maxW = 0
		for _, line in ipairs(trackListLines) do
			maxW = math.max(maxW, font32:getWidth(line))
		end
		local boxX = (SCREEN_W - maxW) / 2 - SCREEN_W * 0.35
		local lineH = font32:getHeight()
		for i, line in ipairs(trackListLines) do
			love.graphics.printf(line, boxX, tracksY + 60 + (i - 1) * lineH, maxW, "center")
		end
	end

	-- 8) Puntuación + título de semana.
	graphics.setColor(1, 1, 1, 1)
	love.graphics.print("WEEK SCORE: " .. lerpScore, 10, 10)

	graphics.setColor(1, 1, 1, 0.7)
	local titleW = font32:getWidth(weekTitleText)
	love.graphics.print(weekTitleText, SCREEN_W - (titleW + 10), 10)

	graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(font)
end

function storymenu.leave(self)
	conductor = nil
end

return storymenu
