--[[
Editor en vivo de offset/ángulo del sprite de lipsync (modules/lipsync.lua)
por personaje y por pose -- mismo patrón que sserafim-stage-debug.lua/
sserafim-cutscene-debug.lua (vista fija propia, J/K/L/I + U/O para
navegarla), pero además permite AJUSTAR EN VIVO el offset[x,y]/ángulo de
LIP_SYNC_DATA y ver el resultado al instante, en vez de editar
stages/sserafim/stage.lua a ciegas y recargar el juego entero por cada
prueba.

IMPORTANTE: LIPSYNC_DATA acá es una COPIA de la tabla real en
stages/sserafim/stage.lua -- no hay forma simple de importarla (es local
a ese módulo, no exportada) sin arriesgar tocar el stage real. Si se
edita una tabla, hay que copiar los valores finales a la OTRA a mano
(con el botón P de este editor, que imprime los valores listos para
pegar).

Controles:
  Q/E              : personaje anterior/siguiente (kazuha/chaewon/eunchae/yunjin/sakura)
  Espacio          : pose anterior/siguiente (idle/left/right/up/down[/-joint para sakura])
  Flechas          : ajustar offset[x,y] (Shift = paso x5, mantener repite)
  Z/X              : ajustar el ángulo (Shift = paso x5, mantener repite)
  A                : alternar "vincular todas las poses" -- con esto activo, cada
                     ajuste de offset/ángulo se aplica IGUAL (mismo delta) a TODAS
                     las poses del personaje actual, no solo a la seleccionada --
                     útil porque en la mayoría de los casos el desajuste es
                     consistente entre todas las poses de canto de un mismo
                     personaje, así que se puede corregir todo de una vez en lugar
                     de repetir el ajuste pose por pose.
  F                : alternar shouldSing (animar la boca vs. congelarla en un frame fijo, más fácil de ver la posición)
  J/K/L/I          : mover la vista (paneo)            U/O : zoom in/out vista
  R                : resetear zoom/paneo de la vista a 1x, (0,0)
  P                : imprimir LIP_SYNC_DATA completo (listo para copiar a stage.lua)
  Escape           : volver al menú de depuración
]]

local state = {}
local graphics, input, character, animateAtlas, lipsync

-- COPIA de stages/sserafim/stage.lua:LIPSYNC_DATA -- ver nota arriba.
-- CLAVES en la convención INTERNA del motor (charts/psych/animnames.lua:
-- toInternal() traduce "singLEFT" -> "left" etc ANTES de guardarlo en
-- animLookup -- sprite:animate()/getAnimName() trabajan con ese nombre
-- traducido, nunca con el crudo del JSON). "-joint" no se traduce
-- (ningún patrón de toInternal lo reconoce), así que esas claves se dejan
-- igual que el nombre real (bug encontrado en esta misma ronda: la
-- versión vieja de esta tabla, y la de stage.lua, usaban las claves
-- crudas "singLEFT" etc, que NUNCA coincidían con getAnimName() real).
local LIPSYNC_DATA = {
	kazuha = {
		atlasPath = "images/png/sserafim/lipsync",
		keyword = "mouth default",
		flipX = true,
		poses = {
			idle = { 5, 4, -13 }, up = { 7, 2, -14 }, right = { 7, 2, -13 },
			down = { 4, 6, -12 }, left = { 5, 4, -14 },
		},
	},
	chaewon = {
		atlasPath = "images/png/sserafim/lipsync",
		keyword = "mouth default",
		flipX = false,
		poses = {
			idle = { 41, 3, -166 }, up = { 38, 0, -168 }, right = { 39, 1, -165 },
			down = { 41, 3, -167 }, left = { 40, 2, -165 },
		},
	},
	eunchae = {
		atlasPath = "images/png/sserafim/lipsync",
		keyword = "mouth default",
		flipX = false,
		poses = {
			idle = { 43, 6, -168 }, up = { 45, 10, -166 }, right = { 42, 5, -166 },
			down = { 41, 3, -168 }, left = { 43, 6, -169 },
		},
	},
	yunjin = {
		atlasPath = "images/png/sserafim/lipsync-yunjin",
		keyword = "mouth yunjin",
		flipX = false,
		poses = {
			idle = { 8, 6, 23 }, up = { 6, 8, 22 }, right = { 6, 8, 23 },
			down = { 8, 6, 23 }, left = { 6, 8, 23 },
		},
	},
	sakura = {
		atlasPath = "images/png/sserafim/lipsync",
		keyword = "mouth edit",
		flipX = true,
		poses = {
			idle = { 7, 2, -14 }, up = { 8, 1, -15 }, right = { 7, 2, -15 },
			down = { 6, 3, -15 }, left = { 7, 2, -14 },
			["singUP-joint"] = { 10, -1, -14 }, ["singRIGHT-joint"] = { 6, 3, -15 },
			["singDOWN-joint"] = { 5, 5, -15 }, ["singLEFT-joint"] = { 7, 2, -16 },
		},
	},
}

