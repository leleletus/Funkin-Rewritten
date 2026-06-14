--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten

Copyright (C) 2021  HTV04

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

local atlasText = require("modules.atlas_text")

local menuID, selection
local curDir, dirTable
local sprite, spriteAnims, overlaySprite
local titleText, menuOptionsText, backgroundImage
local optionsList
local lerpSelected = 1

-- Estado del visor de frames (svMode == 3)
local fvSprite    = nil
local fvFrame     = 1
local fvAnimIdx   = 1
local fvAnimList  = {}
local fvAdjX      = 0
local fvAdjY      = 0
local fvMode      = false   -- true = navegar archivos para visor de frames
local listScroll  = 0       -- offset de scroll para el navegador de archivos (svMode==1)

-- Estado del editor de sprites de results (svMode == 4)
local rePhase      = 0            -- 0 = elegir variación, 1 = editar sprites
local reVariations = {"PERFECT", "EXCELLENT", "GREAT", "GOOD", "LOSS"}
local reVarIdx     = 4            -- índice en reVariations (GOOD por defecto)
local reObjects    = {}           -- sprites cargados para editar
local reSelIdx     = 1            -- sprite seleccionado actualmente
local reDragging   = false        -- true mientras se arrastra un sprite con el mouse
local reDragOffX   = 0            -- offset mouse→origen del sprite al iniciar el arrastre
local reDragOffY   = 0
local reShowBg     = true         -- H: alterna fondo amarillo de results (true) o azul editor

-- Función auxiliar para crear texto centrado con atlasText
local function createCenteredText(y, text, style)
    local textObj = atlasText.new(0, y, text, style)
    -- Calcular el ancho total como la posición x de la última letra más su ancho
    local maxX = 0
    for _, letter in ipairs(textObj.letters) do
        local right = letter.x + (letter.width or 0)
        if right > maxX then maxX = right end
    end
    local offsetX = (1280 - maxX) / 2
    if textObj.setPosition then
        textObj:setPosition(offsetX, y)
    else
        for _, letter in ipairs(textObj.letters) do
            letter.x = letter.x + offsetX
        end
    end
    textObj.centerX = offsetX
    textObj.baseY = y
    return textObj
end

local function loadResultsSprites(variation)
    -- Mismos archivos y configs que usa results.lua (mantener sincronizado con spriteConfig)
    local bfFiles_r = {
        LOSS      = "sprites/resultsScreen/RESULTS_BOYFRIEND_LOSS_RANK_final.lua",
        GOOD      = "sprites/resultsScreen/resultBoyfriendGOOD.lua",
        GREAT     = "sprites/resultsScreen/RESULTS BOYFRIEND GREAT RANK final.lua",
        EXCELLENT = "sprites/resultsScreen/RESULTS BOYFRIEND EXCELLENT RANK final v2.lua",
        PERFECT   = "sprites/resultsScreen/RESULTS BOYFRIEND PERFECT RANK final.lua",
    }
    local gfFiles_r = {
        GOOD      = "sprites/resultsScreen/resultGirlfriendGOOD.lua",
        GREAT     = "sprites/resultsScreen/RESULTS GIRLFRIEND GREAT RANK final.lua",
        EXCELLENT = "sprites/resultsScreen/RESULTS BOYFRIEND EXCELLENT RANK final v2 faces.lua",
        PERFECT   = "sprites/resultsScreen/RESULTS BOYFRIEND PERFECT RANK final heart.lua",
    }
    -- Posiciones exactas de results.lua > spriteConfig (x/y = posición loop/final)
    local cfgData = {
        LOSS      = { bf = {x=928,  y=206, scale=1,    introX=928,  introY=206} },
        GOOD      = { bf = {x=1000, y=265, scale=1,    introX=1000, introY=265},
                      gf = {x=810,  y=500, scale=1,    introX=810,  introY=500} },
        GREAT     = { bf = {x=1013, y=259, scale=0.95, introX=1013, introY=259},
                      gf = {x=771,  y=267, scale=1,    introX=771,  introY=267} },
        EXCELLENT = { bf = {x=956,  y=248, scale=0.95, introX=956,  introY=248},
                      gf = {x=956,  y=248, scale=0.95} },
        PERFECT   = { bf = {x=938,  y=283, scale=1,    introX=938,  introY=283},
                      gf = {x=746,  y=374, scale=0.95} },
    }
    local cfg  = cfgData[variation] or cfgData.GOOD
    local objs = {}

    local function tryLoad(label, path, spriteCfg)
        if not path or not spriteCfg then return end
        local ok, spr = pcall(function() return love.filesystem.load(path)() end)
        if not ok or not spr then
            print("[ResultsEditor] No se pudo cargar: " .. tostring(path))
            return
        end
        local cx, cy, cscale = spriteCfg.x, spriteCfg.y, spriteCfg.scale
        if label == "resultsAnim" then
            local fw, fh = 0, 0
            pcall(function() fw = spr:getFrameWidth(); fh = spr:getFrameHeight() end)
            if fh > 0 then cx = 1280/2 - fw/2; cy = fh + 35 end
        end
        spr.x, spr.y         = cx, cy
        spr.sizeX, spr.sizeY = cscale, cscale
        local animList = {}
        if spr.getAnims then
            for k in pairs(spr:getAnims()) do table.insert(animList, k) end
            table.sort(animList)
            if #animList > 0 then pcall(function() spr:animate(animList[1], false) end) end
        end
        local fd = nil
        pcall(function() fd = spr:getFrameData() end)
        table.insert(objs, {
            name      = label,
            spr       = spr,
            x = cx, y = cy, scale = cscale,
            refX = cx, refY = cy, refScale = cscale,
            introX = spriteCfg.introX,
            introY = spriteCfg.introY,
            animList  = animList,
            animIdx   = 1,
            curFrame  = 1,
            loopStart = nil, loopEnd = nil, loopName = "",
            hasFrames = fd ~= nil and #fd > 0,
        })
    end

    -- BF siempre primero; GF después (se dibuja encima, correcto para PERFECT y EXCELLENT)
    tryLoad("BF", bfFiles_r[variation], cfg.bf or {x=640, y=360, scale=1})

    if gfFiles_r[variation] and cfg.gf then
        tryLoad("GF", gfFiles_r[variation], cfg.gf)
    end

    for _, f in ipairs({
        {name="soundSystem",  path="sprites/resultsScreen/soundSystem.lua",  x=425, y=300, scale=1},
        {name="resultsAnim",  path="sprites/resultsScreen/resultsAnim.lua",  x=640, y=120, scale=1},
        {name="ratingsPopin", path="sprites/resultsScreen/ratingsPopin.lua", x=110, y=330, scale=1},
        {name="scorePopin",   path="sprites/resultsScreen/scorePopin.lua",   x=180, y=590, scale=1},
    }) do
        tryLoad(f.name, f.path, f)
    end

    return objs
