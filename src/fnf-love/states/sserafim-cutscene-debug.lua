--[[
Editor de posición para los props de la cutscene de Sserafim -- igual
patrón que character-offset-debug.lua/stage-editor.lua, pero
autocontenido (no arranca la semana completa, no depende de la cámara
real con su tween/zoom/bop -- vista fija propia, J/K/L/I + Q/E para
navegarla, igual que el editor de personajes) para poder ajustar
posiciones SIN la incertidumbre de a dónde está apuntando la cámara del
juego en ese momento.

Dividido en 2 fases (son 2 escenas visualmente distintas, con props
distintos -- pedido explícito del usuario):
  1a "comiendo hamburguesas" (antes del choque): fondo + backTablesCutscene
      (mostrador alargado) + burgerCutscene (hamburguesa) + el sprite único
      del choque completo (cutsceneMain, que YA trae a bf/gf comiendo
      dibujados como parte de su propia animación de 631 frames).
  1b "después del choque, durante la cuenta regresiva": fondo + el diner
      normal (camión/mesas/sillas) + bf/gf levantándose (sserafim-{gf,bf}-getup).

state.setPhase("1a" | "1b") ANTES de Gamestate.switch() elige cuál.

Controles:
  Q/E              : prop anterior/siguiente
  Flechas          : mover el prop seleccionado (Shift = paso 10, mantener repite)
  J/K/L/I          : mover la vista (paneo)            U/O : zoom in/out vista
  R                : resetear zoom/paneo de la vista a 1x, (0,0)
  Espacio          : alternar animación (cutsceneMain: play/pausa: bf/gf: static/getup)
  C                : forzar visibles TODOS los props (alterna)
  P                : imprimir todas las posiciones actuales a la consola
  Escape           : volver al menú de depuración
]]

local state = {}
local graphics, input, character

local PROPS = {} -- {name=, kind="image"|"character", obj=, x=, y=}
local selection = 1

local view = {x = 0, y = 0, zoom = 1}
local forceVisible = true

local holdTime, holdElapsed = 0, 0

-- "1a" | "1b" -- seteado por state.setPhase() antes de entrar.
local phase = "1a"

function state.setPhase(p)
	phase = p
end

local function loadImageProp(name, path, psychX, psychY)
	local raw = love.graphics.newImage(graphics.imagePath(path))
	local sprite = graphics.newImage(raw)
	sprite.x, sprite.y = psychX + raw:getWidth() / 2, psychY + raw:getHeight() / 2
	table.insert(PROPS, {name = name, kind = "image", obj = sprite})
end

local function loadCharProp(name, jsonPath, x, y, firstAnim)
	local ok, sprite = pcall(character.load, jsonPath, false)
	if not ok then
		print("WARN: no se pudo cargar " .. jsonPath .. ": " .. tostring(sprite))
		return
	end
	-- getOrigin() ANTES de cambiar de animación -- mismo orden que
	-- stage.lua (calcula el origen contra la pose por defecto del JSON,
	-- "static"/"play", igual que el real al construir el sprite).
	local ox, oy = sprite:getOrigin()
	local minX, minY, w, h = sprite:getBounds()
	sprite.x, sprite.y = x + ox, y + oy
	sprite.visible = true
	if firstAnim then sprite:animate(firstAnim, true) end
	table.insert(PROPS, {
		name = name, kind = "character", obj = sprite,
		debugOX = ox, debugOY = oy,
		debugMinX = minX, debugMinY = minY, debugW = w, debugH = h,
	})
end

