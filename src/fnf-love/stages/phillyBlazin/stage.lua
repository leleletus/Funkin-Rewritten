-- Stage: "phillyBlazin" (Weekend 1 - Pico vs Darnell, canción "Blazin'") --
-- puerto 1:1 de states/stages/PhillyBlazin.hx, reconstruido desde cero
-- contra el código fuente real.

local M = {}

local bgsprite = require("charts.psych.bgsprite")
local psychStages = require("charts.psych.stages")
local abotModule = require("sprites.weekend1.abot-speaker")
local blazinFightModule = require("sprites.weekend1.blazin-fight")
local graphics = require("modules.graphics")

local scrollingSkyImg, scrollingSkyScrollX
local skyAdditive, lightning, foregroundCity, foregroundMultiply
local additionalLighten  -- {alpha=}, dibujado como rectángulo blanco ADD

local abot
local blazinFight

local lightningTimer = 3.0
local fadeAlpha = 1  -- createPost(): FlxG.camera.fade(BLACK, 1.5, true) -- arranca en negro, se aclara

-- Tinte de bf/dad y de gf/abot -- normalmente fijos (0.871/0.533, ver
-- createPost() real) pero el rayo los hace flashear MÁS OSCURO un golpe
-- (0xFF606060 ~= 0.376) y los vuelve a su tono normal en 0.3s
-- (FlxTween.color real, LIGHTNING_FADE_DURATION) -- antes esto faltaba
-- por completo, por eso el regreso a la normalidad se sentía abrupto
-- (en realidad era el regreso del FONDO, ya correcto, sin ningún cambio
-- acompañante en los personajes).
local tintState = { bf = 0.871, gf = 0.533 }

local lastBeatNum

-- ── Shader de lluvia (PhillyBlazin.hx:setupRainShader()) ────────────────
-- A diferencia de phillyStreets (intensidad rampeada por canción), acá es
-- FIJA en 0.5 -- lo que varía es rainTimeScale: normalmente decae casi a
-- 0 (lluvia casi congelada, "lenta") y cada rayo la dispara hacia arriba
-- (+0.7), dando el efecto de que la lluvia "acelera" un instante con cada
-- relámpago antes de volver a asentarse. Mismo mecanismo de canvas+shader
-- que phillyStreets/stage.lua (Rewritten no tiene filtros de cámara).
local rainShader, rainCanvas
local rainShaderTime = 0
local rainTimeScale = 1

