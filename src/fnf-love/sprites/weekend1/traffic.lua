-- Puerto del sistema de tráfico de PhillyStreets.hx: driveCar/driveCarBack/
-- driveCarLights/finishCarLights/changeLights -- autos que recorren una
-- curva bezier cuadrática mientras rotan, semáforo con 2 estados.
--
-- quadPath de Flixel real: una curva BEZIER CUADRÁTICA de 3 puntos (no 2 --
-- FlxTween.quadPath con 3 FlxPoint interpola los 3 como control points de
-- una cuadrática, NO los recorre en línea recta). FlxEase.sineIn/cubeOut
-- normalizadas a [0,1] (mismo dominio que easing de tweens reales).

local M = {}

local function lerp(a, b, t) return a + (b - a) * t end

local function quadBezier(t, p0x, p0y, p1x, p1y, p2x, p2y)
	local x = lerp(lerp(p0x, p1x, t), lerp(p1x, p2x, t), t)
	local y = lerp(lerp(p0y, p1y, t), lerp(p1y, p2y, t), t)
	return x, y
end

-- FlxEase reales usadas acá (todas normalizadas [0,1] -> [0,1]):
local function easeLinear(t) return t end
local function easeSineIn(t) return 1 - math.cos(t * math.pi / 2) end
local function easeCubeOut(t) return 1 - (1 - t) ^ 3 end

-- Tween de posición a lo largo de una curva bezier cuadrática + ángulo en
-- paralelo (mismo patrón que FlxTween.quadPath + FlxTween.angle corriendo
-- juntos en Psych real). startDelay: igual semántica que FlxTween
-- (Float, espera antes de empezar a tweenear -- el sprite NO se mueve
-- hasta que termine la demora).
local function makeTween(sprite, duration, startDelay, easeFn, p0x, p0y, p1x, p1y, p2x, p2y,
	angleStart, angleEnd, onComplete)
	return {
		sprite = sprite,
		elapsed = -(startDelay or 0),
		duration = duration,
		easeFn = easeFn,
		p0x = p0x, p0y = p0y, p1x = p1x, p1y = p1y, p2x = p2x, p2y = p2y,
		angleStart = angleStart, angleEnd = angleEnd,
		onComplete = onComplete,
		finished = false,
	}
end

local function updateTween(tw, dt)
	if tw.finished then return end
	tw.elapsed = tw.elapsed + dt
	if tw.elapsed < 0 then return end -- todavía en startDelay

	local t = math.min(1, tw.elapsed / tw.duration)
	local eased = tw.easeFn(t)

	local x, y = quadBezier(eased, tw.p0x, tw.p0y, tw.p1x, tw.p1y, tw.p2x, tw.p2y)
	-- BUG corregido (mismo patrón que el del tanque rodante de semana 7):
	-- FlxTween.quadPath en Psych real mueve sprite.x/y, que en Flixel es
	-- TOP-LEFT -- los puntos del path (p0x/p1x/... acá arriba) son
	-- coordenadas Psych tal cual. En Rewritten sprite.x/y es el CENTRO del
	-- sprite, así que hay que sumar getOrigin() en cada frame (no solo en
	-- la posición inicial vía bgsprite.new) o el auto queda corrido hacia
	-- arriba/izquierda por la mitad del alto/ancho de su frame actual.
	local ox, oy = tw.sprite:getOrigin()
	tw.sprite.x, tw.sprite.y = x + ox, y + oy
	tw.sprite.orientation = math.rad(lerp(tw.angleStart, tw.angleEnd, eased))

	if t >= 1 then
		tw.finished = true
		if tw.onComplete then tw.onComplete() end
	end
end

