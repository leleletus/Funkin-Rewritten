-- Reproductor de "Adobe Animate Texture Atlas" (el formato que exporta Adobe
-- Animate como spritemap1.png + spritemap1.json + Animation.json -- usado
-- por Psych real para las cutscenes de semana 7 vía flxanimate/FlxAnimate,
-- NO el sistema de sprite-sheet simple que usa el resto del juego).
--
-- Formato (verificado leyendo Animation.json real de
-- assets/base_game/week7/images/cutscenes/tankman/ con Python):
--   Animation.json = { AN = <timeline raíz, sin usar acá>,
--                       SD = { S = { {SN=nombre, TL={L=capas}}, ... } },
--                       MD = { FRT = fps } }
--   Cada capa (L) = { LN = nombre, FR = { {I=indiceInicio, DU=duracion, E=elementos}, ... } }
--   Cada elemento (E) es UNO de:
--     { SI = { SN=nombreSimboloHijo, FF=primerFrameHijo, LP="LP"|"PO"|"SF",
--              M3D = matriz 4x4 columna-mayor (16 numeros) } }   -- instancia de símbolo (recursivo)
--     { ASI = { N=nombreSpriteEnAtlas, M3D = matriz 4x4 } }       -- bitmap hoja (atlas)
--   spritemap1.json = { ATLAS = { SPRITES = { {SPRITE={name,x,y,w,h,rotated}}, ... } } }
--
-- M3D: confirmado columna-mayor (índices 0-based 12,13 = traslación x,y,
-- 0,1,4,5 = submatriz afín 2x2 a,b,c,d -- igual que un Matrix/Matrix3D de
-- Flash). TRP ("transformation point") es metadata del editor para el
-- pivote de la herramienta -- el M3D ya es el transform completo hijo->
-- padre, no hace falta restar TRP para componerlo.
--
-- Orden de dibujado: confirmado contra el FlxAnimate real (haxelib
-- Dot-Stuff/flxanimate, FlxAnimate.hx:parseElement). Las CAPAS sí van en
-- reversa: el PRIMERO de la lista es el de más arriba en el panel de
-- capas = se dibuja AL FRENTE, así que hay que recorrer la lista de capas
-- de atrás para adelante (última capa primero/atrás, primera capa
-- último/encima). Los ELEMENTOS dentro del frame de UNA capa (fr.E) NO
-- van en reversa -- FlxAnimate los recorre en orden normal
-- ("for (element in frame.getList())"). Ver renderSymbol() más abajo.
--
-- Símbolos "Graphic" (ST="G", el único tipo que usan estos assets): el
-- frame que muestra un símbolo hijo NO avanza con su propio reloj -- lo
-- decide el padre en cada keyframe vía FF + el modo de loop:
--   "SF" (single frame): siempre FF, sin importar cuánto dure el keyframe.
--   "LP" (loop): FF + (framesTranscurridosDesdeElInicioDeEsteKeyframe % largoDelHijo)
--   "PO" (play once): FF + transcurridos, clampeado a largoDelHijo-1.
-- "largoDelHijo" = max(I+DU) de todas las capas del símbolo hijo.

local json = require("lib.json")

local M = {}

local atlasCache = {}

local function loadJSON(path)
	local raw, err = love.filesystem.read(path)
	if not raw then
		error("animate_atlas: no se pudo leer '" .. path .. "': " .. tostring(err))
	end
	-- Algunos exports de Animate llevan BOM UTF-8 -- quitarlo si está.
	if raw:byte(1) == 0xEF and raw:byte(2) == 0xBB and raw:byte(3) == 0xBF then
		raw = raw:sub(4)
	end
	return json.decode(raw)
end

-- Adobe Animate exporta Animation.json en 2 formatos equivalentes según
-- versión/config de export: "corto" (AN/SD/MD -- usado por los assets de
-- semana 7, picoBlazin/darnellBlazin/spraycanAtlas) o "largo"/legible
-- (ANIMATION/SYMBOL_DICTIONARY/metadata -- usado por los assets de A-Bot,
-- confirmado leyendo abot/abotSystem/Animation.json real). Mismo
-- contenido, distintas claves -- se normaliza UNA vez al cargar, así el
-- resto del archivo (renderSymbol, symbolLength, etc.) no necesita
-- ninguna rama condicional adicional.
local function convertMatrix3D(m)
	if not m then return nil end
	if m.m00 == nil then return m end  -- ya es el array plano corto (M3D)
	-- formato largo: objeto {m00..m33} fila-mayor -> array 16 plano
	-- (mismo orden que documenta la cabecera del archivo: columna-mayor
	-- con índices 0,1,4,5 = afín 2x2, 12,13 = traslación -- fila-mayor
	-- "m<fila><col>" con índice = fila*4+col da exactamente esos lugares).
	return {
		m.m00, m.m01, m.m02, m.m03,
		m.m10, m.m11, m.m12, m.m13,
		m.m20, m.m21, m.m22, m.m23,
		m.m30, m.m31, m.m32, m.m33,
	}
end

local function convertLoop(loop)
	if loop == "loop" then return "LP"
	elseif loop == "play once" then return "PO"
	elseif loop == "single frame" then return "SF"
	else return loop end  -- ya es corto (LP/SF/PO) o nil
end

local function convertElement(el)
	if el.SYMBOL_Instance then
		local si = el.SYMBOL_Instance
		return { SI = {
			SN = si.SYMBOL_name,
			FF = si.firstFrame,
			LP = convertLoop(si.loop),
			M3D = convertMatrix3D(si.Matrix3D),
		} }
	elseif el.ATLAS_SPRITE_instance then
		local asi = el.ATLAS_SPRITE_instance
		return { ASI = {
			N = asi.name,
			M3D = convertMatrix3D(asi.Matrix3D),
		} }
	end
	return el  -- ya es formato corto (SI/ASI)