local CHAR_ORDER = { "kazuha", "chaewon", "eunchae", "yunjin", "sakura" }
local CHAR_JSON = {
	kazuha = "characters/sserafim-kazuha.json",
	chaewon = "characters/sserafim-chaewon.json",
	eunchae = "characters/sserafim-eunchae.json",
	yunjin = "characters/sserafim-yunjin.json",
	sakura = "characters/sserafim-sakura.json",
}
-- sakura es la única "isPlayer" real (slot boyfriend, flip_x real true) --
-- mismo bug que se corrigió en sserafim-stage-debug.lua, ver ahí.
local CHAR_IS_PLAYER = { sakura = true }

-- Nombres en la convención INTERNA del motor (los mismos que las claves
-- de LIPSYNC_DATA.poses arriba) -- esto es lo que hay que pasarle a
-- sprite:animate() para que coincida con animLookup real.
local POSES_NORMAL = { "idle", "left", "right", "up", "down" }
local POSES_SAKURA = {
	"idle", "left", "right", "up", "down",
	"singLEFT-joint", "singRIGHT-joint", "singUP-joint", "singDOWN-joint",
}

local chars = {} -- [nombre] = sprite (charts.psych.character)
local lipsyncs = {} -- [nombre] = instancia modules/lipsync.lua
local selChar = 1
local selPoseIdx = 1
local mouthMat -- recalculado cada frame, ver state:update()

local view = { x = 0, y = 0, zoom = 1 }
local holdTime, holdElapsed = 0, 0
local linkAllPoses = false

local function curCharName() return CHAR_ORDER[selChar] end
local function curPoses() return (curCharName() == "sakura") and POSES_SAKURA or POSES_NORMAL end
local function curPoseName()
	local poses = curPoses()
	if selPoseIdx > #poses then selPoseIdx = 1 end
	return poses[selPoseIdx]
end
local function curPoseData()
	local ld = LIPSYNC_DATA[curCharName()]
	local pose = ld.poses[curPoseName()]
	if not pose then
		-- Mismo criterio que el real (LIP_SYNC_OFFSETS.exists() false):
		-- si esta pose no tiene entrada propia, no hay nada para
		-- editar -- se crea una en {0,0,0} para no romper el editor.
		pose = { 0, 0, 0 }
		ld.poses[curPoseName()] = pose
	end
	return pose
end

local function applyPose()
	local sprite = chars[curCharName()]
	sprite:animate(curPoseName(), true)
end

-- Ajusta offset[x,y]/ángulo. Si linkAllPoses está activo, aplica el MISMO
-- delta a TODAS las poses del personaje actual (no solo a la
-- seleccionada) -- conserva las diferencias relativas que ya estuvieran
-- afinadas entre poses, solo desplaza el conjunto entero junto.
local function adjustOffset(dx, dy, dAngle)
	if linkAllPoses then
		local ld = LIPSYNC_DATA[curCharName()]
		for _, p in pairs(ld.poses) do
			p[1] = p[1] + dx
			p[2] = p[2] + dy
			p[3] = p[3] + dAngle
		end
	else
		local pose = curPoseData()
		pose[1] = pose[1] + dx
		pose[2] = pose[2] + dy
		pose[3] = pose[3] + dAngle
	end
