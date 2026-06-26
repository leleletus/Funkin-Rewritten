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

-- Porcentaje (accuracy, 0-1) asociado a la PERSONAL BEST de freeplay -- igual
-- que Psych Engine (Highscore.hx), que guarda accuracy/rank junto con el
-- score de la misma partida, no como un máximo independiente. Por eso esto
-- se guarda siempre que setFreeplayScore guarda un nuevo récord (mismo
-- gating, ver states/weeks.lua) y nunca por separado.
function highscores.getFreeplayAccuracy(songKey, difficulty)
    local data = readAllScores()
    local key = songKey .. ":" .. difficulty
    return tonumber(ini.readKey(data, "FreeplayAccuracy", key)) or 0
end

function highscores.setFreeplayAccuracy(songKey, difficulty, accuracy)
    local data = readAllScores()
    local key = songKey .. ":" .. difficulty
    ini.writeKey(data, "FreeplayAccuracy", key, tostring(accuracy))
    saveAllScores(data)
end

-- Persistencia de "semana completada" para el sistema de bloqueo del
-- StoryMenu (port 1:1 de StoryMenuState.weekCompleted / PlayState.hx:2468
-- de Psych real -- ver memoria del proyecto "storymenu-port"). Psych
-- guarda esto en FlxG.save.data.weekCompleted (un Map persistido con el
-- save del juego); acá usa el mismo highscores.ini que el resto de
-- puntuaciones, en su propia sección.
function highscores.getWeekCompleted(weekId)
    local data = readAllScores()
    return ini.readKey(data, "WeekCompleted", weekId) == "true"
end

function highscores.setWeekCompleted(weekId)
    local data = readAllScores()
    ini.writeKey(data, "WeekCompleted", weekId, "true")
    saveAllScores(data)
end

-- Crear archivo vacío si no existe
if not love.filesystem.getInfo("highscores.ini") then
    saveAllScores({})
end

return highscores