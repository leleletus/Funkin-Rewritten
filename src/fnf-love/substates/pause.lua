local atlasText = require("modules.atlas_text")

local pause = {}
pause.bgAlpha = 0
pause.textInfoAlpha = 0
pause.musicVolume = 0 -- Variable que usaremos para el lerp de volumen

local menuItems = {"Resume", "Restart Song", "Exit to menu"}
local menuTexts = {}
local curSelected = 1

function pause:enter(previous)
    if self.pauseMusic then
        self.pauseMusic:stop()
        self.pauseMusic = nil
    end
    self.previous = previous
    self.bgAlpha = 0
    self.textInfoAlpha = 0
    self.musicVolume = 0

    if inst then inst:pause() end
    if voices then voices:pause() end

    if self.previous and self.previous.popoMasterVideo then
        self.previous.popoMasterVideo:pause()
    end

    if self.previous and self.previous.pauseRedVG then
        self.previous:pauseRedVG()
    end

    -- Cargar y reproducir la música de pausa (en bucle y con volumen 0)
    self.pauseMusic = love.audio.newSource("music/breakfast.ogg", "stream")
    self.pauseMusic:setLooping(true)
    self.pauseMusic:setVolume(0)
    self.pauseMusic:play()

    -- Tweens de la UI
    Timer.tween(0.4, self, {bgAlpha = 0.6}, "in-out-quad")
    Timer.tween(0.4, self, {textInfoAlpha = 1}, "in-out-quad")
    Timer.tween(2, self, {musicVolume = 0.6}, "linear")

    menuTexts = {}
    for i, item in ipairs(menuItems) do
        local textObj = atlasText.new(90, 320 + (i - 1) * 110, item, "bold")
        table.insert(menuTexts, textObj)
    end

    curSelected = 1
    self:changeSelection(0)
end

function pause:update(dt)
    -- Aplicamos el lerp de volumen al source de audio en tiempo real
    if self.pauseMusic then
        self.pauseMusic:setVolume(self.musicVolume)
    end

    for _, textObj in ipairs(menuTexts) do
        textObj:update(dt)
    end

    if input:pressed("up") then
        self:changeSelection(-1)
    elseif input:pressed("down") then
        self:changeSelection(1)
    end

    if input:pressed("confirm") then
        local daSelected = menuItems[curSelected]
        
        if daSelected == "Resume" then
            self:resumeGame()
            
        elseif daSelected == "Restart Song" then
            if inst then inst:stop() end
            if voices then voices:stop() end
            if self.pauseMusic then self.pauseMusic:stop() end

            -- Guardar datos ANTES de hacer pop (self.previous se pierde después)
            local targetState = self.previous
            local sIndex = self.previous.songIndex
            local sAppend = self.previous.songAppend
            local sStory = self.previous.isStoryMode
            local sName = self.previous.songName

            Gamestate.pop()

            -- Usar LoadingState para que el restart no congele la pantalla
            local LS = require("states.loadingState")
            local tasks = {
                {
                    name = "Limpiando canción...",
                    fn = function()
                        LS.cleanMemory()
                    end
                },
                {
                    name = "Recargando...",
                    fn = function()
                        collectgarbage("step", 300)
                    end
                },
                {
                    name = "Preparando notas...",
                    fn = function()
                        collectgarbage("step", 200)
                    end
                },
                {
                    name = "¡Listo!",
                    fn = function()
                        LS.cleanMemory()
                    end
                }
            }
            LS.switchTo(targetState, {sIndex, sAppend, sStory, sName}, tasks)
            
        elseif daSelected == "Exit to menu" then
            if inst then inst:stop() end
            if voices then voices:stop() end
            if self.pauseMusic then self.pauseMusic:stop() end -- Apagar música de pausa

            Gamestate.pop()
            _G.storyMode = false
            _G.chartEditorPreviewSong = nil
            Gamestate.switch(menu)
        end
    end

    if input:pressed("pause") then
        self:resumeGame()
    end
end

function pause:changeSelection(change)
    curSelected = curSelected + change
    if curSelected < 1 then curSelected = #menuItems end
    if curSelected > #menuItems then curSelected = 1 end

    for i, item in ipairs(menuTexts) do
        if i == curSelected then
            item:setScale(1.2, 1.2)
            item.targetAlpha = 1
        else
            item:setScale(1, 1)
            item.targetAlpha = 0.6
        end
    end
end

function pause:leave()
    if self.pauseMusic then
        self.pauseMusic:stop()
        self.pauseMusic = nil
    end
end

function pause:resumeGame()
    -- Detenemos la música de pausa antes de volver
    if self.pauseMusic then self.pauseMusic:stop() end

    Gamestate.pop()
    if _G.previousFrameTime then
        _G.previousFrameTime = love.timer.getTime() * 1000
    end
    if inst then inst:play() end
    if voices then voices:play() end

    if self.previous and self.previous.popoMasterVideo and self.previous.videoStarted then
        self.previous.popoMasterVideo:play()
    end

    if self.previous and self.previous.resumeRedVG then
        self.previous:resumeRedVG()
    end
end

function pause:draw()
    self.previous:draw()

    love.graphics.setColor(0, 0, 0, self.bgAlpha)
    love.graphics.rectangle("fill", 0, 0, 1280, 720)

    love.graphics.setColor(1, 1, 1, self.textInfoAlpha)
    local font = love.graphics.getFont()
    local songText = (self.previous.songName or "Unknown"):upper()
    
    love.graphics.print(songText, 1280 - font:getWidth(songText) - 20, 20)

    for _, textObj in ipairs(menuTexts) do
        love.graphics.setColor(1, 1, 1, (textObj.targetAlpha or 1) * self.textInfoAlpha)
        textObj:draw()
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

return pause