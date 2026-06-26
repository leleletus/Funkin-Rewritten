-- Stage: "phillyStreets" (Weekend 1 - Pico vs Darnell, canciones Darnell/
-- Lit Up/2Hot) -- puerto 1:1 de states/stages/PhillyStreets.hx, reconstruido
-- desde cero contra el código fuente real (NO se reusó nada del sistema
-- viejo de Rewritten, movido a _backup_weekend1/).
--
-- NO portado (simplificaciones documentadas, ver cada caso):
--   - picoFade (eco semitransparente del frame ACTUAL de Pico al disparar):
--     requiere clonar el frame activo de un sprite ajeno -- se aproxima
--     con un flash de alpha sobre Pico mismo (mismo momento, mismo
--     disparador, efecto visual similar sin la complejidad de clonar frames).
--   - La cutscene de Darnell (darnellCutscene) y "Philly Glow" NO están
--     en este archivo todavía -- son su propia pieza grande, ver TODOs.

local M = {}

local bgsprite = require("charts.psych.bgsprite")
local psychStages = require("charts.psych.stages")
local psychEvents = require("charts.psych.events")
local trafficModule = require("sprites.weekend1.traffic")
local abotModule = require("sprites.weekend1.abot-speaker")
local spraycanModule = require("sprites.weekend1.spraycan")
local casingModule = require("sprites.weekend1.casing")
local graphics = require("modules.graphics")

-- ── Fondos ──────────────────────────────────────────────────────────────
local skybox, skyboxImg, skyboxScrollX
local skyline, foregroundCity, construction
local highwayLights, highwayLightsLightmap, highway, smog
local foreground, spraycanPile

local car1, car2, traffic, trafficLightmap
local trafficCtrl

local abot
local spraycan

local casings = {}
local picoShootingSprite, picoIntroSprite
local pendingCasing = false  -- "weekend-1-cockgun" pide casing al llegar al frame 3 de "cock"
local darkenTimer = 0        -- 1 frame de demora antes de oscurecer props (igual que el real)

local lastBeatNum

-- ── Shader de lluvia (PhillyStreets.hx:setupRainShader()/RainShader.hx) ──
-- Postproceso de pantalla completa (FlxG.camera.setFilters real) --
-- Rewritten no tiene "filtros de cámara" como Flixel, así que se replica
-- dibujando todo el stage a un canvas propio y redibujándolo a la pantalla
-- real con el shader aplicado (weeks:drawUI()/HUD quedan AFUERA de esto,
-- igual que camHUD real queda afuera de FlxG.camera.setFilters()).
local rainShader, rainCanvas
local rainStartIntensity, rainEndIntensity = 0, 0
local rainTime = 0

-- ── Estado de la cutscene de Darnell (ver M.startDarnellCutscene) ───────
local isDarnellCutsceneActive = false

-- graphics.newImage() devuelve un WRAPPER que no expone :getWidth()/
-- :getHeight() (eso solo existe en el love.graphics.Image crudo, vía
-- :getImage()) -- se calcula el centro ANTES de envolver la imagen.
local function loadCenteredImage(path, psychX, psychY)
	local raw = love.graphics.newImage(graphics.imagePath(path))
	local sprite = graphics.newImage(raw)
	sprite.x, sprite.y = psychX + raw:getWidth() / 2, psychY + raw:getHeight() / 2
	return sprite
end

-- Mismo patrón que el fix de autos/A-Bot: boyfriend.x/y es el CENTRO del
-- sprite (convención Rewritten), pero PhillyStreets.hx real usa
-- boyfriend.x/y como TOP-LEFT (convención Flixel) para posicionar el
-- casquillo ("boyfriend.x+250, boyfriend.y+100") y las poses standalone
-- de Pico (picoShootingSprite/picoIntroSprite, que toman boyfriend.x/y
-- como referencia directa). Sin esta conversión, todo queda corrido por
-- la mitad del ancho/alto del frame ACTUAL de Pico -- de ahí que el
-- casquillo "vuele sobre su cabeza" y las poses de disparo se vean
-- descolocadas respecto al Pico jugable normal.
local function picoTopLeft()
	-- BUG corregido: getOrigin() (sin argumento) usa el frame de la
	-- animación ACTUALMENTE activa, que en el momento del gatillo de
	-- disparo suele ser la última pose de canto (singDOWN, singUP, etc),
	-- NO "idle" -- pero boyfriend.x/y se posicionó originalmente con el
	-- origen ESTABLE de "idle" (characters.lua:loadInto(), guardado en
	-- _slotConversionX/Y). Usar el origen dinámico daba una conversión
	-- distinta a la que realmente se usó para ubicarlo, dejando un
	-- desplazamiento residual hacia arriba-izquierda.
	local ox = boyfriend._slotConversionX or 0
	local oy = boyfriend._slotConversionY or 0
	return boyfriend.x - ox, boyfriend.y - oy
end

