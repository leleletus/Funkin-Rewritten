-- Puerto de states/stages/objects/ABotSpeaker.hx -- el robot-parlante de
-- fondo en PhillyStreets/PhillyBlazin.
--
-- Analizador espectral de audio (#if funkin.vis -- SpectralAnalyzer, las 7
-- barras "viz" reactivas a la música, el "speaker" rebotando con el golpe
-- detectado): código fuente REAL de las 2 librerías de las que depende,
-- ambas conseguidas por el usuario -- funkVis-main (SpectralAnalyzer.hx)
-- y grig.audio-funkin (FFT.hx/FFTVisualization.hx, la FFT y el binning
-- logarítmico reales) -- portado en modules/spectral_analyzer.lua (FFT
-- vía modules/dsp_fft.lua, verificada bit-exacta contra el test del
-- propio repo de grig.audio) y modules/spectral_analyzer.lua (binning,
-- dB, suavizado, todo 1:1 contra ese código fuente -- ver el comentario
-- detallado al principio de ese archivo sobre la única pieza que sigue
-- siendo una reconstrucción: la versión EXTENDIDA de makeLogGraph() que
-- SpectralAnalyzer.hx llama, con 4 argumentos más que la versión pública
-- del repo de grig.audio conseguido). soundData decodificado aparte del
-- instrumental real (ver self:setAudioSource() más abajo).
local bgsprite = require("charts.psych.bgsprite")
local animateAtlas = require("modules.animate_atlas")
local graphics = require("modules.graphics")
local spectralAnalyzer = require("modules.spectral_analyzer")

local M = {}

-- VIZ_POS_X/Y de ABotSpeaker.hx real: posiciones ACUMULADAS (cada barra se
-- desplaza relativa a la anterior, arrancando en 140,74).
local VIZ_POS_X = {0, 59, 56, 66, 54, 52, 51}
local VIZ_POS_Y = {0, -8, -3.5, -0.4, 0.5, 4.7, 7}