local function loadPhase1a()
	-- Escena "comiendo hamburguesas" (antes del choque) -- props reales
	-- exclusivos de esta escena (sserafim.json: backTablesCutscene/
	-- burgerCutscene) + el sprite único de 631 frames que YA dibuja a
	-- bf/gf sentados comiendo como parte de su propia animación (sus
	-- símbolos internos incluyen "gf hair"/"gf mouth"/"stool b", etc --
	-- no son sprites separados en esta fase, por eso no hay "bf"/"gf"
	-- individuales acá, a diferencia de 1b).
	loadImageProp("bg (referencia)", "sserafim/bg", -1853, -815)
	loadImageProp("backTablesCutscene (mostrador)", "sserafim/cutscene/counter-stretch", -1858, 377)
	loadImageProp("burgerCutscene (hamburguesa)", "sserafim/cutscene/burger-cutscene", -97, 237)
	loadCharProp("cutsceneMain (choque completo, bf/gf comiendo van DENTRO de esta)",
		"characters/sserafim-cutscene-main.json", -395, 10, "play")
end

local function loadPhase1b()
	-- Escena "después del choque, cuenta regresiva" -- el diner normal
	-- (camión/mesas/sillas, ya visibles de nuevo tras el flash blanco) +
	-- bf/gf levantándose como sprites SEPARADOS (sserafim-{gf,bf}-getup).
	loadImageProp("bg (referencia)", "sserafim/bg", -1853, -815)
	loadImageProp("truck", "sserafim/truck-stuff", -983, -707)
	loadImageProp("truckDoor", "sserafim/truck-door", -980, -173)
	loadImageProp("backTables", "sserafim/back-tables", -1857, 267)
	loadImageProp("backStools (sillas atras)", "sserafim/back-stools", -1357, 426)
	loadImageProp("frontStool (silla frente)", "sserafim/front-stool", -280, 818)
	loadCharProp("cutsceneGf (gf levantandose)", "characters/sserafim-gf-getup.json", 655, -104, "getup")
	loadCharProp("cutsceneBf (bf levantandose)", "characters/sserafim-bf-getup.json", 1220, 531, "getup")
end

function state:enter()
	graphics = require("modules.graphics")
	input = require("input")
	character = require("charts.psych.character")

	PROPS = {}
	selection = 1
	view.x, view.y, view.zoom = 0, 0, 1
	forceVisible = true

	if phase == "1b" then
		loadPhase1b()
	else
		loadPhase1a()
	end

	graphics.fadeIn(0.3)
end

local function shiftDown() return love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") end

local function printPositions()
	print("=== POSICIONES (sserafim-cutscene-debug, fase " .. phase .. ") ===")
	for _, p in ipairs(PROPS) do
		if p.kind == "character" then
			print(string.format("%-45s x=%.0f y=%.0f  (origen: ox=%.0f oy=%.0f | bbox crudo: minX=%.0f minY=%.0f w=%.0f h=%.0f)",
				p.name, p.obj.x, p.obj.y, p.debugOX or 0, p.debugOY or 0,
				p.debugMinX or 0, p.debugMinY or 0, p.debugW or 0, p.debugH or 0))
		else
			print(string.format("%-45s x=%.0f y=%.0f", p.name, p.obj.x, p.obj.y))
		end
	end
end

