local screenStatic = require("sprites.screenstatic")

-- OPT: staticSound cargado en enter(), no al cargar el módulo
local staticSound = nil

local song, difficulty
local stageData
local bloodSplashLoader
local stageLayers = {}
local backgroundSprites = {}

-- Variables para el modchart
local defaultStrumX = {}
local defaultStrumY = {}
local currentStep = 0

local function setActorX(value, index)
    if index >= 0 and index <= 3 then
        enemyArrows[index+1].x = value
    elseif index >= 4 and index <= 7 then
        boyfriendArrows[index-3].x = value
    end
end

local function setActorY(value, index)
    if index >= 0 and index <= 3 then
        enemyArrows[index+1].y = value
    elseif index >= 4 and index <= 7 then
        boyfriendArrows[index-3].y = value
    end
end

local function tweenCameraZoom(targetZoom, duration)
    local originalX = camScale.x
    local originalY = camScale.y
    Timer.tween(duration, camScale, {x = targetZoom, y = targetZoom}, "linear", function()
        Timer.tween(duration, camScale, {x = originalX, y = originalY}, "linear")
    end)
end

return {
    -- Métodos para el shake y flash
    startShake = function(self)
        if self.shakeActive then return end
        self.shakeActive = true
        self.shakeTimer = 0
        self.originalCamX = cam.x
        self.originalCamY = cam.y
    end,

    startFlash = function(self)
        self.flashAlpha = 1
        if self.flashTween then Timer.cancel(self.flashTween) end
        self.flashTween = Timer.tween(4, self, {flashAlpha = 0}, "linear")
    end,

    -- Intro personalizada
    startIntro = function(self)
        Timer.after(1, function()
            self.introPhase = 1
            local screenW = 1280
            local screenH = 720
            local text = self.introSprites.text
            local circle = self.introSprites.circle
            local textTargetX = screenW / 2
            local circleTargetX = screenW / 2
            Timer.tween(1, text, {x = textTargetX}, "out-quad")
            Timer.tween(1, circle, {x = circleTargetX}, "out-quad", function()
                self.introPhase = 2
                Timer.after(2, function()
                    self.introPhase = 3
                    Timer.tween(1.5, self.introSprites.black, {alpha = 0}, "linear")
                    Timer.tween(1.5, self.introSprites.text, {alpha = 0}, "linear")
                    Timer.tween(1.5, self.introSprites.circle, {alpha = 0}, "linear", function()
                        self.introPhase = 4
                        self.introSprites = nil
                    end)
                end)
            end)
        end)
    end,

    enter = function(self, from, songNum, songAppend, isStoryMode, songName)
        weeks:enter(songNum, songAppend, isStoryMode, songName)  -- CORREGIDO: usar :
        self:loadStage(songNum, songAppend)
        self:load()
    end,

    loadStage = function(self, songNum, songAppend)
        song = songNum
        difficulty = songAppend

        -- OPT: cargar el sonido aquí, no al nivel del módulo
        staticSound = love.audio.newSource("sounds/simplejumpsound.ogg", "static")

        bloodSplashLoader = love.filesystem.load("sprites/BloodSplash.lua")

        -- Carga del stage
        local chunk, err = love.filesystem.load("stages/phase1.lua")
        if not chunk then
            print("Error al cargar el stage phase1.lua:", err)
            stageLayers = {}
        else
            local ok, loaded = pcall(chunk)
            if ok and loaded then
                stageData = loaded
                stageLayers = {}

                for _, layerData in ipairs(stageData.layers) do
                    local layer = {
                        type = layerData.type,
                        path = layerData.path,
                        x = layerData.x,
                        y = layerData.y,
                        scrollX = layerData.scrollX or 1,
                        scrollY = layerData.scrollY or 1,
                        scaleX = layerData.scaleX or 1,
                        scaleY = layerData.scaleY or 1,
                        visible = layerData.visible,
                        obj = nil
                    }

                    if layer.type == "image" then
                        local imgPath = graphics.imagePath(layer.path)
                        if love.filesystem.getInfo(imgPath) then
                            layer.obj = graphics.newImage(love.graphics.newImage(imgPath))
                        end
                    elseif layer.type == "sprite" then
                        local spritePath = "sprites/" .. layer.path .. ".lua"
                        local ok2, spriteLoader = pcall(love.filesystem.load, spritePath)
                        if ok2 then
                            local ok3, spriteObj = pcall(spriteLoader)
                            if ok3 then
                                layer.obj = spriteObj

                                if layer.path == "Sonic_EXE_Assets" then
                                    enemy = layer.obj
                                    enemy.x, enemy.y = layer.x, layer.y
                                    enemy.sizeX, enemy.sizeY = layer.scaleX * (enemy.sizeX or 1), layer.scaleY * (enemy.sizeY or 1)
                                elseif layer.path == "boyfriend" then
                                    boyfriend = layer.obj
                                    boyfriend.x, boyfriend.y = layer.x, layer.y
                                    boyfriend.sizeX, boyfriend.sizeY = layer.scaleX * (boyfriend.sizeX or 1), layer.scaleY * (boyfriend.sizeY or 1)
                                elseif layer.path == "girlfriend" then
                                    girlfriend = layer.obj
                                    girlfriend.x, girlfriend.y = layer.x, layer.y
                                    girlfriend.sizeX, girlfriend.sizeY = layer.scaleX * (girlfriend.sizeX or 1), layer.scaleY * (girlfriend.sizeY or 1)
                                else
                                    if layer.obj.anims then
                                        local animName = layer.obj.anims["idle"] and "idle" or next(layer.obj.anims)
                                        if animName then
                                            layer.obj:animate(animName, true)
                                        end
                                    end
                                    table.insert(backgroundSprites, layer.obj)
                                end

                                layer.obj.sizeX = layer.scaleX * (layer.obj.sizeX or 1)
                                layer.obj.sizeY = layer.scaleY * (layer.obj.sizeY or 1)
                            end
                        end
                    end

                    table.insert(stageLayers, layer)

                    -- Apply custom scroll factors for specific layers
                    if layer.path == "PolishedP1/SKY" then
                        layer.scrollX = 0.8   -- fastest
                    elseif layer.path == "PolishedP1/HILLS" then
                        layer.scrollX = 0.9   -- a bit slower
                    elseif layer.path == "PolishedP1/FLOOR2" then
                        layer.scrollX = 1   -- slowest among these three
                    end
                end
            else
                print("Error al ejecutar el stage phase1.lua:", loaded)
            end
        end

        -- Fallback de personajes
        if not enemy then
            enemy = love.filesystem.load("sprites/Sonic_EXE_Assets.lua")()
            enemy.x, enemy.y = -320, 47.5
        end
        if not boyfriend then
            boyfriend = love.filesystem.load("sprites/boyfriend.lua")()
            boyfriend.x, boyfriend.y = 322.5, 180
        end
        if not girlfriend then
            girlfriend = love.filesystem.load("sprites/girlfriend.lua")()
            girlfriend.x, girlfriend.y = 15, -47.5
        end

        -- Estática aleatoria
        self.staticTimer = nil
        self.staticStarted = false
        self.songEnded = false

        self.staticSprite = screenStatic()
        self.staticSprite.alpha = 0
        self.staticSprite.x = 1280 / 2
        self.staticSprite.y = 720 / 2
        self.staticSprite.sizeX = 1
        self.staticSprite.sizeY = 1

        -- Shake y flash
        self.shakeActive = false
        self.shakeTimer = 0
        self.shakeDuration = 0.3
        self.shakeIntensity = 10
        self.originalCamX = 0
        self.originalCamY = 0
        self.flashAlpha = 0
        self.flashTween = nil

        enemyIcon:animate("sonic", false)
        camScale.x, camScale.y = 0.9, 0.9

        -- Configuración de la intro
        self.introPhase = 0
        self.introSprites = {}
        local screenW = 1280
        local screenH = 720

        local blackImg = love.graphics.newImage(graphics.imagePath("StartScreens/BLACK"))
        self.introSprites.black = {
            image = blackImg,
            x = screenW / 2,
            y = screenH / 2,
            alpha = 1,
            scaleX = screenW / blackImg:getWidth(),
            scaleY = screenH / blackImg:getHeight()
        }

        local scale = math.min(screenW / 1280, screenH / 720)  -- factor de escala uniforme

        local textImg = love.graphics.newImage(graphics.imagePath("StartScreens/TextTooSlow"))
        self.introSprites.text = {
            image = textImg,
            x = -textImg:getWidth() / 2,
            y = screenH / 2,
            alpha = 1,
            scaleX = scale,
            scaleY = scale
        }

        local circleImg = love.graphics.newImage(graphics.imagePath("StartScreens/CircleTooSlow"))
        self.introSprites.circle = {
            image = circleImg,
            x = screenW + circleImg:getWidth() / 2,
            y = screenH / 2,
            alpha = 1,
            scaleX = scale,
            scaleY = scale
        }
    end,

    load = function(self)
        weeks:load()  -- CORREGIDO

        self.staticStarted = false
        self.songEnded = false
        if self.staticTimer then
            Timer.cancel(self.staticTimer)
            self.staticTimer = nil
        end
        if self.staticSprite then
            self.staticSprite.alpha = 0
        end

        -- Música (cargamos, PERO no la iniciamos hasta terminar la cutscene)
        inst = love.audio.newSource("music/chillador/too-slow-inst.ogg", "stream")
        voices = love.audio.newSource("music/chillador/too-slow-voices.ogg", "stream")

        self:initUI()
        weeks:setSplash(bloodSplashLoader, nil, true, "Squirt")

        if love.filesystem.getInfo("videos/tooslowcutscene1.ogv") then
            self.cutscene = love.graphics.newVideo("videos/tooslowcutscene1.ogv")
            self.cutscene:play()
            self.cutscenePlaying = true
            self.cutsceneStartTime = love.timer.getTime()
            self.cutsceneDuration = (self.cutscene.getDuration and self.cutscene:getDuration()) or 14
        else
            -- Iniciar música directamente
            if inst then inst:play() end
            if voices then voices:play() end
            self:startIntro()
            weeks.songLength = inst and (inst:getDuration() * 1000) or 0
            countingDown = false
            musicTime = 0
            musicPos = 0
            previousFrameTime = love.timer.getTime() * 1000
        end

        -- Ocultar el countdown
        if countdown then
            countdown.alpha = 0
        end

        -- Posiciones originales de flechas
        for i = 0, 3 do
            defaultStrumX[i] = -925 + 165 * (i+1)
            if settings.downscroll then
                defaultStrumY[i] = 400
            else
                defaultStrumY[i] = -400
            end
        end
        for i = 4, 7 do
            defaultStrumX[i] = 100 + 165 * (i-3)
            if settings.downscroll then
                defaultStrumY[i] = 400
            else
                defaultStrumY[i] = -400
            end
        end
        defaultStrumX[8] = defaultStrumX[7]
        defaultStrumY[8] = defaultStrumY[7]

        self.zoomDone1 = false
        self.zoomDone2 = false
        self.shakeFlashDone = false
    end,

    initUI = function(self)
        weeks:initUI()
        weeks:generateNotes(love.filesystem.load("charts/chillador/too-slow-hard.lua")())
    end,

    scheduleNextStatic = function(self)
        local delay = love.math.random(2, 15)
        self.staticTimer = Timer.after(delay, function()
            if not self.songEnded then
                self:triggerStatic()
                self:scheduleNextStatic()
            end
        end)
    end,

    triggerStatic = function(self)
        local static = self.staticSprite
        if not static then return end

        static.alpha = 0.4
        static:animate("screenSTATIC", true)
        staticSound:play()

        Timer.after(0.25, function()
            if static then
                static.alpha = 0
            end
        end)
    end,

    update = function(self, dt)
        if self.cutscenePlaying then
            -- Permitir saltar con Confirm (Enter / Start)
            if not graphics.isFading() then
                if input:pressed("confirm") then
                    -- Saltar cutscene e iniciar intro/música
                    self.cutscenePlaying = false
                    if self.cutscene then
                        if self.cutscene.stop then
                            self.cutscene:stop()
                        elseif self.cutscene.pause then
                            self.cutscene:pause()
                        end
                        self.cutscene = nil
                    end
                    -- Misma lógica que al terminar la cutscene normalmente
                    self:startIntro()
                    if inst then inst:play() end
                    if voices then voices:play() end
                    weeks.songLength = inst and (inst:getDuration() * 1000) or 0
                    countingDown = false
                    musicTime = 0
                    musicPos = 0
                    previousFrameTime = love.timer.getTime() * 1000
                    return
                elseif input:pressed("gameBack") then
                    -- Salir al menú principal
                    self.cutscenePlaying = false
                    if self.cutscene then
                        if self.cutscene.stop then
                            self.cutscene:stop()
                        elseif self.cutscene.pause then
                            self.cutscene:pause()
                        end
                        self.cutscene = nil
                    end
                    if inst then inst:stop() end
                    if voices then voices:stop() end
                    status.setLoading(true)
                    graphics.fadeOut(0.5, function()
                        Gamestate.switch(menu)
                        status.setLoading(false)
                    end)
                    return
                end
            end

            -- Comprobación normal de duración (si no se ha saltado)
            if love.timer.getTime() - self.cutsceneStartTime >= self.cutsceneDuration then
                self.cutscenePlaying = false
                if self.cutscene then
                    if self.cutscene.stop then
                        self.cutscene:stop()
                    elseif self.cutscene.pause then
                        self.cutscene:pause()
                    end
                    self.cutscene = nil
                end
                self:startIntro()
                if inst then inst:play() end
                if voices then voices:play() end
                weeks.songLength = inst and (inst:getDuration() * 1000) or 0
                countingDown = false
                musicTime = 0
                musicPos = 0
                previousFrameTime = love.timer.getTime() * 1000
            end
            return
        end

        previousFrameTime = previousFrameTime or (love.timer.getTime() * 1000)

        weeks:update(dt)
        weeks:updateUI(dt)

        if not countingDown and not self.staticStarted and not self.songEnded then
            self.staticStarted = true
            self:scheduleNextStatic()
        end

        if self.songEnded and self.staticTimer then
            Timer.cancel(self.staticTimer)
            self.staticTimer = nil
        end

        for _, sprite in ipairs(backgroundSprites) do
            sprite:update(dt)
        end
        if self.staticSprite then
            self.staticSprite:update(dt)
        end

        -- Fin de canción
        if not (countingDown or graphics.isFading()) and weeks.songEnded then
            self.songEnded = true
            if self.staticTimer then
                Timer.cancel(self.staticTimer)
                self.staticTimer = nil
            end

            if _G.storyMode and song < 3 and _G.weekSongs then
                song = song + 1
                _G.currentSongIndex = song
                _G.currentSongName = _G.weekSongs[song]
                self:load()
            end
            -- Si no hay más canciones o es freeplay, weeks.handleSongEnd() ya se encargó
        end

        -- OPT: calcular step y beat una sola vez
        local currentBeat = 0
        if bpm and bpm > 0 then
            local stepTime = 15000 / bpm
            currentStep = math.floor((musicTime or 0) / stepTime)
            currentBeat = (musicTime / 1000) * (bpm / 84)
        else
            currentStep = 0
        end

        -- Modchart: determinar si algún efecto de posición está activo en este step
        local modchartYActive = (currentStep >= 789  and currentStep < 923)
                             or (currentStep >= 924  and currentStep < 1048)
        local modchartXActive = (currentStep >= 1049 and currentStep < 1176)
                             or (currentStep >= 1177 and currentStep < 1959)

        if modchartYActive or modchartXActive then
            -- Resetear a posición base solo cuando el modchart está activo
            for i = 0, 3 do
                enemyArrows[i+1].x = defaultStrumX[i]
                enemyArrows[i+1].y = defaultStrumY[i]
            end
            for i = 4, 7 do
                boyfriendArrows[i-3].x = defaultStrumX[i]
                boyfriendArrows[i-3].y = defaultStrumY[i]
            end

            -- OPT: precalcular la parte del seno compartida (varía solo por i)
            if currentStep >= 789 and currentStep < 923 then
                for i = 0, 8 do
                    setActorY(defaultStrumY[i] + 5 * math.sin((currentBeat + i * 0.25) * math.pi), i)
                end
            elseif currentStep >= 924 and currentStep < 1048 then
                for i = 0, 8 do
                    setActorY(defaultStrumY[i] - 5 * math.sin((currentBeat + i * 0.25) * math.pi), i)
                end
            end

            if currentStep >= 1049 and currentStep < 1176 then
                for i = 0, 8 do
                    setActorX(defaultStrumX[i] + 2 * math.sin((currentBeat + i * 0.25) * math.pi), i)
                end
            elseif currentStep >= 1177 and currentStep < 1959 then
                for i = 0, 8 do
                    setActorX(defaultStrumX[i] - 6 * math.sin((currentBeat + i * 0.25) * math.pi), i)
                end
            end
        end

        -- Zoom en steps originales
        if not self.zoomDone1 and currentStep >= 760 and currentStep < 786 then
            tweenCameraZoom(1.3, 1.5)
            self.zoomDone1 = true
        end

        -- Shake y flash en tiempo exacto
        if not self.shakeFlashDone and musicTime >= 84538 then
            self:startShake()
            self:startFlash()
            self.shakeFlashDone = true
        end

        -- El segundo zoom (si quieres mantenerlo igual)
        if not self.zoomDone2 and currentStep >= 1392 and currentStep < 1428 then
            tweenCameraZoom(1.2, 1.5)
            self.zoomDone2 = true
        end

        if self.shakeActive then
            self.shakeTimer = self.shakeTimer + dt
            if self.shakeTimer < self.shakeDuration then
                local offsetX = love.math.random(-self.shakeIntensity, self.shakeIntensity)
                local offsetY = love.math.random(-self.shakeIntensity, self.shakeIntensity)
                cam.x = self.originalCamX + offsetX
                cam.y = self.originalCamY + offsetY
            else
                cam.x = self.originalCamX
                cam.y = self.originalCamY
                self.shakeActive = false
            end
        end
    end,

    draw = function(self)
        -- CUTSCENE: si está reproduciéndose, dibujarla y no renderizar el juego
        if self.cutscenePlaying and self.cutscene then
            love.graphics.push()
            love.graphics.origin()

            local vw, vh = love.graphics.getDimensions()
            local sw = self.cutscene:getWidth()
            local sh = self.cutscene:getHeight()

            local sx = vw / sw
            local sy = vh / sh

            love.graphics.draw(self.cutscene, 0, 0, 0, sx, sy)

            love.graphics.pop()
            return
        end
        love.graphics.push()
            love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
            love.graphics.scale(cam.sizeX, cam.sizeY)

            for _, layer in ipairs(stageLayers) do
                if layer.visible and layer.obj then
                    love.graphics.push()
                        love.graphics.translate(cam.x * layer.scrollX, cam.y * layer.scrollY)
                        layer.obj.x = layer.x
                        layer.obj.y = layer.y
                        layer.obj:draw()
                    love.graphics.pop()
                end
            end

            weeks:drawRating(0.9)   -- CORREGIDO
        love.graphics.pop()

        weeks:drawUI()   -- CORREGIDO

        -- Estática
        if self.staticSprite and self.staticSprite.alpha > 0 then
            love.graphics.push()
            love.graphics.setColor(1, 1, 1, self.staticSprite.alpha)
            self.staticSprite:draw()
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.pop()
        end

        -- Flash rojo
        if self.flashAlpha and self.flashAlpha > 0 then
            love.graphics.push()
            love.graphics.setColor(1, 0, 0, self.flashAlpha)
            love.graphics.rectangle("fill", 0, 0, 1280, 720)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.pop()
        end

        -- Intro (negro, círculo, texto)
        if self.introSprites then
            love.graphics.push()
            if self.introSprites.black and self.introSprites.black.alpha > 0 then
                love.graphics.setColor(1, 1, 1, self.introSprites.black.alpha)
                love.graphics.draw(
                    self.introSprites.black.image,
                    self.introSprites.black.x, self.introSprites.black.y,
                    0,
                    self.introSprites.black.scaleX, self.introSprites.black.scaleY,
                    self.introSprites.black.image:getWidth() / 2, self.introSprites.black.image:getHeight() / 2
                )
            end
            if self.introSprites.circle and self.introSprites.circle.alpha > 0 then
                love.graphics.setColor(1, 1, 1, self.introSprites.circle.alpha)
                love.graphics.draw(
                    self.introSprites.circle.image,
                    self.introSprites.circle.x, self.introSprites.circle.y,
                    0,
                    self.introSprites.circle.scaleX, self.introSprites.circle.scaleY,
                    self.introSprites.circle.image:getWidth() / 2, self.introSprites.circle.image:getHeight() / 2
                )
            end
            if self.introSprites.text and self.introSprites.text.alpha > 0 then
                love.graphics.setColor(1, 1, 1, self.introSprites.text.alpha)
                love.graphics.draw(
                    self.introSprites.text.image,
                    self.introSprites.text.x, self.introSprites.text.y,
                    0,
                    self.introSprites.text.scaleX, self.introSprites.text.scaleY,
                    self.introSprites.text.image:getWidth() / 2, self.introSprites.text.image:getHeight() / 2
                )
            end
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.pop()
        end
    end,

    leave = function(self)
        if self.staticTimer then
            Timer.cancel(self.staticTimer)
            self.staticTimer = nil
        end
        if self.flashTween then
            Timer.cancel(self.flashTween)
            self.flashTween = nil
        end
        if self.cutscene then
            if self.cutscene.stop then
                self.cutscene:stop()
            elseif self.cutscene.pause then
                self.cutscene:pause()
            end
            self.cutscene = nil
        end
        self.cutscenePlaying = false
        self.staticSprite = nil
        self.zoomDone1 = nil
        self.zoomDone2 = nil
        self.shakeFlashDone = nil
        self.shakeActive = nil
        self.flashAlpha = nil
        self.introSprites = nil

        backgroundSprites = {}
        stageLayers = {}
        stageData = nil

        -- OPT: liberar el sonido de estática explícitamente
        if staticSound then
            staticSound:stop()
            if staticSound.release then staticSound:release() end
            staticSound = nil
        end

        weeks:leave()   -- CORREGIDO
        collectgarbage("collect")
        collectgarbage("collect")
    end
}