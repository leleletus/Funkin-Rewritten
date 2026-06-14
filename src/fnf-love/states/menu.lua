--[[----------------------------------------------------------------------------
... (licencia) ...
------------------------------------------------------------------------------]]

-- Main menu with 5 sprite options (storymode, freeplay, mods, options, credits)
-- Navigation: UP/DOWN to change selection, ENTER to confirm, ESC to go back/exit
-- Camera follows the selected item smoothly, with limits on extremes.

local storymodeSprite = require("sprites.menu.storymode")
local freeplaySprite = require("sprites.menu.freeplay")
local modsSprite = require("sprites.menu.mods")
local optionsSprite = require("sprites.menu.options")
local creditsSprite = require("sprites.menu.credits")

local titleBG = graphics.newImage(love.graphics.newImage(graphics.imagePath("menuBG")))
local titleMagenta = graphics.newImage(love.graphics.newImage(graphics.imagePath("menuBGMagenta")))

-- Menu state control
local selectedIndex = 1 -- 1: Story, 2: Freeplay, 3: Mods, 4: Options, 5: Credits
local menuItems = {} -- will hold the sprite objects

-- Sounds
local selectSound = love.audio.newSource("sounds/menu/select.ogg", "static")
local confirmSound = love.audio.newSource("sounds/menu/confirm.ogg", "static")

-- Flicker control
local magentaVisible = false
local selectedSpriteVisible = true
local flickering = false
local flickerSteps = 0
local FLICKER_INTERVAL = 0.15
local FLICKER_STEPS = 8

-- Menu lock to prevent spam
local menuLocked = false

-- Camera follow with limits
local camFollowY = 0
local targetCamY = 0
local CAMERA_SMOOTH = 5          -- Velocidad de seguimiento
local CAMERA_LIMIT_OFFSET = 100   -- Píxeles de separación de los extremos
local yMin, yMax                 -- Límites calculados al entrar

-- Helper to update sprite animations based on selection
local function updateSelection(newIndex)
    if menuItems[selectedIndex] then
        menuItems[selectedIndex]:animate("idle", true)
    end
    selectedIndex = newIndex
    menuItems[selectedIndex]:animate("selected", true)
    
    -- Aplicar límites a la cámara
    targetCamY = menuItems[selectedIndex].y
    if yMin and yMax then
        targetCamY = math.max(yMin, math.min(targetCamY, yMax))
    end
end

-- Enter main menu (set animations)
local function enterMainMenu()
    for i, sprite in ipairs(menuItems) do
        sprite:animate(i == selectedIndex and "selected" or "idle", true)
    end
end

-- Inicia el efecto de parpadeo y ejecuta un callback al terminar
local function startFlicker(callback)
    magentaVisible = true
    selectedSpriteVisible = true
    flickering = true
    flickerSteps = 0

    local function flickerStep()
        flickerSteps = flickerSteps + 1
        magentaVisible = not magentaVisible
        selectedSpriteVisible = not selectedSpriteVisible

        if flickerSteps < FLICKER_STEPS then
            Timer.after(FLICKER_INTERVAL, flickerStep)
        else
            magentaVisible = false
            selectedSpriteVisible = false
            flickering = false
            callback()
        end
    end

    Timer.after(0.05, flickerStep)
end