end

function state:enter()
	graphics = require("modules.graphics")
	input = require("input")
	character = require("charts.psych.character")
	animateAtlas = require("modules.animate_atlas")
	lipsync = require("modules.lipsync")

	chars = {}
	lipsyncs = {}
	for _, name in ipairs(CHAR_ORDER) do
		local sprite = character.load(CHAR_JSON[name], CHAR_IS_PLAYER[name] or false)
		local ox, oy = sprite:getOrigin()
		sprite.x, sprite.y = ox, oy
		sprite.visible = true
		chars[name] = sprite

		local ld = LIPSYNC_DATA[name]
		local lip = lipsync.new(ld.atlasPath)
		lip.flipX = ld.flipX
		lip.shouldSing = false
		lipsyncs[name] = lip
	end

	selChar = 1
	selPoseIdx = 1
	view.x, view.y, view.zoom = 0, 0, 1
	applyPose()

	graphics.fadeIn(0.3)
end

local function shiftDown() return love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") end

local function printLipsyncData()
	print("=== LIPSYNC_DATA (copiar a stages/sserafim/stage.lua) ===")
	for _, name in ipairs(CHAR_ORDER) do
		local ld = LIPSYNC_DATA[name]
		local parts = {}
		local poses = (name == "sakura") and POSES_SAKURA or POSES_NORMAL
		for _, poseName in ipairs(poses) do
			local p = ld.poses[poseName]
			if p then
				local key = poseName:find("-") and ("[\"" .. poseName .. "\"]") or poseName
				table.insert(parts, string.format("%s = { %d, %d, %d }", key, p[1], p[2], p[3]))
			end
		end
		print(name .. ":")
		print("\t" .. table.concat(parts, ", "))
	end
end

