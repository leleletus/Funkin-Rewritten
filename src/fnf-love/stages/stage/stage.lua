--[[----------------------------------------------------------------------------
Stage: "stage" (Week 1 - Daddy Dearest)
Equivalente de StageWeek1.hx de Psych Engine.

create()      → M.load()   – crea sprites y registra handler del evento Dadbattle
eventPushed() → M.load()   – preload lazy de Psych integrado aquí (Rewritten no tiene lazy loading)
eventCalled() → psychEvents.registerHandler callback
update()      → M.update()
draw()        → M.draw()
destroy()     → M.leave()
------------------------------------------------------------------------------]]

local M = {}

local psychEvents = require("charts.psych.events")
local psychStages = require("charts.psych.stages")

local stageBack, stageFront, stageLightL, stageLightR, curtains

local dadbattleVisible   = false
local dadbattleLight
local dadbattleLightFlashTimer
local dadbattleSmoke1, dadbattleSmoke2
local dadbattleFogAlpha  = {value = 0}
local dadbattleFogTween

function M.load()
    -- ── Fondos ────────────────────────────────────────────────────────────────
    -- Posiciones convertidas de "esquina superior-izquierda Flixel" a centro
    -- (graphics.newImage dibuja desde el centro del sprite).

    stageBack  = graphics.newImage(love.graphics.newImage(graphics.imagePath("week1/stage-back")))
    stageFront = graphics.newImage(love.graphics.newImage(graphics.imagePath("week1/stage-front")))
    stageLightL = graphics.newImage(love.graphics.newImage(graphics.imagePath("week1/stage-light")))
    stageLightR = graphics.newImage(love.graphics.newImage(graphics.imagePath("week1/stage-light")))
    curtains    = graphics.newImage(love.graphics.newImage(graphics.imagePath("week1/curtains")))

    stageBack.x,  stageBack.y  = 680, 500

    stageFront.x, stageFront.y = 758, 919.55
    stageFront.sizeX, stageFront.sizeY = 1.1, 1.1

    stageLightL.x, stageLightL.y = 1.5, 34.2
    stageLightL.sizeX, stageLightL.sizeY = 1.1, 1.1

    stageLightR.x, stageLightR.y = 1351.5, 34.2
    stageLightR.sizeX, stageLightR.sizeY = -1.1, 1.1

    curtains.x, curtains.y = 652, 330
    curtains.sizeX, curtains.sizeY = 0.9, 0.9

    -- ── Posiciones de personajes ──────────────────────────────────────────────
    -- stages/data/stage.json (boyfriend/girlfriend/opponent), igual que el
    -- resto de stages -- antes tenía constantes hardcodeadas (974/749/308)
    -- que habían quedado desactualizadas.
    psychStages.apply("stage")

    -- ── Dadbattle Spotlight ───────────────────────────────────────────────────
    dadbattleVisible = false
    dadbattleFogAlpha = {value = 0}
    if dadbattleFogTween        then Timer.cancel(dadbattleFogTween)        end
    if dadbattleLightFlashTimer then Timer.cancel(dadbattleLightFlashTimer) end
    dadbattleFogTween        = nil
    dadbattleLightFlashTimer = nil

    dadbattleLight = graphics.newImage(love.graphics.newImage(graphics.imagePath("week1/spotlight")))
    dadbattleLight.visible = false
    dadbattleLight.alpha   = 0.375

    dadbattleSmoke1 = graphics.newImage(love.graphics.newImage(graphics.imagePath("week1/smoke")))
    dadbattleSmoke1.x,  dadbattleSmoke1.y  = -50,  620
    dadbattleSmoke1.sizeX, dadbattleSmoke1.sizeY = 1.15, 1.15
    dadbattleSmoke1.vx = 18

    dadbattleSmoke2 = graphics.newImage(love.graphics.newImage(graphics.imagePath("week1/smoke")))
    dadbattleSmoke2.x,  dadbattleSmoke2.y  = 1330, 620
    dadbattleSmoke2.sizeX, dadbattleSmoke2.sizeY = -1.15, 1.15
    dadbattleSmoke2.vx = -18

    -- ── Handler del evento (equivalente a eventPushed + eventCalled de Psych) ─
    psychEvents.registerHandler("Dadbattle Spotlight", function(ev)
        local val = math.floor((tonumber(ev.value1) or 0) + 0.5)

        if val == 1 or val == 2 or val == 3 then
            if val == 1 then
                dadbattleVisible = true
                camScale.x = camScale.x + 0.12
                camScale.y = camScale.y + 0.12

                dadbattleSmoke1.x = -50
                dadbattleSmoke2.x = 1330

                if dadbattleFogTween then Timer.cancel(dadbattleFogTween) end
                dadbattleFogTween = Timer.tween(1.5, dadbattleFogAlpha, {value = 0.7}, "in-out-quad")
            end

            -- val 2 → apunta a dad, val 3 → apunta a bf (val 1 también a dad)
            local target = (val > 2) and boyfriend or enemy

            dadbattleLight.x = target.x
            dadbattleLight.y = target.y

            -- Parpadeo: alpha 0 → 0.375 tras 0.12 s (igual que Psych)
            dadbattleLight.alpha   = 0
            dadbattleLight.visible = true
            if dadbattleLightFlashTimer then Timer.cancel(dadbattleLightFlashTimer) end
            dadbattleLightFlashTimer = Timer.after(0.12, function()
                dadbattleLight.alpha = 0.375
            end)
        else
            dadbattleVisible       = false
            dadbattleLight.visible = false
            camScale.x = camScale.x - 0.12
            camScale.y = camScale.y - 0.12

            if dadbattleFogTween then Timer.cancel(dadbattleFogTween) end
            dadbattleFogTween = Timer.tween(0.7, dadbattleFogAlpha, {value = 0}, "linear")
        end
    end)
