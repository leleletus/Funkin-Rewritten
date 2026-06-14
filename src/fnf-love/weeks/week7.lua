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

local song, difficulty

-- Elementos estáticos
local sky, clouds, mountains, buildings, ruins, ground

-- Elementos animados
local smokeLeft, smokeRight, tankWatchtower, tankGroundAnim
local foregroundSprites = {}

-- Soldados muertos de Stress
local killedTankmen = {}
local tankmanKilledClass

-- =============================================================
-- SISTEMA PICOSPEAKER
--
-- Las notas de Pico se cargan desde charts/week7/stress-pico.lua
-- Cada nota tiene dirección: 0 = izquierda, 3 = derecha.
-- Según el lado, se elige aleatoriamente una de las dos variantes:
--   Derecha → "Pico shoot 1"/"Pico shoot 2" y su loop correspondiente
--   Izquierda → "Pico shoot 3"/"Pico shoot 4" y su loop
--
-- Los soldados aparecen con un tiempo de adelanto (leadTime) antes del disparo,
-- corren hacia el centro y mueren exactamente cuando Pico dispara.
-- =============================================================
local picoQueue      = {}
local picoIndex      = 1
local currentLoopTimer = nil -- para cancelar timer anterior

-- Constante de tiempo de adelanto para los soldados (milisegundos)
local TANKMAN_LEAD_TIME = 200  -- .2 segundos antes del disparo

-- Variantes por lado
local PICO_SHOOT_VARIANTS = {
    [0] = {"Pico shoot 3", "Pico shoot 4"},  -- izquierda
    [3] = {"Pico shoot 1", "Pico shoot 2"},  -- derecha
}
local PICO_LOOP_VARIANTS = {
    [0] = {"Pico shootloop 3", "Pico shootloop 4"},
    [3] = {"Pico shootloop 1", "Pico shootloop 2"},
}

-- Función auxiliar para cargar la novia según la canción
local function loadGirlfriend(songNum)
    if songNum == 3 then
        return love.filesystem.load("sprites/picoSpeaker.lua")()
    else
        return love.filesystem.load("sprites/GF_ass_sets_TA-Export.lua")()
    end
end

-- Spawnea un tankman muerto que aparecerá ANTES del disparo y morirá en deathTime
local function scheduleTankmanSpawn(dir, shotTime)
    if not tankmanKilledClass then return end
    -- Aplicar probabilidad del 25% (igual que antes)
    if math.random() >= 0.25 then return end

    local leadTime = TANKMAN_LEAD_TIME
    local spawnTime = shotTime - leadTime
    if spawnTime < 0 then spawnTime = 0 end  -- no antes del inicio

    local delay = spawnTime / 1000  -- segundos desde ahora
    if delay < 0 then delay = 0 end

    Timer.after(delay, function()
        local killed = tankmanKilledClass()
        if not killed then return end

        -- Posición y dirección según el lado del disparo (dir)
        if dir == 0 then  -- izquierda
            killed.x, killed.y = -1400, 0
            killed.speed = 320
            killed.sizeX = -1
        else  -- derecha
            killed.x, killed.y = 700, 0
            killed.speed = -320
            killed.sizeX = 1
        end

        killed:animate("running", true)
        killed.state      = "running"
        killed.deathTime  = shotTime  -- momento en que morirá (ms)
        killed.shootTimer = nil       -- ya no se usa

        table.insert(killedTankmen, killed)
    end)
end