function M.load()
	-- skyBlur/streetBlur: BGSprite SIN animArray en Psych real (imágenes
	-- estáticas, "new BGSprite('phillyBlazin/skyBlur', -600,-175, 0,0)" --
	-- bgsprite.new() exige al menos una animación, así que se usan como
	-- graphics.newImage() planas, igual que cualquier fondo estático del
	-- resto del proyecto.
	scrollingSkyImg = love.graphics.newImage(graphics.imagePath("phillyBlazin/skyBlur"))
	scrollingSkyScrollX = 0

	-- graphics.newImage() devuelve un WRAPPER que no expone :getWidth()/
	-- :getHeight() (eso solo existe en el love.graphics.Image crudo) --
	-- se calcula el tamaño ANTES de envolver la imagen.
	local skyRaw = love.graphics.newImage(graphics.imagePath("phillyBlazin/skyBlur"))
	skyAdditive = graphics.newImage(skyRaw)
	skyAdditive.sizeX, skyAdditive.sizeY = 1.75, 1.75
	skyAdditive.x, skyAdditive.y = -600 + skyRaw:getWidth() * 1.75 / 2, -175 + skyRaw:getHeight() * 1.75 / 2
	skyAdditive.visible = false
	skyAdditive.alpha = 0

	lightning = bgsprite.new("phillyBlazin/lightning", -50, -300, {"lightning0"}, false, 1.75, 1)
	lightning.visible = false

	local streetRaw = love.graphics.newImage(graphics.imagePath("phillyBlazin/streetBlur"))
	foregroundCity = graphics.newImage(streetRaw)
	foregroundCity.sizeX, foregroundCity.sizeY = 1.75, 1.75
	foregroundCity.x, foregroundCity.y = -600 + streetRaw:getWidth() * 1.75 / 2, -175 + streetRaw:getHeight() * 1.75 / 2

	foregroundMultiply = graphics.newImage(streetRaw)
	foregroundMultiply.sizeX, foregroundMultiply.sizeY = 1.75, 1.75
	foregroundMultiply.x, foregroundMultiply.y = foregroundCity.x, foregroundCity.y
	foregroundMultiply.visible = false
	foregroundMultiply.alpha = 0

	additionalLighten = { alpha = 0, visible = false }

	abot = abotModule.new(0, 0)

	blazinFight = blazinFightModule.new()
	_G.blazinFight = blazinFight  -- weekend1.lua/weeks.lua hooks lo leen de acá

	lightningTimer = 3.0
	fadeAlpha = 1
	lastBeatNum = -1

	psychStages.apply("phillyBlazin")

	-- A-Bot: posición FIJA, calculada UNA SOLA VEZ acá -- ver el comentario
	-- completo en stages/phillyStreets/stage.lua (confirmado contra
	-- PhillyBlazin.hx real: nunca se reasigna en update()).
	if abot then
		local gfOx, gfOy = 0, 0
		if girlfriend then gfOx, gfOy = girlfriend:getOrigin() end
		local gfTopLeftX = (girlfriend and girlfriend.x or 0) - gfOx
		local gfTopLeftY = (girlfriend and girlfriend.y or 0) - gfOy
		abot.x, abot.y = gfTopLeftX, gfTopLeftY + 550 - 200
	end

	-- createPost() real: personajes en gris, abot también -- 0xFFDEDEDE
	-- (bf/dad) ~= 0.871, 0xFF888888 (gf/abot) ~= 0.533.

	-- setupRainShader() real: intensidad FIJA 0.5 (no rampea por canción,
	-- a diferencia de phillyStreets).
	rainShaderTime = 0
	rainTimeScale = 1
	rainShader = love.graphics.newShader("shaders/rain.glsl")
	rainShader:send("uScale", lovesize.getHeight() / 200)
	rainShader:send("uIntensity", 0.5)
	rainShader:send("uTime", 0)
	rainCanvas = love.graphics.newCanvas(lovesize.getWidth(), lovesize.getHeight())
end

-- Ver phillyStreets/stage.lua:M.setupAbotAudio() (mismo mecanismo, mismo
-- motivo -- llamado por weeks/weekend1.lua después de cargar `inst`).
function M.setupAbotAudio(fileName)
	if not abot then return end
	local ok, soundData = pcall(love.sound.newSoundData, "music/" .. fileName .. "/Inst.ogg")
	abot:setAudioSource(ok and soundData or nil, _G.inst)
end

local function applyLightning()
	-- rainTimeScale += 0.7 real -- la lluvia "acelera" un instante con
	-- cada rayo antes de volver a asentarse (ver M.update()).
	rainTimeScale = rainTimeScale + 0.7

	skyAdditive.visible = true
	skyAdditive.alpha = 0.7
	Timer.tween(1.5, skyAdditive, { alpha = 0 }, "linear", function()
		skyAdditive.visible = false
		lightning.visible = false
		foregroundMultiply.visible = false
		additionalLighten.visible = false
	end)

	foregroundMultiply.visible = true
	foregroundMultiply.alpha = 0.64
	Timer.tween(1.5, foregroundMultiply, { alpha = 0 }, "linear")

	additionalLighten.visible = true
	additionalLighten.alpha = 0.3
	Timer.tween(0.3, additionalLighten, { alpha = 0 }, "linear")

	-- FlxTween.color(boyfriend/dad, 0.3, 0xFF606060, 0xFFDEDEDE) +
	-- FlxTween.color(gf/abot, 0.3, 0xFF606060, 0xFF888888) real -- flash
	-- más oscuro (0x60/255) que vuelve al tono normal en 0.3s.
	tintState.bf = 96 / 255
	tintState.gf = 96 / 255
	Timer.tween(0.3, tintState, { bf = 0.871, gf = 0.533 }, "linear")

	lightning.visible = true
	lightning:animate("lightning0", false)

	if love.math.random() < 0.65 then
		lightning.x = love.math.random(-250, 280)
	else
		lightning.x = love.math.random(780, 900)
	end

	audio.playSound(love.audio.newSource("sounds/weekend1/lightning/Lightning" .. love.math.random(1, 3) .. ".ogg", "static"))
end

function M.update(dt)
	-- update() real: rainShader.update(elapsed * rainTimeScale);
	-- rainTimeScale = lerp(0.02, min(1, rainTimeScale), exp(-elapsed/(1/3))).
	-- Decae exponencialmente hacia 0.02 (casi congelada) salvo que un rayo
	-- la dispare de nuevo (applyLightning(): += 0.7).
	if rainShader then
		rainShaderTime = rainShaderTime + dt * rainTimeScale
		rainShader:send("uTime", rainShaderTime)
		rainTimeScale = 0.02 + (math.min(1, rainTimeScale) - 0.02) * math.exp(-dt / (1 / 3))
	end

	scrollingSkyScrollX = scrollingSkyScrollX - dt * 35

	if abot then abot:update(dt) end

	-- skyAdditive/foregroundCity/foregroundMultiply son graphics.newImage()
	-- (imágenes estáticas, sin :update()) -- solo lightning es un sprite
	-- animado (bgsprite.new) que necesita avanzar frames.
	lightning:update(dt)

	lightningTimer = lightningTimer - dt
	if lightningTimer <= 0 then
		applyLightning()
		lightningTimer = love.math.random() * (15 - 7) + 7
	end

	if fadeAlpha > 0 then
		fadeAlpha = math.max(0, fadeAlpha - dt / 1.5)
	end
end

-- ── Hooks de mecánica de pelea (weeks.lua) ───────────────────────────────
-- Estructura real (PhillyBlazin.hx) -- CADA evento dispara a los DOS
-- managers, nunca solo a uno:
--   goodNoteHit(note)     -> picoFight.noteHit(note)  + darnellFight.noteHit(note)
--   noteMiss(note)        -> picoFight.noteMiss(note) + darnellFight.noteMiss(note)
--   opponentNoteHit(note) -> picoFight.noteMiss(note) + darnellFight.noteMiss(note)
--     (¡noteMiss, NO noteHit! -- cuando Darnell ejecuta con éxito su propio
--     golpe (nota "enemy", el bot nunca falla), eso es una falla desde la
--     perspectiva de Pico -- Psych real reutiliza el mismo switch de
--     noteMiss() para esto en lugar de un camino separado.)
-- Antes esto llamaba a UN SOLO manager por evento (picoNoteHit únicamente
-- al acertar, darnellNoteHit únicamente en notas enemy) -- por eso cada
-- personaje se quedaba en idle cuando le tocaba reaccionar al golpe del otro.
function M.customNoteHit(self, curAnim, note, bfSprite)
	if not blazinFight then return false end
	if note.noteTypeStr and note.noteTypeStr:sub(1, 9) == "weekend-1" then
		blazinFight:picoNoteHit(note)
		blazinFight:darnellNoteHit(note)
		return true
	end
	return false
end

function M.customNoteMiss(self, curAnim, note, bfSprite)
	if not blazinFight then return false end
	if note.noteTypeStr and note.noteTypeStr:sub(1, 9) == "weekend-1" then
		blazinFight:picoNoteMiss(note)
		blazinFight:darnellNoteMiss(note)
		return true
	end
	return false
end

function M.customEnemyNoteHit(self, curAnim, note, enemySprite)
	if not blazinFight then return false end
	if note.noteTypeStr and note.noteTypeStr:sub(1, 9) == "weekend-1" then
		blazinFight:picoNoteMiss(note)
		blazinFight:darnellNoteMiss(note)
		return true
	end
	return false
end

-- noteMissPress (input sin nota cerca, "misinput") -- Pico tira un golpe al
-- aire, Darnell esquiva/bloquea. weeks.lua no tiene un hook genérico para
-- esto todavía -- lo dispara el propio weekend1.lua al detectar el input
-- fallido (ver weeks/weekend1.lua).
function M.noteMissPress(direction)
	if not blazinFight then return end
	blazinFight:picoNoteMissPress()
	blazinFight:darnellNoteMissPress()
end

local function drawStageContent()
	graphics.pushParallax(0, 0)
		local imgW = scrollingSkyImg:getWidth() * 1.75 * 1.1
		local wrapped = scrollingSkyScrollX % imgW
		graphics.setColor(1, 1, 1, 1)
		for i = -2, 2 do
			love.graphics.draw(scrollingSkyImg, -500 + wrapped + imgW * i, -120, 0, 1.75 * 1.1, 1.75 / 1.1)
		end

		if skyAdditive.visible then
			love.graphics.setBlendMode("add")
			graphics.setColor(1, 1, 1, skyAdditive.alpha)
			skyAdditive:draw()
			love.graphics.setBlendMode("alpha")
			graphics.setColor(1, 1, 1, 1)
		end
	love.graphics.pop()

	graphics.pushParallax(0, 0)
		foregroundCity:draw()

		if foregroundMultiply.visible then
			love.graphics.setBlendMode("multiply", "premultiplied")
			graphics.setColor(1, 1, 1, foregroundMultiply.alpha)
			foregroundMultiply:draw()
			love.graphics.setBlendMode("alpha")
			graphics.setColor(1, 1, 1, 1)
		end

		if additionalLighten.visible then
			love.graphics.setBlendMode("add")
			graphics.setColor(1, 1, 1, additionalLighten.alpha)
			love.graphics.rectangle("fill", -2500, -2500, 5000, 5000)
			love.graphics.setBlendMode("alpha")
			graphics.setColor(1, 1, 1, 1)
		end

		if lightning.visible then
			lightning:draw()
		end
	love.graphics.pop()

	graphics.pushParallax(1)
		if abot then
			graphics.setColor(tintState.gf, tintState.gf, tintState.gf, 1)
			abot:draw()
			graphics.setColor(1, 1, 1, 1)
		end

		if girlfriend then
			graphics.setColor(tintState.gf, tintState.gf, tintState.gf, 1)
			girlfriend:draw()
			graphics.setColor(1, 1, 1, 1)
		end

		graphics.setColor(tintState.bf, tintState.bf, tintState.bf, 1)
		local bfInFront = not blazinFight or blazinFight.bfInFront
		if bfInFront then
			if enemy then enemy:draw() end
			if boyfriend then boyfriend:draw() end
		else
			if boyfriend then boyfriend:draw() end
			if enemy then enemy:draw() end
		end
		graphics.setColor(1, 1, 1, 1)

		weeks:drawRating()
	love.graphics.pop()

	if fadeAlpha > 0 then
		love.graphics.setColor(0, 0, 0, fadeAlpha)
		love.graphics.rectangle("fill", 0, 0, graphics.getWidth(), graphics.getHeight())
		love.graphics.setColor(1, 1, 1, 1)
	end
end

-- Mismo mecanismo de canvas+shader que phillyStreets/stage.lua (ver
-- comentario ahí) -- Rewritten no tiene filtros de cámara como Flixel.
function M.draw()
	if rainShader and rainCanvas then
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

function M.leave()
	scrollingSkyImg = nil
	skyAdditive = nil; lightning = nil; foregroundCity = nil; foregroundMultiply = nil
	additionalLighten = nil
	abot = nil
	blazinFight = nil
	_G.blazinFight = nil
	tintState.bf, tintState.gf = 0.871, 0.533

	rainShader = nil; rainCanvas = nil; rainShaderTime = 0; rainTimeScale = 1
end

return M
