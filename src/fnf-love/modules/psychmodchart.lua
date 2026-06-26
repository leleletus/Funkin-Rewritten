-- Shim de compatibilidad para modcharts Lua de Psych Engine REAL (la API
-- "global" de Psych: funciones sueltas onCreate/start/update/beatHit/
-- stepHit/keyPressed + setActorX/setActorY/tweenCameraZoom + las variables
-- globales curStep/songPos/downscroll/bpm/defaultStrumNX/defaultStrumNY).
-- FNF Rewritten no tiene nada de esto nativamente -- este módulo es lo
-- mínimo necesario para poder ejecutar un modchart.lua de Psych real (como
-- data/too-slow/modchart.lua) sin reescribirlo entero.
--
-- Pensado para un solo week activo a la vez: mientras está cargado,
-- pollutea _G con setActorX/setActorY/tweenCameraZoom/downscroll/songPos/
-- curStep/defaultStrumNX/Y -- M.unload() los limpia todos.

local M = {}

local hooks = {}        -- start/update/beatHit/stepHit/keyPressed capturados del chunk
local lastStep = -1
local lastBeat = -1
local accumStep = 0     -- contador FRACCIONARIO de steps, ver M.update()

-- Índices 0-3 = enemyArrows (oponente), 4-7 = boyfriendArrows (jugador) --
-- mismo orden que PlayState.hx real (generateStaticArrows(0) para el
-- oponente primero, generateStaticArrows(1) para boyfriend después).
local function arrowFor(index)
    index = math.floor(tonumber(index) or 0)
    if index >= 0 and index <= 3 then
        return enemyArrows and enemyArrows[index + 1]
    elseif index >= 4 and index <= 7 then
        return boyfriendArrows and boyfriendArrows[index - 4 + 1]
    end
    return nil
end

-- setActorX/setActorY (Psych real): fijan la posición ABSOLUTA del strum
-- "index" -- el modchart las llama cada frame con un valor ya calculado
-- (típicamente defaultStrumNX/Y + un offset), no son deltas acumulables.
function _G.setActorX(x, index)
    local arrow = arrowFor(index)
    if arrow then arrow.x = x end
end

function _G.setActorY(y, index)
    local arrow = arrowFor(index)
    if arrow then arrow.y = y end
end

-- tweenCameraZoom(zoom, duration) (Psych real): tween-ea FlxG.camera.zoom
-- -- un valor ABSOLUTO, no relativo a defaultCamZoom/camScale.
function _G.tweenCameraZoom(zoomTo, duration)
    if not (cam and Timer) then return end
    Timer.tween(duration or 1, cam, { sizeX = zoomTo, sizeY = zoomTo }, "out-quad")
end

-- Ejecuta el chunk del modchart -- define start/update/beatHit/stepHit/
-- keyPressed como globales (sin "local", sin "return" -- así está escrito
-- el formato real de Psych); los capturamos y los borramos de _G enseguida
-- para no dejarlos pisando ningún otro "update"/"start" global del motor.
function M.load(path)
    hooks = {}
    lastStep, lastBeat = -1, -1
    accumStep = 0

    if not love.filesystem.getInfo(path) then return false end

    local chunk, err = love.filesystem.load(path)
    if not chunk then
        print("WARN: no se pudo cargar el modchart Psych '" .. path .. "': " .. tostring(err))
        return false
    end

    local ok, runErr = pcall(chunk)
    if not ok then
        print("WARN: error al ejecutar el modchart Psych '" .. path .. "': " .. tostring(runErr))
        return false
    end

    hooks.start      = _G.start
    hooks.update     = _G.update
    hooks.beatHit    = _G.beatHit
    hooks.stepHit    = _G.stepHit
    hooks.keyPressed = _G.keyPressed
    _G.start, _G.update, _G.beatHit, _G.stepHit, _G.keyPressed = nil, nil, nil, nil, nil

    return true
end

