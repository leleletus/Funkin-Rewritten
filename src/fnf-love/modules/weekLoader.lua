--[[----------------------------------------------------------------------------
  weekLoader — Carga semanas con progreso REAL

  Ejecuta los pasos de carga como tareas separadas.
  Usa _G._loadingViaWeekLoader = true para que las semanas sepan que
  no deben arrancar el countdown/cutscene todavía.
  
  Cuando el LoadingState termina y el estado queda activo,
  onLoadingComplete() arranca el countdown/cutscene.

  Tareas (8 pasos = barra granular):
    1. GC limpieza
    2. weeks.enter() → recursos base
    3. GC
    4. loadStage() → fondos, personajes
    5. GC
    6. load() → weeks:load + música + notas (countdown se skipea)
    7. GC final
    8. cleanup flag

  Después: onLoadingComplete() → weeks:setupCountdown()
------------------------------------------------------------------------------]]

local weekLoader = {}

local LoadingState
local function getLS()
    if not LoadingState then LoadingState = require("states.loadingState") end
    return LoadingState
end

-- Carga personajes desde el chart (player1/player2/gfVersion), igual que
-- PlayState.hx en Psych Engine. Fallback a weekCharacters del JSON si el
-- chart no especifica nada. Usado por la Task 4 de loadWeek() Y por el
-- restart ("Restart Song" en pause.lua), que necesita el mismo paso --
-- enemy/boyfriend/girlfriend NO se crean solos, hay que cargarlos siempre.
function weekLoader.loadCharactersForSong(weekId, songIndex, songAppend)
    local json       = require("lib.json")
    local wmd        = require("modules.weekMetadata")
    local psychChars = require("charts.psych.characters")

    local weekMeta
    for _, w in ipairs(wmd.weeks) do
        if w.id == weekId then weekMeta = w; break end
    end

    local player1, player2, gfVersion
    if weekMeta then
        local songData = weekMeta.songs[songIndex]
        if songData then
            local fileName  = songData[4]
            local chartFile = "data/" .. fileName .. "/" .. fileName .. songAppend .. ".json"
            local raw = love.filesystem.read(chartFile)
            if raw then
                local ok, data = pcall(json.decode, raw)
                if ok and data and data.song then
                    player1   = data.song.player1
                    player2   = data.song.player2
                    gfVersion = data.song.gfVersion
                end
            end
        end

        local wc = weekMeta.weekCharacters or {}
        player2   = player2   or wc[1]
        player1   = player1   or wc[2]
        gfVersion = gfVersion or wc[3]
    end

    if player2 then
        local ok, entry = psychChars.loadInto("enemy", player2)
        if ok and entry and entry.icon and _G.enemyIcon then
            _G.enemyIcon:animate(entry.icon, false)
        end
    end
    if player1   then psychChars.loadInto("boyfriend",  player1)   end
    if gfVersion then psychChars.loadInto("girlfriend", gfVersion) end
end

function weekLoader.startFromMenu(weekId, songIndex, songAppend, isStoryMode, songName)
    if music then music:stop() end
    status.setLoading(true)
    graphics.fadeOut(0.5, function()
        weekLoader.loadWeek(weekId, songIndex, songAppend, isStoryMode, songName)
    end)
end

function weekLoader.loadWeek(weekId, songIndex, songAppend, isStoryMode, songName)
    local weekModule = require("weeks." .. weekId)
    local weekState = {}
    for k, v in pairs(weekModule) do weekState[k] = v end
    weekState.isStoryMode = isStoryMode

    local LS = getLS()
    local hasGranular = (weekState.loadStage ~= nil)

    -- Reset flags
    _G._loadingViaWeekLoader = false
    _G._countdownWasSkipped = false

    local tasks = {}

    if hasGranular then

        tasks[#tasks+1] = {
            name = "Liberando memoria...",
            fn = function() LS.cleanMemory() end
        }

        tasks[#tasks+1] = {
            name = "Cargando recursos base...",
            fn = function()
                -- DEBE setearse ANTES de weeks.enter() -- esa función es la
                -- que CONSUME _G.isPixelWeek para decidir qué sonidos/
                -- imágenes/sprites cargar (countdown, notas, etc.). Antes,
                -- semanas con loadStage() (p.ej. week6) solo seteaban
                -- _G.isPixelWeek=true DENTRO de loadStage(), que en este
                -- camino (weekLoader) corre DESPUÉS de weeks.enter() -- la
                -- semana pixel siempre terminaba cargando recursos
                -- normales, y la bandera quedaba mal seteada para la
                -- semana siguiente. weekState.isPixelWeek es declarativo
                -- (ver weeks/week6.lua) justo para poder leerlo acá, antes.
                _G.isPixelWeek = weekState.isPixelWeek or false
                weeks.enter(weekState, songIndex, songAppend, isStoryMode, songName)
            end
        }

        tasks[#tasks+1] = {
            name = "Optimizando...",
            fn = function() collectgarbage("collect") end
        }

        -- Carga personajes desde chart (player1/player2/gfVersion) antes del stage,
        -- igual que PlayState.hx en Psych Engine. Fallback a weekCharacters del JSON.
        tasks[#tasks+1] = {
            name = "Cargando personajes...",
            fn = function()
                weekLoader.loadCharactersForSong(weekId, songIndex, songAppend)
            end
        }

        tasks[#tasks+1] = {
            name = "Cargando escenario...",
            fn = function()
                weekState:loadStage(songIndex, songAppend)
            end
        }

        tasks[#tasks+1] = {
            name = "Optimizando...",
            fn = function() collectgarbage("collect") end
        }

        tasks[#tasks+1] = {
            name = "Cargando música y notas...",
            fn = function()
                -- Flag para que las semanas sepan que NO deben arrancar
                -- setupCountdown/cutscenes todavía
                _G._loadingViaWeekLoader = true
                weekState:load()
            end
        }

        tasks[#tasks+1] = {
            name = "Finalizando...",
            fn = function()
                LS.cleanMemory()
                status.setLoading(false)
            end
        }

        -- Callback que se ejecuta DESPUÉS de que la pantalla de carga
        -- desaparezca y el estado esté activo
        weekState.onLoadingComplete = function(self)
            _G._loadingViaWeekLoader = false
            -- Solo arrancar countdown si setupCountdown fue llamado
            -- durante load() pero se skipeó por el flag
            if _G._countdownWasSkipped then
                _G._countdownWasSkipped = false
                weeks:setupCountdown()
            end
        end

    else
        -- FALLBACK
        tasks[#tasks+1] = {
            name = "Liberando memoria...",
            fn = function() LS.cleanMemory() end
        }
        tasks[#tasks+1] = {
            name = "Cargando semana...",
            fn = function()
                weekState:enter(nil, songIndex, songAppend, isStoryMode, songName)
            end
        }
        tasks[#tasks+1] = {
            name = "Finalizando...",
            fn = function()
                LS.cleanMemory()
                status.setLoading(false)
            end
        }
    end

    LS.switchToPreloaded(weekState, tasks)
end

return weekLoader