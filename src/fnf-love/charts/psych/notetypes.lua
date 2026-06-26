-- Equivalente de backend/NoteTypesConfig.hx: tipos de nota personalizados
-- definidos en custom_notetypes/<nombre>.txt (uno por archivo), aplicados
-- sobre las notas generadas en weeks:generateNotes() cuando noteTypeStr no
-- es uno de los 6 tipos incorporados de Psych ('', "Alt Animation", "Hey!",
-- "Hurt Note", "GF Sing", "No Animation").
--
-- Formato de cada línea (igual que NoteTypesConfig.hx):
--   propiedad: valor
--   propiedad = valor
-- "propiedad" admite notación con puntos y corchetes para anidar/indexar
-- (p.ej. "extraData.spawnAnim", "colorSwap[0]"). El valor se interpreta como
-- booleano/número/null/string, igual que _interpretValue de Psych. Líneas
-- vacías o que empiezan con "//" o "#" se ignoran.

local M = {}

-- cache[name] = lista de entradas, o `false` si el archivo no existe.
local cache = {}

-- Convierte el string crudo del valor a bool/number/nil/string.
local function interpretValue(raw)
	raw = raw:match("^%s*(.-)%s*$") -- trim

	if raw == "true" then return true end
	if raw == "false" then return false end
	if raw == "null" or raw == "nil" then return nil end

	local n = tonumber(raw)
	if n then return n end

	local quoted = raw:match('^"(.*)"$') or raw:match("^'(.*)'$")
	if quoted then return quoted end

	return raw
end

-- Parsea "a.b[2].c" en una lista de claves: {"a", "b", 3, "c"} (los índices
-- de Psych/Haxe son base 0 -> se les suma 1 para Lua).
local function parsePath(path)
	local keys = {}

	for segment in path:gmatch("[^.]+") do
		local name, index = segment:match("^([^%[]*)%[(%d+)%]$")
		if name then
			if name ~= "" then table.insert(keys, name) end
			table.insert(keys, tonumber(index) + 1)
		else
			table.insert(keys, segment)
		end
	end

	return keys
end

-- M.load(name): lee y parsea custom_notetypes/<name>.txt (cacheado).
-- Devuelve una lista de {path = {claves...}, value = valor}, o nil si el
-- archivo no existe.
function M.load(name)
	if not name or name == "" then return nil end

	if cache[name] ~= nil then
		return cache[name] or nil
	end

	local raw = love.filesystem.read("custom_notetypes/" .. name .. ".txt")
	if not raw then
		cache[name] = false
		return nil
	end

	local entries = {}

	for line in raw:gmatch("[^\r\n]+") do
		line = line:match("^%s*(.-)%s*$")

		if line ~= "" and not line:match("^//") and not line:match("^#") then
			local path, value = line:match("^(.-)%s*[:=]%s*(.*)$")

			if path and path ~= "" then
				table.insert(entries, {
					path = parsePath(path),
					value = interpretValue(value or ""),
				})
			end
		end
	end

	cache[name] = entries
	return entries
end

-- M.apply(note, name): aplica las propiedades de custom_notetypes/<name>.txt
-- directamente sobre la tabla `note` (asignación de campos/índices, sin
-- reflexión). "noteType" se ignora (ya viene del 4º elemento del chart);
-- "extraData.*" anida bajo note.extraData. Devuelve true si se aplicó algo.
function M.apply(note, name)
	local entries = M.load(name)
	if not entries then return false end

	for _, entry in ipairs(entries) do
		local keys = entry.path

		if keys[1] ~= "noteType" then
			local target = note

			for i = 1, #keys - 1 do
				local key = keys[i]
				if type(target[key]) ~= "table" then
					target[key] = {}
				end
				target = target[key]
			end

			target[keys[#keys]] = entry.value
		end
	end

	return true
end

-- M.list(): nombres de todos los custom_notetypes/*.txt disponibles (sin
-- extensión), ordenados — usado por el editor de charts para listar tipos.
function M.list()
	local names = {}

	if love.filesystem.getInfo("custom_notetypes") then
		for _, item in ipairs(love.filesystem.getDirectoryItems("custom_notetypes")) do
			local name = item:match("^(.+)%.txt$")
			if name then table.insert(names, name) end
		end
	end

	table.sort(names)
	return names
end

return M