end

local function convertSymbol(sym)
	if not sym.SYMBOL_name then return sym end  -- ya es formato corto (SN/TL)

	local layers = {}
	for _, layer in ipairs(sym.TIMELINE.LAYERS) do
		local frames = {}
		for _, fr in ipairs(layer.Frames) do
			local elements = {}
			for _, el in ipairs(fr.elements or {}) do
				table.insert(elements, convertElement(el))
			end
			table.insert(frames, { I = fr.index, DU = fr.duration, E = elements })
		end
		table.insert(layers, { LN = layer.Layer_name, FR = frames })
	end

	return { SN = sym.SYMBOL_name, TL = { L = layers } }
end

local function normalizeAnimJSON(animJSON)
	if animJSON.SD then return animJSON end  -- ya es formato corto

	local symbols = {}
	for _, sym in ipairs(animJSON.SYMBOL_DICTIONARY.Symbols) do
		table.insert(symbols, convertSymbol(sym))
	end

	return {
		AN = convertSymbol(animJSON.ANIMATION),
		SD = { S = symbols },
		MD = { FRT = (animJSON.metadata and animJSON.metadata.framerate) or 24 },
	}
end

-- folderPath: carpeta que contiene spritemap1.png/.json y Animation.json
-- (p.ej. "images/png/week7/cutscenes/tankman"). Cacheado por carpeta.
function M.load(folderPath)
	if atlasCache[folderPath] then return atlasCache[folderPath] end

	local image = love.graphics.newImage(folderPath .. "/spritemap1.png")
	local atlasJSON = loadJSON(folderPath .. "/spritemap1.json")
	local animJSON  = normalizeAnimJSON(loadJSON(folderPath .. "/Animation.json"))

	local regions = {}
	for _, entry in ipairs(atlasJSON.ATLAS.SPRITES) do
		local s = entry.SPRITE
		regions[s.name] = { x = s.x, y = s.y, w = s.w, h = s.h }
	end

	local symbols = {}
	for _, s in ipairs(animJSON.SD.S) do
		symbols[s.SN] = s.TL
	end
	-- AN/ANIMATION: el timeline RAÍZ (no listado en SD.S) también puede
	-- jugarse por nombre directo (p.ej. A-Bot real: playSymbol("Abot
	-- System", ...)/("a bot eyes lookin", ...) referencian el root, no una
	-- entrada del diccionario) -- se registra igual que cualquier símbolo.
	if animJSON.AN and animJSON.AN.SN then
		symbols[animJSON.AN.SN] = animJSON.AN.TL
	end

	local data = {
		image      = image,
		imgW       = image:getWidth(),
		imgH       = image:getHeight(),
		regions    = regions,
		symbols    = symbols,
		frameRate  = (animJSON.MD and animJSON.MD.FRT) or 24,
		quadCache  = {},
		lengthCache = setmetatable({}, { __mode = "k" }),
		-- Expuesto para casos como modules/lipsync.lua: atlas de un solo
		-- símbolo raíz gigante (sin animaciones nombradas en SD.S) donde se
		-- necesita jugar/inspeccionar el símbolo raíz directo por nombre,
		-- sin que el código que llama tenga que conocerlo de antemano.
		rootSymbolName = (animJSON.AN and animJSON.AN.SN) or nil,
	}

	atlasCache[folderPath] = data
	return data
end

local function getQuad(data, spriteName)
	local q = data.quadCache[spriteName]
	if q then return q end

	local r = data.regions[spriteName]
	if not r then return nil end

	q = love.graphics.newQuad(r.x, r.y, r.w, r.h, data.imgW, data.imgH)
	data.quadCache[spriteName] = q
	return q
end

-- Largo (en frames) de un símbolo: el mayor (I+DU) entre todas sus capas.
-- Symbols sin ninguna capa/frame (no debería pasar) devuelven 1.
local function symbolLength(data, timeline)
	local cached = data.lengthCache[timeline]
	if cached then return cached end

	local maxLen = 1
	for _, layer in ipairs(timeline.L) do
		for _, fr in ipairs(layer.FR) do
			local endIdx = fr.I + fr.DU
			if endIdx > maxLen then maxLen = endIdx end
		end
	end

	data.lengthCache[timeline] = maxLen
	return maxLen
end

-- Exportado (M.symbolLength) para charts/psych/character.lua:
-- getFrameCount()/setFrame() -- necesita el largo del símbolo activo
-- cuando NO hay rango (animación por nombre directo, ver
-- loadAnimateCharacter()), y este cálculo ya existe acá.
M.symbolLength = function(data, symbolName)
	local timeline = data.symbols[symbolName]
	if not timeline then return 1 end
	return symbolLength(data, timeline)
end

-- Encuentra la entrada de frame (I/DU/E) que cubre frameIdx dentro de la
-- lista FR de una capa. Las listas son chicas (decenas de entradas), un
-- escaneo lineal alcanza sobra.
local function findFrameEntry(layerFR, frameIdx)
	for _, fr in ipairs(layerFR) do
		if frameIdx >= fr.I and frameIdx < fr.I + fr.DU then
			return fr
		end
	end
	return nil
end

-- inst: la tabla SI/ASI completa (no solo la matriz) -- algunos exports
-- (confirmado en images/png/menu/title-screen-text/Animation.json, un
-- export "BTA" -- ver MD.V/MD.N del archivo) usan una TERCERA variante de
-- formato: claves top-level cortas (AN/SD/MD, iguales a las que
-- normalizeAnimJSON ya reconoce como "formato corto" y deja sin tocar)
-- pero la matriz viene como "MX" -- un array PLANO de 6 números
-- [a,b,c,d,tx,ty] (convención Matrix de Flash/AS3 directa), NO "M3D" (16
-- números columna-mayor). Como normalizeAnimJSON no entra a convertElement
-- para este formato (ve SD y lo da por "ya corto"), hay que reconocer MX
-- acá mismo, en el punto de uso, en vez de mutar el JSON entero al cargar.
local function affineFromInstance(inst)
	if inst.MX then
		local mx = inst.MX
		return { a = mx[1], b = mx[2], c = mx[3], d = mx[4], tx = mx[5], ty = mx[6] }
	end
	-- m3d: tabla Lua 1-indexada de 16 números (columna-mayor, ver cabecera).
	local m3d = inst.M3D
	return {
		a = m3d[1],  b = m3d[2],
		c = m3d[5],  d = m3d[6],
		tx = m3d[13], ty = m3d[14],
	}
end

-- Transformación de color "C" de una instancia SI/ASI (si existe) sobre
-- el color heredado del padre -- otra pieza del formato "BTA" (ver
-- affineFromInstance() arriba) sin equivalente en el formato largo/corto
-- ya soportado, así que es un no-op (return r,g,b,a sin cambios) para
-- TODOS los assets existentes (nunca tienen este campo). "CA" (Color
-- Alpha) multiplica solo el alpha por AM; "AD" (Advanced) multiplica
-- r/g/b/a por RM/GM/BM/AM y SUMA RO/GO/BO/AO (offsets 0..255 -- igual que
-- el "Advanced Color Effect" real de Flash/Animate).
local function applyColorTransform(inst, r, g, b, a)
	local c = inst.C
	if not c then return r, g, b, a end
	if c.M == "CA" then
		return r, g, b, a * (c.AM or 1)
	elseif c.M == "AD" then
		return
			r * (c.RM or 1) + (c.RO or 0) / 255,
			g * (c.GM or 1) + (c.GO or 0) / 255,
			b * (c.BM or 1) + (c.BO or 0) / 255,
			a * (c.AM or 1) + (c.AO or 0) / 255
	end
	return r, g, b, a
end

-- Compone parent ∘ child (aplica child primero, luego parent) -- la
-- matriz resultante mapea directo del espacio local del hijo al espacio
-- del padre.
local function composeAffine(p, c)
	return {
		a = p.a * c.a + p.c * c.b,
		b = p.b * c.a + p.d * c.b,
		c = p.a * c.c + p.c * c.d,
		d = p.b * c.c + p.d * c.d,
		tx = p.a * c.tx + p.c * c.ty + p.tx,
		ty = p.b * c.tx + p.d * c.ty + p.ty,
	}
end

-- love.math.Transform reutilizado entre draws (evita allocar uno nuevo por
-- sprite hoja dibujado).
local sharedTransform

local function drawLeaf(data, spriteName, mat, r, g, b, a)
	local quad = getQuad(data, spriteName)
	if not quad then return end

	if not sharedTransform then sharedTransform = love.math.newTransform() end

	-- Forma de 16 números, fila-mayor (la base documentada de LÖVE, sin
	-- depender de un atajo de 6 números que no pude confirmar que exista):
	--   fila1: a, c, 0, tx
	--   fila2: b, d, 0, ty
	--   fila3: 0, 0, 1, 0
	--   fila4: 0, 0, 0, 1
	sharedTransform:setMatrix(
		mat.a, mat.c, 0, mat.tx,
		mat.b, mat.d, 0, mat.ty,
		0, 0, 1, 0,
		0, 0, 0, 1
	)

	-- BUG corregido: usaba love.graphics.setColor crudo -- ningún objeto
	-- dibujado vía este módulo (A-Bot, cutscenes de semana 7,
	-- darnell-blazin/pico-blazin, title-screen-text) se oscurecía con el
	-- fundido a negro de cambio de escena (graphics.fadeOut/fadeIn,
	-- modules/graphics.lua), porque ese sistema multiplica el color
	-- SOLO cuando se llama a graphics.setColor(), no
	-- love.graphics.setColor() directo -- el resto del proyecto (sprites
	-- Sparrow vía modules/graphics.lua, fondos, etc.) ya pasaba siempre
	-- por graphics.setColor(), así que sí se apagaban -- estos quedaban
	-- siempre a brillo completo durante cualquier transición.
	graphics.setColor(r or 1, g or 1, b or 1, a or 1)
	love.graphics.draw(data.image, quad, sharedTransform)
end

-- Frame del hijo a dibujar para una instancia de símbolo (SI).
--
-- CORREGIDO DE VUELTA (la "corrección" anterior de esta función estaba
-- mal -- mea culpa, se revierte parcialmente): verificado ahora leyendo
-- TAMBIÉN flxanimate/animate/FlxKeyFrame.hx (no solo FlxElement.hx) --
-- línea 113-122, `FlxKeyFrame.updateRender()`:
--     var curFrame = curFrame - index;  -- (index = fr.I, el inicio del
--                                           keyframe ACTIVO)
--     for (element in _elements) element.updateRender(elapsed, curFrame, ...);
-- es decir, el frame ABSOLUTO SÍ se convierte a relativo-al-keyframe-
-- activo ANTES de llegar a FlxElement.updateRender() -- la resta
-- "elapsed = frameIdx - fr.I" que había ANTES de la ronda 11 (y que se
-- quitó pensando que era el bug) es exactamente esto, solo que aplicada
-- en el lugar correcto -- la formula real completa es:
--     curFF = (frameIdx_DEL_PADRE - keyframeActivo.index) + symbol.firstFrame
-- envuelta/recortada por el largo propio del hijo. Sin la resta, cualquier
-- hijo re-keyframeado (común en animaciones largas) o cualquier animación
-- armada como "wrapper de índices sobre el timeline raíz" (yunjin/gf,
-- ver character.lua/stage.lua -- cada "frame" del wrapper es UN keyframe
-- de duración 1 sobre una capa propia) avanzaba al DOBLE de velocidad o
-- con patrones rotos -- de ahí "el idle de yunjin/gf va absurdamente
-- rápido" y las "convulsiones" en TODOS los personajes reportadas tras
-- haber quitado esta resta.
--
-- Lo que SÍ seguía siendo un bug real y se mantiene corregido: cuando
-- "LP" está AUSENTE el modo real es Loop, no "play once" (confirmado
-- aparte en FlxElement.fromJSONEx() línea ~194) -- antes de la ronda 11
-- el "else" trataba LP ausente como PO.
-- BUG separado, recién confirmado leyendo SymbolParameters.hx (línea
-- ~170-232, set_loop()/set_firstFrame()): "FF"/"LP" del JSON solo se
-- respetan tal cual cuando el tipo del símbolo (si.ST) es "Graphic" --
-- para "MovieClip" (ST="MC") el real FUERZA loop=Loop sin importar "LP",
-- y el setter de firstFrame ni siquiera escribe el valor para MovieClip
-- (queda en 0 sin importar "FF" del JSON); para "Button" fuerza
-- loop=SingleFrame. Antes esto no se distinguía -- irrelevante para los
-- otros 5 personajes (0 instancias "MC" en sus datos), pero Sakura tiene
-- 48 instancias "MC" (todas en sus poses "miss"/"joint miss", donde
-- incrusta sub-rigs completos de "sakura miss X"/"bf miss X").
local function childFrameFor(si, fr, frameIdx, childLen)
	local st = si.ST
	local ff = (st == "MC" or st == "B" or st == "Button") and 0 or (si.FF or 0)
	local relFrame = frameIdx - fr.I
	local curFF = relFrame + ff

	local lp = si.LP
	if st == "MC" then
		lp = "LP" -- MovieClip: loop forzado, ignora "LP" del JSON
	elseif st == "B" or st == "Button" then
		lp = "SF" -- Button: SingleFrame forzado
	end

	if lp == "SF" then
		return ff
	elseif lp == "PO" then
		if curFF < 0 then curFF = 0 end
		if curFF > childLen - 1 then curFF = childLen - 1 end
		return curFF
	else -- "LP" explícito O ausente (default real: Loop)
		local m = curFF % childLen
		if m < 0 then m = m + childLen end
		return m
	end
end

-- ── Bounding box real de un símbolo (para characterOrigin) ─────────────────
-- El motor MODERNO real (funkin/play/character/BaseCharacter.hx,
-- get_characterOrigin(): "xPos = width/2; yPos = height") posiciona a los
-- personajes por CENTRO-X/PISO-Y de su bounding box real, NO por el
-- origen local (0,0) del símbolo Adobe Animate -- a diferencia de Psych
-- Engine (de donde vienen darnell-blazin/pico-blazin/title-screen-text,
-- confirmado leyendo FNF-PsychEngine-main/source/objects/Character.hx:
-- copyAtlasValues() hace atlas.x=x/atlas.y=y SIN ningún characterOrigin,
-- cero referencias a ese concepto en todo Psych), que sí asume (0,0)
-- directo -- por eso character.lua:getOrigin() sigue devolviendo (0,0)
-- por defecto (no romper esos personajes ya afinados a mano), y esto es
-- opt-in vía "useBoundsOrigin" en el JSON, solo para personajes que
-- vienen del motor moderno (los 6 de Sserafim).
--
-- Recorre el árbol de símbolos del frame activo SIN dibujar, acumulando
-- las 4 esquinas locales de cada leaf (ASI) transformadas por la matriz
-- compuesta, en el espacio local del símbolo RAÍZ (parentMat=identidad).
-- Factorizado de accumulateBounds() (la parte que procesa los elementos
-- de UNA entrada de frame ya resuelta) -- reusado tanto por
-- accumulateBounds() (recorre TODAS las capas de un símbolo) como por el
-- recorte por scissor-rect de capas Clipper en renderSymbol() más abajo
-- (necesita el bounding box de SOLO una capa puntual, no del símbolo
-- completo).
local accumulateBounds -- forward-decl: accumulateFrameElementBounds la llama recursivamente vía SI
local function accumulateFrameElementBounds(data, fr, frameIdx, parentMat, bounds)
	for _, el in ipairs(fr.E) do
		if el.SI then
			local si = el.SI
			local childMat = composeAffine(parentMat, affineFromInstance(si))
			local childTimeline = data.symbols[si.SN]
			if childTimeline then
				local childLen = symbolLength(data, childTimeline)
				local childFrame = childFrameFor(si, fr, frameIdx, childLen)
				accumulateBounds(data, si.SN, childFrame, childMat, bounds)
			end
		elseif el.ASI then
			local asi = el.ASI
			local finalMat = composeAffine(parentMat, affineFromInstance(asi))
			local r = data.regions[asi.N]
			if r then
				local corners = {{0, 0}, {r.w, 0}, {0, r.h}, {r.w, r.h}}
				for _, c in ipairs(corners) do
					local lx, ly = c[1], c[2]
					local px = finalMat.a * lx + finalMat.c * ly + finalMat.tx
					local py = finalMat.b * lx + finalMat.d * ly + finalMat.ty
					if px < bounds.minX then bounds.minX = px end
					if px > bounds.maxX then bounds.maxX = px end
					if py < bounds.minY then bounds.minY = py end
					if py > bounds.maxY then bounds.maxY = py end
				end
			end
		end
	end
end

accumulateBounds = function(data, symbolName, frameIdx, parentMat, bounds)
	local timeline = data.symbols[symbolName]
	if not timeline then return end

	for _, layer in ipairs(timeline.L) do
		local fr = findFrameEntry(layer.FR, frameIdx)
		if fr then
			accumulateFrameElementBounds(data, fr, frameIdx, parentMat, bounds)
		end
	end
end

local IDENTITY_MAT = {a = 1, b = 0, c = 0, d = 1, tx = 0, ty = 0}

-- Devuelve minX, minY, width, height del frame activo de la instancia, en
-- el espacio LOCAL del símbolo (sin aplicar self.x/y/sizeX/sizeY) --
-- usado por charts/psych/character.lua para el cálculo de
-- characterOrigin real (opt-in, ver comentario arriba).
M.getInstanceBounds = function(inst)
	if not inst.symbolName then return 0, 0, 0, 0 end
	local absFrame = inst.rangeStart and (inst.rangeStart + math.floor(inst.frame)) or math.floor(inst.frame)

	local bounds = {minX = math.huge, minY = math.huge, maxX = -math.huge, maxY = -math.huge}
	accumulateBounds(inst.data, inst.symbolName, absFrame, IDENTITY_MAT, bounds)

	if bounds.minX == math.huge then return 0, 0, 0, 0 end
	return bounds.minX, bounds.minY, bounds.maxX - bounds.minX, bounds.maxY - bounds.minY
end

-- Busca, en el frame ACTIVO de inst, la primera instancia de símbolo (SI)
-- cuyo nombre de símbolo (si.SN) sea exactamente targetSymbolName --
-- recorre el árbol completo (recursivo a través de hijos SI), SIN
-- dibujar, igual patrón que accumulateBounds()/accumulateFrameElementBounds().
-- Devuelve la matriz compuesta en espacio de MUNDO (ya incluye
-- inst.x/y/sizeX/sizeY como base, igual que el parentMat que usa
-- Instance:draw()) o nil si no aparece en este frame.
--
-- Usado por modules/lipsync.lua para encontrar dónde, en el frame actual
-- de un personaje, está el placeholder "mouth default"/"mouth edit"/
-- "mouth yunjin" (ver sserafim-<personaje>.hxc reales,
-- getFramesWithKeyword()+FlxSpriteElement -- ahí se INYECTA el sprite de
-- lipsync directo en el árbol; acá, al no poder modificar el árbol en
-- runtime, se calcula dónde CAERÍA esa inyección y se dibuja el lipsync
-- por separado en esa misma posición).
local function findNamedTransformRecursive(data, symbolName, frameIdx, parentMat, targetName)
	local timeline = data.symbols[symbolName]
	if not timeline then return nil end

	for _, layer in ipairs(timeline.L) do
		local fr = findFrameEntry(layer.FR, frameIdx)
		if fr then
			for _, el in ipairs(fr.E) do
				if el.SI then
					local si = el.SI
					local childMat = composeAffine(parentMat, affineFromInstance(si))
					if si.SN == targetName then
						return childMat
					end
					local childTimeline = data.symbols[si.SN]
					if childTimeline then
						local childLen = symbolLength(data, childTimeline)
						local childFrame = childFrameFor(si, fr, frameIdx, childLen)
						local found = findNamedTransformRecursive(data, si.SN, childFrame, childMat, targetName)
						if found then return found end
					end
				end
			end
		end
	end
	return nil
end

M.findNamedTransform = function(inst, targetSymbolName)
	if not inst.symbolName then return nil end
	local absFrame = inst.rangeStart and (inst.rangeStart + math.floor(inst.frame)) or math.floor(inst.frame)
	local parentMat = { a = inst.sizeX, b = 0, c = 0, d = inst.sizeY, tx = inst.x, ty = inst.y }
	return findNamedTransformRecursive(inst.data, inst.symbolName, absFrame, parentMat, targetSymbolName)
end

-- ── Filtro de blur (BLF) de Adobe Animate ──────────────────────────────────
-- Formato real, confirmado leyendo Animation.json de picoAppears: una
-- instancia de símbolo puede llevar "F":{"BLF":{BLX=,BLY=,Q=}} -- un blur
-- gaussiano (BLX/BLY en pixeles de radio, por eje). Se ve en assets reales
-- como detalles puntuales (brillo de ojos con estela, etc.), NO como un
-- bloom de pantalla completa -- no hay un filtro de blur a nivel cámara en
-- Tank.hx, solo este, embebido en el atlas mismo.
--
-- LÖVE2D no tiene un "filtro" por sprite nativo -- se renderiza el
-- contenido del símbolo hijo a un canvas aparte (centrado, con margen de
-- sobra para el radio de blur), se le aplica un blur gaussiano separable
-- de 2 pasadas (horizontal + vertical, cada una un shader de 9 muestras),
-- y se compone el resultado en la posición final.
local BLUR_CANVAS_SIZE = 512
local BLUR_CANVAS_HALF = BLUR_CANVAS_SIZE / 2
local blurCanvasA, blurCanvasB, blurShader

local function ensureBlurResources()
	if blurShader then return end
	blurCanvasA = love.graphics.newCanvas(BLUR_CANVAS_SIZE, BLUR_CANVAS_SIZE)
	blurCanvasB = love.graphics.newCanvas(BLUR_CANVAS_SIZE, BLUR_CANVAS_SIZE)
	blurShader = love.graphics.newShader([[
		extern vec2 texelStep;
		vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord)
		{
			vec4 sum = vec4(0.0);
			float total = 0.0;
			for (int i = -4; i <= 4; i++)
			{
				float fi = float(i);
				float w = exp(-(fi * fi) / 12.5);
				sum += Texel(texture, texCoord + texelStep * fi) * w;
				total += w;
			}
			return (sum / total) * color;
		}
	]])
