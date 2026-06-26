-- Puerto de PhillyStreets.hx:createCasing() -- el casquillo de bala que
-- expulsa el arma de Pico al recargar ("weekend-1-cockgun"). Pop inicial
-- (animación "pop", 49 frames) hasta el frame 40 (0-indexed, IGUAL que el
-- real -- "Get the end position of the bullet dynamically", no es el
-- último frame), donde se le da velocidad/rotación y pasa a rodar con
-- física simple (fricción lineal constante, igual que el drag de Flixel:
-- decrece linealmente hasta 0, no exponencial).
local bgsprite = require("charts.psych.bgsprite")

local M = {}

function M.new(x, y)
	local self = {
		x = x or 0, y = y or 0,
		angle = 0,
		visible = true,
		state = "pop",       -- "pop" | "rolling"
		velocityX = 0,
		dragX = 0,
		angularVelocity = 0,
		angularDrag = 0,
		popStartFrame = nil,
		transitioned = false,
	}

	self.sprite = bgsprite.new("PicoBullet", 0, 0, {
		{name = "pop",  prefix = "Pop0"},
		{name = "idle", prefix = "Bullet0"},
	}, false)
	self.sprite:animate("pop", false)
	self.popStartFrame = self.sprite:getCurrentFrame()

	function self:update(dt)
		if self.state == "pop" then
			self.sprite:update(dt)

			local relFrame = self.sprite:getCurrentFrame() - self.popStartFrame
			if relFrame >= 40 and not self.transitioned then
				self.transitioned = true

				-- BUG corregido (segunda vuelta): el frame de transición
				-- ("Pop0041") es un recorte MINÚSCULO (24x26) dentro de un
				-- canvas ENORME (350x323, frameX=-323) -- el frame inicial
				-- de "idle" es un sprite chico y normal, con su propio
				-- origen muy distinto. graphics.lua centra cada frame de
				-- forma INDEPENDIENTE (igual que Flixel) -- al cambiar de
				-- animación, el contenido visual "salta" a menos que se
				-- compense self.x/y por la DIFERENCIA exacta entre el
				-- origen del frame VIEJO (pop, a punto de irse) y el
				-- origen del frame NUEVO (idle, recién empieza) -- ese es
				-- el equivalente real a "casing.x += frame.offset.x - 1"
				-- (que en Flixel compensa lo mismo, pero con su propia
				-- convención de origen). Sacar el ajuste sin reemplazarlo
				-- (intento anterior) dejaba el salto SIN compensar --
				-- "parecía caer bien" porque el frame de pop YA se veía
				-- corrido hacia abajo/derecha por su propio recorte, y al
				-- pasar a "idle" (sin compensación) el casquillo
				-- rebotaba hacia arriba-izquierda de golpe.
				local oldOx, oldOy = self.sprite:getOrigin(self.sprite:getCurrentFrame())
				self.sprite:animate("idle", true)
				local newOx, newOy = self.sprite:getOrigin()
				self.x = self.x - oldOx + newOx
				self.y = self.y - oldOy + newOy

				self.angle = 125.1

				local randomFactorA = love.math.random() * (10 - 3) + 3        -- random.float(3,10)
				local randomFactorB = love.math.random() * (2.0 - 1.0) + 1.0   -- random.float(1.0,2.0)
				self.velocityX = 20 * randomFactorB
				self.dragX = randomFactorA * randomFactorB

				self.angularVelocity = 100
				self.angularDrag = (self.dragX / self.velocityX) * 100

				self.state = "rolling"
			end
		elseif self.state == "rolling" then
			-- Drag de Flixel real: decremento LINEAL constante hacia 0 (no
			-- exponencial) -- FlxObject.hx:computeVelocity().
			local dragStep = self.dragX * dt
			if self.velocityX - dragStep > 0 then
				self.velocityX = self.velocityX - dragStep
			elseif self.velocityX + dragStep < 0 then
				self.velocityX = self.velocityX + dragStep
			else
				self.velocityX = 0
			end
			self.x = self.x + self.velocityX * dt

			local angDragStep = self.angularDrag * dt
			if self.angularVelocity - angDragStep > 0 then
				self.angularVelocity = self.angularVelocity - angDragStep
			elseif self.angularVelocity + angDragStep < 0 then
				self.angularVelocity = self.angularVelocity + angDragStep
			else
				self.angularVelocity = 0
			end
			self.angle = self.angle + self.angularVelocity * dt

			self.sprite:update(dt)
		end
	end

	function self:draw()
		if not self.visible then return end
		self.sprite.x, self.sprite.y = self.x, self.y
		self.sprite.orientation = math.rad(self.angle)
		self.sprite:draw()
	end

	return self
end

return M
