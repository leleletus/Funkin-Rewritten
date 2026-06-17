--[[----------------------------------------------------------------------------
... (licencia)
------------------------------------------------------------------------------]]

local song, difficulty
local stageBack
local hitmarkerLoader, hitSound

return {
	enter = function(self, from, songNum, songAppend, isStoryMode, songName)
		weeks.enter(self, songNum, songAppend, isStoryMode, songName)
		self:loadStage(songNum, songAppend)
		self:load()
	end,

	loadStage = function(self, songNum, songAppend)
		song = songNum
		difficulty = songAppend

		_G.blockGameOver = false
		self.deathCutsceneStarted = false

		_G.customOnPlayerDeath = function()
			if self.deathCutsceneStarted then return end
			self.deathCutsceneStarted = true
			_G.blockGameOver = true
			_G.customOnPlayerDeath = nil

			if inst then inst:stop() end
			if voices then voices:stop() end

			if love.filesystem.getInfo("videos/BfFuckingDies.ogv") then
				self.deathVideo = love.graphics.newVideo("videos/BfFuckingDies.ogv")
				self.deathVideo:play()
				self.deathVideoStartTime = love.timer.getTime()
				self.deathVideoDuration = (self.deathVideo.getDuration and self.deathVideo:getDuration()) or 5
				self.deathVideoPlaying = true
			else
				Timer.after(5, function()
					_G.blockGameOver = false
					love.event.quit()
				end)
			end
		end

		stageBack = graphics.newImage(love.graphics.newImage(graphics.imagePath("sanicbg")))

		enemy = love.filesystem.load("sprites/sanic.lua")()
		enemy.sizeX, enemy.sizeY = 0.25, 0.25

		enemy.x, enemy.y = -300, 20
		boyfriend.x, boyfriend.y = 260, 100

		enemyIcon:animate("sanic", false)

		hitmarkerLoader = love.filesystem.load("sprites/hitmarker.lua")
		hitSound = love.audio.newSource("sounds/hitsound.ogg", "static")

		-- ==========================================================
		-- 1. SHADER ALUCINÓGENO ORIGINAL (Para el escenario)
		-- ==========================================================
		self.trippyShader = love.graphics.newShader[[
			extern number time;

			vec3 rgb2hsv(vec3 c) {
				vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
				vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
				float d = q.x - min(q.w, q.y);
				float e = 1.0e-10;
				return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			vec3 hsv2rgb(vec3 c) {
				vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
				vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
				return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
			}

			vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords ) {
				vec4 texcolor = Texel(tex, texture_coords);
				if (texcolor.a == 0.0) return texcolor * color;
				vec3 hsv = rgb2hsv(texcolor.rgb);
				hsv.x = fract(hsv.x + time * 0.5);
				texcolor.rgb = hsv2rgb(hsv);
				return texcolor * color;
			}
		]]
		self.shaderTime = 0

		-- ==========================================================
		-- 2. SHADER CHROMA KEY NORMAL (Para cuando no hay viaje)
		-- ==========================================================
		self.chromaShader = love.graphics.newShader[[
			extern vec3 chromaKey;
			extern float tolerance;
			extern float smoothing;

			vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
				vec4 texcolor = Texel(tex, texture_coords);
				float diff = length(texcolor.rgb - chromaKey);
				float calculatedAlpha = smoothstep(tolerance, tolerance + smoothing, diff);
				
				texcolor.rgb = texcolor.rgb * calculatedAlpha;
				texcolor.a = calculatedAlpha;
				
				return texcolor * color;
			}
		]]
		self.chromaShader:send("chromaKey", {0.0, 1.0, 0.0}) 
		self.chromaShader:send("tolerance", 0.4) 
		self.chromaShader:send("smoothing", 0.1)

		-- ==========================================================
		-- 3. SÚPER SHADER: CHROMA KEY + ALUCINÓGENO (Para los memes)
		-- ==========================================================
		self.trippyChromaShader = love.graphics.newShader[[
			extern vec3 chromaKey;
			extern float tolerance;
			extern float smoothing;
			extern number time;

			vec3 rgb2hsv(vec3 c) {
				vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
				vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
				float d = q.x - min(q.w, q.y);
				float e = 1.0e-10;
				return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
			vec3 hsv2rgb(vec3 c) {
				vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
				vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
				return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
			}

			vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
				vec4 texcolor = Texel(tex, texture_coords);
				
				// 1. Quitar el fondo verde
				float diff = length(texcolor.rgb - chromaKey);
				float calculatedAlpha = smoothstep(tolerance, tolerance + smoothing, diff);
				
				// 2. Efecto Alucinógeno (Solo si el píxel NO es transparente)
				if (calculatedAlpha > 0.0) {
					vec3 hsv = rgb2hsv(texcolor.rgb);
					hsv.x = fract(hsv.x + time * 0.5);
					texcolor.rgb = hsv2rgb(hsv);
				}
				
				// 3. Alpha Premultiplicado para evitar el cuadro blanco
				texcolor.rgb = texcolor.rgb * calculatedAlpha;
				texcolor.a = calculatedAlpha;
				
				return texcolor * color;
			}
		]]
		self.trippyChromaShader:send("chromaKey", {0.0, 1.0, 0.0}) 
		self.trippyChromaShader:send("tolerance", 0.4) 
		self.trippyChromaShader:send("smoothing", 0.1)
	end,

	load = function(self)
		weeks:load()

		inst = love.audio.newSource("music/sanic/too-fest-inst.ogg", "stream")
		voices = love.audio.newSource("music/sanic/too-fest-voices.ogg", "stream")

		-- Cargar Sonidos de los Hitmarkers
		if love.filesystem.getInfo("sounds/hitmarkers.ogg") then
			self.hitSound = love.audio.newSource("sounds/hitmarkers.ogg", "static")
		end
		self.hitmarkerTimes = { 79750, 97320 }
		self.currentHitIndex = 1

		-- Cargar Video y crear Lienzo (Canvas)
		if love.filesystem.getInfo("videos/toofest.ogv") then
			self.popoMasterVideo = love.graphics.newVideo("videos/toofest.ogv")
			self.videoStarted = false
			
			local vw, vh = love.graphics.getDimensions()
			self.videoCanvas = love.graphics.newCanvas(vw, vh)
		end

		self:initUI()
		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()
		weeks:loadChart("charts/sanic/too-fest-hard")
	end,

	update = function(self, dt)
		if self.deathVideoPlaying then
			if love.timer.getTime() - self.deathVideoStartTime >= self.deathVideoDuration then
				self.deathVideoPlaying = false
				_G.blockGameOver = false
				if self.deathVideo then
					if self.deathVideo.stop then self.deathVideo:stop()
					elseif self.deathVideo.pause then self.deathVideo:pause() end
					self.deathVideo = nil
				end
				love.event.quit()
			end
			return
		end

		weeks:update(dt)

		local musicTime = weeks.getMusicTime and weeks.getMusicTime() or 0
		self.currentMusicTime = musicTime 

		-- REPRODUCIR LOS SONIDOS DE HITMARKERS
		if self.currentHitIndex <= #self.hitmarkerTimes then
			if self.currentMusicTime >= self.hitmarkerTimes[self.currentHitIndex] then
				if self.hitSound then
					self.hitSound:stop()
					self.hitSound:play()
				end
				self.currentHitIndex = self.currentHitIndex + 1
			end
		end

		-- ACTUALIZAR LOS TIEMPOS DE LOS SHADERS
		self.shaderTime = self.shaderTime + dt
		if self.trippyShader then
			self.trippyShader:send("time", self.shaderTime)
		end
		if self.trippyChromaShader then
			self.trippyChromaShader:send("time", self.shaderTime)
		end

		-- SINCRONIZAR EL VIDEO CON LA MÚSICA
		if inst and inst:isPlaying() then
			if self.popoMasterVideo and not self.videoStarted then
				self.popoMasterVideo:play()
				self.videoStarted = true
			end
		end

		if not (countingDown or graphics.isFading()) and weeks.songEnded then
			if _G.storyMode and song < 3 then
				song = song + 1
				_G.currentSongIndex = song
				_G.currentSongName = _G.weekSongs[song]
				self:load()
			end
		end

		-- DETECTAR ENTRADA/SALIDA DE LA FASE TRIPPY PARA EL SPLASH
		local wasTrippyLast = self.trippyPhaseActive
		self.trippyPhaseActive = self.currentMusicTime and
			(self.currentMusicTime >= 75916.6666666667 and self.currentMusicTime <= 99314)

		if self.trippyPhaseActive and not wasTrippyLast then
			weeks:setSplash(hitmarkerLoader, hitSound, true, "hit")
		elseif not self.trippyPhaseActive and wasTrippyLast then
			weeks:resetSplash()
		end

		weeks:updateUI(dt)
	end,

	draw = function(self)
		if self.deathCutsceneStarted and self.deathVideo then
			love.graphics.push()
			love.graphics.origin()
			local vw, vh = love.graphics.getDimensions()
			local sw, sh = (self.deathVideo.getWidth and self.deathVideo:getWidth()) or 640, (self.deathVideo.getHeight and self.deathVideo:getHeight()) or 480
			if sw == 0 or sh == 0 then sw, sh = 640, 480 end
			local sx, sy = vw / sw, vh / sh
			love.graphics.draw(self.deathVideo, 0, 0, 0, sx, sy)
			love.graphics.pop()
			return
		end

		local applyTrippyShader = self.currentMusicTime and (self.currentMusicTime >= 75916.6666666667 and self.currentMusicTime <= 99314)
		
		if applyTrippyShader then
			love.graphics.setShader(self.trippyShader)
		end

		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(cam.sizeX, cam.sizeY)

			love.graphics.push()
				love.graphics.translate(cam.x, cam.y)
				stageBack:draw()
				enemy:draw()
				boyfriend:draw()
			love.graphics.pop()

			weeks:drawRating(0.9)
		love.graphics.pop()

		weeks:drawUI()

		-- DIBUJAR EL VIDEO USANDO EL TRUCO DEL CANVAS Y LOS SHADERS
		if self.popoMasterVideo and self.videoStarted then
			local vw, vh = love.graphics.getDimensions()
			local sw, sh = self.popoMasterVideo:getDimensions()
			
			if sw > 0 and sh > 0 then
				-- Por seguridad, si cambiaste el tamaño de la ventana, ajustamos el lienzo
				if not self.videoCanvas or self.videoCanvas:getWidth() ~= vw or self.videoCanvas:getHeight() ~= vh then
					if self.videoCanvas then self.videoCanvas:release() end
					self.videoCanvas = love.graphics.newCanvas(vw, vh)
				end

				love.graphics.push("all")
				love.graphics.origin()
				
				-- PASO 1: Dibujar el video normal en el lienzo invisible
				love.graphics.setCanvas(self.videoCanvas)
				love.graphics.clear(0, 0, 0, 0)
				love.graphics.setColor(1, 1, 1, 1)
				
				-- ¡CRUCIAL! Apagamos el shader de fondo temporalmente 
				love.graphics.setShader() 
				
				love.graphics.draw(self.popoMasterVideo, 0, 0, 0, vw/sw, vh/sh)
				
				-- PASO 2: Regresar a la pantalla normal y usar el Súper Shader en el Lienzo
				love.graphics.setCanvas() 
				love.graphics.origin()
				
				-- Usamos el súper shader si estamos en la fase alucinógena, o el chroma normal si no
				if applyTrippyShader then
					love.graphics.setShader(self.trippyChromaShader)
				else
					love.graphics.setShader(self.chromaShader)
				end
				
				love.graphics.draw(self.videoCanvas, 0, 0)
				love.graphics.setShader()
				
				love.graphics.pop() -- Restaura los gráficos al estado original
			end
		end

		if applyTrippyShader then
			love.graphics.setShader()
		end
	end,

	leave = function(self)
		if self.deathVideo then
			if self.deathVideo.stop then self.deathVideo:stop()
			elseif self.deathVideo.pause then self.deathVideo:pause() end
			self.deathVideo = nil
		end
		self.deathVideoPlaying = false

		if self.popoMasterVideo then
			if self.popoMasterVideo.stop then self.popoMasterVideo:stop()
			elseif self.popoMasterVideo.pause then self.popoMasterVideo:pause() end
			self.popoMasterVideo = nil
		end
		self.videoStarted = false
		
		-- LIMPIAR EL CANVAS DE LA MEMORIA DE LA SWITCH
		if self.videoCanvas then
			self.videoCanvas:release()
			self.videoCanvas = nil
		end

		if self.hitSound then
			self.hitSound:stop()
		end

		_G.customOnPlayerDeath = nil
		_G.blockGameOver = false
		self.deathCutsceneStarted = false

		weeks:leave()
	end
}