-- Puerto de states/stages/objects/SpraycanAtlasSprite.hx -- la lata que
-- Darnell patea/enciende, usada en la cutscene de Darnell Y en la
-- mecánica de armas en vivo (playCanStart/playCanShot, ver
-- PhillyStreets.hx:goodNoteHit() "weekend-1-cockgun"/"weekend-1-firegun").
local animateAtlas = require("modules.animate_atlas")
local graphics = require("modules.graphics")

local M = {}

function M.new(x, y)
	local self = {
		x = x or 0, y = y or 0,
		visible = false,
		active = false,
		currentState = "WAITING",  -- WAITING | ARCING | SHOT | IMPACTED
		cutscene = false,
		playingAnim = nil,
		-- Ajuste en vivo opcional (debug, ver stages/phillyStreets/stage.lua)
		-- sobre el offset fijo -25/-450 de la explosión -- 0,0 por defecto,
		-- sin efecto si nadie los toca.
		explosionOffsetX = 0,
		explosionOffsetY = 0,
	}

	local data = animateAtlas.load("images/png/spraycanAtlas")
	self.canInst = animateAtlas.newInstance(data)

	local explosionImg = love.graphics.newImage(graphics.imagePath("spraypaintExplosionEZ"))
	local atlas = require("charts.psych.atlas")
	local frames = atlas.loadSparrow("images/png/spraypaintExplosionEZ.xml")
	local explosionFrames = {}
	for _, f in ipairs(frames) do
		if f.name and f.name:sub(1, #"explosion round 1 short0") == "explosion round 1 short0" then
			table.insert(explosionFrames, {
				x = f.x, y = f.y, width = f.width, height = f.height,
				offsetX = f.frameX, offsetY = f.frameY,
				offsetWidth = f.frameWidth, offsetHeight = f.frameHeight,
			})
		end
	end
	self.explosion = graphics.newSprite(explosionImg, explosionFrames,
		{ idle = { start = 1, stop = #explosionFrames, speed = 24, offsetX = 0, offsetY = 0 } },
		"idle", false)
	self.explosion.visible = false

	local function finishCanAnimation()
		if self.playingAnim == "Can Start" then
			self:playHitPico()
		elseif self.playingAnim == "Can Shot" then
			self.visible = false
			self.active = false
			self.currentState = "WAITING"
		elseif self.playingAnim == "Hit Pico" then
			if not self.cutscene then
				self.explosion.visible = true
				self.explosion:animate("idle", false)
			end
			self.visible = false
			self.active = false
			self.currentState = "WAITING"
		end
	end
	self.canInst:onComplete(finishCanAnimation)

	function self:playAnimation(name, startIdx, endIdx)
		self.playingAnim = name
		self.canInst:playSymbolRange("Can with Labels", startIdx, endIdx, false)
	end

	-- Rangos reales de SpraycanAtlasSprite.hx (símbolo "Can with Labels"):
	--   Can Start [0..18], Hit Pico [19..25], Can Shot [26..42]
	function self:playCanStart()
		self:playAnimation("Can Start", 0, 18)
		self.visible = true
		self.active = true
		self.currentState = "ARCING"
	end

	function self:playCanShot()
		self:playAnimation("Can Shot", 26, 42)
		self.currentState = "SHOT"
	end

	function self:playHitPico()
		self:playAnimation("Hit Pico", 19, 25)
		self.currentState = "IMPACTED"
	end

	-- SOLO para herramientas de debug/ajuste -- muestra la explosión
	-- aislada, sin pasar por la lata (Can Start/Hit Pico) primero. Nunca
	-- se usa en el flujo de juego real (ahí siempre se llega por la
	-- cadena automática de finishCanAnimation, igual que el real).
	function self:debugPlayExplosionOnly()
		self.explosion.visible = true
		self.explosion:animate("idle", false)
	end

	function self:update(dt)
		if self.active then
			self.canInst:update(dt)
		end
		if self.explosion.visible then
			self.explosion:update(dt)
			if not self.explosion:isAnimated() then
				self.explosion.visible = false
			end
		end
	end

	function self:draw()
		if self.visible and self.active then
			self.canInst.x, self.canInst.y = self.x, self.y
			self.canInst:draw()
		end
		if self.explosion.visible then
			-- BUG corregido: self.x-25/self.y-450 son coordenadas Psych
			-- (top-left, "new FlxSprite(x-25,y-450)" real) asignadas
			-- DIRECTO a self.explosion.x/y, que en este motor es el
			-- CENTRO del frame actual -- sin sumar getOrigin() quedaba
			-- corrida desde el primer frame (mismo patrón que casing.lua/
			-- picoTopLeft() en stage.lua). getOrigin() es estable acá
			-- porque "idle" es la única animación del explosion (anim.
			-- start nunca cambia).
			local exOx, exOy = self.explosion:getOrigin()
			self.explosion.x = self.x + 282 + exOx + self.explosionOffsetX
			self.explosion.y = self.y - 145 + exOy + self.explosionOffsetY
			self.explosion:draw()
		end
	end

	return self
end

return M