-- ── Cámara de la cutscene de Darnell ─────────────────────────────────────
-- BUG corregido (ronda anterior): había portado esto como un sistema
-- "camFollow" en convención TOP-LEFT (igual que military/stage.lua), pero
-- esa conversión es para Tank.hx, que mueve camFollow manualmente usando
-- dad.x crudo (top-left Flixel) en SU PROPIO código de cutscene. PERO
-- PhillyStreets.hx:darnellCutscene() NO hace eso -- llama a la función
-- COMPARTIDA moveCamera(isDad) (PlayState.hx:2337), que usa
-- dad.getMidpoint().x (el CENTRO del personaje), NO su top-left. Centro
-- en convención Flixel/Psych == boyfriend.x/enemy.x DIRECTO en este motor
-- (centro-anclado) -- restar getOrigin() (como hacía picoTopLeft(), correcto
-- para casquillo/lata que SÍ son top-left) introducía un error de varios
-- cientos de píxeles (medio ancho del sprite) para la cámara específicamente.
--
-- moveCamera(isDad) YA está 1:1 portado y probado en weeks.lua como
-- bfCamTarget()/enemyCamTarget(), expuesto justo para esto vía
-- weeks:getBfCamTarget()/getEnemyCamTarget() (weeks.lua:3404-3409, comentario:
-- "para que un stage... pueda enfocar la cámara... sin reinventar la
-- fórmula"). Esas funciones ya devuelven cam.x/y LISTOS (con cameraPosition
-- del personaje + camera_boyfriend/camera_opponent del stage + escala, todo
-- ya resuelto), no un "camFollow" intermedio -- por eso el signo de los
-- offsets extra de la cutscene ("camFollow.x += N" en Psych) se invierte
-- acá ("cam.x = base - N"), dado que cam.x = -camFollow.x + cte.


-- ── Sonidos ──────────────────────────────────────────────────────────────
local gunPrepSnd, lightCanSnd, kickCanSnd, kneeCanSnd, bonkSnd
local shotSnds = {}

-- ── A-Bot: mirar a quien le toca cantar (PhillyStreets.hx:updateABotEye()) ──
local function updateABotEye()
	if not abot then return end
	-- BUG corregido: "currentMustHit" (sin prefijo) es un LOCAL de
	-- states/weeks.lua, NO una global -- leerlo acá siempre daba nil (el
	-- A-Bot nunca cambiaba de dirección). Expuesto ahora en weeks.currentMustHit.
	if weeks.currentMustHit then
		abot:lookRight()
	else
		abot:lookLeft()
	end
end

-- ── Mecánica de armas: hooks genéricos de states/weeks.lua ───────────────
-- (curAnim, note, sprite) -- return true = "ya lo animé yo, no hagas la
-- animación default". Mismo patrón ya usado por Too Slow/picoShoot.
function M.customNoteHit(self, curAnim, note, bfSprite)
	local kind = note.noteTypeStr

	if kind == "weekend-1-cockgun" then
		-- PhillyStreets.hx:goodNoteHit() -- Pico saca el arma, dispara
		-- Gun_Prep, y a partir del FRAME 3 de "cock" crea el casquillo
		-- (real: callback de frame; acá, contador de tiempo simple --
		-- "cock" corre a 24fps, frame 3 ~= 0.125s).
		boyfriend.visible = false
		picoShootingSprite.visible = true
		picoShootingSprite:animate("cock", false)
		if gunPrepSnd then gunPrepSnd:stop(); gunPrepSnd:play() end
		pendingCasing = 0.125
		return true
	elseif kind == "weekend-1-firegun" then
		boyfriend.visible = false
		picoShootingSprite.visible = true
		picoShootingSprite:animate("shoot", false)
		if shotSnds[1] then
			local s = shotSnds[love.math.random(1, 4)]
			s:stop(); s:play()
		end
		if spraycan then spraycan:playCanShot() end
		darkenTimer = 1 / 24
		return true
	end

	return false
end

function M.customNoteMiss(self, curAnim, note, bfSprite)
	local kind = note.noteTypeStr

	if kind == "weekend-1-firegun" then
		boyfriend.visible = false
		picoShootingSprite.visible = true
		picoShootingSprite:animate("shootMISS", false)
		if bonkSnd then bonkSnd:stop(); bonkSnd:play() end
		health = health - 0.4 * 100  -- game.health -= 0.4 (escala 0-1 de Psych -> 0-100 de Rewritten)
		return true
	end

	return false
end

-- (curAnim, note, enemySprite) -- mismo patrón, lado Darnell (oponente).
function M.customEnemyNoteHit(self, curAnim, note, enemySprite)
	local kind = note.noteTypeStr

	if kind == "weekend-1-lightcan" then
		enemy:animate("lightCan", false)
		if lightCanSnd then lightCanSnd:stop(); lightCanSnd:play() end
		return true
	elseif kind == "weekend-1-kickcan" then
		enemy:animate("kickCan", false)
		if kickCanSnd then kickCanSnd:stop(); kickCanSnd:play() end
		if spraycan then spraycan:playCanStart() end
		return true
	elseif kind == "weekend-1-kneecan" then
		enemy:animate("kneeCan", false)
		if kneeCanSnd then kneeCanSnd:stop(); kneeCanSnd:play() end
		return true
	end

	return false
end