end

-- Recorre y dibuja recursivamente symbolName en el frame frameIdx, con
-- parentMat ya compuesta (espacio padre -> pantalla). r,g,b,a = color
-- heredado (para alpha de toda la instancia).
local renderSymbol

-- Renderiza si.SN (la instancia de símbolo CON filtro BLF) a un canvas
-- propio, le aplica el blur, y compone el resultado con parentMat∘si.M3D.
local function renderBlurredSI(data, si, fr, frameIdx, parentMat, r, g, b, a)
	local childTimeline = data.symbols[si.SN]
	if not childTimeline then return end
	ensureBlurResources()

	local childLen = symbolLength(data, childTimeline)
	local childFrame = childFrameFor(si, fr, frameIdx, childLen)

	-- Dibuja el contenido del hijo centrado en el canvas (su origen local
	-- (0,0) cae en el centro) -- así hay margen de sobra en cualquier
	-- dirección antes de desenfocar, sin recortar contenido cerca de los
	-- bordes.
	--
	-- push("all") + origin(): love.graphics.draw() SIEMPRE compone con la
	-- matriz de transformación activa (la de graphics.pushParallax() en
	-- stage.lua, que en este punto sigue en pie -- traslada al centro de
	-- pantalla, escala por cam.sizeX/Y, etc.). Sin resetearla antes de
	-- dibujar al canvas, "centerMat" (pensada como espacio LOCAL aislado
	-- del canvas) terminaba compuesta TAMBIÉN con esa transformación de
	-- cámara -- el contenido se dibujaba muy lejos del centro del canvas
	-- (o a una escala completamente distinta), dejándolo vacío o casi
	-- invisible. Mismo problema para las pasadas de blur (dibujan el
	-- canvas fuente a tamaño 1:1, también afectado por la matriz activa).
	local prevCanvas = love.graphics.getCanvas()
	love.graphics.push("all")
	love.graphics.origin()
	love.graphics.setCanvas(blurCanvasA)
	love.graphics.clear(0, 0, 0, 0)
	renderSymbol(data, si.SN, childFrame,
		{ a = 1, b = 0, c = 0, d = 1, tx = BLUR_CANVAS_HALF, ty = BLUR_CANVAS_HALF }, 1, 1, 1, 1)

	local blf = si.F.BLF
	local blx, bly = blf.BLX or 0, blf.BLY or 0
	local src, dst = blurCanvasA, blurCanvasB

	local function pass(stepX, stepY)
		love.graphics.setCanvas(dst)
		love.graphics.clear(0, 0, 0, 0)
		love.graphics.setShader(blurShader)
		blurShader:send("texelStep", { stepX, stepY })
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(src)
		love.graphics.setShader()
		src, dst = dst, src
	end

	if blx > 0 then pass((blx / 4) / BLUR_CANVAS_SIZE, 0) end
	if bly > 0 then pass(0, (bly / 4) / BLUR_CANVAS_SIZE) end

	love.graphics.setCanvas(prevCanvas)
	love.graphics.pop()

	-- parentMat ∘ si.M3D ∘ translate(-centro): el centro del canvas
	-- (origen local del símbolo) tiene que caer en la posición final real.
	local finalMat = composeAffine(composeAffine(parentMat, affineFromInstance(si)),
		{ a = 1, b = 0, c = 0, d = 1, tx = -BLUR_CANVAS_HALF, ty = -BLUR_CANVAS_HALF })

	if not sharedTransform then sharedTransform = love.math.newTransform() end
	sharedTransform:setMatrix(
		finalMat.a, finalMat.c, 0, finalMat.tx,
		finalMat.b, finalMat.d, 0, finalMat.ty,
		0, 0, 1, 0,
		0, 0, 0, 1
	)
	-- BUG corregido: mismo motivo que drawLeaf() -- este es el draw FINAL
	-- (a pantalla/canvas real, no un paso intermedio del blur) del
	-- símbolo con filtro BLF, también debe respetar el fundido global.
	graphics.setColor(r or 1, g or 1, b or 1, a or 1)
	love.graphics.draw(src, sharedTransform)
	love.graphics.setColor(1, 1, 1, 1)
