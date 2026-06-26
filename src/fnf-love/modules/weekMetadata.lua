--[[----------------------------------------------------------------------------
weekMetadata — sistema de metadatos de semanas estilo Psych Engine.

Reemplaza data.json con el par weekList.txt + weeks/{id}.json individual.
Para añadir una semana (o mod) solo hace falta:
  1. Crear weeks/{id}.json
  2. Crear weeks/{id}.lua  (si tiene lógica de stage propia)
  3. Añadir el id a weeks/weekList.txt
------------------------------------------------------------------------------]]

local json = require("lib.json")

local function readWeekList()
    local raw = love.filesystem.read("weeks/weekList.txt")
    if not raw then error("No se encontró weeks/weekList.txt") end
    local ids = {}
    for line in raw:gmatch("[^\r\n]+") do
        local id = line:match("^%s*(.-)%s*$")  -- trim whitespace
        if id ~= "" and not id:match("^#") then
            table.insert(ids, id)
        end
    end
    return ids
end

local weeks = {}
for _, id in ipairs(readWeekList()) do
    local raw = love.filesystem.read("weeks/" .. id .. ".json")
    if raw then
        local w = json.decode(raw)
        w.id = id   -- ID inyectado desde el nombre de archivo (igual que Psych Engine)
        table.insert(weeks, w)
    else
        print("[weekMetadata] Advertencia: no se encontró weeks/" .. id .. ".json")
    end
end

return { weeks = weeks }
