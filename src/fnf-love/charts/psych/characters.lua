-- Registro de personajes Psych Engine (player1/player2/gfVersion, "Change
-- Character") -> sprites Lua reales de FNF Rewritten.
--
-- Cada entrada indica el slot global que ocupa ("boyfriend"/"girlfriend"/"enemy")
-- y la ruta del sprite. Las posiciones de escenario NO van aquí — las define
-- el stage.lua de cada semana, igual que Psych Engine usa stage.json para eso.
--
-- FASE 2 de la refactorización de ergonomía de modding (ver memoria del
-- proyecto "modding-ergonomics-refactor"): este REGISTRY ya NO es
-- obligatorio. Si un nombre Psych no está aquí, get()/loadInto() intentan
-- "characters/<nombre>.json" directo, igual que Character.hx real
-- (Character.hx:105-123, sin ningún registro de por medio) -- solo avisan
-- por consola y no hacen nada si TAMPOCO existe ese archivo en disco
-- (nunca rompe el juego). El REGISTRY sigue existiendo para los casos que
-- de verdad necesitan algo no derivable del nombre solo: alias de archivo
-- (ej. "skid and pump"/"sonicexe") y overrides empíricos (yCorrection).

local character = require("charts.psych.character")

local M = {}

-- "icon": nombre de animación de icono (ver sprites/icons.lua), usado para que
-- la barra de salud tome el color correcto desde la tabla characterColors de
-- states/weeks.lua. Si se omite, la barra usa el color por defecto (rojo/verde).
--
-- "kind": vestigial, ya no se lee (ver loadInto() -- el branch ahora mira
-- la PRESENCIA de "path", no este campo). Queda en las entradas existentes
-- sin afectar nada; no hace falta agregarlo a entradas nuevas.
--
-- "path" (legacy, opcional): si está presente, loadInto() carga un sprite
-- Lua ya "horneado" en vez de un characters/<id>.json -- ninguna entrada
-- actual lo usa, pero el soporte se mantiene por si algún mod lo necesita.
--
-- "slot": SOLO documentación histórica -- nunca se lee en ningún lado del
-- código (confirmado por grep, Fase 2 de la refactorización de modding).
-- No restringe en qué slot puede instanciarse un personaje: cualquiera
-- puede ir como player1/player2/gfVersion sin duplicar archivos. Los
-- duplicados que sí existen (pico vs pico-playable/pico-blazin) NO son por
-- esta restricción -- son personajes con JSON genuinamente distinto (ver
-- comentario de Weekend 1 más abajo).
--
-- Las posiciones de slot (dónde va cada personaje en el escenario) las define
-- el stage, NO el personaje — igual que en Psych Engine donde stage.json tiene
-- los campos "boyfriend"/"girlfriend"/"opponent". El personaje solo conoce su
-- propio offset fino (campo "position" en characters/<id>.json).
local REGISTRY = {
	-- ── Boyfriend ─────────────────────────────────────────────────────────────
	bf               = { kind = "psych", json = "characters/bf.json",             slot = "boyfriend",  icon = "boyfriend" },
	["bf-holding-gf"]= { kind = "psych", json = "characters/bf-holding-gf.json",  slot = "boyfriend",  icon = "boyfriend" },
	["bf-car"]       = { kind = "psych", json = "characters/bf-car.json",         slot = "boyfriend",  icon = "boyfriend" },
	["bf-christmas"] = { kind = "psych", json = "characters/bf-christmas.json",   slot = "boyfriend",  icon = "boyfriend" },
	["bf-pixel"]     = { kind = "psych", json = "characters/bf-pixel.json",       slot = "boyfriend",  icon = "boyfriend (pixel)" },

	-- ── Girlfriend ────────────────────────────────────────────────────────────
	gf               = { kind = "psych", json = "characters/gf.json",             slot = "girlfriend", icon = "girlfriend" },
	["gf-christmas"] = { kind = "psych", json = "characters/gf-christmas.json",   slot = "girlfriend", icon = "girlfriend" },
	["gf-car"]       = { kind = "psych", json = "characters/gf-car.json",         slot = "girlfriend", icon = "girlfriend" },
	["gf-pixel"]     = { kind = "psych", json = "characters/gf-pixel.json",       slot = "girlfriend", icon = "girlfriend" },
	["gf-tankmen"]   = { kind = "psych", json = "characters/gf-tankmen.json",     slot = "girlfriend", icon = "girlfriend" },

	-- ── Week 1 ────────────────────────────────────────────────────────────────
	dad              = { kind = "psych", json = "characters/dad.json",            slot = "enemy",      icon = "daddy dearest" },

	-- ── Week 2 (Spooky Month) ─────────────────────────────────────────────────
	spooky           = { kind = "psych", json = "characters/spooky.json",         slot = "enemy",      icon = "skid and pump" },
	["skid and pump"]= { kind = "psych", json = "characters/spooky.json",         slot = "enemy",      icon = "skid and pump" },
	monster          = { kind = "psych", json = "characters/monster.json",        slot = "enemy",      icon = "monster" },
	["monster-christmas"] = { kind = "psych", json = "characters/monster-christmas.json", slot = "enemy", icon = "monster" },

	-- ── Week 3 (Pico) ─────────────────────────────────────────────────────────
	pico             = { kind = "psych", json = "characters/pico.json",           slot = "enemy",      icon = "pico" },

	-- ── Week 4 (Mommy Must Murder) ────────────────────────────────────────────
	mom              = { kind = "psych", json = "characters/mom.json",            slot = "enemy",      icon = "mommy mearest" },
	["mom-car"]      = { kind = "psych", json = "characters/mom-car.json",        slot = "enemy",      icon = "mommy mearest" },

	-- ── Week 5 (Red Snow) ─────────────────────────────────────────────────────
	["parents-christmas"] = { kind = "psych", json = "characters/parents-christmas.json", slot = "enemy", icon = "dearest duo" },

	-- ── Week 6 (Hating Simulator) ─────────────────────────────────────────────
	senpai           = { kind = "psych", json = "characters/senpai.json",         slot = "enemy",      icon = "senpai" },
	["senpai-angry"] = { kind = "psych", json = "characters/senpai-angry.json",   slot = "enemy",      icon = "senpai-angry" },
	spirit           = { kind = "psych", json = "characters/spirit.json",         slot = "enemy",      icon = "spirit" },

	-- ── Week 7 (Tankman) ──────────────────────────────────────────────────────
	tankman          = { kind = "psych", json = "characters/tankman.json",        slot = "enemy",      icon = "tankman" },
	-- yCorrection: ajuste empírico, ver loadInto() más abajo. pico-speaker no
	-- tiene "idle"/"danceLeft"/"danceRight" (su animación inicial es
	-- "shoot1", una pose de disparo) -- es el único personaje de semana 7 en
	-- ese caso. Confirmado visualmente (capturas + Psych Engine real) que
	-- en el juego original queda a la misma altura que gf-tankmen en las
	-- otras 2 canciones. +120 (cálculo a mano) sobrecorrigió (quedó por
	-- debajo); +90 es la siguiente aproximación dentro del rango confirmado
	-- por el usuario (60 < valor real < 120, "menos mal" que el error
	-- original con +120 pero no exacto). Sigue siendo un ajuste empírico --
	-- no se encontró la causa exacta del lado de Flixel/getOrigin(), ver
	-- loadInto() para más detalle.
	["pico-speaker"] = { kind = "psych", json = "characters/pico-speaker.json",   slot = "girlfriend", icon = "pico", yCorrection = 90 },

	-- ── Weekend 1 (Pico vs Darnell) ───────────────────────────────────────────
	-- Reconstruido desde cero contra Psych Engine real (characters/darnell.json,
	-- nene.json, pico-playable.json) -- ya NO usa los sprites/weekend1/*.lua
	-- viejos (movidos a _backup_weekend1/, no se reutilizó nada de ahí).
	-- pico-playable: el atlas principal (Pico_FNF_assetss) solo trae las
	-- poses de canto -- shoot/cock/shootMISS (atlas "Pico_Shooting") e
	-- intro1/intro2/cockCutscene (atlas "Pico_Intro") viven en sprites
	-- standalone aparte, cargados directo por el stage (mismo patrón que
	-- military/stage.lua ya usa para tankmanCutscene/boyfriendCutscene).
	darnell          = { kind = "psych", json = "characters/darnell.json",        slot = "enemy",      icon = "darnell" },
	nene             = { kind = "psych", json = "characters/nene.json",           slot = "girlfriend", icon = "face" },
	["pico-playable"]= { kind = "psych", json = "characters/pico-playable.json",  slot = "boyfriend",  icon = "pico" },
	-- Blazin Fight (Adobe Animate, ver charts/psych/character.lua:loadAnimateCharacter()).
	["darnell-blazin"]= { kind = "psych", json = "characters/darnell-blazin.json", slot = "enemy",      icon = "darnell" },
	["pico-blazin"]   = { kind = "psych", json = "characters/pico-blazin.json",    slot = "boyfriend",  icon = "pico" },

	-- ── Too Slow (mod, Sonic.exe / Angel Island) ─────────────────────────────
	-- icon="sonic": sprites/icons.lua ya tiene esa animación registrada
	-- (-> icon-sonic.png), no hace falta agregar una entrada nueva ahí.
	sonicexe         = { kind = "psych", json = "characters/sonic-exe.json",       slot = "enemy",      icon = "sonic" },

	-- ── Sserafim (colab especial, canción "Spaghetti") ───────────────────────
	-- Reconstruido desde cero contra funkin.assets-main real
	-- (preload/data/characters/sserafim-*.json + shared/images/characters/
	-- sserafim/*/Animation.json) -- la versión anterior fue movida a backup
	-- y se ignora por completo, no se reutilizó nada de ahí.
	--
	-- Todos usan atlas Adobe Animate normal (M3D, NO el formato "MX" de BTA
	-- que tuvo title-screen-text) -- mismo loader que darnell-blazin/
	-- pico-blazin (charts/psych/character.lua:loadAnimateCharacter()),
	-- detectado automáticamente por la presencia de Animation.json junto a
	-- la imagen. getOrigin() de ese loader siempre da (0,0) (no hay forma
	-- barata de calcular el bounding box real de un símbolo Animate
	-- compuesto) -- la posición final es SIEMPRE slot del stage + "position"
	-- del JSON, sin ninguna conversión automática de centro. Si la posición
	-- en pantalla queda mal, no asumir una fórmula -- ajustar a mano con
	-- una herramienta de tuning en vivo (ver memoria "live-offset-tuning-
	-- tool-pattern"), NO adivinar offsets como con title-screen-text.
	--
	-- Confirmado leyendo cada Animation.json real: chaewon/eunchae tienen
	-- un símbolo POR animación (igual que kazuha); yunjin/sserafim-gf NO
	-- tienen símbolos por animación -- TODO su set de poses vive como
	-- frame-labels dentro del timeline RAÍZ (el mismo patrón "ALL ANIMS" +
	-- indices que darnell-blazin/pico-blazin, solo que con el nombre del
	-- timeline raíz en vez de un símbolo del diccionario) -- confirmado
	-- contra Animation.json:AN.SN ("yunjin"/"sserafim-gf") + sus frame
	-- labels. Sakura (multianimateatlas, falta portar) probablemente split
	-- entre 2+ atlas, igual que Pico_Shooting/Pico_FNF_assetss de weekend1.
	["sserafim-kazuha"]  = { kind = "psych", json = "characters/sserafim-kazuha.json",  slot = "enemy",      icon = "kazuha" },
	["sserafim-chaewon"] = { kind = "psych", json = "characters/sserafim-chaewon.json", slot = "enemy",      icon = "chaewon" },
	["sserafim-eunchae"] = { kind = "psych", json = "characters/sserafim-eunchae.json", slot = "enemy",      icon = "eunchae" },
	["sserafim-yunjin"]  = { kind = "psych", json = "characters/sserafim-yunjin.json",  slot = "enemy",      icon = "yunjin" },
	-- BUG corregido: "gf" no es un nombre de animación válido (sprites/
	-- icons.lua registra "girlfriend", no "gf" -- el archivo icon-gf.png
	-- ya está mapeado a ESE nombre, línea 11) -- placeholder nunca
	-- actualizado (igual bug que chaewon/eunchae/yunjin/sakura arriba/abajo).
	["sserafim-gf"]      = { kind = "psych", json = "characters/sserafim-gf.json",      slot = "girlfriend", icon = "girlfriend" },
	-- Sakura (jugable): renderType real "multianimateatlas" -- SOLO por la
	-- secuencia de muerte (firstDeath/deathLoop/deathConfirm), que en el
	-- JSON real tiene su PROPIO assetPath ("shared:characters/bf-death",
	-- el atlas de muerte ESTÁNDAR, reusado, no algo propio de Sakura).
	-- loadAnimateCharacter() de este proyecto no soporta un atlas alterno
	-- por animación -- pero tampoco hace falta: substates/game-over.lua ya
	-- maneja la pantalla de muerte de forma GENÉRICA (igual que Psych real,
	-- donde el character.json NUNCA tiene campo "death" -- eso es
	-- exclusivo del formato moderno). Se omiten esas 3 animaciones del
	-- JSON -- el resto (idle/sing/miss/joint/bf1/bf2) es un solo atlas
	-- normal, sin split real.
	-- BUG corregido (round 36): icon="sakura" (ronda 29) estaba mal para
	-- ELLA específicamente -- confirmado contra el chart real
	-- (data/spaghetti/spaghetti.json): el ícono del JUGADOR (char=0) NUNCA
	-- tiene un evento SetHealthIcon "sakura" -- solo "bf"/"gf" (1 vez cada
	-- uno, alternando el ícono genérico boyfriend<->girlfriend a mitad de
	-- canción). "sakura" SÍ aparece, pero únicamente como ícono de
	-- ENEMIGO (char=1, 2 veces) -- ese caso ya funciona solo, vía el
	-- handler dinámico SetHealthIcon de stage.lua, sin depender de este
	-- campo estático. Por defecto (antes de que dispare cualquier evento)
	-- el ícono del jugador debe ser el genérico "boyfriend", igual que el
	-- color de la barra de vida (que nunca se rompió, porque ESE no
	-- depende de este campo).
	["sserafim-sakura"]  = { kind = "psych", json = "characters/sserafim-sakura.json",  slot = "boyfriend",  icon = "boyfriend" },
}

-- name: nombre Psych (player1/player2/gfVersion, o value1 de "Change Character")
-- Devuelve la entrada del registro (o un fallback armado por convención, ver
-- comentario de Fase 2 más arriba), o nil + warn si tampoco hay JSON en disco.
function M.get(name)
	if not name then return nil end

	local entry = REGISTRY[name]
	if entry then return entry end

	local jsonPath = "characters/" .. name .. ".json"
	if love.filesystem.getInfo(jsonPath) then
		return { json = jsonPath }
	end

	print("WARN: personaje Psych '" .. tostring(name) .. "' sin sprite Lua en FNF Rewritten, se mantiene el personaje actual")
	return nil
end

-- Reemplaza el sprite global del slot ("boyfriend"/"girlfriend"/"enemy") por
-- el personaje Psych indicado, preservando escala si el sprite anterior tenía
-- alguna y usando la posición nativa conocida (o la del sprite anterior si no
-- hay una registrada).
-- Devuelve true, entry si se hizo el cambio; false si no (nombre desconocido o
-- error al cargar el sprite).
function M.loadInto(slot, name)
	local entry = M.get(name)
	if not entry then return false end

	local ok, sprite

	-- Branch por presencia de "path" (legacy), no por "kind" (Fase 2 --
	-- "kind" ya no se lee en ningún lado, ver comentario del REGISTRY).
	-- Así, una entrada armada por convención en M.get() (sin kind ni path)
	-- cae naturalmente en la rama normal de characters/<id>.json.
	if entry.path then
		ok, sprite = pcall(function() return love.filesystem.load(entry.path)() end)
		if not ok or not sprite then
			print("WARN: no se pudo cargar el sprite Psych '" .. entry.path .. "': " .. tostring(sprite))
			return false
		end
	else
		ok, sprite = pcall(character.load, entry.json, slot == "boyfriend")
		if not ok or not sprite then
			print("WARN: no se pudo cargar el personaje Psych '" .. entry.json .. "': " .. tostring(sprite))
			return false
		end
	end

	local current = _G[slot]

	-- El offset propio del personaje (startCharacterPos / "position" en Psych Engine).
	-- La posición de slot del stage la suma stages.lua DESPUÉS de loadInto,
	-- igual que Psych Engine: stageData.boyfriend + charOffset = posición final.
	local posX, posY = 0, 0
	if sprite.psychChar and sprite.psychChar.position then
		posX = sprite.psychChar.position[1] or 0
		posY = sprite.psychChar.position[2] or 0
	end

	-- yCorrection: ver comentario completo en la entrada del REGISTRY
	-- (arriba) -- corrección empírica para personajes sin idle/dance cuya
	-- animación inicial (usada como referencia de getOrigin()) no produce
	-- la misma posición visual que en Psych real.
	posY = posY + (entry.yCorrection or 0)

	if entry.path and current then
		if current.sizeX then sprite.sizeX = current.sizeX end
		if current.sizeY then sprite.sizeY = current.sizeY end
	end

	if sprite:getAnims()["idle"] then
		sprite:animate("idle", false)
	end

	-- Conversión Psych (top-left del bounding box sin trim) -> FNF Rewritten
	-- (centro del bounding box sin trim) -- nunca adivinada a mano, ver
	-- modules/graphics.lua:getOrigin(). Sin argumento: usa el frame de la
	-- animación ACTUALMENTE activa (graphics.lua: frameIndex or anim.start),
	-- que justo tras construir el sprite es la animación inicial
	-- (character.lua elige "idle" si existe, sino "danceRight", sino la
	-- primera con frames válidos -- "idle" casi nunca es la primera listada
	-- en el JSON, así que usar literalmente el frame 1 del JSON daba una
	-- conversión distinta a la real y descolocaba personajes como dad/gf/
	-- spooky donde "idle"/"danceRight" no es la primera animación listada).
	-- getOrigin() devuelve el origen SIN escalar (no multiplica por
	-- sprite.sizeX/Y). Esto es CORRECTO acá, sin multiplicar por la escala:
	-- modules/graphics.lua:draw() pasa exactamente este mismo valor SIN
	-- escalar como ox/oy a love.graphics.draw(), que internamente lo escala
	-- por sx,sy al dibujar -- es decir, sprite.x/y YA representa el centro
	-- visual del frame ESCALADO, precisamente PORQUE el origen que se le
	-- resta en el dibujado está sin escalar (LÖVE hace esa multiplicación
	-- una sola vez, automáticamente). Si acá TAMBIÉN multiplicáramos por la
	-- escala, el centro quedaría desplazado por un factor extra de `scale`
	-- (para personajes pixel, escala 6 -- exactamente el bug de "personajes
	-- hundidos en el suelo" reportado: la ronda pasada multipliqué por
	-- error, pensando que esta conversión necesitaba escalar igual que
	-- charts/psych/bgsprite.lua -- pero bgsprite.lua SÍ multiplica porque ahí
	-- el origen se suma directo a x,y sin pasar por un draw() que ya escale
	-- automáticamente; characters.lua no tiene esa segunda escalada).
	local slotConvX, slotConvY = sprite:getOrigin()
	sprite._slotConversionX = slotConvX
	sprite._slotConversionY = slotConvY

	-- Guardamos el offset propio para que "Change Character" pueda recuperar
	-- la posición de slot Psych del sprite anterior:
	-- slotPsychX = current.x - current._slotConversionX - current._charOffsetX
	sprite._charOffsetX = posX
	sprite._charOffsetY = posY

	if current then
		-- Change Character mid-song: recuperar slot Psych del personaje saliente y reusar.
		local slotX = (current.x or 0) - (current._slotConversionX or 0) - (current._charOffsetX or 0)
		local slotY = (current.y or 0) - (current._slotConversionY or 0) - (current._charOffsetY or 0)
		sprite.x = slotX + slotConvX + posX
		sprite.y = slotY + slotConvY + posY
	else
		-- Primera carga: solo el offset del personaje + conversión de coordenadas.
		-- stages.lua sumará el slot Psych real en su M.apply().
		sprite.x = slotConvX + posX
		sprite.y = slotConvY + posY
	end

	_G[slot] = sprite

	return true, entry
end

-- Expuesto para el editor de charts (selector de personajes).
M.REGISTRY = REGISTRY

return M
