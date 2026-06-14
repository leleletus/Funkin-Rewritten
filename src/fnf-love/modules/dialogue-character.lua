local json = require("lib.json")

local DialogueCharacter = {}

function DialogueCharacter.new(x, y, characterId)
    -- Cargar JSON del personaje
    local jsonPath = "sprites/dialogue/" .. characterId .. ".json"
    local file = love.filesystem.read(jsonPath)
    if not file then
        jsonPath = "sprites/dialogue/pixel/" .. characterId .. ".json"
        file = love.filesystem.read(jsonPath)
    end
    if not file then error("No se encontró el JSON para: " .. characterId) end
    local charFile = json.decode(file)

    -- Determinar la ruta del sprite
    local spriteName = charFile.image
    local spritePath = "sprites/dialogue/" .. spriteName .. ".lua"
    
    -- Si no existe en la raíz, probar en la subcarpeta "pixel/"
    if not love.filesystem.getInfo(spritePath) then
        spritePath = "sprites/dialogue/pixel/" .. spriteName .. ".lua"
    end
    
    -- Cargar el sprite
    local ok, charSprite = pcall(love.filesystem.load, spritePath)
    if not ok then error("El archivo no existe: " .. spritePath) end
    local sprite = charSprite()   -- ejecuta el archivo Lua que retorna el sprite

    -- Añadir propiedades personalizadas
    sprite.json = charFile
    sprite.curCharacter = characterId
    sprite.offsetX = 0
    sprite.offsetY = 0
    sprite.animOffsets = {}

    for _, animData in ipairs(charFile.animations) do
        sprite.animOffsets[animData.loop_name] = {
            animData.loop_offsets[1] or 0,
            animData.loop_offsets[2] or 0
        }
        sprite.animOffsets[animData.idle_name] = {
            animData.idle_offsets[1] or 0,
            animData.idle_offsets[2] or 0
        }
    end

    -- Posicionamiento según dialogue_pos
    if charFile.dialogue_pos == "center" then
        sprite.x = (graphics.getWidth() / 2) - (sprite.width * (charFile.scale or 1) / 2)
                + (charFile.position[1] or 0)
        sprite.y = (charFile.position[2] or 0)
    elseif charFile.dialogue_pos == "right" then
        sprite.x = graphics.getWidth() - sprite.width * (charFile.scale or 1)
                + (charFile.position[1] or -100)
        sprite.y = (charFile.position[2] or 60)
    else -- left
        sprite.x = -60 + (charFile.position[1] or 0)
        sprite.y = (charFile.position[2] or 60)
    end

    sprite.sizeX, sprite.sizeY = charFile.scale or 1, charFile.scale or 1
    sprite.startingX = sprite.x
    sprite.startingY = sprite.y
    sprite.alpha = 1   -- valor por defecto, se cambiará en el diálogo

    -- Método para reproducir animaciones
    sprite.playAnim = function(self, animName, isIdle)
        local animDef = nil
        for _, ad in ipairs(self.json.animations) do
            if ad.anim == animName then
                animDef = ad
                break
            end
        end
        if not animDef then
            print("Animación no encontrada:", animName)
            return
        end
        local realAnim = isIdle and animDef.idle_name or animDef.loop_name
        self:animate(realAnim, not isIdle)
        local off = self.animOffsets[realAnim]
        if off then
            self.offsetX, self.offsetY = off[1], off[2]
        else
            self.offsetX, self.offsetY = 0, 0
        end
    end

    -- Sobrescribir draw para usar alpha
    local originalDraw = sprite.draw
    sprite.draw = function(self)
        love.graphics.push()
        love.graphics.setColor(1, 1, 1, self.alpha)
        originalDraw(self)
        love.graphics.pop()
    end

    return sprite
end

return DialogueCharacter