-- Snapshot de la posición YA puesta por weeks:initUI() en cada strum --
-- llamar DESPUÉS de cargar el chart real, nunca antes (si no,
-- defaultStrumNX/Y quedarían en (0,0), no en la posición real del carril).
function M.setup()
    _G.downscroll = settings and settings.downscroll or false

    for i = 0, 7 do
        local arrow = arrowFor(i)
        if arrow then
            _G["defaultStrum" .. i .. "X"] = arrow.x
            _G["defaultStrum" .. i .. "Y"] = arrow.y
        end
    end

    if hooks.start then
        pcall(hooks.start, _G.currentSongName or "")
    end
end

-- Llamar una vez por frame (mientras la canción esté activa). Calcula
-- songPos/curStep desde el estado real del motor y dispara beatHit/
-- stepHit cuando corresponde.
--
-- BUG real encontrado y corregido: la primera versión calculaba
-- curStep = songPos / stepCrochet(bpm ACTUAL) -- una división GLOBAL que
-- solo es correcta si el bpm nunca cambia en toda la canción. Too Slow
-- cambia de bpm varias veces (135->180->135...), así que ese cálculo se
-- desincronizaba por completo después del primer cambio (los rangos de
-- step 789-1959 que mueve el modchart real terminaban siendo otros
-- tiempos completamente distintos). Ahora se ACUMULA frame a frame con el
-- bpm vigente EN ESE MOMENTO (mismo patrón que el acumulador de beat de
-- las cutscenes de semana 7, stages/military/stage.lua) -- a prueba de
-- cualquier cantidad de cambios de bpm, sin necesitar conocerlos de
-- antemano.
function M.update(dt)
    _G.songPos = absMusicTime or 0

    if bpm and bpm > 0 then
        local stepCrochet = (60 / bpm) / 4  -- en SEGUNDOS, igual que dt
        accumStep = accumStep + dt / stepCrochet
        local step = math.floor(accumStep)
        _G.curStep = step

        if step ~= lastStep then
            lastStep = step
            if hooks.stepHit then pcall(hooks.stepHit, step) end

            local beat = math.floor(step / 4)
            if beat ~= lastBeat then
                lastBeat = beat
                if hooks.beatHit then pcall(hooks.beatHit, beat) end
            end
        end
    end

    if hooks.update then pcall(hooks.update, dt) end
end

function M.keyPressed(key)
    if hooks.keyPressed then pcall(hooks.keyPressed, key) end
end

-- BUG real (modchart deja de funcionar al re-entrar): este unload borraba
-- _G.setActorX/setActorY/tweenCameraZoom -- pero esas funciones se definen
-- (function _G.setActorX...) en el nivel superior de ESTE módulo, que solo
-- se ejecuta UNA VEZ en toda la sesión (la primera vez que algo hace
-- require("modules.psychmodchart") -- Lua cachea el módulo, requires
-- posteriores no vuelven a correr ese código). Borrarlas acá las dejaba
-- nil PARA SIEMPRE: la primera vez que se entraba a Too Slow funcionaban
-- bien, pero cualquier "update" de modchart.lua de ahí en adelante
-- (incluyendo re-entrar a la MISMA canción) llamaba a setActorX/setActorY
-- ya inexistentes -- el error quedaba silenciado por el pcall de
-- M.update()/M.keyPressed(), así que no tiraba ningún error visible, solo
-- dejaba de mover nada. Lo que sí hay que limpiar entre cargas es el
-- ESTADO por-partida (hooks/accumStep, y los globals que el script lee
-- como songPos/curStep/defaultStrumNX/Y) -- no las funciones de la API,
-- que son parte permanente del shim.
function M.unload()
    hooks = {}
    _G.downscroll, _G.songPos, _G.curStep = nil, nil, nil
    for i = 0, 7 do
        _G["defaultStrum" .. i .. "X"] = nil
        _G["defaultStrum" .. i .. "Y"] = nil
    end
end

return M