-- Procesa la cola de disparos y anima a picoSpeaker en sincronía
local function updatePicoQueue(musicTimeMs)
    while picoIndex <= #picoQueue do
        local ev = picoQueue[picoIndex]
        if musicTimeMs >= ev.t then
            local dir = ev.dir
            -- Asegurar que la dirección sea válida (solo 0 o 3)
            local variantsShoot = PICO_SHOOT_VARIANTS[dir]
            local variantsLoop  = PICO_LOOP_VARIANTS[dir]
            if not variantsShoot or not variantsLoop then
                print("WARN: Dirección inválida en nota de Pico: " .. tostring(dir) .. " en t=" .. ev.t .. ". Usando derecha.")
                variantsShoot = PICO_SHOOT_VARIANTS[3]
                variantsLoop  = PICO_LOOP_VARIANTS[3]
                dir = 3
            end

            -- Elegir aleatoriamente entre las dos variantes
            local idx = math.random(1, 2)
            local shootAnim = variantsShoot[idx]
            local loopAnim  = variantsLoop[idx]

            -- Cancelar cualquier timer pendiente para evitar que un loop anterior se active después
            if currentLoopTimer then
                Timer.cancel(currentLoopTimer)
                currentLoopTimer = nil
            end

            -- Reproducir el disparo
            girlfriend:animate(shootAnim, false)

            -- Obtener duración de la animación de disparo
            if girlfriend.anims and girlfriend.anims[shootAnim] then
                local animDef  = girlfriend.anims[shootAnim]
                local frames   = animDef.stop - animDef.start + 1
                local fps      = animDef.speed or 24
                local duration = frames / fps
                -- Programar el loop al finalizar el disparo
                currentLoopTimer = Timer.after(duration, function()
                    if girlfriend then
                        girlfriend:animate(loopAnim, true)
                        currentLoopTimer = nil
                    end
                end)
            else
                girlfriend:animate(loopAnim, true)
            end

            picoIndex = picoIndex + 1
        else
            break
        end
    end
end