-- darkenTint: 1 = blanco normal, 0.133 (0x222222) = oscurecido de golpe.
-- Todos los sprites "darkenable" se oscurecen y aclaran JUNTOS, al mismo
-- ritmo (FlxTween.color real corre la MISMA animación, 1.4s, para cada uno
-- en simultáneo) -- un solo valor compartido alcanza, no hace falta estado
-- por sprite. graphics.newImage()/newSprite() no soportan tinte propio --
-- se envuelve cada :draw() con graphics.setColor(tint,tint,tint,1) en
-- M.draw().
local darkenTint = 1
local darkenTintT = nil  -- nil = no animando

local function darkenStageProps()
	darkenTint = 0.133
	darkenTintT = 0
end

-- songName: nombre file-safe de la canción activa ("darnell"/"lit-up"/
-- "2hot"), pasado por weeks/weekend1.lua:loadStage() -- determina la
-- intensidad de lluvia, igual que el switch(songName) real.
function M.load(songName)
	skyboxImg = love.graphics.newImage(graphics.imagePath("phillyStreets/phillySkybox"))
	skyboxScrollX = 0

	skyline = loadCenteredImage("phillyStreets/phillySkyline", -545, -273)

	foregroundCity = loadCenteredImage("phillyStreets/phillyForegroundCity", 625, 94)

	construction = loadCenteredImage("phillyStreets/phillyConstruction", 1800, 364)

	highwayLights = loadCenteredImage("phillyStreets/phillyHighwayLights", 284, 305)

	highwayLightsLightmap = loadCenteredImage("phillyStreets/phillyHighwayLights_lightmap", 284, 305)
	highwayLightsLightmap.x, highwayLightsLightmap.y = highwayLights.x, highwayLights.y

	highway = loadCenteredImage("phillyStreets/phillyHighway", 139, 209)

	smog = loadCenteredImage("phillyStreets/phillySmog", -6, 245)

	car1 = bgsprite.new("phillyStreets/phillyCars", 1200, 818, {"car1", "car2", "car3", "car4"}, false)
	car2 = bgsprite.new("phillyStreets/phillyCars", 1200, 818, {"car1", "car2", "car3", "car4"}, false)
	car2.sizeX = -car2.sizeX  -- flipX

	traffic = bgsprite.new("phillyStreets/phillyTraffic", 1840, 608, {"redtogreen", "greentored"}, false)
	trafficLightmap = loadCenteredImage("phillyStreets/phillyTraffic_lightmap", 1840, 608)

	trafficCtrl = trafficModule.new(car1, car2, traffic)

	foreground = loadCenteredImage("phillyStreets/phillyForeground", 88, 317)

	-- A-Bot: posición FIJA, calculada UNA SOLA VEZ acá (no en M.update()).
	-- Confirmado contra PhillyStreets.hx real: abot.x/y solo se asignan en
	-- el constructor (new ABotSpeaker(gfGroup.x, gfGroup.y+550)) -- nunca
	-- se reasignan en ningún update() del stage real. Antes lo
	-- recalculaba cada frame siguiendo a girlfriend.x/y, así que cuando
	-- Nene se movía un poco al bailar (danceLeft/danceRight tienen
	-- bounding boxes distintos), el A-Bot temblaba siguiéndola en cada
	-- beat -- se posiciona acá, después de psychStages.apply() (más abajo
	-- en esta función), que es cuando girlfriend.x/y ya tiene su posición
	-- de slot definitiva.
	abot = abotModule.new(0, 0)

	spraycanPile = loadCenteredImage("SpraycanPile", 920, 1045)

	-- BUG corregido: spraycanPile.x/y es el CENTRO (convención Rewritten,
	-- post loadCenteredImage), no el top-left Psych (920,1045) que usa
	-- PhillyStreets.hx real para esta misma suma -- se usan las
	-- coordenadas Psych originales directo, no spraycanPile.x/y.
	spraycan = spraycanModule.new(920 + 569, 1045 - 240)

	picoShootingSprite = love.filesystem.load("sprites/weekend1/pico-shooting.lua")()
	picoShootingSprite.visible = false
	picoIntroSprite = love.filesystem.load("sprites/weekend1/pico-intro.lua")()
	picoIntroSprite.visible = false

	gunPrepSnd  = love.audio.newSource("sounds/weekend1/Gun_Prep.ogg", "static")
	lightCanSnd = love.audio.newSource("sounds/weekend1/Darnell_Lighter.ogg", "static")
	kickCanSnd  = love.audio.newSource("sounds/weekend1/Kick_Can_UP.ogg", "static")
	kneeCanSnd  = love.audio.newSource("sounds/weekend1/Kick_Can_FORWARD.ogg", "static")
	bonkSnd     = love.audio.newSource("sounds/weekend1/Pico_Bonk.ogg", "static")
	shotSnds = {
		love.audio.newSource("sounds/weekend1/shots/shot1.ogg", "static"),
		love.audio.newSource("sounds/weekend1/shots/shot2.ogg", "static"),
		love.audio.newSource("sounds/weekend1/shots/shot3.ogg", "static"),
		love.audio.newSource("sounds/weekend1/shots/shot4.ogg", "static"),
	}

	casings = {}
	pendingCasing = false
	darkenTimer = 0
	lastBeatNum = -1

	psychStages.apply("phillyStreets")

	if abot then
		-- Psych real: new ABotSpeaker(gfGroup.x, gfGroup.y+550) -- gfGroup.x/y
		-- son TOP-LEFT (convención Flixel); girlfriend.x/y en Rewritten es el
		-- CENTRO del sprite -- hay que restar getOrigin() para volver a
		-- top-left antes de sumar el offset, o el A-Bot queda mucho más
		-- abajo/lejos de lo debido (la mitad del alto/ancho del sprite de
		-- Nene de diferencia). Posición FIJA -- ver comentario completo en
		-- la creación de `abot` más arriba (NO se reasigna en M.update()).
		local gfOx, gfOy = 0, 0
		if girlfriend then gfOx, gfOy = girlfriend:getOrigin() end
		local gfTopLeftX = (girlfriend and girlfriend.x or 0) - gfOx
		local gfTopLeftY = (girlfriend and girlfriend.y or 0) - gfOy
		-- Ajuste manual (-150): el offset psych+conversión queda igual
		-- demasiado abajo en la práctica (confirmado jugando, -100 todavía
		-- no alcanzaba) -- no hay editor visual para objetos de stage como
		-- sí lo hay para personajes, así que este valor es ajuste fino a mano.
		abot.x, abot.y = gfTopLeftX, gfTopLeftY + 550 - 200
	end

	updateABotEye()

	-- setupRainShader() real: rampa de intensidad fija por canción
	-- (start->end, interpolada en M.update() según Conductor.songPosition).
	rainStartIntensity, rainEndIntensity = 0, 0
	if songName == "darnell" then
		rainStartIntensity, rainEndIntensity = 0, 0.1
	elseif songName == "lit-up" then
		rainStartIntensity, rainEndIntensity = 0.1, 0.2
	elseif songName == "2hot" then
		rainStartIntensity, rainEndIntensity = 0.2, 0.4
	end

	rainTime = 0
	rainShader = love.graphics.newShader("shaders/rain.glsl")
	rainShader:send("uScale", lovesize.getHeight() / 200)
	rainShader:send("uIntensity", rainStartIntensity)
	rainShader:send("uTime", 0)
	rainCanvas = love.graphics.newCanvas(lovesize.getWidth(), lovesize.getHeight())
