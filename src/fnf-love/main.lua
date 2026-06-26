--[[----------------------------------------------------------------------------
Friday Night Funkin' Rewritten v1.1.0 beta 2

Copyright (C) 2021  HTV04

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

-- cd /d/mati/funkin-rewritten-main


function love.load()
	local curOS = love.system.getOS()

	-- Load libraries
	baton = require "lib.baton"
	ini = require "lib.ini"
	lovesize = require "lib.lovesize"
	Gamestate = require "lib.gamestate"
	Timer = require "lib.timer"

	-- Load modules
	status = require "modules.status"
	audio = require "modules.audio"
	graphics = require "modules.graphics"

	-- Load settings
	settings = require "settings"
	input = require "input"

	-- Load states
	clickStart = require "states.click-start"
	debugMenu = require "states.debug-menu"
	menu = require "states.menu"
	weeks = require "states.weeks"
	freeplay = require "states.freeplay"
	storymenu = require "states.storymenu"
	results = require "states.results"

	-- Load substates
	gameOver = require "substates.game-over"
	pauseMenu = require "substates.pause"

	-- Load loading system
	loadingState = require "states.loadingState"
	weekLoader = require "modules.weekLoader"

	-- Load week data — driven by weeks/weekList.txt (Psych Engine-style)
	-- To add a week or mod: create weeks/{id}.json, add id to weekList.txt.
	-- weeks/{id}.lua is now OPTIONAL (Fase 1 de la refactorización de
	-- ergonomía de modding, ver memoria del proyecto
	-- "modding-ergonomics-refactor") -- semanas simples (un stage fijo,
	-- sin lógica propia) funcionan solo con el JSON, vía
	-- modules/genericWeek.lua (modules/weekLoader.lua lo usa de
	-- fallback al cargar de verdad). ESTE loop de acá es solo "calentar
	-- la caché de require()" -- no tiene ningún consumidor real más allá
	-- de un comentario en storymenu.lua (confirmado por grep) -- así que
	-- semanas sin .lua simplemente no entran a este loop, no hay nada
	-- que cachear para ellas.
	--
	-- BUG corregido: el pcall absorbía CUALQUIER error en silencio, sin
	-- avisar ni la semana ni el motivo -- se mantiene el pcall (sacarlo
	-- arriesgaría que UNA semana rota tire abajo el arranque del juego
	-- ENTERO para todos los usuarios, un costo mucho mayor que el
	-- beneficio de visibilidad) pero ahora se imprime un aviso claro.
	local wmd = require("modules.weekMetadata")
	weekData = {}
	for _, week in ipairs(wmd.weeks) do
		if love.filesystem.getInfo("weeks/" .. week.id .. ".lua") then
			local ok, mod = pcall(require, "weeks." .. week.id)
			if ok then
				table.insert(weekData, mod)
			else
				print("WARN: error al precargar la semana '" .. week.id .. "': " .. tostring(mod))
			end
		end
	end

	-- LÖVE init
	if curOS == "OS X" then
		love.window.setIcon(love.image.newImageData("icons/macos.png"))
	else
		love.window.setIcon(love.image.newImageData("icons/default.png"))
	end

	function love.textinput(text)
		Gamestate.textinput(text)
	end

	function love.wheelmoved(x, y)
		Gamestate.wheelmoved(x, y)
	end

	function love.mousemoved(x, y, dx, dy)
		Gamestate.mousemoved(x, y, dx, dy)
	end

	function love.mousereleased(x, y, button)
		Gamestate.mousereleased(x, y, button)
	end

	lovesize.set(1280, 720)
	transitionRef = {value = nil}

	-- Variables
	font = love.graphics.newFont("fonts/vcr.ttf", 24)

	weekNum = 1
	songDifficulty = 2

	spriteTimers = {
		0, -- Girlfriend
		0, -- Enemy
		0 -- Boyfriend
	}

	storyMode = false
	countingDown = false
	nastyDebug = false

	cam = {x = 0, y = 0, sizeX = 0.9, sizeY = 0.9}
	camScale = {x = 0.9, y = 0.9}
	uiScale = {x = 0.7, y = 0.7}

	musicTime = 0
	health = 0

	if curOS == "Web" then
		Gamestate.switch(clickStart)
	else
		Gamestate.switch(require("states.title"))
	end
end

function love.resize(width, height)
	lovesize.resize(width, height)
end

function love.keypressed(key)
	-- Si hay una transición activa, le damos prioridad
	if transitionRef and transitionRef.value then
		if transitionRef.value:keypressed(key) then
			return
		end
	end

	if key == "f8" then
		nastyDebug = not nastyDebug
	elseif key == "6" then
		love.filesystem.createDirectory("screenshots")
		love.graphics.captureScreenshot("screenshots/" .. os.time() .. ".png")
	elseif key == "7" then
		if _G.chartEditorReturn then
			_G.chartEditorReturn = nil
			Gamestate.switch(require("states.chart-editor"))
		else
			Gamestate.switch(debugMenu)
		end
--  elseif key == "8" then
--      local StickerTransition = require("modules.sticker_transition")
--      transitionRef.value = StickerTransition.new(function() return menu end, transitionRef)
--      transitionRef.value:enter()
	else
		Gamestate.keypressed(key)
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	if transitionRef and transitionRef.value then
		return -- no pasar clicks durante transición
	end
	Gamestate.mousepressed(x, y, button, istouch, presses)
end

local activeTouches = {}

function love.touchpressed(id, x, y, dx, dy, pressure)
	if transitionRef and transitionRef.value then
		return -- no pasar toques durante transición
	end

	local sw, sh = love.graphics.getDimensions()
	local actions = {}

	-- Zona 1: Esquina superior izquierda (Pausa y Back universal)
	if x < sw * 0.15 and y < sh * 0.15 then
		table.insert(actions, "pause")
		table.insert(actions, "back")
		table.insert(actions, "gameBack")
	else
		-- Zona 2: Dividir el resto de la pantalla en 4 carriles (soporta multi-touch)
		if x < sw * 0.25 then
			table.insert(actions, "gameLeft")
			table.insert(actions, "left")
		elseif x < sw * 0.5 then
			table.insert(actions, "gameDown")
			table.insert(actions, "down")
		elseif x < sw * 0.75 then
			table.insert(actions, "gameUp")
			table.insert(actions, "up")
		else
			table.insert(actions, "gameRight")
			table.insert(actions, "right")
			-- Mitad inferior del cuarto carril funciona como 'confirm' (Enter) para menús
			if y > sh * 0.5 then
				table.insert(actions, "confirm")
			end
		end
	end

	activeTouches[id] = actions

	for _, action in ipairs(actions) do
		input.VirtualPad._pressedThisFrame[action] = true
		input.VirtualPad.down[action] = true
	end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
	local actions = activeTouches[id]
	if actions then
		for _, action in ipairs(actions) do
			input.VirtualPad._releasedThisFrame[action] = true
			input.VirtualPad.down[action] = false
		end
		activeTouches[id] = nil
	end
end

function love.update(dt)
	dt = math.min(dt, 1 / 30)

	input:update()

	if status.getNoResize() then
		Gamestate.update(dt)
	else
		love.graphics.setFont(font)
		graphics.screenBase(lovesize.getWidth(), lovesize.getHeight())
		graphics.setColor(1, 1, 1)
		Gamestate.update(dt)
		love.graphics.setColor(1, 1, 1)
		graphics.screenBase(love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setFont(font)
	end

	-- Actualizar transición si existe
	if transitionRef and transitionRef.value then
		transitionRef.value:update(dt)
	end

	Timer.update(dt)

end

function love.draw()
	love.graphics.setFont(font)
	if status.getNoResize() then
		graphics.setColor(1, 1, 1)
		Gamestate.draw()
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(font)

		-- Dibujar transición si existe (encima)
		if transitionRef and transitionRef.value then
			transitionRef.value:draw()
		end
	else
		graphics.screenBase(lovesize.getWidth(), lovesize.getHeight())
		lovesize.begin()
			graphics.setColor(1, 1, 1)
			Gamestate.draw()
			love.graphics.setColor(1, 1, 1)
			love.graphics.setFont(font)

			if transitionRef and transitionRef.value then
				transitionRef.value:draw()
			end
		lovesize.finish()
	end
	graphics.screenBase(love.graphics.getWidth(), love.graphics.getHeight())

	if settings.showDebug then
		love.graphics.print(status.getDebugStr(settings.showDebug), 5, 5, nil, 0.5, 0.5)
	end

	-- Nasty Debug: mostrar coordenadas del mouse al lado del cursor
	if nastyDebug then
		local mx, my = love.mouse.getPosition()
		local coordText = "X: " .. math.floor(mx) .. "  Y: " .. math.floor(my)
		love.graphics.setColor(0, 0, 0, 0.7)
		love.graphics.rectangle("fill", mx + 15, my - 10, font:getWidth(coordText) * 0.45 + 10, 22, 4, 4)
		love.graphics.setColor(0, 1, 0, 1)
		love.graphics.print(coordText, mx + 20, my - 8, 0, 0.4, 0.4)
		love.graphics.setColor(1, 1, 1, 1)
	end
end