end

return {
    spriteViewerSearch = function(self, dir)
        svMode = 1
        fvMode = false  -- reset: esta función es para el visor de animaciones

        if curDir then
            curDir = curDir .. "/" .. dir
        else
            curDir = dir
        end
        selection  = 1
        listScroll = 0
        dirTable = love.filesystem.getDirectoryItems(curDir)
    end,

    enter = function(self, previous)
        menuID = 1
        selection = 1
        lerpSelected = 1

        -- Cargar fondo
        backgroundImage = graphics.newImage(love.graphics.newImage("images/png/menuBGMagenta.png"))
        backgroundImage.x = 1280 / 2
        backgroundImage.y = 720 / 2
        backgroundImage.originX = 0.5
        backgroundImage.originY = 0.5
        backgroundImage.sizeX = 1
        backgroundImage.sizeY = 1

        -- Título principal centrado
        titleText = createCenteredText(720 * 0.139, "REALLY BAD DEBUG MENU", "bold")

        -- Opciones del menú
        -- Helper: lanza results con datos de prueba para una variación específica
        local function testResults(variation)
            -- Tabla de datos falsos que results.lua espera
            local fakeScores = {
                PERFECT    = { sickCount=100, goodCount=0,  badCount=0,  shitCount=0, missedCount=0,  score=50000, maxCombo=100 },
                EXCELLENT  = { sickCount=85,  goodCount=10, badCount=2,  shitCount=0, missedCount=0,  score=40000, maxCombo=90  },
                GREAT      = { sickCount=70,  goodCount=20, badCount=5,  shitCount=0, missedCount=2,  score=30000, maxCombo=60  },
                GOOD       = { sickCount=50,  goodCount=20, badCount=10, shitCount=5, missedCount=5,  score=20000, maxCombo=30  },
                LOSS       = { sickCount=10,  goodCount=5,  badCount=5,  shitCount=5, missedCount=30, score=5000,  maxCombo=5   },
            }
            local sd = {
                diff        = "hard",
                song        = "test-song",
                displaySong = "Test Song",
                artist      = nil,
                scores      = fakeScores[variation] or fakeScores.PERFECT,
            }
            local resultsState = love.filesystem.load("states/results.lua")()
            Gamestate.switch(resultsState, sd)
        end

        menus = {
            {
                1,
                "Really Bad Debug Menu",
                {
                    {"Chart Editor", function() Gamestate.switch(require("states.chart-editor")) end},
                    {"Note Offset Debug", function() Gamestate.switch(require("states.note-offset-debug")) end},
                    {"Character Offset Debug", function() Gamestate.switch(require("states.character-offset-debug")) end},
                    {"Stage Editor", function() Gamestate.switch(require("states.stage-editor")) end},
                    {"Results: PERFECT",   function() testResults("PERFECT")   end},
                    {"Results: EXCELLENT", function() testResults("EXCELLENT") end},
                    {"Results: GREAT",     function() testResults("GREAT")     end},
                    {"Results: GOOD",      function() testResults("GOOD")      end},
                    {"Results: LOSS",      function() testResults("LOSS")      end},
                    {"Sprite Frame Viewer", function()
                        fvMode     = true
                        menuID     = 2
                        svMode     = 1
                        curDir     = "sprites"
                        dirTable   = love.filesystem.getDirectoryItems("sprites")
                        selection  = 1
                        listScroll = 0
                    end},
                    {"Results Sprite Editor", function()
                        menuID    = 2
                        svMode    = 4
                        rePhase   = 0
                        reVarIdx  = 4
                        reObjects = {}
                        reSelIdx  = 1
                    end},
                }
            },
            {2}  -- Sprite viewer
        }

        optionsList = menus[1][3]

        -- Crear textos para las opciones, centrados
        menuOptionsText = {}
        local startY = 720 * 0.417   -- 300/720 ≈ 0.417
        local spacing = 720 * 0.139  -- 100/720 ≈ 0.139
        for i, opt in ipairs(optionsList) do
            local textObj = createCenteredText(startY + (i - 1) * spacing, opt[1], "bold")
            table.insert(menuOptionsText, textObj)
        end

        graphics.setFade(0)
        graphics.fadeIn(0.5)
    end,

    keypressed = function(self, key)
        if menus[menuID][1] == 2 then -- Sprite viewer / Frame viewer
            if svMode == 2 then
                if key == "w" then
                    overlaySprite.y = overlaySprite.y - 1
                elseif key == "a" then
                    overlaySprite.x = overlaySprite.x - 1
                elseif key == "s" then
                    overlaySprite.y = overlaySprite.y + 1
                elseif key == "d" then
                    overlaySprite.x = overlaySprite.x + 1
                end
            elseif svMode == 3 then
                -- Visor de frames: navegar frames y ajustar offsets
                local fd = fvSprite and fvSprite:getFrameData()
                if key == "left" then
                    fvFrame = math.max(1, fvFrame - 1)
                    fvSprite:setFrame(fvFrame)
                    fvAdjX, fvAdjY = 0, 0
                elseif key == "right" then
                    fvFrame = math.min(fd and #fd or 1, fvFrame + 1)
                    fvSprite:setFrame(fvFrame)
                    fvAdjX, fvAdjY = 0, 0
                elseif key == "up" then
                    if #fvAnimList > 0 then
                        fvAnimIdx = ((fvAnimIdx - 2) % #fvAnimList) + 1
                        local ad = fvSprite:getAnims()[fvAnimList[fvAnimIdx]]
                        fvFrame = ad.start
                        fvSprite:setFrame(fvFrame)
                        fvAdjX, fvAdjY = 0, 0
                    end
                elseif key == "down" then
                    if #fvAnimList > 0 then
                        fvAnimIdx = (fvAnimIdx % #fvAnimList) + 1
                        local ad = fvSprite:getAnims()[fvAnimList[fvAnimIdx]]
                        fvFrame = ad.start
                        fvSprite:setFrame(fvFrame)
                        fvAdjX, fvAdjY = 0, 0
                    end
                elseif key == "w" then fvAdjY = fvAdjY - 1
                elseif key == "s" then fvAdjY = fvAdjY + 1
                elseif key == "a" then fvAdjX = fvAdjX - 1
                elseif key == "d" then fvAdjX = fvAdjX + 1
                elseif key == "backspace" then
                    svMode     = 1
                    selection  = 1
                    listScroll = 0
                    fvAdjX, fvAdjY = 0, 0
                end
            elseif svMode == 4 then
                -- ── Editor de sprites de results ──────────────────────────────────
                local shift = love.keyboard.isDown("lshift", "rshift")
                local step  = shift and 10 or 1
                local sStep = shift and 0.01 or 0.05
                if rePhase == 0 then
                    if key == "up" then
                        reVarIdx = (reVarIdx - 2) % #reVariations + 1
                    elseif key == "down" then
                        reVarIdx = reVarIdx % #reVariations + 1
                    elseif key == "return" then
                        reObjects  = loadResultsSprites(reVariations[reVarIdx])
                        reSelIdx   = 1
                        rePhase    = 1
                        reDragging = false
                    elseif key == "backspace" then
                        menuID = 1
                        svMode = 1
                    end
                elseif rePhase == 1 and #reObjects > 0 then
                    local obj = reObjects[reSelIdx]
                    if obj then
                        if key == "tab" then
                            if shift then
                                reSelIdx = (reSelIdx - 2) % #reObjects + 1
                            else
                                reSelIdx = reSelIdx % #reObjects + 1
                            end
                        elseif key == "w" then obj.y = obj.y - step; obj.spr.y = obj.y
                        elseif key == "s" then obj.y = obj.y + step; obj.spr.y = obj.y
                        elseif key == "a" then obj.x = obj.x - step; obj.spr.x = obj.x
                        elseif key == "d" then obj.x = obj.x + step; obj.spr.x = obj.x
                        elseif key == "q" then
                            obj.scale = math.max(0.01, obj.scale - sStep)
                            obj.spr.sizeX, obj.spr.sizeY = obj.scale, obj.scale
                        elseif key == "e" then
                            obj.scale = obj.scale + sStep
                            obj.spr.sizeX, obj.spr.sizeY = obj.scale, obj.scale
                        elseif key == "left" then
                            if obj.hasFrames then
                                obj.curFrame = math.max(1, obj.curFrame - 1)
                                pcall(function() obj.spr:setFrame(obj.curFrame) end)
                            end
                        elseif key == "right" then
                            if obj.hasFrames then
                                local fd = nil
                                pcall(function() fd = obj.spr:getFrameData() end)
                                obj.curFrame = math.min(fd and #fd or 1, obj.curFrame + 1)
                                pcall(function() obj.spr:setFrame(obj.curFrame) end)
                            end
                        elseif key == "," then
                            if #obj.animList > 0 then
                                obj.animIdx = (obj.animIdx - 2) % #obj.animList + 1
                                pcall(function() obj.spr:animate(obj.animList[obj.animIdx], false) end)
                                local ad = nil
                                pcall(function() ad = obj.spr:getAnims()[obj.animList[obj.animIdx]] end)
                                if ad then obj.curFrame = ad.start or 1 end
                            end
                        elseif key == "." then
                            if #obj.animList > 0 then
                                obj.animIdx = obj.animIdx % #obj.animList + 1
                                pcall(function() obj.spr:animate(obj.animList[obj.animIdx], false) end)
                                local ad = nil
                                pcall(function() ad = obj.spr:getAnims()[obj.animList[obj.animIdx]] end)
                                if ad then obj.curFrame = ad.start or 1 end
                            end
                        elseif key == "f1" then
                            obj.loopStart = obj.curFrame
                            if obj.loopName == "" and #obj.animList > 0 then
                                obj.loopName = obj.animList[obj.animIdx]
                            end
                        elseif key == "f2" then
                            obj.loopEnd = obj.curFrame
                        elseif key == "return" then
                            print("=== Results Sprite Config === variación: " .. reVariations[reVarIdx])
                            for _, o in ipairs(reObjects) do
                                print(string.format("  [%s]  x=%d  y=%d  scale=%.3f",
                                    o.name, math.floor(o.x+0.5), math.floor(o.y+0.5), o.scale))
                                if o.loopStart and o.loopEnd then
                                    print(string.format("    loop %q: frames %d → %d",
                                        o.loopName, o.loopStart, o.loopEnd))
                                end
                            end
                        elseif key == "h" then
                            reShowBg = not reShowBg
                        elseif key == "backspace" then
                            rePhase    = 0
                            reObjects  = {}
                            reDragging = false
                        end
                    end
                end
            end
        end
    end,

    spriteViewer = function(self, spritePath)
        local spriteData = love.filesystem.load(spritePath)

        svMode = 2

        sprite = spriteData()
        overlaySprite = spriteData()

        spriteAnims = {}
        for i, _ in pairs(sprite.getAnims()) do
            table.insert(spriteAnims, i)
        end

        sprite:animate(spriteAnims[1], false)
        overlaySprite:animate(spriteAnims[1], false)
    end,

    wheelmoved = function(self, x, y)
        if menus[menuID][1] == 2 then
            if svMode == 1 then
                local maxScroll = math.max(0, #dirTable - 30)
                listScroll = math.max(0, math.min(listScroll - math.floor(y) * 3, maxScroll))
            elseif svMode == 4 and rePhase == 1 and #reObjects > 0 then
                if y > 0 then
                    reSelIdx = (reSelIdx - 2) % #reObjects + 1
                elseif y < 0 then
                    reSelIdx = reSelIdx % #reObjects + 1
                end
            end
        else
            -- Menú principal: scroll entre opciones
            local steps = math.floor(-y)
            if steps ~= 0 then
                selection = selection + steps
                if selection < 1 then selection = #optionsList end
                if selection > #optionsList then selection = 1 end
            end
        end
    end,

    update = function(self, dt)
        if titleText then titleText:update(dt) end
        for _, text in ipairs(menuOptionsText or {}) do
            text:update(dt)
        end

        if menus[menuID][1] == 2 then -- Sprite viewer / Frame viewer
            if svMode == 2 then
                sprite:update(dt)
                overlaySprite:update(dt)

                if input:pressed("up") then
                    selection = selection - 1
                    if selection < 1 then selection = #spriteAnims end
                    sprite:animate(spriteAnims[selection], false)
                end
                if input:pressed("down") then
                    selection = selection + 1
                    if selection > #spriteAnims then selection = 1 end
                    sprite:animate(spriteAnims[selection], false)
                end
                if input:pressed("confirm") then
                    overlaySprite:animate(spriteAnims[selection], false)
                end
            elseif svMode == 3 then
                -- Frame viewer: navegación por teclas manejada en keypressed
            elseif svMode == 4 then
                -- Results sprite editor: actualizar animaciones de todos los sprites
                for _, o in ipairs(reObjects) do
                    if o.spr then pcall(function() o.spr:update(dt) end) end
                end
            else
                -- svMode == 1: navegador de archivos
                local visibleRows = 30  -- filas visibles (~720 / 22px)
                if input:pressed("up") then
                    selection = selection - 1
                    if selection < 1 then selection = #dirTable end
                end
                if input:pressed("down") then
                    selection = selection + 1
                    if selection > #dirTable then selection = 1 end
                end
                -- Ajustar scroll para mantener selección visible
                if selection <= listScroll + 1 then
                    listScroll = math.max(0, selection - 1)
                elseif selection > listScroll + visibleRows then
                    listScroll = selection - visibleRows
                end
                if input:pressed("confirm") then
                    local path = curDir .. "/" .. dirTable[selection]
                    if love.filesystem.getInfo(path).type == "directory" then
                        local wasFvMode = fvMode
                        self:spriteViewerSearch(dirTable[selection])
                        fvMode = wasFvMode  -- preservar modo tras navegar directorio
                    elseif fvMode then
                        -- Cargar sprite en visor de frames
                        local ok, loaded = pcall(love.filesystem.load, path)
                        if ok and loaded then
                            fvSprite   = loaded()
                            fvAnimList = {}
                            for name, _ in pairs(fvSprite:getAnims()) do
                                table.insert(fvAnimList, name)
                            end
                            table.sort(fvAnimList)
                            fvAnimIdx  = 1
                            if #fvAnimList > 0 then
                                local ad = fvSprite:getAnims()[fvAnimList[fvAnimIdx]]
                                fvFrame  = ad.start
                            else
                                fvFrame  = 1
                            end
                            fvSprite:setFrame(fvFrame)
                            fvAdjX, fvAdjY = 0, 0
                            svMode = 3
                        end
                    else
                        self:spriteViewer(path)
                    end
                end
            end
        else -- Menú estándar
            if input:pressed("up") then
                selection = selection - 1
                if selection < 1 then selection = #optionsList end
            end
            if input:pressed("down") then
                selection = selection + 1
                if selection > #optionsList then selection = 1 end
            end
            if input:pressed("confirm") then
                optionsList[selection][2]()
            end

            -- Interpolación para el desplazamiento (scroll)
            lerpSelected = lerpSelected + (selection - lerpSelected) * 0.1

            local startY = 720 * 0.417
            local spacing = 720 * 0.139
            for i, textObj in ipairs(menuOptionsText) do
                local targetY = startY + (i - lerpSelected) * spacing
                if textObj.setPosition then
                    textObj:setPosition(textObj.centerX, targetY)
                else
                    local diffY = targetY - textObj.baseY
                    for _, letter in ipairs(textObj.letters) do
                        letter.y = letter.y + diffY
                    end
                    textObj.baseY = targetY
                end
            end
        end

        if input:pressed("back") then
            if menus[menuID][1] == 2 and svMode == 3 then
                -- Volver al navegador de archivos
                svMode     = 1
                selection  = 1
                listScroll = 0
                fvAdjX, fvAdjY = 0, 0
            elseif menus[menuID][1] == 2 and svMode == 4 then
                if rePhase == 1 then
                    rePhase   = 0
                    reObjects = {}
                else
                    menuID = 1
                    svMode = 1
                end
            elseif not transitionRef.value then
                local StickerTransition = require("modules.sticker_transition")
                transitionRef.value = StickerTransition.new(function() return menu end, transitionRef)
                transitionRef.value:enter()
            end
        end
    end,

    draw = function(self)
        -- Fondo escalado para cubrir toda la pantalla
        if backgroundImage then
            backgroundImage:draw()
        end

        if menus[menuID][1] == 2 then -- Sprite viewer / Frame viewer
            if svMode == 2 then
                graphics.clear(0.5, 0.5, 0.5)

                love.graphics.push()
                    love.graphics.translate(1280 / 2, 720 / 2)
                    sprite:draw()
                    graphics.setColor(1, 1, 1, 0.5)
                    overlaySprite:draw()
                    graphics.setColor(1, 1, 1)
                love.graphics.pop()

                for i = 1, #spriteAnims do
                    if i == selection then
                        graphics.setColor(1, 1, 0)
                    end
                    love.graphics.print(spriteAnims[i], 0, (i - 1) * 20)
                    graphics.setColor(1, 1, 1)

                    love.graphics.print("X: " .. tostring(sprite.x - overlaySprite.x), 0, (#spriteAnims + 1) * 20)
                    love.graphics.print("Y: " .. tostring(sprite.y - overlaySprite.y), 0, (#spriteAnims + 2) * 20)
                end
            elseif svMode == 3 and fvSprite then
                -- ── Visor de frames ────────────────────────────────────────────
                love.graphics.clear(0.12, 0.12, 0.12)
                graphics.setColor(1, 1, 1)

                -- Sprite centrado con ajuste de offset en vivo
                love.graphics.push()
                    fvSprite.offsetX = fvAdjX
                    fvSprite.offsetY = fvAdjY
                    love.graphics.translate(640, 360)
                    fvSprite:draw()
                love.graphics.pop()
                fvSprite.offsetX = 0
                fvSprite.offsetY = 0

                -- Panel de información
                local fd = fvSprite:getFrameData()
                local f  = fvFrame
                if fd and f >= 1 and f <= #fd then
                    local animName = fvAnimIdx <= #fvAnimList and fvAnimList[fvAnimIdx] or "?"
                    local ad       = fvSprite:getAnims()[animName]
                    local inAnim   = ad and f >= ad.start and f <= ad.stop

                    love.graphics.setColor(1, 1, 0)
                    love.graphics.print(string.format("Frame: %d / %d", f, #fd), 10, 10)
                    love.graphics.print(string.format("Anim: %s  [%d - %d]  en anim: %s",
                        animName,
                        ad and ad.start or 0,
                        ad and ad.stop  or 0,
                        tostring(inAnim)), 10, 30)

                    love.graphics.setColor(1, 1, 1)
                    love.graphics.print(string.format("offsetX: %d  (adj %+d  →  nuevo: %d)",
                        fd[f].offsetX, fvAdjX, fd[f].offsetX + fvAdjX), 10, 55)
                    love.graphics.print(string.format("offsetY: %d  (adj %+d  →  nuevo: %d)",
                        fd[f].offsetY, fvAdjY, fd[f].offsetY + fvAdjY), 10, 75)
                    love.graphics.print(string.format("region: x=%d  y=%d  w=%d  h=%d",
                        fd[f].x, fd[f].y, fd[f].width, fd[f].height), 10, 95)
                    love.graphics.print(string.format("offsetWidth: %d   offsetHeight: %d",
                        fd[f].offsetWidth, fd[f].offsetHeight), 10, 115)

                    -- Lista de animaciones
                    love.graphics.setColor(0.55, 0.55, 0.55)
                    love.graphics.print("Animaciones:", 10, 145)
                    for i, name in ipairs(fvAnimList) do
                        local a2 = fvSprite:getAnims()[name]
                        if i == fvAnimIdx then
                            love.graphics.setColor(1, 1, 0)
                        else
                            love.graphics.setColor(0.75, 0.75, 0.75)
                        end
                        love.graphics.print(string.format("  %s  [%d - %d]", name,
                            a2 and a2.start or 0, a2 and a2.stop or 0), 10, 145 + i * 20)
                    end

                    love.graphics.setColor(0.5, 0.5, 0.5)
                    love.graphics.print("← → frame   ↑ ↓ animacion   WASD ajustar offset   Backspace / Esc = volver", 10, 700)
                end
            elseif svMode == 4 then
                -- ── Editor de sprites de results ──────────────────────────────────
                -- Fondo: amarillo de results (H=on) o azul oscuro de editor (H=off)
                if reShowBg then
                    graphics.setColor(255/255, 204/255, 92/255)
                else
                    love.graphics.setColor(0.08, 0.08, 0.18)
                end
                love.graphics.rectangle("fill", 0, 0, 1280, 720)
                graphics.setColor(1, 1, 1)

                if rePhase == 0 then
                    -- Selector de variación
                    love.graphics.setColor(1, 0.85, 0.3)
                    love.graphics.print("RESULTS SPRITE EDITOR", 10, 10)
                    love.graphics.setColor(0.75, 0.75, 0.75)
                    love.graphics.print("Selecciona la variación y presiona Enter para cargar los sprites:", 10, 42)
                    for i, v in ipairs(reVariations) do
                        if i == reVarIdx then
                            love.graphics.setColor(1, 1, 0)
                            love.graphics.print("> " .. v, 40, 68 + i * 30)
                        else
                            love.graphics.setColor(0.5, 0.5, 0.5)
                            love.graphics.print("  " .. v, 40, 68 + i * 30)
                        end
                    end
                    love.graphics.setColor(0.38, 0.38, 0.38)
                    love.graphics.print("[↑↓] Seleccionar   [Enter] Cargar sprites   [Backspace/Esc] Volver", 10, 686)

                else
                    -- ── Fase 1: edición de sprites ────────────────────────────────
                    -- Dibujar todos los sprites
                    for i, o in ipairs(reObjects) do
                        if o.spr then
                            if i == reSelIdx then
                                love.graphics.setColor(1, 1, 1)
                            else
                                -- Sobre fondo amarillo se ve bien con alpha reducido
                                love.graphics.setColor(1, 1, 1, reShowBg and 0.70 or 0.30)
                            end
                            pcall(function() o.spr:draw() end)
                        end
                    end
                    love.graphics.setColor(1, 1, 1)

                    -- Marcadores INTRO (cruz cian) para sprites con posición de entrada diferente
                    for _, o in ipairs(reObjects) do
                        if o.introX and o.introY and
                           (o.introX ~= o.refX or o.introY ~= o.refY) then
                            local ix, iy = o.introX, o.introY
                            love.graphics.setColor(0, 0.9, 1, 0.75)
                            love.graphics.setLineWidth(1.5)
                            love.graphics.line(ix - 12, iy, ix + 12, iy)
                            love.graphics.line(ix, iy - 12, ix, iy + 12)
                            love.graphics.setColor(0, 0.9, 1, 0.9)
                            love.graphics.print("intro", ix + 5, iy - 15)
                        end
                    end
                    love.graphics.setLineWidth(1)

                    -- Bounding boxes y etiquetas de cada sprite
                    for i, o in ipairs(reObjects) do
                        local fw, fh = 0, 0
                        pcall(function()
                            fw = o.spr:getFrameWidth() * o.scale
                            fh = o.spr:getFrameHeight() * o.scale
                        end)
                        local labelY = fh > 0 and (o.y - 16) or (o.y - 16)
                        if i == reSelIdx then
                            -- Seleccionado: caja amarilla gruesa + etiqueta amarilla
                            love.graphics.setColor(1, 1, 0, 0.90)
                            love.graphics.setLineWidth(2)
                            if fw > 0 and fh > 0 then
                                love.graphics.rectangle("line", o.x, o.y, fw, fh)
                            end
                            love.graphics.setColor(1, 1, 0)
                            love.graphics.print("[" .. o.name .. "]", o.x + 4, labelY)
                        else
                            -- No seleccionado: caja tenue + nombre pequeño
                            love.graphics.setColor(0.85, 0.85, 0.25, 0.50)
                            love.graphics.setLineWidth(1)
                            if fw > 0 and fh > 0 then
                                love.graphics.rectangle("line", o.x, o.y, fw, fh)
                            end
                            love.graphics.setColor(0.9, 0.9, 0.4, 0.85)
                            love.graphics.print(o.name, o.x + 2, labelY)
                        end
                    end
                    love.graphics.setLineWidth(1)
                    love.graphics.setColor(1, 1, 1)

                    -- Panel izquierdo semitransparente
                    love.graphics.setColor(0, 0, 0, 0.82)
                    love.graphics.rectangle("fill", 0, 0, 378, 720)

                    local obj = reObjects[reSelIdx]
                    if obj then
                        local ly = 8
                        local function pr(text, r, g, b)
                            love.graphics.setColor(r or 1, g or 1, b or 1)
                            love.graphics.print(text, 6, ly)
                            ly = ly + 17
                        end

                        -- Cabecera: nombre y posición en lista
                        love.graphics.setColor(1, 0.9, 0.2)
                        love.graphics.print(string.format("[ %s ]  %d / %d  (%s)",
                            obj.name, reSelIdx, #reObjects, reVariations[reVarIdx]), 6, ly)
                        ly = ly + 22

                        -- Posición y escala actuales (editor)
                        pr(string.format("x:      %d", math.floor(obj.x + 0.5)))
                        pr(string.format("y:      %d", math.floor(obj.y + 0.5)))
                        pr(string.format("scale:  %.3f", obj.scale))
                        ly = ly + 3

                        -- Referencia de results.lua y diferencia
                        if obj.refX then
                            pr(string.format("ref:    x=%d  y=%d  s=%.3f",
                                obj.refX, obj.refY, obj.refScale), 0.50, 0.65, 1.0)
                            local dx = math.floor(obj.x + 0.5) - obj.refX
                            local dy = math.floor(obj.y + 0.5) - obj.refY
                            if dx ~= 0 or dy ~= 0 then
                                pr(string.format("Δref:   dx=%+d  dy=%+d", dx, dy), 1, 0.42, 0.42)
                            else
                                pr("Δref:   (sin cambios)", 0.38, 0.85, 0.38)
                            end
                        end
                        -- Posiciones intro vs loop si son distintas
                        if obj.introX and obj.introY and
                           (obj.introX ~= obj.refX or obj.introY ~= obj.refY) then
                            pr(string.format("intro:  x=%d  y=%d", obj.introX, obj.introY),
                               0.25, 0.92, 0.92)
                            pr(string.format("loop:   x=%d  y=%d", obj.refX, obj.refY),
                               0.25, 0.85, 0.55)
                        end
                        ly = ly + 5

                        -- Animación
                        if #obj.animList > 0 then
                            pr(string.format("Anim [%d/%d]: %s",
                                obj.animIdx, #obj.animList, obj.animList[obj.animIdx]), 0.45, 0.85, 1)
                        end

                        -- Frame y loop (si el sprite tiene frame data)
                        if obj.hasFrames then
                            local fd = nil
                            pcall(function() fd = obj.spr:getFrameData() end)
                            pr(string.format("Frame:  %d / %d", obj.curFrame, fd and #fd or 0), 0.75, 0.75, 1)
                            ly = ly + 4
                            pr(string.format("LoopStart:  %s", obj.loopStart and tostring(obj.loopStart) or "--"), 0.5, 1, 0.55)
                            pr(string.format("LoopEnd:    %s", obj.loopEnd   and tostring(obj.loopEnd)   or "--"), 0.5, 1, 0.55)
                            pr(string.format("LoopNombre: %s", obj.loopName ~= "" and obj.loopName or "--"), 0.5, 1, 0.55)
                        end

                        ly = ly + 9
                        pr("── Sprites ──────────────────────────────", 0.32, 0.32, 0.32)
                        for i, o in ipairs(reObjects) do
                            if i == reSelIdx then love.graphics.setColor(1, 1, 0)
                            else love.graphics.setColor(0.48, 0.48, 0.48) end
                            love.graphics.print(string.format("%s %s  x=%-4d y=%-4d s=%.2f",
                                i == reSelIdx and ">" or " ",
                                o.name,
                                math.floor(o.x+0.5), math.floor(o.y+0.5), o.scale), 6, ly)
                            ly = ly + 15
                        end

                        ly = ly + 7
                        pr("── Controles ────────────────────────────", 0.32, 0.32, 0.32)
                        love.graphics.setColor(0.48, 0.48, 0.48)
                        local ctrl = {
                            "Clic izq         → seleccionar sprite",
                            "Clic izq + drag  → mover sprite con mouse",
                            "Tab / Shift+Tab  → sprite anterior/sig.",
                            "Scroll ratón     → cambiar sprite",
                            "WASD             → mover  (Shift = ×10)",
                            "Q / E            → escala (Shift = ±0.01)",
                            "← →              → navegar frame",
                            ", / .            → animación anterior/sig.",
                            "F1               → marcar LoopStart",
                            "F2               → marcar LoopEnd",
                            "H                → fondo amarillo results on/off",
                            "Enter            → imprimir config en consola",
                            "Backspace / Esc  → volver",
                        }
                        for _, c in ipairs(ctrl) do
                            love.graphics.print(c, 6, ly)
                            ly = ly + 14
                        end
                    end
                    love.graphics.setColor(1, 1, 1)
                end
            else
                -- svMode == 1: navegador de archivos con scroll
                local rowH     = 22
                local maxVisible = math.floor(700 / rowH)
                love.graphics.setColor(0.6, 0.6, 0.6)
                love.graphics.print(curDir .. "  (" .. #dirTable .. " items)", 0, 0)
                for i = 1, #dirTable do
                    local row = i - 1 - listScroll
                    if row >= 0 and row < maxVisible then
                        if i == selection then
                            graphics.setColor(1, 1, 0)
                        elseif love.filesystem.getInfo(curDir .. "/" .. dirTable[i]).type == "directory" then
                            graphics.setColor(1, 0, 1)
                        else
                            graphics.setColor(1, 1, 1)
                        end
                        love.graphics.print(dirTable[i], 0, 20 + row * rowH)
                    end
                end
                graphics.setColor(1, 1, 1)
            end
        else -- Menú estándar con texto bonito
            -- Dibujar título
            if titleText then titleText:draw() end

            -- Dibujar opciones con color según selección
            for i, textObj in ipairs(menuOptionsText) do
                -- Solo dibujar la opción si está visible en la pantalla (cercana al rango actual)
                if math.abs(i - lerpSelected) < 5 then
                    if i == selection then
                        graphics.setColor(1, 1, 0) -- amarillo
                    else
                        graphics.setColor(1, 1, 1) -- blanco
                    end
                    textObj:draw()
                end
            end
            graphics.setColor(1, 1, 1) -- restaurar color

            -- Texto de ayuda (en la parte inferior izquierda)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Press Esc to exit at any time", 20, 720 - 30)
        end
    end,

    -- ── Interacción con el mouse (svMode == 4) ──────────────────────────────────

    mousepressed = function(self, mx, my, button)
        if menus[menuID][1] ~= 2 or svMode ~= 4 or rePhase ~= 1 then return end
        if button == 1 and mx > 380 then   -- fuera del panel de información
            -- Buscar el sprite bajo el cursor (orden inverso = el más visible primero)
            for i = #reObjects, 1, -1 do
                local o = reObjects[i]
                local fw, fh = 80, 80
                pcall(function()
                    fw = o.spr:getFrameWidth() * o.scale
                    fh = o.spr:getFrameHeight() * o.scale
                end)
                if mx >= o.x and mx <= o.x + fw and my >= o.y and my <= o.y + fh then
                    reSelIdx   = i
                    reDragging = true
                    reDragOffX = mx - o.x
                    reDragOffY = my - o.y
                    break
                end
            end
        end
    end,

    mousemoved = function(self, mx, my, dx, dy)
        if reDragging and rePhase == 1 and #reObjects > 0 then
            local obj = reObjects[reSelIdx]
            if obj then
                obj.x     = mx - reDragOffX
                obj.y     = my - reDragOffY
                obj.spr.x = obj.x
                obj.spr.y = obj.y
            end
        end
    end,

    mousereleased = function(self, mx, my, button)
        if button == 1 then
            reDragging = false
        end
    end,
}