end

-- Dibuja los elementos (SI/ASI) de una entrada de frame (fr.E) ya
-- resuelta -- factorizado de renderSymbol() para poder reusarlo también
-- al volcar una capa "Clipper" dentro del stencil buffer (ver abajo).
local function drawFrameElements(data, fr, frameIdx, parentMat, r, g, b, a)
	local elements = fr.E
	for ei = 1, #elements do
		local el = elements[ei]
		if el.SI then
			local si = el.SI
			if si.F and si.F.BLF then
				renderBlurredSI(data, si, fr, frameIdx, parentMat, r, g, b, a)
			else
				local childMat = composeAffine(parentMat, affineFromInstance(si))
				local childTimeline = data.symbols[si.SN]
				if childTimeline then
					local cr, cg, cb, ca = applyColorTransform(si, r, g, b, a)
					local childLen = symbolLength(data, childTimeline)
					local childFrame = childFrameFor(si, fr, frameIdx, childLen)
					renderSymbol(data, si.SN, childFrame, childMat, cr, cg, cb, ca)
				end
			end
		elseif el.ASI then
			local asi = el.ASI
			local finalMat = composeAffine(parentMat, affineFromInstance(asi))
			local lr, lg, lb, la = applyColorTransform(asi, r, g, b, a)
			drawLeaf(data, asi.N, finalMat, lr, lg, lb, la)
		end
	end
