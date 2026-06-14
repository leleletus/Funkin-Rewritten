--[[----------------------------------------------------------------------------
  LoadingState — Pantalla de carga con progreso REAL

  switchToPreloaded(state, tasks):
    Ejecuta tareas (que llaman enter/load internamente),
    espera a que la barra llegue al 100%,
    instala el estado como activo SIN re-llamar enter(),
    LUEGO ejecuta state:onLoadingComplete() si existe.
    
  Esto permite que setupCountdown() se ejecute DESPUÉS de que
  el LoadingState desaparezca, evitando que el countdown corra
  mientras la pantalla de carga aún es visible.
------------------------------------------------------------------------------]]

local loadingState = {}

local tasks = {}
local currentTask = 0
local totalTasks = 0
local progress = 0
local phase = "idle"

local targetState = nil
local targetArgs = {}
local preloadedMode = false

local loadingImage = nil
local loadingImageW, loadingImageH = 0, 0

local smoothProgress = 0
local isActive = false

local MIN_TASK_DISPLAY = 0.04
local taskDisplayTimer = 0

-- ============================================================
-- switchTo: ejecuta tareas, luego Gamestate.switch normal
-- ============================================================
function loadingState.switchTo(destState, destArgs, taskList)
    targetState = destState
    targetArgs = destArgs or {}
    preloadedMode = false
    tasks = taskList or {{ name = "Cargando...", fn = function() end }}
    totalTasks = #tasks
    currentTask = 0
    progress = 0
    smoothProgress = 0
    phase = "loading"
    taskDisplayTimer = 0
    isActive = true
    Gamestate.switch(loadingState)
end

-- ============================================================
-- switchToPreloaded: tareas ejecutan enter() internamente
-- ============================================================
function loadingState.switchToPreloaded(destState, taskList)
    targetState = destState
    targetArgs = {}
    preloadedMode = true
    tasks = taskList or {{ name = "Cargando...", fn = function() end }}
    totalTasks = #tasks
    currentTask = 0
    progress = 0
    smoothProgress = 0
    phase = "loading"
    taskDisplayTimer = 0
    isActive = true
    Gamestate.switch(loadingState)
end

function loadingState.isLoading() return isActive end

function loadingState.cleanMemory()
    collectgarbage("collect")
    collectgarbage("collect")
    if love.graphics and love.graphics.gc then love.graphics.gc() end
    local memKB = collectgarbage("count")
    print(string.format("[LoadingState] Memoria: %.1f MB", memKB / 1024))
end

function loadingState.enter(self)
    if not loadingImage then
        local ok, img = pcall(love.graphics.newImage, graphics.imagePath("funkay"))
        if ok and img then
            loadingImage = img
            loadingImageW = img:getWidth()
            loadingImageH = img:getHeight()
        end
    end
    collectgarbage("collect")
    collectgarbage("collect")
    graphics.setFade(0)
end

function loadingState.update(self, dt)
    smoothProgress = smoothProgress + (progress - smoothProgress) * dt * 12
    if progress - smoothProgress < 0.005 then
        smoothProgress = progress
    end

    if taskDisplayTimer > 0 then
        taskDisplayTimer = taskDisplayTimer - dt
        return
    end

    if phase == "loading" then
        currentTask = currentTask + 1
        if currentTask <= totalTasks then
            progress = (currentTask - 1) / totalTasks
            local ok, err = pcall(tasks[currentTask].fn)
            if not ok then
                print("[LoadingState] Error: " .. tostring(err))
            end
            progress = currentTask / totalTasks
            taskDisplayTimer = MIN_TASK_DISPLAY
        else
            phase = "waitForBar"
            progress = 1
        end

    elseif phase == "waitForBar" then
        if smoothProgress >= 0.99 then
            smoothProgress = 1
            phase = "finishing"
            collectgarbage("collect")
        end

    elseif phase == "finishing" then
        phase = "done"
        isActive = false

        if targetState then
            if preloadedMode then
                -- enter() ya se ejecutó en las tareas.
                -- Hacemos que enter() sea no-op UNA vez.
                local realEnter = targetState.enter
                targetState.enter = function(self, ...)
                    -- Restaurar enter original para futuros usos
                    targetState.enter = realEnter
                    -- No ejecutar — ya se hizo en las tareas
                end
                Gamestate.switch(targetState)

                -- AHORA el estado está activo. Ejecutar onLoadingComplete
                -- para que setupCountdown/cutscenes arranquen AQUÍ,
                -- no durante la pantalla de carga.
                if targetState.onLoadingComplete then
                    targetState:onLoadingComplete()
                end
            else
                Gamestate.switch(targetState, unpack(targetArgs))
            end
        end

        tasks = {}
        targetState = nil
        targetArgs = {}
    end
end

function loadingState.draw(self)
    local screenW, screenH
    if status and status.getNoResize and status.getNoResize() then
        screenW, screenH = love.graphics.getDimensions()
    else
        screenW, screenH = lovesize.getWidth(), lovesize.getHeight()
    end

    if loadingImage then
        local scale = math.max(screenW / loadingImageW, screenH / loadingImageH)
        local scaledW = loadingImageW * scale
        local scaledH = loadingImageH * scale
        local x = (screenW - scaledW) / 2
        local y = (screenH - scaledH) / 2
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(loadingImage, x, y, 0, scale, scale)
    end

    local barWidth = screenW * 0.8
    local barHeight = 10
    local barX = (screenW - barWidth) / 2
    local barY = screenH - 30
    love.graphics.setColor(1, 22/255, 210/255, 1)
    love.graphics.rectangle("fill", barX, barY, barWidth * math.max(smoothProgress, 0), barHeight)
    love.graphics.setColor(1, 1, 1, 1)
end

function loadingState.leave(self) end

return loadingState