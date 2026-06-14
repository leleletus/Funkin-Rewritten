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

local highscores = require("highscores")

local data = require("data")
local freeplay = {}

-- Dependencias
local Conductor = require("modules.conductor")
local atlasText = require("modules.atlas_text")
local iconsSprite = require("sprites/icons")
local conductor

local pixelCharacters = {
    "boyfriend (pixel)",
    "senpai",
    "senpai-angry",
    "spirit"
}

-- Lista de canciones (se llena en loadSongs)
local songs = {}
local curSelected = 1
local curDifficulty = 2  -- 1=easy, 2=normal, 3=hard
local difficulties = {"easy", "normal", "hard"}
local difficultySuffixes = {"-easy", "", "-hard"}

-- Elementos gráficos
local bg
local grpSongs = {}
local iconArray = {}
local scoreText, diffText, scoreBG
local bottomBG, bottomText, missingTextBG, missingText
local player = { playingMusic = false, playing = false, curTime = 0 }

-- Variables de estado
local intendedScore = 0
local intendedRating = 0
local lerpScore = 0
local lerpRating = 0
local holdTime = 0
local lerpSelected = 1
local drawDistance = 4
local targetColor = {0, 0, 0}      -- Color al que queremos llegar
local currentColorLerp = {0, 0, 0}  -- Color actual (se irá acercando suavemente)

-- Sonidos
local selectSound = love.audio.newSource("sounds/menu/select.ogg", "static")
local cancelSound = love.audio.newSource("sounds/menu/cancel.ogg", "static")
local confirmSound = love.audio.newSource("sounds/menu/confirm.ogg", "static")

-- Variables para la previsualización de canciones
local previewSource = nil          -- fuente de audio de la instrumental
local previewFadeTimer = nil       -- timer para cancelar fades si es necesario

-- Función auxiliar para hacer un fade de volumen en un Source usando func_tween
local function tweenVolume(source, targetVol, duration, callback)
    if not source then return nil end
    return Timer.func_tween(duration, source, {volume = targetVol}, 'linear', callback, {
        volume = {source.setVolume, source.getVolume}
    })
end

-- Cargar canciones desde las semanas (solo NO mods)
local function loadSongs()
    songs = {}
    for weekIndex, week in ipairs(data.weeks) do
        -- Incluir solo si la semana NO es mod (mod ~= true)
        if week.mod ~= true then
            for songIndex, songData in ipairs(week.songs) do
                local songName, songCharacter, songColor
                if type(songData) == "string" then
                    songName = songData
                    songCharacter = week.character
                    songColor = week.color
                else
                    songName = songData.name
                    songCharacter = songData.character or week.character
                    songColor = songData.color or week.color
                end
                local fileSafeName = songName:gsub(" ", "-"):lower()
                table.insert(songs, {
                    name = songName,
                    fileSafeName = fileSafeName,
                    weekId = week.id,
                    songIndex = songIndex,
                    character = songCharacter,
                    color = songColor
                })
            end
        end
    end
end

-- Detener la previsualización y restaurar la música del menú
local function stopPreview()
    if previewFadeTimer then
        Timer.cancel(previewFadeTimer)
        previewFadeTimer = nil
    end
    if previewSource then
        previewSource:stop()
        previewSource = nil
    end
    player.playingMusic = false
    -- Asegurar que la música del menú esté al volumen adecuado
    if _G.music then
        _G.music:setVolume(1)
    end
end