end

renderSymbol = function(data, symbolName, frameIdx, parentMat, r, g, b, a)
	local timeline = data.symbols[symbolName]
	if not timeline then return end

	local layers = timeline.L

	-- BUG corregido: capas de tipo "Clipper"/"Clipped" (LT="Clp" / Clpb=
	-- "<nombre de la capa Clipper>", ver FNF-PsychEngine-main no, sino la
	-- librería real flxanimate/animate/FlxLayer.hx -- "type" -- usadas
	-- para efectos de revelado/máscara, confirmado presentes en
	-- sserafim-gf-getup.json -- "Layer_14" es Clipper, 6 capas más son
	-- Clipped por ella) se dibujaban antes como capas NORMALES -- la capa
	-- Clipper en sí (que en Animate suele ser una forma sólida de un solo
	-- color, NUNCA pensada para verse) se mostraba directamente como un
	-- bloque de color opaco encima de todo ("cuadro azul" reportado), y
	-- las capas Clipped se mostraban SIN recortar (de más, no reportado
	-- pero igual de incorrecto). El real usa cámaras/render-targets
	-- separados para esto (demasiado complejo de portar 1:1) -- acá se
	-- logra el mismo resultado visual con el stencil buffer de LÖVE2D:
	-- la capa Clipper nunca se dibuja directo, y cada capa Clipped se
	-- recorta al stencil generado por su Clipper antes de dibujarse.
	local clipperLayerByName = nil
	for _, layer in ipairs(layers) do
		if layer.LT == "Clp" then
			clipperLayerByName = clipperLayerByName or {}
			clipperLayerByName[layer.LN] = layer
		end
	end

	-- Reversa SOLO para capas (confirmado contra el FlxAnimate real,
	-- Dot-Stuff/flxanimate FlxAnimate.hx:parseElement -- itera
	-- "layers[layers.length-1-i]", o sea de atrás para adelante: la
	-- ÚLTIMA capa de la lista se dibuja PRIMERO/atrás, la PRIMERA capa de
	-- la lista se dibuja ÚLTIMO/al frente). Los ELEMENTOS dentro de un
	-- frame de una capa (fr.E) NO van en reversa -- FlxAnimate los recorre
	-- con "for (element in frame.getList())", orden normal. Antes esto
	-- también se invertía por error, causando exactamente lo reportado:
	-- caras detrás de cabezas, extremidades tapadas mal por el torso
	-- (todos casos de varios elementos dentro de la MISMA capa).
	for li = #layers, 1, -1 do
		local layer = layers[li]

		if layer.LT == "Clp" then
			-- Nunca se dibuja directo -- solo existe para servir de
			-- stencil a las capas que la referencian vía Clpb.
		else
			local fr = findFrameEntry(layer.FR, frameIdx)
			if fr then
				local clipperLayer = layer.Clpb and clipperLayerByName and clipperLayerByName[layer.Clpb]
				if clipperLayer then
					local clipFr = findFrameEntry(clipperLayer.FR, frameIdx)
					if clipFr then
						-- SEGUNDO intento, cambiando de estrategia por completo:
						-- el stencil buffer (con el fix de color mask) seguia
						-- sin funcionar -- depurar eso a ciegas sin runtime ya
						-- dio dos vueltas sin resultado, asi que se abandona a
						-- favor de algo mas simple y robusto: un scissor-rect
						-- (love.graphics.setScissor) con el bounding box REAL
						-- de la capa Clipper en este frame, transformado a
						-- coordenadas de pantalla via love.graphics.transformPoint
						-- (que ya tiene en cuenta el stack de push/translate/
						-- scale activo, p.ej. pushParallax). Es menos preciso
						-- que un recorte por forma exacta (recorta a un
						-- RECTANGULO, no a la silueta exacta de la mascara)
						-- pero no depende de shaders, blend modes, ni de
						-- ningun detalle fino de la API de stencil de LOVE2D.
						local cb = {minX = math.huge, minY = math.huge, maxX = -math.huge, maxY = -math.huge}
						accumulateFrameElementBounds(data, clipFr, frameIdx, parentMat, cb)
						if cb.minX ~= math.huge then
							local x1, y1 = love.graphics.transformPoint(cb.minX, cb.minY)
							local x2, y2 = love.graphics.transformPoint(cb.maxX, cb.minY)
							local x3, y3 = love.graphics.transformPoint(cb.minX, cb.maxY)
							local x4, y4 = love.graphics.transformPoint(cb.maxX, cb.maxY)
							local sx1 = math.min(x1, x2, x3, x4)
							local sx2 = math.max(x1, x2, x3, x4)
							local sy1 = math.min(y1, y2, y3, y4)
							local sy2 = math.max(y1, y2, y3, y4)

							local px, py, pw, ph = love.graphics.getScissor()
							if px then
								sx1 = math.max(sx1, px)
								sy1 = math.max(sy1, py)
								sx2 = math.min(sx2, px + pw)
								sy2 = math.min(sy2, py + ph)
							end

							if sx2 > sx1 and sy2 > sy1 then
								love.graphics.setScissor(sx1, sy1, sx2 - sx1, sy2 - sy1)
								drawFrameElements(data, fr, frameIdx, parentMat, r, g, b, a)
							end
							-- setScissor(nil...) con argumentos nil tira error --
							-- si no había scissor activo antes (px=nil), hay que
							-- llamar sin argumentos para limpiarlo del todo.
							if px then
								love.graphics.setScissor(px, py, pw, ph)
							else
								love.graphics.setScissor()
							end
						end
					end
					-- Si la capa Clipper no tiene contenido en este frame,
					-- el real no muestra nada de la capa Clipped tampoco
					-- (mismo criterio que FlxAnimate.hx línea ~415) -- por
					-- eso NO hay "else: dibujar sin recortar" acá.
				else
					drawFrameElements(data, fr, frameIdx, parentMat, r, g, b, a)
				end
			end
		end
	end