function state:update(dt)
	if #PROPS == 0 then return end

	for _, p in ipairs(PROPS) do
		if p.kind == "character" then p.obj:update(dt) end
	end

	if input:pressed("q") then selection = ((selection - 2) % #PROPS) + 1 end
	if input:pressed("e") then selection = (selection % #PROPS) + 1 end

	if input:pressed("r") then view.x, view.y, view.zoom = 0, 0, 1 end
	if love.keyboard.isDown("j") then view.x = view.x - dt * 500 end
	if love.keyboard.isDown("l") then view.x = view.x + dt * 500 end
	if love.keyboard.isDown("k") then view.y = view.y + dt * 500 end
	if love.keyboard.isDown("i") then view.y = view.y - dt * 500 end
	if love.keyboard.isDown("u") then view.zoom = math.max(0.05, view.zoom - dt * view.zoom) end
	if love.keyboard.isDown("o") then view.zoom = math.min(5, view.zoom + dt * view.zoom) end

	if input:pressed("c") then forceVisible = not forceVisible end
	if input:pressed("p") then printPositions() end

	if input:pressed("space") then
		local p = PROPS[selection]
		if p and p.kind == "character" then
			local cur = p.obj:getAnimName()
			if cur == "static" or cur == "getup" then
				p.obj:animate(cur == "getup" and "static" or "getup", true)
			end
			-- cutsceneMain (fase 1a) solo tiene una animación ("play") --
			-- nada que alternar, Espacio no hace nada ahí.
		end
	end

	local p = PROPS[selection]
	if not p then return end

	local step = shiftDown() and 10 or 1
	local moved = false

	if input:pressed("left")  then p.obj.x = p.obj.x - step; moved = true end
	if input:pressed("right") then p.obj.x = p.obj.x + step; moved = true end
	if input:pressed("up")    then p.obj.y = p.obj.y - step; moved = true end
	if input:pressed("down")  then p.obj.y = p.obj.y + step; moved = true end

	if input:down("left") or input:down("right") or input:down("up") or input:down("down") then
		holdTime = holdTime + dt
		if holdTime > 0.6 then
			holdElapsed = holdElapsed + dt
			while holdElapsed > (1 / 60) do
				if input:down("left")  then p.obj.x = p.obj.x - step end
				if input:down("right") then p.obj.x = p.obj.x + step end
				if input:down("up")    then p.obj.y = p.obj.y - step end
				if input:down("down")  then p.obj.y = p.obj.y + step end
				holdElapsed = holdElapsed - (1 / 60)
			end
		end
	else
		holdTime, holdElapsed = 0, 0
	end

	if input:pressed("back") then
		graphics.fadeOut(0.3, function()
			Gamestate.switch(require("states.debug-menu"))
		end)
	end
end

function state:draw()
	love.graphics.clear(0.15, 0.15, 0.18)

	love.graphics.push()
		love.graphics.translate(graphics.getWidth() / 2 + view.x, graphics.getHeight() / 2 + view.y)
		love.graphics.scale(view.zoom)

		for i, p in ipairs(PROPS) do
			if p.kind == "character" or forceVisible or i == selection then
				p.obj:draw()
			end
		end

		-- Cruz en el prop seleccionado
		local sel = PROPS[selection]
		if sel then
			love.graphics.setColor(1, 1, 0)
			love.graphics.setLineWidth(2 / view.zoom)
			local s = 15 / view.zoom
			love.graphics.line(sel.obj.x - s, sel.obj.y, sel.obj.x + s, sel.obj.y)
			love.graphics.line(sel.obj.x, sel.obj.y - s, sel.obj.x, sel.obj.y + s)
			love.graphics.setLineWidth(1)
		end
	love.graphics.pop()

	love.graphics.setColor(1, 1, 0)
	love.graphics.print("=== SSERAFIM CUTSCENE PROP EDITOR -- FASE " .. phase
		.. (phase == "1a" and " (comiendo hamburguesas)" or " (post-choque, cuenta regresiva)") .. " ===", 10, 10)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("J/K/L/I: paneo vista   U/O: zoom vista (" .. string.format("%.2f", view.zoom) .. ")   R: reset vista", 10, 30)
	love.graphics.print("Q/E: prop anterior/siguiente   Flechas: mover (Shift=10)   Espacio: alternar animacion", 10, 50)
	love.graphics.print("C: forzar todos visibles (" .. tostring(forceVisible) .. ")   P: imprimir posiciones a consola   Escape: volver", 10, 70)

	local sel = PROPS[selection]
	if sel then
		love.graphics.setColor(1, 1, 0)
		love.graphics.print("Seleccionado: " .. sel.name .. "  (" .. (selection) .. "/" .. #PROPS .. ")", 10, 100)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(string.format("x = %.0f   y = %.0f", sel.obj.x, sel.obj.y), 10, 120)
	end

	for i, p in ipairs(PROPS) do
		love.graphics.setColor(i == selection and 1 or 0.7, i == selection and 1 or 0.7, i == selection and 0 or 0.7)
		love.graphics.print(p.name .. ": " .. string.format("%.0f, %.0f", p.obj.x, p.obj.y), 10, 150 + (i - 1) * 16)
	end
	love.graphics.setColor(1, 1, 1)
end

function state:leave()
	PROPS = {}
end

return state