end

-- Llamado por weeks/weekend1.lua DESPUÉS de que `inst` (el Source real)
-- ya está cargado -- decodifica el MISMO archivo aparte como SoundData
-- para que abot-speaker.lua pueda leer muestras crudas (ver
-- modules/spectral_analyzer.lua). Si falla (formato no soportado, etc.)
-- las barras quedan congeladas, igual que Psych sin funkin.vis -- no
-- rompe nada más.
function M.setupAbotAudio(fileName)
	if not abot then return end
	local ok, soundData = pcall(love.sound.newSoundData, "music/" .. fileName .. "/Inst.ogg")
	abot:setAudioSource(ok and soundData or nil, _G.inst)
end

function M.update(dt)

	-- update() real: rainShader.intensity = remapToRange(songPosition, 0,
	-- music.length, startIntensity, endIntensity); rainShader.update(elapsed).
	if rainShader then
		local len = weeks.songLength or 0
		local percent = 0
		if len > 0 then
			percent = math.min(1, math.max(0, weeks:getMusicTime() / len))
		end
		local intensity = rainStartIntensity + (rainEndIntensity - rainStartIntensity) * percent
		rainShader:send("uIntensity", intensity)
		rainTime = rainTime + dt
		rainShader:send("uTime", rainTime)
	end

	skyboxScrollX = skyboxScrollX - dt * 22

	if abot then abot:update(dt) end

	if trafficCtrl then trafficCtrl:update(dt) end

	if spraycan then spraycan:update(dt) end

	if picoShootingSprite.visible then
		picoShootingSprite:update(dt)
		-- BUG corregido: esta reversión automática a "boyfriend visible"
		-- es para la MECÁNICA DE JUEGO normal (terminó la animación de
		-- disparo/recarga, volver al sprite normal de Pico) -- durante la
		-- cutscene de Darnell, "cock" termina de reproducirse MUCHO antes
		-- de que el guion quiera mostrar a Pico normal otra vez (recién
		-- ~1.1s después, en D+5.1), así que esto hacía que Pico
		-- "reapareciera" de golpe a mitad de la cutscene -- el parpadeo
		-- errático reportado.
		if not isDarnellCutsceneActive and not picoShootingSprite:isAnimated() then
			picoShootingSprite.visible = false
			boyfriend.visible = true
		end
	end

	-- BUG corregido: picoIntroSprite (intro1/intro2/cockCutscene, SOLO
	-- usado en esta cutscene) nunca tenía un :update(dt) -- por eso
	-- aparecía "congelado" en el primer frame Y, combinado con el bug de
	-- abajo (faltaba también su :draw()), directamente invisible.
	if picoIntroSprite.visible then
		picoIntroSprite:update(dt)
	end

	-- weeks:update(dt) está congelado por completo durante la cutscene de
	-- Darnell (_G.cutscenePause) -- por eso el avance de frame de
	-- animación de estos 3 personajes tampoco corre ahí (mismo problema y
	-- misma solución que military/stage.lua ya usa para sus cutscenes).
	if isDarnellCutsceneActive then
		if boyfriend then boyfriend:update(dt) end
		if girlfriend then girlfriend:update(dt) end
		if enemy then enemy:update(dt) end
	end

	for i = #casings, 1, -1 do
		casings[i]:update(dt)
	end

	if pendingCasing then
		pendingCasing = pendingCasing - dt
		if pendingCasing <= 0 then
			pendingCasing = false
			local bfTLX, bfTLY = picoTopLeft()
			local c = casingModule.new(bfTLX + 250, bfTLY + 260)
			table.insert(casings, c)
		end
	end

	if darkenTimer > 0 then
		darkenTimer = darkenTimer - dt
		if darkenTimer <= 0 then
			darkenTimer = 0
			darkenStageProps()
		end
	end

	-- FlxTween.color real: 1.4s, vuelve de 0x222222 a blanco.
	if darkenTintT then
		darkenTintT = darkenTintT + dt
		local t = math.min(1, darkenTintT / 1.4)
		darkenTint = 0.133 + (1 - 0.133) * t
		if t >= 1 then darkenTintT = nil end
	end

	if bpm and absMusicTime then
		local curBeat = math.floor(musicTime * bpm / 60000)
		if curBeat > (lastBeatNum or -1) then
			lastBeatNum = curBeat
			trafficCtrl:beatHit(curBeat)
		end
	end
