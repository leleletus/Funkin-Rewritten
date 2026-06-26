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

    -- BUG corregido: si la música está en loop (setLooping(true), el
    -- caso de toda música de menú/título), :tell() vuelve a 0 al
    -- reiniciar -- newBeat también cae a un valor chico, pero
    -- currentBeat se había quedado en el beat MÁS ALTO del loop
    -- anterior. Sin este reset, "newBeat > currentBeat" nunca vuelve a
    -- ser cierto (newBeat tardaría un loop ENTERO en volver a alcanzar
    -- el valor viejo, y para entonces la música ya hizo loop de nuevo)
    -- -- los beats dejan de dispararse para siempre después del primer
    -- loop, congelando cualquier animación atada a ellos (el logo
    -- bumpin'/GF de la pantalla de título, por ejemplo).
    if newBeat < self.currentBeat then
        self.currentBeat = -1
    end

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