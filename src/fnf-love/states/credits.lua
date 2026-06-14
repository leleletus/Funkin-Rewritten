-- states/credits.lua - Pantalla de créditos con estilo unificado
local atlasText = require("modules.atlas_text")

local titleText, backgroundImage
local creditsLines = {
    "v1.5.0 beta 2",
    "Developed by HTV04",
    "Updated by Serqwjahk",
    "",
    "Original game by Funkin' Crew,",
    "in association with Newgrounds"
}
local creditsTexts = {}  -- objetos atlasText para cada línea

-- Función auxiliar para centrar texto
local function createCenteredText(y, text, style)
    local textObj = atlasText.new(0, y, text, style)
    local maxX = 0
    for _, letter in ipairs(textObj.letters) do
        local right = letter.x + (letter.width or 0)
        if right > maxX then maxX = right end
    end
    -- REEMPLAZO: Usar 1280 de ancho base
    local offsetX = (1280 - maxX) / 2
    for _, letter in ipairs(textObj.letters) do
        letter.x = letter.x + offsetX
    end
    return textObj
end

return {
    enter = function(self, previous)
        -- Cargar fondo (mismo que debug-menu y settings)
        backgroundImage = love.graphics.newImage("images/png/menuBGMagenta.png")

        -- Título centrado
        titleText = createCenteredText(100, "Credits", "bold")

        -- Crear textos para cada línea de créditos, centrados
        creditsTexts = {}
        local startY = 250
        local spacing = 50
        for i, line in ipairs(creditsLines) do
            creditsTexts[i] = createCenteredText(startY + (i - 1) * spacing, line, "regular")
        end

        graphics.setFade(0)
        graphics.fadeIn(0.5)
    end,

    update = function(self, dt)
        if titleText then titleText:update(dt) end
        for _, text in ipairs(creditsTexts) do
            text:update(dt)
        end

        -- Volver al menú con Escape
        if input:pressed("back") then
            if not transitionRef.value then
                local StickerTransition = require("modules.sticker_transition")
                transitionRef.value = StickerTransition.new(function() return menu end, transitionRef)
                transitionRef.value:enter()
            end
        end
    end,

    draw = function(self)
        -- Fondo escalado a la resolución virtual (1280x720)
        if backgroundImage then
            -- REEMPLAZO: Usar 1280 y 720 en lugar del tamaño dinámico de la ventana
            local scaleX = 1280 / backgroundImage:getWidth()
            local scaleY = 720 / backgroundImage:getHeight()
            love.graphics.draw(backgroundImage, 0, 0, 0, scaleX, scaleY)
        end

        -- Título
        if titleText then titleText:draw() end

        -- Líneas de créditos (todas en blanco, sin selección)
        graphics.setColor(1, 1, 1)
        for _, text in ipairs(creditsTexts) do
            text:draw()
        end

        -- Texto de ayuda (REEMPLAZO: Usar 720 para la altura)
        love.graphics.print("Press Esc to go back", 20, 720 - 30)
    end
}