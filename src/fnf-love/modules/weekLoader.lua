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
                weeks.enter(weekState, songIndex, songAppend, isStoryMode, songName)
            end
        }

        tasks[#tasks+1] = {
            name = "Optimizando...",
            fn = function() collectgarbage("collect") end
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