end

-- ===========================================================================
-- Instancias reproducibles (una por personaje/cutscene -- equivalente a un
-- "new FlxAnimate(x,y)" de Psych real).
-- ===========================================================================

local Instance = {}
local InstanceMT = { __index = Instance }

-- data: lo que devuelve M.load(folderPath).
function M.newInstance(data)
	return setmetatable({
		data = data,
		x = 0, y = 0,
		sizeX = 1, sizeY = 1,
		alpha = 1,
		tintR = 1, tintG = 1, tintB = 1,
		visible = true,
		symbolName = nil,
		frame = 0,         -- frame ACTUAL (float, para sub-frame timing suave)
		looping = false,
		finished = false,
		onCompleteFn = nil,
	}, InstanceMT)
end

-- symbolName: nombre EXACTO del símbolo en SD.S (p.ej. "TANK TALK 1 P1").
-- loop: true/false. Reinicia siempre desde el frame 0 (Tank.hx siempre
-- llama a esto con Force=true, o sea reinicio incondicional).
function Instance:playSymbol(symbolName, loop)
	self.symbolName = symbolName
	self.rangeStart = nil
	self.rangeEnd = nil
	self.frame = 0
	self.looping = loop or false
	self.finished = false
end

-- Variante para personajes tipo darnell-blazin.json/pico-blazin.json: TODA
-- su hoja de animaciones vive en UN solo símbolo gigante ("Darnell Fighting
-- ALL ANIMS"/"Pico Fighting ALL ANIMS"), y cada "anim" de Psych (idle,
-- punchHigh1, uppercut, ...) es en realidad un RANGO de índices [startIdx,
-- endIdx] dentro de ESE símbolo (siempre contiguo en los JSON reales --
-- "indices":[14,15,16,17,18] nunca salteado). playSymbol() siempre arranca
-- en el frame 0 del símbolo -- no sirve para esto. startIdx/endIdx son
-- índices ABSOLUTOS dentro del símbolo (los mismos números que "indices"
-- en characters/<id>.json).
function Instance:playSymbolRange(symbolName, startIdx, endIdx, loop)
	self.symbolName = symbolName
	self.rangeStart = startIdx
	self.rangeEnd = endIdx
	self.frame = 0
	self.looping = loop or false
	self.finished = false
