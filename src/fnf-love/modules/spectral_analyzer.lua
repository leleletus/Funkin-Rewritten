-- Puerto 1:1 de funkin.vis.dsp.SpectralAnalyzer (camino desktop), usando
-- AHORA el código fuente real de sus dos dependencias, ambas conseguidas
-- por el usuario:
--   - funkVis-main/src/funkin/vis/dsp/SpectralAnalyzer.hx (la clase en sí)
--   - grig.audio-funkin/src/grig/audio/FFT.hx (la FFT real, ver
--     modules/dsp_fft.lua -- portada y verificada bit-exacta contra
--     tests/FFTVisualizationTest.hx del propio repo de grig.audio)
--   - grig.audio-funkin/src/grig/audio/FFTVisualization.hx (el binning
--     logarítmico + conversión a dB, ver computeFreqBand()/makeLogGraph()
--     más abajo -- portados literalmente, también verificados contra el
--     mismo test, ver el comentario al final de este archivo)
--
-- ÚNICA pieza que sigue siendo una reconstrucción (no código fuente
-- literal disponible): SpectralAnalyzer.hx llama
-- `vis.makeLogGraph(freqs, barCount+1, dbRange, range, fftN, sampleRate,
-- minFreq, maxFreq)` -- 8 argumentos. La FFTVisualization.hx real (la del
-- repo grig.audio-funkin que se consiguió) solo expone una versión
-- PÚBLICA de 4 argumentos (freq, bands, dbRange, intRange), confirmado
-- contra su propio test (FFTVisualizationTest.hx usa exactamente esos 4).
-- Esto significa que Psych/funkVis depende de una versión EXTENDIDA de
-- grig.audio (probablemente un fork interno, o una versión más nueva) que
-- agrega frequency-awareness a computeLogXScale() -- su código fuente
-- exacto no está disponible.
--
-- Se PROBÓ generalizar computeLogXScale() interpolando en FRECUENCIA real
-- (vía freqToBin(), código fuente real visible en el camino #if web de
-- SpectralAnalyzer.hx) entre minFreq y maxFreq -- pero numéricamente daba
-- PEOR resultado que la fórmula literal: con minFreq=10/fftN=256 (los
-- valores reales que ABotVis.hx/ABotSpeaker.hx usan), el bin
-- correspondiente a minFreq cae tan cerca de 0 que VARIAS bandas graves
-- consecutivas colapsan al mismo rango de bins vacío -- más bandas
-- muertas que con la fórmula original, no menos. Se usa en cambio la
-- fórmula EXACTA tal cual existe, generalizada SOLO en el tamaño total de
-- bins disponibles (binCount=fftN/2, que en el original es justamente el
-- valor que "256" representa para su N=512 fijo -- no es un número
-- arbitrario, es ESE cálculo para ESE N). El resto del pipeline
-- (computeFreqBand, makeLogGraph, la FFT, el suavizado) es 100% código
-- fuente real, sin adivinar nada.
--
-- Por qué "barCount+1" bands y se descarta el último: real
-- (computeLogXScale) deja xscale[bands] en 0.0 sin llenarlo -- el ÚLTIMO
-- "band" que use ese slot como límite superior da basura/NaN
-- (log de un número negativo). Pedir barCount+1 bands y descartar el
-- último (índice barCount) es justo el truco que el código fuente real de
-- SpectralAnalyzer.hx usa para nunca tocar ese slot roto -- se replica
-- exacto.

local dspFft = require("modules.dsp_fft")

local M = {}

-- computeLogXScale() real -- EXACTA, generalizada SOLO en el tamaño total
-- de bins disponibles (binCount = fftN/2) en vez del "256" hardcodeado
-- (que en el original es justamente fftN/2 para su N=512 fijo -- no es un
-- valor arbitrario, es ESE mismo cálculo para ESE N).
--
-- Probado y descartado: una versión "consciente de Hz" (interpolando
-- minFreq..maxFreq en vez de bin 1..binCount, vía freqToBin()) para poder
-- aprovechar los minFreq/maxFreq que SpectralAnalyzer.hx sí pasa --
-- numéricamente daba PEOR resultado que esta versión simple: con
-- minFreq=10 y fftN=256 (los valores reales de ABotVis.hx/ABotSpeaker.hx)
-- minBin cae tan cerca de 0 que VARIAS bandas bajas consecutivas colapsan
-- al mismo rango de bins vacío (más muertas que con la fórmula original).
-- La fórmula EXACTA tal cual existe (sin saber cómo la versión extendida
-- de 8 parámetros realmente compensa esto -- su fuente no está
-- disponible) da bandas vivas y bien diferenciadas en toda la mezcla.
-- xscale[bands] se deja en 0 sin llenar, A PROPÓSITO, igual que el real
-- (nunca se usa si el caller pide bands+1 y descarta el último, igual
-- que SpectralAnalyzer.hx hace).
local function computeLogXScale(bands, binCount)
	local xscale = {}
	xscale[bands] = 0.0
	for i = 0, bands - 1 do
		xscale[i] = binCount ^ (i / bands) - 0.5
	end
	return xscale
end

