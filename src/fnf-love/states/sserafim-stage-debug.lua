--[[
Editor de posición para los 6 personajes del stage de Sserafim, TODOS
juntos sobre el fondo real del Diner -- a diferencia del "Character
Editor" genérico (que edita UN personaje a la vez, sin contexto del
stage), esto carga el fondo + las 6 chicas simultáneamente, todas
forzadas visibles, en sus posiciones reales actuales, para poder
ajustarlas viendo cómo se relacionan entre sí y con el fondo -- en vez de
adivinar offsets a ciegas personaje por personaje.

Posiciones de partida = las mismas fórmulas reales que usa
stages/sserafim/stage.lua (stagedata.<slot> + character.position para
kazuha/sakura/gf vía el sistema de slots; posición absoluta fija para
yunjin/chaewon/eunchae).

Controles:
  Q/E              : personaje anterior/siguiente
  Flechas          : mover el seleccionado (Shift = paso 10, mantener repite)
  J/K/L/I          : mover la vista (paneo)            U/O : zoom in/out vista
  R                : resetear zoom/paneo de la vista a 1x, (0,0)
  Espacio          : ciclar animación (idle/singLEFT/singDOWN/singUP/singRIGHT) del seleccionado
  C                : forzar visibles TODOS a la vez (alterna, por si se quieren ver de a uno)
  P                : imprimir todas las posiciones actuales a la consola
  Escape           : volver al menú de depuración
]]

local state = {}
local graphics, input, character

local PROPS = {} -- {name=, obj=}
local selection = 1
local animCycleIndex = {} -- [name] = índice actual en CYCLE_ANIMS

local CYCLE_ANIMS = {"idle", "singLEFT", "singDOWN", "singUP", "singRIGHT"}

local view = {x = 0, y = 0, zoom = 0.4} -- arranca alejado: el stage es grande
local forceVisible = true

local holdTime, holdElapsed = 0, 0

local function loadImageProp(name, path, psychX, psychY)
	local raw = love.graphics.newImage(graphics.imagePath(path))
	local sprite = graphics.newImage(raw)
	sprite.x, sprite.y = psychX + raw:getWidth() / 2, psychY + raw:getHeight() / 2
	table.insert(PROPS, {name = name, kind = "image", obj = sprite})
end

local function loadCharProp(name, jsonPath, x, y, isPlayer)
	-- BUG corregido: sakura es la única "isPlayer" real (slot boyfriend)
	-- -- character.load(jsonPath, false) ignoraba esto, así que su
	-- flip_x (real: true) nunca se invertía de vuelta, mostrándola SIN
	-- flip en esta herramienta (la posición en sí no se ve afectada por
	-- esto, pero la imagen sale mirando al lado contrario).
	local ok, sprite = pcall(character.load, jsonPath, isPlayer or false)
	if not ok then
		print("WARN: no se pudo cargar " .. jsonPath .. ": " .. tostring(sprite))
		return
	end
	-- Misma corrección de origen que stage.lua (loadExtraGirl/loadInto)
	-- -- si no se aplica acá también, esta herramienta mostraría la
	-- posición VIEJA (pre-fix), inconsistente con el juego real.
	local ox, oy = sprite:getOrigin()
	local minX, minY, w, h = sprite:getBounds()
	sprite.x, sprite.y = x + ox, y + oy
	sprite.visible = true
	sprite:animate("idle", true)
	animCycleIndex[name] = 1
	table.insert(PROPS, {
		name = name, kind = "character", obj = sprite,
		debugOX = ox, debugOY = oy,
		debugMinX = minX, debugMinY = minY, debugW = w, debugH = h,
	})
end

