-- Puerto 1:1 de states/stages/SchoolEvil.hx (schoolIntro(), cutscene de Roses):
--   senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
-- Nombre custom real de Psych ("idle", distinto del prefijo) -- x,y/escala
-- los sigue fijando stages/school/stage.lua después de cargar.
-- setFilter("nearest") se mantiene (pixel art).
local bgsprite = require("charts.psych.bgsprite")

local sprite = bgsprite.new("week6/senpaiCrazy", 0, 0, {
	{name = "idle", prefix = "Senpai Pre Explosion"},
})
sprite:getSheet():setFilter("nearest", "nearest")
return sprite
