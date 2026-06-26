-- Puerto 1:1 de grig.audio.FFT (grig.audio-funkin/src/grig/audio/FFT.hx,
-- a su vez puerto a Haxe por Thomas J. Webb del fft.c original de John
-- Lindgren, 2011) -- la librería REAL que funkin.vis.dsp.SpectralAnalyzer
-- usa en su camino desktop para el "viz" del A-Bot (código fuente
-- conseguido por el usuario).
--
-- Verificado bit-exacto contra tests/FFTVisualizationTest.hx del propio
-- repo (señal triangular conocida, N=512 -> computeFreqBand da los
-- mismos valores esperados por el test real, ver
-- modules/spectral_analyzer.lua para el resto del pipeline).
--
-- Sin operadores bitwise (<<, >>, &, |) -- LuaJIT/Lua 5.1 no los tiene de
-- forma nativa -- traducidos a aritmética simple (x*2, math.floor(x/2),
-- x%2), exactamente equivalentes.

local M = {}

local TWO_PI = 6.2831853 -- constante EXACTA de FFT.hx (no math.pi*2 -- el
                          -- original usa este valor truncado a propósito)

-- bitReverse(x) real: invierte el orden de los logN bits más bajos de x.
local function bitReverse(x, logN)
	local y = 0
	for _ = 1, logN do
		y = y * 2 + (x % 2)
		x = math.floor(x / 2)
	end
	return y
end

-- new FFT(n) real -- n debe ser potencia de 2. Las tablas internas
-- (hamming/reversed/roots) usan claves 0-indexadas (igual que el Haxe
-- original) para que la traducción de índices en doFFT()/calcFreq() sea
-- literal y auditable contra el código fuente real; data/freq (la
-- interfaz pública) son arrays Lua normales 1-indexados.
function M.new(n)
	n = n or 512
	local logN = math.floor(math.log(n) / math.log(2) + 0.5)

	local hamming, reversed, rootsRe, rootsIm = {}, {}, {}, {}
	for i = 0, n - 1 do
		-- Ventana de Hamming MODIFICADA real (NO la estándar 0.54/0.46 --
		-- FFT.hx usa 1 - 0.85*cos, así literal).
		hamming[i] = 1 - 0.85 * math.cos(i * (TWO_PI / n))
		reversed[i] = bitReverse(i, logN)
	end
	for i = 0, math.floor(n / 2) - 1 do
		local theta = i * (TWO_PI / n)
		rootsRe[i] = math.cos(theta)
		rootsIm[i] = math.sin(theta)
	end

	local self = { n = n }

	-- doFFT(a) real: Cooley-Tukey radix-2, decimación en tiempo,
	-- iterativo, sobre arrays YA puestos en orden bit-reversed (lo hace
	-- calcFreq() antes de llamar esto, igual que el original).
	local function doFFT(aRe, aIm)
		local half = 1
		local inv = math.floor(n / 2)
		while inv > 0 do
			local g = 0
			while g < n do
				local b, r = 0, 0
				while b < half do
					local evenRe, evenIm = aRe[g + b], aIm[g + b]
					local oRe, oIm = aRe[g + half + b], aIm[g + half + b]
					local rootRe, rootIm = rootsRe[r], rootsIm[r]
					-- odd = roots[r] * a[g+half+b] (multiplicación compleja)
					local oddRe = rootRe * oRe - rootIm * oIm
					local oddIm = rootRe * oIm + rootIm * oRe
					aRe[g + b] = evenRe + oddRe
					aIm[g + b] = evenIm + oddIm
					aRe[g + half + b] = evenRe - oddRe
					aIm[g + half + b] = evenIm - oddIm
					b = b + 1
					r = r + inv
				end
				g = g + half * 2
			end
			half = half * 2
			inv = math.floor(inv / 2)
		end
	end

	-- calcFreq(data) real -- data: array Lua 1-indexado de n muestras PCM
	-- (data[1]..data[n]). Devuelve un array Lua 1-indexado de n/2
	-- magnitudes (freq[1]..freq[n/2]).
	function self:calcFreq(data)
		local aRe, aIm = {}, {}
		for i = 0, n - 1 do
			-- Ventaneado de Hamming + reordenado bit-reversed (idéntico al
			-- real: "a[reversed[i]] = {real: data[i]*hamming[i], imag:0}").
			aRe[reversed[i]] = data[i + 1] * hamming[i]
			aIm[reversed[i]] = 0.0
		end

		doFFT(aRe, aIm)

		local half = math.floor(n / 2)
		local freq = {}
		-- "frecuencias de 1 a N/2-1 se duplican" (real, comentario propio
		-- del código fuente) -- bin 0 (DC) se descarta por completo.
		for i = 0, half - 1 do
			local re, im = aRe[1 + i], aIm[1 + i]
			freq[i + 1] = 2 * math.sqrt(re * re + im * im) / n
		end
		-- "frecuencia N/2 no se duplica" (Nyquist) -- sobreescribe el
		-- último slot, igual que el real.
		local re, im = aRe[half], aIm[half]
		freq[half] = math.sqrt(re * re + im * im) / n

		return freq
	end

	return self
end

return M
