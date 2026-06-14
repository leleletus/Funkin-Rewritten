local difficulty
local backgroundSprites = {}
local lastBeatTime = 0
local girlfriendBeatCounter = 0 
local stageData          -- tabla del stage cargada
local stageLayers = {}   -- objetos gráficos listos para dibujar
customGirlfriendIdle = true
local gfIdleTimer = 0
local memberNames = {"yunjin", "sakura", "chaewon", "eunchae", "kazuha"}
local targetToPath = {
    sakura = "sserafim/sakura",
    girlfriend = "sserafim/gf_truck",
    yunjin = "sserafim/yunjin",
    chaewon = "sserafim/chaewon",
    eunchae = "sserafim/eunchae",
    kazuha = "sserafim/kazuha",
    boyfriend = "nastyObject",
    yunjin_gf = "nastyObject2",
    eunchae_gf = "nastyObject3",
    chaewon_gf = "nastyObject4",
    all = "nastyObject5"
}

local sserafimEnding = require("events.sserafimEnding")

-- Sistema de eventos del chart original (reemplaza los cameraFocus manuales)
local chartEvents = {}
local chartEventIndex = 1
local camFocusTimer = nil
local camZoomTimer = nil
local cameraBop = {
    rate = 4,
    intensity = 0,
    offset = 0,
}

-- Mapea easing del chart FNF -> formato Timer (HUMP/flux)
local function mapEase(ease, easeDir)
    if ease == "INSTANT" then
        return nil -- aplicar directo, sin tween
    elseif ease == "CLASSIC" then
        return "out-quad"
    elseif ease == "linear" then
        return "linear"
    else
        local dir = "out"
        if easeDir == "In" then dir = "in"
        elseif easeDir == "InOut" then dir = "in-out" end
        return dir .. "-" .. (ease or "quad")
    end
end

-- Convierte duración en beats a segundos
local function beatsToSeconds(beats, bpm)
    if not bpm or bpm <= 0 then return 1 end
    return (beats * 60) / bpm
end

