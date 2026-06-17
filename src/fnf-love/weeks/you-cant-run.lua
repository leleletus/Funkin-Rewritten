--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten
Copyright (C) 2021  HTV04
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
------------------------------------------------------------------------------]]

local screenStatic = require("sprites.screenstatic")

-- OPT: staticSound cargado en enter(), no al cargar el módulo
local staticSound = nil

local song, difficulty
local stageData
local bloodSplashLoader
local stageLayers = {}
local backgroundSprites = {}

return {
    -- Métodos para efectos (aunque no se usan, se dejan por si acaso)
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

    -- Estática de transición (opaca, sin sonido)
    triggerTransitionStatic = function(self)
        if self.staticTimer then
            Timer.cancel(self.staticTimer)
            self.staticTimer = nil
        end
        if self.staticSprite then
            self.staticSprite.alpha = 1
            self.staticSprite:animate("screenSTATIC", true)
            -- Cancelar cualquier temporizador anterior de transición
            if self.transitionStaticTimer then
                Timer.cancel(self.transitionStaticTimer)
            end
            self.transitionStaticTimer = Timer.after(0.25, function()
                if self.staticSprite then
                    self.staticSprite.alpha = 0
                end
                self.transitionStaticTimer = nil
                -- Reanudar estática aleatoria si la canción no ha terminado
                if not self.songEnded then
                    self:scheduleNextStatic()
                end
            end)
        end
    end,

    -- Transformación a modo pixel
    transformToPixel = function(self)
        self:triggerTransitionStatic()

        -- Ocultar capas normales
        for _, layer in ipairs(stageLayers) do
            local path = layer.path
            if path == "P2/sky" or path == "P2/GrassBack" or path == "P2/trees" or path == "P2/Grass"
                or path == "P2/TreesFront" or path == "girlfriend" or path == "YCR" or path == "boyfriend" then
                layer.visible = false
            end
        end

        -- Mostrar capas pixeladas
        for _, layer in ipairs(stageLayers) do
            local path = layer.path
            if path == "P2/GreenHill" or path == "Pixel_gf" or path == "BF" or path == "Sonic_EXE_Pixel" then
                layer.visible = true
            end
        end

        -- Intercambiar personajes
        enemy = self.pixelEnemy
        boyfriend = self.pixelBoyfriend
        girlfriend = self.pixelGirlfriend

        -- Cambiar iconos a versión pixel
        enemyIcon:animate("crappyonic", false)
        boyfriendIcon:animate("crappyfriend", false)

        -- Zoom modo pixel
        camScale.x, camScale.y = 0.95, 0.95

        -- Asegurar animaciones iniciales
        if enemy and enemy.anims then
            enemy:animate("idle", true)
        end
        if boyfriend and boyfriend.anims then
            boyfriend:animate("idle", true)
        end
        if girlfriend and girlfriend.anims then
            girlfriend:animate("idle", true)
        end
        -- OPT: no llamar collectgarbage() en medio del gameplay (causa microstutter)
    end,

    -- Reversión a modo normal
    revertToNormal = function(self)
        self:triggerTransitionStatic()

        -- Ocultar capas pixeladas
        for _, layer in ipairs(stageLayers) do
            local path = layer.path
            if path == "P2/GreenHill" or path == "Pixel_gf" or path == "BF" or path == "Sonic_EXE_Pixel" then
                layer.visible = false
            end
        end

        -- Restaurar personajes originales (usando el YCR_Mad precargado)
        enemy = self.madEnemy
        boyfriend = self.originalBoyfriend
        girlfriend = self.originalGirlfriend

        -- Mostrar capas normales y asegurar que se dibuje el enemigo correcto
        for _, layer in ipairs(stageLayers) do
            local path = layer.path
            if path == "P2/sky" or path == "P2/GrassBack" or path == "P2/trees" or path == "P2/Grass"
                or path == "P2/TreesFront" or path == "girlfriend" or path == "YCR" or path == "boyfriend" then
                
                layer.visible = true
                
                -- ESTA ES LA CLAVE PARA QUE NO SE CONGELE:
                -- Actualizamos el objeto de la capa con el nuevo enemigo
                if path == "YCR" then
                    layer.obj = enemy
                end
            end
        end

        -- Restaurar iconos 
        enemyIcon:animate("sonic2poop", false) -- angry
        boyfriendIcon:animate("boyfriend", false)

        -- Zoom modo normal
        camScale.x, camScale.y = 0.75, 0.75

        -- Asegurar animaciones
        if enemy and enemy.anims then
            enemy:animate("idle", true)
        end
        if boyfriend and boyfriend.anims then
            boyfriend:animate("idle", true)
        end
        if girlfriend and girlfriend.anims then
            girlfriend:animate("idle", true)
        end
        -- OPT: no llamar collectgarbage() en medio del gameplay (causa microstutter)
    end,

    enter = function(self, from, songNum, songAppend, isStoryMode, songName)
        weeks:enter(songNum, songAppend, isStoryMode, songName)
        self:loadStage(songNum, songAppend)
        self:load()
    end,

    loadStage = function(self, songNum, songAppend)
        song = songNum
        difficulty = songAppend

        -- OPT: cargar el sonido aquí, no al nivel del módulo
        staticSound = love.audio.newSource("sounds/simplejumpsound.ogg", "static")

        bloodSplashLoader = love.filesystem.load("sprites/BloodSplash.lua")

        -- Carga del stage (phase2.lua)
        local chunk, err = love.filesystem.load("stages/phase2.lua")
        if not chunk then
            print("Error al cargar el stage phase2.lua:", err)
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
                            local img = love.graphics.newImage(imgPath)
                            -- Aplicar filtro nearest a la imagen pixelada
                            if layer.path == "P2/GreenHill" then
                                img:setFilter("nearest", "nearest")
                            end
                            layer.obj = graphics.newImage(img)
                            -- Aplicar escala definida en el stage
                            layer.obj.sizeX = layer.scaleX
                            layer.obj.sizeY = layer.scaleY
                        end
                    elseif layer.type == "sprite" then
                        local spritePath = "sprites/" .. layer.path .. ".lua"
                        local ok2, spriteLoader = pcall(love.filesystem.load, spritePath)
                        if ok2 then
                            local ok3, spriteObj = pcall(spriteLoader)
                            if ok3 then
                                layer.obj = spriteObj

                                -- Asignar personajes según el nombre del sprite
                                if layer.path == "YCR" then
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
                                    -- No añadir a backgroundSprites si es un personaje pixelado
                                    if layer.path ~= "Sonic_EXE_Pixel" and layer.path ~= "BF" and layer.path ~= "Pixel_gf" then
                                        if layer.obj.anims then
                                            local animName = layer.obj.anims["idle"] and "idle" or next(layer.obj.anims)
                                            if animName then
                                                layer.obj:animate(animName, true)
                                            end
                                        end
                                        table.insert(backgroundSprites, layer.obj)
                                    else
                                        -- Guardar referencias a sprites pixelados
                                        if layer.path == "Sonic_EXE_Pixel" then
                                            self.pixelEnemy = layer.obj
                                        elseif layer.path == "BF" then
                                            self.pixelBoyfriend = layer.obj
                                        elseif layer.path == "Pixel_gf" then
                                            self.pixelGirlfriend = layer.obj
                                        end
                                    end
                                end

                                layer.obj.sizeX = layer.scaleX * (layer.obj.sizeX or 1)
                                layer.obj.sizeY = layer.scaleY * (layer.obj.sizeY or 1)
                                layer.obj.x = layer.x
                                layer.obj.y = layer.y
                            end
                        end
                    end

                    table.insert(stageLayers, layer)
                end

                -- Después de cargar, establecer visibilidad inicial: ocultar capas pixeladas
                for _, layer in ipairs(stageLayers) do
                    local path = layer.path
                    if path == "P2/GreenHill" or path == "Pixel_gf" or path == "BF" or path == "Sonic_EXE_Pixel" then
                        layer.visible = false
                    else
                        layer.visible = true
                    end
                end

                -- Fallback de personajes (por si no se cargaron del stage)
                if not enemy then
                    enemy = love.filesystem.load("sprites/YCR.lua")()
                    enemy.x, enemy.y = -391.66666666666, -85
                end
                if not boyfriend then
                    boyfriend = love.filesystem.load("sprites/boyfriend.lua")()
                    boyfriend.x, boyfriend.y = 384.16666666667, 56.666666666667
                end
                if not girlfriend then
                    girlfriend = love.filesystem.load("sprites/girlfriend.lua")()
                    girlfriend.x, girlfriend.y = 9.1666666666667, -141.66666666667
                end

                -- Guardar referencias a personajes originales
                self.originalEnemy = enemy
                self.originalEnemyX = enemy.x
                self.originalEnemyY = enemy.y
                self.originalEnemySizeX = enemy.sizeX
                self.originalEnemySizeY = enemy.sizeY
                self.originalBoyfriend = boyfriend
                self.originalGirlfriend = girlfriend

                self.madEnemy = love.filesystem.load("sprites/YCR_Mad.lua")()
                self.madEnemy.x = self.originalEnemyX
                self.madEnemy.y = self.originalEnemyY
                self.madEnemy.sizeX = self.originalEnemySizeX
                self.madEnemy.sizeY = self.originalEnemySizeY

                -- Guardar referencia a fondo pixelado (imagen)
                for _, layer in ipairs(stageLayers) do
                    if layer.path == "P2/GreenHill" then
                        self.pixelBackground = layer.obj
                        break
                    end
                end
            else
                print("Error al ejecutar el stage phase2.lua:", loaded)
            end
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

        -- Shake y flash (no se activan, pero se dejan las variables)
        self.shakeActive = false
        self.shakeTimer = 0
        self.shakeDuration = 0.3
        self.shakeIntensity = 10
        self.originalCamX = 0
        self.originalCamY = 0
        self.flashAlpha = 0
        self.flashTween = nil

        -- Variables para control de fase
        self.transformed = false
        self.reverted = false

        -- Iconos iniciales (modo normal)
        enemyIcon:animate("sonic2", false)
        boyfriendIcon:animate("boyfriend", false)
        camScale.x, camScale.y = 0.75, 0.75

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

        local scale = math.min(screenW / 1280, screenH / 720)

        -- Texto y círculo personalizados
        local textImg = love.graphics.newImage(graphics.imagePath("StartScreens/TextYouCantRun"))
        self.introSprites.text = {
            image = textImg,
            x = -textImg:getWidth() / 2,
            y = screenH / 2,
            alpha = 1,
            scaleX = scale,
            scaleY = scale
        }

        local circleImg = love.graphics.newImage(graphics.imagePath("StartScreens/CircleYouCantRun"))
        self.introSprites.circle = {
            image = circleImg,
            x = screenW + circleImg:getWidth() / 2,
            y = screenH / 2,
            alpha = 1,
            scaleX = scale,
            scaleY = scale
        }

        --[[ REDVG: crear el sprite de viñeta roja --]]
        local vgImg = love.graphics.newImage(graphics.imagePath("RedVG"))
        self.vg = {
            image = vgImg,
            x = screenW / 2,
            y = screenH / 2,
            alpha = 1,
            visible = false,
            scaleX = screenW / vgImg:getWidth(),
            scaleY = screenH / vgImg:getHeight()
        }
        self.vgTween = nil
        self.lastStep = -1
    end,

    load = function(self)
        weeks:load()

        -- Resetear flags de transformación para que los eventos vuelvan a disparar
        self.transformed = false
        self.reverted = false

        self.staticStarted = false
        self.songEnded = false
        if self.staticTimer then
            Timer.cancel(self.staticTimer)
            self.staticTimer = nil
        end
        if self.staticSprite then
            self.staticSprite.alpha = 0
        end

        -- Música (cargamos, pero no la iniciamos hasta terminar la cutscene)
        inst = love.audio.newSource("music/you-cant-run/you-cant-run-inst.ogg", "stream")
        voices = love.audio.newSource("music/you-cant-run/you-cant-run-voices.ogg", "stream")

        self:initUI()
        weeks:setSplash(bloodSplashLoader, nil, true, "Squirt")

        if love.filesystem.getInfo("videos/ycrCutscene.ogv") then
            self.cutscene = love.graphics.newVideo("videos/ycrCutscene.ogv")
            self.cutscene:play()
            self.cutscenePlaying = true
            self.cutsceneStartTime = love.timer.getTime()
            self.cutsceneDuration = (self.cutscene.getDuration and self.cutscene:getDuration()) or 32 -- Ajusta si es necesario
        else
            -- Iniciar música directamente
            if inst then inst:play() end
            if voices then voices:play() end
            -- introSprites puede ser nil en un retry (se anula al terminar la animación)
            if self.introSprites then
                self:startIntro()
            end
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
    end,

    initUI = function(self)
        weeks:initUI()
        weeks:loadChart("charts/you-cant-run/you-cant-run-hard")
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

        static.alpha = 0.5
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
                    if self.introSprites then self:startIntro() end
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
                if self.introSprites then self:startIntro() end
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

        -- Comprobar transiciones de fase basadas en el tiempo de la canción
        if not countingDown and musicTime >= 0 and not graphics.isFading() then
            -- Antes de transformar a pixel, ocultar RedVG si está visible
            if not self.transformed and musicTime >= 56459 then
                if self.vg and self.vg.visible then
                    self.vg.visible = false
                    self:pauseRedVG()
                end
                -- Luego ejecutar la transformación
                self:transformToPixel()
                weeks:setPixelMode(true, "sonic")
                self.transformed = true
            end
            -- Después de revertir, volver a mostrar RedVG
            if self.transformed and not self.reverted and musicTime >= 83998 then
                self:revertToNormal()
                weeks:setPixelMode(false)
                self.reverted = true
                -- Mostrar RedVG nuevamente
                if self.vg and not self.vg.visible then
                    self.vg.visible = true
                    self.vg.alpha = 1
                    self:startRedVGCycle()
                end
            end
        end

        --[[ REDVG: lógica de steps (solo para activación inicial) --]]
        if not countingDown and musicTime >= 0 then
            local bpm = weeks:getBPM()
            if bpm and bpm > 0 then
                local stepTime = (60000 / bpm) / 4
                local curStep = math.floor(musicTime / stepTime) + 1
                if curStep ~= self.lastStep then
                    self.lastStep = curStep
                    if curStep == 80 then
                        self.vg.visible = true
                        self.vg.alpha = 1
                        self:startRedVGCycle()
                    end
                end
            end
        end

        -- Parpadeo del RedVG (fundido infinito mientras visible)
        if self.vg and self.vg.visible then
            if self.vg.alpha == 1 and not self.vgTween then
                -- Fundido de salida
                self.vgTween = Timer.tween(1, self.vg, {alpha = 0}, "in-out-quad", function()
                    self.vgTween = nil
                    -- Cuando termina de salir, volver a entrar si sigue visible
                    if self.vg and self.vg.visible then
                        self.vgTween = Timer.tween(1, self.vg, {alpha = 1}, "in-out-quad", function()
                            self.vgTween = nil
                        end)
                    end
                end)
            end
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
    end,

    --[[ REDVG: control de ciclo --]]
    pauseRedVG = function(self)
        if self.vgTween then
            Timer.cancel(self.vgTween)
            self.vgTween = nil
        end
    end,

    resumeRedVG = function(self)
        if self.vg and self.vg.visible then
            self:startRedVGCycle()
        end
    end,

    startRedVGCycle = function(self)
        if not self.vg or not self.vg.visible then return end
        if self.vgTween then
            Timer.cancel(self.vgTween)
            self.vgTween = nil
        end
        -- Comienza el ciclo de parpadeo (fundido infinito)
        local function cycle()
            if not self.vg or not self.vg.visible then return end
            local target = self.vg.alpha > 0.5 and 0 or 1
            self.vgTween = Timer.tween(1, self.vg, {alpha = target}, "in-out-quad", function()
                self.vgTween = nil
                if self.vg and self.vg.visible then
                    cycle()
                end
            end)
        end
        cycle()
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

            weeks:drawRating(0.9)
        love.graphics.pop()

        weeks:drawUI()

        --[[ REDVG: dibujar encima de la UI --]]
        if self.vg and self.vg.visible and self.vg.alpha > 0 then
            love.graphics.push()
            love.graphics.setColor(1, 1, 1, self.vg.alpha)
            love.graphics.draw(
                self.vg.image,
                self.vg.x, self.vg.y,
                0,
                self.vg.scaleX, self.vg.scaleY,
                self.vg.image:getWidth() / 2, self.vg.image:getHeight() / 2
            )
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.pop()
        end

        -- Estática
        if self.staticSprite and self.staticSprite.alpha > 0 then
            love.graphics.push()
            love.graphics.setColor(1, 1, 1, self.staticSprite.alpha)
            self.staticSprite:draw()
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.pop()
        end

        -- Flash rojo (no se usa, pero se deja por compatibilidad)
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
        self.shakeActive = nil
        self.flashAlpha = nil
        self.introSprites = nil

        --[[ REDVG: limpieza --]]
        if self.vgTween then
            Timer.cancel(self.vgTween)
            self.vgTween = nil
        end
        self.vg = nil

        backgroundSprites = {}
        stageLayers = {}
        stageData = nil

        -- OPT: liberar el sonido de estática explícitamente
        if staticSound then
            staticSound:stop()
            if staticSound.release then staticSound:release() end
            staticSound = nil
        end

        weeks:leave()
        collectgarbage("collect")
        collectgarbage("collect")
    end
}