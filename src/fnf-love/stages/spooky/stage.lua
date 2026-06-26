-- Stage: "spooky" (Week 2 - Spooky Month) — puerto 1:1 de states/stages/Spooky.hx

local M = {}

local bgsprite = require("charts.psych.bgsprite")
local psychStages = require("charts.psych.stages")

local hauntedHouse
local thunderSounds = {}

-- Spooky.hx: lightningStrikeBeat / lightningOffset (cooldown en beats, no en tiempo)
local lastBeatNum = -1
local lightningStrikeBeat = 0
local lightningOffset = 8

function M.load()
    -- Spooky.hx create(): halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike'])
    hauntedHouse = bgsprite.new("week2/halloween_bg", -200, -100, {"halloweem bg0", "halloweem bg lightning strike"})

    thunderSounds = {
        love.audio.newSource("sounds/week2/thunder1.ogg", "static"),
        love.audio.newSource("sounds/week2/thunder2.ogg", "static"),
    }

    lastBeatNum = -1
    lightningStrikeBeat = 0
    lightningOffset = love.math.random(8, 24)

    psychStages.apply("spooky")
end

function M.update(dt)
    if hauntedHouse then
        hauntedHouse:update(dt)
        if not hauntedHouse:isAnimated() and hauntedHouse:getAnimName() ~= "halloweem bg0" then
            hauntedHouse:animate("halloweem bg0", false)
        end
    end

    -- Spooky.hx beatHit(): 10% de chance cada beat, con cooldown de 8-24 beats
    if bpm and absMusicTime then
        -- musicTime (con signo), no absMusicTime -- ver nota en limo/stage.lua.
        local curBeat = math.floor(musicTime * bpm / 60000)
        if curBeat > lastBeatNum then
            lastBeatNum = curBeat
            if love.math.random() < 0.10 and curBeat > lightningStrikeBeat + lightningOffset then
                M.lightningStrike(curBeat)
            end
        end
    end
end

function M.lightningStrike(curBeat)
    audio.playSound(thunderSounds[love.math.random(2)])

    if hauntedHouse then hauntedHouse:animate("halloweem bg lightning strike", false) end

    local function tryScared(sprite)
        if sprite and sprite:getAnims()["scared"] then
            sprite:animate("scared", false)
        end
    end
    tryScared(boyfriend)
    tryScared(girlfriend)
    tryScared(enemy)

    lightningStrikeBeat = curBeat or 0
    lightningOffset = love.math.random(8, 24)
end

function M.draw()
    -- Fondo scrollFactor 0.9
    graphics.pushParallax(0.9)
        if hauntedHouse then hauntedHouse:draw() end
    love.graphics.pop()

    -- Personajes scrollFactor 1
    graphics.pushParallax(1)
        if girlfriend then girlfriend:draw() end
        if enemy      then enemy:draw()      end
        if boyfriend  then boyfriend:draw()  end
        weeks:drawRating()
    love.graphics.pop()
end

function M.leave()
    hauntedHouse = nil
    thunderSounds = {}
end

return M
