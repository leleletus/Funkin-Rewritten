-- Puerto 1:1 de states/stages/objects/BackgroundTank.hx:
--   super('tankRolling', 0, 0, 0.5, 0.5, ['BG tank w lighting'], true);
-- x,y los sigue fijando stages/military/stage.lua (rotación incluida) --
-- acá solo se modernizó la fuente de frames (atlas real en vez de tabla
-- hardcodeada). Nombre real de Psych ("BG tank w lighting"), no "anim".
local bgsprite = require("charts.psych.bgsprite")
return bgsprite.new("week7/tankRolling", 0, 0, {"BG tank w lighting"}, true)
