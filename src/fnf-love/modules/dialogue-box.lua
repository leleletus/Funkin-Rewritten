local DialogueCharacter = require("modules.dialogue-character")
local TypedText = require("modules.typed-text")
local Timer = require("lib.timer")
local json = require("lib.json")

local DialogueBox = {}

function DialogueBox:new(dialogueJsonFile, onFinish)
    local box = {}
    setmetatable(box, self)
    self.__index = self

    local file = love.filesystem.read(dialogueJsonFile)
    if not file then error("No se encuentra el diálogo: " .. dialogueJsonFile) end
    local data = json.decode(file)
    box.dialogueList = data.dialogue
    box.currentIndex = 1
    box.onFinish = onFinish

    -- Fondo negro
    local blackImg = love.graphics.newImage("images/png/ui/black.png")
    box.bgFade = graphics.newImage(blackImg)
    box.bgFade.alpha = 0
    box.bgFade.sizeX, box.bgFade.sizeY = graphics.getWidth() * 2, graphics.getHeight() * 2
    box.bgFade.x, box.bgFade.y = -500, -500

    -- Caja de diálogo
    local bubbleSprite = love.filesystem.load("sprites/dialogue/speech_bubble.lua")()
    box.boxSprite = bubbleSprite
    box.boxSprite.visible = false
    box.boxSprite:setAnimSpeed(24)

    -- Texto
    box.text = TypedText.new(175, 460, "")

    box.characters = {}
    box.lastCharacter = nil
    box.lastBoxType = nil

    box:startNext()
    return box
end

function DialogueBox:getCharacter(charName)
    if not self.characters[charName] then
        self.characters[charName] = DialogueCharacter.new(0, 0, charName)
    end
    return self.characters[charName]
end

function DialogueBox:startNext()
    if self.currentIndex > #self.dialogueList then
        self:endDialogue()
        return
    end

    local line = self.dialogueList[self.currentIndex]
    self.currentIndex = self.currentIndex + 1

    local char = self:getCharacter(line.portrait)

    -- Animación de la caja
    local boxAnim = line.boxState or "normal"
    if char.json.dialogue_pos == "center" then
        boxAnim = "center-" .. boxAnim
    end

    -- Mapeo de nombres de animación (ajusta según tu speech_bubble.lua)
    local animMap = {
        normal = "speech bubble normal",
        normalOpen = "Speech Bubble Normal Open",
        angry = "AHH speech bubble",
        angryOpen = "speech bubble loud open",
        ["center-normal"] = "speech bubble middle",
        ["center-normalOpen"] = "Speech Bubble Middle Open",
        ["center-angry"] = "AHH Speech Bubble middle",
        ["center-angryOpen"] = "speech bubble Middle loud open",
    }

    local animToPlay
    if self.lastCharacter ~= line.portrait or self.lastBoxType ~= line.boxState then
        animToPlay = animMap[boxAnim .. "Open"] or animMap[boxAnim]
    else
        animToPlay = animMap[boxAnim]
    end

    if animToPlay then
        self.boxSprite:animate(animToPlay, false)
    end
    self.lastCharacter = line.portrait
    self.lastBoxType = line.boxState
    self.boxSprite.visible = true
    self.boxSprite.flipX = (char.json.dialogue_pos == "left")

    -- Texto
    self.text:setText(line.text, line.speed or 0.05, line.sound or "dialogue.ogg")
    self.text.y = 460
    if self.text.rows > 2 then
        self.text.y = self.text.y - 24
    end

    char:playAnim(line.expression or "talk", false)
end

function DialogueBox:update(dt)
    if self.bgFade.alpha < 0.5 then
        self.bgFade.alpha = math.min(0.5, self.bgFade.alpha + dt * 0.5)
    end

    for name, char in pairs(self.characters) do
        local targetX = char.startingX
        local targetY = char.startingY
        local isCurrent = (name == self.lastCharacter)
        local speed = 4000 * dt

        if char.json.dialogue_pos == "left" then
            if isCurrent then
                char.x = math.min(char.x + speed, targetX)
            else
                char.x = math.max(char.x - speed, targetX - 600)
            end
        elseif char.json.dialogue_pos == "right" then
            if isCurrent then
                char.x = math.max(char.x - speed, targetX)
            else
                char.x = math.min(char.x + speed, targetX + 600)
            end
        elseif char.json.dialogue_pos == "center" then
            if isCurrent then
                char.y = math.min(char.y + speed, targetY)
            else
                char.y = math.max(char.y - speed, targetY - 600)
            end
        end

        char.alpha = math.min(1, math.max(0.0001, char.alpha + (isCurrent and dt*3 or -dt*3)))
    end

    self.boxSprite:update(dt)
    self.text:update(dt)

    if input:pressed("confirm") then
        if not self.text.finished then
            self.text:finish()
        else
            self:startNext()
        end
        local click = love.audio.newSource("sounds/clickText.ogg", "static")
        click:setVolume(0.8)
        click:play()
    elseif input:pressed("gameBack") then
        self:endDialogue()
    end
end

function DialogueBox:endDialogue()
    Timer.tween(1, self.bgFade, {alpha = 0})
    self.boxSprite.visible = false
    if self.onFinish then self.onFinish() end
end

function DialogueBox:draw()
    self.bgFade:draw()
    for _, char in pairs(self.characters) do
        char:draw()
    end
    self.boxSprite:draw()
    self.text:draw()
end

return DialogueBox