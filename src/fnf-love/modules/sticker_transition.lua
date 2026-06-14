-- modules/sticker_transition.lua
local stickerTransition = {}
stickerTransition.__index = stickerTransition

local Timer = require "lib.timer"

function stickerTransition.new(targetStateFunc, transitionRef)
    -- Evitar crear múltiples transiciones simultáneas
    if transitionRef and transitionRef.value then
        return transitionRef.value
    end

    local self = setmetatable({}, stickerTransition)
    self.targetStateFunc = targetStateFunc
    self.transitionRef = transitionRef
    self.stickerSprites = {}
    self.stickerImages = {}
    self.soundFolders = {}
    self.soundFiles = {}
    self.switching = false
    self.active = true
    self.phase = "appearing"
    self.entered = false
    return self
end

function stickerTransition:enter()
    if self.entered then return end
    self.entered = true

    local success, err = xpcall(function()
        local stickerFolder = "images/png/transitionSwag/stickers-set-1/"
        local files = love.filesystem.getDirectoryItems(stickerFolder)
        self.stickerImages = {}
        for _, file in ipairs(files) do
            if file:match("%.png$") then
                local path = stickerFolder .. file
                local img = love.graphics.newImage(path)
                table.insert(self.stickerImages, img)
            end
        end
    end, debug.traceback)

    if not success then
        print("Error loading sticker images:", err)
        self:cleanup()
        return
    end

    local soundsBase = "sounds/stickersounds/"
    if love.filesystem.getInfo(soundsBase, "directory") then
        local soundDirs = love.filesystem.getDirectoryItems(soundsBase)
        self.soundFolders = {}
        for _, item in ipairs(soundDirs) do
            if love.filesystem.getInfo(soundsBase .. item, "directory") then
                table.insert(self.soundFolders, item)
            end
        end

        if #self.soundFolders > 0 then
            local chosenFolder = self.soundFolders[math.random(#self.soundFolders)]
            local soundFilesInFolder = love.filesystem.getDirectoryItems(soundsBase .. chosenFolder)
            self.soundFiles = {}
            for _, file in ipairs(soundFilesInFolder) do
                if file:match("%.ogg$") or file:match("%.wav$") then
                    table.insert(self.soundFiles, soundsBase .. chosenFolder .. "/" .. file)
                end
            end
        end
    end

    self:generateStickers()
    self:shuffleStickers()
    self:moveCenterToEnd()
    self:startAppearing()
end

function stickerTransition:cleanup()
    self.active = false
    if self.transitionRef then
        self.transitionRef.value = nil
    end
    self.stickerSprites = nil
    self.stickerImages = nil
    self.soundFiles = nil
end

function stickerTransition:startAppearing()
    self.phase = "appearing"
    local total = #self.stickerSprites
    for i, sticker in ipairs(self.stickerSprites) do
        local timing = (i - 1) / (total - 1) * 0.9
        if total == 1 then timing = 0 end

        Timer.after(timing, function()
            if not self.active or self.switching or self.phase ~= "appearing" then return end
            sticker.visible = true
            self:playRandomSound()

            if i == total then
                Timer.after(0.1, function()
                    if not self.active or self.switching or self.phase ~= "appearing" then return end
                    self.phase = "loading"
                    Gamestate.switch(self.targetStateFunc())
                    Timer.after(0.5, function()
                        if not self.active or self.switching then return end
                        self:startDisappearing()
                    end)
                end)
            else
                local frameTimer = math.random(0, 2) * (1/24)
                Timer.after(frameTimer, function()
                    if sticker and self.active and self.phase == "appearing" then
                        sticker.scaleX = math.random(97, 102) / 100
                        sticker.scaleY = sticker.scaleX
                    end
                end)
            end
        end)
    end
end

function stickerTransition:startDisappearing()
    self.phase = "disappearing"
    local total = #self.stickerSprites
    local desaparecidos = 0
    local extraCenterDelay = 0.2  -- segundos adicionales para el sticker central

    for i, sticker in ipairs(self.stickerSprites) do
        local timing
        if total == 1 then
            -- Si solo hay un sticker (el central), aplicamos el retraso extra directamente
            timing = extraCenterDelay
        else
            -- Cálculo normal basado en la posición
            timing = (i - 1) / (total - 1) * 0.9
            if sticker.isCenter then
                timing = timing + extraCenterDelay  -- retraso extra para el central
            end
        end

        Timer.after(timing, function()
            if not self.active or self.switching or self.phase ~= "disappearing" then return end
            sticker.visible = false
            self:playRandomSound()

            desaparecidos = desaparecidos + 1
            if desaparecidos == total then
                Timer.after(0.1, function()
                    if not self.active or self.switching then return end
                    self:cleanup()
                end)
            end
        end)
    end
end

function stickerTransition:playRandomSound()
    if #self.soundFiles > 0 then
        local soundPath = self.soundFiles[math.random(#self.soundFiles)]
        local sound = love.audio.newSource(soundPath, "static")
        love.audio.play(sound)
    end
end

function stickerTransition:generateStickers()
    self.stickerSprites = {}
    local sw, sh = graphics.getWidth(), graphics.getHeight()
    local x = -100
    local y = -100

    while y <= sh do
        local img = self.stickerImages[math.random(#self.stickerImages)]
        local sprite = {
            image = img,
            x = x,
            y = y,
            angle = math.random(-60, 70),
            scaleX = 1,
            scaleY = 1,
            visible = false
        }
        table.insert(self.stickerSprites, sprite)

        x = x + img:getWidth() * 0.5
        if x >= sw then
            x = -100
            y = y + math.random(70, 120)
        end
    end

    local lastImg = self.stickerImages[math.random(#self.stickerImages)]
    local lastSprite = {
        image = lastImg,
        x = sw / 2 - lastImg:getWidth() / 2,   -- Centrado horizontal
        y = sh / 2 - lastImg:getHeight() / 2,  -- Centrado vertical
        angle = 0,
        scaleX = 1,
        scaleY = 1,
        visible = false,
        isCenter = true
    }
    table.insert(self.stickerSprites, lastSprite)
end

function stickerTransition:moveCenterToEnd()
    for i, sticker in ipairs(self.stickerSprites) do
        if sticker.isCenter then
            table.remove(self.stickerSprites, i)
            table.insert(self.stickerSprites, sticker)
            break
        end
    end
end

function stickerTransition:shuffleStickers()
    local n = #self.stickerSprites
    for i = n - 1, 1, -1 do
        local j = math.random(i)
        self.stickerSprites[i], self.stickerSprites[j] = self.stickerSprites[j], self.stickerSprites[i]
    end
end

function stickerTransition:update(dt) end

function stickerTransition:draw()
    if not self.active then return end
    for _, sticker in ipairs(self.stickerSprites) do
        if sticker.visible then
            love.graphics.draw(
                sticker.image,
                sticker.x, sticker.y,
                math.rad(sticker.angle),
                sticker.scaleX, sticker.scaleY
            )
        end
    end
end

function stickerTransition:keypressed(key)
    return true -- Consumir todos los eventos de teclado
end

return stickerTransition