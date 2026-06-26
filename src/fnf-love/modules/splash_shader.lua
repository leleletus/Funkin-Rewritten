-- Shader de tintado RGB para el splash "vanilla" de Psych Engine real.
--
-- El atlas vanilla (noteSplashes.png/.xml) usa el MISMO arte en rojo/verde
-- para los 4 colores -- Psych real lo recolorea con un shader que remapea
-- canal por canal: el rojo del sprite se reemplaza por el color "r" de la
-- flecha, el verde por el color "g" (blanco, en los 4 carriles, por default),
-- y el azul (no usado en este atlas) por "b". Ver
-- FNF-PsychEngine-main/source/objects/NoteSplash.hx (PixelSplashShader) y
-- ClientPrefs.hx (arrowRGB default).
--
-- Esto reemplaza la necesidad de tener 4 imágenes de splash distintas: el
-- mismo sprite + este shader producen los 4 colores.
--
-- UN shader por carril, con los uniforms fijados UNA SOLA VEZ al crearlo
-- (no un shader compartido reconfigurado en cada fireSplash) -- varios
-- splashes de carriles distintos pueden estar vivos a la vez (activeSplashes
-- guarda instancias independientes), y si reusáramos un solo shader
-- reescribiendo sus uniforms en cada disparo, todos los splashes vivos se
-- dibujarían con el último color seteado, sin importar su carril real.

local M = {}

local SHADER_SRC = [[
	extern vec3 splashR;
	extern vec3 splashG;
	extern vec3 splashB;

	vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 screenCoord)
	{
		vec4 texColor = Texel(tex, texCoord);
		vec3 newRGB = min(texColor.r * splashR + texColor.g * splashG + texColor.b * splashB, vec3(1.0));
		return vec4(newRGB, texColor.a) * color;
	}
]]

-- Colores reales default de Psych (ClientPrefs.hx arrowRGB), uno por carril
-- en el orden de Note.colArray = ['purple','blue','green','red'] (= left,
-- down, up, right). Cada entrada es {r, g, b} -- los TRES colores que el
-- shader usa para remapear los canales rojo/verde/azul del sprite (no son
-- componentes de un solo color). El canal "g" es blanco en los 4 carriles
-- en Psych real -- así sale el centro brillante característico del splash.
local LANE_RGB = {
	{ {0.7608, 0.2941, 0.6000}, {1, 1, 1}, {0.2353, 0.1216, 0.3373} }, -- left / purple
	{ {0.0000, 1.0000, 1.0000}, {1, 1, 1}, {0.0824, 0.2588, 0.7176} }, -- down / blue
	{ {0.0706, 0.9804, 0.0196}, {1, 1, 1}, {0.0392, 0.2667, 0.2784} }, -- up / green
	{ {0.9765, 0.2235, 0.2471}, {1, 1, 1}, {0.3961, 0.0627, 0.2196} }, -- right / red
}

local laneShaders = {}

-- laneIdx: 1=left, 2=down, 3=up, 4=right (mismo orden que boyfriendArrows).
-- Devuelve el shader YA tintado para ese carril (creado una sola vez, lazy).
function M.forLane(laneIdx)
	local sh = laneShaders[laneIdx]
	if not sh then
		sh = love.graphics.newShader(SHADER_SRC)
		local rgb = LANE_RGB[laneIdx] or LANE_RGB[1]
		sh:send("splashR", rgb[1])
		sh:send("splashG", rgb[2])
		sh:send("splashB", rgb[3])
		laneShaders[laneIdx] = sh
	end
	return sh
end

return M