-- computeFreqBand() real -- EXACTO, verificado bit a bit contra
-- FFTVisualizationTest.hx (freqBandA/freqBandB del test real). freq:
-- array Lua 1-indexado (freq[1] == grig.audio freq[0], ver dsp_fft.lua).
-- binCount: largo real del array freq (fftN/2) -- el "256" hardcodeado
-- del original es justamente ESTO (freq.length para su N=512 fijo), NO
-- maxBin -- son cosas distintas (maxBin es el límite superior de
-- FRECUENCIA pedido, binCount es cuántos bins existen en total).
local function computeFreqBand(freq, xscale, band, bands, binCount)
	local a = math.ceil(xscale[band])
	local b = math.floor(xscale[band + 1])
	local n = 0.0

	if b < a then
		n = n + freq[b + 1] * (xscale[band + 1] - xscale[band])
	else
		if a > 0 then
			n = n + freq[(a - 1) + 1] * (a - xscale[band])
		end
		while a < b do
			n = n + freq[a + 1]
			a = a + 1
		end
		if b < binCount then
			n = n + freq[b + 1] * (xscale[band + 1] - b)
		end
	end

	-- "fudge factor" real: mantiene la altura del gráfico comparable sin
	-- importar cuántas bandas se pidan.
	n = n * (bands / 12)

	return 20 * math.log(n, 10)
end

-- makeLogGraph() real -- EXACTO (escala (-dbRange,0) a (0,intRange),
-- clamp final). binCount: largo real del array freq (fftN/2).
local function makeLogGraph(freq, bands, dbRange, intRange, binCount)
	local xscale = computeLogXScale(bands, binCount)

	local graph = {}
	for i = 0, bands - 1 do
		local val = computeFreqBand(freq, xscale, i, bands, binCount)
		val = (1 + val / dbRange) * intRange
		if val ~= val then val = 0 end -- NaN -> 0 (defensivo)
		graph[i] = math.max(0, math.min(intRange, math.floor(val)))
	end
	return graph
end

-- soundData: love.sound.SoundData decodificado del instrumental (un
-- Source en streaming no expone muestras crudas -- ver
-- sprites/weekend1/abot-speaker.lua:setAudioSource()).
-- minFreq/maxFreq: aceptados por compatibilidad con la firma real
-- (SpectralAnalyzer.hx los expone como campos de la clase) pero SIN
-- efecto en el binning -- ver el comentario de computeLogXScale() sobre
-- por qué la versión "consciente de Hz" se descartó.
function M.new(soundData, barCount, smoothingTimeConstant, fftN, minFreq, maxFreq, minDb, maxDb)
	barCount = barCount or 7
	smoothingTimeConstant = smoothingTimeConstant or 0.1
	fftN = dspFft.new(fftN or 256).n
	minDb = minDb or -70
	maxDb = maxDb or -20

	local sampleRate = soundData:getSampleRate()
	local channels = soundData:getChannelCount()
	local sampleCount = soundData:getSampleCount()
	local fftN2 = math.floor(fftN / 2)

	local fft = dspFft.new(fftN)
	local dbRange = math.floor(maxDb - minDb)
	local range = 256

	local self = { levels = {} }
	for i = 1, barCount do self.levels[i] = 0 end

	-- Buffer de muestras reusado entre llamadas (evita asignar memoria
	-- cada frame, mismo espíritu que el `_buffer` reusado de getSignal()
	-- real).
	local samples = {}
	for i = 1, fftN do samples[i] = 0 end

	-- centerTime: posición de reproducción actual en SEGUNDOS del Source
	-- REAL que está sonando (mismo reloj, ver abot-speaker.lua). El real
	-- (LimeAudioClip.hx) remapea tiempo a un índice de buffer crudo en
	-- BYTES -- detalle de bajo nivel de Lime/OpenFL imposible de
	-- replicar con la API de SoundData de LÖVE2D (que ya da muestras
	-- normalizadas -1..1 sin lidiar con bytes/bitsPerSample) -- acá se va
	-- directo a índice de MUESTRA vía sampleRate, conceptualmente
	-- equivalente (el real también remapea tiempo->posición en el
	-- buffer, solo que en unidades de bytes en vez de muestras).
	function self:analyze(centerTime)
		local startSample = math.floor((centerTime or 0) * sampleRate)
		if startSample < 0 or startSample >= sampleCount then
			for i = 1, barCount do self.levels[i] = self.levels[i] * (1 - smoothingTimeConstant) end
			return self.levels
		end

		for i = 1, fftN do
			local s = startSample + i - 1
			local sample = 0
			if s < sampleCount then
				if channels == 2 then
					sample = (soundData:getSample(s * 2) + soundData:getSample(s * 2 + 1)) * 0.5
				else
					sample = soundData:getSample(s)
				end
			end
			samples[i] = sample
		end

		local freq = fft:calcFreq(samples)
		-- barCount+1 bands, se descarta el último -- ver comentario al
		-- principio del archivo (xscale[bands] roto a propósito en el
		-- real).
		local bars = makeLogGraph(freq, barCount + 1, dbRange, range, fftN2)

		for b = 1, barCount do
			local value = bars[b - 1] / range

			-- Suavizado exponencial EXACTO del camino desktop real
			-- (SpectralAnalyzer.hx:239-251, "Web Audio API exponential
			-- smoothing" -- comentario del propio código fuente).
			local lastValue = self.levels[b]
			value = smoothingTimeConstant * lastValue + (1 - smoothingTimeConstant) * math.abs(value)
			self.levels[b] = value
		end

		return self.levels
	end

	-- Usado por abot-speaker.lua cuando el Source real NO está sonando
	-- (cinemática de Darnell antes del countdown, countdown mismo --
	-- inst todavía no arrancó) -- sin esto, analyze() seguiría leyendo
	-- SIEMPRE la misma ventana fija (la del instante en que inst quedó
	-- pausado/sin avanzar), mostrando un patrón no-cero pero CONGELADO,
	-- en vez de las barras quietas que correspondería mostrar sin sonido
	-- real. Mismo decaimiento exponencial que el branch "fuera de rango"
	-- de arriba, expuesto acá para no duplicar la fórmula.
	function self:decay()
		for i = 1, barCount do self.levels[i] = self.levels[i] * (1 - smoothingTimeConstant) end
		return self.levels
	end

	return self
end

return M