end

-- Hook de sección (mustHitSection cambia) -- llamado desde fuera por
-- weeks.lua si expone ese evento; como fallback, M.update() también
-- puede llamarlo si currentMustHit cambia entre frames.
local lastMustHit = nil
local function checkSectionChange()
	if weeks.currentMustHit ~= lastMustHit then
		lastMustHit = weeks.currentMustHit
		updateABotEye()
	end
end

local function drawStageContent()
	checkSectionChange()

	graphics.pushParallax(0.1)
		-- Cielo con scroll infinito (FlxTiledSprite real) -- copias con
		-- offset envuelto por módulo. Antes solo 2 copias (2*imgW de ancho
		-- total) -- a veces se veía un hueco negro en los extremos cuando
		-- la cámara se movía lo suficiente para correr el rango visible
		-- fuera de esa franja. 5 copias (centradas en el rango -2..+2)
		-- dan margen de sobra para cualquier posición de cámara razonable.
		local imgW = skyboxImg:getWidth() * 0.65
		local wrapped = skyboxScrollX % imgW
		graphics.setColor(1, 1, 1, 1)
		for i = -2, 2 do
			love.graphics.draw(skyboxImg, -650 + wrapped + imgW * i, -375, 0, 0.65, 0.65)
		end
	love.graphics.pop()

	graphics.pushParallax(0.2)
		skyline:draw()
	love.graphics.pop()

	graphics.pushParallax(0.3)
		foregroundCity:draw()
	love.graphics.pop()

	-- darkenTint: aplicado a los mismos sprites que "darkenable" en
	-- PhillyStreets.hx real (flash al disparar/golpear, ver
	-- darkenStageProps()) -- graphics.newImage/newSprite no tienen tinte
	-- propio, se envuelve cada :draw() con setColor.
	graphics.pushParallax(0.7, 1)
		graphics.setColor(darkenTint, darkenTint, darkenTint, 1)
		construction:draw()
		graphics.setColor(1, 1, 1, 1)
	love.graphics.pop()

	graphics.pushParallax(1)
		graphics.setColor(darkenTint, darkenTint, darkenTint, 1)
		highwayLights:draw()
		graphics.setColor(darkenTint, darkenTint, darkenTint, 0.6)
		highwayLightsLightmap:draw()
		graphics.setColor(darkenTint, darkenTint, darkenTint, 1)
		highway:draw()
		graphics.setColor(1, 1, 1, 1)
	love.graphics.pop()

	graphics.pushParallax(0.8, 1)
		graphics.setColor(darkenTint, darkenTint, darkenTint, 1)
		smog:draw()
		graphics.setColor(1, 1, 1, 1)
	love.graphics.pop()

	graphics.pushParallax(0.9, 1)
		graphics.setColor(darkenTint, darkenTint, darkenTint, 1)
		car1:draw()
		car2:draw()
		traffic:draw()
		graphics.setColor(darkenTint, darkenTint, darkenTint, 0.6)
		trafficLightmap:draw()
		graphics.setColor(1, 1, 1, 1)
	love.graphics.pop()

	graphics.pushParallax(1)
		graphics.setColor(darkenTint, darkenTint, darkenTint, 1)
		foreground:draw()
		graphics.setColor(1, 1, 1, 1)
	love.graphics.pop()

	-- Orden real (PhillyStreets.hx): abot se agrega en create() (ANTES de
	-- los personajes, que los agrega el framework justo después) -- spraycan
	-- y spraycanPile se agregan en createPost() (DESPUÉS de los personajes,
	-- por eso se dibujan ENCIMA/delante de ellos) -- y casingGroup se crea
	-- recién al primer casquillo (más tarde todavía), encima de todo. Antes
	-- esto estaba al revés (spraycanPile/spraycan dibujados ANTES que los
	-- personajes, tapando mal el oponente con las latas).
	graphics.pushParallax(1)
		if abot then abot:draw() end

		if girlfriend then girlfriend:draw() end

		if picoShootingSprite.visible then
			local bfTLX, bfTLY = picoTopLeft()
			local pOx, pOy = picoShootingSprite:getOrigin()
			picoShootingSprite.x, picoShootingSprite.y = bfTLX + pOx, bfTLY + pOy
			picoShootingSprite:draw()
		end
		-- BUG corregido: faltaba el :draw() de picoIntroSprite (intro1/
		-- intro2/cockCutscene) -- por eso Pico se veía invisible
		-- exactamente durante esas poses de la cutscene (playPicoCutsceneAnim
		-- ya le pone la posición correcta, solo faltaba dibujarlo).
		if picoIntroSprite.visible then
			picoIntroSprite:draw()
		end
		if boyfriend.visible then boyfriend:draw() end
		if enemy then enemy:draw() end

		graphics.setColor(darkenTint, darkenTint, darkenTint, 1)
		if spraycan then spraycan:draw() end
		spraycanPile:draw()
		graphics.setColor(1, 1, 1, 1)

		for _, c in ipairs(casings) do c:draw() end

		weeks:drawRating()
	love.graphics.pop()