function M.new(x, y)
	local self = {
		x = x or 0, y = y or 0,
		visible = true,
		lookingRight = true,
		levelMax = 0,
		analyzeTimer = 0,
	}

	-- bg: 'abot/stereoBG' en (90,20) relativo al grupo (FlxSpriteGroup de
	-- Psych: x,y de cada hijo son YA absolutos top-left de Flixel, sin
	-- conversión de centro -- graphics.newImage es centro-anclado, así que
	-- se suma medio ancho/alto nativo, igual que el resto del proyecto).
	local bgImg = love.graphics.newImage(graphics.imagePath("abot/stereoBG"))
	self.bg = graphics.newImage(bgImg)
	-- graphics.newImage() no expone :getWidth()/:getHeight() (solo el
	-- love.graphics.Image crudo las tiene) -- offset relativo precalculado
	-- una vez, ver self:draw() donde se suma a self.x/y cada frame.
	self.bgOffsetX = 90 + bgImg:getWidth() / 2
	self.bgOffsetY = 20 + bgImg:getHeight() / 2

	-- vizSprites: 7 barras, congeladas en su último frame (curAnim:finish()
	-- en Psych real -- "que vaya al punto más bajo"). bgsprite.new() ya
	-- arranca animaciones en loop=false sin auto-loop -- alcanza con
	-- animarlas hasta el último frame una sola vez.
	self.vizSprites = {}
	local vizX, vizY = 0, 0
	for i = 1, 7 do
		vizX = vizX + VIZ_POS_X[i]
		vizY = vizY + VIZ_POS_Y[i]
		local viz = bgsprite.new("abot/aBotViz", 0, 0, {{name = "VIZ", prefix = "viz" .. i}}, false)
		-- Congelar en el último frame (curAnim.finish() de Flixel real) --
		-- ANTES de leer getOrigin(), porque el origen depende del frame
		-- activo (puede variar entre los 7 "viz1".."viz7").
		viz:setFrame(viz:getFrameCount())
		-- BUG corregido: faltaba la conversión top-left (Psych) -> centro
		-- (Rewritten) -- se estaba usando vizX+140/vizY+74 (coordenadas
		-- top-left) directo como si fueran coordenadas de centro, dejando
		-- las 7 barras visiblemente desalineadas entre sí.
		local vox, voy = viz:getOrigin()
		viz._relX, viz._relY = vizX + 140 + vox, vizY + 74 + voy
		table.insert(self.vizSprites, viz)
	end

	-- eyeBg: rectángulo blanco sólido 160x60 en (-30,215).
	self.eyeBg = { relX = -30 + 80, relY = 215 + 30, w = 160, h = 60 }

	-- eyes: Adobe Animate 'abot/systemEyes', símbolo "a bot eyes lookin"
	-- dividido en 2 rangos -- mismo patrón que darnell-blazin/pico-blazin
	-- (ver charts/psych/character.lua:loadAnimateCharacter()), pero acá
	-- standalone (no es un personaje del registro, es parte de este objeto
	-- de stage). ABotSpeaker.hx real usa addBySymbolIndices con [0..17]/
	-- [18..35] (36 frames), pero el símbolo de ESTE asset solo tiene 32
	-- frames reales (verificado leyendo el Animation.json -- la última
	-- entrada es I=30,DU=2, cubre hasta el índice 31) -- se parte 16/16
	-- en su lugar, mismo criterio (mitad y mitad), sin referenciar índices
	-- fuera de rango.
	local eyesData = animateAtlas.load("images/png/abot/systemEyes")
	self.eyesInst = animateAtlas.newInstance(eyesData)
	-- BUG corregido: este loop inicial estaba en `true`, pero
	-- ABotSpeaker.hx real registra AMBAS animaciones (lookleft/lookright)
	-- con loop=false (addBySymbolIndices(..., 24, false)) -- con loop=true
	-- los ojos quedaban ciclando sin parar la pose "mirando a la derecha"
	-- en vez de quedarse quietos en el último frame hasta el próximo
	-- cambio de sección, lo que se percibía como "los ojos no se mueven".
	self.eyesInst:playSymbolRange("a bot eyes lookin", 16, 31, false)
	self.eyesInst.frame = 15 -- curFrame = anim.length-1: arranca ya mirando a la derecha, quieto
	-- Coordenadas EXACTAS de ABotSpeaker.hx real (new FlxAnimate(-10, 230)) --
	-- sin ajuste inventado: un FlxAnimate es un FlxSprite normal, su x/y es
	-- el top-left de SU PROPIO espacio de símbolo (el punto de registro que
	-- el artista de Adobe Animate haya usado), no hay una conversión de
	-- centro/bounding-box genérica posible acá (a diferencia de los frames
	-- Sparrow, que sí tienen un bounding box bien definido) -- mismo
	-- criterio ya documentado para personajes Adobe Animate en
	-- character.lua: la posición final se ajusta a mano, no por fórmula.
	self._eyesRelX, self._eyesRelY = -10, 230

	-- speaker: Adobe Animate 'abot/abotSystem', símbolo "Abot System"
	-- completo (sin rango -- es UN solo símbolo, no "ALL ANIMS"),
	-- congelado en su último frame (igual que vizSprites).
	local speakerData = animateAtlas.load("images/png/abot/abotSystem")
	self.speakerInst = animateAtlas.newInstance(speakerData)
	self.speakerInst:playSymbol("Abot System", false)
	-- Coordenadas EXACTAS de ABotSpeaker.hx real (new FlxAnimate(-65, -10)) --
	-- mismo criterio que self._eyesRelX/Y arriba, ver ese comentario.
	self._speakerRelX, self._speakerRelY = -65, -10

	function self:lookLeft()
		if self.lookingRight then
			self.eyesInst:playSymbolRange("a bot eyes lookin", 0, 15, false)
		end
		self.lookingRight = false
	end

	function self:lookRight()
		if not self.lookingRight then
			self.eyesInst:playSymbolRange("a bot eyes lookin", 16, 31, false)
		end
		self.lookingRight = true
	end

	-- soundData: love.sound.SoundData del MISMO instrumental que está
	-- sonando (decodificado aparte para análisis -- ver
	-- modules/spectral_analyzer.lua). source: el Source REAL en
	-- reproducción (love.audio), usado solo para leer su posición actual
	-- (:tell("seconds")) y mantener el análisis sincronizado con lo que se
	-- escucha. Si soundData es nil (formato no soportado, archivo
	-- faltante, etc.) las barras simplemente quedan congeladas, igual que
	-- el comportamiento de Psych SIN funkin.vis.
	function self:setAudioSource(soundData, source)
		self.audioSource = source
		-- Parámetros EXACTOS de ABotSpeaker.hx: "new SpectralAnalyzer(...,
		-- 7, 0.1, 40)" (barCount=7, smoothingTimeConstant=0.1, peakHold=40
		-- -- peakHold no se porta, ver comentario en spectral_analyzer.lua,
		-- ABotSpeaker tampoco lee .peak) + el override "#if desktop
		-- analyzer.fftN = 256" (líneas 126-130 reales).
		--
		-- BUG corregido (barra 1 muerta para siempre): con minFreq=50 (el
		-- default de la clase, lo que ABotSpeaker.hx de PSYCH usa sin
		-- override) + fftN=256, el rango de bins de la banda más grave
		-- cae por debajo de la resolución mínima de la FFT -- queda
		-- vacío/degenerado siempre. El código fuente REAL del juego
		-- oficial (Funkin-main/source/funkin/audio/visualize/ABotVis.hx:
		-- initAnalyzer()) tiene EXACTAMENTE este mismo problema
		-- documentado y ya solucionado ahí: "we use a very low minFreq
		-- since some songs use low low subbass like a boss" ->
		-- minFreq=10 (en vez de 50), minDb=-65/maxDb=-25 (en vez de
		-- -70/-20). Se adopta esa sintonización ya hecha y probada en
		-- vez de inventar una propia.
		self.analyzer = soundData and spectralAnalyzer.new(soundData, 7, 0.1, 256, 10, 22000, -65, -25) or nil
	end

	-- beatHit() real: reinicia la animación del speaker (rebote).
	function self:beatHit()
		self.speakerInst:playSymbol("Abot System", false)
	end

	function self:update(dt)
		for _, viz in ipairs(self.vizSprites) do viz:update(dt) end
		self.eyesInst:update(dt)
		self.speakerInst:update(dt)

		if self.analyzer and self.audioSource then
			-- Throttle a ~30Hz -- el suavizado exponencial del analizador
			-- (smoothingTimeConstant) ya hace que el resultado se vea
			-- fluido igual, y reduce el costo de la FFT a la mitad.
			self.analyzeTimer = self.analyzeTimer + dt
			if self.analyzeTimer >= 1 / 30 then
				self.analyzeTimer = 0

				-- BUG corregido: durante la cinemática de Darnell y el
				-- countdown, `inst` (audioSource) existe pero TODAVÍA NO
				-- está sonando (:play() recién lo dispara
				-- weeks:setupCountdown(), llamado DESPUÉS de la cutscene)
				-- -- analyze() seguía leyendo SIEMPRE la misma ventana fija
				-- del archivo (su contenido real en el instante en el que
				-- inst está parado), mostrando un patrón no-cero pero
				-- CONGELADO, como si algo estuviera sonando. Si no está
				-- reproduciendo, se decae hacia 0 en vez de analizar --
				-- mismo criterio que getDefaultLevels()/"deberían quedarse
				-- quietas" pedido.
				local ok, levels = pcall(function()
					if self.audioSource:isPlaying() then
						return self.analyzer:analyze(self.audioSource:tell("seconds"))
					end
					return self.analyzer:decay()
				end)
				if not ok then levels = nil end

				if levels then
					local oldLevelMax = self.levelMax
					local newLevelMax = 0

					for i, viz in ipairs(self.vizSprites) do
						local maxFrame = viz:getFrameCount() - 1
						local animFrame = math.floor(0.5 + (levels[i] or 0) * maxFrame)
						animFrame = math.abs(math.max(0, math.min(maxFrame, animFrame)) - maxFrame)
						viz:setFrame(animFrame + 1)
						newLevelMax = math.max(newLevelMax, maxFrame - animFrame)
					end

					-- ABotSpeaker.hx real: if(levelMax>=4) if(oldLevelMax<=
					-- levelMax && (levelMax>=5 || speaker.curFrame>=3)) beatHit()
					if newLevelMax >= 4 and oldLevelMax <= newLevelMax
						and (newLevelMax >= 5 or self.speakerInst.frame >= 3) then
						self:beatHit()
					end

					self.levelMax = newLevelMax
				end
			end
		end
	end

	function self:draw()
		if not self.visible then return end

		self.bg.x, self.bg.y = self.x + self.bgOffsetX, self.y + self.bgOffsetY
		self.bg:draw()

		-- BUG corregido: este :draw() hardcodeaba blanco (1,1,1,1) para el
		-- rectángulo y nunca tintaba eyesInst/speakerInst -- el tinte
		-- gris que el stage pone ANTES de llamar abot:draw() (para que
		-- coincida con girlfriend, createPost() real: abot.color =
		-- 0xFF888888) se perdía a partir de acá, dejando los ojos/parlante
		-- siempre en blanco puro sin importar el tinte pedido.
		local tr, tg, tb, ta = love.graphics.getColor()

		for _, viz in ipairs(self.vizSprites) do
			viz.x = self.x + viz._relX
			viz.y = self.y + viz._relY
			viz:draw()
		end

		love.graphics.setColor(tr, tg, tb, ta)
		love.graphics.rectangle("fill",
			self.x + self.eyeBg.relX - self.eyeBg.w / 2,
			self.y + self.eyeBg.relY - self.eyeBg.h / 2,
			self.eyeBg.w, self.eyeBg.h)

		self.eyesInst.tintR, self.eyesInst.tintG, self.eyesInst.tintB = tr, tg, tb
		self.eyesInst.x = self.x + self._eyesRelX
		self.eyesInst.y = self.y + self._eyesRelY
		self.eyesInst:draw()

		self.speakerInst.tintR, self.speakerInst.tintG, self.speakerInst.tintB = tr, tg, tb
		self.speakerInst.x = self.x + self._speakerRelX
		self.speakerInst.y = self.y + self._speakerRelY
		self.speakerInst:draw()

		love.graphics.setColor(tr, tg, tb, ta)
	end

	return self
end

return M