-- Actualizar textos de puntuación y dificultad
local function updateTexts()
    local song = songs[curSelected]
    local keyHyphen = song.weekId .. "_" .. song.fileSafeName
    local keySpace = song.weekId .. "_" .. song.name
    local score = highscores.getFreeplayScore(keyHyphen, difficulties[curDifficulty])
    if score == 0 then
        score = highscores.getFreeplayScore(keySpace, difficulties[curDifficulty])
    end
    intendedScore = score

    local ratingPercent = intendedRating * 100
    scoreText.text = "PERSONAL BEST: " .. intendedScore .. " (" .. string.format("%.2f", ratingPercent) .. "%)"
    
    -- REEMPLAZO: Usar 1280 en lugar de love.graphics.getWidth()
    scoreText.x = 1280 - scoreText:getWidth() - 6
    
    -- Actualizar fondo del score
    scoreBG.scaleX = 1280 - scoreText.x + 360
    scoreBG.x = 1280 - (scoreBG.scaleX / 2)
    
    -- Texto de dificultad
    local diffName = difficulties[curDifficulty]:upper()
    diffText.text = (#difficulties > 1) and ("< " .. diffName .. " >") or diffName
    
    -- Centrar diffText debajo de scoreText
    diffText.x = scoreText.x + (scoreText:getWidth() - diffText:getWidth()) / 2
    diffText.y = scoreText.y + love.graphics.getFont():getHeight() + 5
end

-- Cambiar selección de canción
local function changeSelection(change)
    curSelected = curSelected + change
    if curSelected < 1 then curSelected = #songs end
    if curSelected > #songs then curSelected = 1 end
    audio.playSound(selectSound)

    -- Cambiar color de fondo instantáneamente
    targetColor = songs[curSelected].color

    -- Actualizar alphas
    for i, item in ipairs(grpSongs) do
        item.alpha = (i == curSelected) and 1 or 0.6
    end
    for i, icon in ipairs(iconArray) do
        icon.alpha = (i == curSelected) and 1 or 0.6
    end

    updateTexts()
end

-- Cambiar dificultad
local function changeDifficulty(change)
    curDifficulty = curDifficulty + change
    if curDifficulty < 1 then curDifficulty = #difficulties end
    if curDifficulty > #difficulties then curDifficulty = 1 end
    audio.playSound(selectSound)
    updateTexts()
end

local function playSong()
    audio.playSound(confirmSound)
    local song = songs[curSelected]
    local songAppend = difficultySuffixes[curDifficulty]

    _G.storyMode = false
    _G.currentWeekId = song.weekId
    _G.currentSongName = song.fileSafeName
    _G.currentSongDisplayName = song.name
    _G.currentDifficulty = difficulties[curDifficulty]

    -- Detener preview si está sonando
    stopPreview()

    -- Usar el nuevo sistema de carga
    local wl = require("modules.weekLoader")
    wl.startFromMenu(song.weekId, song.songIndex, songAppend, false, song.fileSafeName)
end

-- Crear un elemento de texto usando atlasText (bold)
local function createAlphabet(text, y)
    local obj = atlasText.new(90, y, text, "bold")
    obj.alpha = 1
    obj.visible = true
    return obj
end

-- Crear un icono usando el sprite de iconos
local function createIcon(character)
    local icon = iconsSprite.create()
    icon:animate(character, true)
    -- Determinar escala según si es pixel o no
    local isPixel = false
    for _, pc in ipairs(pixelCharacters) do
        if pc == character then
            isPixel = true
            break
        end
    end
    if isPixel then
        icon.sizeX = 3.3
        icon.sizeY = 3.3
    else
        icon.sizeX = 0.7
        icon.sizeY = 0.7
    end
    icon.alpha = 1
    icon.visible = true
    return icon
end

-- Función para posicionar correctamente los textos e iconos
local function repositionItems()
    local min = math.max(1, math.floor(lerpSelected - drawDistance))
    local max = math.min(#songs, math.ceil(lerpSelected + drawDistance))

    for i = min, max do
        local item = grpSongs[i]
        -- REEMPLAZO: Usar 720 en lugar de love.graphics.getHeight()
        local targetY = 720 * 0.444 + (i - lerpSelected) * 720 * 0.167
        item:setPosition(90, targetY)
        item.visible = true

        local icon = iconArray[i]
        icon.visible = true
        icon.x = 90 + item:getWidth() + 40
        icon.y = targetY
    end

    for i = 1, #grpSongs do
        if i < min or i > max then
            grpSongs[i].visible = false
            iconArray[i].visible = false
        end
    end
end

-- Métodos del estado
function freeplay.enter(self, previous)
    loadSongs()
    curSelected = 1
    curDifficulty = 2
    lerpSelected = 1
    targetColor = songs[1].color
    currentColorLerp = {targetColor[1], targetColor[2], targetColor[3]}

    -- Fondo: usar 1280 y 720
    bg = graphics.newImage(love.graphics.newImage(graphics.imagePath("menuDesat")))
    bg.x = 1280 / 2
    bg.y = 720 / 2
    bg.originX = 0.5
    bg.originY = 0.5

    -- Crear lista de canciones e iconos
    grpSongs = {}
    iconArray = {}
    for i, song in ipairs(songs) do
        -- REEMPLAZO: Usar 720
        local songText = createAlphabet(song.name, 720 * 0.444 + (i-1) * 720 * 0.167)
        table.insert(grpSongs, songText)

        local icon = createIcon(song.character)
        table.insert(iconArray, icon)
    end

    repositionItems()

    -- Texto de puntuación
    scoreText = {
        text = "",
        x = 0, y = 720 * 0.007,
        getWidth = function(self) return love.graphics.getFont():getWidth(self.text) end,
        draw = function(self)
            graphics.setColor(1,1,1)
            love.graphics.print(self.text, self.x, self.y)
        end
    }
    scoreBG = {
        x = 0, y = 0, scaleX = 1,
        draw = function(self)
            graphics.setColor(0,0,0,0.6)
            love.graphics.rectangle("fill", self.x, self.y, self.scaleX, 66)
        end
    }
    diffText = {
        text = "",
        x = 0, y = 720 * 0.057,
        getWidth = function(self) return love.graphics.getFont():getWidth(self.text) end,
        draw = function(self)
            graphics.setColor(1,1,1)
            love.graphics.print(self.text, self.x, self.y)
        end
    }

    -- Fondo inferior
    bottomBG = {
        y = 720 - 26,
        draw = function(self)
            graphics.setColor(0,0,0,0.6)
            love.graphics.rectangle("fill", 0, self.y, 1280, 26)
        end
    }
    bottomText = {
        text = "",
        y = 720 - 22,
        draw = function(self)
            graphics.setColor(1,1,1)
            love.graphics.printf(self.text, 0, self.y, 1280, "center")
        end
    }

    -- Detectar plataforma
    if love.system.getOS() == "NX" then
        bottomText.text = "Press Y to listen to the Song."
    else
        bottomText.text = "Press SPACE to listen to the Song."
    end

    -- Mensaje de error
    missingTextBG = {
        visible = false,
        draw = function(self)
            if not self.visible then return end
            graphics.setColor(0,0,0,0.6)
            love.graphics.rectangle("fill", 0, 0, 1280, 720)
        end
    }
    missingText = {
        text = "",
        visible = false,
        draw = function(self)
            if not self.visible then return end
            graphics.setColor(1,1,1)
            love.graphics.printf(self.text, 50, 720/2 - 50, 1280-100, "center")
        end
    }

    -- Conductor (para ritmo, opcional)
    conductor = Conductor.new(102)

    -- Asegurar música del menú
    if not music or not music:isPlaying() then
        music = love.audio.newSource("music/menu/menu.ogg", "stream")
        music:setLooping(true)
        music:play()
        _G.music = music
    end
    _G.music:setVolume(1)  -- volumen inicial

    updateTexts()
    graphics.setFade(0)
    graphics.fadeIn(0.5)
end

function freeplay.update(self, dt)
    if music and music:isPlaying() then
        conductor:update(dt, music:tell() * 1000)
    end

    -- Interpolación de puntuación (simple)
    lerpScore = lerpScore + (intendedScore - lerpScore) * 0.1
    lerpRating = lerpRating + (intendedRating - lerpRating) * 0.1

    if graphics.isFading() then return end

    -- Si la previsualización terminó sola, restaurar menú
    if player.playingMusic and previewSource and not previewSource:isPlaying() then
        stopPreview()
    end

    -- Controles
    if not player.playingMusic then
        -- Navegación arriba/abajo
        if input:pressed("up") then
            changeSelection(-1)
            holdTime = 0
        elseif input:pressed("down") then
            changeSelection(1)
            holdTime = 0
        end

        -- Mantener pulsado
        if input:down("up") or input:down("down") then
            holdTime = holdTime + dt
            if holdTime > 0.5 then
                local speed = math.floor((holdTime - 0.5) * 10) + 1
                changeSelection(input:down("up") and -speed or speed)
            end
        else
            holdTime = 0
        end

        -- Cambiar dificultad izquierda/derecha
        if input:pressed("left") then
            changeDifficulty(-1)
        elseif input:pressed("right") then
            changeDifficulty(1)
        end

        -- Home / End con PageUp/PageDown
        if input:pressed("pageup") then
            curSelected = 1
            changeSelection(0)
        elseif input:pressed("pagedown") then
            curSelected = #songs
            changeSelection(0)
        end
    end

    -- Tecla de retroceso
    if input:pressed("back") then
        if player.playingMusic then
            -- Detener preview y restaurar menú
            stopPreview()
        else
            audio.playSound(cancelSound)
            graphics.fadeOut(0.5, function()
                Gamestate.switch(require("states.menu"))
            end)
        end
    end

    -- Confirmar (jugar)
    if input:pressed("confirm") and not player.playingMusic then
        playSong()
    end

    -- Espacio (preview)
    if input:pressed("space") then
        if player.playingMusic then
            -- Ya está sonando la preview → la detenemos
            stopPreview()
        else
            -- Iniciar preview de la canción seleccionada
            local song = songs[curSelected]
            local weekId = song.weekId
            -- Construir ruta de la instrumental (ej. music/week1/bopeebo-inst.ogg)
            local instPath = string.format("music/%s/%s-inst.ogg", weekId, song.fileSafeName)  -- usar nombre normalizado
            
            if love.filesystem.getInfo(instPath) then
                -- Cancelar cualquier fade previo
                if previewFadeTimer then
                    Timer.cancel(previewFadeTimer)
                    previewFadeTimer = nil
                end

                -- Crear fuente de audio para la instrumental
                previewSource = love.audio.newSource(instPath, "stream")
                previewSource:setVolume(0)

                -- Bajar volumen del menú a 0 usando func_tween
                previewFadeTimer = tweenVolume(_G.music, 0, 0.5, function()
                    -- Una vez el menú está en silencio, reproducir preview y subir volumen
                    previewSource:play()
                    previewFadeTimer = tweenVolume(previewSource, 1, 0.5, function()
                        previewFadeTimer = nil
                    end)
                    player.playingMusic = true
                end)
            else
                print("Preview no disponible: " .. instPath)
                -- Opcional: mostrar un mensaje en pantalla
            end
        end
    end

    -- Actualizar textos y iconos (para animaciones)
    for _, item in ipairs(grpSongs) do
        item:update(dt)
    end
    for _, icon in ipairs(iconArray) do
        icon:update(dt)
    end

    -- Interpolación de la lista (efecto de desplazamiento)
    lerpSelected = lerpSelected + (curSelected - lerpSelected) * 0.1
    repositionItems()

    local lerpSpeed = 0.05
    currentColorLerp[1] = currentColorLerp[1] + (targetColor[1] - currentColorLerp[1]) * lerpSpeed
    currentColorLerp[2] = currentColorLerp[2] + (targetColor[2] - currentColorLerp[2]) * lerpSpeed
    currentColorLerp[3] = currentColorLerp[3] + (targetColor[3] - currentColorLerp[3]) * lerpSpeed
end

function freeplay.draw(self)
    -- Dibujar fondo con color
    graphics.setColor(currentColorLerp[1]/255, currentColorLerp[2]/255, currentColorLerp[3]/255)
    bg:draw()  -- Ya no necesita parámetros
    graphics.setColor(1,1,1)

    -- Dibujar lista de canciones con transparencia
    for i, item in ipairs(grpSongs) do
        if item.visible then
            graphics.setColor(1, 1, 1, item.alpha)
            item:draw()
        end
    end
    -- Dibujar iconos con transparencia
    for i, icon in ipairs(iconArray) do
        if icon.visible then
            graphics.setColor(1, 1, 1, icon.alpha)
            icon:draw()
        end
    end
    graphics.setColor(1,1,1)

    -- UI superior
    scoreBG:draw()
    scoreText:draw()
    diffText:draw()

    -- UI inferior
    bottomBG:draw()
    bottomText:draw()

    -- Mensajes de error
    missingTextBG:draw()
    missingText:draw()
end

function freeplay.resume(self)
    -- Al reanudar, recargamos los datos actualizados
    refresh()
end

function freeplay.leave(self)
    -- Limpiar referencias y detener preview si está activa
    stopPreview()
    grpSongs = {}
    iconArray = {}
    bg = nil
end

return freeplay