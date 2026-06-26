-- Parsers de atlas Psych Engine. Soporta los DOS formatos que usa Psych:
--
-- 1. Sparrow/Starling XML (<TextureAtlas><SubTexture .../></TextureAtlas>),
--    el caso normal para personajes (BOYFRIEND.xml, GF_assets.xml, ...).
--    Soporta el subconjunto necesario: <SubTexture> de un solo nivel con
--    atributos name/x/y/width/height/frameX/frameY/frameWidth/frameHeight,
--    más rotated="true" (confirmado que SÍ aparece en algunos atlas reales
--    -- Nene.xml de Weekend 1 tiene sus 90 frames con rotated="true" --
--    ver modules/graphics.lua:newSprite() para cómo se "des-rota" al cargar).
--
-- 2. "Packer" genérico de TexturePacker, texto plano, una línea por frame:
--    "nombre = x y width height" -- usado por un puñado de assets de Psych
--    (characters/spirit.txt, week6/weebTrees.txt). No tiene trim: frameX/
--    frameY=0, frameWidth/frameHeight=width/height.
--
-- A diferencia de una versión anterior de este archivo, el formato NO se
-- detecta por contenido -- eso resultó frágil (ver Paths.hx de Psych real).
-- Psych decide el formato por EXISTENCIA de archivo (Paths.getAtlas():
-- si existe <key>.xml -> Sparrow; si no, si existe <key>.json -> TexturePacker
-- JSON; si no, cae a <key>.txt -> packer). character.lua/bgsprite.lua
-- replican esa misma lógica de existencia y llaman explícitamente a
-- M.loadSparrow() o M.loadPacker() según cuál archivo encontraron.

local M = {}

local cache = {}

local function parseSparrow(raw)
	local frames = {}

	for tag in raw:gmatch("<SubTexture(.-)/>") do
		local attrs = {}
		for key, value in tag:gmatch('(%a+)="(.-)"') do
			attrs[key] = value
		end

		local width = tonumber(attrs.width) or 0
		local height = tonumber(attrs.height) or 0

		table.insert(frames, {
			name = attrs.name,
			x = tonumber(attrs.x) or 0,
			y = tonumber(attrs.y) or 0,
			width = width,
			height = height,
			frameX = tonumber(attrs.frameX) or 0,
			frameY = tonumber(attrs.frameY) or 0,
			frameWidth = tonumber(attrs.frameWidth) or width,
			frameHeight = tonumber(attrs.frameHeight) or height,
			rotated = attrs.rotated == "true",
		})
	end

	return frames
end

local function parsePacker(raw)
	local frames = {}

	for line in raw:gmatch("[^\r\n]+") do
		local name, x, y, w, h = line:match("^%s*(.-)%s*=%s*(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s*$")
		if name then
			local width = tonumber(w) or 0
			local height = tonumber(h) or 0

			table.insert(frames, {
				name = name,
				x = tonumber(x) or 0,
				y = tonumber(y) or 0,
				width = width,
				height = height,
				frameX = 0,
				frameY = 0,
				frameWidth = width,
				frameHeight = height,
			})
		end
	end

	return frames
end

local function loadCached(path, parser)
	if cache[path] then return cache[path] end

	local raw, err = love.filesystem.read(path)
	if not raw then
		error("no se pudo leer el atlas '" .. path .. "': " .. tostring(err))
	end

	local frames = parser(raw)
	cache[path] = frames
	return frames
end

-- path: ruta completa a un atlas Sparrow/Starling XML real (p.ej.
-- "images/png/characters/BOYFRIEND.xml"). Devuelve una lista ordenada (mismo
-- orden que el XML) de {name=, x=, y=, width=, height=, frameX=, frameY=,
-- frameWidth=, frameHeight=}
function M.loadSparrow(path)
	return loadCached(path, parseSparrow)
end

-- path: ruta completa a un atlas "packer" de TexturePacker en texto plano
-- (p.ej. "images/png/characters/spirit.txt"). Misma forma de salida que
-- M.loadSparrow().
function M.loadPacker(path)
	return loadCached(path, parsePacker)
end

return M