function state:update(dt)
	for _, name in ipairs(CHAR_ORDER) do
		chars[name]:update(dt)
	end

	local name = curCharName()
	local sprite = chars[name]
	local ld = LIPSYNC_DATA[name]
	local lip = lipsyncs[name]

	-- mouthMat: dónde cae el placeholder de boca en el frame ACTUAL del
	-- personaje seleccionado -- igual mecanismo que stage.lua, recalculado
	-- cada frame (ver charla sobre por qué esto NO se cachea).
	mouthMat = animateAtlas.findNamedTransform(sprite:getAtlasInstance(), ld.keyword)

	local pose = curPoseData()
	lip:setPoseOffset(pose[1], pose[2], pose[3])
	-- love.timer.getTime()*1000 como "tiempo de canción" falso, solo para
	-- poder probar la animación con F -- si shouldSing=false, MT:update()
	-- igual congela en frame 0 sin importar qué tiempo se le pase.
	lip:update(love.timer.getTime() * 1000)

	if input:pressed("q") then
		selChar = ((selChar - 2) % #CHAR_ORDER) + 1
		selPoseIdx = 1
		applyPose()
	end
	if input:pressed("e") then
		selChar = (selChar % #CHAR_ORDER) + 1
		selPoseIdx = 1
		applyPose()
	end
	if input:pressed("space") then
		local poses = curPoses()
		selPoseIdx = (selPoseIdx % #poses) + 1
		applyPose()
	end
	if input:pressed("f") then
		lip.shouldSing = not lip.shouldSing
	end

	if input:pressed("r") then view.x, view.y, view.zoom = 0, 0, 1 end
	if love.keyboard.isDown("j") then view.x = view.x - dt * 500 end
	if love.keyboard.isDown("l") then view.x = view.x + dt * 500 end
	if love.keyboard.isDown("k") then view.y = view.y + dt * 500 end
	if love.keyboard.isDown("i") then view.y = view.y - dt * 500 end
	if love.keyboard.isDown("u") then view.zoom = math.max(0.1, view.zoom - dt * view.zoom) end
	if love.keyboard.isDown("o") then view.zoom = math.min(10, view.zoom + dt * view.zoom) end

	if input:pressed("p") then printLipsyncData() end
	if input:pressed("a") then linkAllPoses = not linkAllPoses end

	local step = shiftDown() and 5 or 1

	if input:pressed("left")  then adjustOffset(-step, 0, 0) end
	if input:pressed("right") then adjustOffset(step, 0, 0) end
	if input:pressed("up")    then adjustOffset(0, -step, 0) end
	if input:pressed("down")  then adjustOffset(0, step, 0) end
	if input:pressed("z") then adjustOffset(0, 0, -step) end
	if input:pressed("x") then adjustOffset(0, 0, step) end

	local anyHeld = input:down("left") or input:down("right") or input:down("up") or input:down("down")
		or input:down("z") or input:down("x")
	if anyHeld then
		holdTime = holdTime + dt
		if holdTime > 0.6 then
			holdElapsed = holdElapsed + dt
			while holdElapsed > (1 / 60) do
				if input:down("left")  then adjustOffset(-step, 0, 0) end
				if input:down("right") then adjustOffset(step, 0, 0) end
				if input:down("up")    then adjustOffset(0, -step, 0) end
				if input:down("down")  then adjustOffset(0, step, 0) end
				if input:down("z") then adjustOffset(0, 0, -step) end
				if input:down("x") then adjustOffset(0, 0, step) end
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

		local name = curCharName()
		chars[name]:draw()

		if mouthMat then
			lipsyncs[name]:drawAt(mouthMat, 1)

			-- Cruz amarilla en mouthMat (la posición CRUDA del placeholder,
			-- ANTES del offset fino) -- para distinguir "el placeholder está
			-- mal calculado" de "el offset fino está mal".
			love.graphics.setColor(1, 1, 0)
			love.graphics.setLineWidth(2 / view.zoom)
			local s = 12 / view.zoom
			love.graphics.line(mouthMat.tx - s, mouthMat.ty, mouthMat.tx + s, mouthMat.ty)
			love.graphics.line(mouthMat.tx, mouthMat.ty - s, mouthMat.tx, mouthMat.ty + s)
			love.graphics.setLineWidth(1)
			love.graphics.setColor(1, 1, 1)
		end
	love.graphics.pop()

	love.graphics.setColor(1, 1, 0)
	love.graphics.print("=== SSERAFIM LIPSYNC EDITOR ===", 10, 10)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("J/K/L/I: paneo vista   U/O: zoom vista (" .. string.format("%.2f", view.zoom) .. ")   R: reset vista", 10, 30)
	love.graphics.print("Q/E: personaje anterior/siguiente   Espacio: pose anterior/siguiente   F: animar boca (" .. tostring(lipsyncs[curCharName()].shouldSing) .. ")", 10, 50)
	love.graphics.print("Flechas: ajustar offset x,y (Shift=x5)   Z/X: ajustar angulo (Shift=x5)   P: imprimir todo   Escape: volver", 10, 70)

	love.graphics.setColor(linkAllPoses and 0 or 1, 1, linkAllPoses and 0 or 1)
	love.graphics.print("A: vincular todas las poses del personaje (" .. (linkAllPoses and "ACTIVO -- el ajuste se aplica a TODAS" or "inactivo -- solo a la pose actual") .. ")", 10, 90)

	local pose = curPoseData()
	love.graphics.setColor(1, 1, 0)
	love.graphics.print("Personaje: " .. curCharName() .. "  (" .. selChar .. "/" .. #CHAR_ORDER .. ")   Pose: " .. curPoseName(), 10, 110)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(string.format("offset = %d, %d   angulo = %d", pose[1], pose[2], pose[3]), 10, 130)
	if mouthMat then
		love.graphics.print(string.format("mouthMat: tx=%.1f ty=%.1f  (cruz amarilla = placeholder crudo, sin offset)", mouthMat.tx, mouthMat.ty), 10, 150)
	else
		love.graphics.print("mouthMat: nil (esta pose no tiene placeholder de boca en este personaje)", 10, 150)
	end
	love.graphics.setColor(1, 1, 1)
end

function state:leave()
	chars = {}
	lipsyncs = {}
	mouthMat = nil
end

return state
