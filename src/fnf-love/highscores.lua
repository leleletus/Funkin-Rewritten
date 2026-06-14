local ini = require("ini")
local highscores = {}

-- Función para asegurar el directorio (aunque con rutas relativas no es necesaria)
local function ensureDir()
    local dir = love.filesystem.getSaveDirectory()
    if not love.filesystem.getInfo(dir) then
        love.filesystem.createDirectory(dir)
    end
end

local function readAllScores()
    ensureDir()
    if love.filesystem.getInfo("highscores.ini") then
        return ini.load("highscores.ini")
    else
        return {}
    end
end

local function saveAllScores(data)
    ensureDir()
    local ok, err = pcall(ini.save, data, "highscores.ini")
    if not ok then
        print("Error al guardar highscores.ini:", err)
    end
    return ok
end

function highscores.getStoryScore(weekId, difficulty)
    local data = readAllScores()
    local key = weekId .. ":" .. difficulty
    local value = tonumber(ini.readKey(data, "Story", key)) or 0
    print("DEBUG: getStoryScore(", weekId, ",", difficulty, ") =", value)
    return value
end

function highscores.setStoryScore(weekId, difficulty, score)
    local data = readAllScores()
    local key = weekId .. ":" .. difficulty
    local current = tonumber(ini.readKey(data, "Story", key)) or 0
    print("DEBUG: setStoryScore - weekId=", weekId, "difficulty=", difficulty, "score=", score, "current=", current)
    if score > current then
        ini.writeKey(data, "Story", key, tostring(score))
        local ok = saveAllScores(data)
        print("DEBUG: saveAllScores result =", ok)
    else
        print("DEBUG: score no es mayor que current, no se guarda")
    end
end

function highscores.getFreeplayScore(songKey, difficulty)
    local data = readAllScores()
    local key = songKey .. ":" .. difficulty
    return tonumber(ini.readKey(data, "Freeplay", key)) or 0
end

function highscores.setFreeplayScore(songKey, difficulty, score)
    local data = readAllScores()
    local key = songKey .. ":" .. difficulty
    local current = tonumber(ini.readKey(data, "Freeplay", key)) or 0
    if score > current then
        ini.writeKey(data, "Freeplay", key, tostring(score))
        saveAllScores(data)
    end
end

-- Crear archivo vacío si no existe
if not love.filesystem.getInfo("highscores.ini") then
    saveAllScores({})
end

return highscores