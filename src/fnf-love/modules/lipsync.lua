-- Sprite de lipsync de Sserafim -- puerto de
-- preload/scripts/stages/props/SserafimLipSyncSprite.hxc (funkin.assets-main).
--
-- Mecanismo real (NO es texto-a-fonema ni depende de eventos del chart):
-- el atlas tiene UN símbolo raíz de ~4100 frames -- básicamente toda la
-- canción dibujada cuadro por cuadro a 24fps. El frame a mostrar es
-- simplemente "tiempo de canción * 24fps", igual que el real
-- ("curFrame = floor(Conductor.songPosition/1000 * 24) - 1"). Si
-- shouldSing es false, se congela en el frame 0 (boca cerrada/neutra).
--
-- En el juego real, este sprite se INYECTA directo dentro del árbol de
-- símbolos del propio personaje (en cada keyframe que tenga un elemento
-- llamado "mouth default"/"mouth edit"/"mouth yunjin" -- ver
-- getFramesWithKeyword() en los .hxc reales), así hereda automáticamente
-- la posición/rotación de la cabeza en cada frame. Este motor no puede
-- modificar el árbol de símbolos en runtime, así que en cambio se CALCULA
-- dónde caería esa inyección (animateAtlas.findNamedTransform(), buscando
-- ese mismo nombre dentro del personaje) y se dibuja el lipsync aparte,
-- en esa posición -- mismo resultado visual, sin tocar el árbol del
-- personaje.

local animateAtlas = require("modules.animate_atlas")

local M = {}
local MT = {}
MT.__index = MT

-- Composición de matrices afines 2x2+traslación -- mismo álgebra que
-- composeAffine() en animate_atlas.lua (no exportada de ahí, se duplica
-- acá -- es una sola multiplicación de matrices, no vale la pena exponer
-- una API nueva solo para esto). compose(P, C): aplica C primero, P
-- después (point -> C(point) -> P(C(point))).
local function compose(p, c)
	return {
		a = p.a * c.a + p.c * c.b,
		b = p.b * c.a + p.d * c.b,
		c = p.a * c.c + p.c * c.d,
		d = p.b * c.c + p.d * c.d,
		tx = p.a * c.tx + p.c * c.ty + p.tx,
		ty = p.b * c.tx + p.d * c.ty + p.ty,
	}
end

