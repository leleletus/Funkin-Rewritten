-- Parser de atlas Sparrow/Starling XML (<TextureAtlas><SubTexture .../></TextureAtlas>),
-- usado por charts/psych/character.lua para leer los spritesheets de
-- personajes en formato Psych Engine (BOYFRIEND.xml, GF_assets.xml,
-- DADDY_DEAREST.xml, ...).
--
-- Soporta el subconjunto necesario para estos atlas: <SubTexture> de un solo
-- nivel con atributos name/x/y/width/height/frameX/frameY/frameWidth/frameHeight
-- (sin tags anidados ni rotated="true", que no aparecen en estos archivos).

local M = {}

local cache = {}

-- xmlPath: ruta completa al .xml (p.ej. "images/png/characters/BOYFRIEND.xml")
-- Devuelve una lista ordenada (mismo orden que el XML) de
-- {name=, x=, y=, width=, height=, frameX=, frameY=, frameWidth=, frameHeight=}
function M.load(xmlPath)
	if cache[xmlPath] then return cache[xmlPath] end

	local raw, err = love.filesystem.read(xmlPath)
	if not raw then
		error("no se pudo leer el atlas '" .. xmlPath .. "': " .. tostring(err))
	end

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
		})
	end

	cache[xmlPath] = frames

	return frames
end

return M