function state:enter()
	graphics = require("modules.graphics")
	input = require("input")
	character = require("charts.psych.character")

	PROPS = {}
	selection = 1
	view.x, view.y, view.zoom = 0, 0, 0.4
	forceVisible = true

	-- Fondo de referencia (no editable, mismas posiciones reales que
	-- stages/sserafim/stage.lua).
	loadImageProp("bg (referencia)", "sserafim/bg", -1853, -815)
	loadImageProp("backTables (referencia)", "sserafim/back-tables", -1857, 267)
	loadImageProp("truck (referencia)", "sserafim/truck-stuff", -983, -707)

	-- Las 6 chicas, en sus posiciones reales de partida (stagedata.json --
	-- "position" propio de kazuha/sakura/gf ya está en [0,0] desde que se
	-- agregó originMode="feet", ver memoria del proyecto; posición
	-- absoluta fija para las 3 extra -- ver loadExtraGirl()/
	-- EXTRA_GIRL_POS en stage.lua). Solo sakura es isPlayer=true (slot
	-- boyfriend real) -- bug corregido, antes esto se ignoraba.
	loadCharProp("kazuha (enemy, opponent[70,470])", "characters/sserafim-kazuha.json", 70, 470, false)
	loadCharProp("sakura (boyfriend, boyfriend[1530,970])", "characters/sserafim-sakura.json", 1530, 970, true)
	loadCharProp("gf (girlfriend, girlfriend[938.5,392])", "characters/sserafim-gf.json", 938.5, 392, false)
	loadCharProp("yunjin (posicion absoluta real)", "characters/sserafim-yunjin.json", -621, 154, false)
	loadCharProp("chaewon (posicion absoluta real)", "characters/sserafim-chaewon.json", 687, 98, false)
	loadCharProp("eunchae (posicion absoluta real)", "characters/sserafim-eunchae.json", 770, 675, false)

	graphics.fadeIn(0.3)
end

local function shiftDown() return love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") end

local function printPositions()
	print("=== POSICIONES (sserafim-stage-debug) ===")
	for _, p in ipairs(PROPS) do
		if p.kind == "character" then
			-- debugOX/OY = la corrección de getOrigin() YA aplicada (no
			-- una posición aparte) -- útil para diagnosticar si el
			-- "elevadas de más" viene de un bounding box mal calculado
			-- (valores enormes/raros acá) en vez de adivinar entre
			-- "feet" vs "centro" sin datos.
			print(string.format("%-50s x=%.0f y=%.0f  (origen: ox=%.0f oy=%.0f | bbox crudo: minX=%.0f minY=%.0f w=%.0f h=%.0f)",
				p.name, p.obj.x, p.obj.y, p.debugOX or 0, p.debugOY or 0,
				p.debugMinX or 0, p.debugMinY or 0, p.debugW or 0, p.debugH or 0))
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

	if input:pressed("r") then view.x, view.y, view.zoom = 0, 0, 0.4 end
	if love.keyboard.isDown("j") then view.x = view.x - dt * 500 end
	if love.keyboard.isDown("l") then view.x = view.x + dt * 500 end
	if love.keyboard.isDown("k") then view.y = view.y + dt * 500 end
	if love.keyboard.isDown("i") then view.y = view.y - dt * 500 end
	if love.keyboard.isDown("u") then view.zoom = math.max(0.05, view.zoom - dt * view.zoom) end
	if love.keyboard.isDown("o") then view.zoom = math.min(5, view.zoom + dt * view.zoom) end

	if input:pressed("c") then forceVisible = not forceVisible end
	if input:pressed("p") then printPositions() end

	local p = PROPS[selection]

	if input:pressed("space") and p and p.kind == "character" then
		local idx = (animCycleIndex[p.name] or 0) % #CYCLE_ANIMS + 1
		animCycleIndex[p.name] = idx
		p.obj:animate(CYCLE_ANIMS[idx], true)
	end

	if not p then return end

	local step = shiftDown() and 10 or 1

	if input:pressed("left")  then p.obj.x = p.obj.x - step end
	if input:pressed("right") then p.obj.x = p.obj.x + step end
	if input:pressed("up")    then p.obj.y = p.obj.y - step end
	if input:pressed("down")  then p.obj.y = p.obj.y + step end

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

		local sel = PROPS[selection]
		if sel then
			love.graphics.setColor(1, 1, 0)
			love.graphics.setLineWidth(2 / view.zoom)
			local s = 25 / view.zoom
			love.graphics.line(sel.obj.x - s, sel.obj.y, sel.obj.x + s, sel.obj.y)
			love.graphics.line(sel.obj.x, sel.obj.y - s, sel.obj.x, sel.obj.y + s)
			love.graphics.setLineWidth(1)
		end
	love.graphics.pop()

	love.graphics.setColor(1, 1, 0)
	love.graphics.print("=== SSERAFIM STAGE -- TODOS LOS PERSONAJES JUNTOS ===", 10, 10)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("J/K/L/I: paneo vista   U/O: zoom vista (" .. string.format("%.2f", view.zoom) .. ")   R: reset vista", 10, 30)
	love.graphics.print("Q/E: personaje anterior/siguiente   Flechas: mover (Shift=10)   Espacio: ciclar animacion", 10, 50)
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
	animCycleIndex = {}
end

return state
