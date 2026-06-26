--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten
------------------------------------------------------------------------------]]

--[[
Editor de offsets de la mecánica de armas de Weekend 1 -- compara
picoShootingSprite/picoIntroSprite/casquillo/lata-explosión contra el Pico
jugable normal ("idle", semitransparente, de referencia), con la misma
fórmula de posición que usa stages/phillyStreets/stage.lua en el juego real.

Controles:
  Tab              : cambiar de categoría (Pico_Shooting/Pico_Intro/Casquillo/Lata)
  W/S              : pose/sub-objetivo anterior/siguiente dentro de la categoría
  Flechas          : mover el offset activo (Shift = paso 10)
  Espacio          : repetir/disparar la animación activa desde el principio
  J/K/L/I          : mover la vista     E/Q : zoom vista     R : reset zoom
  F2               : imprimir todos los offsets finales (consola)
  Escape           : volver al menú de depuración
]]

local state = {}
local graphics, character

local boyfriendRef
local categories = {
	{
		kind = "atlas",
		label = "Pico_Shooting",
		loader = "sprites/weekend1/pico-shooting.lua",
		poses = {"shoot", "shootMISS", "cock"},
		baseline = {shoot = {149, 151}, shootMISS = {-4, -2}, cock = {22, -7}},
	},
	{
		kind = "atlas",
		label = "Pico_Intro",
		loader = "sprites/weekend1/pico-intro.lua",
		poses = {"intro1", "cockCutscene", "intro2"},
		baseline = {intro1 = {8, 0}, cockCutscene = {40, 13}, intro2 = {145, 151}},
	},
	{
		-- Casquillo: posición relativa a Pico ("bfTLX+250, bfTLY+260" en
		-- stage.lua) -- un solo "pose" (su posición de aparición).
		kind = "casing",
		label = "Casquillo",
		poses = {"posicion"},
		baseline = {posicion = {250, 260}},
	},
	{
		-- Lata/explosión: NO relativa a Pico -- relativa a spraycanPile
		-- (920,1045 Psych). 2 sub-objetivos: posición de la lata misma
		-- ("920+530,1045-240" en stage.lua) y el offset de la explosión
		-- relativo a la lata ("lata.x-25,lata.y-450" en spraycan.lua).
		kind = "spraycan",
		label = "Lata/Explosión",
		poses = {"lata", "explosion"},
		baseline = {lata = {569, -240}, explosion = {282, -145}},
	},
}

local curCatIdx = 1
local curPoseIdx = 1
local objs = {}    -- [catIdx] = sprite/instancia cargada (atlas) o módulo (casing/spraycan)
local deltas = {}  -- [catIdx][poseName] = {x=, y=}

local camView = {x = 0, y = 0, zoom = 1}
local holdTime, holdElapsed = 0, 0

local function shiftDown()
	return love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
end

local function curCat() return categories[curCatIdx] end
local function curPoseName() return curCat().poses[curPoseIdx] end

local function ensureDeltas(catIdx)
	if deltas[catIdx] then return end
	deltas[catIdx] = {}
	for _, pose in ipairs(categories[catIdx].poses) do
		deltas[catIdx][pose] = {x = 0, y = 0}
	end
end

-- Misma fórmula EXACTA que stages/phillyStreets/stage.lua:picoTopLeft() --
-- boyfriendRef está en (0,0), así que esto da directamente el "Psych
-- top-left" equivalente.
local function picoTopLeft()
	local ox, oy = boyfriendRef:getOrigin()
	return 0 - ox, 0 - oy
end

local function applyDelta()
	local cat = curCat()
	if cat.kind ~= "atlas" then return end
	local sprite = objs[curCatIdx]
	if not sprite then return end
	local d = deltas[curCatIdx][curPoseName()]
	sprite.offsetX = d.x
	sprite.offsetY = d.y
end

