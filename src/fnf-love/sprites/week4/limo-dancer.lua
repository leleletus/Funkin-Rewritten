-- Puerto 1:1 de states/stages/objects/BackgroundDancer.hx:
--   animation.addByIndices('danceLeft',  'bg dancer sketch PINK', [0..14],  ...);
--   animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15..29], ...);
-- x,y los sigue fijando stages/limo/stage.lua después de cargar -- acá solo
-- se modernizó la fuente de frames (atlas real en vez de tabla
-- hardcodeada).
--
-- BUG real arreglado: a esta sprite SIEMPRE le faltó el .png (no existía
-- en el repo -- los 5 bailarines de fondo de Limo crasheaban al cargar
-- cualquier canción de Week 4).
local bgsprite = require("charts.psych.bgsprite")

local indicesLeft, indicesRight = {}, {}
for i = 0, 14 do indicesLeft[#indicesLeft + 1] = i end
for i = 15, 29 do indicesRight[#indicesRight + 1] = i end

return bgsprite.new("week4/limo-dancer", 0, 0, {
	{name = "danceLeft",  prefix = "bg dancer sketch PINK", indices = indicesLeft},
	{name = "danceRight", prefix = "bg dancer sketch PINK", indices = indicesRight},
})
