--[[----------------------------------------------------------------------------
...
------------------------------------------------------------------------------]]

local fromState
local currentBoyfriend  -- sprite que se está usando para la animación de muerte
local musicPath
local musicEndPath
local boyfriendPosX, boyfriendPosY  -- para recordar la posición original si es necesario

return {
    enter = function(self, from)
        fromState = from

        -- Detener música de la canción
        if inst then inst:stop() end
        voices:stop()

        audio.playSound(sounds["death"])

        -- Elegir rutas de música según el modo pixel
        if _G.isPixelWeek then
            musicPath = "music/pixel/game-over.ogg"
            musicEndPath = "music/pixel/game-over-end.ogg"
        else
            musicPath = "music/game-over.ogg"
            musicEndPath = "music/game-over-end.ogg"
        end

        -- Obtener el sprite correcto para la muerte
        if _G.isPixelWeek then
            -- En semana pixel, usar el sprite de muerte específico
            currentBoyfriend = love.filesystem.load("sprites/pixel/boyfriend-dead.lua")()
            -- Escalarlo al mismo tamaño que el boyfriend pixel (6.5)
            currentBoyfriend.sizeX, currentBoyfriend.sizeY = 6.5, 6.5
            -- Usar la misma posición que tenía el boyfriend vivo (de la variable global)
            if boyfriend then
                currentBoyfriend.x, currentBoyfriend.y = boyfriend.x, boyfriend.y
            else
                -- Fallback a la posición típica de semana 6
                currentBoyfriend.x, currentBoyfriend.y = 50 * 6.5, 30 * 6.5
            end
        else
            -- Semana normal: usar el sprite de boyfriend normal (que ya está en _G.boyfriend o fakeBoyfriend)
            currentBoyfriend = fakeBoyfriend or _G.boyfriend
        end

        if not currentBoyfriend then
            -- Fallback extremo: un objeto dummy que no haga nada (evita crashes)
            currentBoyfriend = { animate = function() end, update = function() end, draw = function() end }
        end

        currentBoyfriend:animate("dies", false)

        Timer.clear()

        Timer.tween(
            2,
            cam,
            {x = -currentBoyfriend.x, y = -currentBoyfriend.y, sizeX = camScale.x, sizeY = camScale.y},
            "out-quad",
            function()
                inst = love.audio.newSource(musicPath, "stream")
                inst:setLooping(true)
                inst:play()

                -- Verificamos que exista antes de animar
                if currentBoyfriend then
                    currentBoyfriend:animate("dead", true)
                end
            end
        )
    end,

    update = function(self, dt)
        if not graphics.isFading() and not transitionRef.value then
            if input:pressed("confirm") then
                if inst then inst:stop() end

                inst = love.audio.newSource(musicEndPath, "stream")
                inst:play()

                Timer.clear()

                cam.x, cam.y = -currentBoyfriend.x, -currentBoyfriend.y

                currentBoyfriend:animate("dead confirm", false)

                graphics.fadeOut(
                    3,
                    function()
                        -- Guardamos una referencia antes de hacer pop
                        local stateToLoad = fromState 
                        Gamestate.pop()
                        
                        -- Cargamos usando la referencia guardada
                        if stateToLoad and stateToLoad.load then
                            stateToLoad:load()
                        end
                    end
                )
            elseif input:pressed("gameBack") then
                if inst then inst:stop() end
                if voices then voices:stop() end

                Timer.clear()

                -- Limpiar el estado de la semana actual
                if fromState and fromState.leave then
                    fromState:leave()
                end

                if not transitionRef.value then
                    local StickerTransition = require("modules.sticker_transition")
                    transitionRef.value = StickerTransition.new(function()
                        return menu
                    end, transitionRef)
                    transitionRef.value:enter()
                end
            end
        end

        if currentBoyfriend then
            currentBoyfriend:update(dt)
        end
    end,

    draw = function(self)
        if not currentBoyfriend then return end

        love.graphics.push()
            love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)

            love.graphics.push()
                love.graphics.scale(cam.sizeX, cam.sizeY)
                love.graphics.translate(cam.x, cam.y)

                currentBoyfriend:draw()
            love.graphics.pop()
        love.graphics.pop()
    end
}