-- Traduce nombres de animación del formato Psych Engine ("singLEFT", "singDOWN-alt",
-- "singUPmiss", ...) a la convención interna de FNF Rewritten ("left", "down alt",
-- "miss up", ...).

local DIRECTIONS = {
	LEFT  = "left",
	DOWN  = "down",
	UP    = "up",
	RIGHT = "right",
}

local M = {}

-- name: string del lado Psych (value1 de "Play Animation", "Alt Idle Animation", etc.)
-- Devuelve el nombre interno equivalente. Si no se reconoce el patrón, se
-- devuelve tal cual (graphics.lua ya ignora con un WARN las animaciones
-- inexistentes, así que nunca rompe el juego).
function M.toInternal(name)
	if type(name) ~= "string" then return name end

	-- singLEFT-alt / singLEFT-ALT -> "left alt"
	local dir = name:match("^sing(%u+)%-[Aa][Ll][Tt]$")
	if dir and DIRECTIONS[dir] then
		return DIRECTIONS[dir] .. " alt"
	end

	-- singLEFTmiss -> "miss left"
	dir = name:match("^sing(%u+)miss$")
	if dir and DIRECTIONS[dir] then
		return "miss " .. DIRECTIONS[dir]
	end

	-- singLEFT -> "left"
	dir = name:match("^sing(%u+)$")
	if dir and DIRECTIONS[dir] then
		return DIRECTIONS[dir]
	end

	-- "-alt" suelto al final (p.ej. usado por "Alt Idle Animation" con "idle-alt")
	local base = name:match("^(.-)%-[Aa][Ll][Tt]$")
	if base then
		return base .. " alt"
	end

	return name
end

return M