-- M.new(carSprite1, carSprite2, trafficSprite): construye el controlador.
-- Los 3 sprites (autos ida/vuelta + semáforo) ya vienen creados/posicionados
-- por el stage (bgsprite.new con sf propio) -- este módulo solo orquesta el
-- movimiento, no los crea.
function M.new(car1, car2, traffic)
	local self = {
		car1 = car1, car2 = car2, traffic = traffic,
		lightsStop = false,
		lastChange = 0,
		changeInterval = 8,
		carWaiting = false,
		carInterruptable = true,
		car2Interruptable = true,
		tweens = {},
	}

	local function addTween(tw)
		table.insert(self.tweens, tw)
	end

	-- offset real: [306.6, 168.3] -- resta fija sobre TODOS los puntos del
	-- path (PhillyStreets.hx real lo aplica así, no lo expongo como
	-- parámetro porque nunca cambia).
	local OX, OY = 306.6, 168.3

	function self:finishCarLights()
		self.carWaiting = false
		local duration = love.math.random() * (3 - 1.8) + 1.8
		local startDelay = love.math.random() * (1.2 - 0.2) + 0.2

		local p0x, p0y = 1950 - OX - 80, 980 - OY + 15
		local p1x, p1y = 2400 - OX, 980 - OY - 50
		local p2x, p2y = 3102 - OX, 1127 - OY + 40

		addTween(makeTween(self.car1, duration, startDelay, easeSineIn,
			p0x, p0y, p1x, p1y, p2x, p2y, -5, 18, function()
				self.carInterruptable = true
			end))
	end

	function self:driveCarLights()
		self.carInterruptable = false
		local variant = love.math.random(1, 4)
		self.car1:animate("car" .. variant, false)

		local extraOffset = {0, 0}
		local duration = 2
		if variant == 1 then duration = love.math.random() * (1.7 - 1) + 1
		elseif variant == 2 then extraOffset = {20, -15}; duration = love.math.random() * (1.5 - 0.9) + 0.9
		elseif variant == 3 then extraOffset = {30, 50};  duration = love.math.random() * (2.5 - 1.5) + 1.5
		elseif variant == 4 then extraOffset = {10, 60};  duration = love.math.random() * (2.5 - 1.5) + 1.5
		end
		self.car1.offsetX, self.car1.offsetY = extraOffset[1], extraOffset[2]

		local p0x, p0y = 1500 - OX - 20, 1049 - OY - 20
		local p1x, p1y = 1770 - OX - 80, 994 - OY + 10
		local p2x, p2y = 1950 - OX - 80, 980 - OY + 15

		addTween(makeTween(self.car1, duration, 0, easeCubeOut,
			p0x, p0y, p1x, p1y, p2x, p2y, -7, -5, function()
				self.carWaiting = true
				if not self.lightsStop then self:finishCarLights() end
			end))
	end

	function self:driveCar()
		self.carInterruptable = false
		local variant = love.math.random(1, 4)
		self.car1:animate("car" .. variant, false)

		local extraOffset = {0, 0}
		local duration = 2
		if variant == 1 then duration = love.math.random() * (1.7 - 1) + 1
		elseif variant == 2 then extraOffset = {20, -15}; duration = love.math.random() * (1.2 - 0.6) + 0.6
		elseif variant == 3 then extraOffset = {30, 50};  duration = love.math.random() * (2.5 - 1.5) + 1.5
		elseif variant == 4 then extraOffset = {10, 60};  duration = love.math.random() * (2.5 - 1.5) + 1.5
		end
		self.car1.offsetX, self.car1.offsetY = extraOffset[1], extraOffset[2]

		local p0x, p0y = 1570 - OX, 1049 - OY - 30
		local p1x, p1y = 2400 - OX, 980 - OY - 50
		local p2x, p2y = 3102 - OX, 1127 - OY + 40

		addTween(makeTween(self.car1, duration, 0, easeLinear,
			p0x, p0y, p1x, p1y, p2x, p2y, -8, 18, function()
				self.carInterruptable = true
			end))
	end

	function self:driveCarBack()
		self.car2Interruptable = false
		local variant = love.math.random(1, 4)
		self.car2:animate("car" .. variant, false)

		local extraOffset = {0, 0}
		local duration = 2
		if variant == 1 then duration = love.math.random() * (1.7 - 1) + 1
		elseif variant == 2 then extraOffset = {20, -15}; duration = love.math.random() * (1.2 - 0.6) + 0.6
		elseif variant == 3 then extraOffset = {30, 50};  duration = love.math.random() * (2.5 - 1.5) + 1.5
		elseif variant == 4 then extraOffset = {10, 60};  duration = love.math.random() * (2.5 - 1.5) + 1.5
		end
		self.car2.offsetX, self.car2.offsetY = extraOffset[1], extraOffset[2]

		local p0x, p0y = 3102 - OX, 1127 - OY + 60
		local p1x, p1y = 2400 - OX, 980 - OY - 30
		local p2x, p2y = 1570 - OX, 1049 - OY - 10

		addTween(makeTween(self.car2, duration, 0, easeLinear,
			p0x, p0y, p1x, p1y, p2x, p2y, 18, -8, function()
				self.car2Interruptable = true
			end))
	end

	function self:changeLights(beat)
		self.lastChange = beat
		self.lightsStop = not self.lightsStop

		if self.lightsStop then
			self.traffic:animate("greentored", false)
			self.changeInterval = 20
		else
			self.traffic:animate("redtogreen", false)
			self.changeInterval = 30
			if self.carWaiting then self:finishCarLights() end
		end
	end

	-- beatHit(): llamar una vez por beat (PhillyStreets.hx:beatHit()).
	function self:beatHit(curBeat)
		if love.math.random() < 0.10 and curBeat ~= (self.lastChange + self.changeInterval) and self.carInterruptable then
			if not self.lightsStop then
				self:driveCar()
			else
				self:driveCarLights()
			end
		end

		if love.math.random() < 0.10 and curBeat ~= (self.lastChange + self.changeInterval) and self.car2Interruptable and not self.lightsStop then
			self:driveCarBack()
		end

		if curBeat == (self.lastChange + self.changeInterval) then
			self:changeLights(curBeat)
		end
	end

	function self:update(dt)
		for i = #self.tweens, 1, -1 do
			updateTween(self.tweens[i], dt)
			if self.tweens[i].finished then table.remove(self.tweens, i) end
		end
	end

	return self
end

return M