end

-- setupRainShader() real aplica el shader vía FlxG.camera.setFilters(),
-- que en Flixel afecta SOLO esa cámara (no camHUD) -- acá se replica
-- dibujando drawStageContent() a un canvas propio y presentándolo con el
-- shader, dejando afuera tanto el HUD (weeks:drawUI(), dibujado después
-- de M.draw() en weekend1.lua) como el overlay de debug de abajo.
function M.draw()
	if rainShader and rainCanvas then
		-- main.lua ya aplicó el scale/translate de lovesize ANTES de
		-- llegar a este draw() (lovesize.begin()) -- si se dibuja al
		-- canvas con esa transformación todavía activa, el contenido
		-- queda escalado de más (el canvas tiene el tamaño NATIVO de
		-- lovesize, sin escalar). push()+origin() la resetea solo para
		-- la fase de "dibujar al canvas"; pop() la restaura para el
		-- draw() final del canvas, que SÍ debe pasar por esa
		-- transformación para llenar la ventana real correctamente.
		love.graphics.push()
		love.graphics.origin()
		love.graphics.setCanvas(rainCanvas)
		love.graphics.clear()
		drawStageContent()
		love.graphics.setCanvas()
		love.graphics.pop()

		love.graphics.setShader(rainShader)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(rainCanvas, 0, 0)
		love.graphics.setShader()
	else
		drawStageContent()
	end
end

-- ── Cutscene de Darnell (PhillyStreets.hx:darnellCutscene()) ────────────
-- Disparada por weeks/weekend1.lua DESPUÉS del video "darnellCutscene"
-- (story mode, primera vez con la canción "darnell"). Choreo de cámara
-- (zoom 1.3->0.66->0.77 + paneo entre Pico/Darnell, vía
-- weeks:getBfCamTarget()/getEnemyCamTarget()) y ocultado de HUD (vía
-- weeks:getGuiAlphaObj()) YA implementados -- ver M.startDarnellCutscene().
local cutsceneMusic, darnellLaughSnd, neneLaughSnd
local cutsceneTimers = {}

local function cutsceneTimer(delay, fn)
	table.insert(cutsceneTimers, Timer.after(delay, fn))
end

-- Pico durante la cutscene usa DOS atlas separados según la pose: intro1/
-- intro2/cockCutscene viven en Pico_Intro (picoIntroSprite), cock vive en
-- Pico_Shooting (picoShootingSprite) -- mismo split que la mecánica de
-- armas in-game, ver M.customNoteHit.
local function playPicoCutsceneAnim(sprite, animName)
	boyfriend.visible = false
	picoIntroSprite.visible = false
	picoShootingSprite.visible = false
	sprite.visible = true
	-- animate() PRIMERO: getOrigin() (sin argumento) usa el frame de
	-- inicio de la animación ACTUALMENTE activa -- si se llama antes de
	-- animate(), todavía refleja la pose VIEJA del sprite.
	sprite:animate(animName, false)
	local bfTLX, bfTLY = picoTopLeft()
	local pOx, pOy = sprite:getOrigin()
	sprite.x, sprite.y = bfTLX + pOx, bfTLY + pOy
end

-- BUG corregido: en la fuente real, gf.animation.finishCallback/
-- dad.animation.finishCallback re-disparan danceLeft/danceRight ("dance")
-- e "idle" cada vez que terminan -- yo solo llamaba :animate(nombre,
-- false) UNA vez al arrancar la cutscene, así que la animación corría
-- una sola pasada y quedaba congelada en su último frame el resto del
-- tiempo (~5s hasta el primer evento programado). Se repite a mano vía
-- el parámetro callback de :animate(), cortando apenas Darnell/Nene
-- pasan a otra animación (lightCan/kickCan/etc., que llaman :animate()
-- sin este callback, reemplazando el anterior automáticamente).
-- Character.hx:dance() real alterna con un booleano "danced = !danced"
-- entre danceRight/danceLeft -- yo solo repetía "danceLeft" siempre, por
-- eso Nene nunca alternaba.
local gfDanced = false
local function girlfriendDanceLoop()
	if not girlfriend then return end
	gfDanced = not gfDanced
	girlfriend:animate(gfDanced and "danceRight" or "danceLeft", false, girlfriendDanceLoop)
end

local function enemyIdleLoop()
	if not enemy then return end
	enemy:animate("idle", false, enemyIdleLoop)
end

