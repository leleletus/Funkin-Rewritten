local TypedText = {}

function TypedText.new(x, y, text)
    local self = {
        x = x,
        y = y,
        fullText = text or "",
        displayText = "",
        charIndex = 1,
        delay = 0.05,
        timer = 0,
        finished = false,
        sound = "dialogue.ogg",
        rows = 1
    }

    function self:setText(newText, delay, sound)
        self.fullText = newText
        self.delay = delay or 0.05
        self.sound = sound or "dialogue.ogg"
        self.displayText = ""
        self.charIndex = 1
        self.finished = false
        self.timer = 0
        self.rows = math.ceil(#newText / 35)
    end

    function self:update(dt)
        if self.finished then return end
        self.timer = self.timer + dt
        while self.timer >= self.delay and self.charIndex <= #self.fullText do
            self.displayText = self.displayText .. self.fullText:sub(self.charIndex, self.charIndex)
            self.charIndex = self.charIndex + 1
            self.timer = self.timer - self.delay
            local s = love.audio.newSource("sounds/" .. self.sound, "static")
            s:setVolume(0.6)
            s:play()
        end
        if self.charIndex > #self.fullText then
            self.finished = true
        end
    end

    function self:finish()
        self.displayText = self.fullText
        self.finished = true
    end

    function self:draw()
        love.graphics.print(self.displayText, self.x, self.y)
    end

    return self
end

return TypedText