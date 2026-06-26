-- Puerto 1:1 de states/stages/School.hx:
--   treeLeaves = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
-- x,y/escala los sigue fijando stages/school/stage.lua después de cargar --
-- acá solo se modernizó la fuente de frames (atlas real en vez de tabla
-- hardcodeada). setFilter("nearest") se mantiene (pixel art).
local bgsprite = require("charts.psych.bgsprite")

local sprite = bgsprite.new("week6/petals", 0, 0, {"PETALS ALL"}, true)
sprite:getSheet():setFilter("nearest", "nearest")
return sprite