function M.startDarnellCutscene(onComplete)
	-- BUG corregido (mismo que semana 7): sin esto, weeks:update(dt) sigue
	-- procesando notas/chart EN PARALELO a la cutscene -- el jugador
	-- termina muriendo por misses acumulados durante los 10s, o las
	-- animaciones de note-hit normales pisan a las de la cutscene si el
	-- chart ya arrancó. _G.cutscenePause es el mecanismo YA EXISTENTE que
	-- military/stage.lua usa para esto (weeks.lua:update()/updateUI()
	-- retornan temprano sin tocar musicTime/notas mientras está activo).
	_G.cutscenePause = true
	isDarnellCutsceneActive = true

	-- _G.disableAutoCam: evita que el sistema de cámara automático
	-- (mustHitSection) pelee con el tween manual de abajo -- mismo
	-- mecanismo que military/stage.lua usa para sus cutscenes (en
	-- realidad redundante mientras cutscenePause esté activo, porque
	-- weeks:update() corta antes de llegar al auto-cam de todas formas,
	-- pero se deja en true por las dudas y por claridad).
	_G.disableAutoCam = true

	-- Ocultar el HUD (barra de vida, score, flechas) durante la cutscene
	-- -- antes seguía visible encima de todo, cosa que NO pasa en la
	-- cutscene real ni en las de semana 7.
	if weeks.getGuiAlphaObj then
		weeks:getGuiAlphaObj().value = 0
	end

	-- Choreo de cámara: moveCamera(false) real (foco INICIAL, zoom 1.3)
	-- apunta a BOYFRIEND/Pico con offset fijo "camFollow.x += 250" ->
	-- cam.x = getBfCamTarget().x - 250 (signo invertido, ver comentario de
	-- arriba); moveCamera(true) (zoom-out a partir de D) apunta a
	-- DAD/Darnell con "camFollow.x += 100" -> cam.x = getEnemyCamTarget().x
	-- - 100 -- verificado contra PlayState.hx:moveCamera().
	-- BUG corregido (zoom): graphics.lua:pushParallax() lee cam.sizeX/sizeY
	-- para el zoom, NO camScale.x/y -- camScale solo se COMBINA hacia
	-- cam.sizeX/Y dentro de weeks:update() (congelado por cutscenePause),
	-- así que tweendear camScale no tenía NINGÚN efecto visual. Hay que
	-- tweendear cam.sizeX/Y directamente.
	if cam then
		cam.sizeX, cam.sizeY = 1.3, 1.3
		if boyfriend and weeks.getBfCamTarget then
			local bx, by = weeks:getBfCamTarget()
			cam.x, cam.y = bx - 250, by
		end
	end

	spraycan.cutscene = true

	cutsceneMusic = love.audio.newSource("music/darnellCanCutscene.ogg", "stream")
	cutsceneMusic:setLooping(true)

	darnellLaughSnd = love.audio.newSource("sounds/weekend1/cutscene/darnell_laugh.ogg", "static")
	darnellLaughSnd:setVolume(0.6)
	neneLaughSnd = love.audio.newSource("sounds/weekend1/cutscene/nene_laugh.ogg", "static")
	neneLaughSnd:setVolume(0.6)

	gfDanced = false
	girlfriendDanceLoop()
	enemyIdleLoop()
	playPicoCutsceneAnim(picoIntroSprite, "intro1")

	local D = 2.0  -- cutsceneDelay real

	cutsceneTimer(0.7, function() cutsceneMusic:play() end)

	-- moveCamera(true) (-> Darnell, +100) + zoom 0.66 real, en
	-- cutsceneDelay (D) exacto.
	cutsceneTimer(D, function()
		if cam and enemy and weeks.getEnemyCamTarget then
			Timer.tween(2.5, cam, { sizeX = 0.66, sizeY = 0.66 }, "in-out-quad")
			local ex, ey = weeks:getEnemyCamTarget()
			Timer.tween(2.5, cam, { x = ex - 100, y = ey }, "in-out-quad")
		end
	end)

	cutsceneTimer(D + 3, function()
		enemy:animate("lightCan", false)
		if lightCanSnd then lightCanSnd:stop(); lightCanSnd:play() end
	end)

	cutsceneTimer(D + 4, function()
		playPicoCutsceneAnim(picoShootingSprite, "cock")
		if gunPrepSnd then gunPrepSnd:stop(); gunPrepSnd:play() end

		-- Paneo extra real: camFollow.x+180 (sobre los +100 ya fijados en
		-- D) -> cam.x = getEnemyCamTarget().x - 180, 0.4s ease backOut --
		-- el scroll se acerca un poco más antes de que Pico recargue.
		if cam and enemy and weeks.getEnemyCamTarget then
			local ex = weeks:getEnemyCamTarget()
			Timer.tween(0.4, cam, { x = ex - 180 }, "out-back")
		end
	end)

	cutsceneTimer(D + 4.166, function()
		local bfTLX, bfTLY = picoTopLeft()
		table.insert(casings, casingModule.new(bfTLX + 250, bfTLY + 260))
	end)

	cutsceneTimer(D + 4.4, function()
		enemy:animate("kickCan", false)
		spraycan:playCanStart()
		if kickCanSnd then kickCanSnd:stop(); kickCanSnd:play() end
	end)

	cutsceneTimer(D + 4.8, function()
		enemy:animate("kneeCan", false)
		if kneeCanSnd then kneeCanSnd:stop(); kneeCanSnd:play() end
	end)

	cutsceneTimer(D + 5.1, function()
		playPicoCutsceneAnim(picoIntroSprite, "intro2")
		local s = shotSnds[love.math.random(1, 4)]
		if s then s:stop(); s:play() end
		spraycan:playCanShot()
		Timer.after(1 / 24, function() darkenStageProps() end)

		-- Vuelve al paneo base (camFollow.x+100) sobre 2.5s.
		if cam and enemy and weeks.getEnemyCamTarget then
			local ex = weeks:getEnemyCamTarget()
			Timer.tween(2.5, cam, { x = ex - 100 }, "in-out-quad")
		end
	end)

	cutsceneTimer(D + 5.9, function()
		enemy:animate("laughCutscene", false)
		darnellLaughSnd:play()
	end)

	cutsceneTimer(D + 6.2, function()
		girlfriend:animate("laughCutscene", false)
		neneLaughSnd:play()
	end)

	-- cutsceneHandler.endTime real = 10s.
	cutsceneTimer(10, function()
		if cutsceneMusic then cutsceneMusic:stop() end
		spraycan.visible = false
		spraycan.cutscene = false
		boyfriend.visible = true
		picoIntroSprite.visible = false
		picoShootingSprite.visible = false

		-- cutscenePause se apaga YA (el countdown/chart necesita correr
		-- normal de acá en más) pero disableAutoCam se mantiene un poco
		-- más, hasta que el tween de vuelta a zoom normal termine --
		-- apagarlo antes haría que el auto-cam (mustHitSection) peleara
		-- visualmente contra este tween, mismo criterio que
		-- military/stage.lua:finishCutsceneWithFade().
		_G.cutscenePause = false
		isDarnellCutsceneActive = false

		if cam then
			-- BUG corregido: 0.77 estaba hardcodeado -- el zoom "normal" de
			-- un stage es SIEMPRE stageData.defaultZoom (PlayState.hx:345),
			-- leído de stages/data/<id>.json, NUNCA un literal fijo (para
			-- phillyStreets.json da 0.77, pero no debe asumirse). Se lee
			-- dinámicamente vía psychStages (ya cacheado, sin re-leer el
			-- archivo) igual que charts/psych/stages.lua:M.apply() ya hace
			-- al cargar el stage por primera vez.
			local defaultZoom = (psychStages.getCurrentData() or {}).defaultZoom or 1
			Timer.tween(2, cam, { sizeX = defaultZoom, sizeY = defaultZoom }, "in-out-quad")
			-- camScale.x/y (la base que el auto-cam normal usa para
			-- RECALCULAR cam.sizeX/Y una vez disableAutoCam se apague) se
			-- deja en ese mismo valor para que no haya un salto al
			-- reactivarse -- sin esto, camScale se hubiera quedado pegado
			-- en 1.3 (nunca tocado desde el arranque de la cutscene).
			if camScale then camScale.x, camScale.y = defaultZoom, defaultZoom end
			-- finishCallback real: vuelve a camFollow.x+180 (mismo target
			-- de Darnell, +180 igual que el paso D+4) -> cam.x =
			-- getEnemyCamTarget().x - 180 -- el auto-cam real corrige el
			-- resto apenas disableAutoCam se apague al terminar este tween.
			if enemy and weeks.getEnemyCamTarget then
				local ex, ey = weeks:getEnemyCamTarget()
				Timer.tween(2, cam, { x = ex - 180, y = ey }, "in-out-quad", function()
					_G.disableAutoCam = false
				end)
			else
				_G.disableAutoCam = false
			end
		else
			_G.disableAutoCam = false
		end

		if weeks.getGuiAlphaObj then
			weeks:getGuiAlphaObj().value = 1
		end

		if onComplete then onComplete() end
	end)