end

function M.update(dt)
    -- Humo deriva horizontalmente mientras la niebla es visible
    if dadbattleFogAlpha.value > 0.001 then
        dadbattleSmoke1.x = dadbattleSmoke1.x + dadbattleSmoke1.vx * dt
        dadbattleSmoke2.x = dadbattleSmoke2.x + dadbattleSmoke2.vx * dt
    end
end

function M.draw()
    -- Fondo — scrollFactor 0.9 (stageback, stagefront, stage_light en StageWeek1.hx)
    graphics.pushParallax(0.9)
        stageBack:draw()
        stageFront:draw()
        stageLightL:draw()
        stageLightR:draw()
    love.graphics.pop()

    -- Personajes — scrollFactor 1 (valor por defecto de FlxSprite en Flixel)
    graphics.pushParallax(1)
        -- Niebla del Dadbattle Spotlight (DadBattleFog.hx), detrás de los personajes
        if dadbattleFogAlpha.value > 0.001 then
            love.graphics.setBlendMode("add")
            love.graphics.setColor(1, 1, 1, dadbattleFogAlpha.value)
            dadbattleSmoke1:draw()
            dadbattleSmoke2:draw()
            love.graphics.setBlendMode("alpha")
            love.graphics.setColor(1, 1, 1, 1)
        end

        if girlfriend then girlfriend:draw() end
        if enemy      then enemy:draw()      end
        if boyfriend  then boyfriend:draw()  end

        weeks:drawRating()
    love.graphics.pop()

    -- Cortinas — scrollFactor 1.3 (stagecurtains en StageWeek1.hx)
    graphics.pushParallax(1.3)
        curtains:draw()
    love.graphics.pop()

    -- Oscurecimiento de pantalla del Dadbattle Spotlight (dadbattleBlack, scrollFactor 0)
    if dadbattleVisible then
        love.graphics.setColor(0, 0, 0, 0.25)
        love.graphics.rectangle("fill", 0, 0, graphics.getWidth(), graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- Foco del spotlight (dadbattleLight, scrollFactor 1, blend ADD)
    if dadbattleLight.visible then
        graphics.pushParallax(1)
            love.graphics.setBlendMode("add")
            love.graphics.setColor(1, 1, 1, dadbattleLight.alpha)
            dadbattleLight:draw()
            love.graphics.setBlendMode("alpha")
            love.graphics.setColor(1, 1, 1, 1)
        love.graphics.pop()
    end
end

function M.leave()
    if dadbattleFogTween        then Timer.cancel(dadbattleFogTween)        end
    if dadbattleLightFlashTimer then Timer.cancel(dadbattleLightFlashTimer) end
    dadbattleFogTween        = nil
    dadbattleLightFlashTimer = nil

    stageBack    = nil
    stageFront   = nil
    stageLightL  = nil
    stageLightR  = nil
    curtains     = nil
    dadbattleLight  = nil
    dadbattleSmoke1 = nil
    dadbattleSmoke2 = nil
    dadbattleVisible = false
end

return M