return {
    enter = function(self, from, songNum, songAppend, isStoryMode, songName)
        weeks.enter(self, songNum, songAppend, isStoryMode, songName)
        self:loadStage(songNum, songAppend)
        self:load()
    end,

    load = function(self)
        weeks:load()

        girlfriend = loadGirlfriend(song)
        if song == 3 then
            girlfriend.x = -635
            girlfriend.y = -105
            customGirlfriendIdle = true
        else
            girlfriend.x, girlfriend.y = -435, -65
            customGirlfriendIdle = false
        end

        if song == 3 then
            inst   = love.audio.newSource("music/week7/stress-inst.ogg",   "stream")
            voices = love.audio.newSource("music/week7/stress-voices.ogg", "stream")

            local ok, chunk = pcall(love.filesystem.load, "sprites/week7/tankmanKilled.lua")
            if ok and chunk then
                tankmanKilledClass = chunk()
            else
                tankmanKilledClass = nil
                print("WARN week7: no se pudo cargar tankmanKilled.lua")
            end
            killedTankmen = {}

            -- Cargar las notas de Pico desde el archivo dedicado
            local ok, picoNotes = pcall(love.filesystem.load, "charts/week7/stress-pico.lua")
            if ok and picoNotes then
                picoQueue = picoNotes()  -- devuelve la tabla de notas
                print("week7: picoQueue con " .. #picoQueue .. " disparos")
            else
                picoQueue = {}
                print("WARN week7: no se pudo cargar stress-pico.lua")
            end

            picoIndex      = 1
            currentLoopTimer = nil

            -- Programar la aparición de soldados para cada nota (con adelanto)
            for _, note in ipairs(picoQueue) do
                scheduleTankmanSpawn(note.dir, note.t)
            end

            -- Arrancar en el loop neutro hasta que llegue el primer disparo del chart
            girlfriend:animate("Pico shootloop 1", true)

        elseif song == 2 then
            inst   = love.audio.newSource("music/week7/guns-inst.ogg",   "stream")
            voices = love.audio.newSource("music/week7/guns-voices.ogg", "stream")
        else
            inst   = love.audio.newSource("music/week7/ugh-inst.ogg",   "stream")
            voices = love.audio.newSource("music/week7/ugh-voices.ogg", "stream")
        end

        self:initUI()
        weeks:setupCountdown()
    end,

    initUI = function(self)
        weeks:initUI()

        if song == 3 then
            weeks:generateNotes(love.filesystem.load("charts/week7/stress" .. difficulty .. ".lua")())
        elseif song == 2 then
            weeks:generateNotes(love.filesystem.load("charts/week7/guns" .. difficulty .. ".lua")())
        else
            weeks:generateNotes(love.filesystem.load("charts/week7/ugh" .. difficulty .. ".lua")())
        end
    end,

    update = function(self, dt)
        weeks:update(dt)

        if smokeLeft      then smokeLeft:update(dt)      end
        if smokeRight     then smokeRight:update(dt)     end
        if tankWatchtower then tankWatchtower:update(dt) end
        if tankGroundAnim then tankGroundAnim:update(dt) end
        for _, spr in ipairs(foregroundSprites) do
            if spr then spr:update(dt) end
        end

        if musicThres ~= oldMusicThres and math.fmod(absMusicTime, 60000 / bpm) < 100 then
            tankWatchtower:animate("anim", false)
            for _, spr in ipairs(foregroundSprites) do
                spr:animate("anim", false)
            end
        end

        if song == 3 then
            -- Actualizar cola de picoSpeaker (animaciones)
            if not (countingDown or graphics.isFading()) then
                updatePicoQueue(musicTime)
            end

            -- Actualizar tankmen muertos: mover mientras corren y matarlos en el momento exacto
            for i = #killedTankmen, 1, -1 do
                local k = killedTankmen[i]
                k:update(dt)

                if k.state == "running" then
                    -- Movimiento
                    k.x = k.x + k.speed * dt
                    -- Comprobar si ya es hora de morir
                    if musicTime >= k.deathTime then
                        local shot = math.random(2) == 1 and "shot1" or "shot2"
                        k:animate(shot, false)
                        k.state = "shooting"
                    end
                elseif k.state == "shooting" then
                    if k:isAnimFinished() then
                        table.remove(killedTankmen, i)
                    end
                end
            end
        end

        if not (countingDown or graphics.isFading()) and weeks.songEnded then
            if _G.storyMode and song < 3 then
                song = song + 1
                _G.currentSongIndex = song
                _G.currentSongName  = _G.weekSongs[song]
                self:load()
            end
        end

        weeks:updateUI(dt)
    end,

    draw = function(self)
        love.graphics.push()
            love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
            love.graphics.scale(cam.sizeX, cam.sizeY)

            love.graphics.push()
                love.graphics.translate(cam.x * 0.5, cam.y * 0.5)
                sky:draw()
                clouds:draw()
                mountains:draw()
                buildings:draw()
            love.graphics.pop()

            love.graphics.push()
                love.graphics.translate(cam.x * 0.9, cam.y * 0.9)
                ruins:draw()
                smokeLeft:draw()
                smokeRight:draw()
                tankWatchtower:draw()
            love.graphics.pop()

            love.graphics.push()
                love.graphics.translate(cam.x, cam.y)
                tankGroundAnim:draw()
                ground:draw()

                if song == 3 then
                    for _, k in ipairs(killedTankmen) do
                        k:draw()
                    end
                end

                girlfriend:draw()
                enemy:draw()
                boyfriend:draw()
            love.graphics.pop()

            love.graphics.push()
                love.graphics.translate(cam.x * 1.1, cam.y * 1.1)
                for _, spr in ipairs(foregroundSprites) do
                    spr:draw()
                end
            love.graphics.pop()

            weeks:drawRating(0.9)
        love.graphics.pop()

        weeks:drawUI()
    end,

	loadStage = function(self, songNum, songAppend)
		song = songNum
		difficulty = songAppend

		sky = graphics.newImage(love.graphics.newImage(graphics.imagePath("week7/tankSky")))
		sky.x, sky.y = -250, -300
		clouds = graphics.newImage(love.graphics.newImage(graphics.imagePath("week7/tankClouds")))
		clouds.x, clouds.y = -250, 0
		mountains = graphics.newImage(love.graphics.newImage(graphics.imagePath("week7/tankMountains")))
		mountains.x, mountains.y = -250, -10
		mountains.sizeX, mountains.sizeY = 1.2, 1.2
		buildings = graphics.newImage(love.graphics.newImage(graphics.imagePath("week7/tankBuildings")))
		buildings.x, buildings.y = -365, -80
		buildings.sizeX, buildings.sizeY = 1.1, 1.1
		ruins = graphics.newImage(love.graphics.newImage(graphics.imagePath("week7/tankRuins")))
		ruins.x, ruins.y = -365, -80
		ruins.sizeX, ruins.sizeY = 1.1, 1.1
		ground = graphics.newImage(love.graphics.newImage(graphics.imagePath("week7/tankGround")))
		ground.x, ground.y = -420, -50
		ground.sizeX, ground.sizeY = 1.15, 1.15
		smokeLeft = love.filesystem.load("sprites/week7/smokeLeft.lua")()
		smokeLeft.x, smokeLeft.y = -1100, -150
		smokeLeft:animate("anim", true)
		smokeRight = love.filesystem.load("sprites/week7/smokeRight.lua")()
		smokeRight.x, smokeRight.y = 550, -100
		smokeRight:animate("anim", true)
		tankWatchtower = love.filesystem.load("sprites/week7/tankWatchtower.lua")()
		tankWatchtower.x, tankWatchtower.y = -920, -50
		tankGroundAnim = love.filesystem.load("sprites/week7/tankRolling.lua")()
		tankGroundAnim.x, tankGroundAnim.y = -930, -50
		tankGroundAnim:animate("anim", true)
		foregroundSprites[1] = love.filesystem.load("sprites/week7/tank0.lua")()
		foregroundSprites[1].x, foregroundSprites[1].y = -1400, 300
		foregroundSprites[2] = love.filesystem.load("sprites/week7/tank1.lua")()
		foregroundSprites[2].x, foregroundSprites[2].y = -1100, 450
		foregroundSprites[3] = love.filesystem.load("sprites/week7/tank2.lua")()
		foregroundSprites[3].x, foregroundSprites[3].y = -700, 400
		foregroundSprites[4] = love.filesystem.load("sprites/week7/tank3.lua")()
		foregroundSprites[4].x, foregroundSprites[4].y = -200, 435
		foregroundSprites[5] = love.filesystem.load("sprites/week7/tank4.lua")()
		foregroundSprites[5].x, foregroundSprites[5].y = 200, 400
		foregroundSprites[6] = love.filesystem.load("sprites/week7/tank5.lua")()
		foregroundSprites[6].x, foregroundSprites[6].y = 500, 300

		enemy = love.filesystem.load("sprites/week7/tankman.lua")()
		enemy.x, enemy.y = -810, 90
		enemy.sizeX = -1
		boyfriend.x, boyfriend.y = -80, 120

		local function loadGF(sn)
			if sn == 3 then return love.filesystem.load("sprites/picoSpeaker.lua")()
			else return love.filesystem.load("sprites/GF_ass_sets_TA-Export.lua")() end
		end
		girlfriend = loadGF(songNum)
		if songNum == 3 then girlfriend.x, girlfriend.y = -635, -105
		else girlfriend.x, girlfriend.y = -435, -65 end

		enemyIcon:animate("tankman", false)
		camScale.x, camScale.y = 0.9, 0.9
	end,


    leave = function(self)
        sky               = nil
        clouds            = nil
        mountains         = nil
        buildings         = nil
        ruins             = nil
        ground            = nil
        smokeLeft         = nil
        smokeRight        = nil
        tankWatchtower    = nil
        tankGroundAnim    = nil
        foregroundSprites = {}
        enemy             = nil
        killedTankmen     = {}
        tankmanKilledClass   = nil
        picoQueue            = {}
        picoIndex            = 1
        if currentLoopTimer then
            Timer.cancel(currentLoopTimer)
            currentLoopTimer = nil
        end
        customGirlfriendIdle = false
        weeks:leave()
    end
}