local function switchPose(index)
	local poses = curCat().poses
	curPoseIdx = ((index - 1) % #poses) + 1
	if curCat().kind == "atlas" then
		local sprite = objs[curCatIdx]
		if sprite then
			sprite:animate(curPoseName(), false)
			applyDelta()
		end
	end
end

local function loadCategory(catIdx)
	local cat = categories[catIdx]
	if cat.kind == "atlas" then
		objs[catIdx] = love.filesystem.load(cat.loader)()
	elseif cat.kind == "casing" then
		local casingModule = require("sprites.weekend1.casing")
		objs[catIdx] = casingModule.new(0, 0)
	elseif cat.kind == "spraycan" then
		local spraycanModule = require("sprites.weekend1.spraycan")
		objs[catIdx] = spraycanModule.new(0, 0)
	end
end

local function switchCategory(index)
	curCatIdx = ((index - 1) % #categories) + 1
	curPoseIdx = 1
	ensureDeltas(curCatIdx)
	if not objs[curCatIdx] then loadCategory(curCatIdx) end
	switchPose(1)
end

-- Dispara/repite la acción activa según la categoría (Espacio).
local function triggerActive()
	local cat = curCat()
	local obj = objs[curCatIdx]
	if not obj then return end

	if cat.kind == "atlas" then
		obj:animate(curPoseName(), false)
	elseif cat.kind == "casing" then
		-- Recrear: casing.lua no tiene "replay", se recrea desde cero.
		local casingModule = require("sprites.weekend1.casing")
		objs[curCatIdx] = casingModule.new(0, 0)
	elseif cat.kind == "spraycan" then
		-- Disparo AISLADO según el sub-objetivo activo -- antes siempre
		-- llamaba playCanStart() (la secuencia completa lata->impacto->
		-- explosión) sin importar cuál se estuviera ajustando, dando la
		-- impresión de que estaban "fusionadas" en una sola animación.
		if curPoseName() == "explosion" then
			obj:debugPlayExplosionOnly()
		else
			obj:playCanStart()
		end
	end
end

function state:enter()
	graphics = require("modules.graphics")
	character = require("charts.psych.character")

	boyfriendRef = character.load("characters/pico-playable.json", true)
	boyfriendRef.x, boyfriendRef.y = 0, 0
	boyfriendRef:animate("idle", false)

	objs = {}
	deltas = {}
	camView.x, camView.y, camView.zoom = 0, 0, 1
	switchCategory(1)
end

function state:update(dt)
	boyfriendRef:update(dt)
	local obj = objs[curCatIdx]
	if obj and obj.update then obj:update(dt) end

	local shiftMult = shiftDown() and 4 or 1
	if love.keyboard.isDown("j") then camView.x = camView.x + dt * 500 * shiftMult end
	if love.keyboard.isDown("l") then camView.x = camView.x - dt * 500 * shiftMult end
	if love.keyboard.isDown("k") then camView.y = camView.y + dt * 500 * shiftMult end
	if love.keyboard.isDown("i") then camView.y = camView.y - dt * 500 * shiftMult end
	if input:pressed("r") then
		camView.zoom = 1
	elseif love.keyboard.isDown("e") and camView.zoom < 5 then
		camView.zoom = math.min(5, camView.zoom + dt * camView.zoom)
	elseif love.keyboard.isDown("q") and camView.zoom > 0.1 then
		camView.zoom = math.max(0.1, camView.zoom - dt * camView.zoom)
	end

	if input:pressed("back") then
		Gamestate.switch(debugMenu)
		return
	end

	if #categories > 1 and input:pressed("tab") then switchCategory(curCatIdx + 1) end
	if #curCat().poses > 1 then
		if input:pressed("w") then switchPose(curPoseIdx - 1) end
		if input:pressed("s") then switchPose(curPoseIdx + 1) end
	end

	if input:pressed("space") then triggerActive() end

	local d = deltas[curCatIdx][curPoseName()]
	local step = shiftDown() and 10 or 1
	local changed = false

	if input:pressed("left") then d.x = d.x + step; changed = true end
	if input:pressed("right") then d.x = d.x - step; changed = true end
	if input:pressed("up") then d.y = d.y + step; changed = true end
	if input:pressed("down") then d.y = d.y - step; changed = true end

	if input:down("left") or input:down("right") or input:down("up") or input:down("down") then
		holdTime = holdTime + dt
		if holdTime > 0.6 then
			holdElapsed = holdElapsed + dt
			while holdElapsed > (1 / 60) do
				if input:down("left") then d.x = d.x + step; changed = true end
				if input:down("right") then d.x = d.x - step; changed = true end
				if input:down("up") then d.y = d.y + step; changed = true end
				if input:down("down") then d.y = d.y - step; changed = true end
				holdElapsed = holdElapsed - (1 / 60)
			end
		end
	else
		holdTime, holdElapsed = 0, 0
	end

	if changed then applyDelta() end

	if input:pressed("f2") then
		print("=== Offsets finales (baseline + delta editado) ===")
		for ci, cat in ipairs(categories) do
			print(cat.label .. ":")
			for _, pose in ipairs(cat.poses) do
				local base = cat.baseline[pose]
				local dd = deltas[ci] and deltas[ci][pose] or {x = 0, y = 0}
				print(string.format("  %s = {%d, %d}", pose, base[1] + dd.x, base[2] + dd.y))
			end
		end
	end
end

function state:draw()
	love.graphics.push()
	love.graphics.origin()
	love.graphics.translate(graphics.getWidth() / 2 + camView.x, graphics.getHeight() / 2 + camView.y)
	love.graphics.scale(camView.zoom)

	love.graphics.setColor(1, 1, 1, 0.45)
	boyfriendRef:draw()

	local cat = curCat()
	local obj = objs[curCatIdx]
	local tlX, tlY = picoTopLeft()

	if cat.kind == "atlas" and obj then
		local sOx, sOy = obj:getOrigin()
		obj.x, obj.y = tlX + sOx, tlY + sOy
		love.graphics.setColor(1, 1, 1, 1)
		obj:draw()
	elseif cat.kind == "casing" and obj then
		local d = deltas[curCatIdx].posicion
		local base = cat.baseline.posicion
		obj.x = tlX + base[1] + d.x
		obj.y = tlY + base[2] + d.y
		love.graphics.setColor(1, 1, 1, 1)
		obj:draw()
	elseif cat.kind == "spraycan" and obj then
		-- spraycan NO es relativo a Pico -- es relativo a spraycanPile,
		-- que acá se trata como el origen mundial (0,0) directamente
		-- (equivalente a psychX=0,psychY=0 para este editor aislado).
		local dLata = deltas[curCatIdx].lata
		local baseLata = cat.baseline.lata
		obj.x = baseLata[1] + dLata.x
		obj.y = baseLata[2] + dLata.y
		-- El offset de explosión se aplica DENTRO de spraycan:draw() usando
		-- los valores -25/-450 hardcodeados -- para previsualizar el delta
		-- editado, se sobreescribe temporalmente esa lógica acá calculando
		-- a mano (mismo getOrigin() que spraycan.lua aplica de verdad).
		love.graphics.setColor(1, 1, 1, 1)
		if obj.visible and obj.active then
			obj.canInst.x, obj.canInst.y = obj.x, obj.y
			obj.canInst:draw()
		end
		if obj.explosion.visible then
			local dExp = deltas[curCatIdx].explosion
			local baseExp = cat.baseline.explosion
			local exOx, exOy = obj.explosion:getOrigin()
			obj.explosion.x = obj.x + baseExp[1] + dExp.x + exOx
			obj.explosion.y = obj.y + baseExp[2] + dExp.y + exOy
			obj.explosion:draw()
		end
	end

	love.graphics.setColor(0, 1, 0, 0.8)
	love.graphics.setLineWidth(2 / camView.zoom)
	local s = 20 / camView.zoom
	love.graphics.line(-s, 0, s, 0)
	love.graphics.line(0, -s, 0, s)

	love.graphics.pop()

	love.graphics.setColor(1, 1, 1, 1)
	local d = deltas[curCatIdx][curPoseName()]
	local base = cat.baseline[curPoseName()]
	local extra = ""
	if cat.kind == "spraycan" then
		extra = "\n(la cruz verde = spraycanPile; F2 imprime lata Y explosión)"
	end
	love.graphics.print(string.format(
		"Categoria: %s (Tab)   Sub-objetivo: %s (W/S)\nOffset final: {%d, %d}  (baseline {%d,%d} + delta {%d,%d})\nFlechas: mover (Shift=10x)   Espacio: repetir/disparar   F2: imprimir todo   Esc: volver%s",
		cat.label, curPoseName(),
		base[1] + d.x, base[2] + d.y, base[1], base[2], d.x, d.y, extra
	), 20, 20)
end

function state:leave()
	boyfriendRef = nil
	objs = {}
end

return state
