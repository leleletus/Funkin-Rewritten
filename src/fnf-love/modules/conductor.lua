-- modules/conductor.lua
local Conductor = {}
Conductor.__index = Conductor

function Conductor.new(bpm)
    local self = setmetatable({}, Conductor)
    self.bpm = bpm or 102          -- BPM por defecto (freakyMenu)
    self.currentBeat = 0
    self.lastTime = 0
    self.beatHitCallbacks = {}      -- funciones a llamar en cada beat
    return self
end

function Conductor:update(dt, musicTime)
    if not musicTime then return end
    local newBeat = math.floor(musicTime * self.bpm / 60000)
    if newBeat > self.currentBeat then
        -- Han pasado uno o más beats desde la última vez
        for beat = self.currentBeat + 1, newBeat do
            self:onBeat(beat)
        end
        self.currentBeat = newBeat
    end
end

function Conductor:onBeat(beat)
    for _, callback in ipairs(self.beatHitCallbacks) do
        callback(beat)
    end
end

function Conductor:addBeatHitCallback(callback)
    table.insert(self.beatHitCallbacks, callback)
end

return Conductor