end

function Instance:getCurrentSymbolName()
	return self.symbolName
end

function Instance:isFinished()
	return self.finished
end

function Instance:onComplete(fn)
	self.onCompleteFn = fn
end

function Instance:update(dt)
	if not self.symbolName or self.finished then return end

	local timeline = self.data.symbols[self.symbolName]
	if not timeline then return end

	-- Con rango activo (playSymbolRange), "len" es el largo DEL RANGO, no
	-- del símbolo completo -- self.frame sigue siendo relativo al inicio
	-- del rango (0-based), igual que sin rango es relativo al símbolo.
	local len = self.rangeEnd and (self.rangeEnd - self.rangeStart + 1) or symbolLength(self.data, timeline)

	self.frame = self.frame + dt * self.data.frameRate

	if self.frame >= len then
		if self.looping then
			self.frame = self.frame % len
		else
			self.frame = len - 1
			self.finished = true
			local fn = self.onCompleteFn
			if fn then fn(self) end
		end
	end
end

function Instance:draw()
	if not self.visible or not self.symbolName then return end

	local parentMat = {
		a = self.sizeX, b = 0,
		c = 0, d = self.sizeY,
		tx = self.x, ty = self.y,
	}

	-- Con rango activo, self.frame es relativo al inicio del rango -- hay
	-- que sumarle rangeStart para obtener el índice ABSOLUTO dentro del
	-- símbolo que espera renderSymbol().
	local absFrame = self.rangeStart and (self.rangeStart + math.floor(self.frame)) or math.floor(self.frame)

	-- self.shader: opt-in, nil por defecto -- mismo criterio que
	-- modules/graphics.lua (usado por el shader HSL de Sserafim, el único
	-- caso hoy que necesita tintar un personaje Adobe Animate).
	if self.shader then love.graphics.setShader(self.shader) end
	renderSymbol(self.data, self.symbolName, absFrame, parentMat, self.tintR, self.tintG, self.tintB, self.alpha)
	if self.shader then love.graphics.setShader() end

	love.graphics.setColor(1, 1, 1, 1)
end

-- Dibuja symbolName/frameIdx con una matriz arbitraria en vez de la que
-- Instance:draw() construye desde self.x/y/sizeX/sizeY -- necesario para
-- el sprite de lipsync (modules/lipsync.lua), que necesita ROTACIÓN
-- (el "angle" fino por pose de cada personaje real) además de
-- posición/escala -- el modelo simple de Instance no tiene campo de
-- rotación, así que esto compone la matriz a mano (incluyendo rotación)
-- y la pasa directo a renderSymbol().
M.drawAtMatrix = function(data, symbolName, frameIdx, matrix, r, g, b, a, shader)
	if shader then love.graphics.setShader(shader) end
	renderSymbol(data, symbolName, frameIdx, matrix, r or 1, g or 1, b or 1, a or 1)
	if shader then love.graphics.setShader() end
	love.graphics.setColor(1, 1, 1, 1)
end

return M