end

function M.leave()
	for _, t in ipairs(cutsceneTimers) do Timer.cancel(t) end
	cutsceneTimers = {}
	if cutsceneMusic then cutsceneMusic:stop() end
	cutsceneMusic = nil; darnellLaughSnd = nil; neneLaughSnd = nil
	-- Seguro: si el jugador sale a mitad de la cutscene, que no queden
	-- pegados para siempre (romperían la próxima canción/semana entera --
	-- notas que nunca procesan, cámara que nunca se mueve, HUD invisible).
	_G.cutscenePause = false
	_G.disableAutoCam = false
	isDarnellCutsceneActive = false
	if weeks.getGuiAlphaObj then
		weeks:getGuiAlphaObj().value = 1
	end

	skybox = nil; skyline = nil; foregroundCity = nil; construction = nil
	highwayLights = nil; highwayLightsLightmap = nil; highway = nil; smog = nil
	foreground = nil; spraycanPile = nil
	car1 = nil; car2 = nil; traffic = nil; trafficLightmap = nil; trafficCtrl = nil
	abot = nil; spraycan = nil
	picoShootingSprite = nil; picoIntroSprite = nil
	casings = {}
	darkenTint = 1
	darkenTintT = nil

	rainShader = nil; rainCanvas = nil; rainTime = 0
end

return M