-- folderPath: "images/png/sserafim/lipsync" o "images/png/sserafim/lipsync-yunjin"
-- (yunjin usa un atlas de boca propio, distinto del genérico que comparten
-- kazuha/chaewon/eunchae/sakura -- ver SserafimLipSyncSprite(0,0,'yunjin')
-- real vs el resto sin sufijo).
function M.new(folderPath)
	local data = animateAtlas.load(folderPath)
	local inst = animateAtlas.newInstance(data)
	inst.symbolName = data.rootSymbolName
	-- inst.frame ya arranca en 0 (default de newInstance()) -- IMPORTANTE
	-- calcular el centro ACÁ, antes de que nada cambie inst.frame.

	local totalLen = animateAtlas.symbolLength(data, data.rootSymbolName)

	-- BUG corregido: el centro (usado como pivote de rotación, ver
	-- drawAt()) se recalculaba en CADA frame según el contenido visible
	-- de ESE frame puntual -- pero el "origin" real de Flixel
	-- (FlxSprite.origin, default frameWidth/2,frameHeight/2) se calcula
	-- UNA SOLA VEZ al crear/asignar la animación del sprite (vía
	-- updateHitbox() interno) y NUNCA se recalcula de nuevo al cambiar
	-- de frame, así que si los distintos frames de boca varían un poco
	-- de tamaño/posición, recalcularlo cada vez genera un desajuste
	-- sistemático (reportado: "consistente en todas, mismo lado, misma
	-- magnitud" -- exactamente la firma de este tipo de bug). Se calcula
	-- UNA vez acá (frame 0, el mismo "default" que usaría Flixel al
	-- construir el sprite) y se cachea.
	local minX, minY, w, h = animateAtlas.getInstanceBounds(inst)
	local centerX, centerY = minX + w / 2, minY + h / 2

	return setmetatable({
		data = data,
		inst = inst,
		totalLen = totalLen,
		centerX = centerX,
		centerY = centerY,
		shouldSing = false,
		offsetX = 0,
		offsetY = 0,
		angle = 0,
		flipX = false,
		shader = nil,
	}, MT)
end

-- musicTimeMs: tiempo actual de la canción (weeks:getMusicTime(), en ms).
-- Set DIRECTO del frame -- a diferencia de Instance:update(dt) (que
-- acumula por dt), el real deriva el frame DIRECTO del tiempo de canción
-- cada vez, sin acumulación -- así nunca se desincroniza con la música
-- aunque haya saltos de frame/lag.
function MT:update(musicTimeMs)
	if self.shouldSing then
		local f = math.floor(((musicTimeMs or 0) / 1000) * self.data.frameRate) - 1
		if f < 0 then f = 0 end
		if f >= self.totalLen then f = self.totalLen - 1 end
		self.inst.frame = f
	else
		self.inst.frame = 0
	end
end

-- Actualiza el offset/ángulo fino (por pose) -- llamado SOLO cuando la
-- animación actual del personaje dueño existe en su tabla de
-- LIP_SYNC_OFFSETS (igual condición que el real, ver
-- "LIP_SYNC_OFFSETS.exists(name)" en los .hxc) -- si no existe (p.ej.
-- poses sin entrada propia como "-bf1"/"-bf2"/"-miss" en sakura), el
-- offset/ángulo se queda en el último valor aplicado, no se resetea.
function MT:setPoseOffset(offsetX, offsetY, angle)
	self.offsetX = offsetX
	self.offsetY = offsetY
	self.angle = angle
end

-- mouthMat: matriz en espacio de MUNDO de dónde cae el placeholder de
-- boca del personaje dueño en su frame ACTUAL (animateAtlas.
-- findNamedTransform(ownerInst, keyword) -- nil si esa pose no tiene
-- placeholder de boca, p.ej. getup/cutscene/doorclosed/kick).
function MT:drawAt(mouthMat, alpha)
	if not mouthMat then return end

	-- TERCER intento -- esta vez con la fórmula CONFIRMADA leyendo el
	-- código fuente real exacto: hmm.json (Funkin-main) fija la
	-- dependencia "flixel-animate" en el commit c5e3393 de
	-- github.com/MaybeMaru/flixel-animate (un fork DISTINTO al
	-- Dot-Stuff/flxanimate 4.0.0 disponible en haxelib local -- por eso
	-- las dos rondas anteriores fueron a ciegas). Bajado directo de ahí
	-- src/animate/internal/elements/FlxSpriteElement.hx
	-- (applyObjectTransform()), más flixel/FlxObject.hx
	-- (getScreenPosition()) y flixel/FlxSprite.hx (drawComplex()), ya
	-- disponibles localmente. La fórmula real, paso a paso:
	--   1. x,y = parentMatrix.transform(basic.x, basic.y) -- como
	--      basic.x/y siempre es (0,0) para este sprite, esto da
	--      EXACTAMENTE parentMatrix.tx/ty (su traslación pura, SIN
	--      rotación/escala) -- confirma que "solo posición" de la ronda
	--      23 iba en la dirección correcta.
	--   2. basic.angle += atan2(parentMatrix.b, parentMatrix.a)*180/pi
	--      -- el ángulo heredado del padre se SUMA como ESCALAR, JAMÁS
	--      se compone como matriz.
	--   3. flipX es una propiedad SEPARADA e independiente de Flixel
	--      (espeja el muestreo de textura, no la rotación/geometría) --
	--      JAMÁS se hereda del padre, solo viene de LIP_SYNC_OFFSETS.
	--      (la ronda 23 fallaba exactamente en los puntos 2 y 3: ahí
	--      tiraba la rotación del padre por completo, y antes de eso --
	--      ronda 21 -- la componía como matriz junto al flip, lo cual
	--      para ángulos cercanos a 180° -- chaewon/eunchae -- intercambia
	--      qué eje se ve espejado, porque rotar 180° tras un flip en X
	--      da el mismo resultado que un flip en Y).
	--   4. drawComplex() real: la posición final del PIVOTE es
	--      "getScreenPosition() - offset + origin", con origin=CENTRO
	--      del frame actual (default de Flixel) -- o sea el offset se
	--      RESTA (no se suma) y la rotación ocurre alrededor del CENTRO
	--      del frame, no de su esquina superior izquierda (a diferencia
	--      de cómo este motor dibuja símbolos Adobe Animate normales,
	--      anclados a su (0,0) local).
	local parentAngle = math.atan2(mouthMat.b, mouthMat.a) * 180 / math.pi
	local totalAngle = (self.angle or 0) + parentAngle
	local rad = math.rad(totalAngle)
	local cosA, sinA = math.cos(rad), math.sin(rad)
	local flip = self.flipX and -1 or 1

	-- self.centerX/Y: calculado UNA sola vez en M.new() (frame 0), NO
	-- recalculado acá -- ver el comentario en M.new() sobre por qué.
	local centerMat = { a = 1, b = 0, c = 0, d = 1, tx = -self.centerX, ty = -self.centerY }
	local rotMat = { a = cosA * flip, b = sinA * flip, c = -sinA, d = cosA, tx = 0, ty = 0 }
	local pivotMat = {
		a = 1, b = 0, c = 0, d = 1,
		tx = mouthMat.tx - (self.offsetX or 0),
		ty = mouthMat.ty - (self.offsetY or 0),
	}

	local finalMat = compose(compose(pivotMat, rotMat), centerMat)

	animateAtlas.drawAtMatrix(
		self.data, self.data.rootSymbolName, math.floor(self.inst.frame),
		finalMat, 1, 1, 1, alpha or 1, self.shader
	)
end

return M
