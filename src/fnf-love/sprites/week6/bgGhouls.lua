-- Puerto 1:1 de states/stages/SchoolEvil.hx (eventPushed "Trigger BG Ghouls"):
--   bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
-- x,y/escala los sigue fijando stages/school/stage.lua después de cargar --
-- acá solo se modernizó la fuente de frames (atlas real en vez de tabla
-- hardcodeada). Nombre real de Psych ("BG freaks glitch instance"), no
-- "anim" -- setFilter("nearest") se mantiene (pixel art).
local bgsprite = require("charts.psych.bgsprite")

local sprite = bgsprite.new("week6/bgGhouls", 0, 0, {"BG freaks glitch instance"}, false)
sprite:getSheet():setFilter("nearest", "nearest")
return sprite