return {
    enter = function(self, previous)
        -- Crear menu sprites (con mods después de freeplay)
        menuItems = {
            storymodeSprite,
            freeplaySprite,
            modsSprite,
            optionsSprite,
            creditsSprite
        }

        -- Escalar todos los sprites
        local scale = 1.1
        for i, sprite in ipairs(menuItems) do
            sprite.sizeX, sprite.sizeY = scale, scale
        end

        -- Posicionamiento vertical
        local startY = -200
        local spacing = 150
        for i, sprite in ipairs(menuItems) do
            sprite.x = 0
            sprite.y = startY + (i - 1) * spacing
        end

        -- Calcular límites de la cámara
        local firstY = menuItems[1].y
        local lastY = menuItems[#menuItems].y
        yMin = firstY + CAMERA_LIMIT_OFFSET   -- más alto (menos negativo) que firstY
        yMax = lastY - CAMERA_LIMIT_OFFSET    -- más bajo (menos positivo) que lastY

        selectedIndex = 1
        enterMainMenu()
        camFollowY = menuItems[selectedIndex].y
        targetCamY = camFollowY
        -- Aplicar límites al target inicial
        targetCamY = math.max(yMin, math.min(targetCamY, yMax))

        -- Configurar fondos
        titleBG.x, titleBG.y = 0, 0
        titleBG.sizeX, titleBG.sizeY = 1, 1
        titleMagenta.x, titleMagenta.y = 0, 0
        titleMagenta.sizeX, titleMagenta.sizeY = 1, 1

        magentaVisible = false
        selectedSpriteVisible = true
        flickering = false
        menuLocked = false

        -- Camera and fade
        cam.sizeX, cam.sizeY = 0.9, 0.9
        camScale.x, camScale.y = 0.9, 0.9
        graphics.setFade(0)
        graphics.fadeIn(0.5)

        if not _G.music or not _G.music:isPlaying() then
            _G.music = love.audio.newSource("music/menu/menu.ogg", "stream")
            _G.music:setLooping(true)
            _G.music:play()
        end
    end,

    update = function(self, dt)
        -- Actualizar sprites del menú
        for _, sprite in ipairs(menuItems) do
            sprite:update(dt)
        end

        -- Movimiento suave de la cámara hacia la opción seleccionada (con límites)
        if not graphics.isFading() then
            camFollowY = camFollowY + (targetCamY - camFollowY) * (1 - math.exp(-dt * CAMERA_SMOOTH))
        end

        if graphics.isFading() or menuLocked then return end

        -- Navegación del menú principal
        if input:pressed("up") then
            audio.playSound(selectSound)
            local new = selectedIndex - 1
            if new < 1 then new = #menuItems end
            updateSelection(new)
        elseif input:pressed("down") then
            audio.playSound(selectSound)
            local new = selectedIndex + 1
            if new > #menuItems then new = 1 end
            updateSelection(new)
        elseif input:pressed("confirm") then
            audio.playSound(confirmSound)
            menuLocked = true

            local targetState
            if selectedIndex == 1 then
                targetState = "states.storymenu"
            elseif selectedIndex == 2 then
                targetState = "states.freeplay"
            elseif selectedIndex == 3 then
                targetState = "states.freeplay_mods"
            elseif selectedIndex == 4 then
                targetState = "states.settings"
            elseif selectedIndex == 5 then
                targetState = "states.credits"
            end

            startFlicker(function()
                graphics.fadeOut(0.5, function()
                    Gamestate.switch(require(targetState))
                end)
            end)
        elseif input:pressed("back") then
            audio.playSound(selectSound)
            -- En lugar de love.event.quit, volvemos al título
            graphics.fadeOut(0.5, function()
                Gamestate.switch(require("states.title"))
            end)
        end
    end,

    draw = function(self)
        love.graphics.push()
            love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)

            -- Fondos estáticos
            titleBG:draw()
            if magentaVisible then
                titleMagenta:draw()
            end

            -- Menú con cámara limitada
            love.graphics.push()
                love.graphics.translate(0, -camFollowY)
                love.graphics.scale(cam.sizeX, cam.sizeY)

                for i, sprite in ipairs(menuItems) do
                    if i == selectedIndex then
                        if selectedSpriteVisible then
                            sprite:draw()
                        end
                    else
                        sprite:draw()
                    end
                end
            love.graphics.pop()
        love.graphics.pop()
    end,

    leave = function(self)
        Timer.clear()
        menuLocked = false
    end
}