return {
    enter = function(self, from, songNum, songAppend, isStoryMode, songName)
        _G.disableAutoCam = true
        weeks.enter(self, songNum, songAppend, isStoryMode, songName)
        self:loadStage(songNum, songAppend)
        self:load()
    end,

    loadStage = function(self, songNum, songAppend)
        song = songNum
        difficulty = songAppend

        -- Bandera para controlar los eventos de ending
        self.endingTriggered1 = false
        self.endingTriggered2 = false

        -- Cargar el stage (ajusta el nombre del archivo según corresponda)
        local chunk, err = love.filesystem.load("stages/fideos.lua")
        if not chunk then
            print("Error al cargar el stage:", err)
            -- fallback a valores por defecto si no se carga
            stageLayers = {}
        else
            local ok, loaded = pcall(chunk)
            if ok and loaded then
                stageData = loaded
                -- Procesar capas
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
                        local ok2, sprite = pcall(love.filesystem.load, "sprites/" .. layer.path .. ".lua")
                        if ok2 then
                            local ok3, spriteObj = pcall(sprite)
                            if ok3 then
                                layer.obj = spriteObj
                                if layer.obj.anims then
                                    local animName = next(layer.obj.anims)
                                    if animName then layer.obj:animate(animName, true) end
                                end
                            end
                        end
                    end
                    table.insert(stageLayers, layer)

                    -- Asignar personajes según la ruta
                    if layer.path == "week7/tankman" and layer.obj then
                        enemy = layer.obj
                        enemy.x, enemy.y = layer.x, layer.y
                        enemy.sizeX, enemy.sizeY = layer.scaleX * (enemy.sizeX or 1), layer.scaleY * (enemy.sizeY or 1)
                        -- Si el sprite ya tiene escala interna, multiplicamos
                    elseif layer.path == "boyfriend" and layer.obj then
                        boyfriend = layer.obj
                        boyfriend.x, boyfriend.y = layer.x, layer.y
                        boyfriend.sizeX, boyfriend.sizeY = layer.scaleX * (boyfriend.sizeX or 1), layer.scaleY * (boyfriend.sizeY or 1)
                    elseif layer.path == "girlfriend" and layer.obj then
                        girlfriend = layer.obj
                        girlfriend.x, girlfriend.y = layer.x, layer.y
                        girlfriend.sizeX, girlfriend.sizeY = layer.scaleX * (girlfriend.sizeX or 1), layer.scaleY * (girlfriend.sizeY or 1)
                    elseif layer.path == "sserafim/gf_truck" and layer.obj then
                        girlfriend = layer.obj
                        girlfriend.x, girlfriend.y = layer.x, layer.y
                        girlfriend.sizeX, girlfriend.sizeY = layer.scaleX * (girlfriend.sizeX or 1), layer.scaleY * (girlfriend.sizeY or 1)
                    elseif layer.path == "sserafim/sakura" and layer.obj then
                        boyfriend = layer.obj
                        boyfriend.x, boyfriend.y = layer.x, layer.y
                        boyfriend.sizeX, boyfriend.sizeY = layer.scaleX * (boyfriend.sizeX or 1), layer.scaleY * (boyfriend.sizeY or 1)
                    end

                    -- Agregar sprites de fondo (excluyendo a los personajes)
                    if layer.type == "sprite" and layer.obj and layer.obj ~= enemy and layer.obj ~= boyfriend and layer.obj ~= girlfriend then
                        local animName = layer.obj.anims["idle"] and "idle" or next(layer.obj.anims)
                        if animName then
                            local anim = layer.obj.anims[animName]
                            local frameCount = anim.stop - anim.start + 1
                            table.insert(backgroundSprites, {
                                sprite = layer.obj,
                                animName = animName,
                                frameCount = frameCount
                            })
                            -- Iniciar la animación con su velocidad original
                            layer.obj:animate(animName, false)
                        end
                    end
                end
                -- Aplicar escala a los sprites de fondo (no personajes)
                for _, layer in ipairs(stageLayers) do
                    if layer.type == "sprite" and layer.obj then
                        -- Determinar si es un personaje ya asignado
                        local isCharacter = layer.obj == enemy or layer.obj == boyfriend or layer.obj == girlfriend
                        if not isCharacter then
                            layer.obj.sizeX = layer.scaleX * (layer.obj.sizeX or 1)
                            layer.obj.sizeY = layer.scaleY * (layer.obj.sizeY or 1)
                        end
                    end
                end    
            else
                print("Error al ejecutar el stage:", loaded)
            end
        end

        -- Si no se cargaron los personajes, usar valores por defecto (por si acaso)
        if not enemy then
            enemy = love.filesystem.load("sprites/week7/tankman.lua")()
            enemy.x, enemy.y = -765, 765
            enemy.sizeX = -1
        end
        if not boyfriend then
            boyfriend = love.filesystem.load("sprites/boyfriend.lua")()
            boyfriend.x, boyfriend.y = 720, 965
        end

        fakeBoyfriend = love.filesystem.load("sprites/boyfriend.lua")()
        fakeBoyfriend.x, fakeBoyfriend.y = boyfriend.x, boyfriend.y
        fakeBoyfriend.sizeX, fakeBoyfriend.sizeY = boyfriend.sizeX, boyfriend.sizeY
        _G.deathBoyfriend = fakeBoyfriend
        
        if not girlfriend then
            girlfriend = love.filesystem.load("sprites/girlfriend.lua")()
            girlfriend.x, girlfriend.y = 55, 300
        end

        -- Recolectar sprites de personajes para los nuevos tipos de notas
        self.charSprites = {}
        for _, layer in ipairs(stageLayers) do
            if layer.type == "sprite" and layer.obj then
                local path = layer.path
                if path == "sserafim/yunjin" then
                    self.charSprites.yunjin = layer.obj
                elseif path == "sserafim/kazuha" then
                    self.charSprites.kazuha = layer.obj
                elseif path == "sserafim/eunchae" then
                    self.charSprites.eunchae = layer.obj
                elseif path == "sserafim/chaewon" then
                    self.charSprites.chaewon = layer.obj
                elseif path == "sserafim/gf_truck" then
                    self.charSprites.girlfriend = layer.obj
                elseif path == "sserafim/sakura" then
                    self.charSprites.boyfriend = layer.obj
                end
            end
        end

        enemyIcon:animate("yunjin", false)

        _G.currentWeek = self

        -- Nuevas variables para el video
        self.cutscene = nil
        self.cutscenePlaying = false
    end,

    load = function(self)
        -- Limpiar overlays de ending de jugadas anteriores y resetear flags
        sserafimEnding.reset()
        self.endingTriggered1 = false
        self.endingTriggered2 = false

        weeks:load()
        customGirlfriendIdle = true

        -- Cargar eventos del chart original (cámara, zoom, lights, etc.)
        local evChunk = love.filesystem.load("charts/sserafim/spaghetti-events.lua")
        if evChunk then
            local ok, evData = pcall(evChunk)
            if ok and evData then
                chartEvents = evData
                chartEventIndex = 1
                print("[sserafim] Loaded " .. #chartEvents .. " chart events")
            else
                print("[sserafim] WARNING: Error executing spaghetti-events.lua")
                chartEvents = {}
                chartEventIndex = 1
            end
        else
            print("[sserafim] WARNING: Could not find spaghetti-events.lua")
            chartEvents = {}
            chartEventIndex = 1
        end

        inst = love.audio.newSource("music/sserafim/spaghetti-inst.ogg", "stream")
        voices = love.audio.newSource("music/sserafim/spaghetti-voices.ogg", "stream")

        self:initUI()
        
        if love.filesystem.getInfo("videos/fideos.ogv") then
            self.cutscene = love.graphics.newVideo("videos/fideos.ogv")
            self.cutscene:play()
            self.cutscenePlaying = true
            self.cutsceneStartTime = love.timer.getTime()
            self.cutsceneDuration = (self.cutscene.getDuration and self.cutscene:getDuration()) or 29
        else
            weeks:setupCountdown()
        end
    end,

    initUI = function(self)
        weeks:initUI()
        local loadedChart = love.filesystem.load("charts/sserafim/spaghetti" .. difficulty .. ".lua")()
        weeks:generateNotes(loadedChart)
    end,

    customNoteHit = function(self, direction, note, boyfriendSprite)
        local alt = note.altNote
        if type(alt) ~= "string" then
            return false  -- no es un tipo especial, que lo maneje weeks
        end

        -- Función auxiliar para animar a un personaje
        local function animateChar(charName, dir)
            local sprite = self.charSprites[charName]
            if sprite and sprite.anims and sprite.anims[dir] then
                sprite:animate(dir, false)
                if sprite == girlfriend then
                    gfIdleTimer = 12  -- La novia canta, no debe ser interrumpida
                end
            end
        end

        if alt == "yujin" then
            animateChar("yunjin", direction)
            return true   -- no animar a boyfriend
        elseif alt == "kazuha" then
            animateChar("kazuha", direction)
            return true
        elseif alt == "eunchae" then
            animateChar("eunchae", direction)
            return true
        elseif alt == "chaewon" then
            animateChar("chaewon", direction)
            return true
        elseif alt == "all" then
            animateChar("yunjin", direction)
            animateChar("kazuha", direction)
            animateChar("eunchae", direction)
            animateChar("chaewon", direction)
            animateChar("girlfriend", direction)

            -- También animará boyfriend porque devolvemos false
            return false
        elseif alt == "yujin_gf" then
            animateChar("yunjin", direction)
            animateChar("girlfriend", direction)
            return true
        elseif alt == "eunchae_gf" then
            animateChar("eunchae", direction)
            animateChar("girlfriend", direction)
            return true
        elseif alt == "chaewon_gf" then
            animateChar("chaewon", direction)
            animateChar("girlfriend", direction)
            return true
        else
            return false
        end
    end,

    customNoteHold = function(self, direction, note, boyfriendSprite)
        local alt = note.altNote
        if type(alt) ~= "string" then
            return false   -- No es un tipo especial, que lo maneje weeks
        end

        -- Determinar si es la nota final del hold
        local isEnd = note:getAnimName() == "end"
        local loop = not isEnd   -- Las notas hold se repiten, la final no

        -- Función auxiliar para animar un personaje con posibilidad de bucle
        local function animateChar(charName, dir, shouldLoop, isEnd)
            local sprite = self.charSprites[charName]
            if sprite and sprite.anims and sprite.anims[dir] then
                sprite:animate(dir, shouldLoop)
                if sprite == girlfriend then
                    if isEnd then
                        gfIdleTimer = 12          -- Nota final: vuelve a permitir bailes pronto
                    elseif shouldLoop then
                        gfIdleTimer = 999          -- Hold en curso: bloquea bailes indefinidamente
                    else
                        gfIdleTimer = 12
                    end
                end
            end
        end

        -- Misma lógica que en customNoteHit, pero con el parámetro loop
        if alt == "yujin" then
            animateChar("yunjin", direction, loop, isEnd)
            return true
        elseif alt == "kazuha" then
            animateChar("kazuha", direction, loop, isEnd)
            return true
        elseif alt == "eunchae" then
            animateChar("eunchae", direction, loop, isEnd)
            return true
        elseif alt == "chaewon" then
            animateChar("chaewon", direction, loop, isEnd)
            return true
        elseif alt == "all" then
            animateChar("yunjin", direction, loop, isEnd)
            animateChar("kazuha", direction, loop, isEnd)
            animateChar("eunchae", direction, loop, isEnd)
            animateChar("chaewon", direction, loop, isEnd)
            animateChar("girlfriend", direction, loop, isEnd)
            -- Devolvemos false para que weeks también anime a boyfriend
            return false
        elseif alt == "yujin_gf" then
            animateChar("yunjin", direction, loop, isEnd)
            animateChar("girlfriend", direction, loop, isEnd)
            return true
        elseif alt == "eunchae_gf" then
            animateChar("eunchae", direction, loop, isEnd)
            animateChar("girlfriend", direction, loop, isEnd)
            return true
        elseif alt == "chaewon_gf" then
            animateChar("chaewon", direction, loop, isEnd)
            animateChar("girlfriend", direction, loop, isEnd)
            return true
        else
            return false
        end
    end,

    customNoteMiss = function(self, direction, note, boyfriendSprite)
        local alt = note.altNote
        if type(alt) ~= "string" then
            return false
        end

        local missAnim = "miss " .. direction

        -- Función auxiliar para animar a un personaje con la animación de miss
        local function animateCharMiss(charName)
            local sprite = self.charSprites[charName]
            if sprite and sprite.anims and sprite.anims[missAnim] then
                sprite:animate(missAnim, false)
                if sprite == girlfriend then
                    gfIdleTimer = 12
                end
                return true
            end
            return false
        end

        if alt == "yujin" then
            return animateCharMiss("yunjin")
        elseif alt == "kazuha" then
            return animateCharMiss("kazuha")
        elseif alt == "eunchae" then
            return animateCharMiss("eunchae")
        elseif alt == "chaewon" then
            return animateCharMiss("chaewon")
        elseif alt == "all" then
            local any = false
            any = animateCharMiss("yunjin") or any
            any = animateCharMiss("kazuha") or any
            any = animateCharMiss("eunchae") or any
            any = animateCharMiss("chaewon") or any
            any = animateCharMiss("girlfriend") or any
            -- Devolvemos false para que boyfriend también haga miss (como en customNoteHit)
            return false
        elseif alt == "yujin_gf" then
            animateCharMiss("yunjin")
            animateCharMiss("girlfriend")
            return true
        elseif alt == "eunchae_gf" then
            animateCharMiss("eunchae")
            animateCharMiss("girlfriend")
            return true
        elseif alt == "chaewon_gf" then
            animateCharMiss("chaewon")
            animateCharMiss("girlfriend")
            return true
        else
            return false
        end
    end,

    update = function(self, dt)
        if self.cutscenePlaying then
            -- Permitir saltar con Confirm (Enter / Start)
            if not graphics.isFading() then
                if input:pressed("confirm") then
                    -- Saltar cutscene e iniciar countdown
                    self.cutscenePlaying = false
                    if self.cutscene then
                        if self.cutscene.stop then
                            self.cutscene:stop()
                        elseif self.cutscene.pause then
                            self.cutscene:pause()
                        end
                        self.cutscene = nil
                    end
                    weeks:setupCountdown()
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
                    -- Detener música si estuviera sonando
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
                weeks:setupCountdown()
            end
            return  -- No actualizar el resto del juego
        end

        if gfIdleTimer > 0 then
            gfIdleTimer = gfIdleTimer - 1
        end

        weeks:update(dt)
   
        local musicTime = weeks:getMusicTime()  -- en milisegundos (única llamada en este frame)

        -- Eventos de ending de sserafim
        if not self.endingTriggered1 and musicTime >= 167357 then
            sserafimEnding.trigger("sserafim/end1", "end1.ogg")
            self.endingTriggered1 = true
        end
        if not self.endingTriggered2 and musicTime >= 170137 then
            sserafimEnding.trigger("sserafim/end2", "end2.ogg")
            self.endingTriggered2 = true
        end

        -- ============================================================
        -- Procesar eventos del chart original (FocusCamera, ZoomCamera, etc.)
        -- Reemplaza el viejo sistema manual de cameraFocus
        -- ============================================================
        local bpm = weeks:getBPM() or 111.5

        while chartEventIndex <= #chartEvents do
            local ev = chartEvents[chartEventIndex]
            if ev.t > musicTime then break end

            local v = ev.v
            local etype = ev.e

            -- FocusCamera: mueve la cámara a posición x,y del stage
            -- Las coordenadas del chart son el punto de enfoque en el stage
            -- cam.x/y negativos = el stage se desplaza para centrar ese punto
            if etype == "FocusCamera" then
                local targetX = -(v.x or 0)
                local targetY = -(v.y or 0)
                local durSec = beatsToSeconds(v.duration or 4, bpm)
                local easeStr = mapEase(v.ease, v.easeDir)

                if camFocusTimer then Timer.cancel(camFocusTimer) end
                if camTimer then Timer.cancel(camTimer) end

                if easeStr == nil then
                    cam.x = targetX
                    cam.y = targetY
                else
                    camFocusTimer = Timer.tween(durSec, cam, {
                        x = targetX,
                        y = targetY,
                    }, easeStr)
                end

            -- ZoomCamera: cambia el zoom
            -- weeks.lua aplica: cam.sizeX = camScale.x * beatPulse cada frame
            -- Por eso tweenamos camScale, NO cam.sizeX/Y directamente
            -- FNF zoom 1.0 = vista normal. Escalamos: zoomFinal = chartZoom * 0.5
            -- para que zoom 1.0 del chart ≈ 0.5 en tu engine (ajusta si necesario)
            elseif etype == "ZoomCamera" then
                local BASE_ZOOM = 0.45  -- Factor de escala: chartZoom * BASE_ZOOM = tu zoom
                local targetZoom = (v.zoom or 1) * BASE_ZOOM
                local durSec = beatsToSeconds(v.duration or 4, bpm)
                local easeStr = mapEase(v.ease, v.easeDir)

                if camZoomTimer then Timer.cancel(camZoomTimer) end

                if easeStr == nil then
                    camScale.x = targetZoom
                    camScale.y = targetZoom
                else
                    camZoomTimer = Timer.tween(durSec, camScale, {
                        x = targetZoom,
                        y = targetZoom,
                    }, easeStr)
                end

            -- SetCameraBop: configura el pulso rítmico
            elseif etype == "SetCameraBop" then
                cameraBop.rate = v.rate or 4
                cameraBop.intensity = v.intensity or 0
                cameraBop.offset = v.offset or 0

            -- SetHealthIcon: cambia el ícono
            elseif etype == "SetHealthIcon" then
                local iconId = v.id
                if iconId then
                    if v.char == 0 then
                        -- Cambiar ícono del jugador
                        if boyfriendIcon and boyfriendIcon.anims and boyfriendIcon.anims[iconId] then
                            boyfriendIcon:animate(iconId, false)
                        end
                    else
                        -- Cambiar ícono del enemigo
                        if enemyIcon and enemyIcon.anims and enemyIcon.anims[iconId] then
                            enemyIcon:animate(iconId, false)
                        end
                    end
                end

            -- sserafimSing: controla quién canta
            elseif etype == "sserafimSing" then
                -- singing = {yunjin, kazuha, chaewon, eunchae, sakura/bf, jhope/gf}
                -- Puedes expandir esto según necesites

            -- sserafimShow: visibilidad de personajes
            elseif etype == "sserafimShow" then
                -- visible = {yunjin, kazuha, chaewon, eunchae, sakura}

            -- sserafimDark: oscurecer escenario
            elseif etype == "sserafimDark" then
                -- v.amount, v.duration

            -- sserafimFlash: destello
            elseif etype == "sserafimFlash" then
                -- v.duration

            -- sserafimPulseLights: luces pulsantes
            elseif etype == "sserafimPulseLights" then
                -- v.enabled, v.colors, v.intensities, v.durations

            -- sserafimGuitarVibration: screen shake
            elseif etype == "sserafimGuitarVibration" then
                -- v.duration

            -- sserafimCover: cover art
            elseif etype == "sserafimCover" then
                -- v.visible

            -- sserafimBeautiful: efecto especial
            elseif etype == "sserafimBeautiful" then
                -- v.beautiful

            -- sserafimKick
            elseif etype == "sserafimKick" then
                -- v.final

            -- sserafimEnd
            elseif etype == "sserafimEnd" then
                -- fin de la canción
            end

            chartEventIndex = chartEventIndex + 1
        end
        if musicTime and bpm then
            local beatInterval = 60000 / bpm -- milisegundos por beat
            if lastBeatTime == 0 then
                lastBeatTime = musicTime
            end
            if musicTime - lastBeatTime >= beatInterval then
                lastBeatTime = musicTime
                for _, bg in ipairs(backgroundSprites) do
                    if not bg.sprite:isAnimated() then
                        -- Dividimos la velocidad entre 2 para que coincida con el beat
                        local desiredSpeed = (bg.frameCount * bpm / 60) / 2
                        bg.sprite:setAnimSpeed(desiredSpeed)
                        bg.sprite:animate(bg.animName, false)
                    end
                end

                -- Animación de girlfriend (se mantiene igual)
                if girlfriend then
                    if gfIdleTimer <= 0 then  -- Solo baila si no está ocupada
                        girlfriendBeatCounter = girlfriendBeatCounter + 1
                        local animName = (girlfriendBeatCounter % 2 == 1) and "dance left" or "dance right"
                        girlfriend:animate(animName, false)
                        local anim = girlfriend.anims[animName]
                        if anim then
                            local frameCount = anim.stop - anim.start + 1
                            local desiredSpeed = frameCount * bpm / 60
                            girlfriend:setAnimSpeed(desiredSpeed)
                        end
                        gfIdleTimer = 12  -- Bloquea nuevos bailes por 12 frames
                    end
                end
            end
        end

        for _, bg in ipairs(backgroundSprites) do
            bg.sprite:update(dt)
        end

        local currentAnim = enemyIcon:getAnimName()
        local baseName
        if currentAnim:find(" losing$") then
            baseName = currentAnim:gsub(" losing$", "")  -- quita el sufijo
        else
            baseName = currentAnim
        end

        -- Fin de la canción: weeks.handleSongEnd() se encarga de la transición

        weeks:updateUI(dt)
    end,

    draw = function(self)
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

            -- Dibujar capas agrupadas por factor de scroll (o una a una con su propio scroll)
            -- Para mantener el orden de fondo a frente, simplemente iteramos stageLayers
            -- y aplicamos la transformación con su scroll.
            for _, layer in ipairs(stageLayers) do
                if layer.visible and layer.obj then
                    love.graphics.push()
                        love.graphics.translate(cam.x * layer.scrollX, cam.y * layer.scrollY)
                        layer.obj.x = layer.x
                        layer.obj.y = layer.y
                        -- La escala ya se aplicó al cargar o se puede forzar aquí
                        -- (si el sprite ya tiene escala interna, respetarla)
                        layer.obj:draw()
                    love.graphics.pop()
                end
            end

            --weeks:drawRating(0.9)
        love.graphics.pop()

        weeks:drawUI()
        sserafimEnding.draw()
    end,

    leave = function(self)
        sserafimEnding.reset()
        _G.disableAutoCam = false
        customGirlfriendIdle = false

        -- Detener video si está reproduciéndose
        if self.cutscene then
            if self.cutscene.stop then
                self.cutscene:stop()
            elseif self.cutscene.pause then
                self.cutscene:pause()
            end
            self.cutscene = nil
        end
        self.cutscenePlaying = false

        -- Vaciar tablas locales
        backgroundSprites = {}
        stageLayers = {}
        stageData = nil
        lastBeatTime = 0

        -- Limpiar sistema de eventos del chart
        chartEvents = {}
        chartEventIndex = 1
        if camFocusTimer then Timer.cancel(camFocusTimer); camFocusTimer = nil end
        if camZoomTimer then Timer.cancel(camZoomTimer); camZoomTimer = nil end
        cameraBop.rate = 4
        cameraBop.intensity = 0
        cameraBop.offset = 0

        -- Limpiar referencias a sprites de personajes
        self.charSprites = nil
        fakeBoyfriend = nil
        girlfriend = nil
        enemy = nil
        boyfriend = nil

        _G.currentWeek = nil
        _G.deathBoyfriend = nil

        weeks:leave()

        collectgarbage("collect")
        collectgarbage("collect")
    end
}